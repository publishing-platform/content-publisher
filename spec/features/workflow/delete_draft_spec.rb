require "rails_helper"

RSpec.feature "Delete draft", type: :feature do
  before do
    stub_publishing_api_has_linkables([], document_type: "organisation")
  end

  scenario do
    given_there_is_an_edition
    when_i_visit_the_summary_page
    and_i_delete_the_draft
    then_i_see_the_edition_is_gone
    and_the_draft_is_discarded
  end

  def given_there_is_an_edition
    @image_revision = create(:image_revision, :on_asset_manager)
    @edition = create(:edition,
                      lead_image_revision: @image_revision)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
    expect(page).to have_content(@edition.title)
  end

  def and_i_delete_the_draft
    @content_request = stub_publishing_api_discard_draft(@edition.content_id)
    @image_request = stub_asset_manager_deletes_any_asset

    click_on "Delete draft"
    expect(page).to have_content("Are you sure you want to delete this draft?")

    click_on "Yes, delete draft"
  end

  def then_i_see_the_edition_is_gone
    expect(page).to have_current_path(documents_path, ignore_query: true)
    expect(page).not_to have_content @edition.title
  end

  def and_the_draft_is_discarded
    expect(@content_request).to have_been_requested
    # TODO: Re-enable this check when Asset Manager supports deleting images associated with deleted drafts
    # expect(@image_request).to have_been_requested.at_least_once
  end
end

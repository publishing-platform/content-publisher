require "rails_helper"

RSpec.feature "Remove a document", type: :feature do
  scenario do
    given_there_is_a_published_edition
    when_i_visit_the_summary_page
    and_i_click_on_remove
    and_i_confirm_the_removal
    then_i_see_the_document_has_been_removed
  end

  def given_there_is_a_published_edition
    @edition = create(:edition, :published)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
    expect(page).to have_content(@edition.title)
  end

  def and_i_click_on_remove
    click_on "Remove"
  end

  def and_i_confirm_the_removal
    freeze_time do
      expect(page).to have_content(I18n.t!("remove.new.title", title: @edition.title))

      body = {
        type: "gone",
        unpublished_at: Time.zone.now,
      }

      stub_asset_manager_deletes_any_asset
      stub_publishing_api_unpublish(@edition.content_id, body:)
      click_on "Remove document"
    end
  end

  def then_i_see_the_document_has_been_removed
    expect(page).to have_content(I18n.t!("user_facing_states.removed.name"))
  end
end

require "rails_helper"

RSpec.feature "Delete a file attachment", type: :feature do
  scenario "inline" do
    given_there_is_an_edition_with_attachments
    when_i_insert_an_attachment
    and_i_delete_the_attachment
    and_i_confirm_the_deletion
    then_i_am_told_the_attachment_is_gone
    and_i_see_the_attachment_is_gone
  end

  scenario "featured" do
    given_there_is_an_edition_with_featured_attachments
    when_i_go_to_change_an_attachment
    and_i_delete_the_attachment
    and_i_confirm_the_deletion
    then_i_see_the_attachment_is_gone
  end

  def given_there_is_an_edition_with_attachments
    @attachment_revision = create(:file_attachment_revision, :on_asset_manager)

    @edition = create(:edition,
                      document_type: build(:document_type, :with_body),
                      file_attachment_revisions: [@attachment_revision])
  end

  def given_there_is_an_edition_with_featured_attachments
    @attachment_revision = create(:file_attachment_revision)

    @edition = create(:edition,
                      document_type: build(:document_type, attachments: "featured"),
                      file_attachment_revisions: [@attachment_revision])
  end

  def when_i_insert_an_attachment
    visit content_path(@edition.document)
    expect(page).to have_selector("form textarea[name=body]")

    click_on "Insert attachment"
  end

  def when_i_go_to_change_an_attachment
    visit document_path(@edition.document)
    expect(page).to have_selector("a", text: "Change Attachments")

    click_on "Change Attachments"
  end

  def and_i_delete_the_attachment
    stub_publishing_api_put_content(@edition.content_id, {})
    expect(page).to have_selector(".gem-c-attachment__metadata")
    click_on "Delete attachment"
  end

  def and_i_confirm_the_deletion
    expect(page).to have_content("Are you sure you want to delete this attachment?")
    click_on "Yes, delete attachment"
  end

  def then_i_am_told_the_attachment_is_gone
    expect(page).to have_content(I18n.t!("file_attachments.index.flashes.deleted", file: @attachment_revision.filename))
  end

  def then_i_see_the_attachment_is_gone
    expect(page).not_to have_selector(".gem-c-attachment__metadata")
  end

  alias_method :and_i_see_the_attachment_is_gone, :then_i_see_the_attachment_is_gone
end

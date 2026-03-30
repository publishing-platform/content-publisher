require "rails_helper"

RSpec.feature "Edit a file attachment", type: :feature do
  scenario do
    given_there_is_an_edition_with_featured_attachments
    when_i_go_to_edit_an_attachment
    and_i_edit_the_attachment_metadata
    then_i_see_the_attachment_is_updated
  end

  def given_there_is_an_edition_with_featured_attachments
    @attachment_revision = create(:file_attachment_revision)

    @edition = create(:edition,
                      document_type: build(:document_type, attachments: "featured"),
                      file_attachment_revisions: [@attachment_revision])
  end

  def when_i_go_to_edit_an_attachment
    visit featured_attachments_path(@edition.document)
    expect(page).to have_content(I18n.t!("featured_attachments.index.title", title: @edition.title))

    click_on "Edit details"
    expect(page).to have_content(I18n.t!("file_attachments.edit.title", title: @edition.title))
  end

  def and_i_edit_the_attachment_metadata
    stub_publishing_api_put_content(@edition.content_id, {})
    stub_asset_manager_receives_an_asset

    unique_ref = "REF"
    isbn = "9788700631625"
    @metadata = "Ref: ISBN #{isbn}, #{unique_ref}"

    fill_in "file_attachment[unique_reference]", with: unique_ref
    fill_in "file_attachment[isbn]", with: isbn

    click_on "Save"
  end

  def then_i_see_the_attachment_is_updated
    expect(page).to have_content(@metadata)
  end
end

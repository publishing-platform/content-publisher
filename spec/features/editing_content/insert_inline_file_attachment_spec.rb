require "rails_helper"

RSpec.feature "Insert inline file attachment", type: :feature do
  scenario "without javascript" do
    given_there_is_an_edition_with_file_attachments
    when_i_go_to_edit_the_edition
    and_i_click_to_insert_a_file_attachment
    then_i_see_previously_uploaded_file_attachments
    when_i_choose_one_of_the_file_attachments
    then_i_see_the_attachment_markdown_snippet
    and_i_see_the_attachment_link_markdown_snippet
  end

  def given_there_is_an_edition_with_file_attachments
    @file_attachment_revision = create(:file_attachment_revision,
                                       :on_asset_manager,
                                       filename: "foo.pdf")
    @edition = create(:edition,
                      document_type: build(:document_type, :with_body),
                      file_attachment_revisions: [@file_attachment_revision])
  end

  def when_i_go_to_edit_the_edition
    visit content_path(@edition.document)
    expect(page).to have_selector("form textarea[name=body]")
  end

  def and_i_click_to_insert_a_file_attachment
    click_on "Insert attachment"
  end

  def when_i_choose_one_of_the_file_attachments
    click_on "Insert attachment"
  end

  def then_i_see_previously_uploaded_file_attachments
    expect(page).to have_selector(".app-c-media-with-actions", count: 1)
  end

  def then_i_see_the_attachment_markdown_snippet
    snippet = I18n.t("file_attachments.show.attachment_markdown",
                     filename: @file_attachment_revision.filename)
    expect(page).to have_content(snippet)
  end

  def and_i_see_the_attachment_link_markdown_snippet
    snippet = I18n.t("file_attachments.show.attachment_link_markdown",
                     filename: @file_attachment_revision.filename)
    expect(page).to have_content(snippet)
  end
end

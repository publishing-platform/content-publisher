require "rails_helper"

RSpec.describe "Insert inline image", type: :system do
  scenario "without javascript" do
    given_there_is_an_edition_with_images
    when_i_go_to_edit_the_edition
    and_i_click_to_insert_an_image
    then_i_see_the_image_markdown_snippet
  end

  def given_there_is_an_edition_with_images
    @image_revision = create(:image_revision,
                             :on_asset_manager,
                             filename: "foo.jpg")
    @edition = create(:edition,
                      document_type: build(:document_type, :with_body),
                      image_revisions: [@image_revision])
  end

  def when_i_go_to_edit_the_edition
    visit content_path(@edition.document)
  end

  def and_i_click_to_insert_an_image
    click_on "Insert image"
  end

  def then_i_see_the_image_markdown_snippet
    switch_to_window(page.windows.last)
    snippet = I18n.t("images.index.meta.inline_code.value", filename: @image_revision.filename)
    expect(page).to have_content(snippet)
  end
end

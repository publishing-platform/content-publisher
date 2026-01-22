require "rails_helper"

RSpec.describe "Delete an image", type: :system do
  scenario "non-lead image" do
    given_there_is_an_edition_with_images
    when_i_visit_the_images_page
    and_i_delete_the_image
    and_i_confirm_the_deletion
    then_i_see_the_image_is_gone
  end

  scenario "lead image" do
    given_there_is_an_edition_with_a_lead_image
    when_i_visit_the_images_page
    when_i_delete_the_lead_image
    and_i_confirm_the_deletion
    then_i_see_the_lead_image_is_gone
  end

  scenario "inline image" do
    given_there_is_an_edition_with_images
    when_i_insert_an_inline_image
    and_i_delete_the_image
    and_i_confirm_the_deletion
    then_i_see_the_image_is_gone
  end

  def given_there_is_an_edition_with_a_lead_image
    document_type = build(:document_type, :with_lead_image)
    @image_revision = create(:image_revision, :on_asset_manager)

    @edition = create(:edition,
                      document_type:,
                      lead_image_revision: @image_revision)
  end

  def given_there_is_an_edition_with_images
    document_type = build(:document_type, :with_body, :with_lead_image)
    @image_revision = create(:image_revision, :on_asset_manager)

    @edition = create(:edition,
                      document_type:,
                      image_revisions: [@image_revision])
  end

  def when_i_visit_the_images_page
    visit images_path(@edition.document)
  end

  def when_i_insert_an_inline_image
    visit content_path(@edition.document)

    click_on "Insert image"
  end

  def and_i_delete_the_image
    stub_publishing_api_put_content(@edition.content_id, {})
    click_on "Delete image"
  end

  def when_i_delete_the_lead_image
    stub_publishing_api_put_content(@edition.content_id, {})
    click_on "Delete lead image"
  end

  def and_i_confirm_the_deletion
    click_on "Yes, delete image"
  end

  def then_i_see_the_image_is_gone
    expect(page).to have_content(I18n.t!("images.index.flashes.deleted", file: @image_revision.filename))
    expect(page).not_to have_selector("#image-#{@image_revision.image_id}")
  end

  def then_i_see_the_lead_image_is_gone
    expect(page).to have_content(I18n.t!("images.index.flashes.lead_image.deleted", file: @image_revision.filename))
    expect(page).not_to have_selector("#image-#{@image_revision.image_id}")

    visit document_path(@edition.document)
    expect(page).to have_content(I18n.t!("documents.show.lead_image.no_lead_image"))
  end
end

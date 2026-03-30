require "rails_helper"

RSpec.feature "Choose a lead image", type: :feature do
  scenario "on the index page" do
    given_there_is_an_edition_with_images
    when_i_visit_the_images_page
    and_i_choose_one_of_the_images
    then_the_edition_has_a_lead_image
  end

  scenario "on the metadata page" do
    given_there_is_an_edition_with_images
    when_i_visit_the_edit_image_metadata_page
    and_i_tick_the_image_is_the_lead_image
    then_the_edition_has_a_lead_image
  end

  def given_there_is_an_edition_with_images
    document_type = build(:document_type, :with_lead_image)
    @image_revision = create(:image_revision,
                             :on_asset_manager,
                             alt_text: "image alt text")
    @edition = create(:edition,
                      document_type:,
                      image_revisions: [@image_revision])
  end

  def when_i_visit_the_images_page
    visit images_path(@edition.document)
  end

  def when_i_visit_the_edit_image_metadata_page
    stub_publishing_api_put_content(@edition.content_id, {})
    stub_asset_manager_updates_any_asset

    visit edit_image_path(@edition.document, @image_revision.image_id)
  end

  def and_i_tick_the_image_is_the_lead_image
    expect(find_field("lead_image").checked?).to be false
    check(I18n.t!("images.edit.form_labels.lead_image"))
    click_on "Save"
  end

  def and_i_choose_one_of_the_images
    stub_publishing_api_put_content(@edition.content_id, {})
    stub_asset_manager_updates_any_asset

    within("#image-#{@image_revision.image_id}") do
      click_on "Select as lead image"
    end
  end

  def then_the_edition_has_a_lead_image
    expect(find("#lead-image img")["src"]).to include(@image_revision.filename)
    expect(page).to have_content(I18n.t!("documents.show.flashes.lead_image.selected", file: @image_revision.filename))
  end
end

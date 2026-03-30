require "rails_helper"

RSpec.feature "Reorder attachments", type: :feature do
  scenario "without javascript" do
    given_there_is_an_edition_with_attachments
    when_i_go_to_the_attachments_page
    and_i_click_to_reorder_the_attachments
    then_i_see_the_current_attachment_order
    and_i_change_the_numeric_positions
    then_i_see_the_order_is_updated
  end

  scenario "with javascript", :js do
    given_there_is_an_edition_with_attachments
    when_i_go_to_the_attachments_page
    and_i_click_to_reorder_the_attachments
    then_i_see_the_current_attachment_order
    and_i_move_an_attachment_up
    then_i_see_the_order_is_updated
  end

  def given_there_is_an_edition_with_attachments
    @attachment_revision1 = create(:file_attachment_revision)
    @attachment_revision2 = create(:file_attachment_revision)

    @edition = create(:edition,
                      document_type: build(:document_type, attachments: "featured"),
                      file_attachment_revisions: [@attachment_revision1, @attachment_revision2])
  end

  def when_i_go_to_the_attachments_page
    visit featured_attachments_path(@edition.document)
    expect(page).to have_content("Attachments for ‘#{@edition.title}’")
  end

  def and_i_click_to_reorder_the_attachments
    click_on "Reorder attachments"
    stub_any_publishing_api_put_content
    stub_asset_manager_receives_an_asset
  end

  def then_i_see_the_current_attachment_order
    expect(page).to have_content("Reorder attachments for ‘#{@edition.title}’")
    expect(all(".gem-c-reorderable-list__title", count: 2).map(&:text)).to eq([
      @attachment_revision1.title, @attachment_revision2.title
    ])
  end

  def and_i_change_the_numeric_positions
    fill_in "Position for #{@attachment_revision1.title}", with: 2
    fill_in "Position for #{@attachment_revision2.title}", with: 1
    click_on "Save attachment order"
  end

  def and_i_move_an_attachment_up
    all("button", text: "Up").last.click
    click_on "Save attachment order"
  end

  def then_i_see_the_order_is_updated
    expect(all(".gem-c-attachment__title", count: 2).map(&:text)).to eq([
      @attachment_revision2.title,
      @attachment_revision1.title,
    ])
  end
end

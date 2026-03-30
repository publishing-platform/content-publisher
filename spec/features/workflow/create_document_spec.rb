require "rails_helper"

RSpec.feature "Create a document", type: :feature do
  before do
    # Ensure there is a current user for the duration of the test
    create(:user)
    stub_publishing_api_has_linkables([], document_type: "organisation")
  end

  scenario do
    given_i_am_on_the_home_page
    when_i_click_to_create_a_document
    and_i_select_a_supertype
    and_i_select_a_document_type
    and_i_fill_in_the_contents
    then_i_see_the_document_summary
  end

  def given_i_am_on_the_home_page
    visit root_path
    expect(page).to have_content(I18n.t!("documents.index.title"))
  end

  def when_i_click_to_create_a_document
    click_on "Create new document"
  end

  def and_i_select_a_supertype
    expect(page).to have_content(I18n.t("document_type_selections.root.label"))

    choose I18n.t("document_type_selections.news.label")
    click_on "Continue"
  end

  def and_i_select_a_document_type
    expect(page).to have_content(I18n.t("document_type_selections.news.label"))

    choose I18n.t("document_type_selections.news_story.label")
    click_on "Continue"
  end

  def and_i_fill_in_the_contents
    stub_any_publishing_api_put_content
    stub_publishing_api_has_lookups({})

    document_type = I18n.t("document_type_selections.news_story.label").downcase
    expect(page).to have_content(I18n.t("content.edit.title_new", document_type:))

    fill_in "title", with: "A title"
    fill_in "summary", with: "A summary"
    click_on "Save"
  end

  def then_i_see_the_document_summary
    expect(page).to have_content(I18n.t!("user_facing_states.draft.name"))
    expect(page).to have_content("A summary")
  end
end

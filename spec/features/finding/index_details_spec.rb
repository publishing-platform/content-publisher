require "rails_helper"

RSpec.feature "Index details", type: :feature do
  before do
    stub_publishing_api_has_linkables([], document_type: "organisation")
  end

  scenario do
    given_there_is_an_edition
    when_i_visit_the_index_page
    then_i_can_see_the_edition
  end

  def given_there_is_an_edition
    @edition = create(:edition)
  end

  def when_i_visit_the_index_page
    visit documents_path
  end

  def then_i_can_see_the_edition
    expect(page).to have_content(@edition.title)
    expect(page).to have_content(@edition.document_type.label)
    expect(page).to have_content(I18n.t!("user_facing_states.draft.name"))
    expect(page).to have_content(@edition.updated_at.to_fs(:time_on_date))
  end
end

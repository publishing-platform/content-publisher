require "rails_helper"

RSpec.describe "Edit tags", type: :system do
  let(:initial_tag_content) { "Initial tag" }
  let(:initial_tag_content_id) { SecureRandom.uuid }
  let(:tag_to_select_content) { "Tag to select" }
  let(:single_tag_field_id) { "primary_publishing_organisation" }

  scenario do
    given_there_is_an_edition
    when_i_visit_the_summary_page
    and_i_click_on_edit_tags
    then_i_see_the_current_selections
    when_i_edit_the_tags
    then_i_can_see_the_tags
  end

  def given_there_is_an_edition
    all_tags = DocumentType.all.flat_map(&:tags).uniq(&:class)
    tag_linkables = [
      { "content_id" => initial_tag_content_id, "internal_name" => initial_tag_content },
      { "content_id" => SecureRandom.uuid, "internal_name" => tag_to_select_content },
    ]

    all_tags.each do |tag|
      stub_publishing_api_has_linkables(tag_linkables, document_type: tag.id.singularize)
    end

    # TODO: remove the line below once a document type has organisations tag
    stub_publishing_api_has_linkables(tag_linkables, document_type: "organisation")

    initial_tags = {
      single_tag_field_id => [initial_tag_content_id],
    }

    @edition = create(:edition,
                      document_type: build(:document_type, tags: all_tags),
                      tags: initial_tags)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_edit_tags
    click_on "Change Tags"
  end

  def then_i_see_the_current_selections
    @request = stub_publishing_api_put_content(@edition.content_id, {})
    expect(page).to have_select("#{single_tag_field_id}[]", selected: initial_tag_content)
  end

  def when_i_edit_the_tags
    select tag_to_select_content, from: "#{single_tag_field_id}[]"
    click_on "Save"
  end

  def then_i_can_see_the_tags
    within("#tags") do
      expect(page).to have_content(tag_to_select_content)
      expect(page).not_to have_content(initial_tag_content)
    end
  end
end

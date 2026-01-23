require "rails_helper"

RSpec.describe "Publish without review", type: :system do
  scenario do
    given_there_is_an_edition
    when_i_visit_the_summary_page
    and_i_publish_without_review
    then_i_see_the_publish_succeeded
    and_the_editors_receive_an_email

    when_i_visit_the_summary_page
    then_i_see_it_has_not_been_reviewed

    when_i_click_the_approve_button
    then_i_see_that_its_reviewed
  end

  def given_there_is_an_edition
    @me = create(:user) # current_user
    @creator = create(:user, email: "someone@example.com")

    @edition = create(:edition,
                      :publishable,
                      created_by: @creator,
                      created_at: 1.day.ago,
                      base_path: "/news/banana-pricing-updates",
                      editors: [@creator])
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def when_i_click_the_approve_button
    click_on "Approve"
  end

  def and_i_publish_without_review
    perform_enqueued_jobs do
      travel_to(@publish_time = Time.zone.now) do
        click_on "Publish"
        choose I18n.t!("publish.confirmation.should_be_reviewed")
        stub_any_publishing_api_put_content
        stub_any_publishing_api_publish
        click_on "Confirm publish"
      end
    end
  end

  def then_i_see_the_publish_succeeded
    expect(page).to have_content(I18n.t!("publish.published.published_without_review.title"))
  end

  def then_i_see_it_has_not_been_reviewed
    expect(page).to have_content I18n.t!("user_facing_states.published_but_needs_2i.name")
  end

  def then_i_see_that_its_reviewed
    expect(page).to have_content(I18n.t!("documents.show.flashes.approved"))
    expect(page).to have_content(I18n.t!("user_facing_states.published.name"))
  end

  def and_the_editors_receive_an_email
    tos = ActionMailer::Base.deliveries.map(&:to)
    message = ActionMailer::Base.deliveries.first

    expect(tos).to contain_exactly([@creator.email], [current_user.email])
    expect(message.body).to have_content("https://www.test.publishing-platform.co.uk/news/banana-pricing-updates")
    expect(message.body).to have_content(document_path(@edition.document))

    expect(message.subject).to eq(I18n.t("publish_mailer.publish_email.subject.published_but_needs_2i",
                                         title: @edition.title))

    expect(message.body).to have_content(I18n.t("publish_mailer.publish_email.details.publish",
                                                datetime: @publish_time.to_fs(:time_on_date),
                                                user: current_user.name))
  end
end

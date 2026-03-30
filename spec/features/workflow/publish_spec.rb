require "rails_helper"

RSpec.feature "Publishing an edition", type: :feature do
  scenario do
    given_there_is_an_edition_in_draft
    when_i_visit_the_summary_page
    and_i_publish_the_edition
    then_i_see_the_publish_succeeded
    and_the_content_is_shown_as_published
    and_i_receive_a_confirmation_email
  end

  def given_there_is_an_edition_in_draft
    @me = create(:user) # current_user
    @creator = create(:user, email: "someone@example.com")

    @edition = create(:edition,
                      :publishable,
                      created_by: @creator,
                      base_path: "/news/banana-pricing-updates",
                      editors: [@creator])
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
    expect(page).to have_content(@edition.title)
  end

  def and_i_publish_the_edition
    perform_enqueued_jobs do
      travel_to(@publish_time = Time.zone.now) do
        stub_any_publishing_api_put_content
        @content_request = stub_publishing_api_publish(@edition.content_id, {})

        click_on "Publish"
        expect(page).to have_content(I18n.t!("publish.confirmation.title"))

        choose I18n.t!("publish.confirmation.has_been_reviewed")
        click_on "Confirm publish"
      end
    end
  end

  def then_i_see_the_publish_succeeded
    expect(page).to have_content(I18n.t!("publish.published.reviewed.title"))
    expect(@content_request).to have_been_requested
  end

  def and_the_content_is_shown_as_published
    visit document_path(@edition.document)
    expect(page).to have_content(I18n.t!("user_facing_states.published.name"))
    expect(page).to have_link("View on Publishing Platform", href: "https://www.test.publishing-platform.co.uk/news/banana-pricing-updates")
  end

  def and_i_receive_a_confirmation_email
    tos = ActionMailer::Base.deliveries.map(&:to)
    message = ActionMailer::Base.deliveries.first

    expect(tos).to contain_exactly([@creator.email], [current_user.email])
    expect(message.body).to have_content("https://www.test.publishing-platform.co.uk/news/banana-pricing-updates")
    expect(message.body).to have_content(document_path(@edition.document))

    expect(message.subject).to eq(I18n.t("publish_mailer.publish_email.subject.published",
                                         title: @edition.title))

    expect(message.body).to have_content(I18n.t("publish_mailer.publish_email.details.publish",
                                                datetime: @publish_time.to_fs(:time_on_date),
                                                user: current_user.name))
  end
end

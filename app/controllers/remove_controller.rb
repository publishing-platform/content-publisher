class RemoveController < ApplicationController
  def new
    @edition = Edition.find_current(document_id: params[:document_id])

    assert_edition_state(@edition, assertion: "is published") do
      @edition.published? || @edition.published_but_needs_2i?
    end
  end

  def create
    result = Remove::CreateInteractor.call(params:, user: current_user)
    edition, issues, api_error = result.to_h.values_at(:edition, :issues, :api_error)

    if issues
      flash.now["requirements"] = {
        "items" => issues.items(link_options: {
          redirect_url: { href: "#redirect_url-field" },
        }),
      }

      render :new,
             assigns: { edition:,
                        redirect_url: params[:redirect_url],
                        issues: },
             status: :unprocessable_entity
    elsif api_error
      flash.now["alert"] = t("remove.new.flashes.publishing_api_error")

      render :new,
             assigns: { edition:,
                        redirect_url: params[:redirect_url] },
             status: :service_unavailable
    else
      redirect_to document_path(edition.document)
    end
  end
end

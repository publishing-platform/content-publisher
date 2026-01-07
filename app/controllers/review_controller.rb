class ReviewController < ApplicationController
  def submit_for_2i
    result = Review::SubmitFor2iInteractor.call(params:, user: current_user)
    issues, api_error = result.to_h.values_at(:issues, :api_error)

    if api_error
      redirect_to document_path(params[:document_id]),
                  alert: t("documents.show.flashes.2i_error.description")
    elsif issues
      redirect_to document_path(params[:document_id]), tried_to_publish: true
    else
      redirect_to document_path(params[:document_id])
    end
  end

  def approve
    Review::ApproveInteractor.call(params:, user: current_user)

    redirect_to document_path(params[:document_id]),
                notice: t("documents.show.flashes.approved")
  end
end

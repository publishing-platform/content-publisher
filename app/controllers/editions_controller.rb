class EditionsController < ApplicationController
  def create
    # Editions::CreateInteractor.call(params:, user: current_user)
    # redirect_to content_path(params[:document_id])
  end

  def destroy_draft
    result = Editions::DestroyInteractor.call(params:, user: current_user)

    if result.api_error
      redirect_to document_path(params[:document_id]),
                  alert_with_description: t("documents.show.flashes.delete_draft_error")
    else
      redirect_to documents_path
    end
  end

  def confirm_delete_draft
    @edition = Edition.find_current(document_id: params[:document_id])
    assert_edition_state(@edition, &:editable?)
  end
end

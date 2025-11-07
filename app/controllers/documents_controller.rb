class DocumentsController < ApplicationController
  def index
    if filter_params.empty? && current_user.organisation_content_id
      redirect_to documents_path(organisation: current_user.organisation_content_id)
      return
    end

    filter = EditionFilter.new(filters: filter_params)
    @editions = filter.editions
    @filter_params = filter.filter_params
  end

  def new
    @document_type_selection = DocumentTypeSelection.find(params[:type] || "root")
  end

  def create
    Rails.logger.debug params[:selected_option_id]

    document_type_selection = DocumentTypeSelection.find(params[:type])
    selected_option = document_type_selection.find_option(params[:selected_option_id])

    redirect_to new_document_path(type: selected_option.id)
  end

private

  def filter_params
    params.permit(:title_or_url, :organisation, :document_type, :state)
  end
end

class DocumentsController < ApplicationController
  def index; end

  def new
    @document_type_selection = DocumentTypeSelection.find(params[:type] || "root")
  end

  def create
    Rails.logger.debug params[:selected_option_id]

    document_type_selection = DocumentTypeSelection.find(params[:type])
    selected_option = document_type_selection.find_option(params[:selected_option_id])

    redirect_to new_document_path(type: selected_option.id)
  end
end

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
    result = Documents::CreateInteractor.call(params:, user: current_user)

    if result.issues
      flash.now["requirements"] = { "items" => result.issues.items }

      render :new,
             assigns: {
              issues: result.issues,
              document_type_selection: result.document_type_selection
             },
             status: :unprocessable_entity
    else
      destination = if result.document
                      content_path(document)
                    else
                      new_document_path(type: result.selected_option.id)
                    end
                    
      redirect_to destination
    end
  end

private

  def filter_params
    params.permit(:title_or_url, :organisation, :document_type, :state)
  end
end

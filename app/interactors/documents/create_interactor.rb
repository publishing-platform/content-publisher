class Documents::CreateInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :document,
           :document_type_selection,
           :selected_option,
           to: :context
  def call
    find_selection
    check_for_issues
    return unless selected_option.document_type?

    create_document
  end

private

  def find_selection
    context.document_type_selection = DocumentTypeSelection.find(params[:type])
    context.selected_option = document_type_selection.find_option(params[:selected_option_id])
  end

end
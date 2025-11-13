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

  def check_for_issues
    issues = Requirements::CheckerIssues.new
    issues.create(:document_type_selection, :not_selected) unless selected_option

    context.fail!(issues:) if issues.any?
  end

  def create_document
    context.document = CreateDocumentService.call(
      document_type_id: selected_option.id, tags: default_tags, user:,
    )
  end

  def default_tags
    user.organisation_content_id ? { primary_publishing_organisation: [user.organisation_content_id] } : {}
  end
end

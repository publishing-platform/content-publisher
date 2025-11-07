class DocumentType::BodyField
  def id
    "body"
  end

  def payload(edition)
    {
      details: {
        body: [
          content_type: "text/markdown",
          content: edition.contents[id],
        ],
      },
    }
  end

  def updater_params(_edition, params)
    { contents: { body: params[:body] } }
  end

  def form_issues(_edition, _params)
    Requirements::CheckerIssues.new
  end

  def preview_issues(_edition)
    Requirements::CheckerIssues.new
  end

  def publish_issues(edition)
    issues = Requirements::CheckerIssues.new

    issues.create(id, :blank) if edition.contents[id].blank?
    issues
  end
end

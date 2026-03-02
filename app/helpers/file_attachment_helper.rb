module FileAttachmentHelper
  def file_attachment_preview_url(attachment_revision, edition)
    params = { token: edition.auth_bypass_token }.to_query
    "#{attachment_revision.asset_url}?#{params}"
  end

  def file_attachment_attributes(attachment_revision, edition)
    attributes = {
      id: attachment_revision.file_attachment_id,
      title: attachment_revision.title,
      filename: attachment_revision.filename,
      content_type: attachment_revision.content_type,
      file_size: attachment_revision.byte_size,
      number_of_pages: attachment_revision.number_of_pages,
      isbn: attachment_revision.isbn.presence,
      unique_reference: attachment_revision.unique_reference.presence,
      paper_number: attachment_revision.paper_number,
      url: preview_file_attachment_path(edition.document, attachment_revision.file_attachment),
    }

    attributes.compact
  end
end

class PublishingApiPayload::FileAttachmentPayload
  include Rails.application.routes.url_helpers
  include FileAttachmentHelper

  attr_reader :attachment, :edition

  def initialize(attachment, edition)
    @attachment = attachment
    @edition = edition
  end

  def payload
    payload = {
      id: attachment.file_attachment_id.to_s,
      attachment_type: "file",
      url: attachment.asset_url,
    }

    file_attachment_attributes(attachment, edition).merge!(payload)
  end
end

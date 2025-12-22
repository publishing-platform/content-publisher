class PreviewAssetService::Payload
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def for_update
    { draft: true, auth_bypass_ids: [edition.auth_bypass_id] }
  end

  def for_upload(asset)
    for_update.merge(
      file: PreviewAssetService::UploadedFile.new(asset),
      content_type: asset.content_type,
    )
  end
end

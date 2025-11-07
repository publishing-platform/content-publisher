module EditionUrlHelper
  def edition_public_url(edition)
    return unless edition.base_path

    PublishingPlatformLocation.website_root + edition.base_path
  end

  def edition_preview_url(edition)
    return unless edition.base_path

    host = PublishingPlatformLocation.external_url_for("draft-origin")
    params = { token: edition.auth_bypass_token }.to_query
    "#{host}#{edition.base_path}?#{params}"
  end
end

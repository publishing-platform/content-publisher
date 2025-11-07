class Linkables
  CACHE_OPTIONS = { expires_in: 5.minutes, race_condition_ttl: 10.seconds }.freeze

  attr_reader :document_type

  def initialize(document_type)
    @document_type = document_type
  end

  def select_options
    linkables.map { |content| [content["internal_name"], content["content_id"]] }
      .sort_by { |option| option[0].downcase }
  end

  def by_content_id(content_id)
    linkables.find { |l| l["content_id"] == content_id }
  end

private

  def linkables
    @linkables ||= Rails.cache.fetch("linkables.#{document_type}", CACHE_OPTIONS) do
      PublishingPlatformApi.publishing_api(timeout: 3).get_linkables(document_type:).to_hash
    end
  end
end

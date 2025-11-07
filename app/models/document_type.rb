class DocumentType
  include InitializeWithHash

  attr_reader :id,
              :label,
              :contents,
              :publishing_metadata,
              :path_prefix,
              :tags

  # class-level method
  def self.find(id)
    item = all.find { |document_type| document_type.id == id }
    item || (raise "Document type #{id} not found")
  end

  # class-level method
  def self.all
    @all ||= begin
      document_types = YAML.load_file(Rails.root.join("config/document_types.yml"), aliases: true)["document_types"]

      document_types.map do |document_type|
        document_type["contents"] = document_type["contents"].map do |field_id|
          "DocumentType::#{field_id.camelize}Field".constantize.new
        end

        document_type["tags"] = document_type["tags"].to_a.map do |field_id|
          "DocumentType::#{field_id.camelize}Field".constantize.new
        end

        document_type["publishing_metadata"] = PublishingMetadata.new(document_type["publishing_metadata"])
        new(document_type)
      end
    end
  end

  def self.clear
    @all = nil
  end

  def lead_image?
    @lead_image
  end

  def attachments
    ActiveSupport::StringInquirer.new(@attachments)
  end

  class PublishingMetadata
    include InitializeWithHash
    attr_reader :schema_name, :rendering_app
  end
end

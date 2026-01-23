class EditionFilter
  include ActiveRecord::Sanitization::ClassMethods

  attr_reader :filters

  def initialize(filters: {})
    @filters = filters.to_h.symbolize_keys
  end

  def editions
    revision_joins = { revision: %i[content_revision tags_revision metadata_revision] }
    scope = Edition.where(current: true)
                   .joins(revision_joins, :status, :document)
                   .preload(revision_joins, :status, :document, :last_edited_by)
    scope = filtered_scope(scope)
    ordered_scope(scope)
  end

  def filter_params
    filters
  end

private

  def filtered_scope(scope)
    filters.inject(scope) do |memo, (field, value)|
      next memo if value.blank?

      case field
      when :title_or_url
        memo.where("content_revisions.title ILIKE ? OR content_revisions.base_path ILIKE ?",
                   "%#{sanitize_sql_like(value)}%",
                   "%#{sanitize_sql_like(value)}%")
      when :document_type
        memo.where("metadata_revisions.document_type_id": value)
      when :state
        if value == "published"
          memo.where("statuses.state": %w[published published_but_needs_2i])
        else
          memo.where("statuses.state": value)
        end
      when :organisation
        memo.merge(TagsRevision.primary_organisation_is(value))
      else
        memo
      end
    end
  end

  def ordered_scope(scope)
    scope.order("editions.last_edited_at desc")
  end
end

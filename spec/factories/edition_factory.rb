FactoryBot.define do
  factory :edition do
    last_edited_at { Time.zone.now }
    current { true }
    live { false }
    revision_synced { true }
    association :created_by, factory: :user
    last_edited_by { created_by }
    editors { [created_by] }

    revision_fields

    transient do
      content_id { SecureRandom.uuid }
      document_type { build(:document_type, path_prefix: "/prefix") }
      state { "draft" }
      first_published_at { nil }
      change_history { [] }
    end

    after(:build) do |edition, evaluator|
      unless edition.document
        args = [:document,
                evaluator.live ? :live : nil,
                { created_by: edition.created_by,
                  content_id: evaluator.content_id,
                  first_published_at: evaluator.first_published_at }]
        edition.document = evaluator.association(*args.compact)
      end

      edition.number = edition.document&.next_edition_number unless edition.number

      unless edition.revision
        edition.revision = evaluator.association(
          :revision,
          created_by: edition.created_by,
          document: edition.document,
          document_type_id: evaluator.document_type_id,
          title: evaluator.title,
          summary: evaluator.summary,
          base_path: evaluator.base_path,
          contents: evaluator.contents,
          tags: evaluator.tags,
          update_type: evaluator.update_type,
          change_note: evaluator.change_note,
          change_history: evaluator.change_history,
        )
      end

      unless edition.status
        edition.status = evaluator.association(
          :status,
          created_by: edition.created_by,
          revision_at_creation: edition.revision,
          state: evaluator.state,
        )
      end
    end

    trait :publishable do
      summary { SecureRandom.alphanumeric(10) }
    end

    trait :not_publishable do
      summary { "" }
    end

    trait :published do
      summary { SecureRandom.alphanumeric(10) }
      live { true }
      first_published_at { Time.zone.now }
      published_at { Time.zone.now }

      transient do
        state { "published" }
      end

      after(:build) do |edition, evaluator|
        edition.status = evaluator.association(
          :status,
          created_by: edition.created_by,
          state: evaluator.state,
          revision_at_creation: edition.revision,
          created_at: evaluator.published_at,
        )
      end
    end

    trait :published_but_needs_2i do
      published

      transient do
        state { "published_but_needs_2i" }
      end
    end

    trait :removed do
      live { true }

      after(:build) do |edition, evaluator|
        edition.status = evaluator.association(
          :status,
          :removed,
          created_by: edition.created_by,
          revision_at_creation: edition.revision,
        )
      end
    end

    trait :failed_to_publish do
      summary { SecureRandom.alphanumeric(10) }

      transient do
        scheduling { nil }
      end

      after(:build) do |edition, evaluator|
        edition.status = evaluator.association(
          :status,
          :failed_to_publish,
          created_by: edition.created_by,
          revision_at_creation: edition.revision,
          scheduling: evaluator.scheduling,
        )
      end
    end
  end
end

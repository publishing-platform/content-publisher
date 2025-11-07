FactoryBot.define do
  factory :status do
    state { :draft }
    association :created_by, factory: :user
    association :revision_at_creation, factory: :revision

    trait :published do
      state { :published }
    end

    trait :published_but_needs_2i do
      state { :published_but_needs_2i }
    end

    trait :removed do
      state { :removed }
    end

    trait :failed_to_publish do
      state { :failed_to_publish }
    end
  end
end

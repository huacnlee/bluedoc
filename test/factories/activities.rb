FactoryBot.define do
  factory :activity do
    action { "star_repo" }
    association :user
    association :actor, factory: :user
    association :target, factory: :repository
    meta { "" }
  end
end

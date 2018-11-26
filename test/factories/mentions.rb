FactoryBot.define do
  factory :mention do
    association :mentionable, factory: :doc
    user_ids { "[]" }
  end
end

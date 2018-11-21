FactoryBot.define do
  factory :comment do
    association :commentable, factory: :doc
    sequence(:body) { |n| "This is comment #{n}" }
    association :user
  end
end

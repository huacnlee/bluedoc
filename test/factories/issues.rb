FactoryBot.define do
  factory :issue do
    association :repository
    sequence(:title) { |n| "title #{n}" }
    association :user
    format { "markdown" }
    status { 0 }
  end
end

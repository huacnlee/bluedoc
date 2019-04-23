# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    association :commentable, factory: :doc
    sequence(:body) { |n| "This is comment #{n}" }
    sequence(:body_sml) { |n| %(["p", "This is comment #{n}"]) }
    association :user
  end
end

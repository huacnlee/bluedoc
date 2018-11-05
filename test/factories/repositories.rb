# frozen_string_literal: true

FactoryBot.define do
  factory :repository do
    sequence(:slug) { |n| "slug#{n}" }
    sequence(:name) { |n| "name #{n}" }
    sequence(:description) { |n| "description #{n}" }
    association :user, factory: :group
    privacy { "public" }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :doc do
    association :repository
    sequence(:slug) { |n| "slug#{n}" }
    sequence(:title) { |n| "title #{n}" }
    sequence(:draft_title) { |n| "draft title #{n}" }
    body_updated_at { Time.now }
    format { "markdown" }
  end
end

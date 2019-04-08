# frozen_string_literal: true

FactoryBot.define do
  factory :repository_toc do
    association :repository
    sequence(:url) { |n| "slug#{n}" }
    sequence(:title) { |n| "title #{n}" }
  end
end

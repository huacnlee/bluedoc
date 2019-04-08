# frozen_string_literal: true

FactoryBot.define do
  factory :toc do
    association :repository
    sequence(:url) { |n| "slug#{n}" }
    sequence(:title) { |n| "title #{n}" }
  end
end

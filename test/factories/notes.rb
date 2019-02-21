# frozen_string_literal: true

FactoryBot.define do
  factory :note do
    sequence(:slug) { |n| "slug#{n}" }
    sequence(:title) { |n| "title #{n}" }
    sequence(:description) { |n| "description #{n}" }
    association :user
    reads_count { 0 }
    comments_count { 0 }
  end
end

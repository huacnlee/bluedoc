# frozen_string_literal: true

FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "Group Name #{n}" }
    sequence(:slug) { |n| "group-slug-#{n}" }
    sequence(:email) { |n| "group-#{n}@example.com" }
  end
end

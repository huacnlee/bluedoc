# frozen_string_literal: true

FactoryBot.define do
  factory :authorization do
    provider { "google_oauth" }
    sequence(:uid) { |n| "uid-#{n}" }
    association(:user)
  end
end

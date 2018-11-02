# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "Name #{n}" }
    sequence(:slug) { |n| "login#{n}" }
    sequence(:email) { |n| "email#{n}@example.com" }
    password { "password" }
    password_confirmation { "password" }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    notify_type { "add_member" }
    association :target, factory: :member
    association :user
    association :actor, factory: :user
  end
end

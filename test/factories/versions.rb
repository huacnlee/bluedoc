# frozen_string_literal: true

FactoryBot.define do
  factory :version do
    type { "Version" }

    association :user
    association :subject, factory: :doc
    body { "Version body" }
  end
end

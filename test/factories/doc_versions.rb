# frozen_string_literal: true

FactoryBot.define do
  factory :doc_version do
    type { "DocVersion" }

    association :user
    association :subject, factory: :doc
    body { "Version body" }
  end
end

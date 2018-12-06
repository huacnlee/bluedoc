# frozen_string_literal: true

FactoryBot.define do
  factory :share do
    association :shareable, factory: :doc
  end
end

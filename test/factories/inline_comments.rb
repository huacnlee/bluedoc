# frozen_string_literal: true

FactoryBot.define do
  factory :inline_comment do
    association :subject, factory: :doc
    sequence(:nid) { |n| "nid-#{n}" }
  end
end
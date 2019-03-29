# frozen_string_literal: true

FactoryBot.define do
  factory :label do
    association :target, factory: :repository
    sequence(:title) { |n| "Label #{n}" }
    color { BlueDoc::Utils.random_color }
  end
end

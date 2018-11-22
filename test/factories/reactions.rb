FactoryBot.define do
  factory :reaction do
    association :subject, factory: :comment
    name { "+1" }
    association :user
  end
end

FactoryBot.define do
  factory :user_active do
    association :user
    association :subject, factory: :group
  end
end

FactoryBot.define do
  factory :member do
    association :user
    association :subject, factory: :group
    role { :admin }
  end
end

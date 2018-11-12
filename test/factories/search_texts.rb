FactoryBot.define do
  factory :search_text do
    association :record, factory: :doc
    title { "This is title" }
    body { "This is body" }
  end
end

FactoryBot.define do
  factory :attachment, class: "ActiveStorage::Attachment" do
    name { "avatar" }
  end
end

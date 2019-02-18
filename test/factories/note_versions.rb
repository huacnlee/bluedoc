# frozen_string_literal: true

FactoryBot.define do
  factory :note_version do
    type { "NoteVersion" }

    association :user
    association :subject, factory: :note
    body { "Version body" }
  end
end

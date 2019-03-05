# frozen_string_literal: true

FactoryBot.define do
  factory :repository_source do
    association :repository
    provider { "gitbook" }
    url { "https://github.com/huacnlee/test.git" }
    status { "running" }
    retries_count { 0 }
  end
end

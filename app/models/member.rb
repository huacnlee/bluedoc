class Member < ApplicationRecord
  enum role: %i(admin editor reader)

  belongs_to :user, required: false
  belongs_to :subject, required: false, polymorphic: true, counter_cache: true
end

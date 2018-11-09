# frozen_string_literal: true

class User
  has_many :activities, -> { order("id desc") }
  has_many :actor_activities, -> { where("user_id is null").order("id desc") }, class_name: "Activity", foreign_key: :actor_id
end

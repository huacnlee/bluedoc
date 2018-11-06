class User
  has_many :activities, -> { order("id desc") }
  has_many :actor_activities, -> { order("id desc") }, class_name: "Activity", foreign_key: :actor_id
end
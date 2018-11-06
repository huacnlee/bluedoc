class User
  has_many :activities, -> { order("id desc") }
end
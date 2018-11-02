class Repository
  serialize :preferences, Hash

  store_accessor :preferences, :has_toc

  before_validation :set_default_preferences, on: :create
  def set_default_preferences
    self.preferences[:has_toc] = true
  end
end

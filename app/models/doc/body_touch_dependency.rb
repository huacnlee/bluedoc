class Doc
  before_save do
    self.body_updated_at = Time.now
  end

  scope :recent, -> { order("body_updated_at desc, id desc") }

  def body_updated_at
    self[:body_updated_at] || self.updated_at
  end
end
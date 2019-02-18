class Note
  enum privacy: %i(private public), _prefix: :is
  scope :publics, -> { where(privacy: :public) }

  def private?
    self.is_private?
  end

  def public?
    self.is_public?
  end
end
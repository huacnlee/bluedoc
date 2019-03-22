class Issue
  def participants
    return @participants if defined? @participants
    users = self.comments.collect(&:user)
    users << self.user
    @participants = users.compact.uniq
    @participants
  end
end
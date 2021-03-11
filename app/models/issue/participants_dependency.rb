# frozen_string_literal: true

class Issue
  def participants
    return @participants if defined? @participants
    users = comments.collect(&:user)
    users << user
    @participants = users.compact.uniq
    @participants
  end
end

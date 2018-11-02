class User
  def self.prefix_search(term, user: nil, group: nil, repository: nil, limit: 30)
    following = []
    term = "#{term}%"
    users = User.where(type: "User")
      .where("slug ilike ? or email ilike ? or name ilike ?", term, term, term)
      .limit(limit).to_a

    following = []
    group_members = []
    repository_members = []

    users.unshift(*Array(following))
    users.uniq!
    users.compact!

    users.first(limit)
  end
end
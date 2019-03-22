class User
  def as_item_json
    as_json(only: %i[id slug name], methods: %i[avatar_url])
  end
end
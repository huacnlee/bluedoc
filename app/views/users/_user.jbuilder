# frozen_string_literal: true

json.cache! ["1.0", user] do
  json.call(user, :id, :slug, :name)
  json.avatar_url user.avatar_url
end

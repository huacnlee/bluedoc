class User
  action_store :watch, :repository, counter_cache: true
  action_store :star, :repository, counter_cache: true
end
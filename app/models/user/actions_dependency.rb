# frozen_string_literal: true

class User
  action_store :watch, :repository, counter_cache: true
  action_store :star, :repository, counter_cache: true
  action_store :star, :doc
  action_store :watch_comment, :doc
end

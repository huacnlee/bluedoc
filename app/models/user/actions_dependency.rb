# frozen_string_literal: true

class User
  action_store :watch, :repository, counter_cache: true
  action_store :star, :repository, counter_cache: true
  action_store :star, :doc
  action_store :watch_comment, :doc
  action_store :watch_comment, :note
  action_store :read, :doc, counter_cache: true

  # read doc, or update visit time if exist
  def read_doc(doc)
    return nil if doc.blank?

    action = User.find_action(:read, target: doc, user: self)
    if action
      action.touch
      return action
    end

    action = User.create_action(:read, target: doc, user: self)
    doc.reload
    action
  end
end

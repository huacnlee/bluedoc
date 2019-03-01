class User
  action_store :read, :doc, counter_cache: true
  action_store :read, :note, counter_cache: true

  # read Doc, or update visit time if exist
  def read_doc(doc)
    return false unless allow_feature?(:reader_list)
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

  # read Note, or update visit time if exist
  def read_note(note)
    return false unless allow_feature?(:reader_list)
    return nil if note.blank?

    action = User.find_action(:read, target: note, user: self)
    if action
      action.touch
      return action
    end

    action = User.create_action(:read, target: note, user: self)
    note.reload
    action
  end
end
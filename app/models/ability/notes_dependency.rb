# frozen_string_literal: true

class Ability
  def abilities_for_notes
    can :manage, Note, user_id: user.id
    can :read, Note do |note|
      note.public?
    end
  end
end

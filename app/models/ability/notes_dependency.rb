# frozen_string_literal: true

class Ability
  def abilities_for_notes
    can :read, Note do |note|
      note.public?
    end
    can :manage, Note, user_id: user.id
  end
end

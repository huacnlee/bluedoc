# frozen_string_literal: true

class Ability
  def abilities_for_inline_comments
    can :read, InlineComment do |inline_comment|
      can? :read, inline_comment.subject
    end
    can :manage, InlineComment do |inline_comment|
      can? :manage, inline_comment.subject
    end
  end
end

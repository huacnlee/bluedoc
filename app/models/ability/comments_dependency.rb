# frozen_string_literal: true

class Ability
  def abilities_for_comments
    can :read, Comment do |comment|
      can? :read, comment.commentable
    end
    can :manage, Comment, user_id: user.id
    can :destroy, Comment do |comment|
      can? :update, comment.commentable
    end
  end
end

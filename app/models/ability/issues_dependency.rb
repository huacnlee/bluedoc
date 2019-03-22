# frozen_string_literal: true

class Ability
  def abilities_for_issues
    can [:read, :create], Issue do |issue|
      can? :read, issue.repository
    end
    can :manage, Issue do |issue|
      can? :update, issue.repository
    end
    can :update, Issue, user_id: user.id
    can :update, Issue do |issue|
      can? :update, issue.repository
    end
    can :create_issue, Repository do |repo|
      can? :read, repo
    end
  end
end

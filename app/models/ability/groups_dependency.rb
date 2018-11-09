# frozen_string_literal: true

class Ability
  def abilities_for_groups
    can :manage, User, id: user.id
    can :create, Group
    can :manage, Group do |group|
      group.user_role(user) == :admin
    end
    can %i[read create_repo read_repo], Group do |group|
      group.user_role(user) == :editor
    end
    can %i[read read_repo], Group do |group|
      group.user_role(user) == :reader
    end
    can :read, Group
  end
end

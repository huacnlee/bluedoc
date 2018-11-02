class Ability
  def abilities_for_groups
    can :manage, User, id: user.id
    can :create, Group
    can :manage, Group do |group|
      group.user_role(user) == :admin
    end
    can %i[read create_repo], Group do |group|
      group.user_role(user) == :editor
    end
    can :read, Group
  end
end
class Ability
  include CanCan::Ability

  attr_reader :user

  depends_on :groups, :repositories, :docs

  def initialize(u)
    @user = u || User.new

    if user.admin?
      can :manage, :all
    else
      abilities_for_anonymous
      abilities_for_sign_in_user
    end
  end

  def abilities_for_sign_in_user
    cannot :manage, :all
    abilities_for_groups
    abilities_for_repositories
    abilities_for_docs
  end

  def abilities_for_anonymous
    return unless user.new_record?
    cannot :manage, :all
  end
end

# frozen_string_literal: true

class Ability
  include CanCan::Ability

  attr_reader :user

  depends_on :groups, :repositories, :docs, :comments

  def initialize(u)
    @user = u || User.new

    abilities_for_anonymous
    abilities_for_sign_in_user
  end

  def abilities_for_sign_in_user
    cannot :manage, :all
    abilities_for_groups
    abilities_for_repositories
    abilities_for_docs
    abilities_for_comments

    can :read, Member, user_id: user.id
  end

  def abilities_for_anonymous
    return unless user.new_record?
    cannot :manage, :all
  end
end

# frozen_string_literal: true

class Ability
  def abilities_for_repositories
    can :read, Repository, privacy: :public

    # :admin
    can :manage, Repository do |repo|
      repo.user_role(user) == :admin
    end
    can :manage, Repository do |repo|
      can? :manage, repo.user
    end

    # :editor
    can %i[read create_doc], Repository do |repo|
      repo.user_role(user) == :editor
    end

    can %i[update], Repository do |repo|
      can? :update, repo.user
    end
    can %i[create create_doc], Repository do |repo|
      if repo.user&.user?
        repo.user&.id == user.id
      else
        role = repo.user&.user_role(user)
        role.in? %i[editor admin]
      end
    end

    # :reader
    can %i[read], Repository do |repo|
      if repo.public?
        return true
      else
        repo.user_role(user) == :reader
      end
    end

    can %i[read], Repository do |repo|
      if repo.public?
        true
      elsif repo.user.user?
        repo.user&.id == user.id
      else
        repo.user&.has_member?(user)
      end
    end
  end
end

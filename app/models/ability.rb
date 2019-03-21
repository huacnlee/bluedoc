# frozen_string_literal: true

class Ability
  include CanCan::Ability

  attr_reader :user, :cache

  depends_on :groups, :repositories, :docs, :comments, :notes, :issues

  def initialize(u)
    @user = u || User.new

    abilities_for_anonymous
    abilities_for_sign_in_user

    @cache = {}

    can :read, Share
  end

  def abilities_for_sign_in_user
    cannot :manage, :all
    abilities_for_groups
    abilities_for_repositories
    abilities_for_docs
    abilities_for_comments
    abilities_for_notes
    abilities_for_issues

    can :read, Member, user_id: user.id
  end

  def abilities_for_anonymous
    return unless user.new_record?
    cannot :manage, :all
  end

  def can?(action, obj)
    if obj.respond_to?(:cache_key)
      cache_key = "#{action}:#{obj.cache_key}"
    else
      cache_key = "#{action}:#{obj}"
    end
    res = self.cache[cache_key]
    if res != nil
      Rails.logger.debug "  CACHE CanCanCan load: #{cache_key} (#{res})"
      return res
    end
    self.cache[cache_key] = super(action, obj)
    self.cache[cache_key]
  end

  def reload
    @cache = {}
  end
end

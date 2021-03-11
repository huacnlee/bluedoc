# frozen_string_literal: true

class Ability
  include CanCan::Ability

  attr_reader :user, :cache

  depends_on :groups, :repositories, :docs, :comments, :notes, :issues, :inline_comments

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
    abilities_for_inline_comments

    can :read, Member, user_id: user.id
  end

  def abilities_for_anonymous
    return unless user.new_record?
    cannot :manage, :all
  end

  def can?(action, obj)
    cache_key = if obj.respond_to?(:cache_key)
      "#{action}:#{obj.cache_key}"
    else
      "#{action}:#{obj}"
    end
    res = cache[cache_key]
    if !res.nil?
      Rails.logger.debug "  CACHE CanCanCan load: #{cache_key} (#{res})"
      return res
    end
    cache[cache_key] = super(action, obj)
    cache[cache_key]
  end

  def reload
    @cache = {}
  end
end

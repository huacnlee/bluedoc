# frozen_string_literal: true

class Ability
  def abilities_for_docs
    can :read, Doc do |doc|
      can? :read, doc.repository
    end
    can :create_comment, Doc do |doc|
      can? :read, doc.repository
    end
    can :manage, Doc do |doc|
      can? :manage, doc.repository
    end
    can %i[create update destroy], Doc do |doc|
      can? :create_doc, doc.repository
    end
  end
end

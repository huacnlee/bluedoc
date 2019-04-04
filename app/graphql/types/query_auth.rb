# frozen_string_literal: true

module Types::QueryAuth
  def authorize!(*args)
    current_ability.authorize!(*args)
  end

  def current_ability
    @current_ability ||= ::Ability.new(current_user)
  end

  def current_user
    context[:current_user]
  end
end

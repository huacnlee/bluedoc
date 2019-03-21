# frozen_string_literal: true

class User
  %i[doc note issue].each do |model|
    action_store :read, model, counter_cache: true

    # read Target, or update visit time if exist
    define_method("read_#{model}") do |target|
      return false unless allow_feature?(:reader_list)
      return nil if target.blank?

      action = User.find_action(:read, target: target, user: self)
      if action
        action.touch
        return action
      end

      action = User.create_action(:read, target: target, user: self)
      target.reload
      action
    end
  end
end

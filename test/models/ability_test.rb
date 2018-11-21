# frozen_string_literal: true

require "test_helper"

class AbilityTest < ActiveSupport::TestCase
  test "admin can manage all" do
    user = create(:user)
    user.stub(:admin?, true) do
      ability = Ability.new(user)
      assert ability.cannot? :manage, :all
    end
  end

  test "anonymous cannot manage all" do
    ability = Ability.new(nil)
    assert ability.cannot? :manage, :all
  end

  test "other model" do
    user = create(:user)
    ability = Ability.new(user)

    member = create(:member, user: user)
    assert ability.can? :read, member
  end
end

# frozen_string_literal: true

require "test_helper"

class Ability::GroupsTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @group = create(:group)
    @ability = Ability.new(@user)
  end

  test "with user" do
    assert @ability.can? :manage, @user
    assert @ability.can? :update, @user
    assert @ability.can? :read_repo, @user

    other_user = create(:user)
    assert @ability.cannot? :manage, other_user
  end

  test ":admin" do
    @group.add_member(@user, :admin)

    assert @ability.can? :manage, @group
  end

  test ":editor" do
    @group.add_member(@user, :editor)
    @ability.reload
    assert @ability.can? :read, @group
    assert @ability.can? :create_repo, @group
    assert @ability.can? :read_repo, @group
    assert @ability.cannot? :update, @group
    assert @ability.cannot? :destroy, @group
  end

  test ":reader" do
    @group.add_member(@user, :reader)
    @ability.reload
    assert @ability.can? :read, @group
    assert @ability.can? :read_repo, @group
    assert @ability.cannot? :create_repo, @group
    assert @ability.cannot? :update, @group
    assert @ability.cannot? :destroy, @group
  end

  test "not member" do
    assert @ability.can? :read, @group
    assert @ability.cannot? :create_repo, @group
    assert @ability.cannot? :read_repo, @group
    assert @ability.cannot? :update, @group
    assert @ability.cannot? :destroy, @group
  end
end

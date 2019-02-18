# frozen_string_literal: true

require "test_helper"

class Ability::NotesTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @other_user = create(:user)

    @ability = Ability.new(@user)
    @other_ability = Ability.new(@other_user)
    @anonymous_ability = Ability.new(nil)
  end

  test "Base" do
    note = create(:note, user: @user, privacy: :public)
    assert @ability.can? :manage, note
    assert @other_ability.cannot? :manage, note
    assert @other_ability.can? :read, note
    assert @other_ability.cannot? :create, note
    assert @other_ability.cannot? :update, note
    assert @other_ability.cannot? :destroy, note
    assert @anonymous_ability.cannot? :manage, note
    assert @anonymous_ability.can? :read, note
    assert @anonymous_ability.cannot? :create, note
    assert @anonymous_ability.cannot? :update, note
    assert @anonymous_ability.cannot? :destroy, note

    private_note = create(:note, user: @user, privacy: :private)
    assert @ability.can? :read, private_note
    assert @other_ability.cannot? :read, private_note
    assert @anonymous_ability.cannot? :read, private_note
  end
end

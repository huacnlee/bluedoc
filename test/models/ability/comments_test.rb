# frozen_string_literal: true

require "test_helper"

class Ability::CommentsTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @other_user = create(:user)

    @ability = Ability.new(@user)
    @other_ability = Ability.new(@other_user)
    @anonymous_ability = Ability.new(nil)
  end

  test "Public comment" do
    comment = create(:comment, user_id: @user.id)

    assert @other_ability.can? :read, comment
    assert @other_ability.cannot? :update, comment
    assert @other_ability.cannot? :destroy, comment
    assert @anonymous_ability.can? :read, comment
  end

  test "Owned Comment" do
    comment = create(:comment, user_id: @user.id)

    assert @ability.can? :read, comment
    assert @ability.can? :update, comment
    assert @ability.can? :destroy, comment

    assert @other_ability.cannot? :update, comment
    assert @other_ability.cannot? :destroy, comment
  end

  test "Private Doc comment" do
    group = create(:group)
    repo = create(:repository, user: group, privacy: :private)
    doc = create(:doc, repository: repo)
    comment = create(:comment, commentable: doc)

    assert @ability.cannot? :read, comment
    assert @ability.cannot? :update, comment
    assert @ability.cannot? :destroy, comment

    group.add_member(@user, :reader)
    assert @ability.can? :read, comment
    assert @ability.cannot? :update, comment
    assert @ability.cannot? :destroy, comment

    group.add_member(@user, :editor)
    assert @ability.can? :read, comment
    assert @ability.cannot? :update, comment
    assert @ability.can? :destroy, comment
  end
end

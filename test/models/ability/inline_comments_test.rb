# frozen_string_literal: true

require "test_helper"

class Ability::InlineCommentsTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @other_user = create(:user)

    @ability = Ability.new(@user)
    @other_ability = Ability.new(@other_user)
    @anonymous_ability = Ability.new(nil)
  end

  test "Owned InlineComment" do
    inline_comment = create(:inline_comment, user: @user)

    assert @ability.can? :read, inline_comment
    assert @ability.cannot? :update, inline_comment
    assert @ability.cannot? :destroy, inline_comment
    assert @ability.cannot? :manage, inline_comment

    assert @other_ability.can? :read, inline_comment
    assert @other_ability.cannot? :update, inline_comment
    assert @other_ability.cannot? :destroy, inline_comment
  end

  test "Membered Group Repository" do
    group = create(:group)
    repo = create(:repository, user: group)
    doc = create(:doc, repository: repo)
    inline_comment = create(:inline_comment, subject: doc)

    private_repo = create(:repository, user: group, privacy: :private)
    private_doc = create(:doc, repository: private_repo)
    private_inline_comment = create(:inline_comment, subject: private_doc)

    # :reader
    group.add_member(@user, :reader)
    @ability.reload
    assert @ability.can? :read, inline_comment
    assert @ability.can? :read, private_inline_comment
    assert @ability.cannot? :update, inline_comment
    assert @ability.cannot? :update, private_inline_comment
    assert @ability.can? :read, private_inline_comment
    assert @ability.cannot? :destroy, inline_comment
    assert @ability.cannot? :destroy, private_inline_comment
    assert @ability.cannot? :manage, private_inline_comment

    # :editor
    group.add_member(@user, :editor)
    @ability.reload
    assert @ability.can? :read, inline_comment
    assert @ability.cannot? :update, inline_comment
    assert @ability.cannot? :destroy, inline_comment
    assert @ability.can? :read, private_inline_comment
    assert @ability.cannot? :update, private_inline_comment
    assert @ability.cannot? :destroy, private_inline_comment
    assert @ability.cannot? :manage, private_inline_comment

    # :admin
    group.add_member(@user, :admin)
    @ability.reload
    assert @ability.can? :read, inline_comment
    assert @ability.can? :update, inline_comment
    assert @ability.can? :destroy, inline_comment
    assert @ability.can? :read, private_inline_comment
    assert @ability.can? :update, private_inline_comment
    assert @ability.can? :destroy, private_inline_comment
    assert @ability.can? :manage, private_inline_comment

    # Other user
    assert @other_ability.can? :read, inline_comment
    assert @other_ability.cannot? :update, inline_comment
    assert @anonymous_ability.can? :read, inline_comment
    assert @anonymous_ability.cannot? :update, inline_comment
    assert @other_ability.cannot? :read, private_inline_comment
    assert @other_ability.cannot? :update, private_inline_comment
    assert @anonymous_ability.cannot? :read, private_inline_comment
    assert @anonymous_ability.cannot? :update, private_inline_comment
  end
end

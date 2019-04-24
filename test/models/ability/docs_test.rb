# frozen_string_literal: true

require "test_helper"

class Ability::DocsTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @other_user = create(:user)

    @ability = Ability.new(@user)
    @other_ability = Ability.new(@other_user)
    @anonymous_ability = Ability.new(nil)
  end

  test "Owned Repository" do
    repo = create(:repository, user: @user)
    doc = create(:doc, repository: repo)

    private_repo = create(:repository, user: @user, privacy: :private)
    private_doc = create(:doc, repository: private_repo)

    assert @ability.can? :manage, doc

    assert @other_ability.can? :read, doc
    assert @other_ability.can? :create_comment, doc
    assert @other_ability.cannot? :read, private_doc
    assert @other_ability.cannot? :create, doc
    assert @other_ability.cannot? :update, doc
    assert @other_ability.cannot? :destroy, doc

    assert @anonymous_ability.can? :read, doc
    assert @anonymous_ability.can? :create_comment, doc
    assert @anonymous_ability.cannot? :read, private_doc
    assert @anonymous_ability.cannot? :create, doc
    assert @anonymous_ability.cannot? :update, doc
    assert @anonymous_ability.cannot? :destroy, doc

    # private Repository
    repo = create(:repository, user: @user, privacy: :private)
    doc = create(:doc, repository: repo)

    assert @ability.can? :manage, doc

    assert @other_ability.cannot? :read, doc
    assert @other_ability.cannot? :create_comment, doc
    assert @anonymous_ability.cannot? :read, doc
  end

  test "Membered Group Repository" do
    group = create(:group)
    repo = create(:repository, user: group)
    doc = create(:doc, repository: repo)

    private_repo = create(:repository, user: group, privacy: :private)
    private_doc = create(:doc, repository: private_repo)

    # :reader
    group.add_member(@user, :reader)
    @ability.reload
    assert @ability.can? :read, doc
    assert @ability.can? :read, private_doc
    assert @ability.cannot? :create, doc
    assert @ability.cannot? :update, doc
    assert @ability.cannot? :destroy, doc

    # :editor
    group.add_member(@user, :editor)
    @ability.reload
    assert @ability.can? :read, doc
    assert @ability.can? :create, doc
    assert @ability.can? :update, doc
    assert @ability.can? :destroy, doc
    assert @ability.can? :read, private_doc
    assert @ability.can? :create, private_doc
    assert @ability.can? :update, private_doc
    assert @ability.can? :destroy, private_doc

    # :admin
    group.add_member(@user, :admin)
    @ability.reload
    assert @ability.can? :manage, doc
    assert @ability.can? :manage, private_doc

    # Other user
    assert @other_ability.can? :read, doc
    assert @anonymous_ability.can? :read, doc
    assert @other_ability.cannot? :read, private_doc
    assert @anonymous_ability.cannot? :read, private_doc
  end
end

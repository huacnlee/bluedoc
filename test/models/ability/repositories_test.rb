# frozen_string_literal: true

require "test_helper"

class Ability::RepositoriesTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @other_user = create(:user)

    @ability = Ability.new(@user)
    @other_ability = Ability.new(@other_user)
    @anonymous_ability = Ability.new(nil)
  end

  test "Owned Repository" do
    repo = create(:repository, user: @user, privacy: :public)
    assert @ability.can? :manage, repo
    assert @other_ability.cannot? :manage, repo
    assert @other_ability.can? :read, repo
    assert @other_ability.cannot? :create, repo
    assert @other_ability.cannot? :update, repo
    assert @other_ability.cannot? :destroy, repo
    assert @other_ability.cannot? :create_doc, repo
    assert @anonymous_ability.cannot? :manage, repo
    assert @anonymous_ability.can? :read, repo
    assert @anonymous_ability.cannot? :create, repo
    assert @anonymous_ability.cannot? :update, repo
    assert @anonymous_ability.cannot? :destroy, repo
    assert @anonymous_ability.cannot? :create_doc, repo

    private_repo = create(:repository, user: @user, privacy: :private)
    assert @ability.can? :read, private_repo
    assert @other_ability.cannot? :read, private_repo
    assert @anonymous_ability.cannot? :read, private_repo
  end

  test "Membered Group Repository" do
    group = create(:group)
    repo = create(:repository, user: group, privacy: :public)
    private_repo = create(:repository, user: group, privacy: :private)

    # :reader
    group.add_member(@user, :reader)
    @ability.reload
    assert @ability.cannot? :manage, repo
    assert @ability.cannot? :create, repo
    assert @ability.cannot? :update, repo
    assert @ability.cannot? :create_doc, repo
    assert @ability.can? :read, repo

    assert @ability.cannot? :manage, private_repo
    assert @ability.cannot? :create, private_repo
    assert @ability.cannot? :update, private_repo
    assert @ability.cannot? :create_doc, private_repo
    assert @ability.can? :read, private_repo

    # :editor
    group.add_member(@user, :editor)
    @ability.reload
    assert @ability.cannot? :manage, repo
    assert @ability.can? :create, repo
    assert @ability.cannot? :update, repo
    assert @ability.can? :create_doc, repo
    assert @ability.can? :read, repo

    assert @ability.cannot? :manage, private_repo
    assert @ability.can? :create, private_repo
    assert @ability.cannot? :update, private_repo
    assert @ability.can? :create_doc, private_repo
    assert @ability.can? :read, private_repo

    # :admin
    group.add_member(@user, :admin)
    @ability.reload
    assert @ability.can? :manage, repo
    assert @ability.can? :manage, private_repo

    # other user
    assert @other_ability.cannot? :create, repo
    assert @other_ability.cannot? :update, repo
    assert @other_ability.cannot? :destroy, repo
    assert @other_ability.cannot? :create_doc, repo
    assert @other_ability.can? :read, repo
    assert @other_ability.cannot? :read, private_repo

    # anonymous
    assert @anonymous_ability.cannot? :create, repo
    assert @anonymous_ability.cannot? :update, repo
    assert @anonymous_ability.cannot? :destroy, repo
    assert @anonymous_ability.cannot? :create_doc, repo
    assert @anonymous_ability.can? :read, repo
    assert @anonymous_ability.cannot? :read, private_repo
  end

  test "Membered Repository" do
    repo = create(:repository, privacy: :public)
    private_repo = create(:repository, privacy: :private)

    # :reader
    private_repo.add_member(@user, :reader)
    @ability.reload
    assert @ability.cannot? :manage, repo
    assert @ability.cannot? :update, repo
    assert @ability.cannot? :create_doc, repo
    assert @ability.can? :read, repo

    assert @ability.cannot? :manage, private_repo
    assert @ability.cannot? :update, private_repo
    assert @ability.cannot? :create_doc, private_repo
    assert @ability.can? :read, private_repo

    # :editor
    private_repo.add_member(@user, :editor)
    @ability.reload
    assert @ability.cannot? :manage, private_repo
    assert @ability.cannot? :update, private_repo
    assert @ability.can? :create_doc, private_repo
    assert @ability.can? :read, private_repo

    # :admin
    private_repo.add_member(@user, :admin)
    @ability.reload
    assert @ability.can? :manage, private_repo

    # other user
    assert @other_ability.cannot? :create, private_repo
    assert @other_ability.cannot? :update, private_repo
    assert @other_ability.cannot? :destroy, private_repo
    assert @other_ability.cannot? :create_doc, private_repo
    assert @other_ability.cannot? :read, private_repo

    # anonymous
    assert @anonymous_ability.cannot? :create, private_repo
    assert @anonymous_ability.cannot? :update, private_repo
    assert @anonymous_ability.cannot? :destroy, private_repo
    assert @anonymous_ability.cannot? :create_doc, private_repo
    assert @anonymous_ability.cannot? :read, private_repo
  end
end

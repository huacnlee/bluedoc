# frozen_string_literal: true

require "test_helper"

class Ability::IssuesTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @other_user = create(:user)

    @ability = Ability.new(@user)
    @other_ability = Ability.new(@other_user)
    @anonymous_ability = Ability.new(nil)
  end

  test "Owned Issue" do
    repo = create(:repository)
    issue = create(:issue, repository: repo, user: @user)

    assert @ability.can? :read, issue
    assert @ability.can? :update, issue
    assert @ability.cannot? :destroy, issue
    assert @ability.can? :create_issue, Repository
    assert @ability.can? :create_issue, repo

    assert @other_ability.can? :read, issue
    assert @other_ability.cannot? :update, issue
    assert @other_ability.cannot? :destroy, issue
    assert @other_ability.can? :create_issue, repo
  end

  test "Membered Group Repository" do
    group = create(:group)
    repo = create(:repository, user: group)
    issue = create(:issue, repository: repo)

    private_repo = create(:repository, user: group, privacy: :private)
    private_issue = create(:issue, repository: private_repo)

    # :reader
    group.add_member(@user, :reader)
    @ability.reload
    assert @ability.can? :read, issue
    assert @ability.can? :read, private_issue
    assert @ability.cannot? :update, issue
    assert @ability.cannot? :update, private_issue
    assert @ability.can? :read, private_issue
    assert @ability.can? :create_issue, repo
    assert @ability.can? :create_issue, repo
    assert @ability.cannot? :update, private_repo
    assert @ability.cannot? :destroy, issue
    assert @ability.cannot? :destroy, private_issue

    # :editor
    group.add_member(@user, :editor)
    @ability.reload
    assert @ability.can? :read, issue
    assert @ability.cannot? :update, issue
    assert @ability.cannot? :destroy, issue
    assert @ability.can? :read, private_issue
    assert @ability.cannot? :update, private_issue
    assert @ability.cannot? :destroy, private_issue

    # :admin
    group.add_member(@user, :admin)
    @ability.reload
    assert @ability.can? :read, issue
    assert @ability.can? :update, issue
    assert @ability.can? :destroy, issue
    assert @ability.can? :read, private_issue
    assert @ability.can? :update, private_issue
    assert @ability.can? :destroy, private_issue

    # Other user
    assert @other_ability.can? :read, issue
    assert @other_ability.cannot? :update, issue
    assert @anonymous_ability.can? :read, issue
    assert @anonymous_ability.cannot? :update, issue
    assert @other_ability.cannot? :read, private_issue
    assert @other_ability.cannot? :update, private_issue
    assert @anonymous_ability.cannot? :read, private_issue
    assert @anonymous_ability.cannot? :update, private_issue
  end
end

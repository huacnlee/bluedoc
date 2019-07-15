# frozen_string_literal: true

require "test_helper"

class AbilityTest < ActiveSupport::TestCase
  test "anonymous can not read private repository doc" do
    ab = Ability.new nil
    private_doc = build :doc, repository: build(:repository, privacy: :private)
    assert ab.cannot?(:read, private_doc)
  end

  test "anonymous can read public repository doc" do
    ab = Ability.new nil
    public_repository_doc = build :doc
    assert ab.can?(:read, public_repository_doc)
  end

  test "anonymous can read private repository but shared doc" do
    ab = Ability.new nil
    shared_doc = build :doc, repository: build(:repository, privacy: :private)
    shared_doc.stubs(:share).returns(build :share)
    assert ab.can?(:read, shared_doc)
  end

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

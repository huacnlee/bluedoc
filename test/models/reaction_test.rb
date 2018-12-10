# frozen_string_literal: true

require "test_helper"

class ReactionTest < ActiveSupport::TestCase
  test "validate name" do
    reaction = Reaction.new(name: "+1")
    assert_equal true, reaction.valid?

    reaction = Reaction.new(name: "Foooo")
    assert_equal false, reaction.valid?
    assert_equal ["is an invalid emoji name"], reaction.errors[:name]
  end

  test "create_reaction / destroy_reaction" do
    doc = create(:doc)
    user = create(:user)
    user1 = create(:user)

    t = doc.updated_at

    reaction = Reaction.create_reaction("smile", doc, user: user)
    assert_equal false, reaction.new_record?
    assert_equal "smile", reaction.name
    assert_equal user, reaction.user
    assert_equal doc, reaction.subject
    # should touch doc
    doc.reload
    assert_not_equal t, doc.updated_at

    # same user, same reaction with same subject just once
    assert_no_changes -> { Reaction.count } do
      reaction1 = Reaction.create_reaction("smile", doc, user: user)
      assert_equal reaction, reaction1
    end

    assert_changes -> { Reaction.count }, 1 do
      reaction = Reaction.create_reaction("+1", doc, user: user1)
      assert_equal "+1", reaction.name
      assert_equal user1, reaction.user
      assert_equal doc, reaction.subject
    end

    assert_changes -> { Reaction.count }, -1 do
      t = doc.updated_at
      Reaction.destroy_reaction("+1", doc, user: user1)
      assert_equal 0, Reaction.where(name: "+1", subject: doc, user: user1).count
      doc.reload
      assert_not_equal t, doc.updated_at
    end
  end

  test "allow_reactions" do
    assert_equal Reaction::ALLOW_NAMES.count, Reaction.allow_reactions.count
    assert_equal true, Reaction.allow_reactions.first.is_a?(Reaction)
  end

  test "group_user_slugs" do
    reaction = Reaction.new
    assert_equal [], reaction.group_user_slugs
  end

  test "group by name" do
    doc = create(:doc)
    r0 = create_list(:reaction, 2, name: "+1", subject: doc)
    r1 = create_list(:reaction, 3, name: "smile", subject: doc)

    reactions = Reaction.where(subject: doc).grouped
    assert_equal true, reactions.is_a?(Array)

    assert_equal 2, reactions.count
    assert_equal true, reactions.first.is_a?(Reaction)

    assert_equal "+1", reactions[0].name
    assert_equal "👍", reactions[0].unicode
    assert_equal "/twemoji/svg/1f44d.svg", reactions[0].url
    assert_equal 2, reactions[0].group_count
    assert_equal r0.collect(&:user).collect(&:slug), reactions[0].group_user_slugs

    assert_equal "smile", reactions[1].name
    assert_equal "😄", reactions[1].unicode
    assert_equal "/twemoji/svg/1f604.svg", reactions[1].url
    assert_equal 3, reactions[1].group_count
    assert_equal r1.collect(&:user).collect(&:slug), reactions[1].group_user_slugs
  end

  test "text" do
    assert_equal ":+1:", Reaction.new(name: "+1").text
    assert_equal ":smile:", Reaction.new(name: "smile").text
  end

  test "unicode" do
    assert_equal "👍", Reaction.new(name: "+1").unicode
    assert_equal "😄", Reaction.new(name: "smile").unicode
  end

  test "url" do
    assert_equal "/twemoji/svg/1f44d.svg", Reaction.new(name: "+1").url
    assert_equal "/twemoji/svg/1f604.svg", Reaction.new(name: "smile").url
  end
end

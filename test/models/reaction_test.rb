require 'test_helper'

class ReactionTest < ActiveSupport::TestCase
  test "create_reaction" do
    doc = create(:doc)
    user = create(:user)
    user1 = create(:user)

    reaction = Reaction.create_reaction("smile", doc, user: user)
    assert_equal false, reaction.new_record?
    assert_equal "smile", reaction.name
    assert_equal user, reaction.user
    assert_equal doc, reaction.subject

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
  end

  test "group by name" do
    doc = create(:doc)
    create_list(:reaction, 2, name: "+1", subject: doc)
    create_list(:reaction, 3, name: "smile", subject: doc)
    reactions = Reaction.where(subject: doc).grouped
    assert_equal 2, reactions.count
    assert_equal true, reactions.first.is_a?(Reaction)
    assert_equal ["+1", "smile"], reactions.collect(&:name)
    assert_equal ["👍", "😄"], reactions.collect(&:unicode)
    assert_equal ["/twemoji/svg/1f44d.svg", "/twemoji/svg/1f604.svg"], reactions.collect(&:url)
    assert_equal [2, 3], reactions.collect(&:group_count)
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

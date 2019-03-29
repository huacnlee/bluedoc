# frozen_string_literal: true

require "test_helper"

class SequenceTest < ActiveSupport::TestCase
  test "next" do
    user = create(:user)
    other_user = create(:user)

    assert_equal 1, Sequence.next(other_user)

    10.times do |i|
      assert_equal i + 1, Sequence.next(user)
    end

    assert_equal 2, Sequence.next(other_user)

    assert_equal 1, Sequence.where(target: user).count

    sequence = Sequence.find_by_target(user)
    assert_equal 10, sequence.number
    assert_equal "User", sequence.target_type
    assert_equal user.id, sequence.target_id
  end

  test "next with scope" do
    repo = create(:repository)
    assert_equal 1, Sequence.next(repo)
    assert_equal 1, Sequence.next(repo, :issue)
    assert_equal 2, Sequence.next(repo, :issue)
    assert_equal 1, Sequence.next(repo, :other)

    assert_equal 3, Sequence.where(target: repo).count
    assert_sequence_number repo, 2, scope: :issue
  end

  test "Test issue sequence" do
    repo = create(:repository)
    issue1 = create(:issue, repository: repo)
    assert_equal 1, issue1.iid
    issue2 = create(:issue, repository: repo)
    assert_equal 2, issue2.iid

    assert_sequence_number repo, 2, scope: :issue

    repo1 = create(:repository)
    issue = create(:issue, repository: repo1)
    assert_equal 1, issue.iid
    assert_sequence_number repo1, 1, scope: :issue
  end

  def assert_sequence_number(target, number, scope: "")
    sequence = Sequence.find_by_target(target, scope)
    assert_not_nil sequence
    assert_equal number, sequence.number
  end
end

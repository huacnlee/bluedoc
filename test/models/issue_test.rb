require 'test_helper'

class IssueTest < ActiveSupport::TestCase
  setup do
    @repo = create(:repository)
  end

  test "to_path" do
    issue = create(:issue, repository: @repo)
    assert_equal "#{@repo.to_path}/issues/#{issue.iid}", issue.to_path
  end

  test "find_by_iid and find_by_iid!" do
    issue = create(:issue, repository: @repo)

    assert_equal issue, @repo.issues.find_by_iid(issue.iid)
    assert_equal issue, @repo.issues.find_by_iid!(issue.iid)

    assert_raise(ActiveRecord::RecordNotFound) do
      @repo.issues.find_by_iid!(0)
    end
  end
end

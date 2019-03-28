# frozen_string_literal: true

require "test_helper"

class SearchReindexJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include JobsTestHelper

  test "perform" do
    create_list(:user, 2)
    create_list(:group, 3)
    create_list(:repository, 4)
    create_list(:doc, 5)
    create_list(:note, 5)

    # Should invoked delete index
    assert_perform_request method: "DELETE", url: "test-notes" do
      assert_perform_request method: "DELETE", url: "test-groups" do
        assert_perform_request method: "DELETE", url: "test-users" do
          assert_perform_request method: "DELETE", url: "test-repositories" do
            assert_perform_request method: "DELETE", url: "test-docs" do
              SearchReindexJob.perform_now
            end
          end
        end
      end
    end

    # Should invoked create index
    assert_perform_request method: "HEAD", url: "test-notes" do
      assert_perform_request method: "HEAD", url: "test-groups" do
        assert_perform_request method: "HEAD", url: "test-users" do
          assert_perform_request method: "HEAD", url: "test-repositories" do
            assert_perform_request method: "HEAD", url: "test-docs" do
              SearchReindexJob.perform_now
            end
          end
        end
      end
    end
  end
end

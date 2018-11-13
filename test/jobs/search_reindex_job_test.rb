# frozen_string_literal: true

require "test_helper"

class SearchReindexJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "perform" do
    create_list(:user, 2)
    create_list(:group, 3)
    create_list(:repository, 4)
    create_list(:doc, 5)

    SearchReindexJob.perform_now
  end
end

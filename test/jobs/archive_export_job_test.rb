# frozen_string_literal: true

require "test_helper"

class ArchiveExportJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "perform" do
    repo = create(:repository)

    exporter = MiniTest::Mock.new
    exporter.expect(:perform, [])

    BookLab::Export::Archive.stub(:new, exporter) do
      ArchiveExportJob.perform_now(repo)
    end

    assert_equal "done", repo.export_archive_status.value

    exporter.expect(:perform, []) do |args|
      raise "Error"
    end
    repo.set_export_status(:archive, "running")
    assert_changes -> { ExceptionTrack::Log.count }, 1 do
      BookLab::Export::Archive.stub(:new, exporter) do
        ArchiveExportJob.perform_now(repo)
      end
    end
    assert_equal "done", repo.export_archive_status.value
  end
end

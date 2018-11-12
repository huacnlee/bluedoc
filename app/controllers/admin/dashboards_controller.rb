# frozen_string_literal: true

module Admin
  class DashboardsController < Admin::ApplicationController
    def show
    end

    def reindex
      SearchReindexJob.perform_later
      redirect_to admin_root_path, notice: "Search indexes has running reindex with async."
    end
  end
end

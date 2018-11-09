# frozen_string_literal: true

module Groups
  class ApplicationController < ::ApplicationController
    def set_group
      @group = Group.find_by_slug!(params[:group_id])
    end
  end
end

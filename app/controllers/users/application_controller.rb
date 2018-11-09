# frozen_string_literal: true

module Users
  class ApplicationController < ::ApplicationController
    def set_user
      @user = User.find_by_slug!(params[:user_id])
    end
  end
end

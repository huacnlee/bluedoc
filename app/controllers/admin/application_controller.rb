# frozen_string_literal: true

module Admin
  class ApplicationController < ::ApplicationController
    layout "admin"
    before_action :authenticate_user!
    before_action :require_admin!

    def require_admin!
      if !current_user.admin?
        raise CanCan::AccessDenied.new
      end
    end
  end
end

# frozen_string_literal: true

class ApplicationController < ActionController::Base
  depends_on :devise_parameters

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden }
      format.html { render plain: "Access Denied", status: :forbidden }
    end
  end

  def set_nav_search(url: request.fullpath)
    @nav_search_path = url
  end
end

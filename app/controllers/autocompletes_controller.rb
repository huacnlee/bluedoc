class AutocompletesController < ApplicationController
  before_action :authenticate_user!, only: %i[users]

  # GET /autocomplete/users
  def users
    @users = User.prefix_search(params[:q], user: current_user)
    render "users", layout: false
  end
end
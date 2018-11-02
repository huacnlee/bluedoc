class VersionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_version, except: [:index]

  def show
    authorize! :update, @version.subject
  end

  private

    def set_version
      @version = Version.find(params[:id])
      raise ActiveRecord::RecordNotFound if @version.subject.blank?
    end
end

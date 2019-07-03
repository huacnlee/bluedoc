# frozen_string_literal: true

class VersionsController < ApplicationController
  before_action :authenticate_anonymous!
  before_action :authenticate_user!
  before_action :set_version, except: [:index]

  def show
    authorize! :update, @version.subject
  end

  private
    def set_version
      @version = Version.find(params[:id])
      @current_version = @version.subject.versions.includes(:user).first
      @previous_version = @version.subject.versions.order("id desc").where("id < ?", @version.id).first
      raise ActiveRecord::RecordNotFound if @version.subject.blank?
    end
end

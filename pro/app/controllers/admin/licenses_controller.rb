# frozen_string_literal: true

class Admin::LicensesController < Admin::ApplicationController
  def show
  end

  def create
    license_data = params[:license]&.read || "empty"
    license = BlueDoc::License.import(license_data)
    if license.valid?
      License.update(license_data)
      redirect_to admin_licenses_path, notice: t(".License was successfully updated, thank you")
    else
      redirect_to admin_licenses_path, alert: t(".Invalid license")
    end
  rescue => e
    redirect_to admin_licenses_path, alert: t(".Invalid license")
  end

  def destroy
    Setting.license = ""
    redirect_to admin_licenses_path, notice: t(".License was successfully deleted")
  end
end

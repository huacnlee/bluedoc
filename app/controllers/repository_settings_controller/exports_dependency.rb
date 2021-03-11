# frozen_string_literal: true

class RepositorySettingsController
  # POST /:user/:repo/settings/export
  # - type: pdf|archive
  def export
    authorize! :update, @repository

    if request.get? && params[:type] == "pdf"
      render partial: "/export_pdf/repository", layout: "pdf", locals: {subject: @repository}
    elsif params[:force]
      @repository.export(params[:type])
    end
  end
end

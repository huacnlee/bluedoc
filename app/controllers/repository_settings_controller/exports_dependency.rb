# frozen_string_literal: true

class RepositorySettingsController
  # POST /:user/:repo/settings/export
  # - type: pdf|archive
  def export
    if params[:type] == "pdf"
      check_feature! :export_pdf
    else
      check_feature! :export_archive
    end

    authorize! :update, @repository

    if request.get? && params[:type] == "pdf"
      render partial: "/export_pdf/repository", layout: "pdf", locals: { subject: @repository }
    else
      if params[:force]
        @repository.export(params[:type])
      end
    end
  end
end

# frozen_string_literal: true

class PDFExportJob < ApplicationJob
  def perform(subject)
    pdf_file = nil

    if subject.is_a?(Doc)
      pdf_file = render("doc", subject)
    elsif subject.is_a?(Note)
      pdf_file = render("note", subject)
    elsif subject.is_a?(Repository)
      pdf_file = render("repository", subject)
    end

    subject.update_export!(:pdf, pdf_file)
  rescue => e
    BlueDoc::Error.track(e, title: "PDFExportJob [#{subject.class} #{subject.slug}] error")
  ensure
    pdf_file.close! if pdf_file
    subject.set_export_status(:pdf, "done")
  end

  def render(name, subject)
    html = ApplicationController.renderer.render(partial: "export_pdf/#{name}", layout: "pdf", locals: { subject: subject })
    WickedPdf.new.pdf_from_string(html, return_file: true)
  end
end

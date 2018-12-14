# frozen_string_literal: true

class PDFExportJob < ApplicationJob
  def perform(subject)
    pdf_file = nil

    if subject.is_a?(Doc)
      pdf_file = render("doc", subject)
    elsif subject.is_a?(Repository)
      pdf_file = render("repository", subject)
    end

    if pdf_file
      subject.pdf.attach(io: pdf_file, filename: subject.pdf_filename)
      subject.save!
    end
  rescue => e
    BookLab::Error.track(e, title: "PDFExportJob [#{subject.class} #{subject.slug}] error")
  ensure
    pdf_file.close! if pdf_file
    subject.export_pdf_status = "done"
  end

  def render(name, subject)
    html = ApplicationController.renderer.render(partial: "export_pdf/#{name}", layout: "pdf", locals: { subject: subject })
    WickedPdf.new.pdf_from_string(html, return_file: true)
  end
end

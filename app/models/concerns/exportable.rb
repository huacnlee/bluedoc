# frozen_string_literal: true

module Exportable
  extend ActiveSupport::Concern

  included do
    include Redis::Objects

    has_one_attached :pdf, dependent: false
    value :export_pdf_status
  end

  def export_pdf
    self.export_pdf_status = "running"
    PDFExportJob.perform_later(self)
  end

  def pdf_url
    return nil unless self.pdf.attached?
    "#{Setting.host}/uploads/#{self.pdf.blob.key}"
  end

  def pdf_filename
    fname = case self.class.name
            when "Doc"
              self.title
            when "Repository"
              self.name
            else
              "booklab-export"
            end
    "#{fname}.pdf"
  end
end

# frozen_string_literal: true

module Exportable
  extend ActiveSupport::Concern

  included do
    include Redis::Objects

    has_one_attached :pdf, dependent: false
    value :export_pdf_status

    has_one_attached :archive, dependent: false
    value :export_archive_status
  end

  def export(type)
    type = type.to_sym
    set_export_status(type, "running")

    if type == :pdf
      PDFExportJob.perform_later(self)
    elsif type == :archive
      ArchiveExportJob.perform_later(self)
    end
  end

  def export_url(type)
    type = type.to_sym
    return nil unless send(type).attached?

    if type == :pdf
      "#{Setting.host}/uploads/#{pdf.blob.key}"
    elsif type == :archive
      "#{Setting.host}/uploads/#{archive.blob.key}"
    end
  end

  def export_filename(type)
    type = type.to_sym
    fname = case self.class.name
            when "Doc"
              title
            when "Repository"
              name
            when "Note"
              title
            else
              "bluedoc-export"
    end

    if type == :pdf
      BlueDoc::Slug.filenameize("#{fname}.pdf")
    elsif type == :archive
      BlueDoc::Slug.filenameize("#{fname}.zip")
    end
  end

  def set_export_status(type, value)
    type = type.to_sym
    if type == :pdf
      self.export_pdf_status = value
    elsif type == :archive
      self.export_archive_status = value
    end
  end

  def export_status(type)
    type = type.to_sym
    if type == :pdf
      export_pdf_status
    elsif type == :archive
      export_archive_status
    end
  end

  def update_export!(type, io)
    type = type.to_sym
    return nil if io.blank?
    send(type).attach(io: io, filename: export_filename(type))
    save!
  end
end

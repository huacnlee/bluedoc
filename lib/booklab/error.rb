# frozen_string_literal: true

module BookLab
  class Error
    class << self
      # Track error to ExceptionTrack
      def track(e, title: nil)
        error_body = e.message + "\n\n"
        error_body += '-------------------------------------------------------------\n'
        error_body += (e.backtrace || []).join("\n")
        title ||= e.message

        ExceptionTrack::Log.create!(title: title, body: error_body)
      end
    end
  end
end

# frozen_string_literal: true

module BookLab
  class Error
    class << self
      # Track error to ExceptionTrack
      def track(e, title: nil, body: nil)
        body ||= ""
        body += "\n\n"
        body += e.class.name + ":\n"
        body += e.message + "\n\n"
        body += '-------------------------------------------------------------\n'
        body += (e.backtrace || []).join("\n")
        title ||= e.message

        ExceptionTrack::Log.create!(title: title, body: body)
      end
    end
  end
end

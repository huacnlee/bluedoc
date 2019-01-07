# frozen_string_literal: true

module BookLab::Status
  class BaseService < StatusPage::Services::Base
    def check_tcp!(host, timeout: 0.2)
      host ||= ""
      uri = URI.parse(host)

      Timeout::timeout(timeout) do
        s = TCPSocket.new(uri.host, uri.port)
        s.close
      rescue SocketError => e
        raise "#{host} service not exist"
      end
    end
  end
end

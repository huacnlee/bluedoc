# frozen_string_literal: true

module BlueDoc::Status
  class MathjaxService < BaseService
    def check!
      check_tcp!(Setting.mathjax_service_host)
    end
  end
end

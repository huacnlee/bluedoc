module BookLab::Status
  class MathjaxService < BaseService
    def check!
      check_tcp!(Setting.mathjax_service_host)
    end
  end
end
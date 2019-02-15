# frozen_string_literal: true

module BlueDoc::Status
  class PlantumlService < BaseService
    def check!
      check_tcp!(Setting.plantuml_service_host)
    end
  end
end

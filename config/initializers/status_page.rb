# frozen_string_literal: true

StatusPage.configure do
  # Cache check status result 10 seconds
  self.interval = 10
  # Use service
  use :database
  use :cache
  use :sidekiq
  add_custom_service(BlueDoc::Status::PlantumlService)
  add_custom_service(BlueDoc::Status::MathjaxService)
  add_custom_service(BlueDoc::Status::ElasticSearchService)
end

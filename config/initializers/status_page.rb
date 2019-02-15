# frozen_string_literal: true

StatusPage.configure do
  # Cache check status result 10 seconds
  self.interval = 10
  # Use service
  self.use :database
  self.use :cache
  self.use :sidekiq
  self.add_custom_service(BlueDoc::Status::PlantumlService)
  self.add_custom_service(BlueDoc::Status::MathjaxService)
  self.add_custom_service(BlueDoc::Status::ElasticSearchService)
end

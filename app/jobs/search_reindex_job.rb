# frozen_string_literal: true

class SearchReindexJob < ApplicationJob
  def perform
    User.where(type: "User").find_each { |record| record.__elasticsearch__.index_document }
    Group.find_each { |record| record.__elasticsearch__.index_document }
    Repository.find_each { |record| record.__elasticsearch__.index_document }
    Doc.find_each { |record| record.__elasticsearch__.index_document }
    Note.find_each { |record| record.__elasticsearch__.index_document }
  end
end

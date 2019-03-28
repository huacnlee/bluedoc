# frozen_string_literal: true

class SearchReindexJob < ApplicationJob
  def perform
    # https://github.com/elastic/elasticsearch-rails/blob/00596345ec1c22d177603dcdde7d6422a7cf8de7/elasticsearch-model/lib/elasticsearch/model/indexing.rb#L224
    # Force to recreate new index (Delete first) to ensure that old invalid data will be cleanup.
    [User, Group, Repository, Doc, Note].each do |klass|
      klass.__elasticsearch__.delete_index!(force: true)
      klass.__elasticsearch__.create_index!
    end

    User.where(type: "User").find_each { |record| record.__elasticsearch__.index_document }
    Group.find_each { |record| record.__elasticsearch__.index_document }
    Repository.find_each { |record| record.__elasticsearch__.index_document }
    Doc.find_each { |record| record.__elasticsearch__.index_document }
    Note.find_each { |record| record.__elasticsearch__.index_document }
  end
end

# frozen_string_literal: true

class SearchIndexJob < ApplicationJob
  queue_as :index
  delegate :client, to: Elasticsearch::Model

  def perform(operation, type, id)
    obj = nil

    type = type.downcase

    case type
    when "doc"
      obj = Doc.find_by_id(id)
    when "repository"
      obj = Repository.find_by_id(id)
    when "user"
      obj = User.find_by_id(id)
    when "group"
      obj = Group.find_by_id(id)
    end


    return false unless obj

    if operation == "update"
      obj.__elasticsearch__.update_document

      if type == "repository"
        invoke_client :update_by_query, index: "_all", body: {
          conflicts: "proceed",
          query: { term: { repository_id: obj.id } },
          script: { inline: "ctx._source.repository.public = #{obj.public?}" }
        }
      end
    elsif operation == "delete"
      obj.__elasticsearch__.delete_document

      if type == "repository"
        invoke_client :delete_by_query, index: "_all", body: {
          query: { term: { repository_id: obj.id } }
        }
      elsif type == "user"
        invoke_client :delete_by_query, index: "_all", body: {
          query: { term: { user_id: obj.id } }
        }
      end
    elsif operation == "index"
      obj.__elasticsearch__.index_document
    end
  rescue => e
    raise e unless Rails.env.test?
  end

  def invoke_client(method, opts = {})
    client.send(method, opts)
  end
end

# frozen_string_literal: true

class SearchIndexJob < ApplicationJob
  queue_as :index
  delegate :client, to: Elasticsearch::Model

  def perform(operation, type, id)
    obj = nil
    type = type.downcase

    if operation == "delete"
      return perform_for_delete(type, id)
    end

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

    return false if obj.blank?

    if operation == "update"
      obj.__elasticsearch__.update_document

      if type == "repository"
        invoke_client :update_by_query, index: "#{Doc.index_name},#{Repository.index_name}", body: {
          conflicts: "proceed",
          query: { term: { repository_id: obj.id } },
          script: { inline: "ctx._source.repository.public = #{obj.public?}" }
        }
      end
    elsif operation == "index"
      obj.__elasticsearch__.index_document
    end
  rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
    logger.warn e
  end

  def perform_for_delete(type, id)
    klass = type.classify.constantize
    invoke_client :delete, index: klass.index_name, type: klass.document_type, id: id

    if type == "repository"
      invoke_client :delete_by_query, index: "_all", body: {
        conflicts: "proceed",
        query: { term: { repository_id: id } }
      }
    elsif type == "user" || type == "group"
      invoke_client :delete_by_query, index: "_all", body: {
        conflicts: "proceed",
        query: { term: { user_id: id } }
      }
    end
  end

  def invoke_client(method, opts = {})
    client.send(method, opts)
  end
end

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
        invoke_client :update_by_query, index: "_all", body: {
          conflicts: "proceed",
          query: { term: { repository_id: obj.id } },
          script: { inline: "ctx._source.repository.public = #{obj.public?}" }
        }
      end
    elsif operation == "index"
      obj.__elasticsearch__.index_document
    end
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

  def perform_for_delete(type, id)
    klass = type.classify.constantize
    obj = klass.new(id: id)
    obj.__elasticsearch__.delete_document

    if type == "repository"
      invoke_client :delete_by_query, index: "_all", body: {
        conflicts: "proceed",
        query: { term: { repository_id: obj.id } }
      }
    elsif type == "user"
      invoke_client :delete_by_query, index: "_all", body: {
        conflicts: "proceed",
        query: { term: { user_id: obj.id } }
      }
    end
  end

  def invoke_client(method, opts = {})
    index_name = opts[:index]
    if index_name == "_all"
      all_index_names.each do |name|
        logger.info "invoke #{method} for index: #{name}, opts: #{opts}"
        client.send(method, opts.merge(index: name))
      end
    else
      logger.info "invoke #{method} for index: #{opts}"
      client.send(method, opts)
    end
  end

  private

    def all_index_names
      [User, Group, Repository, Doc].collect { |klass| klass.index_name }
    end
end

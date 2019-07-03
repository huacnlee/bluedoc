# frozen_string_literal: true

module BlueDoc
  # Global search with ElasticSearch
  class Search
    attr_accessor :type, :query, :user_id, :repository_id, :include_private, :client

    def initialize(type, query, user_id: nil, repository_id: nil, include_private: false)
      self.type = type.to_s.tableize.to_sym
      self.query = query
      self.user_id = user_id
      self.repository_id = repository_id
      self.include_private = include_private
      self.client = Elasticsearch::Model
    end

    def execute
      case self.type
      when :docs then search_docs
      when :repositories then search_repositories
      when :groups then search_groups
      when :users then search_users
      when :notes then search_notes
      when :issues then search_issues
      else
        raise ActiveRecord::RecordNotFound
      end
    end

    def private?
      self.include_private == true
    end

    def search_params(query, filter = [])
      filter << query
      params = {
        query: {
          bool: {
            must: filter,
            must_not: { term: { deleted: true } }
          }
        },
        highlight: {
          fields: { title: {}, body: {}, search_body: {} },
          pre_tags: ["[h]"],
          post_tags: ["[/h]"],
        }
      }
      params
    end

    private
      def search_docs
        filter = []

        if self.user_id
          filter << { term: { user_id: self.user_id } }
        elsif self.repository_id
          filter << { term: { repository_id: self.repository_id } }
        end

        if !self.private?
          filter << { term: { "repository.public" => true } }
        end



        q = {
          query_string: {
            fields: %w[slug title^10 body search_body],
            query: (self.query || ""),
            default_operator: "AND",
            minimum_should_match: "70%",
          }
        }

        params = search_params(q, filter)

        client.search(params, Doc)
      end

      def search_repositories
        filter = []

        if self.user_id
          filter << { term: { user_id: self.user_id } }
        end

        if !self.private?
          filter << { term: { "repository.public" => true } }
        end

        q = {
          query_string: {
            fields: %w[slug title^10 body search_body],
            query: "#{self.query} or *#{self.query}*",
          }
        }

        client.search(search_params(q, filter), Repository)
      end

      def search_notes
        filter = []

        if self.user_id
          filter << { term: { user_id: self.user_id } }
        end

        if !self.private?
          filter << { term: { public: true } }
        end

        q = {
          query_string: {
            fields: %w[slug title^10 body search_body],
            query: (self.query || ""),
            default_operator: "AND",
            minimum_should_match: "70%",
          }
        }

        client.search(search_params(q, filter), Note)
      end

      def search_groups
        filter = []
        filter << { term: { sub_type: "group" } }

        q = {
          query_string: {
            fields: %w[slug title^10 body search_body],
            query: "#{self.query} or *#{self.query}*",
          }
        }

        client.search(search_params(q, filter), Group)
      end

      def search_users
        filter = []
        filter << { term: { sub_type: "user" } }

        q = {
          query_string: {
            fields: %w[slug title^10 body search_body],
            query: "#{self.query} or *#{self.query}*",
          }
        }

        client.search(search_params(q, filter), User)
      end

      def search_issues
        filter = []

        if self.user_id
          filter << { term: { user_id: self.user_id } }
        elsif self.repository_id
          filter << { term: { repository_id: self.repository_id } }
        end

        if !self.private?
          filter << { term: { "repository.public" => true } }
        end

        q = {
          query_string: {
            fields: %w[slug title^10 body search_body],
            query: (self.query || ""),
            default_operator: "AND",
            minimum_should_match: "70%",
          }
        }

        params = search_params(q, filter)

        client.search(params, Issue)
      end
  end
end

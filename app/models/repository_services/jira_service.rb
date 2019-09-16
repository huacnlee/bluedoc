# frozen_string_literal: true

class JiraService < Service
  store_accessor :properties, :site, :username, :password
  validates :site, :username, :password, presence: true, if: :need_validate?
  validate :validate_site, :auth_service, if: :need_validate?

  def self.accessible_attrs
    super.concat [:site, :username, :password]
  end

  def extract_jira_keys doc
    Rails.cache.fetch(["jira_service", "doc_issue_keys", doc.id, doc.updated_at], expires_in: 1.day) do
      doc.body_plain
        .scan(jira_issue_key_regex)
        .flatten
        .uniq
    end
  end

  def issues issue_keys
    return [] if issue_keys.blank?
    data = jira_request { JIRA::Resource::Issue.jql(client, "id in (#{issue_keys.join(",")})", fields: issue_fields, validate_query: false) }
    Array(data).map { |issue| issue_as_json(issue) }
  end

  private

    def validate_site
      self.errors.add(:site, t(".is not a valid site, only support HTTP or HTTPS protocol")) unless BlueDoc::Validate.url?(site)
    end

    def jira_request
      yield
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, Errno::ECONNREFUSED, URI::InvalidURIError, JIRA::HTTPError, OpenSSL::SSL::SSLError => e
      @request_error = "#{e.class} #{e.message}"
      Rails.logger.error("Error on JiraService##{id}: #{e.class} #{@request_error}")
      nil
    end

    def auth_service
      return if self.errors.present?
      result = jira_request { client.ServerInfo.all.attrs }
      return if result.present?
      self.errors.add(:base, t(".test JIRA service connection faield, please check the JIRA user name and password")) if @request_error
    end

    def jira_issue_key_regex
      /\[.+?\]\(#{Regexp.escape(site)}(?:\/)?(?:browse|.+\/issues)\/([A-Z][A-Z_0-9]+-\d+).*\)/
    end

    def issue_url issue
      "#{site}/browse/#{issue.key}"
    end

    def issue_as_json issue
      { key: issue.key, summary: issue.summary, url: issue_url(issue) }
    end

    def issue_fields
      [:key, :summary, :url]
    end

    def client
      return @client if @client
      options = {
        :site         => site,
        :username     => username,
        :password     => password,
        :context_path => '',
        :auth_type    => :basic
      }

      @client = JIRA::Client.new(options)
    end
end

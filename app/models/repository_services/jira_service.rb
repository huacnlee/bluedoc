# frozen_string_literal: true

class JiraService < Service

  def extract_jira_keys text
    text
      .scan(jira_issue_key_regex)
      .flatten
      .uniq
  end

  def issues issue_keys
    return [] if issue_keys.blank?
    data = JIRA::Resource::Issue.jql(client, "id in (#{issue_keys.join(",")})", fields: issue_fields, validate_query: false)
    data.map { |issue| issue_as_json(issue) }
  end

  private

    def jira_issue_key_regex
      /\[.+\]\(#{Regexp.escape(Setting.jira_service_site)}(?:\/)?(?:browse|.+\/issues)\/([A-Z][A-Z_0-9]+-\d+).*\)/
    end

    def issue_url issue
      "#{Setting.jira_service_site}/browse/#{issue.key}"
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
        :username     => Setting.jira_service_username,
        :password     => Setting.jira_service_password,
        :site         => Setting.jira_service_site,
        :context_path => '',
        :auth_type    => :basic
      }

      @client = JIRA::Client.new(options)
    end
end

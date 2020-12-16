# frozen_string_literal: true

require "test_helper"

class JiraServiceTest < ActiveSupport::TestCase
  test "valid" do
    repository = create(:repository)
    jira_service = JiraService.new(repository: repository, active: false)
    assert jira_service.valid?

    jira_service.assign_attributes(active: true)
    assert_not jira_service.valid?
    assert_equal ["Jira site can't be blank", "Jira site is not a valid site, only support HTTP or HTTPS protocol", "Username can't be blank", "Password can't be blank"].sort, jira_service.errors.full_messages.sort

    jira_service.assign_attributes(site: "http://my-jira.com", username: "jirausername", password: "jirapwd")
    JiraService.any_instance.stubs(:jira_request).once
    jira_service.instance_variable_set(:@request_error, true)
    assert_not jira_service.valid?
    assert_equal ["Test Jira service connection faield, please check the Jira user name and password"], jira_service.errors.full_messages

    jira_service.assign_attributes(site: "http://my-jira.com", username: "jirausername", password: "jirapwd")
    jira_service.remove_instance_variable(:@request_error)
    JiraService.any_instance.stubs(:jira_request).once
    assert jira_service.valid?
  end

  test "extract_jira_keys" do
    body = <<-EOF
http://my-jira.com/browse/PP-1
[PP-3](http://my-jira.com/browse/PP-3)
[PP-3](http://my-jira.com/browse/PP-3)
[test](http://my-jira.com/browse/go)
[PP-5](http://other-jira.com/browse/PP-5)
[PP-10](http://my-jira.com/projects/PP/issues/PP-10?filter=allopenissues)
    EOF
    doc = create(:doc, body: body)

    JiraService.any_instance.stubs(:auth_service).once
    jira_service = JiraService.create(active: true, site: "http://my-jira.com", username: "jirausername", password: "jirapwd", repository: create(:repository))

    keys = jira_service.extract_jira_keys doc
    expected = ["PP-3", "PP-10"]
    assert_equal expected, keys
    assert_equal expected, Rails.cache.read(["jira_service", "doc_issue_keys", doc.id, doc.updated_at])
  end
end

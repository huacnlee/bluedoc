# frozen_string_literal: true

require "test_helper"

class ApplicationRecordTest < ActiveSupport::TestCase
  test "as_rc_json" do
    group = build(:group, slug: "admin&^", name: "1", description: "Hello world")
    assert_equal false, group.valid?

    json = group.as_rc_json(only: %i[slug name description])
    assert_equal %w[slug name description errors].sort, json.keys.sort
    assert_equal group.slug, json["slug"]
    assert_equal group.name, json["name"]
    assert_equal group.description, json["description"]

    assert_equal "Group name invalid, [admin&^] is a keyword.", json["errors"]["slug"]
    assert_equal "Title is too short (minimum is 2 characters)", json["errors"]["name"]
  end
end
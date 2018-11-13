# frozen_string_literal: true

require "test_helper"

class SearchableTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  TYPES = %i(doc repository group user)

  test "index_name" do
    assert_equal "test-docs", Doc.index_name
    assert_equal "test-repositories", Repository.index_name
    assert_equal "test-users", User.index_name
    assert_equal "test-groups", Group.index_name
  end

  test ".reindex" do
    TYPES.each do |type|
      item = create(type)
      assert_enqueued_with job: SearchIndexJob, args: ["index", type.to_s.classify, item.id] do
        item.reindex
      end
    end
  end

  test "create hook" do
    TYPES.each do |type|
      assert_enqueued_with job: SearchIndexJob do
        create(type)
      end
    end
  end

  test "update hook" do
    TYPES.each do |type|
      item = create(type)
      assert_no_enqueued_jobs do
        item.save
      end

      assert_enqueued_with job: SearchIndexJob, args: ["update", type.to_s.classify, item.id] do
        item.stub(:indexed_changed?, true) do
          item.save
        end
      end
    end
  end

  test "destroy hook" do
    TYPES.each do |type|
      item = create(type)
      assert_enqueued_with job: SearchIndexJob, args: ["delete", type.to_s.classify, item.id] do
        item.destroy
      end
    end
  end

  test "model reigstry" do
    # Touch class first
    Group.first
    User.first
    Doc.first
    Repository.first

    # check Elasticsearch::Model Registry
    registry_names = Elasticsearch::Model::Registry.all.collect(&:index_name)
    assert_equal true, registry_names.include?("test-groups")
    assert_equal true, registry_names.include?("test-users")
    assert_equal true, registry_names.include?("test-repositories")
    assert_equal true, registry_names.include?("test-docs")
  end
end

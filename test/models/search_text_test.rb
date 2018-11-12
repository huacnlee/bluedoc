require 'test_helper'

class SearchTextTest < ActiveSupport::TestCase
  test "index doc" do
    Setting.stub(:default_locale, "zh-CN") do
      # doc
      doc = create(:doc, title: "Hello world\n this is title", body: "Hello\n this is body 中文文本搜索演示")

      item = SearchText.where(record: doc).last
      assert_equal doc, item.record
      assert_equal doc.repository_id, item.repository_id
      assert_equal doc.repository.user_id, item.user_id
      assert_equal "Hello world title", item.title
      assert_equal doc.slug, item.slug
      assert_equal "Hello body 中文 文本 搜索 演示", item.body

      doc.title = "New this is title"
      doc.save
      item1 = SearchText.where(record: doc).last
      assert_equal item.id, item1.id
      assert_equal "New title", item1.title

      doc.destroy
      assert_nil SearchText.where(record: doc).last

      # repository
      repo = create(:repository, name: "Simple 项目演示", description: "body 中文文本搜索演示")
      item = SearchText.where(record: repo).last
      assert_equal repo, item.record
      assert_equal repo.id, item.repository_id
      assert_equal repo.user_id, item.user_id
      assert_equal "Simple 项目 演示", item.title
      assert_equal repo.slug, item.slug
      assert_equal "body 中文 文本 搜索 演示", item.body

      repo.update(name: "Complex 项目演示", description: "description演示")
      item1 = SearchText.where(record: repo).last
      assert_equal item.id, item1.id
      assert_equal "Complex 项目 演示", item1.title
      assert_equal "description 演示", item1.body

      create_list(:search_text, 2, repository_id: repo.id)
      assert_equal 3, SearchText.where(repository_id: repo.id).count
      repo.destroy
      assert_equal 0, SearchText.where(repository_id: repo.id).count
      assert_equal 0, SearchText.where(record: repo).count

      # group
      group = create(:group, name: "Simple 团队演示", description: "body 中文文本搜索演示")
      item = SearchText.where(record_type: "Group", record_id: group.id).last
      assert_equal "Group", item.record_type
      assert_equal group, item.record
      assert_nil item.repository_id
      assert_equal group.id, item.user_id
      assert_equal "Simple 团队 演示", item.title
      assert_equal group.slug, item.slug
      assert_equal "body 中文 文本 搜索 演示", item.body

      group.update(name: "团队演示Simple")
      item1 = SearchText.where(record_type: "Group", record_id: group.id).last
      assert_equal item.id, item1.id
      assert_equal "团队 演示 Simple", item1.title

      create_list(:search_text, 2, user_id: group.id)
      assert_equal 3, SearchText.where(user_id: group.id).count
      group.destroy
      assert_equal 0, SearchText.where(user_id: group.id).count
      assert_equal 0, SearchText.where(record: group).count

      # user
      user = create(:user, name: "Simple 团队演示", description: "body 中文文本搜索演示")
      item = SearchText.where(record: user).last
      assert_equal "User", item.record_type
    end
  end

  test "Search dependency" do
    Setting.stub(:default_locale, "zh-CN") do
      # create
      doc0 = create(:doc, title: "Ha ha ha with title", body: "This is ha ha ha body")
      doc = create(:doc, title: "This is title", body: "Hello\n this is body 中文文本搜索演示")

      # prefix_text = "#{doc.repository.user.name} #{doc.repository.user.slug} #{doc.repository.name} #{doc.repository.slug}"

      search_text = SearchText.where(record: doc).last
      assert_not_nil search_text
      assert_equal doc, search_text.record
      assert_equal "Hello body 中文 文本 搜索 演示", search_text.body

      items = SearchText.search(:docs, "title")
      assert_equal 2, items.length

      items = SearchText.search(:docs, "hello body")
      assert_equal 1, items.length
      assert_equal doc, items.first.record

      items = SearchText.search(:docs, "body hello")
      assert_equal 1, items.length
      assert_equal doc, items.last.record

      items = SearchText.search(:docs, "中文演示搜索")
      assert_equal 1, items.length
      assert_equal doc, items.last.record
    end
  end
end

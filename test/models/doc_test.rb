# frozen_string_literal: true

require "test_helper"

class DocTest < ActiveSupport::TestCase
  test "Slugable" do
    repo = create(:repository)
    doc = create(:doc, repository: repo, slug: "FooBar")
    assert_equal "#{doc.repository.to_path}/#{doc.slug}", doc.to_path
    assert_equal "FooBar", doc.slug

    assert_equal doc, repo.docs.find_by_slug(doc.slug)
    assert_equal doc, repo.docs.find_by_slug!(doc.slug.upcase)
    assert_equal [Setting.host, doc.to_path].join(""), doc.to_url

    # slug unique with case insensitive
    doc = build(:doc, repository: repo, slug: "fooBar")
    assert_equal false, doc.valid?
    assert_equal ["has already been taken"], doc.errors[:slug]

    # auto format slug
    doc = build(:doc, slug: " Get started ")
    assert_equal true, doc.valid?
    assert_equal "Get-started", doc.slug
  end

  test "Markdownable" do
    doc = create(:doc, body: "Hello **world**")
    assert_equal "<p>Hello <strong>world</strong></p>", doc.body_html
  end

  test "Body touch" do
    doc = create(:doc)
    assert_not_nil doc[:body_updated_at]
    old_updated_at = doc[:body_updated_at]
    doc.save
    assert_not_equal old_updated_at, doc.body_updated_at
  end

  test "User Active" do
    user = create(:user)

    doc0 = create(:doc, last_editor_id: user.id)
    doc1 = create(:doc, last_editor_id: user.id)

    assert_equal 1, user.user_actives.where(subject: doc0).count
    assert_equal 1, user.user_actives.where(subject: doc0.repository).count
    assert_equal 1, user.user_actives.where(subject: doc0.repository.user).count

    doc0.destroy
    assert_equal 1, UserActive.where(subject_type: "Doc").count
    doc1.destroy
    assert_equal 0, UserActive.where(subject_type: "Doc").count
  end

  test "Watches on create/update" do
    user = create(:user)
    user1 = create(:user)
    user2 = create(:user)

    # user watch by create
    mock_current user: user
    doc = create(:doc)
    assert_equal [user.id], doc.watch_comment_by_user_ids

    # user2 direct watch, with "watch" action_option
    User.create_action(:watch_comment, target: doc, user: user2, action_option: "watch")

    # user1 watch by update
    mock_current user: user1
    doc.update(title: "New title")
    doc.reload

    # should user, user1, user2 in watching
    assert_equal [user.id, user1.id, user2.id].sort, doc.watch_comment_by_user_ids.sort

    # user to watch with "ignore" action_option
    User.create_action(:watch_comment, target: doc, user: user, action_option: "ignore")
    assert_equal [user1.id, user2.id].sort, doc.watch_comment_by_user_ids.sort

    # and then user to update again, it will not change action_option
    mock_current user: user
    doc.update(title: "New new title")
    assert_equal [user1.id, user2.id].sort, doc.watch_comment_by_user_ids.sort
    action = User.find_action(:watch_comment, target: doc, user: user)
    assert_equal "ignore", action.action_option
  end

  test "actors" do
    user = create(:user)

    mock_current(user: user)
    doc = create(:doc)

    assert_equal user.id, doc.creator_id
    assert_equal user.id, doc.last_editor_id
    assert_equal [user.id], doc.editor_ids

    other_u0 = create(:user)
    other_u1 = create(:user)
    repo_old_editor_ids = [other_u0.id, other_u1.id]
    repo = create(:repository, editor_ids: repo_old_editor_ids)

    doc = create(:doc, repository: repo, last_editor_id: 11, creator_id: 22)
    assert_equal user.id, doc.last_editor_id
    assert_equal user.id, doc.creator_id
    assert_equal [user.id], doc.editor_ids

    user1 = create(:user)
    mock_current(user: user1)
    doc.save
    assert_equal user1.id, doc.last_editor_id
    assert_equal user.id, doc.creator_id
    assert_equal [user.id, user1.id], doc.editor_ids
    assert_equal [user, user1], doc.editors

    doc.update(title: "New title")
    assert_equal [user.id, user1.id], doc.editor_ids

    user2 = create(:user)
    doc1 = create(:doc, repository: repo, editor_ids: [user1.id, user2.id])

    # check repo editor_ids will including doc.editor_ids, doc1.editor_ids
    repo.reload
    assert_equal (repo_old_editor_ids + doc.editor_ids + doc1.editor_ids).uniq, repo.editor_ids
    assert_equal 5, repo.editor_ids.length
  end

  test ".draft_title" do
    doc = Doc.new(title: "AAA")
    assert_equal "AAA", doc.title
    assert_equal doc.title, doc.draft_title

    doc.draft_title = "BBB"
    assert_equal "AAA", doc.title
    assert_equal "BBB", doc.draft_title
  end

  test ".draft_body" do
    doc = create(:doc, body: "AAA")
    assert_equal "AAA", doc.body_plain
    assert_equal doc.body_plain, doc.draft_body_plain

    doc.update(draft_body: "BBB")
    assert_equal "AAA", doc.body_plain
    assert_equal "BBB", doc.draft_body_plain
  end

  test ".draft_body_sml" do
    doc = create(:doc, body_sml: "AAA")
    assert_equal "AAA", doc.body_sml_plain
    assert_equal doc.body_sml_plain, doc.draft_body_sml_plain

    doc.update(draft_body_sml: "BBB")
    assert_equal "AAA", doc.body_sml_plain
    assert_equal "BBB", doc.draft_body_sml_plain
  end

  test "create_new" do
    repo = create(:repository)
    doc = Doc.create_new(repo, 123)
    assert_equal false, doc.new_record?
    assert_not_nil doc.slug
    assert_equal "New Document", doc.title
    assert_equal "New Document", doc.draft_title
    assert_equal repo.id, doc.repository_id
    assert_equal 123, doc.last_editor_id
  end

  test "_search_body" do
    user = create(:user)
    repo = create(:repository, user: user)
    doc = create(:doc, repository: repo, body: "Hello world")

    expected = [user.fullname, repo.fullname, doc.to_path, doc.body_plain].join("\n\n")
    assert_equal expected, doc._search_body
  end

  test "as_indexed_json" do
    repo = create(:repository)
    doc = create(:doc, repository: repo, body: "Hello world")

    doc.stub(:_search_body, "Search body") do
      data = { slug: doc.slug, title: doc.title, body: "Hello world", search_body: "Search body", repository_id: repo.id, user_id: repo.user_id, repository: { public: true } }
      assert_equal data, doc.as_indexed_json
    end

    repo = create(:repository, privacy: :private)
    doc = create(:doc, repository: repo, body: "Hello world")

    doc.stub(:_search_body, "Search body") do
      data = { slug: doc.slug, title: doc.title, body: "Hello world", search_body: "Search body", repository_id: repo.id, user_id: repo.user_id, repository: { public: false } }
      assert_equal data, doc.as_indexed_json
    end
  end

  test "indexed_changed?" do
    doc = create(:doc)
    assert_equal true, doc.indexed_changed?

    doc = Doc.find(doc.id)
    assert_equal false, doc.indexed_changed?
    doc.updated_at = Time.now
    doc.draft_title = "Draft title"
    assert_equal false, doc.indexed_changed?

    doc.stub(:saved_change_to_title?, true) do
      assert_equal true, doc.indexed_changed?
    end

    doc = Doc.find(doc.id)
    doc.body = "New Body"
    assert_equal true, doc.indexed_changed?
  end

  test "reactions" do
    doc = create(:doc)
    create(:reaction, subject: doc)
    assert_equal 1, doc.reactions.count
    assert_equal doc, doc.reactions.first.subject
  end
end

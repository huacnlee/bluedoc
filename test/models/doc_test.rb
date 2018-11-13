# frozen_string_literal: true

require "test_helper"

class DocTest < ActiveSupport::TestCase
  test "Slugable" do
    repo = create(:repository)
    doc = create(:doc, repository: repo)
    assert_equal "#{doc.repository.to_path}/#{doc.slug}", doc.to_path

    assert_equal doc, repo.docs.find_by_slug(doc.slug)
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

  test "actors" do
    user = create(:user)

    mock_current(user: user)
    doc = create(:doc)

    assert_equal user.id, doc.creator_id
    assert_equal user.id, doc.last_editor_id

    doc = create(:doc, last_editor_id: 11, creator_id: 22)
    assert_equal user.id, doc.last_editor_id
    assert_equal user.id, doc.creator_id

    user1 = create(:user)
    mock_current(user: user1)
    doc.save
    assert_equal user1.id, doc.last_editor_id
    assert_equal user.id, doc.creator_id
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

  test "as_indexed_json" do
    repo = create(:repository)
    doc = create(:doc, repository: repo, body: "Hello world")

    data = { slug: doc.slug, title: doc.title, body: "Hello world", repository_id: repo.id, user_id: repo.user_id, repository: { public: true } }
    assert_equal data, doc.as_indexed_json

    repo = create(:repository, privacy: :private)
    doc = create(:doc, repository: repo, body: "Hello world")
    data = { slug: doc.slug, title: doc.title, body: "Hello world", repository_id: repo.id, user_id: repo.user_id, repository: { public: false } }
    assert_equal data, doc.as_indexed_json
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
end

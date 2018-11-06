require 'test_helper'

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
end

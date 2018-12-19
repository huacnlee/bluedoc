# frozen_string_literal: true

require "test_helper"

class SoftDeleteTest < ActiveSupport::TestCase
  test "Soft Delete with Group destroy" do
    group0 = create(:group, slug: "group-0")
    repo0 = create(:repository, user: group0, slug: "repo-0")
    repo1 = create(:repository, user: group0, slug: "repo-1")
    repo2 = create(:repository, slug: "repo-2")
    doc0 = create(:doc, repository: repo0, slug: "doc-0")
    doc1 = create(:doc, repository: repo1, slug: "doc-1")
    doc2 = create(:doc, repository: repo2, slug: "doc-2")
    comment0 = create(:comment, commentable: doc0)
    comment1 = create(:comment, commentable: doc1)
    comment2 = create(:comment)
    member0 = create(:member, subject: group0)
    member1 = create(:member, subject: repo0)
    member2 = create(:member)

    create_list(:activity, 2, group_id: group0.id)
    create_list(:activity, 2, repository_id: repo0.id)

    assert_equal 2, Activity.where(group_id: group0.id).count
    assert_equal 2, Activity.where(repository_id: repo0.id).count

    # Destroy
    group0.destroy
    assert_equal true, group0.frozen?
    assert_equal true, group0.destroyed?
    assert_soft_deleted Group, group0, slug: "group-0"
    assert_soft_deleted Repository, repo0, slug: "repo-0"
    assert_equal true, repo0.reload.deleted_at >= group0.reload.deleted_at
    assert_soft_deleted Repository, repo1, slug: "repo-1"
    assert_no_soft_delete Repository, repo2, slug: "repo-2"
    assert_soft_deleted Doc, doc0, slug: "doc-0"
    assert_soft_deleted Doc, doc1, slug: "doc-1"
    assert_no_soft_delete Doc, doc2, slug: "doc-2"
    assert_soft_deleted Comment, comment0
    assert_soft_deleted Comment, comment1
    assert_no_soft_delete Comment, comment2
    assert_soft_deleted Member, member0
    assert_soft_deleted Member, member1
    assert_no_soft_delete Member, member2
    assert_equal 0, Activity.where(group_id: group0.id).count
    assert_equal 0, Activity.where(repository_id: repo0.id).count

    # Restore
    group = Group.unscoped.find_by_id(group0.id)
    assert_not_nil group.deleted_at
    group.restore
    assert_no_soft_delete Group, group0, slug: "group-0"
    assert_no_soft_delete Repository, repo0, slug: "repo-0"
    assert_no_soft_delete Repository, repo1, slug: "repo-1"
    assert_no_soft_delete Doc, doc0, slug: "doc-0"
    assert_no_soft_delete Doc, doc1, slug: "doc-1"
    assert_no_soft_delete Comment, comment0
    assert_no_soft_delete Comment, comment1
    assert_no_soft_delete Member, member0
    assert_no_soft_delete Member, member1

    # Destroy again
    group.destroy
    assert_soft_deleted Group, group0, slug: "group-0"
    assert_soft_deleted Repository, repo0, slug: "repo-0"
    assert_soft_deleted Doc, doc0, slug: "doc-0"

    # Use same slug
    group3 = create(:group, slug: "group-0")
    assert_equal false, group3.new_record?
    assert_equal "group-0", group3.slug
    group = Group.unscoped.find_by_id(group0.id)
    group.restore

    assert_no_soft_delete Group, group
    assert_not_equal "group-0", group.slug
    assert_match /group\-0\-/, group.slug
    assert_no_soft_delete Repository, repo0, slug: "repo-0"
    assert_no_soft_delete Doc, doc0, slug: "doc-0"
  end

  test "Soft Delete with Repository" do
    repo0 = create(:repository, slug: "repo-0")
    repo1 = create(:repository, slug: "repo-1")
    doc0 = create(:doc, repository: repo0, slug: "doc-0")
    doc1 = create(:doc, repository: repo0, slug: "doc-1")
    doc2 = create(:doc, repository: repo1, slug: "doc-2")
    comment0 = create(:comment, commentable: doc0)
    comment1 = create(:comment, commentable: doc1)
    comment2 = create(:comment, commentable: doc2)
    member0 = create(:member, subject: repo0)
    member1 = create(:member, subject: repo1)

    repo0.destroy
    assert_soft_deleted Repository, repo0, slug: "repo-0"
    assert_soft_deleted Doc, doc0, slug: "doc-0"
    assert_soft_deleted Doc, doc1, slug: "doc-1"
    assert_no_soft_delete Doc, doc2, slug: "doc-2"
    assert_soft_deleted Comment, comment0
    assert_soft_deleted Comment, comment1
    assert_no_soft_delete Comment, comment2
    assert_soft_deleted Member, member0
    assert_no_soft_delete Member, member1

    # Restore
    repo = Repository.unscoped.find(repo0.id)
    repo.restore
    assert_no_soft_delete Repository, repo0, slug: "repo-0"
    assert_no_soft_delete Doc, doc0, slug: "doc-0"
    assert_no_soft_delete Doc, doc1, slug: "doc-1"
    assert_no_soft_delete Comment, comment0
    assert_no_soft_delete Comment, comment1
    assert_no_soft_delete Member, member0

    repo.destroy

    # Create same slug as repo0 and then restore
    repo3 = create(:repository, user: repo0.user, slug: "repo-0")
    assert_equal false, repo3.new_record?
    assert_equal "repo-0", repo3.slug
    repo = Repository.unscoped.find(repo0.id)
    repo.restore

    assert_no_soft_delete Repository, repo
    assert_not_equal "repo-0", repo.slug
    assert_match /repo\-0\-/, repo.slug
    assert_no_soft_delete Doc, doc0, slug: "doc-0"
    assert_no_soft_delete Doc, doc1, slug: "doc-1"
    assert_no_soft_delete Comment, comment0
    assert_no_soft_delete Comment, comment1
    assert_no_soft_delete Member, member0
  end

  test "Soft Delete doc with restore dependents" do
    doc = create(:doc, body: "Hello world")
    comment0 = create(:comment, commentable: doc)
    comment1 = create(:comment, commentable: doc)
    comment2 = create(:comment, commentable: doc)
    versions = create_list(:doc_version, 2, subject: doc)

    # delete comment2 first
    comment2.destroy
    assert_soft_deleted Comment, comment2

    sleep 0.01
    doc.destroy

    assert_soft_deleted Doc, doc
    assert_soft_deleted Comment, comment0
    assert_soft_deleted Comment, comment1
    assert_equal "Hello world", RichText.where(record: doc).first&.body
    assert_equal 3, doc.versions.count
    assert_equal "Hello world", doc.versions.last&.body_plain

    doc = Doc.unscoped.find(doc.id)
    doc.restore
    assert_no_soft_delete Doc, doc
    assert_equal "Hello world", doc.body_plain
    assert_not_nil RichText.where(record: doc).first
    assert_equal 3, doc.versions.count
    assert_equal "Hello world", doc.versions.last&.body_plain

    assert_no_soft_delete Comment, comment0
    assert_no_soft_delete Comment, comment1
    # comment2 has deleted before doc destroy, so it will not restore
    assert_soft_deleted Comment, comment2
  end

  test "Soft Delete restore with Member exist" do
    repo = create(:repository)
    user0 = create(:user)
    member0 = create(:member, subject: repo, user: user0)

    member0.destroy
    assert_soft_deleted Member, member0

    member = Member.unscoped.find(member0.id)
    member.restore
    assert_no_soft_delete Member, member

    # add user with deleted will restore record
    member.destroy

    repo.add_member(user0, :editor)
    member = Member.unscoped.find(member0.id)
    assert_no_soft_delete Member, member
    assert_equal "editor", member.role
  end

  private
    # check record has soft deleted
    def assert_soft_deleted(klass, item, slug: nil)
      assert_nil klass.find_by_id(item.id), "should not find anymore with id"
      reload_item = klass.unscoped.find_by_id(item.id)
      assert_not_nil reload_item.deleted_at, "deleted_at should present"
      assert_equal reload_item.deleted_at.to_s, reload_item.updated_at.to_s, "updated_at should equal to deleted_at"

      if slug
        assert_equal slug, reload_item.deleted_slug, "deleted_slug should equal #{slug}"
        assert_not_equal slug, reload_item.slug, "slug should not equal #{slug}"
        assert_match /deleted\-/, reload_item.slug, "slug should prefix with deleted-"
      end
    end

    def assert_no_soft_delete(klass, item, slug: nil)
      reload_item = klass.unscoped.find_by_id(item.id)
      assert_nil reload_item.deleted_at, "deleted_at should be nil"

      if slug
        assert_equal slug, reload_item.slug, "slug should equal #{slug}"
        assert_nil reload_item.deleted_slug, "deleted_slug should be nil"
      end
    end
end

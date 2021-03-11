# frozen_string_literal: true

require "test_helper"

class TocTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test "create_by_toc_text! with toc_text exist" do
    repo = create(:repository)
    old_updated_at = repo.updated_at
    docs = create_list(:doc, 6, repository: repo)

    toc_docs = [
      { id: docs[1].id, url: docs[1].slug, title: docs[1].title, depth: 0 }.as_json,
      { id: docs[0].id, url: docs[0].slug, title: docs[0].title, depth: 1 }.as_json,
      { id: docs[2].id, url: docs[2].slug, title: docs[2].title, depth: 2 }.as_json,
      { id: docs[4].id, url: docs[4].slug, title: docs[4].title, depth: 0 }.as_json,
      { id: nil, url: "test", title: "Test url", depth: 1 }.as_json,
      { id: docs[3].id, url: docs[3].slug, title: docs[3].title, depth: 0 }.as_json,
      { id: docs[5].id, url: docs[5].slug, title: docs[5].title, depth: 1 }.as_json,
    ]

    repo.tocs.destroy_all
    RichText.create!(record: repo, name: "toc", body: toc_docs.to_yaml)

    # Do upgrade
    Toc.create_by_toc_text!(repo)

    # Reload
    repo = Repository.find(repo.id)
    assert_not_equal old_updated_at, repo.updated_at
    assert_equal toc_docs.to_yaml, repo.tocs.to_text
  end

  test "create_by_toc_text! with not toc_text" do
    repo = create(:repository)
    old_updated_at = repo.updated_at
    docs = create_list(:doc, 6, repository: repo)
    # cleanup auto created tocs first
    Toc.where(repository: repo).delete_all

    # Do upgrade
    Toc.create_by_toc_text!(repo)

    assert_equal docs.sort, repo.tocs.collect(&:doc).sort
  end

  test "next / prev" do
    repo = create(:repository)
    docs = create_list(:doc, 4, repository: repo)

    assert_equal 4, repo.tocs.length
    docs[0].move_to(docs[1], :child)

    assert_equal docs[1], docs[0].toc.prev.doc
    assert_equal docs[2], docs[0].toc.next.doc

    assert_equal docs[0], docs[2].toc.prev.doc
    assert_equal docs[3], docs[2].toc.next.doc
  end

  test "destroy" do
    repo = create(:repository)
    doc0 = create(:doc, repository: repo, title: "First item")
    doc = create(:doc, repository: repo, title: "Will delete item")
    docs = [
      create(:doc, title: "title 1", repository: repo),
      create(:doc, title: "title 2", repository: repo),
      create(:doc, title: "title 3", repository: repo),
      create(:doc, title: "title 4", repository: repo)
    ]
    docs[0].move_to(doc, :child)
    docs[1].move_to(docs[0], :right)
    docs[2].move_to(docs[0], :child)
    docs[3].move_to(docs[2], :child)
    doc1 = create(:doc, repository: repo, title: "Last item")

    toc = doc.toc

    # check children nested
    assert_equal 2, Toc.where(repository_id: toc.repository_id, parent_id: toc.id).count
    assert_equal 1, docs[0].toc.depth
    assert_equal toc.id, docs[0].toc.parent_id
    assert_equal 1, docs[1].toc.depth
    assert_equal toc.id, docs[1].toc.parent_id
    assert_equal 2, docs[2].toc.depth
    assert_equal docs[0].toc.id, docs[2].toc.parent_id
    assert_equal 3, docs[3].toc.depth
    assert_equal docs[2].toc.id, docs[3].toc.parent_id

    expected_struct = <<~TOC
    First item
    Will delete item
      title 1
        title 3
          title 4
      title 2
    Last item
    TOC
    repo_tocs = repo.tocs.nested_tree
    toc_struct = repo_tocs.map { |item| "  " * item.depth + item.title }.join("\n")
    assert_equal expected_struct.strip, toc_struct.strip

    assert_equal 7, repo.tocs.count
    assert_equal 7, repo.docs.count

    toc.destroy

    assert_equal 6, repo.tocs.count
    assert_equal 6, repo.docs.count

    assert_nil Toc.find_by_id(toc.id)
    assert_nil Doc.find_by_id(doc.id)

    # doc.children will move to toc left, and keep nested tree
    docs[0].reload
    assert_equal 0, docs[0].toc.depth
    assert_nil docs[0].toc.parent_id
    docs[1].reload
    assert_equal 0, docs[1].toc.depth
    assert_nil docs[1].toc.parent_id
    docs[2].reload
    assert_equal 1, docs[2].toc.depth
    assert_equal docs[0].toc.id, docs[2].toc.parent_id
    docs[3].reload
    assert_equal 2, docs[3].toc.depth
    assert_equal docs[2].toc.id, docs[3].toc.parent_id

    # check nested order
    repo_tocs = repo.tocs.nested_tree
    toc_struct = repo_tocs.map { |item| "  " * item.depth + item.title }.join("\n")
    expected_struct = <<~TOC
    First item
    title 1
      title 3
        title 4
    title 2
    Last item
    TOC

    assert_equal expected_struct.strip, toc_struct.strip

    # Restore will revert toc
    doc = Doc.unscoped.find_by_id(doc.id)

    doc.restore
    doc = Doc.find_by_id(doc.id)
    assert_not_nil doc
    assert_not_nil doc.toc

    toc1 = create(:toc, doc_id: nil)
    toc1.destroy
    assert_nil Toc.find_by_id(toc1.id)
  end
end

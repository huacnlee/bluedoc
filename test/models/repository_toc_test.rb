# frozen_string_literal: true

require "test_helper"

class RepositoryTocTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test "create_by_toc_text! with toc_text exist" do
    repo = create(:repository)
    old_updated_at = repo.updated_at
    docs = create_list(:doc, 6, repository: repo)

    toc_docs = [
      { id: docs[1].id, url: docs[1].slug, title: docs[1].title, depth: 0 }.as_json,
      { id: docs[0].id, url: docs[0].slug, title: docs[0].title, depth: 1 }.as_json,
      { id: docs[2].id, url: docs[2].slug, title: docs[2].title, depth: 2 }.as_json,
      { id: docs[2].id, url: docs[2].slug, title: docs[2].title, depth: 3 }.as_json,
      { id: docs[4].id, url: docs[4].slug, title: docs[4].title, depth: 0 }.as_json,
      { id: nil, url: "test", title: "Test url", depth: 1 }.as_json,
      { id: docs[3].id, url: docs[3].slug, title: docs[3].title, depth: 0 }.as_json,
      { id: docs[5].id, url: docs[5].slug, title: docs[5].title, depth: 1 }.as_json,
    ]

    RichText.create!(record: repo, name: "toc", body: toc_docs.to_yaml)

    # Do upgrade
    RepositoryToc.create_by_toc_text!(repo)

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
    RepositoryToc.where(repository: repo).delete_all

    # Do upgrade
    RepositoryToc.create_by_toc_text!(repo)

    assert_equal docs, repo.tocs.collect(&:doc)
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
end

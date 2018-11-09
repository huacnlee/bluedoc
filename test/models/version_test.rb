# frozen_string_literal: true

require "test_helper"

class VersionTest < ActiveSupport::TestCase
  test "base" do
    version = create(:version, body: "123123")
    assert_equal false, version.new_record?

    assert_equal "<p>123123</p>", version.body_html
  end

  test "Versionable with Doc" do
    doc = build(:doc, body: "This is new body")
    doc.save

    assert_equal false, doc.new_record?

    assert_equal 1, doc.versions.count
    version0 = doc.versions.first
    assert_equal "DocVersion", version0.type
    assert_equal "This is new body", version0.body_plain

    doc.update(title: "Foo bar")
    versions = doc.versions
    assert_equal 1, versions.count

    doc.update(body: "123456")
    assert_equal 2, doc.versions.count
    version1 = doc.versions.first
    assert_equal "123456", version1.body_plain

    # revert
    assert_equal false, doc.revert(-1)
    assert_equal ["Revert version is invalid"], doc.errors[:base]

    user = create(:user)
    assert_equal true, doc.revert(version0.id, user_id: user.id)
    doc.reload
    assert_equal version0.body_plain, doc.body_plain
    assert_equal user.id, doc.last_editor_id
    assert_equal 3, doc.versions.count
    assert_equal user.id, doc.versions.first.user_id
  end

  test "Versionable with Repository Toc" do
    repo = create(:repository)
    assert_equal 0, repo.toc_versions.count

    repo = build(:repository)
    toc = <<~TOC
    - title: Hello world
      url: hello
    TOC
    repo.toc = toc
    repo.save

    assert_equal false, repo.new_record?

    version = repo.toc_versions.first
    assert_equal "TocVersion", version.type
    assert_equal toc.strip, version.body_plain.strip

    repo.update(name: "Foo bar")
    assert_equal 1, repo.toc_versions.count

    new_toc = <<~TOC
    - title: World hello
      url: hello
    TOC
    repo.update(toc: new_toc)
    assert_equal 2, repo.toc_versions.count
    version = repo.toc_versions.first
    assert_equal new_toc.strip, version.body_plain.strip
  end
end

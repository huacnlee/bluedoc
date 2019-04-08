# frozen_string_literal: true

require "test_helper"

class VersionTest < ActiveSupport::TestCase
  test "base" do
    version = create(:version, body: "123123")
    assert_equal false, version.new_record?

    assert_equal "<p>123123</p>", version.body_html
  end

  test "Versionable with Doc" do
    doc = build(:doc, body: "This is new body", body_sml: "AAA this is new body", format: "sml")
    doc.save

    assert_equal false, doc.new_record?

    assert_equal 1, doc.versions.count
    version0 = doc.versions.first
    assert_equal "DocVersion", version0.type
    assert_equal "This is new body", version0.body_plain
    assert_equal "AAA this is new body", version0.body_sml_plain
    assert_equal "sml", version0.format

    doc.update(title: "Foo bar")
    versions = doc.versions
    assert_equal 1, versions.count

    doc.update(body: "123456", body_sml: "23456", format: "markdown")
    assert_equal 2, doc.versions.count
    version1 = doc.versions.first
    assert_equal "123456", version1.body_plain
    assert_equal "23456", version1.body_sml_plain
    assert_equal "markdown", version1.format

    # revert
    assert_equal false, doc.revert(-1)
    assert_equal ["Revert version is invalid"], doc.errors[:base]

    user = create(:user)
    assert_equal true, doc.revert(version0.id, user_id: user.id)
    doc.reload
    assert_equal version0.body_plain, doc.body_plain
    assert_equal version0.body_plain, doc.draft_body_plain
    assert_equal version0.body_sml_plain, doc.body_sml_plain
    assert_equal version0.body_sml_plain, doc.draft_body_sml_plain
    assert_equal version0.format, doc.format
    assert_equal user.id, doc.last_editor_id
    assert_equal 3, doc.versions.count
    assert_equal user.id, doc.versions.first.user_id
  end

  test "Versionable with Note" do
    note = build(:note, body: "This is new body", body_sml: "AAA this is new body", format: "sml")
    note.save

    assert_equal false, note.new_record?

    assert_equal 1, note.versions.count
    version0 = note.versions.first
    assert_equal "NoteVersion", version0.type
    assert_equal "This is new body", version0.body_plain
    assert_equal "AAA this is new body", version0.body_sml_plain
    assert_equal "sml", version0.format

    note.update(title: "Foo bar")
    versions = note.versions
    assert_equal 1, versions.count

    note.update(body: "123456", body_sml: "23456", format: "markdown")
    assert_equal 2, note.versions.count
    version1 = note.versions.first
    assert_equal "123456", version1.body_plain
    assert_equal "23456", version1.body_sml_plain
    assert_equal "markdown", version1.format

    # revert
    assert_equal false, note.revert(-1)
    assert_equal ["Revert version is invalid"], note.errors[:base]

    user = create(:user)
    assert_equal true, note.revert(version0.id, user_id: user.id)
    note.reload
    assert_equal version0.body_plain, note.body_plain
    assert_equal version0.body_sml_plain, note.body_sml_plain
    assert_equal version0.format, note.format
    assert_equal 3, note.versions.count
  end
end

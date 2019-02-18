require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  test "create_new" do
    user = create(:user)
    note = Note.create_new(user.id)
    assert_not_nil note.slug
    assert_match /[\w]+/, note.slug

    check_note = user.notes.find_by_slug(note.slug)
    assert_equal note, check_note

    # Create a exist slug, will auto regenrate a random slug
    assert_raise(ActiveRecord::RecordInvalid) do
      note1 = Note.create_new(user.id, slug: note.slug)
      assert_equal false, note1.new_record?
      assert_not_equal note.slug, note1.slug
      check_note = user.notes.find_by_slug(note1.slug)
      assert_equal note1, check_note
    end
  end

  test "Validation" do
    note = build(:note, title: "")
    assert_equal false, note.valid?
  end

  test "publish" do
    note = create(:note)
    assert_equal false, note.publishing?

    note.publishing!
    assert_equal true, note.publishing?
  end

  test "Body touch" do
    note = create(:note)
    assert_not_nil note[:body_updated_at]
    old_updated_at = note[:body_updated_at]

    # body no changes
    note.title = "New title"
    assert_equal false, note.body_touch?
    note.save
    assert_equal old_updated_at, note.body_updated_at

    # change body
    note.body = "Foo"
    assert_equal true, note.body_touch?
    note.save
    assert note.body_updated_at > old_updated_at

    # change body_sml
    old_updated_at = note.body_updated_at
    note.body_sml = "Bar"
    assert_equal true, note.body_touch?
    note.save
    assert note.body_updated_at > old_updated_at

    # When publishing
    assert_equal false, note.body_touch?
    note.publishing!
    assert_equal true, note.body_touch?
  end

  test "to_path" do
    note = create(:note)
    assert_equal "#{note.user.to_path}/notes/#{note.slug}", note.to_path
    assert_equal "#{note.user.to_path}/notes/#{note.slug}/versions", note.to_path("/versions")

    assert_equal "#{Setting.host}#{note.to_path}", note.to_url
  end

  test "prev_and_next_of_notes" do
    user = create(:user)
    create_list(:note, 5, user: user)
    notes = user.notes.recent.all

    # with first
    result = notes[0].prev_and_next_of_notes
    assert_nil result[:prev]
    assert_equal notes[1], result[:next]

    # with normal
    result = notes[2].prev_and_next_of_notes
    assert_equal notes[1], result[:prev]
    assert_equal notes[3], result[:next]

    # with last
    result = notes[4].prev_and_next_of_notes
    assert_equal notes[3], result[:prev]
    assert_nil result[:next]
  end

  test "Privacy" do
    note = build(:note, privacy: :private)
    assert_equal true, note.private?
    assert_equal false, note.public?

    note = build(:note, privacy: :public)
    assert_equal false, note.private?
    assert_equal true, note.public?
  end
end

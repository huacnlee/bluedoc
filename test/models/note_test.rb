# frozen_string_literal: true

require "test_helper"

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
    other_user = create(:user)
    private_note0 = create(:note, user: user, privacy: :private)
    create_list(:note, 5, user: user)
    private_note1 = create(:note, user: user, privacy: :private)

    notes = user.notes.recent.all
    public_notes = user.notes.publics.recent.all

    # with first for including private
    # Make sure all private when not with a user
    notes.each do |note|
      result = note.prev_and_next_of_notes
      if result[:prev]
        assert_equal false, result[:prev].private?
      end
      if result[:next]
        assert_equal false, result[:next].private?
      end

      result = note.prev_and_next_of_notes(with_user: other_user)
      if result[:prev]
        assert_equal false, result[:prev].private?
      end
      if result[:next]
        assert_equal false, result[:next].private?
      end
    end

    # with first
    result = notes[0].prev_and_next_of_notes(with_user: user)
    assert_nil result[:prev]
    assert_equal notes[1], result[:next]

    result = public_notes[0].prev_and_next_of_notes
    assert_nil result[:prev]
    assert_equal public_notes[1], result[:next]


    # with normal
    result = notes[2].prev_and_next_of_notes(with_user: user)
    assert_equal notes[1], result[:prev]
    assert_equal notes[3], result[:next]

    result = public_notes[2].prev_and_next_of_notes
    assert_equal public_notes[1], result[:prev]
    assert_equal public_notes[3], result[:next]

    # with last
    result = notes[notes.length - 1].prev_and_next_of_notes(with_user: user)
    assert_equal notes[notes.length - 2], result[:prev]
    assert_nil result[:next]

    result = public_notes[4].prev_and_next_of_notes
    assert_equal public_notes[3], result[:prev]
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

  test "private dependent :activites" do
    note = create(:note)
    create(:activity, target: note)
    create(:activity, target: note)
    assert_equal 2, Activity.where(target: note).count

    note.update(privacy: :public)
    assert_equal 2, Activity.where(target: note).count

    note.update(privacy: :private)
    assert_equal 0, Activity.where(target: note).count
  end

  test "_search_body" do
    user = create(:user)
    note = create(:note, user: user, body: "Hello world")

    expected = [user.fullname, note.to_path, note.body_plain].join("\n\n")
    assert_equal expected, note._search_body
  end

  test "as_indexed_json" do
    note = create(:note, body: "Hello world")

    note.stub(:_search_body, "Search body") do
      data = { slug: note.slug, title: note.title, body: "Hello world", search_body: "Search body", user_id: note.user_id, public: true, deleted: false }
      assert_equal data, note.as_indexed_json
    end

    note = create(:note, body: "Hello world", privacy: "private", deleted_at: Time.now)

    note.stub(:_search_body, "Search body") do
      data = { slug: note.slug, title: note.title, body: "Hello world", search_body: "Search body", user_id: note.user_id, public: false, deleted: true }
      assert_equal data, note.as_indexed_json
    end
  end

  test "indexed_changed?" do
    note = build(:note)
    assert_equal true, note.indexed_changed?

    note = create(:note)

    note = Note.find(note.id)
    assert_equal false, note.indexed_changed?
    note.updated_at = Time.now
    assert_equal false, note.indexed_changed?

    note.stub(:saved_change_to_title?, true) do
      assert_equal true, note.indexed_changed?
    end

    note.stub(:saved_change_to_deleted_at?, true) do
      assert_equal true, note.indexed_changed?
    end

    note.stub(:saved_change_to_privacy?, true) do
      assert_equal true, note.indexed_changed?
    end

    note.stub(:saved_change_to_user_id?, true) do
      assert_equal true, note.indexed_changed?
    end

    note = Note.find(note.id)
    note.body = "New Body"
    assert_equal true, note.indexed_changed?
  end

  test "watches" do
    note = create(:note)

    assert_equal true, note.user.watch_comment_note?(note)
  end
end

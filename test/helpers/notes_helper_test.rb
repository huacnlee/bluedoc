# frozen_string_literal: true

require "test_helper"

class NotesHelperTest < ActionView::TestCase
  test "note_title_tag" do
    note = create(:note)

    assert_equal %(<a class="note-link" title="#{note.title}" href="#{note.to_path}">#{note.title}</a>), note_title_tag(note)

    assert_equal %(), note_title_tag(nil)

    note.stub(:user, nil) do
      assert_equal %(), note_title_tag(note)
    end
  end
end

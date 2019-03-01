# frozen_string_literal: true

require "test_helper"

class ProLicenseTest < ActiveSupport::TestCase
  test "read_target" do
    user = create(:user)
    doc = create(:doc)
    note = create(:note)

    # Not enable, not raise, but do nothing
    assert_equal false, user.read_doc(doc)
    assert_equal false, user.read_doc?(doc)

    assert_equal false, user.read_note(note)
    assert_equal false, user.read_note?(note)

    allow_feature(:reader_list) do
      # read doc
      user.read_doc(doc)
      user.read_doc(doc)
      assert_equal true, user.read_doc?(doc)
      assert_equal [user.id], doc.read_by_user_ids

      # read note
      user.read_note(note)
      user.read_note(note)
      assert_equal true, user.read_note?(note)
      assert_equal [user.id], note.read_by_user_ids
    end
  end
end
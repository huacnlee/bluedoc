require 'test_helper'

class LabelTest < ActiveSupport::TestCase
  test "validates" do
    label = build(:label, title: "")
    assert_equal false, label.valid?
    assert_equal true, label.errors.include?(:title)

    label = build(:label, color: "")
    assert_equal false, label.valid?
    assert_equal true, label.errors.include?(:color)

    label = build(:label, color: "#666")
    assert_equal true, label.valid?

    label = build(:label, color: "#01UU12")
    assert_equal false, label.valid?
    assert_equal true, label.errors.include?(:color)

    label = build(:label, color: "#0291FF")
    assert_equal true, label.valid?
  end

  test "Repository create_default_issue_labels!" do
    repo = create(:repository)
    assert_nothing_raised do
      repo.create_default_issue_labels!
    end

    assert_equal Repository::DEFAULT_ISSUE_LABELS.keys.length, repo.issue_labels.count
    Repository::DEFAULT_ISSUE_LABELS.each do |name, color|
      label = repo.issue_labels.find_by(title: name.to_s.titleize)
      assert_not_nil label
      assert_equal color, label.color
      assert_equal true, BlueDoc::Utils.valid_color?(label.color)
    end
  end
end
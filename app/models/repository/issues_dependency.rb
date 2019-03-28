# frozen_string_literal: true

class Repository
  has_many :issues, dependent: :destroy
  has_many :issue_labels, as: :target, dependent: :destroy, class_name: "Label"

  def has_issues?
    return true if self.preferences[:has_issues].nil?
    ActiveModel::Type::Boolean.new.cast(self.preferences[:has_issues])
  end

  DEFAULT_ISSUE_LABELS = {
    discussion: "#afb9ff",
    question: "#ff6c4b",
    support: "#31e06f",
    invalid: "#f9ea37",
    duplicate: "#dec07c",
    wontfix: "#e6a9ff"
  }

  def ensure_default_issue_labels
    return false if self.issue_labels.any?
    create_default_issue_labels!
  end

  def create_default_issue_labels!
    Label.transaction do
      DEFAULT_ISSUE_LABELS.each_key do |name|
        Label.create!(target: self, title: name.to_s.titleize, color: DEFAULT_ISSUE_LABELS[name])
      end
    end
  end
end

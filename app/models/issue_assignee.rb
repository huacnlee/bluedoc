# frozen_string_literal: true

class IssueAssignee < ApplicationRecord
  belongs_to :user
  belongs_to :issue
end
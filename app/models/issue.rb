# frozen_string_literal: true

class Issue < ApplicationRecord
  second_level_cache expires_in: 1.week

  include Smlable
  include Sequenceable
  include Reactionable

  has_sequence :repository, scope: :issue

  depends_on :assignees, :labels, :participants, :watches

  belongs_to :user
  belongs_to :repository
  belongs_to :last_editor, class_name: "User", required: false

  has_many :comments, as: :commentable, dependent: :destroy

  validates :repository, presence: true
  validates :title, presence: true, length: { maximum: 255 }

  enum status: %i(open closed)

  scope :recent, -> { order("iid desc") }

  def to_path(suffix = nil)
    "#{repository.to_path}/issues/#{self.iid}#{suffix}"
  end

  def to_url(anchor: nil)
    url = [Setting.host, self.to_path].join("")
    url += "##{anchor}" if anchor
    url
  end

  def issue_title
    [self.title, "##{self.iid}"].join(" ")
  end

  def self.find_by_iid(iid)
    where("iid = ?", iid).take
  end

  def self.find_by_iid!(iid)
    find_by_iid(iid) || raise(ActiveRecord::RecordNotFound)
  end
end

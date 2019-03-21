class Issue < ApplicationRecord
  include Smlable
  include Sequenceable

  has_sequence :repository, scope: :issue

  belongs_to :user
  belongs_to :repository
  belongs_to :last_editor, class_name: "User", required: false

  has_many :issue_assignees
  has_many :assignees, class_name: "User", through: :issue_assignees
  has_many :comments, as: :commentable, dependent: :destroy

  validates :repository, presence: true
  validates :title, presence: true, length: { maximum: 255 }

  enum status: %i(open closed)

  def to_path(suffix = nil)
    "#{repository.to_path}/issues/#{self.iid}#{suffix}"
  end

  def self.find_by_iid(iid)
    where("iid = ?", iid).take
  end

  def self.find_by_iid!(iid)
    find_by_iid(iid) || raise(ActiveRecord::RecordNotFound)
  end
end

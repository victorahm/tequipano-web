class Task < ApplicationRecord
  belongs_to :list
  belongs_to :user

  has_many :task_tags, dependent: :destroy
  has_many :tags, through: :task_tags
  has_many :comments, dependent: :destroy

  enum :status, { todo: 'todo', doing: 'doing', done: 'done', paused: 'paused', blocked: 'blocked' }

  validates :title, presence: true
  validates :status, presence: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :completed, -> { where(status: :done) }
  scope :active, -> { where.not(status: :done) }
end

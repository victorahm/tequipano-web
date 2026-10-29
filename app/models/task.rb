class Task < ApplicationRecord
  # Allowed transitions per the state machine documented in the README:
  #
  #   todo → doing → done
  #   todo → done (direct completion)
  #   doing → paused → doing
  #   doing → blocked → doing
  #   done → todo (reopened)
  STATUS_TRANSITIONS = {
    "todo" => %w[ doing done ],
    "doing" => %w[ done paused blocked ],
    "paused" => %w[ doing ],
    "blocked" => %w[ doing ],
    "done" => %w[ todo ]
  }.freeze

  belongs_to :list
  belongs_to :user

  has_many :task_tags, dependent: :destroy
  has_many :tags, through: :task_tags
  has_many :comments, dependent: :destroy

  enum :status, { todo: "todo", doing: "doing", done: "done", paused: "paused", blocked: "blocked" }

  validates :title, presence: true
  validates :status, presence: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :status_transition_must_be_allowed, if: :will_save_change_to_status?

  before_save :sync_completed_at

  scope :completed, -> { where(status: :done) }
  scope :active, -> { where.not(status: :done) }
  scope :ordered, -> { order(:position, :id) }

  def allowed_next_statuses
    return self.class.statuses.keys if new_record?

    ([ status ] + STATUS_TRANSITIONS.fetch(status.to_s, [])).uniq
  end

  private

  def status_transition_must_be_allowed
    return if new_record?

    from = status_was.to_s
    to = status.to_s
    return if STATUS_TRANSITIONS.fetch(from, []).include?(to)

    errors.add(:status, "can't change from #{from} to #{to}")
  end

  def sync_completed_at
    return unless will_save_change_to_status?

    self.completed_at = Time.current if done?
    self.completed_at = nil unless done?
  end
end

class List < ApplicationRecord
  DEFAULT_COLOR = "#2f6df6"

  belongs_to :user
  has_many :tasks, dependent: :destroy

  validates :name, presence: true
  validates :color, presence: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end

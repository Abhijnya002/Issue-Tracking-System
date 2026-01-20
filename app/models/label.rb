class Label < ApplicationRecord
  belongs_to :project
  has_many :issue_labels, dependent: :delete_all
  has_many :issues, through: :issue_labels

  # Tailwind classes (fixed set so CSS is always generated)
  COLOR_BADGE_CLASSES = {
    "blue" => "bg-blue-600 text-white",
    "green" => "bg-emerald-600 text-white",
    "purple" => "bg-violet-600 text-white",
    "yellow" => "bg-amber-500 text-white",
    "red" => "bg-red-600 text-white",
    "pink" => "bg-pink-600 text-white",
    "orange" => "bg-orange-500 text-white",
    "teal" => "bg-teal-600 text-white",
    "indigo" => "bg-indigo-600 text-white",
    "slate" => "bg-slate-600 text-white"
  }.freeze

  COLOR_OPTIONS = COLOR_BADGE_CLASSES.keys.freeze

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false, scope: :project_id }
  validates :color, inclusion: { in: COLOR_OPTIONS }

  before_validation :normalize_name

  def badge_classes
    COLOR_BADGE_CLASSES[color] || COLOR_BADGE_CLASSES["slate"]
  end

  private

  def normalize_name
    self.name = name.to_s.strip
  end
end

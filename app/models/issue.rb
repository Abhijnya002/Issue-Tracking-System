class Issue < ApplicationRecord
  belongs_to :project
  belongs_to :assignee, class_name: "User", optional: true
  belongs_to :reporter, class_name: "User"
  has_many :comments, dependent: :destroy
  has_many :issue_labels, dependent: :destroy
  has_many :labels, through: :issue_labels

  ISSUE_TYPES = %w[bug task story epic].freeze
  STATUSES = %w[backlog todo in_progress done cancelled].freeze
  # Shown on the active board (Jira-style); backlog is a separate section above.
  BOARD_STATUSES = %w[todo in_progress done cancelled].freeze
  PRIORITIES = %w[lowest low medium high highest].freeze

  validates :title, presence: true
  validates :identifier, presence: true, uniqueness: { scope: :project_id }
  validates :issue_type, inclusion: { in: ISSUE_TYPES }
  validates :status, inclusion: { in: STATUSES }
  validates :priority, inclusion: { in: PRIORITIES }

  validate :assignee_must_be_member
  validate :labels_must_match_project

  scope :ordered, -> { order(position: :asc, id: :asc) }
  scope :for_project, ->(project) { where(project: project) }

  def key
    "#{project.key}-#{identifier}"
  end

  def self.next_identifier(project)
    project.with_lock do
      next_id = (project.issue_sequence || 0) + 1
      project.update!(issue_sequence: next_id)
      next_id
    end
  end

  private

  def assignee_must_be_member
    return if assignee_id.blank?
    return if project&.members&.exists?(id: assignee_id)

    errors.add(:assignee_id, "must be a project member")
  end

  def labels_must_match_project
    return if labels.empty?

    labels.each do |l|
      next if l.project_id == project_id

      errors.add(:labels, "must belong to this project")
      break
    end
  end
end

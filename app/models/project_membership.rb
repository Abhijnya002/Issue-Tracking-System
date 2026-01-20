class ProjectMembership < ApplicationRecord
  belongs_to :user
  belongs_to :project

  ROLES = %w[admin member viewer].freeze

  validates :role, inclusion: { in: ROLES }
end

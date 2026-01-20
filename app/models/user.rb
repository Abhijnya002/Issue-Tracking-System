class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :owned_projects, class_name: "Project", foreign_key: :owner_id, inverse_of: :owner, dependent: :destroy
  has_many :project_memberships, dependent: :destroy
  has_many :projects, through: :project_memberships
  has_many :reported_issues, class_name: "Issue", foreign_key: :reporter_id, inverse_of: :reporter, dependent: :restrict_with_exception
  has_many :assigned_issues, class_name: "Issue", foreign_key: :assignee_id, inverse_of: :assignee, dependent: :nullify
  has_many :comments, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def display_name
    email_address
  end

  def member_of?(project)
    project_memberships.exists?(project_id: project.id)
  end

  def admin_on?(project)
    project_memberships.exists?(project_id: project.id, role: "admin")
  end
end

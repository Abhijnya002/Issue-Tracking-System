class Project < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :project_memberships, dependent: :destroy
  has_many :members, through: :project_memberships, source: :user
  has_many :issues, dependent: :destroy
  has_many :labels, dependent: :destroy

  validates :name, presence: true
  validates :key, presence: true, uniqueness: { case_sensitive: false }

  before_validation :normalize_key
  before_validation :assign_default_key, on: :create
  after_create :add_owner_as_admin

  def self.generate_key_from_name(name)
    base = name.to_s.gsub(/[^A-Za-z0-9]+/, "").upcase
    base = "PRJ" if base.blank?
    base[0, 10]
  end

  private

  def normalize_key
    self.key = key.to_s.strip.upcase if key.present?
  end

  def assign_default_key
    return if key.present?

    self.key = self.class.generate_key_from_name(name)
  end

  def add_owner_as_admin
    project_memberships.create!(user: owner, role: "admin")
  end
end

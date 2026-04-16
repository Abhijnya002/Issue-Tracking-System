class Projects::MembershipsController < ApplicationController
  include ProjectScoped

  before_action :require_project_admin!
  before_action :set_membership, only: :destroy

  def index
    @memberships = @project.project_memberships.includes(:user).order(:role, :id)
  end

  def create
    raw = params.require(:membership)
    email = raw[:email_address].to_s.strip.downcase
    role = raw[:role].to_s.presence_in(ProjectMembership::ROLES) || "member"

    if email.blank?
      redirect_to project_memberships_path(@project), alert: "Enter an email address."
      return
    end

    user = User.find_by(email_address: email)
    unless user
      redirect_to project_memberships_path(@project), alert: "No account found for that email. Ask them to sign up first, then add them here."
      return
    end

    if @project.members.exists?(id: user.id)
      redirect_to project_memberships_path(@project), alert: "That person is already on this project."
      return
    end

    @project.project_memberships.create!(user: user, role: role)
    redirect_to project_memberships_path(@project), notice: "#{user.email_address} can now access this project."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to project_memberships_path(@project), alert: e.record.errors.full_messages.to_sentence
  end

  def destroy
    if @membership.user_id == @project.owner_id
      redirect_to project_memberships_path(@project), alert: "You can't remove the project owner from the team."
      return
    end

    email = @membership.user.email_address
    @membership.destroy!
    redirect_to project_memberships_path(@project), notice: "Removed #{email} from the project."
  end

  private

  def set_membership
    @membership = @project.project_memberships.find(params[:id])
  end

  def require_project_admin!
    return if current_user.admin_on?(@project)

    redirect_to @project, alert: "You need admin access to manage the team."
  end
end

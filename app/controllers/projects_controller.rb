class ProjectsController < ApplicationController
  before_action :set_project, only: %i[show edit update destroy]
  before_action :require_admin!, only: %i[edit update destroy]

  def index
    redirect_to root_path
  end

  def show
    issues = @project.issues.includes(:assignee, :reporter, :labels).order(:position, :id)
    @issues_by_status = issues.group_by(&:status)
    @backlog_issues = @issues_by_status["backlog"] || []
    @board_by_status = Issue::BOARD_STATUSES.index_with { |s| @issues_by_status[s] || [] }
    @board_role = @project.project_memberships.find_by(user: current_user)&.role
    @can_edit_board = @board_role.in?(%w[admin member])
    @board_filter_labels = @project.labels.order(:name)
  end

  def new
    @project = Project.new
  end

  def create
    @project = current_user.owned_projects.build(project_params)
    if @project.save
      redirect_to @project, notice: "Project created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: "Project updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to root_path, notice: "Project deleted.", status: :see_other
  end

  private

  def set_project
    @project = current_user.projects.find(params[:id])
  end

  def require_admin!
    return if current_user.admin_on?(@project)

    redirect_to @project, alert: "You need admin access to do that."
  end

  def project_params
    params.require(:project).permit(:name, :key, :description)
  end
end

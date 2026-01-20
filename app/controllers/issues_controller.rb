class IssuesController < ApplicationController
  include ProjectScoped

  before_action :set_issue, only: %i[show edit update destroy fragment]
  before_action :require_editor!, only: %i[new create edit update destroy reorder]
  before_action :load_assignees_and_labels, only: %i[new create edit update]

  def show
    @comments = @issue.comments.includes(:user).order(created_at: :desc)
  end

  def new
    @issue = @project.issues.build(status: params[:status].presence_in(Issue::STATUSES) || "backlog")
    @return_to_path = request.fullpath
  end

  def create
    @issue = @project.issues.build(issue_params)
    @issue.reporter = current_user
    @issue.identifier = Issue.next_identifier(@project)
    @issue.position = next_position(@project, @issue.status)

    if @issue.save
      redirect_to project_issue_path(@project, @issue), notice: "Issue created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @return_to_path = request.fullpath
  end

  def update
    if @issue.update(issue_params)
      redirect_to project_issue_path(@project, @issue), notice: "Issue updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @issue.destroy
    redirect_to project_path(@project), notice: "Issue deleted.", status: :see_other
  end

  # HTML for one issue in board card vs backlog row layout (used after drag-and-drop swaps lists).
  def fragment
    role = @project.project_memberships.find_by(user: current_user)&.role
    can_edit_board = role.in?(%w[admin member])
    placement = params[:placement].presence_in(%w[board backlog]) || "board"
    partial = placement == "backlog" ? "issue_row" : "issue_card"
    render partial: "projects/#{partial}", layout: false,
           locals: { project: @project, issue: @issue, role:, can_edit_board: }
  end

  def reorder
    columns = parse_reorder_columns
    ordered_ids = columns.values.flatten
    if ordered_ids.uniq.size != ordered_ids.size
      return render json: { error: "Duplicate issue in board state" }, status: :unprocessable_entity
    end

    if ordered_ids.sort != @project.issue_ids.sort
      return render json: { error: "Board must include every project issue exactly once" }, status: :unprocessable_entity
    end

    Issue.transaction do
      columns.each do |status, ids|
        ids.each_with_index do |id, index|
          @project.issues.find(id).update_columns(status: status, position: index, updated_at: Time.current)
        end
      end
    end

    head :no_content
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Issue not found" }, status: :unprocessable_entity
  end

  private

  def set_issue
    @issue = @project.issues.includes(:labels, comments: :user).find(params[:id])
  end

  def require_editor!
    role = @project.project_memberships.find_by(user: current_user)&.role
    return if role.in?(%w[admin member])

    redirect_to project_path(@project), alert: "You do not have permission to change issues."
  end

  def issue_params
    permitted = params.require(:issue).permit(:title, :description, :issue_type, :status, :priority, :assignee_id, :position, label_ids: [])
    permitted[:label_ids] = Array(permitted[:label_ids]).compact_blank.map(&:to_i) if permitted.key?(:label_ids)
    permitted
  end

  def parse_reorder_columns
    raw = params.require(:columns)

    Issue::STATUSES.index_with do |st|
      Array(raw[st] || raw[st.to_s]).map(&:to_i)
    end
  end

  def next_position(project, status)
    (project.issues.where(status: status).maximum(:position) || 0) + 1
  end

  def load_assignees_and_labels
    @assignees = @project.members.order(:email_address)
    @project_labels = @project.labels.order(:name)
  end
end

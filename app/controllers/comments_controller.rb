class CommentsController < ApplicationController
  include ProjectScoped

  before_action :set_issue
  before_action :require_comment_access!

  def create
    @comment = @issue.comments.build(comment_params.merge(user: current_user))
    if @comment.save
      redirect_to project_issue_path(@project, @issue), notice: "Comment added."
    else
      redirect_to project_issue_path(@project, @issue), alert: @comment.errors.full_messages.to_sentence
    end
  end

  def destroy
    @comment = @issue.comments.find(params[:id])
    if @comment.user_id == current_user.id || current_user.admin_on?(@project)
      @comment.destroy
      redirect_to project_issue_path(@project, @issue), notice: "Comment removed.", status: :see_other
    else
      redirect_to project_issue_path(@project, @issue), alert: "You cannot remove this comment."
    end
  end

  private

  def set_issue
    @issue = @project.issues.find(params[:issue_id])
  end

  def require_comment_access!
    role = @project.project_memberships.find_by(user: current_user)&.role
    return if role.in?(%w[admin member])

    redirect_to project_path(@project), alert: "You do not have permission to comment."
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end

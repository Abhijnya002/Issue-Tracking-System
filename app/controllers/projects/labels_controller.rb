module Projects
  class LabelsController < ApplicationController
    before_action :set_project
    before_action :set_label, only: %i[edit update destroy]
    before_action :require_editor!

    def index
      @labels = @project.labels.order(:name)
    end

    def new
      @label = @project.labels.build(color: "blue")
      @return_to = params[:return_to]
    end

    def create
      @label = @project.labels.build(label_params)
      if @label.save
        redirect_to safe_return_path || project_labels_path(@project), notice: "Label created."
      else
        @return_to = params[:return_to]
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @label.update(label_params)
        redirect_to project_labels_path(@project), notice: "Label updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @label.destroy
      redirect_to project_labels_path(@project), notice: "Label removed.", status: :see_other
    end

    private

    def set_project
      @project = current_user.projects.find(params[:project_id])
    end

    def set_label
      @label = @project.labels.find(params[:id])
    end

    def require_editor!
      role = @project.project_memberships.find_by(user: current_user)&.role
      return if role.in?(%w[admin member])

      redirect_to project_path(@project), alert: "You do not have permission to manage labels."
    end

    def label_params
      params.require(:label).permit(:name, :color)
    end

    def safe_return_path
      path = params[:return_to].to_s
      return unless path.start_with?("/") && !path.start_with?("//")

      path
    end
  end
end

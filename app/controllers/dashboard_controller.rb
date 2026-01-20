class DashboardController < ApplicationController
  def index
    @projects = current_user.projects.includes(:owner).order(:name)
  end
end

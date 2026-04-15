module Projects
  class ReportsController < ApplicationController
    include ProjectScoped

    def show
      @status_rows = IssueReporting.status_breakdown(@project.id)
      @priority_rows = IssueReporting.priority_breakdown(@project.id)
      @weekly_rows = IssueReporting.created_by_week(@project.id)
      @assignee_rows = IssueReporting.assignee_workload(@project.id)
    end
  end
end

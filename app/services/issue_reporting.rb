# Reporting queries written as explicit SQL for aggregations and time bucketing.
class IssueReporting
  class << self
    def status_breakdown(project_id)
      sql = Issue.sanitize_sql_array([
        <<~SQL.squish,
          SELECT status, COUNT(*)::bigint AS count
          FROM issues
          WHERE project_id = ?
          GROUP BY status
          ORDER BY status
        SQL
        project_id
      ])
      ActiveRecord::Base.connection.exec_query(sql, "IssueReporting#status_breakdown")
    end

    def priority_breakdown(project_id)
      sql = Issue.sanitize_sql_array([
        <<~SQL.squish,
          SELECT priority, COUNT(*)::bigint AS count
          FROM issues
          WHERE project_id = ?
            AND status <> 'done'
            AND status <> 'cancelled'
          GROUP BY priority
          ORDER BY priority
        SQL
        project_id
      ])
      ActiveRecord::Base.connection.exec_query(sql, "IssueReporting#priority_breakdown")
    end

    def created_by_week(project_id, weeks: 12)
      sql = Issue.sanitize_sql_array([
        <<~SQL.squish,
          SELECT date_trunc('week', created_at AT TIME ZONE 'UTC') AS week,
                 COUNT(*)::bigint AS count
          FROM issues
          WHERE project_id = ?
            AND created_at >= (NOW() AT TIME ZONE 'UTC') - (?::int * INTERVAL '1 week')
          GROUP BY 1
          ORDER BY 1
        SQL
        project_id,
        weeks
      ])
      ActiveRecord::Base.connection.exec_query(sql, "IssueReporting#created_by_week")
    end

    def assignee_workload(project_id)
      sql = Issue.sanitize_sql_array([
        <<~SQL.squish,
          SELECT u.email_address,
                 COUNT(i.id) FILTER (WHERE i.status NOT IN ('done', 'cancelled'))::bigint AS open_issues,
                 COUNT(i.id) FILTER (WHERE i.status IN ('done', 'cancelled'))::bigint AS closed_issues
          FROM users u
          LEFT JOIN issues i ON i.assignee_id = u.id AND i.project_id = ?
          WHERE u.id IN (
            SELECT user_id FROM project_memberships WHERE project_id = ?
          )
          GROUP BY u.id, u.email_address
          ORDER BY open_issues DESC, u.email_address ASC
        SQL
        project_id,
        project_id
      ])
      ActiveRecord::Base.connection.exec_query(sql, "IssueReporting#assignee_workload")
    end
  end
end

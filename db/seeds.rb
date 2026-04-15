# Demo data for local development. Idempotent where practical.

demo = User.find_or_initialize_by(email_address: "demo@example.com")
if demo.new_record?
  demo.password = "password"
  demo.password_confirmation = "password"
  demo.save!
end

project = Project.find_or_initialize_by(key: "DEMO")
if project.new_record?
  project.owner = demo
  project.name = "Demo project"
  project.description = "Sample backlog, issues, and reporting data."
  project.save!
end

alice = User.find_or_initialize_by(email_address: "alice@example.com")
if alice.new_record?
  alice.password = "password"
  alice.password_confirmation = "password"
  alice.save!
end

ProjectMembership.find_or_create_by!(user: alice, project: project) do |m|
  m.role = "member"
end

[
  ["Billing", "blue"],
  ["Accounts", "green"],
  ["Forms", "purple"],
  ["Feedback", "yellow"]
].each do |name, color|
  Label.find_or_create_by!(project: project, name: name) do |l|
    l.color = color
  end
end

if project.issues.none?
  i1 = project.issues.create!(
    title: "Set up PostgreSQL locally",
    description: "Install Postgres and create development databases.",
    issue_type: "task",
    status: "done",
    priority: "high",
    reporter: demo,
    assignee: demo,
    identifier: Issue.next_identifier(project),
    position: 1
  )
  i1.update_column(:created_at, 3.weeks.ago)

  filters = project.issues.create!(
    title: "Add board filters",
    description: "Filter issues by assignee and label.",
    issue_type: "story",
    status: "in_progress",
    priority: "medium",
    reporter: demo,
    assignee: alice,
    identifier: Issue.next_identifier(project),
    position: 1
  )
  filters.labels << project.labels.find_by!(name: "Forms")

  slow = project.issues.create!(
    title: "Investigate slow report query",
    description: "Reporting page takes >2s on large projects.",
    issue_type: "bug",
    status: "todo",
    priority: "highest",
    reporter: alice,
    assignee: demo,
    identifier: Issue.next_identifier(project),
    position: 1
  )
  slow.labels << project.labels.find_by!(name: "Billing")
  slow.labels << project.labels.find_by!(name: "Feedback")

  project.issues.create!(
    title: "Write onboarding copy",
    issue_type: "task",
    status: "backlog",
    priority: "low",
    reporter: demo,
    identifier: Issue.next_identifier(project),
    position: 1
  )
end

puts "Seeded demo@example.com / password and sample project #{project.key}."

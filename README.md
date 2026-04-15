# Issue Tracking System

A small Jira-style app I built to track work by project. You get a board, a backlog, issues with tags, and simple reports. Nothing fancy on purpose. I wanted it easy to read and change.

## What you can do

- Sign up, sign in, reset password if you forget it.
- Make projects with a short key (like `PROJ`) so issues read `PROJ-1`, `PROJ-2`, and so on.
- Move issues on a board with drag and drop. Backlog sits under the board.
- Add coloured tags per project, filter the board by tag, and tag issues when you create or edit them.
- Leave comments on an issue and open a report page with a few SQL-backed summaries.
- Share a project with teammates: project **admins** use **Team** on the project (or **Manage team** on project settings) to add people **by email**. They need an account first — sign up, then get added. Everyone on the team sees the project on their dashboard and shows up in the **assignee** list. Roles are **admin** (settings + team), **member** (edit issues and board), or **viewer** (read-only).

## What it’s built with

- **Ruby on Rails** (8.x)
- **PostgreSQL** for the database
- **Tailwind CSS** for layout and colours
- **Alpine.js** for small UI bits (menus and similar)
- **Hotwire** (Turbo + Stimulus) for how pages load and feel
- **SortableJS** for dragging cards between columns

## Before you start

You’ll need:

- Ruby (3.3.x works fine here — see `.ruby-version` or `mise.toml` if you use mise)
- PostgreSQL running on your machine
- `bundler` for gems

On a Mac, if `bundle install` complains about the **psych** gem, install libyaml first (`brew install libyaml`), then:

```bash
bundle config set build.psych "--with-libyaml-dir=$(brew --prefix libyaml)"
bundle install
```

## Setup

```bash
cd "Issue Tracking System"
bundle install
bin/rails db:prepare
bin/rails db:seed
```

The seed file adds a demo user: **demo@example.com** / **password**, plus a sample project and issues so you can click around.

## Run it

```bash
bin/dev
```

Sometimes `bin/dev` stops if the CSS watcher exits. If that happens, run the server alone:

```bash
bin/rails server
```

Then open **http://localhost:3000** in your browser.

For CSS while you edit Tailwind files:

```bash
bin/rails tailwindcss:watch
```

(run that in a second terminal)

## Tests

```bash
bin/rails test
```

## Notes

- Reporting uses plain SQL in a small service class — handy if you want to tweak charts or add filters later.
- Tags are per project, so names can repeat across projects but not inside the same one.
- Your dashboard lists only projects you **belong** to. Creating a project adds you automatically; joining someone else’s project only happens when a project admin adds you on the **Team** page.

If something breaks, check Postgres is up and your `config/database.yml` matches how you log in locally. Happy building.

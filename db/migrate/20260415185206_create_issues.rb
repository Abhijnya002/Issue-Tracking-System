class CreateIssues < ActiveRecord::Migration[8.1]
  def change
    create_table :issues do |t|
      t.references :project, null: false, foreign_key: true
      t.integer :identifier, null: false
      t.string :title, null: false
      t.text :description
      t.string :issue_type, null: false, default: "task"
      t.string :status, null: false, default: "backlog"
      t.string :priority, null: false, default: "medium"
      t.references :assignee, foreign_key: { to_table: :users }
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.integer :position, null: false, default: 0

      t.timestamps
    end
    add_index :issues, [ :project_id, :identifier ], unique: true
    add_index :issues, [ :project_id, :status ]
    add_index :issues, [ :project_id, :position ]
  end
end

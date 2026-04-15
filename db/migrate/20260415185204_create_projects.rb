class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.string :name
      t.string :key
      t.text :description
      t.integer :issue_sequence, null: false, default: 0

      t.timestamps
    end
    add_index :projects, :key, unique: true
  end
end

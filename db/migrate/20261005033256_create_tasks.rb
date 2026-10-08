class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :list, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.string :status
      t.integer :position
      t.datetime :due_date
      t.datetime :completed_at

      t.timestamps
    end
  end
end

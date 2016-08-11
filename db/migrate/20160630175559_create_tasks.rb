class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :workerID
      t.string :condition
      t.integer :tasktype
      t.integer :taskstage
      t.integer :timelimit
      t.datetime :started_at
      t.datetime :finished_at
      t.string :state
      t.text :text
      t.integer :keystrokes

      t.timestamps null: false
    end
  end
end

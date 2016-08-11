class AddStagelimitToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :stagelimit, :string
  end
end

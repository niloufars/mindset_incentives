class AddStagelimitToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :stagelimit, :integer
  end
end

class AddAccuracyToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :accuracy, :integer
  end
end

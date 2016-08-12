class AddBonusToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :bonus, :integer
  end
end

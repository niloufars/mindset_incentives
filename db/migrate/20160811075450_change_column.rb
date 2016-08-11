class ChangeColumn < ActiveRecord::Migration
  def change
  	 change_column(:tasks, :stagelimit, :integer)
  end
end

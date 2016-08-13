class CreateMycounters < ActiveRecord::Migration
  def change
    create_table :mycounters do |t|
      t.string :condition
      t.integer :count

      t.timestamps null: false
    end
  end
end

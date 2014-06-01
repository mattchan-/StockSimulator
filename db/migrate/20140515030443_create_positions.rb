class CreatePositions < ActiveRecord::Migration
  def change
    create_table :positions do |t|
      t.integer :portfolio_id
      t.string :symbol
      t.integer :shares
      t.float :cost_per_share

      t.timestamps
    end
    add_index :positions, :portfolio_id
  end
end

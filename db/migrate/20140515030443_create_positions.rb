class CreatePositions < ActiveRecord::Migration
  def change
    create_table :positions do |t|
      t.integer :portfolio_id
      t.string :ticker
      t.integer :quantity
      t.float :cost_basis

      t.timestamps
    end
    add_index :positions, :portfolio_id
  end
end

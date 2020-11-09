class CreateGamesTable < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.integer :user_id
      t.integer :spi_id
      t.date :date
      t.float :user_balance
      t.timestamps
    end
  end
end

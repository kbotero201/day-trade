class CreateSpisTable < ActiveRecord::Migration[6.0]
  def change
      create_table :spis do |t|
        t.string :stock_symbool 
        t.timestamps
      end
  end                                                                           
end

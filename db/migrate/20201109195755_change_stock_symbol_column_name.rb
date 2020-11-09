class ChangeStockSymbolColumnName < ActiveRecord::Migration[6.0]
  def change
    change_table :spis do |t|
      t.rename :stock_symbool, :stock_symbol 
    end
  end
end

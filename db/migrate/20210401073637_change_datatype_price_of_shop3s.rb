class ChangeDatatypePriceOfShop3s < ActiveRecord::Migration[6.1]
  def change
    change_column :shop3s, :price, 'integer USING CAST(price AS integer)'
  end
end

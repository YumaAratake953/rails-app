class ChangeDatatypePriceOfShop2s < ActiveRecord::Migration[6.1]
  def change
    change_column :shop2s, :price, 'integer USING CAST(price AS integer)'
  end
end

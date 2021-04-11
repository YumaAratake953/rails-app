class ChangeDatatypePriceOfShops < ActiveRecord::Migration[6.1]
  def change
    change_column :shops, :price, 'integer USING CAST(price AS integer)'
  end
end

class AddComToShop4s < ActiveRecord::Migration[6.1]
  def change
    add_column :shop4s, :com, :text
  end
end

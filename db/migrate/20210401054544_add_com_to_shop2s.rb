class AddComToShop2s < ActiveRecord::Migration[6.1]
  def change
    add_column :shop2s, :com, :text
  end
end

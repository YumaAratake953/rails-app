class AddComToShop3s < ActiveRecord::Migration[6.1]
  def change
    add_column :shop3s, :com, :text
  end
end

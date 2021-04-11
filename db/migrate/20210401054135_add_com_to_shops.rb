class AddComToShops < ActiveRecord::Migration[6.1]
  def change
    add_column :shops, :com, :text
  end
end

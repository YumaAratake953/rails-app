class CreateShop4s < ActiveRecord::Migration[6.1]
  def change
    create_table :shop4s do |t|
      t.text :name
      t.string :price
      t.text :url
      t.text :img
      
      t.timestamps
    end
  end
end

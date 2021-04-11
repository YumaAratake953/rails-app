class CreateShops < ActiveRecord::Migration[6.1]
  def change
    create_table :shops do |t|
      t.text :name
      t.string :price
      t.text :url
      t.text :img
      

      t.timestamps
    end
  end
end

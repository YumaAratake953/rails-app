class CreateShop3s < ActiveRecord::Migration[6.1]
  def change
    create_table :shop3s do |t|
      t.text :name
      t.string :price
      t.text :url
      t.text :img

      t.timestamps
    end
  end
end

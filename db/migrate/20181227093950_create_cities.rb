class CreateCities < ActiveRecord::Migration[5.2]
  def change
    create_table :cities do |t|
      t.string :city_name

      t.string :address
      t.string :details
      t.datetime :date
      t.integer :price

      t.timestamps
    end
  end
end

class AddCityToStates < ActiveRecord::Migration[5.2]
  def change
    add_column :states, :city, :string
  end
end

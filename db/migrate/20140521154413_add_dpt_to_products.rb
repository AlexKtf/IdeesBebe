class AddDptToProducts < ActiveRecord::Migration
  def change
    add_column :products, :dpt, :integer
  end
end

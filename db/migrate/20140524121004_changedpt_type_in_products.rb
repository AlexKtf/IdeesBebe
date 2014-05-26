class ChangedptTypeInProducts < ActiveRecord::Migration
  def change
  	change_column :products, :dpt, :string
  end
end

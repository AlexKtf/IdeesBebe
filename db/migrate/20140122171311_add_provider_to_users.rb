class AddProviderToUsers < ActiveRecord::Migration
  def change
    add_column :users, :provider, :string
    add_column :users, :fb_id, :string
    add_column :users, :fb_tk, :string
  end
end

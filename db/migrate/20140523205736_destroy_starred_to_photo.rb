class DestroyStarredToPhoto < ActiveRecord::Migration
  def change
    remove_column :photos, :starred, :boolean
  end
end

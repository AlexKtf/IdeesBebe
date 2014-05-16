class DestroyComment < ActiveRecord::Migration
    def up
    drop_table :comments
  end

  def down
    create_table :comments do |t|
      t.text :content
      t.references :product
      t.references :user

      t.timestamps
    end
  end
end

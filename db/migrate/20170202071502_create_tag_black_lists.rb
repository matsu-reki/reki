class CreateTagBlackLists < ActiveRecord::Migration[5.0]
  def change
    create_table :tag_black_lists do |t|
      t.string :name, limit: 100
      t.boolean :enabled, default: true

      t.timestamps
    end
  end
end

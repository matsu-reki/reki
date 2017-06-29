class CreateCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :categories do |t|
      t.integer :code
      t.string :name, limit: 30
      t.boolean :enabled, default: true

      t.timestamps
    end
  end
end

class CreateLicenses < ActiveRecord::Migration[5.0]
  def change
    create_table :licenses, id: :uuid do |t|
      t.integer :code
      t.string :name
      t.integer :content_type, default: 0
      t.text :content
      t.boolean :enabled, default: true

      t.timestamps
    end
  end
end

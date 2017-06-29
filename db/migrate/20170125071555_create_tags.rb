class CreateTags < ActiveRecord::Migration[5.0]
  def change
    enable_extension "uuid-ossp"

    create_table :tags, id: :uuid  do |t|
      t.string :name, limit: 100
      t.boolean :enabled, default: true

      t.timestamps
    end
  end
end

class CreateArchives < ActiveRecord::Migration[5.0]
  def change

    create_table :archives, id: :uuid  do |t|
      t.belongs_to :category
      t.uuid :license_id
      t.string :name, limit: 100
      t.text :description
      t.string :author, limit: 100
      t.string :owner, limit: 100
      t.integer :created_begin_on_y
      t.integer :created_begin_on_m
      t.integer :created_begin_on_d
      t.integer :created_end_on_y
      t.integer :created_end_on_m
      t.integer :created_end_on_d
      t.text :location
      t.st_point :lonlat, geographic: true, srid: 4326
      t.text :note
      t.attachment :represent_image
      t.boolean :enabled, default: false
      t.integer :updated_user_id
      t.timestamps
    end

    add_index :archives, :updated_user_id

  end
end

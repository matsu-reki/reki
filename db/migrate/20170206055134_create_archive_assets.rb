class CreateArchiveAssets < ActiveRecord::Migration[5.0]
  def change
    create_table :archive_assets do |t|
      t.uuid :archive_id
      t.attachment :image

      t.timestamps
    end
  end
end

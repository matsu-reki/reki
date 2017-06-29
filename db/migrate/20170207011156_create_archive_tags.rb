class CreateArchiveTags < ActiveRecord::Migration[5.0]
  def change
    create_table :archive_tags do |t|
      t.uuid :archive_id
      t.uuid :tag_id

      t.timestamps
    end
  end
end

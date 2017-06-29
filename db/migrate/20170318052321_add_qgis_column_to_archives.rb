class AddQgisColumnToArchives < ActiveRecord::Migration[5.0]
  def change
    add_column :archives, :qgis_id, :integer
    add_column :archives, :qgis_group_id, :integer

    add_column :archive_assets, :qgis_id, :integer
    add_column :archive_assets, :qgis_group_id, :integer
  end
end

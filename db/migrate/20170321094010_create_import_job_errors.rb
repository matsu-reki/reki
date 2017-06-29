class CreateImportJobErrors < ActiveRecord::Migration[5.0]
  def change
    create_table :import_job_errors do |t|
      t.integer :import_job_id
      t.string :name
      t.text :content

      t.timestamps
    end
  end
end

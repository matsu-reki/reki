class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :name, limit:50
      t.string :login, limit:30
      t.integer :role, default: 0
      t.string :password_digest
      t.datetime :last_logged_in_at
      t.boolean :enabled, default: true

      t.timestamps
    end
  end
end

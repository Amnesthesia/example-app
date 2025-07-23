class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :encrypted_password
      t.string :password_digest
      t.string :role
      t.references :organization

      t.timestamps
    end
    add_index :users, :password_digest
    add_index :users, :encrypted_password
    add_index :users, :role
  end
end

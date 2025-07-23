class CreateFamilies < ActiveRecord::Migration[7.0]
  def change
    create_table :families do |t|
      t.string :name

      t.references :organization
      t.timestamps
    end
    add_index :families, :name
  end
end

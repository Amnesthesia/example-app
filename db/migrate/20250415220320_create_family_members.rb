class CreateFamilyMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :family_members do |t|
      t.references :user, null: false, foreign_key: true
      t.references :family, null: false, foreign_key: true
      t.string :visibility, default: 'staff'

      t.timestamps
    end
    add_index :family_members, :visibility
  end
end

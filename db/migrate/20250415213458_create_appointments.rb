class CreateAppointments < ActiveRecord::Migration[7.0]
  def change
    create_table :appointments do |t|
      t.string :title
      t.string :state, default: 'draft'
      t.datetime :start_time
      t.datetime :end_time
      t.references :organization
      t.references :owner, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :appointments, :title
    add_index :appointments, :state
    add_index :appointments, :start_time
    add_index :appointments, :end_time
  end
end

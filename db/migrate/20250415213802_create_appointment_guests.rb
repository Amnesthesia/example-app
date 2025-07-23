class CreateAppointmentGuests < ActiveRecord::Migration[7.0]
  def change
    create_table :appointment_guests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :appointment, null: false, foreign_key: true

      t.timestamps
    end
  end
end

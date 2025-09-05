class CreateReservations < ActiveRecord::Migration[7.2]
  def change
    create_table :reservations do |t|
      t.string :title
      t.text :description
      t.string :reservation_type
      t.datetime :start_date
      t.datetime :end_date
      t.decimal :cost
      t.string :location
      t.string :confirmation_number
      t.references :user, null: false, foreign_key: true
      t.references :tribe, null: false, foreign_key: true

      t.timestamps
    end
  end
end

class CreateReservations < ActiveRecord::Migration[7.2]
  def change
    create_table :reservations do |t|
      t.string :title,               null: false
      t.text :description
      t.string :reservation_type,    null: false # 'flight', 'accommodation', 'activity', 'restaurant', 'transport', 'other'
      t.datetime :start_date
      t.datetime :end_date
      t.decimal :cost,               precision: 10, scale: 2
      t.string :country,            null: false
      t.string :city
      t.string :confirmation_number
      t.text :notes
      t.string :status,              default: 'planned' # 'planned', 'pending', 'reserved', 'paid', 'onsite', 'cancelled'

      # References
      t.references :user,            null: false, foreign_key: true
      t.references :tribe,           null: false, foreign_key: true

      t.timestamps
    end

    add_index :reservations, :reservation_type
    add_index :reservations, :start_date
    add_index :reservations, [:tribe_id, :start_date]
    add_index :reservations, :status
  end
end

class CreateTribes < ActiveRecord::Migration[7.2]
  def change
    create_table :tribes do |t|
      t.string :name,              null: false
      t.text :description
      t.string :invite_code,       null: false
      t.string :destination
      t.date :start_date
      t.date :end_date
      t.decimal :total_budget,     precision: 10, scale: 2
      t.decimal :current_expenses, precision: 10, scale: 2, default: 0

      t.timestamps
    end

    add_index :tribes, :invite_code, unique: true
    add_index :tribes, :name
  end
end

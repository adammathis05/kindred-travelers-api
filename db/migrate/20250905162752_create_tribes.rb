class CreateTribes < ActiveRecord::Migration[7.2]
  def change
    create_table :tribes do |t|
      t.string :name
      t.text :description
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end
end

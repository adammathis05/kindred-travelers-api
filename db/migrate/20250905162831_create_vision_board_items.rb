class CreateVisionBoardItems < ActiveRecord::Migration[7.2]
  def change
    create_table :vision_board_items do |t|
      t.string :title,               null: false
      t.text :description
      t.string :image_url
      t.string :link_url
      t.string :item_type,           default: 'inspiration' # 'inspiration', 'activity', 'place', 'food', 'accommodation'
      t.integer :priority,           default: 1 # 1-5 scale
      t.boolean :achieved,           default: false
      
      # References
      t.references :user,            null: false, foreign_key: true
      t.references :tribe,           null: false, foreign_key: true

      t.timestamps
    end

    add_index :vision_board_items, :item_type
    add_index :vision_board_items, :priority
    add_index :vision_board_items, [:tribe_id, :priority]
    add_index :vision_board_items, :achieved
  end
end

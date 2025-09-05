class CreateVisionBoardItems < ActiveRecord::Migration[7.2]
  def change
    create_table :vision_board_items do |t|
      t.string :title
      t.text :description
      t.string :image_url
      t.string :link_url
      t.references :user, null: false, foreign_key: true
      t.references :tribe, null: false, foreign_key: true

      t.timestamps
    end
  end
end

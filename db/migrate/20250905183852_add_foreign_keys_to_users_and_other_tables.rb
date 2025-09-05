class AddForeignKeysToUsersAndOtherTables < ActiveRecord::Migration[7.2]
  def change
    # Add foreign key constraint from users to tribes
    add_foreign_key :users, :tribes
    
    # Make tribe_id not nullable now that tribes table exists
    change_column_null :users, :tribe_id, false
    
    # Add any other foreign key constraints that might be needed
    # (reservations and vision_board_items should already have them from their generators)
  end
end

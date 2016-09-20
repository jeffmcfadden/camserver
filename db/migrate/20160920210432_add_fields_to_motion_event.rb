class AddFieldsToMotionEvent < ActiveRecord::Migration[5.0]
  def change
    add_column :motion_events, :processed, :boolean, default: false
    add_column :motion_events, :data_directory, :string
    
    add_index :motion_events, :occurred_at
    add_index :motion_events, [:camera_id, :occurred_at]
  end
end

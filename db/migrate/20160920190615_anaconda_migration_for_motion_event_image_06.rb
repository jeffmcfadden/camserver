class AnacondaMigrationForMotionEventImage06 < ActiveRecord::Migration
  def change
    add_column :motion_events, :image_06_filename, :string
    add_column :motion_events, :image_06_file_path, :text
    add_column :motion_events, :image_06_size, :integer
    add_column :motion_events, :image_06_original_filename, :text
    add_column :motion_events, :image_06_stored_privately, :boolean
    add_column :motion_events, :image_06_type, :string
  end
end

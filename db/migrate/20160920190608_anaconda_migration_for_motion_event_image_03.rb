class AnacondaMigrationForMotionEventImage03 < ActiveRecord::Migration
  def change
    add_column :motion_events, :image_03_filename, :string
    add_column :motion_events, :image_03_file_path, :text
    add_column :motion_events, :image_03_size, :integer
    add_column :motion_events, :image_03_original_filename, :text
    add_column :motion_events, :image_03_stored_privately, :boolean
    add_column :motion_events, :image_03_type, :string
  end
end

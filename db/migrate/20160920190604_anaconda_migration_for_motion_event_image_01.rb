class AnacondaMigrationForMotionEventImage01 < ActiveRecord::Migration
  def change
    add_column :motion_events, :image_01_filename, :string
    add_column :motion_events, :image_01_file_path, :text
    add_column :motion_events, :image_01_size, :integer
    add_column :motion_events, :image_01_original_filename, :text
    add_column :motion_events, :image_01_stored_privately, :boolean
    add_column :motion_events, :image_01_type, :string
  end
end

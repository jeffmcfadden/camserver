class AnacondaMigrationForMotionEventImage05 < ActiveRecord::Migration
  def change
    add_column :motion_events, :image_05_filename, :string
    add_column :motion_events, :image_05_file_path, :text
    add_column :motion_events, :image_05_size, :integer
    add_column :motion_events, :image_05_original_filename, :text
    add_column :motion_events, :image_05_stored_privately, :boolean
    add_column :motion_events, :image_05_type, :string
  end
end

class AnacondaMigrationForMotionEventImage04 < ActiveRecord::Migration
  def change
    add_column :motion_events, :image_04_filename, :string
    add_column :motion_events, :image_04_file_path, :text
    add_column :motion_events, :image_04_size, :integer
    add_column :motion_events, :image_04_original_filename, :text
    add_column :motion_events, :image_04_stored_privately, :boolean
    add_column :motion_events, :image_04_type, :string
  end
end

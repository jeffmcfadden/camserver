class CreateCameras < ActiveRecord::Migration[5.0]
  def change
    create_table :cameras do |t|
      t.string :name
      t.integer :camera_type
      t.string :ip_address
      t.string :username
      t.string :password
      t.string :port

      t.timestamps
    end
  end
end

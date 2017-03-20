class AddFtpStorageDirToCamera < ActiveRecord::Migration[5.0]
  def change
    add_column :cameras, :ftp_storage_dir, :string
  end
end

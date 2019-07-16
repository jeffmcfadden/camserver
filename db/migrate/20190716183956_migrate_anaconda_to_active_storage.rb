class MigrateAnacondaToActiveStorage < ActiveRecord::Migration[5.2]
  def change

    # MotionEvent.all.each do |me|
    #   puts "Migrating MotionEvent #{me.id} to Active Storage"
    #
    #   ["video_01", "image_01", "image_02", "image_03", "image_04", "image_05", "image_06"].each do |anaconda_column|
    #
    #     unless me.send(anaconda_column.to_sym).attached?
    #       begin
    #         blob       = ActiveStorage::Blob.create( key: me.video_01_file_path, filename: me.video_01_filename, metadata: {}, byte_size: me.video_01_size, checksum: "" )
    #         attachment = ActiveStorage::Attachment.create( name: "video_01", record_type: "MotionEvent", record_id: me.id, blob_id: blob.id )
    #       rescue ActiveRecord::RecordNotUnique => e
    #         puts "  Error migrating #{me.id} — we were using a duplicate key."
    #       end
    #     end
    #   end
    # end

  end
end

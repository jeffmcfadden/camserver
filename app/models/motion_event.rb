class MotionEvent < ApplicationRecord
  include ShellCommandable
  include Rails.application.routes.url_helpers
  
  belongs_to :camera
  
  paginates_per 40
  
  has_one_attached :video_01
  has_one_attached :image_01
  has_one_attached :image_02
  has_one_attached :image_03
  has_one_attached :image_04
  has_one_attached :image_05
  has_one_attached :image_06
  
  scope :favorites, -> { where( favorite: true ) }
  scope :not_favorites, -> { where( favorite: false ) }

  def video_01_url
    self.video_01.attached? ? rails_blob_path( self.video_01 ) : ""
  end
  
  def image_01_url
    self.image_01.attached? ? rails_blob_path( self.image_01 ) : ""
  end

  def image_02_url
    self.image_02.attached? ? rails_blob_path( self.image_02 ) : ""
  end

  def image_03_url
    self.image_03.attached? ? rails_blob_path( self.image_03 ) : ""
  end

  def image_04_url
    self.image_04.attached? ? rails_blob_path( self.image_04 ) : ""
  end

  def image_05_url
    self.image_05.attached? ? rails_blob_path( self.image_05 ) : ""
  end

  def image_06_url
    self.image_06.attached? ? rails_blob_path( self.image_06 ) : ""
  end
  
  def process_event_directory!
    event_directory = self.data_directory
    
    raise "Event Directory does not exist" unless Dir.exists?( "#{event_directory}" )

    if camera.amcrest_ipm721?
      f = Dir.glob( "#{event_directory}/*.mp4" ).first
    elsif camera.foscam_9821_ftp?
      f = Dir.glob( "#{event_directory}/*.mkv" ).first
    else
      f = Dir.glob( "#{event_directory}/*.avi" ).first
    end

    this_video_file = f

    Rails.logger.debug "  #{this_video_file}"

    base_filename = f.split( '/' ).last.gsub( '.avi', '' ).gsub( 'SDalarm_', '' ).gsub( 'MDalarm_', '' ).gsub( 'alarm_', '' )
    
    if camera.amcrest_ipm721?
      transcoded_filename = "#{this_video_file}-transcoded.mp4"
    elsif camera.foscam_9821_ftp?
      transcoded_filename = "#{this_video_file}-transcoded.mp4"
    else
      transcoded_filename = this_video_file.gsub( 'avi', 'mp4' )
    end

    transcode_cmd = "ffmpeg -y -i #{this_video_file} -acodec libfdk_aac -b:a 128k -vcodec copy #{transcoded_filename}"
    Rails.logger.debug "       #{transcode_cmd}"

    # last_exit_status, stdout, stderr = exec_with_timeout(transcode_cmd, desc = "", false, true,  120)
    last_exit_status, output = run_shell_command( transcode_cmd, "", false, false )

    if last_exit_status != 0
      #puts stdout
      #puts stderr
      Rails.logger.debug output
      raise "Transcode failed with code (#{last_exit_status})"
    end

    Rails.logger.debug "    Extracting stills"


    extract_cmd = "ffmpeg -ss 00:00:5.0 -i #{this_video_file} -vf fps=2 -vframes 6 #{event_directory}/image-%3d.jpeg"

    # last_exit_status, stdout, stderr = exec_with_timeout(extract_cmd, desc = "", false, true,  120)
    last_exit_status, output = run_shell_command( extract_cmd, "", false, false )

    if last_exit_status != 0
      #puts stdout
      #puts stderr
      Rails.logger.debug output
      raise "Frame extraction failed with code (#{last_exit_status})"
    end

    Rails.logger.debug "    Uploading and Creating Motion Event"

    # 5, 6, 7 images and the video, which represent 2.5, 3.0, and 3.5 seconds into the video
    image_filenames = ["image-001.jpeg", "image-002.jpeg", "image-003.jpeg", "image-004.jpeg", "image-005.jpeg"]
    video_filenames = [transcoded_filename.split( "/" ).last]

    begin
      self.video_01.attach(io: File.open(transcoded_filename), filename: transcoded_filename, content_type: "video/mpeg")
    rescue Errno::ENOENT => ex
      Rails.logger.error "    Motion Event #{self.id}. File failed to upload to S3. #{transcoded_filename} | #{ex}"
    end
        
    begin
      self.image_01.attach(io: File.open("#{event_directory}/image-001.jpeg"), filename: "image-001.jpeg", content_type: "image/jpeg")
    rescue Errno::ENOENT => ex
      Rails.logger.error "    Motion Event #{self.id}. File failed to upload to S3. #{event_directory}/image-001.jpeg | #{ex}"
    end

    begin
      self.image_02.attach(io: File.open("#{event_directory}/image-002.jpeg"), filename: "image-002.jpeg", content_type: "image/jpeg")
    rescue Errno::ENOENT => ex
      Rails.logger.error "    Motion Event #{self.id}. File failed to upload to S3. #{event_directory}/image-002.jpeg | #{ex}"
    end

    begin
      self.image_03.attach(io: File.open("#{event_directory}/image-003.jpeg"), filename: "image-003.jpeg", content_type: "image/jpeg")
    rescue Errno::ENOENT => ex
      Rails.logger.error "    Motion Event #{self.id}. File failed to upload to S3. #{event_directory}/image-003.jpeg | #{ex}"
    end
    
    begin
      self.image_04.attach(io: File.open("#{event_directory}/image-004.jpeg"), filename: "image-004.jpeg", content_type: "image/jpeg")
    rescue Errno::ENOENT => ex
      Rails.logger.error "    Motion Event #{self.id}. File failed to upload to S3. #{event_directory}/image-004.jpeg | #{ex}"
    end
    
    begin
      self.image_05.attach(io: File.open("#{event_directory}/image-005.jpeg"), filename: "image-005.jpeg", content_type: "image/jpeg")
    rescue Errno::ENOENT => ex
      Rails.logger.error "    Motion Event #{self.id}. File failed to upload to S3. #{event_directory}/image-005.jpeg | #{ex}"
    end
    
    begin
      self.image_06.attach(io: File.open("#{event_directory}/image-006.jpeg"), filename: "image-006.jpeg", content_type: "image/jpeg")
    rescue Errno::ENOENT => ex
      Rails.logger.error "    Motion Event #{self.id}. File failed to upload to S3. #{event_directory}/image-006.jpeg | #{ex}"
    end

    Rails.logger.debug "Cleaning up the directory"
    
    begin
      FileUtils.rm this_video_file,     force: true
      FileUtils.rm transcoded_filename, force: true
      FileUtils.rm_rf("#{event_directory}") if event_directory.strip != "" && event_directory.length > 12 #Tiny safeguard
    rescue StanderError => error
      Rails.logger.debug "    Error removing files: #{error}"
    end
    
    self.update_attributes( processed: true )

    Rails.logger.debug "    Done with #{this_video_file}"
  end
  
  def migrate_to_active_storage
    me = self # Just because I copied from somewhere else
    ["video_01", "image_01", "image_02", "image_03", "image_04", "image_05", "image_06"].each do |anaconda_column|

      unless me.send(anaconda_column.to_sym).attached?
        begin
          
          filename = me.send( "#{anaconda_column}_filename".to_sym )
          filename = "#{anaconda_column}" if filename.nil?
          
          blob       = ActiveStorage::Blob.create( key: me.send( "#{anaconda_column}_file_path".to_sym ), filename: filename, metadata: {}, byte_size: me.send( "#{anaconda_column}_size".to_sym ).to_i, checksum: "" )
          attachment = ActiveStorage::Attachment.create( name: "#{anaconda_column}", record_type: "MotionEvent", record_id: me.id, blob_id: blob.id )
        rescue ActiveRecord::RecordNotUnique => e
          puts "  Error migrating #{me.id} column #{anaconda_column} — we were using a duplicate key."
        rescue StandardError => e
          puts "  Error migrating #{me.id} column #{anaconda_column} — #{e}"
        end
      end
    end
  end
    
  
  private 

  def asset_key( asset_name )
    "motion_events/#{self.id}_#{self.occurred_at.strftime("%Y-%m-%d-%H-%M-%S")}/#{asset_name}_#{random_string}"
  end
  
  def random_string
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    s = (0...24).map { o[rand(o.length)] }.join
  end
  
end

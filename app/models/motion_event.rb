class MotionEvent < ApplicationRecord
  include ShellCommandable
  
  belongs_to :camera
  
  paginates_per 40
  
  anaconda_for :video_01, base_key: :video_01_asset_key
  anaconda_for :image_01, base_key: :image_01_asset_key
  anaconda_for :image_02, base_key: :image_02_asset_key
  anaconda_for :image_03, base_key: :image_03_asset_key
  anaconda_for :image_04, base_key: :image_04_asset_key
  anaconda_for :image_05, base_key: :image_05_asset_key
  anaconda_for :image_06, base_key: :image_06_asset_key
  
  scope :favorites, -> { where( favorite: true ) }
  scope :not_favorites, -> { where( favorite: false ) }
  
  def video_01_asset_key
    asset_key( "video_01")
  end
  
  def image_01_asset_key
    asset_key( "image_01")
  end
  
  def image_02_asset_key
    asset_key( "image_02")
  end
  
  def image_03_asset_key
    asset_key( "image_03")
  end
  
  def image_04_asset_key
    asset_key( "image_04")
  end
  
  def image_05_asset_key
    asset_key( "image_05")
  end
  
  def image_06_asset_key
    asset_key( "image_06")
  end
  
  def process_event_directory!
    event_directory = self.data_directory
    
    raise "Event Directory does not exist" unless Dir.exists?( "#{event_directory}" )

    if camera.amcrest_ipm721?
      f = Dir.glob( "#{event_directory}/*.mp4" ).first
    else
      f = Dir.glob( "#{event_directory}/*.avi" ).first
    end

    this_video_file = f

    Rails.logger.debug "  #{this_video_file}"

    base_filename = f.split( '/' ).last.gsub( '.avi', '' ).gsub( 'SDalarm_', '' ).gsub( 'MDalarm_', '' ).gsub( 'alarm_', '' )
    
    if camera.amcrest_ipm721?
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
      self.import_file_to_anaconda_column( transcoded_filename, :video_01, { acl: "public-read" } )
    rescue Errno::ENOENT => ex
      Rails.logger.error "    Motion Event #{self.id}. File failed to upload to S3. #{transcoded_filename} | #{ex}"
    end
        
    begin
      self.import_file_to_anaconda_column( "#{event_directory}/image-001.jpeg", :image_01, { acl: "public-read" } )
    rescue Errno::ENOENT => ex
      Rails.logger.error "    Motion Event #{self.id}. File failed to upload to S3. #{event_directory}/image-001.jpeg | #{ex}"
    end

    begin
      self.import_file_to_anaconda_column( "#{event_directory}/image-002.jpeg", :image_02, { acl: "public-read" } )
    rescue Errno::ENOENT => ex
      Rails.logger.error "    Motion Event #{self.id}. File failed to upload to S3. #{event_directory}/image-002.jpeg | #{ex}"
    end

    begin
      self.import_file_to_anaconda_column( "#{event_directory}/image-003.jpeg", :image_03, { acl: "public-read" } )
    rescue Errno::ENOENT => ex
      Rails.logger.error "    Motion Event #{self.id}. File failed to upload to S3. #{event_directory}/image-003.jpeg | #{ex}"
    end
    
    begin
      self.import_file_to_anaconda_column( "#{event_directory}/image-004.jpeg", :image_04, { acl: "public-read" } )
    rescue Errno::ENOENT => ex
      Rails.logger.error "    Motion Event #{self.id}. File failed to upload to S3. #{event_directory}/image-004.jpeg | #{ex}"
    end
    
    begin
      self.import_file_to_anaconda_column( "#{event_directory}/image-005.jpeg", :image_05, { acl: "public-read" } )
    rescue Errno::ENOENT => ex
      Rails.logger.error "    Motion Event #{self.id}. File failed to upload to S3. #{event_directory}/image-005.jpeg | #{ex}"
    end
    
    begin
      self.import_file_to_anaconda_column( "#{event_directory}/image-006.jpeg", :image_06, { acl: "public-read" } )
    rescue Errno::ENOENT => ex
      Rails.logger.error "    Motion Event #{self.id}. File failed to upload to S3. #{event_directory}/image-006.jpeg | #{ex}"
    end

    Rails.logger.debug "Cleaning up the directory"
    FileUtils.rm_rf("#{event_directory}") if event_directory.strip != "" && event_directory.length > 12 #Tiny safeguard
    self.update_attributes( processed: true )

    Rails.logger.debug "    Done with #{this_video_file}"
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

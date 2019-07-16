class MotionEvent < ApplicationRecord
  include ShellCommandable
  
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
    self.video_01.attached? ? self.video_01.service_url : ""
  end
  
  def image_01_url
    self.image_01.attached? ? self.image_01.service_url : ""
  end

  def image_02_url
    self.image_02.attached? ? self.image_02.service_url : ""
  end

  def image_03_url
    self.image_03.attached? ? self.image_03.service_url : ""
  end

  def image_04_url
    self.image_04.attached? ? self.image_04.service_url : ""
  end

  def image_05_url
    self.image_05.attached? ? self.image_05.service_url : ""
  end

  def image_06_url
    self.image_06.attached? ? self.image_06.service_url : ""
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

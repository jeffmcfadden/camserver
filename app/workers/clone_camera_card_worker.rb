class CloneCameraCardWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'low'
  
  include ShellCommandable
  
  def perform(camera_id)
    
    @camera = Camera.find(camera_id)
    
    raise "Camera #{camera_id} not found" if @camera.nil?
    
    @working_dir_base = ENV['TRANSCODE_WORKING_DIRECTORY'] || Rails.root.join( 'tmp' ).to_s
    @camera_dir = @working_dir_base + "/camera_#{@camera.id}"
    @clone_dir = @camera_dir + "/card_clone"
    @events_dir = @camera_dir + "/events"
    
    
    Dir.mkdir( "#{@camera_dir}" ) unless Dir.exists?( "#{@camera_dir}" )
    Dir.mkdir( "#{@clone_dir}" )  unless Dir.exists?( "#{@clone_dir}" )
    Dir.mkdir( "#{@events_dir}" ) unless Dir.exists?( "#{@events_dir}" )
    
    clone_camera_card
    create_events_from_camera_card_clone
  end
  
  def clone_camera_card
    Rails.logger.debug "  clone_camera_card"
    
    ftp_command = "lftp -p #{@camera.port} -u #{@camera.username},#{@camera.password} -e \"set ftp:passive-mode false; mirror -v --Move /IPCamera #{@clone_dir}; bye\" #{@camera.ip_address}"
    
    Rails.logger.debug "  #{ftp_command}"
    
    # last_exit_status, stdout, stderr = exec_with_timeout(ftp_command, desc = "", false, true,  1800)
    last_exit_status, output = run_shell_command( ftp_command, "", false, false )
    
    if last_exit_status != 0
      #puts stdout
      #puts stderr
      Rails.logger.debug "Clone returned an error: \n\n#{output}"
      # raise "Clone failed with exit code #{last_exit_status}."
    end
  end
  
  def create_events_from_camera_card_clone
    Rails.logger.debug "create_events_from_camera_card_clone"
    
    Find.find(self.camera_files_clone_directory) do |f|
      begin
        if f.match(/\.avi\Z/)
          base_filename = f.split( '/' ).last.gsub( '.avi', '' ).gsub( 'alarm_', '' ).gsub( 'MD', '' ).gsub( 'SD', '' )

          Rails.logger.debug "  #{f}"
          Rails.logger.debug "  #{base_filename}"

          year  = base_filename[0,4]
          month = base_filename[4,2]
          day   = base_filename[6,2]
          hour   = base_filename[9,2]
          minute = base_filename[11,2]
          second = base_filename[13,2]

          event_time = Time.local( year, month, day, hour, minute, second )

          this_event_directory = self.camera_events_directory + '/' + event_time.strftime( "%Y-%m-%d_%H%M%S" )

          Dir.mkdir( "#{this_event_directory}" ) unless Dir.exists?( "#{this_event_directory}" )

          Rails.logger.debug "    Moving file to new directory"
          FileUtils.mv f, this_event_directory
        end
      rescue Exception => ex
       Rails.logger.debug "    Error: #{ex.to_s}"
      end
    end
  end
  
  
end
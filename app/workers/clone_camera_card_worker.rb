require 'find'
require 'fileutils'

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
    
    CloneCameraCardWorker.perform_in( 2.minutes, camera_id)
  end
  
  def clone_camera_card
    Rails.logger.debug "  clone_camera_card"
    
    @camera.ftp_storage_dir = "/IPCamera" unless @camera.ftp_storage_dir.present?
    
    ftp_command = "lftp -p #{@camera.port} -u \"#{@camera.username},#{@camera.password}\" -e \"set ftp:passive-mode false; mirror -v --Move #{@camera.ftp_storage_dir} #{@clone_dir}; bye\" #{@camera.ip_address}"
    
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
    
    if @camera.foscam_9821?
      create_events_from_camera_card_clone_foscam_9821
    elsif @camera.amcrest_ipm721?
      create_events_from_camera_card_clone_amcrest_ipm721
    elsif @camera.foscam_9821_ftp?
      create_events_from_camera_card_clone_foscam_9821_ftp
    else
      Rails.logger.info "Camera type unknown. Skipping. (#{@camera.camera_type})"
    end

  end
  
  def create_events_from_camera_card_clone_foscam_9821
    Rails.logger.debug "create_events_from_camera_card_clone_foscam_9821"
    
    Find.find(@clone_dir) do |f|
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

          this_event_directory = @events_dir + '/' + event_time.strftime( "%Y-%m-%d_%H%M%S" )

          unless Dir.exists?( "#{this_event_directory}" )
            Dir.mkdir( "#{this_event_directory}" ) 
            @motion_event = MotionEvent.create( { camera: @camera, occurred_at: event_time, processed: false, data_directory: this_event_directory } )
          end

          Rails.logger.debug "    Moving file to new directory"
          Rails.logger.debug "    #{f}   =>   #{this_event_directory}"
          
          FileUtils.mv f, this_event_directory
          
          ProcessEventWorker.perform_in( 10.seconds, @motion_event.id ) if @motion_event.present?
        end
      rescue Exception => ex
       Rails.logger.debug "    Error: #{ex.to_s}"
      end
    end
  end
  
  def create_events_from_camera_card_clone_amcrest_ipm721
    Rails.logger.debug "create_events_from_camera_card_clone_amcrest_ipm721"
    
    Find.find(@clone_dir) do |f|
      begin
        if f[-4,4] == ".mp4"
          next unless File.new(f).size > 100000 #Skip tiny files. Sometimes bad data happens.
          event_time = File.new(f).mtime
          
          this_event_directory = @events_dir + '/' + event_time.strftime( "%Y-%m-%d_%H%M%S" )

          unless Dir.exists?( "#{this_event_directory}" )
            Dir.mkdir( "#{this_event_directory}" ) 
            @motion_event = MotionEvent.create( { camera: @camera, occurred_at: event_time, processed: false, data_directory: this_event_directory } )
          end

          Rails.logger.debug "    Moving file to new directory"
          Rails.logger.debug "    #{f}   =>   #{this_event_directory}"
          
          FileUtils.mv f, "#{this_event_directory}/#{event_time.strftime( "%Y%m%d_%H%M%S" )}.mp4"
          
          ProcessEventWorker.perform_in( 10.seconds, @motion_event.id ) if @motion_event.present?
        elsif f[-4,4] == ".jpg"
          File.delete(f)
        end
      rescue Exception => ex
       Rails.logger.debug "    Error: #{ex.to_s}"
      end
    end
    
    def create_events_from_camera_card_clone_foscam_9821_ftp
      Rails.logger.debug "create_events_from_camera_card_clone_foscam_9821_ftp"
    
      Find.find(@clone_dir) do |f|
        begin
          if f.match(/\.mkv/)
          
            event_time = File.new(f).mtime
          
            this_event_directory = @events_dir + '/' + event_time.strftime( "%Y-%m-%d_%H%M%S" )

            unless Dir.exists?( "#{this_event_directory}" )
              Dir.mkdir( "#{this_event_directory}" ) 
              @motion_event = MotionEvent.create( { camera: @camera, occurred_at: event_time, processed: false, data_directory: this_event_directory } )
            end

            Rails.logger.debug "    Moving file to new directory"
            Rails.logger.debug "    #{f}   =>   #{this_event_directory}"
          
            FileUtils.mv f, "#{this_event_directory}/#{event_time.strftime( "%Y%m%d_%H%M%S" )}.mkv"
          
            ProcessEventWorker.perform_in( 10.seconds, @motion_event.id ) if @motion_event.present?
          else
            puts "Ignoring #{f}"
          end
        rescue Exception => ex
         Rails.logger.debug "    Error: #{ex.to_s}"
        end
      end
    end
  end
end
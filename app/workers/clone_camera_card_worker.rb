class CloneCameraCardWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'cardclone'
  
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
      puts output
      raise "Clone failed with exit code #{last_exit_status}."
    end
  end
  
  
end
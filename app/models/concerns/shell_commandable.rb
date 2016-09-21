# Original Author Ben McFadden <ben@forgeapps.com>

require "active_support/all"


module ShellCommandable
  extend ActiveSupport::Concern

  def run_shell_command( cmd, desc = "", raise_error_on_fail = true, return_output = false )
    output = `#{cmd.force_encoding("UTF-8")} 2>&1`
    status = $?.exitstatus.to_i

    # puts "Output:\n#{output}"
    # puts "Status:\n#{status}"

    raise "#{desc} failed. #{output}" if status != 0 && raise_error_on_fail
    if return_output
      return output
    end
    
    return status, output
  end
  
  
  #TODO: This needs a lot of testing before going into use
  #http://stackoverflow.com/a/15326369/1084109
  #http://stackoverflow.com/a/12202439/1084109
  def exec_with_timeout(cmd, desc = "", raise_error_on_fail = true, return_output = false,  timeout = 60)
    # stdout, stderr pipes
    rout, wout = IO.pipe
    rerr, werr = IO.pipe
    
    pid = Process.spawn(cmd, out: wout, err: werr, pgroup: true)
    puts "PID: #{pid}"
    begin
      process_status = nil
      Timeout.timeout(timeout) do
        _, process_status = Process.wait2(pid)
      end
      
      # close write ends so we could read them
      wout.close
      werr.close

      stdout = rout.readlines.join("\n")
      stderr = rerr.readlines.join("\n")

      # dispose the read ends of the pipes
      rout.close
      rerr.close

      last_exit_status = process_status.exitstatus
      
      raise "#{desc} failed. #{stdout}" if last_exit_status != 0 && raise_error_on_fail
    rescue Timeout::Error
      Process.kill(15, -Process.getpgid(pid))
      raise Error::TimeoutError
    end
    
    if return_output
      return stdout
    end
    
    return last_exit_status, stdout, stderr
  end
  
  module Error
    class Standard < StandardError; end
    class TimeoutError < Standard; end
  end
end
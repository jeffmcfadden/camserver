require 'mail'
require 'net/http'
require 'json'

class ImportEventsFromMailWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'low'
  
  def perform
    Mail.defaults do
      retriever_method :imap, :address    => ENV['MAIL_IMPORT_ADDRESS'],
                              :port       => ENV['MAIL_IMPORT_PORT'].to_i,
                              :user_name  => ENV['MAIL_IMPORT_USERNAME'],
                              :password   => ENV['MAIL_IMPORT_PASSWORD'],
                              :enable_ssl => (ENV['MAIL_IMPORT_ENDABLE_SSL'] == "true"),
                              :mailbox    => ENV['MAIL_IMPORT_MAILBOX']
    end

    Rails.logger.debug "Checking mail..."

    process_mail

    ImportEventsFromMailWorker.perform_in( 1.minute )
  end  
  
  def process_mail
    subjects = ["motion alarm", "IPCamera alarm"]

    subjects.each do |subject|
      Rails.logger.debug "  Processing messages with subject #{subject}..."

      begin
        Mail.find_and_delete( keys: "SUBJECT \"#{subject}\"" ) do |m|
          
          Rails.logger.debug "    Processing message #{m.subject}"
          
      
          event_date_string = m.subject.split( " " ).last rescue ""
      
          event_date_year   = event_date_string[0..3].to_i rescue 2000
          event_date_month  = event_date_string[4..5].to_i rescue 01
          event_date_day    = event_date_string[6..7].to_i rescue 01
          event_date_hour   = event_date_string[8..9].to_i rescue 01
          event_date_minute = event_date_string[10..11].to_i rescue 01
          event_date_second = event_date_string[12..13].to_i rescue 01

          event_date = Time.new( event_date_year, event_date_month, event_date_day , event_date_hour, event_date_minute, event_date_second )

          # printf "Mail date: #{m.date}\n"
          # printf "Event date: #{event_date}\n"

          matches = /.*\((.*)\).*/.match(m.subject)
          
          camera_name = matches[1]
          
          Rails.logger.debug "      Camera name: #{camera_name}"

          @camera = Camera.find_by name: camera_name
          
          Rails.logger.debug "      Creating motion event..."
          @motion_event = @camera.motion_events.create occurred_at: event_date, processed: true

          Rails.logger.debug "      Saving attachments..."
          n = 0
          m.attachments.each_with_index do |attachment, i|
            Rails.logger.debug "          #{i + 1}"
            
            Dir.mktmpdir {|dir|
              filename = File.join( dir, "event_image.jpg")
              File.open(filename, "w+b", 0644) {|f| f.write attachment.body.decoded}
              
              begin
                @motion_event.send("image_0#{i + 1}".to_sym).attach(io: File.open(filename), filename: "image_0#{i + 1}.jpg", content_type: "image/jpeg")
              rescue Errno::ENOENT => ex
                Rails.logger.error "File failed to upload to S3. #{filename} | #{ex}"
              end
            }
          end
          
          
          Rails.logger.debug "      done with message."
        end

      rescue Exception => e
        Rails.logger.debug "Exception! #{e.message}"
        Rails.logger.debug "Will retry."
      end
    end
  end
  
end
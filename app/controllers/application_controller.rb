class ApplicationController < ActionController::Base
  # protect_from_forgery with: :exception, prepend: true
  
  before_action :set_time_zone
  
  def set_time_zone
    Time.zone = "US/Arizona"
  end
  
end

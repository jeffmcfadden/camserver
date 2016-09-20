class HomeController < ApplicationController
  def index
  
    if current_user.present?
      redirect_to [:motion_events]
    end
  end
end

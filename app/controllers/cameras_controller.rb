class CamerasController < ApplicationController

  def index
    @cameras = Camera.order( name: :asc )
  end
  
  def new
    @camera = Camera.new
  end
  
  def create
    @camera = Camera.create( camera_params )
    
    redirect_to @camera
  end
  
  def edit
    @camera = Camera.find(params[:id])
  end
  
  def update
    @camera = Camera.find(params[:id])
    
    @camera.update_attributes( camera_params )
    
    flash[:notice] = "Updated"
    redirect_to @camera
  end
  
  def show
    @camera = Camera.find(params[:id])
  end
  
  def create_card_clone_worker
    @camera = Camera.find(params[:id])
    
    CloneCameraCardWorker.perform_async(@camera.id)
    flash[:notice] = "Worker enqueued"
    redirect_to @camera
  end
  
  private
  
  def camera_params
    params.require( :camera ).permit( :name, :camera_type, :ip_address, :port, :username, :password, :ftp_storage_dir )
  end
  

end

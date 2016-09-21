class MotionEvent < ApplicationRecord
  belongs_to :camera
  
  paginates_per 40
  
  anaconda_for :video_01, base_key: :video_01_asset_key
  anaconda_for :image_01, base_key: :image_01_asset_key
  anaconda_for :image_02, base_key: :image_02_asset_key
  anaconda_for :image_03, base_key: :image_03_asset_key
  anaconda_for :image_04, base_key: :image_04_asset_key
  anaconda_for :image_05, base_key: :image_05_asset_key
  anaconda_for :image_06, base_key: :image_06_asset_key
  
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
    
  
  private 

  def asset_key( asset_name )
    "motion_events/#{self.id}_#{self.occurred_at.strftime("%Y-%m-%d-%H-%M-%S")}/#{asset_name}_#{random_string}"
  end
  
  def random_string
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    s = (0...24).map { o[rand(o.length)] }.join
  end
  
end

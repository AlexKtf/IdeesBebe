# == Schema Information
#
# Table name: photos
#
#  id         :integer          not null, primary key
#  product_id :integer
#  file       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Photo < ActiveRecord::Base

  belongs_to :product

  mount_uploader :file, PhotoUploader

end

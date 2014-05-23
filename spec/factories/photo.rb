# == Schema Information
#
# Table name: photos
#
#  id              :integer          not null, primary key
#  file            :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  referencer_id   :integer
#  referencer_type :string(255)
#  uploading       :boolean          default(FALSE)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :photo do
    file "MyString"
  end
end

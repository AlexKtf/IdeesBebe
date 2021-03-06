# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  username               :string(255)
#  slug                   :string(255)
#  response_time          :integer          default(0)
#  provider               :string(255)
#  fb_id                  :string(255)
#  fb_tk                  :string(255)
#  is_admin               :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :user do
    email
    username
    password 'myamazingpassword'
    response_time 0
    is_admin false
  end
end

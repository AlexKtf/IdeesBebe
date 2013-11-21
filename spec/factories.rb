FactoryGirl.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  sequence :username do |n|
    "username#{n}"
  end

  sequence :name do |n|
    "product_name#{n}"
  end
end
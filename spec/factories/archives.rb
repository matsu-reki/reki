#
# デフォルトでは category を同時に作成しないこと
#
FactoryGirl.define do
  factory :archive do
    sequence(:author) { |n| "作者#{n}" }
    sequence(:description) { |n| "説明#{n}" }
    enabled   true
    latitude  35.475482
    longitude 133.049498
    sequence(:name)  { |n| "資料#{n}" }
    sequence(:owner) { |n| "所有者#{n}" }
    represent_image { File.new(Rails.root.join("spec", "factories", "images", "test01.jpg")) }
  end

end

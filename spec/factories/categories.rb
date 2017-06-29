FactoryGirl.define do
  factory :category do
    sequence(:code) { |n| n }
    sequence(:name) { |n| "分類#{n}" }
    enabled true
  end
end

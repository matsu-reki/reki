FactoryGirl.define do
  factory :tag do
    sequence(:name) { |n| "タグ#{n}" }
    enabled true
  end
end

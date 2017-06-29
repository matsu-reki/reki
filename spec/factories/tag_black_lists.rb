FactoryGirl.define do
  factory :tag_black_list do
    sequence(:name) { |n| "タグ禁止用語#{n}" }
    enabled true
  end
end

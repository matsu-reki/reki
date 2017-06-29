FactoryGirl.define do
  factory :license do
    sequence(:code) { |n| n }
    sequence(:name) { |n| "ライセンス#{n}" }
    enabled true
    content_type "url"
    content "http://www.netlab.jp"
  end
end

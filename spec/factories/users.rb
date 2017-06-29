FactoryGirl.define do
  factory :user do
    password 'password'
    password_confirmation 'password'
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:name)  { |n| "ユーザ#{n}" }
    sequence(:login) { |n| "user#{n}" }
    enabled true

    trait :admin do
      role 'admin'
    end

    trait :standard do
      role 'standard'
    end
  end

  factory :user_admin, parent: :user, traits: %i(admin), class: User
  factory :user_standard, parent: :user, traits: %i(standard), class: User

end

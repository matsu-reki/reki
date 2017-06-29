require 'rails_helper'

RSpec.describe User, type: :model do

  describe "Validation" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }

    it { is_expected.to validate_presence_of(:login) }
    it { is_expected.to validate_uniqueness_of(:login) }
    it { is_expected.to validate_length_of(:login).is_at_least(4) }
    it { is_expected.to validate_length_of(:login).is_at_most(30) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_least(4) }
    it { is_expected.to validate_length_of(:name).is_at_most(50) }

    it { is_expected.to validate_length_of(:password) }
    it { is_expected.to validate_length_of(:password).is_at_least(8) }

    it { is_expected.to validate_presence_of(:role) }

    it "invalid emails" do
      invalid_emails = %w(
          user@foo,com
          user_at_foo.org
          example.user@foo.
          foo@bar_baz.com
          foo@bar+baz.com
          foo@bar..com
        )
      is_expected.not_to allow_value(*invalid_emails).for(:email)
    end

    it "invalid logins" do
      invalid_logins = %w(
          あいうえお
          ＡＢＣＤ
          ０１２３４
        )
      is_expected.not_to allow_value(*invalid_logins).for(:login)
    end

    it "invalid passwords" do
      invalid_passwords = %w(
          あいうえおかきくけこ
          ＡＢＣＤＥＦＧＨＩＪ
          ０１２３４５６７８９
        )
      is_expected.not_to allow_value(*invalid_passwords).for(:password)
    end

  end

end

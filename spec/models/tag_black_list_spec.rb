require 'rails_helper'

RSpec.describe TagBlackList, type: :model do

  describe "Validation" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_least(1) }
    it { is_expected.to validate_length_of(:name).is_at_most(100) }

    it "valid names" do
      valid_names = [
        "漢字",
        "あいうえお",
        "AＢC",
        "アイウエオ",
        "ｱｲｳｴｵ",
        "12345",
        "１２３４５"
      ]

      is_expected.to allow_value(*valid_names).for(:name)
    end

    it "invalid names" do
      invalid_names = [
        "あ あ",
        "あ　あ",
        "あ,あ"
      ]
      is_expected.not_to allow_value(*invalid_names).for(:name)
    end
  end
end

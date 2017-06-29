require 'rails_helper'

RSpec.describe License, type: :model do

  describe "Validation" do
    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_numericality_of(:code) }
    it { is_expected.to validate_uniqueness_of(:code) }

    it { is_expected.to validate_presence_of(:content_type) }

    it { is_expected.to validate_presence_of(:content) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(50) }
    it { is_expected.to validate_uniqueness_of(:name) }

    describe "validate_url_content" do
      it "content_type が url の場合、content の内容が URL形式でないとエラー" do
        license = build(:license, content_type: "url")
        license.content = "aaaaa"
        license.valid?
        expect(license.errors.added?(:content, :invalid)).to be true
      end
    end
  end
end

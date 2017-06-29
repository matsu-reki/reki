require 'rails_helper'

RSpec.describe Category, type: :model do

  describe "Validation" do
    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_numericality_of(:code) }
    it { is_expected.to validate_uniqueness_of(:code) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(30) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

end

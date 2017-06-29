#
# 資料の分類
#
class Category < ApplicationRecord

  has_many :archives, dependent: :restrict_with_error

  validates :code, presence: true, numericality: { only_integer: true }, uniqueness: true
  validates :enabled, inclusion: { in: [true, false] }
  validates :name, presence: true, uniqueness: true, length: { maximum: 30 }

  scope :enabled, -> { where(enabled: true) }

  #
  # 資料登録時の初期値とする分類
  #
  def self.default
    return Category.first
  end
end

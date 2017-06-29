#
# タグに使えない言葉
#
# とりあえず完全一致のみ
#
class TagBlackList < ApplicationRecord

  validates :name, presence: true, uniqueness: true, length: { in: 1..100 },
    tag: true
  validates :enabled, inclusion: { in: [true, false] }

  scope :enabled, -> { where(enabled: true) }
end

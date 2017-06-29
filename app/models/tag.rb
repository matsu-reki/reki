#
# 資料に付与するタグ
#
# タグを用いて、資料の関連を作成する
#
class Tag < ApplicationRecord

  has_many :archives, through: :archive_tags
  has_many :archive_tags, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true, length: { in: 1..100 },
    tag: true
  validates :enabled, inclusion: { in: [true, false] }

  validate :validate_black_list

  scope :enabled, -> { where(enabled: true) }

  #
  # キーワードから固有名詞を抜き出し、タグのラベルを抽出する
  #
  def self.generate(text)
    ret = []
    if text.blank?
      return ret
    end

    meacb_options = {}
    meacb_options[:dicdir] = Settings.mecab.dicdir if Settings.mecab.dicdir.present?
    m = Natto::MeCab.new(meacb_options)
    m.enum_parse(text).map do |e|
      next if e.is_eos?

      f = e.feature.split(',')

      # 指定の要素以外は除外する
      unless Settings.tag.morpheme.include?(f[1])
        next
      end

      tag = Tag.new(name: f[-3])
      tag.valid?

      if tag.errors.size == 0
        ret << f[-3]
      elsif tag.errors.size == 1
        if tag.errors.added?(:name, :taken)
          ret << f[-3]
        end
      end
    end

    ret.uniq!

    TagBlackList.enabled.where(name: ret).each do |b|
      ret.delete b.name
    end

    return ret
  end


  private

    #
    # タグ名称が禁止用語に含まれているかを検証する
    #
    def validate_black_list
      if name.present? && TagBlackList.enabled.where(name: name).exists?
        errors.add(:name, :black_list, target: "x")
      end
    end

end

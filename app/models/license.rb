#
# 資料のライセンス
#
class License < ApplicationRecord
  include EnumAttribute

  # ライセンスの種別
  enum content_type: {
    url: 0,          # 外部サイトのライセンス表示を設定する
    text: 1          # システムのライセンス用ページに内容を表示する
  }

   has_many :archives, dependent: :restrict_with_error

   validates :code, presence: true, numericality: { only_integer: true }, uniqueness: true
   validates :content, presence: true
   validates :content_type, presence: true
   validates :enabled, inclusion: { in: [true, false] }
   validates :name, presence: true, uniqueness: true, length: { maximum: 50 }

   validate :validate_url_content

   scope :enabled, -> { where(enabled: true) }

  #
  # 資料登録時の初期値とするライセンス
  #
  def self.default
    return License.first
  end

   #
   # ライセンス表記を示すURLを返す
   #
   # 種別によって返す内容が異なる
   #  * url  : content に設定した 外部サイトの URL の内容を返す.
   #  * text : content に設定した内容を表示するシステムの URL を返す
   #
   def url
     if url?
       return content
     else
       return Rails.application.routes.url_helpers.license_url(id: id)
     end
   end


   private

    #
    # content_type が url の場合、content が URL 形式かどうかチェックする
    #
    def validate_url_content
      if url?
        if content !~ URI::regexp(%w(http https))
          errors.add :content, :invalid
        end
      end
    end

end

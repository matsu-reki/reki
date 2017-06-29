#
# 資料に付与したタグの情報を管理する
#
class ArchiveTag < ApplicationRecord

  belongs_to :archive
  belongs_to :tag

end

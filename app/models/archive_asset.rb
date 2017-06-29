#
# 資料の画像
#
class ArchiveAsset < ApplicationRecord

  has_attached_file :image,
    path: ":rails_root/public/system/:rails_env/:class/:attachment/:id/:style/:filename",
    url: "/system/:rails_env/:class/:attachment/:id/:style/:filename",
    styles: { original: "700x>", thumb: "120x150#" }

  belongs_to :archive

  validates_attachment :image, presence: true,
    content_type: { content_type: ["image/jpeg", "image/gif", "image/png"] }

end

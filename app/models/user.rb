#
# ユーザ
#
class User < ApplicationRecord
  include EnumAttribute

  # 権限
  enum role: {
    admin: 0,     # 管理者
    standard: 1   # 編集者
  }

  has_secure_password

  has_many :archives, foreign_key: "updated_user_id", dependent: :nullify
  has_many :import_jobs, dependent: :nullify

  validates :email, presence: true, uniqueness: true, email: true
  validates :enabled, inclusion: { in: [true, false] }
  validates :login, presence: true, uniqueness: true,
    length: { in: 4..30 }, alphameric: true
  validates :name, presence: true, length: { in: 4..50 }
  validates :password, presence: true, length: { minimum: 8 }, alphameric: true,
    if: :password
  validates :role, presence: true

  #
  # ,削除可能かどうかを返す
  #
  def destroyable?(current_user)
    if id == current_user.id
      return false
    end

    if admin? && User.admin.where.not(id: id).count < 1
      return false
    else
      return true
    end
  end

end

#
# 管理者機能の基底クラス
#
class Admin::BaseController < ::ApplicationController

  before_action :admin_required

end

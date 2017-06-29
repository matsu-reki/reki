#
# ライセンス内容表示
#
class LicensesController < ApplicationController

  layout 'docs'

  before_action :set_license, only: %i(show)

  #
  # ライセンスの内容を表示する
  #
  def show
    render 'show'
  end

  private

    def set_license
      @license = License.enabled.text.find_by(id: params[:id])
      if @license.blank?
        render_error
      end
    end

end

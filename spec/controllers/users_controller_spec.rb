require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  describe "Action" do

    before do
      @user = create(:user_admin)
      login @user
    end

    describe "GET #edit" do
      it 'edit テンプレートが表示されること' do
        get :edit, params: { id: @user.to_param }
        expect(response).to render_template :edit
      end

      it 'User のインスタンスが管理者ユーザであること' do
        get :edit, params: { id: @user.to_param }
        expect(assigns(:user)).to eq(@user)
      end
    end

    describe 'PUT #update' do

      context 'パラメータが正しい場合' do
        let(:valid_attributes) {
          { id: @user.to_param, user: { name: "update_#{@user.name}" } }
        }

        before { patch :update, params: valid_attributes }

        it 'ユーザ情報が変更されること' do
          expect(User.find(@user.id).name).to eq("update_#{@user.name}")
        end

        it '一覧画面へリダイレクトされること' do
          expect(response).to redirect_to(root_url)
        end

        it 'メッセージが設定されること' do
          expect(flash[:notice]).to eq(
            I18n.t("shared.crud.update", target: "ユーザ update_#{@user.name}")
          )
        end
      end

      context 'パラメータが不正の場合' do
        render_views

        let(:invalid_attributes) {
          { id: @user.to_param,
            user: { name: "update_#{@user.name}", password: "z" }
          }
        }

        before { patch :update, params: invalid_attributes }

        it 'ユーザ情報が変更されない' do
          expect(User.find(@user.id).name).not_to eq("update_#{@user.name}")
        end

        it 'edit テンプレートが表示されること' do
          expect(response).to render_template :edit
        end

        it 'エラーメッセージが表示されること' do
          expect(response.body).to have_css('li.red-text')
        end
      end
    end
  end
end

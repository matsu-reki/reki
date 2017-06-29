require 'rails_helper'

RSpec.describe SessionsController, type: :controller do

  describe "Action" do
    describe "GET #new" do
      it "newテンプレートを描写する" do
        get :new
        expect(response).to render_template :new
      end
    end

    describe "POST #create" do
      let!(:user) { create(:user_admin) }

      describe 'ログイン成功' do

        subject {
          post :create, params: { session: { login: user.login, password: "password"} }
        }

        before { subject }

        it "current_user が作成されること" do
          expect(session[:current_user]).to eq(user.id)
        end

        it "ダッシュボードへリダイレクトされること" do
          expect(response).to redirect_to root_path
        end

        it "エラーメッセージが表示されないこと" do
          expect(flash[:alert]).to be_nil
        end
      end

      describe 'ログイン失敗' do
        subject do
          post :create, params: {
            session: { login: user.login, password: "invalid"}
          }
        end

        before { subject }

        it "current_user が空であること" do
          expect(session[:current_user]).to be_nil
        end

        it "ログイン画面にリダイレクトされること" do
          expect(response).to redirect_to new_session_path
        end

        it "エラーメッセージが表示されること" do
          expect(flash[:alert]).to eq(I18n.t("sessions.create.failure"))
        end
      end
    end

    describe "DELETE #destroy" do
      let!(:user) { create(:user_admin) }

      before do
        login(user)
      end

      subject { delete :destroy, params: { id: user.id } }

      it "current_user が空であること" do
        subject
        expect(session[:current_user]).to be_nil
      end

      it "ログイン画面にリダイレクトされること" do
        subject
        expect(response).to redirect_to new_session_path
      end
    end

  end
end

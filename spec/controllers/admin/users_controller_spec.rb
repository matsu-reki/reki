require "rails_helper"

RSpec.describe Admin::UsersController, type: :controller do

  describe "Action" do

    before do
      @user_1 = create(:user_admin)
      users = create_list :user_standard, 101
      login @user_1
    end

    describe "GET #index" do
      it "edit テンプレートが表示されること" do
        get :index
        expect(response).to render_template :index
      end

      it "一覧に表示する最大件数が100件であること" do
        get :index
        expect(assigns(:users).size).to eq(100)
      end
    end

    describe "GET # new" do
      it "edit テンプレートが表示されること" do
        get :new
        expect(response).to render_template :new
      end

      it "User のインスタンスが新規作成されること" do
        get :new
        expect(assigns(:user)).to be_a_new(User)
      end
    end

    describe "GET #edit" do
      it "edit テンプレートが表示されること" do
        get :edit, params: { id: @user_1.to_param }
        expect(response).to render_template :edit
      end

      it "User のインスタンスが管理者ユーザであること" do
        get :edit, params: { id: @user_1.to_param }
        expect(assigns(:user)).to eq(@user_1)
      end
    end

    describe "POST #create" do
      let(:valid_attributes) {
        { user: attributes_for(:user_admin) }
      }
      let(:invalid_attributes) {
        attr = { user: attributes_for(:user_admin) }
        attr[:user][:password]  = "X"
        return attr
     }

      context "パラメータが正しい場合" do

        subject { post :create, params: valid_attributes }

        it "管理者ユーザが作成されること" do
          expect { subject }.to change(User, :count).by(1)
        end

        it "登録内容が正しいこと" do
          subject
          user = User.last
          expect(valid_attributes[:user][:login]).to eq(user.login)
          expect(valid_attributes[:user][:name]).to eq(user.name)
          expect(valid_attributes[:user][:email]).to eq(user.email)
        end

        it "一覧画面へリダイレクトされること" do
          subject
          expect(response).to redirect_to(admin_users_url)
        end
      end

      context "パラメータが不正の場合" do
        render_views

        before { post :create, params: invalid_attributes }

        it "new テンプレートが表示されること" do
          expect(response).to render_template :new
        end

        it "ユーザが作成されないこと" do
          expect { subject }.to change(User.admin, :count).by(0)
        end

        it "エラーメッセージが表示されること" do
          expect(response.body).to have_css("li.red-text")
        end
      end
    end

    describe "PUT #update" do
      context "パラメータが正しい場合" do
        let(:valid_attributes) {
          { id: @user_1.to_param, user: { name: "update_#{@user_1.name}" } }
        }

        before { patch :update, params: valid_attributes }

        it "ユーザ情報が変更されること" do
          expect(User.find(@user_1.id).name).to eq("update_#{@user_1.name}")
        end

        it "一覧画面へリダイレクトされること" do
          expect(response).to redirect_to(admin_users_url)
        end

        it "メッセージが設定されること" do
          expect(flash[:notice]).to eq(
            I18n.t("shared.crud.update", target: "ユーザ update_#{@user_1.name}")
          )
        end
      end

      context "パラメータが不正の場合" do
        render_views

        let(:invalid_attributes) {
          { id: @user_1.to_param,
            user: { name: "update_#{@user_1.name}", password: "z" }
          }
        }

        before { patch :update, params: invalid_attributes }

        it "ユーザ情報が変更されない" do
          expect(User.find(@user_1.id).name).not_to eq("update_#{@user_1.name}")
        end

        it "edit テンプレートが表示されること" do
          expect(response).to render_template :edit
        end

        it "エラーメッセージが表示されること" do
          expect(response.body).to have_css("li.red-text")
        end
      end
    end

    describe 'DELETE #destroy' do
      before do
        @user_2 = create(:user_admin)
      end

      context "削除可能なユーザ" do
        subject { delete :destroy, params: {:id => @user_2.to_param} }

        it '指定したユーザが削除できること' do
          expect { subject }.to change(User, :count).by(-1)
        end

        it "一覧画面へリダイレクトされること" do
          subject
          expect(response).to redirect_to(admin_users_url)
        end
      end

      context "削除不可能なユーザ" do
        it 'ログイン中のユーザは削除できないこと' do
          expect {
            delete :destroy, params: {:id => @user_1.to_param}
          }.to change(User, :count).by(0)
        end
      end
    end
  end
end

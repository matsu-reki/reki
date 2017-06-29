require 'rails_helper'

RSpec.describe Admin::LicensesController, type: :controller do
  describe "Action" do
    before do
      @user = create(:user_admin)
      login @user

      @licenses = create_list :license, 15
      @license = @licenses.first
    end

    describe "GET #index" do
      it "edit テンプレートが表示されること" do
        get :index
        expect(response).to render_template :index
      end

      it "一覧に表示する最大件数が15件であること" do
        get :index
        expect(assigns(:licenses).size).to eq(15)
      end
    end

    describe "GET # new" do
      it "edit テンプレートが表示されること" do
        get :new
        expect(response).to render_template :new
      end

      it "License のインスタンスが新規作成されること" do
        get :new
        expect(assigns(:license)).to be_a_new(License)
      end
    end

    describe "GET #edit" do
      it "edit テンプレートが表示されること" do
        get :edit, params: { id: @license.to_param }
        expect(response).to render_template :edit
      end

      it "License のインスタンスが管理者タグであること" do
        get :edit, params: { id: @license.to_param }
        expect(assigns(:license)).to eq(@license)
      end
    end

    describe "POST #create" do
      let(:valid_attributes) {
        { license: attributes_for(:license) }
      }

      let(:invalid_attributes) {
        attr = { license: attributes_for(:license) }
        attr[:license][:name]  = ""
        attr
     }

      context "パラメータが正しい場合" do
        subject { post :create, params: valid_attributes }

        it "タグが作成されること" do
          expect { subject }.to change(License, :count).by(1)
        end

        it "登録内容が正しいこと" do
          subject
          license = License.order(updated_at: :desc).first
          expect(license.name).to eq(valid_attributes[:license][:name])
        end

        it "一覧画面へリダイレクトされること" do
          subject
          expect(response).to redirect_to(admin_licenses_url)
        end
      end

      context "パラメータが不正の場合" do
        render_views

        before { post :create, params: invalid_attributes }

        it "new テンプレートが表示されること" do
          expect(response).to render_template :new
        end

        it "タグが作成されないこと" do
          expect { subject }.to change(License, :count).by(0)
        end

        it "エラーメッセージが表示されること" do
          expect(response.body).to have_css("li.red-text")
        end
      end
    end

    describe "PUT #update" do
      context "パラメータが正しい場合" do
        let(:valid_attributes) {
          { id: @license.to_param, license: { name: "update_#{@license.name}" } }
        }

        before { patch :update, params: valid_attributes }

        it "タグ情報が変更されること" do
          expect(License.find(@license.id).name).to eq("update_#{@license.name}")
        end

        it "一覧画面へリダイレクトされること" do
          expect(response).to redirect_to(admin_licenses_url)
        end

        it "メッセージが設定されること" do
          expect(flash[:notice]).to eq(
            I18n.t("shared.crud.update", target: "ライセンス update_#{@license.name}")
          )
        end
      end

      context "パラメータが不正の場合" do
        render_views

        let(:invalid_attributes) {
          { id: @license.to_param,
            license: { name: "" }
          }
        }

        before { patch :update, params: invalid_attributes }

        it "タグ情報が変更されない" do
          expect(License.find(@license.id).name).to eq(@license.name)
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
      context "削除可能なタグ" do
        subject { delete :destroy, params: {:id => @license.to_param} }

        it '指定したタグが削除できること' do
          expect { subject }.to change(License, :count).by(-1)
        end

        it "一覧画面へリダイレクトされること" do
          subject
          expect(response).to redirect_to(admin_licenses_url)
        end
      end

      context "削除不可能なタグ" do
        pending "TODO: 資料を持つタグを削除できないことを確認"
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Admin::TagsController, type: :controller do
  describe "Action" do

    before do
      @user = create(:user_admin)
      login @user

      @tags = create_list :tag, 15
      @tag = @tags.first
    end

    describe "GET #index" do
      it "edit テンプレートが表示されること" do
        get :index
        expect(response).to render_template :index
      end

      it "一覧に表示する最大件数が15件であること" do
        get :index
        expect(assigns(:tags).size).to eq(15)
      end
    end

    describe "GET # new" do
      it "edit テンプレートが表示されること" do
        get :new
        expect(response).to render_template :new
      end

      it "Tag のインスタンスが新規作成されること" do
        get :new
        expect(assigns(:tag)).to be_a_new(Tag)
      end
    end

    describe "GET #edit" do
      it "edit テンプレートが表示されること" do
        get :edit, params: { id: @tag.to_param }
        expect(response).to render_template :edit
      end

      it "Tag のインスタンスが管理者タグであること" do
        get :edit, params: { id: @tag.to_param }
        expect(assigns(:tag)).to eq(@tag)
      end
    end

    describe "POST #create" do
      let(:valid_attributes) {
        { tag: attributes_for(:tag) }
      }

      let(:invalid_attributes) {
        attr = { tag: attributes_for(:tag) }
        attr[:tag][:name]  = ""
        attr
     }

      context "パラメータが正しい場合" do
        subject { post :create, params: valid_attributes }

        it "タグが作成されること" do
          expect { subject }.to change(Tag, :count).by(1)
        end

        it "登録内容が正しいこと" do
          subject
          tag = Tag.order(updated_at: :desc).first
          expect(tag.name).to eq(valid_attributes[:tag][:name])
        end

        it "一覧画面へリダイレクトされること" do
          subject
          expect(response).to redirect_to(admin_tags_url)
        end
      end

      context "パラメータが不正の場合" do
        render_views

        before { post :create, params: invalid_attributes }

        it "new テンプレートが表示されること" do
          expect(response).to render_template :new
        end

        it "タグが作成されないこと" do
          expect { subject }.to change(Tag, :count).by(0)
        end

        it "エラーメッセージが表示されること" do
          expect(response.body).to have_css("li.red-text")
        end
      end
    end

    describe "PUT #update" do
      context "パラメータが正しい場合" do
        let(:valid_attributes) {
          { id: @tag.to_param, tag: { name: "update_#{@tag.name}" } }
        }

        before { patch :update, params: valid_attributes }

        it "タグ情報が変更されること" do
          expect(Tag.find(@tag.id).name).to eq("update_#{@tag.name}")
        end

        it "一覧画面へリダイレクトされること" do
          expect(response).to redirect_to(admin_tags_url)
        end

        it "メッセージが設定されること" do
          expect(flash[:notice]).to eq(
            I18n.t("shared.crud.update", target: "タグ update_#{@tag.name}")
          )
        end
      end

      context "パラメータが不正の場合" do
        render_views

        let(:invalid_attributes) {
          { id: @tag.to_param,
            tag: { name: "" }
          }
        }

        before { patch :update, params: invalid_attributes }

        it "タグ情報が変更されない" do
          expect(Tag.find(@tag.id).name).to eq(@tag.name)
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
        subject { delete :destroy, params: {:id => @tag.to_param} }

        it '指定したタグが削除できること' do
          expect { subject }.to change(Tag, :count).by(-1)
        end

        it "一覧画面へリダイレクトされること" do
          subject
          expect(response).to redirect_to(admin_tags_url)
        end
      end

      context "削除不可能なタグ" do
        pending "TODO: 資料を持つタグを削除できないことを確認"
      end
    end
  end
end

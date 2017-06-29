require 'rails_helper'

RSpec.describe Admin::CategoriesController, type: :controller do
  describe "Action" do

    before do
      @user = create(:user_admin)
      login @user

      @categories = create_list :category, 15
      @category = @categories.first
    end

    describe "GET #index" do
      it "edit テンプレートが表示されること" do
        get :index
        expect(response).to render_template :index
      end

      it "一覧に表示する最大件数が15件であること" do
        get :index
        expect(assigns(:categories).size).to eq(15)
      end
    end

    describe "GET # new" do
      it "edit テンプレートが表示されること" do
        get :new
        expect(response).to render_template :new
      end

      it "Category のインスタンスが新規作成されること" do
        get :new
        expect(assigns(:category)).to be_a_new(Category)
      end
    end

    describe "GET #edit" do
      it "edit テンプレートが表示されること" do
        get :edit, params: { id: @category.to_param }
        expect(response).to render_template :edit
      end

      it "Category のインスタンスが管理者分類であること" do
        get :edit, params: { id: @category.to_param }
        expect(assigns(:category)).to eq(@category)
      end
    end

    describe "POST #create" do
      let(:valid_attributes) {
        { category: attributes_for(:category) }
      }
      let(:invalid_attributes) {
        attr = { category: attributes_for(:category) }
        attr[:category][:code]  = "X"
        return attr
     }

      context "パラメータが正しい場合" do
        subject { post :create, params: valid_attributes }

        it "分類が作成されること" do
          expect { subject }.to change(Category, :count).by(1)
        end

        it "登録内容が正しいこと" do
          subject
          category = Category.order(updated_at: :desc).first
          expect(category.code).to eq(valid_attributes[:category][:code])
          expect(category.name).to eq(valid_attributes[:category][:name])
        end

        it "一覧画面へリダイレクトされること" do
          subject
          expect(response).to redirect_to(admin_categories_url)
        end
      end

      context "パラメータが不正の場合" do
        render_views

        before { post :create, params: invalid_attributes }

        it "new テンプレートが表示されること" do
          expect(response).to render_template :new
        end

        it "分類が作成されないこと" do
          expect { subject }.to change(Category, :count).by(0)
        end

        it "エラーメッセージが表示されること" do
          expect(response.body).to have_css("li.red-text")
        end
      end
    end

    describe "PUT #update" do
      context "パラメータが正しい場合" do
        let(:valid_attributes) {
          { id: @category.to_param, category: { name: "update_#{@category.name}" } }
        }

        before { patch :update, params: valid_attributes }

        it "分類情報が変更されること" do
          expect(Category.find(@category.id).name).to eq("update_#{@category.name}")
        end

        it "一覧画面へリダイレクトされること" do
          expect(response).to redirect_to(admin_categories_url)
        end

        it "メッセージが設定されること" do
          expect(flash[:notice]).to eq(
            I18n.t("shared.crud.update", target: "分類 update_#{@category.name}")
          )
        end
      end

      context "パラメータが不正の場合" do
        render_views

        let(:invalid_attributes) {
          { id: @category.to_param,
            category: { name: "update_#{@category.name}", code: "z" }
          }
        }

        before { patch :update, params: invalid_attributes }

        it "分類情報が変更されない" do
          expect(Category.find(@category.id).name).not_to eq("update_#{@category.name}")
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
      context "削除可能な分類" do
        subject { delete :destroy, params: {:id => @category.to_param} }

        it '指定した分類が削除できること' do
          expect { subject }.to change(Category, :count).by(-1)
        end

        it "一覧画面へリダイレクトされること" do
          subject
          expect(response).to redirect_to(admin_categories_url)
        end
      end

      context "削除不可能な分類" do
        pending "TODO: 資料を持つ分類を削除できないことを確認"
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Archive, type: :model do

  describe "Validation" do
    it { is_expected.to validate_presence_of(:author) }
    it { is_expected.to validate_length_of(:author).is_at_most(100) }
    it { is_expected.to validate_presence_of(:category_id) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_numericality_of(:latitude) }
    it { is_expected.to validate_numericality_of(:longitude) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(100) }
    it { is_expected.to validate_presence_of(:owner) }
    it { is_expected.to validate_length_of(:owner).is_at_most(100) }

    describe "validate_tags" do
      before do
        @category = create(:category)
        create :tag_black_list, name: "禁止用語"
      end

      it "タグに禁止用語が指定できないこと" do
        archive = build(:archive, category: @category)
        archive.tag_labels = "タグ名,禁止用語"
        archive.valid?
        expect(archive.errors[:base]).to eq(
          ["#{I18n.t("activerecord.attributes.tag.name")}#{I18n.t("activerecord.errors.models.tag.attributes.name.black_list")}"]
        )
      end

      it "上限以上のタグが設定できないこと" do
        archive = build(:archive, category: @category)
        tag_labels = []
        11.times { |n| tag_labels << "タグ名#{n}" }
        archive.tag_labels = tag_labels.join(",")
        archive.valid?
        expect(archive.errors[:tag_labels]).to eq(
          [I18n.t("activerecord.errors.models.archive.attributes.tag_labels.less_than_or_equal_to", count: 10)]
        )
      end
    end

    describe "#chart" do
      context '子ノード(B)が2つの子ノード(C,D)を持つ場合' do
        before do
          @tag1 = create(:tag)
          @tag2 = create(:tag)
          @tag3 = create(:tag)
          @category = create(:category)
          @archive_a = create(:archive, name: 'A', category: @category)
          @archive_b = create(:archive, name: 'B', category: @category)
          @archive_c = create(:archive, name: 'C', category: @category)
          @archive_d = create(:archive, name: 'D', category: @category)
          create(:archive_tag, archive: @archive_a, tag: @tag1)
          create(:archive_tag, archive: @archive_b, tag: @tag1)
          create(:archive_tag, archive: @archive_b, tag: @tag2)
          create(:archive_tag, archive: @archive_b, tag: @tag3)
          create(:archive_tag, archive: @archive_c, tag: @tag2)
          create(:archive_tag, archive: @archive_d, tag: @tag3)
        end
        it 'ノードが4件作成されること' do
          data = @archive_a.chart
          expect(data[:nodes].sort{|a, b| a[:id] <=> b[:id] }).to eq [
            { id: 0, archive_id: @archive_a.id, label: @archive_a.name, file: @archive_a.represent_image.url },
            { id: 1, archive_id: @archive_b.id, label: @archive_b.name, file: @archive_b.represent_image.url },
            { id: 2, archive_id: @archive_c.id, label: @archive_c.name, file: @archive_c.represent_image.url },
            { id: 3, archive_id: @archive_d.id, label: @archive_d.name, file: @archive_d.represent_image.url }
          ]
        end
        it 'A-B, B-C, B-Dのように、3つのリンクが作成されること)' do
          data = @archive_a.chart
          expect(data[:links]).to eq [
            { source: 0, target: 1, target_archive_id: @archive_b.id, distance: 1 },
            { source: 1, target: 2, target_archive_id: @archive_c.id, distance: 2 },
            { source: 1, target: 3, target_archive_id: @archive_d.id, distance: 2 }
          ]
        end
      end

      context '子ノード(B)が親ノード(A)と共通のタグが2件以上ある場合' do
        before do
          @tag1 = create(:tag)
          @tag2 = create(:tag)
          @category = create(:category)
          @archive_a = create(:archive, name: 'A', category: @category)
          @archive_b = create(:archive, name: 'B', category: @category)
          create(:archive_tag, archive: @archive_a, tag: @tag1)
          create(:archive_tag, archive: @archive_a, tag: @tag2)
          create(:archive_tag, archive: @archive_b, tag: @tag1)
          create(:archive_tag, archive: @archive_b, tag: @tag2)
        end
        it 'ノードが2件作成されること' do
          data = @archive_a.chart
          expect(data[:nodes]).to eq [
            { id: 0, archive_id: @archive_a.id, label: @archive_a.name, file: @archive_a.represent_image.url },
            { id: 1, archive_id: @archive_b.id, label: @archive_b.name, file: @archive_b.represent_image.url }
          ]
        end
        it 'A-Bのように、リンクは1つしか作られないこと(A-B, A-Bのように1つの親は同じ子は複数持たず、重複削除すること)' do
          data = @archive_a.chart
          expect(data[:links]).to eq [
            { source: 0, target: 1, target_archive_id: @archive_b.id, distance: 1 }
          ]
        end
      end
      context '子ノード2つとルートノードに共通のタグがある場合' do
        before do
          @tag1 = create(:tag)
          @category = create(:category)
          @archive_a = create(:archive, name: 'A', category: @category)
          @archive_b = create(:archive, name: 'B', category: @category)
          @archive_c = create(:archive, name: 'C', category: @category)
          create(:archive_tag, archive: @archive_a, tag: @tag1)
          create(:archive_tag, archive: @archive_b, tag: @tag1)
          create(:archive_tag, archive: @archive_c, tag: @tag1)
        end
        it 'ノードが3件作成されること' do
          data = @archive_a.chart
          expect(data[:nodes].sort{|a, b| a[:id] <=> b[:id] }).to eq [
            { id: 0, archive_id: @archive_a.id, label: @archive_a.name, file: @archive_a.represent_image.url },
            { id: 1, archive_id: @archive_b.id, label: @archive_b.name, file: @archive_b.represent_image.url },
            { id: 2, archive_id: @archive_c.id, label: @archive_c.name, file: @archive_c.represent_image.url }
          ]
        end
        it 'A-B, A-Cのように、2方向にリンクが作成されること' do
          data = @archive_a.chart
          expect(data[:links]).to eq [
            { source: 0, target: 1, target_archive_id: @archive_b.id, distance: 1 },
            { source: 0, target: 2, target_archive_id: @archive_c.id, distance: 1 }
          ]
        end
      end

      context '子ノード3つとルートノードに共通のタグがある場合' do
        before do
          @tag1 = create(:tag)
          @tag2 = create(:tag)
          @tag3 = create(:tag)
          @tag4 = create(:tag)

          @category = create(:category)
          @archive_a = create(:archive, name: 'A', category: @category)
          @archive_b = create(:archive, name: 'B', category: @category)
          @archive_c = create(:archive, name: 'C', category: @category)
          @archive_d = create(:archive, name: 'D', category: @category)
          @archive_e = create(:archive, name: 'E', category: @category)
          @archive_f = create(:archive, name: 'F', category: @category)


          create(:archive_tag, archive: @archive_a, tag: @tag1)
          create(:archive_tag, archive: @archive_a, tag: @tag2)
          create(:archive_tag, archive: @archive_b, tag: @tag1)
          create(:archive_tag, archive: @archive_b, tag: @tag3)
          create(:archive_tag, archive: @archive_c, tag: @tag1)
          create(:archive_tag, archive: @archive_c, tag: @tag4)
          create(:archive_tag, archive: @archive_d, tag: @tag2)
          create(:archive_tag, archive: @archive_e, tag: @tag3)
          create(:archive_tag, archive: @archive_f, tag: @tag4)

          @data = @archive_a.chart
        end
        #
        it 'ノードが5件作成されること' do
          expect(@data[:nodes].sort{|a, b| a[:id] <=> b[:id] }).to eq [
            { id: 0, archive_id: @archive_a.id, label: @archive_a.name, file: @archive_a.represent_image.url },
            { id: 1, archive_id: @archive_b.id, label: @archive_b.name, file: @archive_b.represent_image.url },
            { id: 2, archive_id: @archive_c.id, label: @archive_c.name, file: @archive_c.represent_image.url },
            { id: 3, archive_id: @archive_d.id, label: @archive_d.name, file: @archive_d.represent_image.url },
            { id: 4, archive_id: @archive_e.id, label: @archive_e.name, file: @archive_e.represent_image.url },
            { id: 5, archive_id: @archive_f.id, label: @archive_f.name, file: @archive_f.represent_image.url }
          ]
        end
        it 'A-B-E, A-C-F, A-Dのように、3方向にリンクが作成されること' do
          expect(@data[:links]).to eq [
             { source: 0, target: 1, target_archive_id: @archive_b.id, distance: 1 },
             { source: 0, target: 2, target_archive_id: @archive_c.id, distance: 1 },
             { source: 0, target: 3, target_archive_id: @archive_d.id, distance: 1 },
             { source: 1, target: 4, target_archive_id: @archive_e.id, distance: 2 },
             { source: 2, target: 5, target_archive_id: @archive_f.id, distance: 2 }
          ]
        end
      end
    end

    require 'benchmark'

    context '親からの距離が100ある場合' do
      before do
        category = create(:category)
        root = create(:archive, name: 0, category: category)
        pre_archive = root
        (1..100).each do |n|
          archive = create(:archive, name: n, category: category)
          tag = create(:tag)
          create(:archive_tag, archive: pre_archive, tag: tag)
          create(:archive_tag, archive: archive, tag: tag)
          pre_archive = archive
        end
        result = Benchmark.realtime do
          @data = root.chart
        end
        puts "処理速度 #{result}s"
      end
      it 'ノードが101件、リンクが100件作成されること' do
        expect(@data[:nodes].size).to eq 101
        expect(@data[:links].size).to eq 100
      end
    end
    context '親からの距離が101ある場合' do
      before do
        category = create(:category)
        root = create(:archive, name: 0, category: category)
        pre_archive = root
        (1..101).each do |n|
          archive = create(:archive, name: n, category: category)
          tag = create(:tag)
          create(:archive_tag, archive: pre_archive, tag: tag)
          create(:archive_tag, archive: archive, tag: tag)
          pre_archive = archive
        end
        result = Benchmark.realtime do
          @data = root.chart
        end
        puts "処理速度 #{result}s"
      end
      it 'ノードが101件、リンクが100件作成されること' do
        expect(@data[:nodes].size).to eq 101
        expect(@data[:links].size).to eq 100
      end
    end

  end
end

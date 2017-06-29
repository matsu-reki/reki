#
# 初期データ投入
#

require 'factory_girl'
Dir[Rails.root.join('spec', 'support', 'factories', '*.rb')].each {|f| require f }

Archive.delete_all
ArchiveAsset.delete_all
ArchiveTag.delete_all
User.delete_all
Category.delete_all
License.delete_all
Tag.delete_all

ActiveRecord::Base.connection.reset_pk_sequence!('archives')
ActiveRecord::Base.connection.reset_pk_sequence!('archive_assets')
ActiveRecord::Base.connection.reset_pk_sequence!('archive_tags')
ActiveRecord::Base.connection.reset_pk_sequence!('users')
ActiveRecord::Base.connection.reset_pk_sequence!('categories')
ActiveRecord::Base.connection.reset_pk_sequence!('licenses')
ActiveRecord::Base.connection.reset_pk_sequence!('tags')

FactoryGirl.create(:user_admin, login: 'admin')
FactoryGirl.create(:user_standard, login: 'standard')

categories = []
[ "文献", "図像", "考古", "民俗"].each do |name|
  categories << FactoryGirl.create(:category, name: name)
end

license = FactoryGirl.create(:license, code: 1,
  name: "Creative Commons BY 4.0",
  content: "http://creativecommons.org/licenses/by/4.0/legalcode.ja",
  content_type: 'url'
)
lonlats = [
    [133.049498, 35.475482],
    [133.047398, 35.476482],
    [133.049598, 35.477482],
    [133.049298, 35.478482],
    [133.049698, 35.479482],
    [133.049198, 35.473482],
    [133.049798, 35.472482],
    [133.049098, 35.471482],
    [133.049898, 35.470482],
    [133.049998, 35.474482],
]
5.times do
  (1..10).each do |n|
    represent_image  = File.new(Rails.root.join("spec", "factories", "images", "#{n}.jpg"))
    image_1  = File.new(Rails.root.join("spec", "factories", "images", "#{n}-1.jpg"))
    image_2  = File.new(Rails.root.join("spec", "factories", "images", "#{n}-2.jpg"))

    lon, lat = lonlats.sample

    archive = FactoryGirl.create(:archive,
      category_id: categories.sample.id,
      license_id: license.id,
      represent_image: represent_image,
      tag_labels: "松江の写真",
      longitude: lon,
      latitude: lat
    )
    FactoryGirl.create :archive_asset, archive_id: archive.id, image: image_1
    FactoryGirl.create :archive_asset, archive_id: archive.id, image: image_2
  end
end

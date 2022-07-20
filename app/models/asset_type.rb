class AssetType < ApplicationRecord
  has_many :assets

  rails_admin do
    configure :assets do
      hide
    end
  end
end

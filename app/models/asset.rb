class Asset < ApplicationRecord
  belongs_to :asset_type
  has_many :trades
  has_many :events

  rails_admin do
    list do
      fields :id, :code, :name, :cnpj, :paying_source_cnpj, :asset_type
    end
  end
end

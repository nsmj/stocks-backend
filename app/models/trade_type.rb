class TradeType < ApplicationRecord
  has_many :trades
  has_many :irrfs

  rails_admin do
    configure :trades do
      hide
    end
  end
end

class TradeType < ApplicationRecord
  has_many :trades

  rails_admin do
    configure :trades do
      hide
    end
  end
end

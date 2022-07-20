class Trade < ApplicationRecord
  belongs_to :asset
  belongs_to :trade_type

  rails_admin do
    configure :date do
      strftime_format '%d/%m/%Y'
    end

    # FIXME: The purchase filed for some reason make the model not to be shown.
    # list do
    #  fields :id, :date, :quantity, :asset, :asset_type, :purchase
    # end
  end
end

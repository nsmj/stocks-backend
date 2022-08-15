class EndYearPosition < ApplicationRecord
  belongs_to :asset

  rails_admin do
    configure :average_price do
      pretty_value do
        value.round(2)
      end
    end

    configure :total_cost do
      pretty_value do
        value.round(2)
      end
    end
  end
end

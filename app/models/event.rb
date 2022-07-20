class Event < ApplicationRecord
  belongs_to :event_type
  belongs_to :asset

  rails_admin do
    configure :date do
      strftime_format '%d/%m/%Y'
    end
  end
end

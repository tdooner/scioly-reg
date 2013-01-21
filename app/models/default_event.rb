class DefaultEvent < ActiveRecord::Base
  scope :for_year, lambda { |year| where(:year => year) }
end

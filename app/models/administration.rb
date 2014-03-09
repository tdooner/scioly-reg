class Administration < ActiveRecord::Base
  belongs_to :user
  belongs_to :administrates, polymorphic: true
end

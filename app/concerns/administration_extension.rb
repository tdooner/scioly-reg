module AdministrationExtension
  extend ActiveSupport::Concern

  included do
    has_many :administrations, as: :administrates
    has_many :administrators, through: :administrations, source: :user
  end
end

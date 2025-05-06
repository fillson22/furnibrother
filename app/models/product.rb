class Product < ApplicationRecord

    belongs_to :user

    validates :name, :text, :user, presence: true

end

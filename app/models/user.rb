class User < ApplicationRecord

    has_many :products, dependent: :destroy

    validates :email, :username, presence: true
    validates :email, :username, uniqueness: true


end

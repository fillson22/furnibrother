require 'openssl'

class User < ApplicationRecord
    # параметри для шифрування паролів
    ITERATIONS = 20000
    DIGEST = OpenSSL::Digest::SHA256.new

    has_many :products, dependent: :destroy

    validates :email, :username, presence: true
    validates :email, :username, uniqueness: true

    attr_accessor :password
    validates :password, presence: true, length: { minimum: 6 }, on: :create
    validates :password, confirmation: true, on: :update, if: :password_required?
    
    before_save :encrypt_password

    def encrypt_password
        if password.present?
            self.password_salt = User.hash_to_string(OpenSSL::Random.random_bytes(16))
            self.password_hash = User.hash_to_string(
                OpenSSL::PKCS5.pbkdf2_hmac(self.password, self.password_salt, ITERATIONS, DIGEST.length, DIGEST))
        end
    end

    def self.hash_to_string(password_hash)
        password_hash.unpack('H*')[0]
    end

    def self.authenticate(email, password)
        user = find_by(email: email)
        if user.present? && user.password_hash == User.hash_to_string(
            OpenSSL::PKCS5.pbkdf2_hmac(password, user.password_salt, ITERATIONS, DIGEST.length, DIGEST))
            return user
        else
            return nil
        end
    end

end

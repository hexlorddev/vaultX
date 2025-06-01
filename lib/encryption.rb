require 'openssl'
require 'base64'
require 'bcrypt'

class VaultXEncryption
  ALGORITHM = 'AES-256-CBC'
  KEY_LENGTH = 32 # 256 bits
  SALT_LENGTH = 16
  ITERATIONS = 100000

  def self.generate_salt
    SecureRandom.hex(SALT_LENGTH)
  end

  def self.derive_key(password, salt)
    pkcs5_pbkdf2_hmac(password, salt, ITERATIONS, KEY_LENGTH, OpenSSL::Digest::SHA256.new)
  end

  def self.encrypt(plaintext, key)
    cipher = OpenSSL::Cipher.new(ALGORITHM)
    cipher.encrypt
    cipher.key = key
    iv = cipher.random_iv
    
    encrypted = cipher.update(plaintext)
    encrypted << cipher.final
    
    {
      iv: Base64.strict_encode64(iv),
      encrypted_data: Base64.strict_encode64(encrypted)
    }
  end

  def self.decrypt(encrypted_data, key, iv)
    cipher = OpenSSL::Cipher.new(ALGORITHM)
    cipher.decrypt
    cipher.key = key
    cipher.iv = Base64.strict_decode64(iv)
    
    decrypted = cipher.update(Base64.strict_decode64(encrypted_data))
    decrypted << cipher.final
    
    decrypted
  end

  def self.hash_master_password(password, salt)
    BCrypt::Password.create("#{password}#{salt}", cost: BCrypt::Engine::DEFAULT_COST)
  end

  def self.validate_master_password(password, salt, stored_hash)
    BCrypt::Password.new(stored_hash) == "#{password}#{salt}"
  end
end
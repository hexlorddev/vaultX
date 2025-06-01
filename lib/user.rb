require_relative 'encryption'
require_relative 'database'

class VaultXUser
  def self.register(username, password)
    # Generate salt
    salt = VaultXEncryption.generate_salt
    
    # Hash master password with salt
    password_hash = VaultXEncryption.hash_master_password(password, salt)
    
    # Store user in database
    db = VaultXDatabase.connect
    db.execute(
      'INSERT INTO users (username, password_hash, salt) VALUES (?, ?, ?)',
      [username, password_hash, salt]
    )
    
    db.last_insert_row_id
  end

  def self.authenticate(username, password)
    db = VaultXDatabase.connect
    user = db.execute(
      'SELECT id, password_hash, salt FROM users WHERE username = ?',
      [username]
    ).first
    
    return nil unless user
    
    user_id, stored_hash, salt = user
    
    if VaultXEncryption.validate_master_password(password, salt, stored_hash)
      user_id
    else
      nil
    end
  end

  def self.exists?(username)
    db = VaultXDatabase.connect
    !db.execute(
      'SELECT 1 FROM users WHERE username = ?',
      [username]
    ).empty?
  end
end
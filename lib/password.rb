require_relative 'encryption'
require_relative 'database'

class VaultXPassword
  def self.add(user_id, service, username, password, url = nil, notes = nil)
    # Generate encryption key using user's master password
    # In a real application, this key would be derived from the master password
    # For now, we'll use a placeholder key - this will be fixed when integrated with authentication
    
    # Generate a random IV
    iv = OpenSSL::Cipher.new('AES-256-CBC').random_iv
    
    # Encrypt the password
    encrypted_data = VaultXEncryption.encrypt(password, 'placeholder_key')
    
    # Store in database
    db = VaultXDatabase.connect
    db.execute(
      'INSERT INTO passwords (user_id, service, username, encrypted_password, iv, url, notes) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [user_id, service, username, encrypted_data[:encrypted_data], encrypted_data[:iv], url, notes]
    )
    
    db.last_insert_row_id
  end

  def self.get(user_id, password_id)
    db = VaultXDatabase.connect
    result = db.execute(
      'SELECT service, username, encrypted_password, iv, url, notes FROM passwords WHERE id = ? AND user_id = ?',
      [password_id, user_id]
    ).first
    
    return nil unless result
    
    service, username, encrypted_data, iv, url, notes = result
    
    # Decrypt the password
    # In a real application, this key would be derived from the master password
    decrypted_password = VaultXEncryption.decrypt(encrypted_data, 'placeholder_key', iv)
    
    {
      service: service,
      username: username,
      password: decrypted_password,
      url: url,
      notes: notes
    }
  end

  def self.list(user_id)
    db = VaultXDatabase.connect
    results = db.execute(
      'SELECT id, service, username FROM passwords WHERE user_id = ? ORDER BY service',
      [user_id]
    )
    
    results.map do |id, service, username|
      {
        id: id,
        service: service,
        username: username
      }
    end
  end

  def self.search(user_id, query)
    db = VaultXDatabase.connect
    results = db.execute(
      'SELECT id, service, username FROM passwords WHERE user_id = ? AND (service LIKE ? OR username LIKE ?) ORDER BY service',
      [user_id, "%#{query}%", "%#{query}%"]
    )
    
    results.map do |id, service, username|
      {
        id: id,
        service: service,
        username: username
      }
    end
  end
end
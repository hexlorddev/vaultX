require_relative '../lib/encryption'

puts "Testing AES-256-CBC Encryption Module"

# Test key derivation
puts "\n1. Testing key derivation..."
salt = VaultXEncryption.generate_salt
puts "Generated salt: #{salt}"
key = VaultXEncryption.derive_key("testpassword", salt)
puts "Derived key (length #{key.length} bytes): #{key.unpack1('H*')}"

# Test encryption/decryption
puts "\n2. Testing encryption/decryption..."
plaintext = "This is a test password! 1234567890"
puts "Plaintext: #{plaintext}"

encrypted = VaultXEncryption.encrypt(plaintext, key)
puts "Encrypted (IV: #{encrypted[:iv]}): #{encrypted[:encrypted_data]}"

decrypted = VaultXEncryption.decrypt(encrypted[:encrypted_data], key, encrypted[:iv])
puts "Decrypted: #{decrypted}"

# Test password hashing
puts "\n3. Testing password hashing..."
password = "masterpassword123"
hashed = VaultXEncryption.hash_master_password(password, salt)
puts "Hashed password: #{hashed}"

valid = VaultXEncryption.validate_master_password(password, salt, hashed)
puts "Password validation: #{valid ? 'Valid' : 'Invalid'}"

# Test with different password
valid = VaultXEncryption.validate_master_password("wrongpassword", salt, hashed)
puts "Wrong password validation: #{valid ? 'Valid' : 'Invalid'}"

puts "\nTest completed!"
require 'sqlite3'
require 'fileutils'

class VaultXDatabase
  DB_PATH = 'vaultx.db'
  
  def self.connect
    @db ||= SQLite3::Database.new(DB_PATH)
  end

  def self.setup
    # Create data directory if it doesn't exist
    Dir.mkdir('db') unless Dir.exist?('db')
    
    # Initialize database
    db = connect
    
    # Create tables
    schema_sql = File.read('db/schema.sql')
    db.execute_batch(schema_sql)
    
    puts "Database initialized successfully at #{DB_PATH}"
  end
end
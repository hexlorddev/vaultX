#!/usr/bin/env ruby

require 'tty-prompt'
require_relative '../lib/database'
require_relative '../lib/encryption'
require_relative '../lib/user'
require_relative '../lib/password'

class VaultXCLI
  def initialize
    @prompt = TTY::Prompt.new
    @current_user_id = nil
    @current_username = nil
  end

  def run
    VaultXDatabase.setup unless Dir.exist?('db')
    
    loop do
      if @current_user_id
        action = @prompt.select("Welcome #{@current_username}! What would you like to do?", [
          { name: 'Add New Credential', value: :add },
          { name: 'View Credentials', value: :view },
          { name: 'Search Credentials', value: :search },
          { name: 'Generate Password', value: :generate },
          { name: 'Logout', value: :logout },
          { name: 'Exit', value: :exit }
        ])
        
        case action
        when :add
          add_credential
        when :view
          view_credentials
        when :search
          search_credentials
        when :generate
          generate_password
        when :logout
          @current_user_id = nil
          @current_username = nil
        when :exit
          break
        end
      else
        action = @prompt.select("Welcome to VaultX! Please login or register", [
          { name: 'Login', value: :login },
          { name: 'Register', value: :register },
          { name: 'Exit', value: :exit }
        ])
        
        case action
        when :login
          login
        when :register
          register
        when :exit
          break
        end
      end
    end
  end

  private

  def register
    username = @prompt.ask('Enter username') { |q| q.validate(/\A[a-zA-Z0-9_]+\z/, 'Invalid username format') }
    return if username.nil?
    
    if VaultXUser.exists?(username)
      puts "Username #{username} already exists!"
      return
    end
    
    password = @prompt.mask('Enter master password') { |q| q.validate(:min_length, 12) }
    return if password.nil?
    
    confirm = @prompt.mask('Confirm master password')
    return if confirm.nil?
    
    if password != confirm
      puts "Passwords do not match!"
      return
    end
    
    user_id = VaultXUser.register(username, password)
    @current_user_id = user_id
    @current_username = username
    puts "Registration successful! Welcome #{@current_username}"
  end

  def login
    username = @prompt.ask('Enter username') { |q| q.validate(/\A[a-zA-Z0-9_]+\z/, 'Invalid username format') }
    return if username.nil?
    
    password = @prompt.mask('Enter master password')
    return if password.nil?
    
    user_id = VaultXUser.authenticate(username, password)
    
    if user_id
      @current_user_id = user_id
      @current_username = username
      puts "Login successful! Welcome #{@current_username}"
    else
      puts "Invalid username or password"
    end
  end

  def add_credential
    service = @prompt.ask('Service name (e.g., "GitHub")')
    return if service.nil?
    
    username = @prompt.ask('Username')
    return if username.nil?
    
    password = @prompt.mask('Password')
    return if password.nil?
    
    url = @prompt.ask('URL (optional)')
    notes = @prompt.ask('Notes (optional)')
    
    password_id = VaultXPassword.add(@current_user_id, service, username, password, url, notes)
    puts "Credential added successfully! (ID: #{password_id})"
  end

  def view_credentials
    credentials = VaultXPassword.list(@current_user_id)
    
    if credentials.empty?
      puts "No credentials found. Add some using the 'Add New Credential' option."
      return
    end
    
    credentials.each do |cred|
      puts "\n#{cred[:service]} (#{cred[:username]})"
      puts "ID: #{cred[:id]}"
    end
    
    selected_id = @prompt.ask('Enter ID to view details (or press Enter to go back)') { |q| q.required(false) }
    return if selected_id.nil? || selected_id.empty?
    
    credential = VaultXPassword.get(@current_user_id, selected_id)
    
    if credential
      puts "\nService: #{credential[:service]}"
      puts "Username: #{credential[:username]}"
      puts "Password: #{credential[:password]}"
      puts "URL: #{credential[:url]}" if credential[:url]
      puts "Notes: #{credential[:notes]}" if credential[:notes]
    else
      puts "Credential not found!"
    end
  end

  def search_credentials
    query = @prompt.ask('Enter search term')
    return if query.nil?
    
    results = VaultXPassword.search(@current_user_id, query)
    
    if results.empty?
      puts "No matching credentials found."
      return
    end
    
    puts "\nSearch Results:"
    results.each do |cred|
      puts "#{cred[:service]} (#{cred[:username]})"
      puts "ID: #{cred[:id]}"
    end
  end

  def generate_password
    length = @prompt.slider('Password length', min: 12, max: 64, default: 20)
    include_uppercase = @prompt.yes?('Include uppercase letters?')
    include_numbers = @prompt.yes?('Include numbers?')
    include_symbols = @prompt.yes?('Include special symbols?')
    
    password = generate_strong_password(length, include_uppercase, include_numbers, include_symbols)
    puts "\nGenerated password: #{password}"
    puts "\nRemember to save this in a secure place!"
  end

  def generate_strong_password(length, include_uppercase, include_numbers, include_symbols)
    chars = ('a'..'z').to_a
    chars += ('A'..'Z').to_a if include_uppercase
    chars += ('0'..'9').to_a if include_numbers
    chars += %w[! @ # $ % ^ & * ( ) - _ = + [ ] { } | ; : ' " , . < > / ?] if include_symbols
    
    password = ''
    length.times { password << chars.sample }
    password
  end
end

# Start the CLI application
VaultXCLI.new.run
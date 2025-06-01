require 'sinatra'
require 'sinatra/reloader' if development?
require 'securerandom'
require 'json'
require_relative '../lib/database'
require_relative '../lib/encryption'
require_relative '../lib/user'
require_relative '../lib/password'

class VaultXWeb < Sinatra::Base
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
  set :public_folder, 'web/public'
  set :views, 'web/views'

  # Before filters
  before do
    @current_user = session[:user]
  end

  # Routes
  get '/' do
    if @current_user
      redirect '/dashboard'
    else
      erb :index
    end
  end

  get '/login' do
    erb :login
  end

  post '/login' do
    username = params[:username]
    password = params[:password]
    
    user_id = VaultXUser.authenticate(username, password)
    
    if user_id
      session[:user] = { id: user_id, username: username }
      redirect '/dashboard'
    else
      @error = "Invalid username or password"
      erb :login
    end
  end

  get '/register' do
    erb :register
  end

  post '/register' do
    username = params[:username]
    password = params[:password]
    confirm = params[:confirm]
    
    if username.empty? || password.empty?
      @error = "Username and password cannot be empty"
      erb :register
      return
    end
    
    if VaultXUser.exists?(username)
      @error = "Username #{username} already exists"
      erb :register
      return
    end
    
    if password != confirm
      @error = "Passwords do not match"
      erb :register
      return
    end
    
    user_id = VaultXUser.register(username, password)
    session[:user] = { id: user_id, username: username }
    redirect '/dashboard'
  end

  get '/dashboard' do
    require_login
    @credentials = VaultXPassword.list(session[:user][:id])
    erb :dashboard
  end

  get '/search' do
    require_login
    query = params[:q]
    @credentials = VaultXPassword.search(session[:user][:id], query)
    erb :search_results
  end

  get '/credential/:id' do
    require_login
    credential = VaultXPassword.get(session[:user][:id], params[:id])
    if credential
      content_type :json
      { success: true, credential: credential }.to_json
    else
      { success: false, error: "Credential not found" }.to_json
    end
  end

  post '/add' do
    require_login
    service = params[:service]
    username = params[:username]
    password = params[:password]
    url = params[:url]
    notes = params[:notes]
    
    password_id = VaultXPassword.add(session[:user][:id], service, username, password, url, notes)
    { success: true, id: password_id }.to_json
  end

  get '/logout' do
    session.clear
    redirect '/'
  end

  # API for password generation
  get '/generate-password' do
    require_login
    length = params[:length].to_i
    include_uppercase = params[:include_uppercase] == 'true'
    include_numbers = params[:include_numbers] == 'true'
    include_symbols = params[:include_symbols] == 'true'
    
    password = generate_strong_password(length, include_uppercase, include_numbers, include_symbols)
    { password: password }.to_json
  end

  private

  def require_login
    unless @current_user
      session[:return_to] = request.path
      redirect '/login'
    end
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
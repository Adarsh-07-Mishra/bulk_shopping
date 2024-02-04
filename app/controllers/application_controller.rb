class ApplicationController < ActionController::API
  # before_action :authentication
  SECRET = 'yoursecretword'

  def authentication
    decode_data = decode_account_data(request.headers['token'])
    account_data = decode_data[0]['account_data'] if decode_data
    @current_account = Account.find_by(id: account_data)
    
    return true if @current_account

    render json: { message: 'invalid credentials' }
  end

  def encode_account_data(payload)
    JWT.encode payload, SECRET, 'HS256'
  end

  def decode_account_data(token)
    JWT.decode token, SECRET, true, { algorithm: 'HS256' }
  rescue StandardError => e
    puts e
  end
end

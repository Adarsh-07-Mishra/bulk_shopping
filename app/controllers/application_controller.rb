class ApplicationController < ActionController::Base
  include ::ActionView::Layouts
  include ::ActionController::Cookies
  protect_from_forgery
  SECRET = "yoursecretword".freeze

  def authentication
    decode_data = decode_account_data(request.headers["token"])
    @account_data = decode_data[0]["account_data"] if decode_data.is_a?(Array)
    return true if Account.find_by(id: @account_data).present?

    render json: { message: "invalid credentials" }
  end

  def encode_account_data(payload)
    JWT.encode(payload, SECRET, "HS256")
  end

  def decode_account_data(token)
    JWT.decode(token, SECRET, true, { algorithm: "HS256" })
  rescue JWT::DecodeError => e
    Rails.logger.debug e
  end

  def serialize_params
    { params: { host: request.base_url } }
  end
end

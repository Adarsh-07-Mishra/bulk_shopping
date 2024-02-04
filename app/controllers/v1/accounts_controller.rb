class V1::AccountsController < ApplicationController
  before_action :authentication, only: [:login]

  def signup
    account = Account.new(mobile_number: params[:mobile_number], password_digest: params[:password])
    if account.save
      success_response(account)
    else
      error_response(account)
    end
  end

  def login
    account = Account.find(mobile_number: params[:mobile_number])
  rescue StandardError
    not_found
  end

  private

  def success_response(data)
    render json: V1::AccountSerializer.new(data).attributes, status: :ok
  end

  def error_response(data)
    render json: { errors: data.errors.full_maessages }, status: :unprocessable_entity
  end

  def not_found
    render json: { message: 'Record Not Found' }, status: :not_found
  end
end

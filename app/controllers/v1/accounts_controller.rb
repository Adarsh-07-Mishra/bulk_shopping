class V1::AccountsController < ApplicationController
  before_action :authentication, only: [:update, change_password]
  before_action :get_account, only: [:login, :forgot_password]
  before_action :find_token, only: [:otp_verify, :resend_otp, :account_verify]

  def signup
    @account = Account.new(account_params)
    if @account.save
      send_otp
    else
      error_response(@account)
    end
  end

  def login
    if @account.authenticate(params[:password])
      render json: { message: "Successfully Login" }
    else
      render json: { errors: "invalid password" }, status: :unauthorized
    end
  end

  def otp_verify
    otp_id = @decode_data[0]['id']
    otp = SmsOtp.find(otp_id)
    if otp.pin == params[:pin] && otp.valid_until > Time.current
      account = Account.find_by(mobile_number: otp.mobile_number)
      return not_found if account.blank?

      account.update(is_otp_verify: true)
      render json: { token: encode(account.id), account: account }, status: :ok
    else
      render json: { message: 'Please enter valid pin' }, status: :unprocessable_entity
    end
  rescue StandardError
    not_found
  end

  def forgot_password
    send_otp
  end

  def resend_otp
    otp_id = @decode_account[0]['id']
    @account = SmsOtp.find(otp_id)
    send_otp
  rescue StandardError
    not_found
  end

  def account_verify
    account_id = @decode_account[0]['account_data']
    @account = Account.find(account_id)
    return render json: { errors: confirm_password } unless confirm_password.nil?

    update_password
  rescue StandardError
    not_found
  end

  def change_password
    return render json: { errors: confirm_password } unless confirm_password.nil?

    if @account.authenticate(params[:old_password])
      update_password
    else
      invalid_password_error
    end
  end

  def update
    if @account.authenticate(params[:account][:password])
      if @account.update(update_params)
        render json: V1::AccountSerializer.new(@account, serialize_params).serializable_hash,
               status: :ok
      else
        error_response(@account)
      end
    else
      invalid_password_error
    end
  end

  private

  def account_params
    params.require(:account).permit(:mobile_number, :password_digest, :password_confirmation)
  end

  def update_params
    params.require(:account).permit(:full_name, :mobile_number, :age, :gender, :dob, :city, :address, :pincode, :profile_pic)
  end

  def encode(id)
    encode_account_data({ account_data: id })
  end

  def success_response(data)
    render json: V1::AccountSerializer.new(data, serialize_params).serializable_hash, status: :ok
  end

  def error_response(data)
    render json: { errors: data.errors.full_messages }, status: :unprocessable_entity
  end

  def not_found
    render json: { message: 'Record Not Found' }, status: :not_found
  end

  def get_account
    @account = Account.find_by(mobile_number: params[:mobile_number])
    return not_found unless @account.present?
  end

  def send_otp
    @otp = SmsOtp.create(mobile_number: @account.mobile_number) if @account.present?
    render json: { token: encode_account_data({ id: @otp.id, model: @otp.class.to_s }), pin: @otp.pin, account: @account,
                   message: "OTP Send Successfully" }, status: :ok
  end

  def find_token
    @decode_data = decode_account_data(request.headers['token'])
    return @decode_data if @decode_data.is_a?(Array)

    render json: { message: "Invalid Token" }, status: :unprocessable_entity
  end

  def confirm_password
    return 'You can not enter old password again' if @account.authenticate(params[:new_password])

    'Both Passwords Does Not Match' if params[:new_password] != params[:confirm_password]
  end

  def update_password
    if @account.update(password: params[:new_password])
      render json: { message: 'Password Update Successfully' }, status: :ok
    else
      error_response(@account)
    end
  end
end

class V1::AccountsController < ApplicationController
  # before_action :authentication, only: [:login]
  before_action :get_account, only: [:login]
  before_action :find_token, only: %i[otp_verify]

  def signup
    @account = Account.new(account_params)
    if @account.save
      send_otp
    else
      error_response(@account)
    end
  end

  def login
    if @current_user.authenticate(params[:password])
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

  private

  def account_params
    params.require(:account).permit(:mobile_number, :password_digest, :password_confirmation)
  end

  def encode(id)
    encode_account_data({ user_account: id })
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
    @current_user = Account.find_by(mobile_number: params[:mobile_number])
    return not_found unless @current_user.present?
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
end

#     class UsersController < ApplicationController
#       before_action :authentication, only: %i[reset_password update]
#       before_action :find_token, only: %i[otp_verify user_verify resend_otp]

#       before_action :find_user, only: %i[login forgot_password]     

#       def forgot_password
#         send_otp
#       end

#       def user_verify
#         user_id = @decode_data[0]['user_data']
#         @user = User.find(user_id)
#         return render json: { errors: confirm_password } unless confirm_password.nil?

#         update_password
#       rescue StandardError
#         record_not_found
#       end

#       def reset_password
#         @user = current_user
#         return render json: { errors: confirm_password } unless confirm_password.nil?

#         if @user.authenticate(params[:old_password])
#           update_password
#         else
#           invalid_password_error
#         end
#       end

#       def resend_otp
#         otp_id = @decode_data[0]['id']
#         @user = EmailOtp.find(otp_id)
#         send_otp
#       rescue StandardError
#         record_not_found
#       end

#       def update
#         if current_user.authenticate(params[:user][:password])
#           if current_user.update(user_params)
#             render json: V1::Customer::UserSerializer.new(current_user, serialize_params).serializable_hash,
#                    status: :ok
#           else
#             error_response(current_user)
#           end
#         else
#           invalid_password_error
#         end
#       end

#       def confirm_password
#         return 'You can not enter old password again' if @user.authenticate(params[:new_password])

#         'Both Passwords Does Not Match' if params[:new_password] != params[:confirm_password]
#       end

#       def update_password
#         if @user.update(password: params[:new_password])
#           render json: { message: 'Password Update Successfully' }, status: :ok
#         else
#           error_response(@user)
#         end
#       end

#     end
#   end
# end
Rails.application.routes.draw do

  namespace :v1 do
    post 'signup', to: 'accounts#signup'
    post 'login', to: 'accounts#login'
    post 'otp_verify', to: 'accounts#otp_verify'
    post 'forgot_password', to: 'accounts#forgot_password'
    post 'resend_otp', to: 'accounts#resend_otp'
    post 'account_verify', to: 'accounts#account_verify'
    post 'change_password', to: 'accounts#change_password'
    patch 'update_profile', to: 'accounts#update'
  end
end

Rails.application.routes.draw do

  namespace :v1 do
    post 'signup', to: 'accounts#signup'
    post 'login', to: 'accounts#login'
    post 'otp_verify', to: 'accounts#otp_verify'
  end
end

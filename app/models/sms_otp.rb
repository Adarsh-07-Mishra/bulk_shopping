class SmsOtp < ApplicationRecord
  before_create :generate_otp
	# before_create :check_otp
	validates :mobile_number, uniqueness: true

	def generate_otp
		self.pin = rand(1000..9999)
		self.valid_until = Time.current + 5.minutes
  end

  # def check_otp
  #   SmsOtp.last&.destroy
  # end
end

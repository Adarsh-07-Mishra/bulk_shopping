class Account < ApplicationRecord
  enum role: [:customer, :owner]
  enum status: [:pending, :approved]
	validates :mobile_number, uniqueness: true
end
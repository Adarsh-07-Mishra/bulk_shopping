class Account < ApplicationRecord

  has_one_attached :profile_pic
  enum role: [:customer, :owner]
  enum status: [:pending, :approved]
	validates :mobile_number, uniqueness: true, presence: true
end
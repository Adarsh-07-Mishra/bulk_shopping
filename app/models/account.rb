class Account < ApplicationRecord
  enum role: [:customer, :owner]
  enum status: [:pending, :approved]
end

class CreateAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts do |t|
      t.string :full_name
      t.string :mobile_number
      t.integer :age
      t.integer :gender
      t.string :dob
      t.string :city
      t.string :address
      t.integer :pincode
      t.integer :role, default: 0
      t.integer :status, default: 0
      t.string :password_digest
      t.boolean :is_otp_verify, default: false

      t.timestamps
    end
  end
end

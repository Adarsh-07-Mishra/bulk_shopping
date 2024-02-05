class CreateSmsOtps < ActiveRecord::Migration[7.1]
  def change
    create_table :sms_otps do |t|
      t.string :mobile_number
      t.string :pin
      t.datetime :valid_until

      t.timestamps
    end
  end
end

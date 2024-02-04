module V1
  class AccountSerializer < ActiveModel::Serializer
    attributes :id, :mobile_number, :role, :status
  end
end

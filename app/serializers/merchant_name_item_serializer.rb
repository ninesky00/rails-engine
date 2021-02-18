class MerchantNameItemSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :count
end

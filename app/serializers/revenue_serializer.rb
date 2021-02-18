class RevenueSerializer
  include FastJsonapi::ObjectSerializer
  set_type :merchant
  attributes :name, :revenue
end

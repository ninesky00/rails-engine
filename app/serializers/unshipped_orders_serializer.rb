class UnshippedOrdersSerializer
  include FastJsonapi::ObjectSerializer
  set_type :unshipped_order
  attributes :potential_revenue
end

class RevenueSerializer
  def self.period(revenue)
    { 
      data: {
      id: nil,
      type: 'revenue',
      attributes: {
        revenue: revenue
      }
      }
    }
  end

  def self.unshipped_order(orders)
    {
      data: orders.map do |order|
        {
          id: order.id.to_s,
          type: 'unshipped_order',
          attributes: {
            potential_revenue: order.potential_revenue
          }
        }
      end
    }
  end
end

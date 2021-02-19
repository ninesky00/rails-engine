class RevenueSerializer
  def self.format(revenue)
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
end

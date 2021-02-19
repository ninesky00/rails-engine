class RevenueSerializer
  def self.period(revenue)
    { data:
      {
        id: nil,
        type: 'revenue',
        attributes: {
          revenue: revenue
        }
      } }
  end
end

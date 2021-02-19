class MerchantRevenueSerializer
  def self.format(merchant)
    {
      data: {
        id: merchant.id.to_s,
        type: 'merchant_revenue',
        attributes: {
          revenue: Merchant.revenue(merchant.id)
        }
      }
    }
  end
end

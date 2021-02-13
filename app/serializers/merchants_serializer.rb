class MerchantsSerializer
  class << self 
    def format_merchants(merchants)
      merchants.map do |merchant|
        {
          id: merchant.id,
          name: merchant.name,
        }
      end
    end

    def single_merchant(merchant)
      {
        data:
        {
        id: merchant.id,
        name: merchant.name,
        }
      }
    end
  end
end
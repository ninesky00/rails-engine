FactoryBot.define do
  factory :invoice_item, class: InvoiceItem do
    association :item
    association :invoice
    quantity { Faker::Number.between(from: 1, to: 10) }
    unit_price { Faker::Number.decimal(l_digits: 4, r_digits: 2)}
    status {["pending", "packaged", "shipped"].sample}
  end
end
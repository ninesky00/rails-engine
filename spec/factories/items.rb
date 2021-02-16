FactoryBot.define do
  factory :item, class: Item do
    name { Faker::Commerce.product_name }
    description { Faker::Quote.famous_last_words }
    unit_price { (Faker::Number.decimal(l_digits: 3, r_digits: 2))}
    association :merchant
  end
end
FactoryBot.define do
  factory :invoice, class: Invoice do
    association :customer
    association :merchant
    status {['packaged', 'shipped', 'returned'].sample}
  end
end
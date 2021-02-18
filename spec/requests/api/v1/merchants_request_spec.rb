require 'rails_helper'

describe "Merchants API" do
  it "sends a list of merchants" do
    create_list(:merchant, 3)

    get '/api/v1/merchants'

    expect(response).to be_successful
    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(merchants[:data].count).to eq(3)

    merchants[:data].each do |merchant|
      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to be_an(String)

      expect(merchant[:attributes]).to have_key(:name)
      expect(merchant[:attributes][:name]).to be_a(String)
    end
  end

  describe 'fetching a single merchant' do
    it 'succeeds when there is something to fetch' do
      merchant = create(:merchant)
      expected_attributes = {
        name: merchant.name
      }
      get api_v1_merchant_path(merchant.id)
      expect(response.status).to eq(200)
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:data][:id]).to eq(merchant.id.to_s)
      expected_attributes.each do |attribute, value|
        expect(json[:data][:attributes][attribute]).to eq(value)
      end
    end
  end

  it 'fails with 404 if merchant does not exist' do
    get api_v1_merchant_path(999999)
    expect(response.status).to eq(404)
    # as an extension, you can make a custom error message, but a 404 with an empty "data" structure from the serializer is fine too
    # json = JSON.parse(response.body, symbolize_names: true)
    # expect(json).to have_key(:error)
    # expect(json[:error]).to eq('resource could not be found')
  end
  describe "fetch merchant items" do 
    it "can get all items for a given merchant ID" do 
      merchant = create(:merchant)
      items = create_list(:item, 5, merchant: merchant)
      get "/api/v1/merchants/#{merchant.id}/items"

      expect(response).to be_successful
      merchant_items = JSON.parse(response.body, symbolize_names: true)

      expect(merchant_items[:data].count).to eq(5)

      merchant_items[:data].each do |item|
        expect(item).to have_key(:id)
        expect(item[:id]).to be_an(String)

        expect(item[:attributes]).to have_key(:name)
        expect(item[:attributes][:name]).to be_a(String)

        expect(item[:attributes]).to have_key(:description)
        expect(item[:attributes][:description]).to be_a(String)

        expect(item[:attributes]).to have_key(:unit_price)
        expect(item[:attributes][:unit_price]).to be_a(Float)

        expect(item[:attributes]).to have_key(:merchant_id)
        expect(item[:attributes][:merchant_id]).to be_a(Integer)
      end
    end

    it "will error to retrieve items if merchant does not exist in database" do 
      merchant = create(:merchant)
      items = create_list(:item, 5, merchant: merchant)
      get "/api/v1/merchants/404/items"

      expect(response.status).to eq(404)
    end
  end

  describe "find one merchant search criteria" do 
    it "can find a merchant based on search criteria" do 
      merchant = create(:merchant, name: 'Hard to Find')

      expected_attributes = {
        name: merchant.name
      }
      get "/api/v1/merchants/find?name=hard"

      expect(response.status).to eq(200)
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:data][:id]).to eq(merchant.id.to_s)
      expected_attributes.each do |attribute, value|
        expect(json[:data][:attributes][attribute]).to eq(value)
      end
    end
  end

  it "find merchants ranked by total revenue" do
    merchant1 = create(:merchant)
    merchant2 = create(:merchant)
    merchant3 = create(:merchant)
    item1 = create(:item, merchant: merchant1, unit_price: 100)
    item2 = create(:item, merchant: merchant2, unit_price: 90)
    item3 = create(:item, merchant: merchant3, unit_price: 80)
    invoice1 = create(:invoice, merchant: merchant1)
    invoice2 = create(:invoice, merchant: merchant2)
    invoice3 = create(:invoice, merchant: merchant3)
    create(:invoice_item, item: item1, invoice: invoice1, quantity: 1, unit_price: 100)
    create(:invoice_item, item: item2, invoice: invoice2, quantity: 1, unit_price: 90)
    create(:invoice_item, item: item3, invoice: invoice3, quantity: 1, unit_price: 80)

    transaction = create(:transaction, invoice: invoice1, result: 'success')
    transaction = create(:transaction, invoice: invoice2, result: 'success')
    transaction = create(:transaction, invoice: invoice3, result: 'success')

    get "/api/v1/revenue/merchants?quantity=2"
    expect(response.status). to eq(200)
    data = JSON.parse(response.body, symbolize_names: true)
    data1, data2 = data[:data][0], data[:data][1]
    expect(data1[:type]).to eq("merchant_name_revenue")
    expect(data1[:id]).to eq(merchant1.id.to_s)
    expect(data1[:attributes][:name]).to eq(merchant1.name)
    expect(data1[:attributes]).to have_key(:revenue)

    expect(data2[:type]).to eq("merchant_name_revenue")
    expect(data2[:id]).to eq(merchant2.id.to_s)
    expect(data2[:attributes][:name]).to eq(merchant2.name)
    expect(data2[:attributes]).to have_key(:revenue)
  end

  it "find merchants by most items sold" do 
    merchant1 = create(:merchant)
    merchant2 = create(:merchant)
    merchant3 = create(:merchant)
    item1 = create(:item, merchant: merchant1, unit_price: 100)
    item2 = create(:item, merchant: merchant2, unit_price: 90)
    item3 = create(:item, merchant: merchant3, unit_price: 80)
    invoice1 = create(:invoice, merchant: merchant1)
    invoice2 = create(:invoice, merchant: merchant2)
    invoice3 = create(:invoice, merchant: merchant3)
    create(:invoice_item, item: item1, invoice: invoice1, quantity: 80, unit_price: 100)
    create(:invoice_item, item: item2, invoice: invoice2, quantity: 90, unit_price: 90)
    create(:invoice_item, item: item3, invoice: invoice3, quantity: 100, unit_price: 80)

    transaction = create(:transaction, invoice: invoice1, result: 'success')
    transaction = create(:transaction, invoice: invoice2, result: 'success')
    transaction = create(:transaction, invoice: invoice3, result: 'success')

    get '/api/v1/merchants/most_items?quantity=2'
    expect(response.status). to eq(200)
    data = JSON.parse(response.body, symbolize_names: true)
    data1, data2 = data[:data][0], data[:data][1]
    expect(data1[:type]).to eq("merchant_name_item")
    expect(data1[:id]).to eq(merchant3.id.to_s)
    expect(data1[:attributes][:name]).to eq(merchant3.name)
    expect(data1[:attributes]).to have_key(:count)

    expect(data2[:type]).to eq("merchant_name_item")
    expect(data2[:id]).to eq(merchant2.id.to_s)
    expect(data2[:attributes][:name]).to eq(merchant2.name)
    expect(data2[:attributes]).to have_key(:count)
  end
end
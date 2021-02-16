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

      expect(merchant).to have_key(:name)
      expect(merchant[:name]).to be_a(String)
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

  it "can create a new merchant" do
    merchant_params = ({
                    name: 'Express',
                  })
    headers = {"CONTENT_TYPE" => "application/json"}
  
    post "/api/v1/merchants", headers: headers, params: JSON.generate(merchant: merchant_params)
    created_merchant = Merchant.last
  
    expect(response).to be_successful
    expect(created_merchant.name).to eq(merchant_params[:name])
  end

  it "can update an existing book" do
    id = create(:merchant).id
    previous_name = Merchant.last.name
    merchant_params = { name: "Amani" }
    headers = {"CONTENT_TYPE" => "application/json"}
  
    # We include this header to make sure that these params are passed as JSON rather than as plain text
    patch "/api/v1/merchants/#{id}", headers: headers, params: JSON.generate({merchant: merchant_params})
    merchant = Merchant.find_by(id: id)
  
    expect(response).to be_successful
    expect(merchant.name).to_not eq(previous_name)
    expect(merchant.name).to eq("Amani")
  end

  it "can destroy an merchant" do
    merchant = create(:merchant)
  
    expect(Merchant.count).to eq(1)
  
    delete "/api/v1/merchants/#{merchant.id}"
  
    expect(response).to be_successful
    expect(Merchant.count).to eq(0)
    expect{Merchant.find(merchant.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "can get all items for a given merchant ID" do 
    merchant = create(:merchant)
    items = create_list(:item, 5, merchant: merchant)
    get "/api/v1/merchants/#{merchant.id}/items"

    expect(response).to be_successful
    merchant_items = JSON.parse(response.body, symbolize_names: true)

    expect(merchant_items[:data].count).to eq(5)

    merchant_items[:data].each do |item|
      expect(item).to have_key(:id)
      expect(item[:id]).to be_an(Integer)

      expect(item).to have_key(:name)
      expect(item[:name]).to be_a(String)

      expect(item).to have_key(:description)
      expect(item[:description]).to be_a(String)

      expect(item).to have_key(:unit_price)
      expect(item[:unit_price]).to be_a(Numberic)

      expect(item).to have_key(:merchant_id)
      expect(item[:merchant_id]).to be_a(Integer)
    end
  end
end
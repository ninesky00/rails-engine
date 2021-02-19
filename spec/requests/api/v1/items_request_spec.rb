require 'rails_helper'

describe "Items API" do
  it "sends a list of items" do
    create_list(:item, 3)

    get '/api/v1/items'

    expect(response).to be_successful
    items = JSON.parse(response.body, symbolize_names: true)

    expect(items[:data].count).to eq(3)

    items[:data].each do |item|
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

  describe 'fetching a single item' do
    it 'succeeds when there is something to fetch' do
      item = create(:item)
      expected_attributes = {
        name: item.name,
        description: item.description,
        unit_price: item.unit_price,
        merchant_id: item.merchant_id
      }
      get api_v1_item_path(item.id)
      expect(response.status).to eq(200)
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:data][:id]).to eq(item.id.to_s)
      expected_attributes.each do |attribute, value|
        expect(json[:data][:attributes][attribute]).to eq(value)
      end
    end
  end

  it 'fails with 404 if item does not exist' do
    get api_v1_item_path(999999)
    expect(response.status).to eq(404)
    # as an extension, you can make a custom error message, but a 404 with an empty "data" structure from the serializer is fine too
    # json = JSON.parse(response.body, symbolize_names: true)
    # expect(json).to have_key(:error)
    # expect(json[:error]).to eq('resource could not be found')
  end

  it "can create a new item" do
    merchant = create(:merchant, id: 200)
    item_params = ({
                    name: 'brick',
                    description: 'expensive stone',
                    unit_price: 500,
                    merchant_id: merchant.id,
                  })
    headers = {"CONTENT_TYPE" => "application/json"}
  
    post "/api/v1/items", headers: headers, params: JSON.generate({item: item_params})
    created_item = Item.last
  
    expect(response.status).to eq(201)
    expect(created_item.name).to eq(item_params[:name])
    expect(created_item.description).to eq(item_params[:description])
    expect(created_item.unit_price).to eq(item_params[:unit_price])
    expect(created_item.merchant_id).to eq(merchant.id)
  end

  it "will error 409 if incorrect item_params" do
    item_params = ({
                    name: 'brick',
                    description: 'expensive stone',
                    unit_price: 500,
                    merchant_id: 404,
                  })
    headers = {"CONTENT_TYPE" => "application/json"}
  
    post "/api/v1/items", headers: headers, params: JSON.generate({item: item_params})
    created_item = Item.last
  
    expect(response.status).to eq(409)
  end

  it "can update an existing item" do
    merchant = create(:merchant)
    id = create(:item, merchant: merchant).id
    previous_name = Item.last.name
    item_params = ({
                    name: 'morter',
                    description: 'no longer sustainable',
                    unit_price: 2,
                    merchant: merchant,
    })
    headers = {"CONTENT_TYPE" => "application/json"}
  
    # We include this header to make sure that these params are passed as JSON rather than as plain text
    patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate({item: item_params})
    item = Item.find_by(id: id)
  
    expect(response).to be_successful
    expect(item.name).to_not eq(previous_name)
    expect(item.name).to eq("morter")
    expect(item.description).to eq("no longer sustainable")
    expect(item.unit_price).to eq(2)
    expect(item.merchant_id).to eq(merchant.id)
  end

  it "will not update an existing item if missing merchant" do
    id = create(:item).id
    previous_name = Item.last.name
    item_params = ({
                    name: 'morter',
                    description: 'no longer sustainable',
                    unit_price: 2,
                    merchant_id: 404,
    })
    headers = {"CONTENT_TYPE" => "application/json"}
  
    # We include this header to make sure that these params are passed as JSON rather than as plain text
    patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate({item: item_params})
    item = Item.find_by(id: id)
  
    expect(response.status).to eq(404)
  end

  it "can destroy an item" do
    item = create(:item)
  
    expect(Item.count).to eq(1)
  
    delete "/api/v1/items/#{item.id}"
  
    expect(response).to be_successful
    expect(Item.count).to eq(0)
    expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end

  describe "fetch item's merchant" do 
    it "can get the merchant information for a given item ID" do 
      merchant = create(:merchant)
      item = create(:item, merchant: merchant)
      get "/api/v1/items/#{item.id}/merchant"

      expect(response).to be_successful
      merchant = JSON.parse(response.body, symbolize_names: true)


      expect(merchant[:data]).to have_key(:id)
      expect(merchant[:data][:id]).to be_an(String)

      expect(merchant[:data][:attributes]).to have_key(:name)
      expect(merchant[:data][:attributes][:name]).to be_a(String)
    end

    it "will error to retrieve merchant if item does not exist in database" do 
      merchant = create(:merchant)
      items = create_list(:item, 5, merchant: merchant)
      get "/api/v1/items/id/merchant"

      expect(response.status).to eq(404)
    end
  end

  describe "find all items search criteria" do 
    it "can find all items based on search criteria" do 
      items = create_list(:item, 2, name: 'HarDer To Find')
      item = create(:item, name: 'cannot be FouND')
      expected_attributes1 = {
        name: items[0].name,
        description: items[0].description,
        unit_price: items[0].unit_price,
        merchant_id: items[0].merchant_id
      }

      expected_attributes2 = {
        name: items[1].name,
        description: items[1].description,
        unit_price: items[1].unit_price,
        merchant_id: items[1].merchant_id
      }

      get "/api/v1/items/find_all?name=hard"

      expect(response.status).to eq(200)
      json = JSON.parse(response.body, symbolize_names: true)
      item1 = json[:data][0]
      item2 = json[:data][1]
      item3 = json[:data][2]

      expect(item1[:id]).to eq(items[0].id.to_s)
      expected_attributes1.each do |attribute, value|
        expect(item1[:attributes][attribute]).to eq(value)
      end

      expect(item2[:id]).to eq(items[1].id.to_s)
      expected_attributes2.each do |attribute, value|
        expect(item2[:attributes][attribute]).to eq(value)
      end
      
      expect(item3).to be_nil
    end

    it "will error to find all items without search criteria" do 
      items = create_list(:item, 2, name: 'HarDer To Find')
      item = create(:item, name: 'cannot be FouND')

      get "/api/v1/items/find_all?name="

      expect(response.status).to eq(400)
    end
  end
end
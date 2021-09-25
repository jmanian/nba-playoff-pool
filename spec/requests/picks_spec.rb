require 'rails_helper'

RSpec.xdescribe 'Picks', type: :request do
  describe 'GET /index' do
    it 'returns http success' do
      get '/picks'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /new' do
    it 'returns http success' do
      get '/picks/new'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /create' do
    it 'returns http success' do
      get '/picks/create'
      expect(response).to have_http_status(:success)
    end
  end
end

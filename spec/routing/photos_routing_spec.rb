require 'spec_helper'

describe PhotosController do
  describe 'Routing' do

    it 'routes to #destroy' do
      delete('/photos/1').should route_to('photos#destroy', id: '1')
    end

    it 'routes to #create' do
      post('/products/1/photos').should route_to('photos#create', product_id: '1')
    end
  end
end
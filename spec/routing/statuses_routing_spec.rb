require "spec_helper"

describe StatusController do
  describe "Routing" do

    it "routes to #show" do
      get("/products/1/status/2").should route_to("status#show", product_id: '1', id: '2')
    end

    it "routes to #update" do
      put("/products/1/status/2").should route_to("status#update", product_id: '1', id: '2')
    end
  end
end
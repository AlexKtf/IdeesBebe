require "spec_helper"

describe MessagesController do
  describe "Routing" do

    it "routes to #create" do
      post("/products/1/messages").should route_to("messages#create", product_id: '1')
    end
  end
end
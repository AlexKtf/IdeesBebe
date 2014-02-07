require "spec_helper"

describe CategoriesController do
  describe "Routing" do

    it "routes to #show" do
      get("/categories/1").should route_to("categories#show", id: '1')
    end

    it "routes to #show_subcategory" do
      get("/categories/1/2").should route_to("categories#show_subcategory", category_id: '1', id: '2')
    end
  end
end
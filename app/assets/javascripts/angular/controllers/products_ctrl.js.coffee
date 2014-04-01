App.controller 'ProductsCtrl', ['$scope', 'Product', ($scope, Product) ->
  $scope.products = Product.query ->
    $scope.selectedProduct = $scope.products[0]
    $scope.selectedRow = 0

  $scope.showProduct = (product, row) ->
    $scope.selectedProduct = product
    $scope.selectedRow = row
]
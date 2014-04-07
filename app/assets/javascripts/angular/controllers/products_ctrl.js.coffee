App.controller 'ProductsCtrl', ['$scope', '$http', 'Product', ($scope, $http, Product) ->
  $scope.products = Product.query ->
    $scope.selectedProduct = $scope.products[0]
    $scope.selectedRow = 0
    $scope.selectedFilter = 'none'


  $scope.showProduct = (product, row) ->
    $scope.selectedProduct = product
    $scope.selectedRow = row

  $scope.allowedFilter = (filter) ->
    $scope.filter = filter
    $http({method: 'GET', url: '/admin/products.json?allowed=' + filter}).success($scope.filtered)

  $scope.filtered = (data) ->
    $scope.products = data
    $scope.selectedProduct = $scope.products[0]
    $scope.selectedRow = 0
    if angular.isUndefined($scope.filter)
      $scope.selectedFilter = 'none'
    else
      $scope.selectedFilter = $scope.filter

]
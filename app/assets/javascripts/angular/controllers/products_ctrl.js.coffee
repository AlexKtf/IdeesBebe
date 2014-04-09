App.controller 'ProductsCtrl', ['$scope', '$http', 'Product', 'filterFilter', ($scope, $http, Product, filterFilter) ->
  $scope.loading = true
  $scope.selectedFilter = 'default'
  $scope.products = Product.query ->
    $scope.allProducts = $scope.products
    $scope.initializeSelected()
    $scope.selectedFilter = 'none'
    $scope.loading = false

  $scope.showProduct = (product, row) ->
    $scope.selectedProduct = product
    $scope.selectedRow = row

  $scope.allowedFilter = (filter) ->
    $scope.loading = true
    $scope.products = filterFilter($scope.allProducts, { allowed: filter })
    if angular.isUndefined(filter)
      $scope.selectedFilter = 'none'
    else
      $scope.selectedFilter = filter
    $scope.initializeSelected()
    $scope.loading = false

  $scope.initializeSelected = () ->
    $scope.selectedProduct = $scope.products[0]
    $scope.selectedRow = 0


]
App.factory 'Product', ['$resource', ($resource) ->
  $resource '/admin/products.json'
]
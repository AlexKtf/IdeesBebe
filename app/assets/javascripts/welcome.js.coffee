# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
	$(".ui.dropdown").dropdown()

blueimp.Gallery document.getElementById("links").getElementsByTagName("a"),
  container: "#blueimp-gallery-carousel"
  carousel: true
  thumbnailIndicators: true

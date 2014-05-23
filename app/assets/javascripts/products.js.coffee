$ ->
  $('.subdropdown .item').click ->
    id = $(this).children('#sub-id').attr('data-id')
    $('.category_id_field').val(id)

  $('.upload-form').each (i, e) ->
    $(e).children().find('#photo_file').change ->
      form = $(this).parents('form')
      icon = form.children().find('.cloud')
      icon.removeClass('cloud upload').addClass('loading')
      form.submit()

  if $('#blueimp-product-carousel').length > 0
    links = $('#links a')
    blueimp.Gallery links,
      container: '#blueimp-product-carousel',
      carousel: true,
      stretchImages: true,
      thumbnailIndicators: true,
      thumbnailProperty: 'thumbnail'

  if $('#conversation').length > 0
    $conversation = $('#conversation')
    $conversation.scrollTop($conversation.scrollTop() - $conversation.offset().top + $('.comments .comment:last-child').offset().top)

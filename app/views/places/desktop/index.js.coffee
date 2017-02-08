if $('.places-container').length > 0
  $('.places-container').replaceWith("<%= j render partial: '/places/desktop/index' %>")
else
  $('#places').append("<%= j render partial: '/places/desktop/index' %>")

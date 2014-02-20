window.chantbox.service 'Chatter', ['$window', '$timeout', ($window, $timeout) ->

  $chatter = document.querySelector("#chatter ul")

  scrollToBottom = ->
    $chatter.scrollTop = $chatter.scrollHeight

  if $chatter
      t = null
      first = true
      resize = do ->
        clearTimeout(t) if typeof(t) is 'number'
        t = $timeout ->
          $chatter.style.height = $window.innerHeight - 90 + 'px'
          $chatter.style.width = $window.innerWidth  - 310 + 'px'
          if first
            first = false
            scrollToBottom()
        , 300
        return arguments.callee

      $window.addEventListener 'resize', resize, false

  return {
    scrollToBottom: scrollToBottom
  }

]

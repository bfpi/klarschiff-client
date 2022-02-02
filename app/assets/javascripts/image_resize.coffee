$ ->
  $(document).on 'change', 'input[type="file"]', (e) ->
    settings = {
      max_width: 2000
      max_height: 2000
      quality: 1
      do_not_resize: [
        'gif'
        'svg'
      ]
    }
    changedInput = e.target

    originalFile = @files[0]
    if !originalFile or !originalFile.type.startsWith('image')
      return
    if settings.do_not_resize.includes('*') or settings.do_not_resize.includes(originalFile.type.split('/')[1])
      return
    reader = new FileReader

    reader.onload = (e) ->
      img = document.createElement('img')
      canvas = document.createElement('canvas')
      img.src = e.target.result

      img.onload = ->
        ctxOriginal = canvas.getContext('2d')
        ctxOriginal.drawImage img, 0, 0
        if img.width < settings.max_width and img.height < settings.max_height
          return # Resize not required
        ratio = Math.min(settings.max_width / img.width, settings.max_height / img.height)
        width = Math.round(img.width * ratio)
        height = Math.round(img.height * ratio)
        canvas.width = width
        canvas.height = height
        ctxResized = canvas.getContext('2d')
        ctxResized.drawImage img, 0, 0, width, height
        canvas.toBlob ((blob) ->
          resizedFile = new File([ blob ], 'resized_' + originalFile.name, originalFile)
          dataTransfer = new DataTransfer
          dataTransfer.items.add resizedFile

          # temporary remove event listener, change and restore
          currentOnChange = changedInput.onchange
          changedInput.onchange = null
          changedInput.files = dataTransfer.files
          changedInput.onchange = currentOnChange
          return
        ), 'image/jpeg', settings.quality

    reader.readAsDataURL originalFile

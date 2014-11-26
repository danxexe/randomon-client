require 'native'
require 'browser/canvas'

canvas = Browser::Canvas.new width: 200, height: 200
canvas.append_to `document.body`

canvas.style.fill = 'green'
canvas.rect 0, 0, 200, 200
canvas.fill
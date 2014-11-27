require 'native'
require 'opal-parser'
require 'browser/canvas'

def stage
  `stage`
end

def canvas
  $canvas ||= begin
    c = Browser::Canvas.new width: `stage.clientWidth`, height: `stage.clientHeight`
    c.append_to stage
    c
  end
end

def sketch(&block)
  canvas.instance_eval &block
end

# sketch do
#     path do
#         style.fill = 'blue'
#         rect 0, 0, 200, 200
#         fill
#     end
    
#     path do
#         style.fill = 'green'
#         rect 100, 100, 200, 200
#         fill
#     end
# end
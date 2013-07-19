d3 = require 'd3'

## Drawing preview circles and lines
# click and drag to draw an orbit or link (modes)

measure_distance = (point1, point2) ->
  # point to point line distance for two objects with x and y
  # attributes

  pow = Math.pow

  r2 = pow(point1.x - point2.x, 2) + pow(point1.y - point2.y, 2)

  return pow(r2, 0.5) | 0  # rounded pixels should be faster - iD blog


state =
  brush: 'Orbit'  # default brush
  preview: []


# Event handlers for different brushes
brushes =
  clear: ->
    state.preview.length = 0

  Orbit:
    mousedown: (x, y) ->
      state.preview = [{x: x, y: y, r: 0}]

    mousemove: (x, y) ->
      state.preview[0].r = measure_distance state.preview[0], {x: x, y: y}

    mouseup: (x, y) ->
      # Set to 1 to avoid NaN cx and cy after dividing by zero
      r = measure_distance state.preview[0], {x: x, y: y}
      state.preview[0].r = r or 1

      # save orbit

      brushes.clear()

    render: (svg, preview) ->
      svg.select('#circle-brush')
        .datum(preview[0])
          .style('display', '')
          .style('fill', 'none')
          .style('stroke', 'gray')
          .style('stroke-width', 1)
          .attr('r', (d) -> d.r)
          .attr('cx', (d) -> d.x)
          .attr('cy', (d) -> d.y)

  Link:
    mousedown: (x, y) ->
      state.preview = [{x1: x, y1: y, x2: x, y2: y}]

    mousemove: (x, y) ->
      state.preview[0].x2 = x
      state.preview[0].y2 = y

    mouseup: (x, y) ->
      state.preview[0].x2 = x
      state.preview[0].y2 = y

      # save link

      brushes.clear()

    render: (svg, preview) ->
      svg.select('#link-brush')
        .datum(preview[0])
          .style('display', '')
          .style('stroke', 'gray')
          .style('stroke-width', 3)
          .attr('x1', (d) -> d.x1)
          .attr('y1', (d) -> d.y1)
          .attr('x2', (d) -> d.x2)
          .attr('y2', (d) -> d.y2)


bind = (brush_change_dispatcher, svg) ->

  # Update our brush when it changes and clear the current brush
  brush_change_dispatcher.on 'change_brush.preview', (new_brush_name) ->
    state.brush = new_brush_name
    brushes.clear()

  svg.on 'mousedown', ->
    [x, y] = d3.mouse this  # get position in svg
    brushes[state.brush]['mousedown'] x, y

  svg.on 'mousemove', ->
    if state.preview.length == 0
      return

    [x, y] = d3.mouse this
    brushes[state.brush]['mousemove'] x, y

  svg.on 'mouseup', ->
    if state.preview.length == 0
      return

    [x, y] = d3.mouse this
    brushes[state.brush]['mouseup'] x, y

  svg.on 'mouseout', ->
    # abruptly kill the preview
    brushes.clear()

  d3.timer ->
    if state.preview.length == 0
      svg.select('.brush circle').style('display', 'none')
      svg.select('.brush line').style('display', 'none')
      return false

    brushes[state.brush]['render'] svg, state.preview
    return false


module.exports =
  bind: bind

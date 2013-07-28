d3 = require 'd3'

## Drawing preview circles and lines
# click and drag to draw an orbit or link (modes)

measure_distance = (point1, point2) ->
  # point to point line distance for two objects with x and y
  # attributes

  pow = Math.pow

  r2 = pow(point1.x - point2.x, 2) + pow(point1.y - point2.y, 2)

  return pow(r2, 0.5) | 0  # rounded pixels should be faster - iD blog


measure_distance_magnitude = (point1, point2) ->
  # point to point distance without sqrt for comparisions
  pow = Math.pow
  r2 = pow(point1[0] - point2[0], 2) + pow(point1[1] - point2[1], 2)
  return r2


state =
  brush: 'orbit'  # default brush
  preview: []


# Fire save events with an orbit or line preview
dispatcher = d3.dispatch "save"

closest_point_from_array = (point, array) ->
  # not including the point itself
  # faster if sorted and bisect on closest
  # but using order mapping back to orbits in main update
  # console.log array
  closest = null
  closest_distance = +Infinity
  for other_point in array
    if point[0] == other_point[0] and point[1] == other_point[1]
      continue
    distance = measure_distance_magnitude point, other_point
    if distance < closest_distance
      closest = other_point
      closest_distance = distance
  return closest

console.log closest_point_from_array [10, 10], []  # null
console.log closest_point_from_array [10, 10], [[10, 10]]  # null
console.log closest_point_from_array [10, 10], [[20, 10], [30, 10]]  # [20, 10]


# Event handlers for different brushes
brushes =
  clear: ->
    state.preview.length = 0

  orbit:
    mousedown: (x, y) ->
      state.preview = [{type: state.brush, x: x, y: y, r: 0}]

    mousemove: (x, y) ->
      if state.preview.length == 0
        return

      state.preview[0].r = measure_distance state.preview[0], {x: x, y: y}

    mouseup: (x, y) ->
      # Set to 1 to avoid NaN cx and cy after dividing by zero
      r = measure_distance state.preview[0], {x: x, y: y}
      state.preview[0].r = r or 1

      # save orbit
      dispatcher.save state.preview[0]

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

  link:
    mousedown: (x, y) ->
      # instead save the nearest orbiter (highlighted)
      # and pause
      state.preview = [{type: state.brush, x1: x, y1: y, x2: x, y2: y}]

    mousemove: (x, y, orbiters) ->
      # highlight the nearest orbiter
      console.log 'os', orbiters.length
      # !! need matching svg element so pass orbiters selection instead
      console.log closest_point_from_array [x, y], orbiters

      if state.preview.length == 0
        return

      state.preview[0].x2 = x
      state.preview[0].y2 = y

    mouseup: (x, y) ->
      # unpause
      state.preview[0].x2 = x
      state.preview[0].y2 = y

      # save link
      dispatcher.save state.preview[0]

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


bind = (brush_change_dispatcher, svg, orbiters) ->
  # Update our brush when it changes and clear the current brush
  brush_change_dispatcher.on 'change_brush.preview', (new_brush_name) ->
    state.brush = new_brush_name
    brushes.clear()

  svg.on 'mousedown', ->
    # Don't track right and middle clicks
    if d3.event.which != 1
      return

    [x, y] = d3.mouse this  # get position in svg
    brushes[state.brush]['mousedown'] x, y

  svg.on 'mousemove', ->
    [x, y] = d3.mouse this
    brushes[state.brush]['mousemove'] x, y, orbiters

  svg.on 'mouseup', ->
    if state.preview.length == 0
      return

    [x, y] = d3.mouse this
    brushes[state.brush]['mouseup'] x, y

  # svg.on 'mouseout', ->
  #   console.log 'mouseout' # triggered by going over another orbit
  #   # use mouseup or abruptly kill the preview?
  #   # brushes.clear()

  d3.timer ->
    if state.preview.length == 0
      svg.select('.brush circle').style('display', 'none')
      svg.select('.brush line').style('display', 'none')
      return false

    brushes[state.brush]['render'] svg, state.preview
    return false

  return dispatcher

module.exports =
  bind: bind

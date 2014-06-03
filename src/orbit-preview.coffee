d3 = require 'd3'

## Drawing preview circles

measure_distance = (point1, point2) ->
  # point to point line distance for two objects with x and y
  # attributes

  pow = Math.pow

  r2 = pow(point1.x - point2.x, 2) + pow(point1.y - point2.y, 2)

  return pow(r2, 0.5) | 0  # rounded pixels should be faster - iD blog


render = (svg, preview) ->
  if preview == null
    svg.select('#circle-brush').style('display', 'none')
    return

  svg.select('#circle-brush')
    .datum(preview)
      .style('display', '')
      .style('fill', 'none')
      .style('stroke', 'gray')
      .style('stroke-width', 1)
      .attr('r', (d) -> d.r)
      .attr('cx', (d) -> d.x)
      .attr('cy', (d) -> d.y)


current_brush = 'orbit'


setup = (svg, main_events) ->
  preview = null

  main_events.on 'time.orbit-preview', (new_time) ->
    if current_brush == 'orbit'
      render svg, preview

  # clear other preview handlers
  svg.on 'mousedown.preview', ->
    # Don't track right and middle clicks
    if d3.event.which != 1
      return

    [x, y] = d3.mouse this  # get position in svg
    preview = {type: 'orbit', x: x, y: y, r: 0}

    render svg, preview

  svg.on 'mousemove.preview', (x, y) ->
    if preview == null
      return

    [x, y] = d3.mouse this  # get position in svg
    preview.r = measure_distance preview, {x: x, y: y}

    render svg, preview

  svg.on 'mouseup', (x, y) ->
    if preview == null
      return

    [x, y] = d3.mouse this  # get position in svg

    # Set to 1 to avoid NaN cx and cy after dividing by zero
    r = measure_distance preview, {x: x, y: y}
    preview.r = r or 1

    # save orbit
    main_events.save preview

    preview = null
    render svg, preview


bind = (svg, brush_change_events, main_events) ->

  # Update our brush when it changes and clear the current brush
  brush_change_events.on 'change_brush.orbit-preview', (new_brush_name) ->
    current_brush = new_brush_name
    if new_brush_name != 'orbit'
      render svg, null
      return

    setup svg, main_events

  # start with orbit brush
  setup svg, main_events

module.exports =
  bind: bind
  cancel: ->
    console.log 'cancelling orbit preview'
    preview = null

d3 = require 'd3'

## Drawing preview links

measure_distance_magnitude = (point1, point2) ->
  # point to point distance without sqrt for comparisions
  pow = Math.pow
  r2 = pow(point1[0] - point2[0], 2) + pow(point1[1] - point2[1], 2)
  return r2

mouse_position = null
time = null
preview = null
closest_orbiter = null
current_brush = 'orbit'

render = (svg, preview) ->
  if current_brush != 'link'
    svg.selectAll('.orbiter')  # reset highlighted orbiter
      .attr('r', 3)
      .style('fill', 'black')
      .attr('stroke', 'black')
  else if closest_orbiter != null
    orbiters = svg.selectAll('.orbiter')

    # highlight nearest orbiter
    closest_orbiter.attr('r', 10).style('fill', 'red').attr('stroke', 'red')

    # unhighlight others
    orbiters.filter(
      (d, i) ->
        if this == closest_orbiter.node()
          return null
        return this
    ).attr('r', 3).style('fill', 'black').attr('stroke', 'black')

  if preview == null
    svg.select('#link-brush').style('display', 'none')
  else
    svg.select('#link-brush')
      .datum(preview)
        .style('display', '')
        .style('stroke', 'gray')
        .style('stroke-width', 3)
        .attr('x1', (d) -> d.start.orbiter.absolute.x)
        .attr('y1', (d) -> d.start.orbiter.absolute.y)
        .attr('x2', (d) -> d.end.orbiter.absolute.x)
        .attr('y2', (d) -> d.end.orbiter.absolute.y)


setup = (svg, main_events) ->

  select_closest_orbiter = ->
    if mouse_position == null
      return null

    orbits = []

    orbiters = svg.selectAll('.orbiter')

    orbiters.each(
      (d) ->
        d.orbiter.distanceToMouseSquared =
          measure_distance_magnitude mouse_position, [d.orbiter.absolute.x, d.orbiter.absolute.y]
        orbits.push d
    )

    # TODO: add .remove from d3.geom.quadtree and use quadtree?
    closest_distance = d3.min orbits, (d) -> d.orbiter.distanceToMouseSquared

    closest_orbiter = orbiters.filter(
      (d, i) ->
        if d.orbiter.distanceToMouseSquared == closest_distance
          return this
        else
          return null
    )
    return closest_orbiter

  main_events.on 'mouse_position.link-preview', (new_mouse_position) ->
    mouse_position = new_mouse_position

  main_events.on 'time.link-preview', (new_time) ->
    time = new_time
    if current_brush == 'link'
      closest_orbiter = select_closest_orbiter svg, preview
      render svg, preview

  svg.on 'mousedown.preview', ->
    # Don't track right and middle clicks
    if d3.event.which != 1
      return

    # save the highlighted nearest orbiter and pause
    if not closest_orbiter
      console.error "No closest orbiter."
      return

    preview = {
      type: 'link'
      start: closest_orbiter.node().__data__
      end: closest_orbiter.node().__data__
    }

    console.log 'link start', preview

  svg.on 'mousemove.preview', ->
    if preview == null
      return

    preview.end = closest_orbiter.node().__data__

  svg.on 'mouseup.preview', ->
    if preview == null
      return

    preview.end = closest_orbiter.node().__data__
    console.log 'link end', preview

    # save link
    # TODO: check start and end orbits are different
    # TODO: check that link doesn't already exist
    main_events.save preview
    preview = null


bind = (svg, brush_change_events, main_events) ->

  # Update our brush when it changes and clear the current brush
  brush_change_events.on 'change_brush.link-preview', (new_brush_name) ->
    current_brush = new_brush_name
    if new_brush_name != 'link'
      preview = null
      render svg, preview
      return

    setup svg, main_events


module.exports =
  bind: bind
  cancel: ->
    console.log 'cancelling link preview'
    preview = null

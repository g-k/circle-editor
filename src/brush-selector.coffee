d3 = require 'd3'
Mousetrap = require './mousetrap.js'

## brush selector UI

# bind brush options for drawing a orbit or a link between orbits
# show exactly one active brush
# select brush with mouse
# select brush with keyboard shortcuts (c for orbit and l for link)
# highlight keyboard shortcut with css


state = [
    {name: 'orbit', active: true}, # default to drawing orbits
    {name: 'link'}
]

# Fire change_brush events to draw the correct preview
# sends the brush name
dispatcher = d3.dispatch "change_brush"

activate_button = (buttons, name) ->
  # Remove existing active button data
  buttons.filter((d) -> d.active == true)
    .each((d) -> d.active = false)

  # Set newly active button
  buttons.filter((d) -> d.name == name)
    .each((d) -> d.active = true)

  # Update the DOM
  buttons.classed('pure-button-active', (d) -> d.active == true)


bind = (selector) ->
  buttons = d3.select(selector)
    .selectAll('a.brush')
      .data(state)

  # Update the active button when the brush changes
  dispatcher.on 'change_brush.activate', (brush_name) ->
    activate_button buttons, brush_name

  return buttons


module.exports =
  bind: bind
  events: dispatcher
  select_orbit_brush: ->
    dispatcher.change_brush 'orbit'
  select_link_brush: ->
    dispatcher.change_brush 'link'
  _activate_button: activate_button

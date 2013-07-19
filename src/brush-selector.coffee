d3 = require 'd3'
Mousetrap = require './mousetrap.js'

## brush selector UI

# bind brush options for drawing a orbit or a link between orbits
# show exactly one active brush
# select brush with mouse
# select brush with keyboard shortcuts (c for orbit and l for link)
# highlight keyboard shortcut with css


state = [
    {name: 'Orbit', active: true}, # default to drawing orbits
    {name: 'Link'}
]


activate_button = (buttons, name) ->
  # Remove existing active button data
  buttons.filter((d) -> d.active == true)
    .each((d) -> d.active = false)

  # Set newly active button
  buttons.filter((d) -> d.name == name)
    .each((d) -> d.active = true)

  # Update the DOM
  buttons.classed('pure-button-active', (d) -> d.active == true)


# Fire change_brush events to draw the correct preview
# sends the brush name
dispatcher = d3.dispatch "change_brush"


bind = (selector) ->
  buttons = d3.select(selector)
    .selectAll('a')
      .data(state)

  # Update the active button when the brush changes
  dispatcher.on 'change_brush.activate', (brush_name) ->
    activate_button buttons, brush_name

  buttons.on 'click', (button) ->
    dispatcher.change_brush button.name

  Mousetrap.bind ['o', 'O'], ->
    dispatcher.change_brush 'Orbit'

  Mousetrap.bind ['l', 'L'], ->
    dispatcher.change_brush 'Link'

  return dispatcher


module.exports =
  bind: bind
  state: state

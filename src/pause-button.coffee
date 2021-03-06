d3 = require 'd3'

## Pause button
# should show pause or unpause (text or icon)
# on click should toggle pause/unpause
# on hover highlight as active and button-like

# assuming we start running/unpaused

module.exports =
  bind: (selector, pause_events) ->
    button = d3.select(selector)
    label = button.select '.label'

    # highlight as active on hover
    button.on 'mouseover', ->
      button.classed('pure-button-active', true)

    button.on 'mouseout', ->
      button.classed('pure-button-active', false)

    pause_events.on 'pause.button', ->
      label.text label.text().replace 'pause', 'unpause'

    pause_events.on 'unpause.button', ->
      label.text label.text().replace 'unpause', 'pause'

    return button

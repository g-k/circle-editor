d3 = require 'd3'

## Pause button
# should show pause or unpause (text or icon)
# on click should toggle pause/unpause
# on hover highlight as active and button-like

# assuming we start running/unpaused

module.exports =
  bind: (selector, pause_events, toggler) ->
    button = d3.select(selector)

    # highlight as active on hover
    button.on 'mouseover', ->
      button.classed('pure-button-active', true)

    button.on 'mouseout', ->
      button.classed('pure-button-active', false)

    button.on 'click', toggler

    pause_events.on 'pause.button', ->
      button.text 'unpause'

    pause_events.on 'unpause.button', ->
      button.text 'pause'

d3 = require 'd3'

## Pause/Resume control

dispatcher = d3.dispatch "pause", "unpause" # notify render loop to pause/unpause animation
seconds = 0 # elapsed time paused and unpaused
window.paused = paused = false # paused or not
pauses = []  # lists of pause start and end global times
total_pause_elapsed = 0
pause_start = null

## Always be animating to provide user feedback

dispatcher.on "pause", (seconds) ->
  console.log 'pause start', seconds
  pauses.push [seconds]  # push pause start
  pause_start = seconds

  # start a timer to measure pause duration
  d3.timer (pause_elapsed) ->
    dispatcher.on "unpause", (seconds) ->
      console.log 'pause end', seconds
      pauses[pauses.length-1].push seconds # add pause end

      total_pause_elapsed += seconds - pause_start

    if paused
      return false  # keep timing while still paused
    else
      return true


module.exports =
  run: (update) ->
    # Run the update loop with pauses

    d3.timer (elapsed) ->
      # global space key handler depends on not modifying this
      seconds = (elapsed / 1000) # ms -> s

      # depends on dispatcher completing before setting the global pause variable
      # ignore time spent paused
      if paused
        update pause_start - total_pause_elapsed
      else
        update seconds - total_pause_elapsed

      return false  # keep going

  pause_resume: ->
    event.preventDefault()  # don't scroll

    if paused
      dispatcher.unpause seconds
    else
      dispatcher.pause seconds

    paused = not paused

  events: dispatcher

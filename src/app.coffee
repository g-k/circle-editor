d3 = require 'd3'
Mousetrap = require './mousetrap.js'

pow = Math.pow
cos = Math.cos
sin = Math.sin


circles = []  # any circles to draw go here
connections = [] # connections between circle orbiters as refs to circles
# expect a sparse graph since people should be too lazy to connect all
# the circles to each other

added = [] # stack of circles or connections added
redo = [] # stack of things to read if new circles or connections aren't drawn


circle_candidate = null  # data about a circle candidate if dragged out

speed = 100  # linear velocity of particles in orbits
dispatcher = d3.dispatch "pause", "unpause" # notify render loop to pause/unpause animation
seconds = 0 # elapsed time paused and unpaused
paused = false # paused or not
window.pauses = pauses = []  # lists of pause start and end global times

# expose vars for debugging
window.d3 = d3
window.circles = circles
window.connections = connections


## Random utility functions

measureDistance = (point1, point2) ->
  # point to point line distance for two objects with x and y
  # attributes
  r2 = pow(point1.x - point2.x, 2) + pow(point1.y - point2.y, 2)
  return pow r2, 0.5

line = d3.svg.line()


## Initialize svg element, base groups, and hidden candidate circle for new circles

svg = d3.select('body')
  .append('svg')
    .style('position', 'absolute')
    .style('top', 0)
    .style('left', 0)
# everything except IE8: http://compatibility.shwups-cms.ch/de/home/?search=innerWidth
    .attr('height', window.innerHeight)
    .attr('width', window.innerWidth)
# http://stackoverflow.com/questions/9400615/whats-the-best-way-to-make-a-d3-js-visualisation-layout-responsive
    .attr('viewBox', "500 500 #{window.innerWidth} #{window.innerHeight}")
    .attr('preserveAspectRatio', 'xMinYMin')

d3.select(window).on 'resize', ->
  svg.attr('height', window.innerHeight)
     .attr('width', window.innerWidth)


# saved circles
circles_group = svg.append('g')
  .attr('class', 'circles')

connections_group = svg.append('g')
  .attr('class', 'connections')

# initialize circle candidate (might be better to do this with canvas)
candidate_group = svg.append('g')
  .attr('class', 'candidate')
  .attr('display', 'none') # hide until click

candidate_center = candidate_group.append('circle')
  .attr('class', 'center')
  .attr('cx', 0)
  .attr('cy', 0)
  .attr('r', 2)
  .attr('fill', 'gray')

candidate_edge = candidate_group.append('circle')
  .attr('cx', 0)
  .attr('cy', 0)
  .attr('r', 30)
  .attr('fill', 'none')
  .attr('stroke', 'gray')
  .attr('stroke-width', 1)
  .attr('display', 'none') # hide until drag


## Drawing circles

svg.on 'mousedown', ->
  [x, y] = d3.mouse this  # get position in svg
  candidate_group
    .attr('transform', "translate(#{x},#{y})")
    .attr('display', '')

  circle_candidate = {x: x, y: y}

svg.on 'mousemove', ->
  if circle_candidate == null
    return

  [x, y] = d3.mouse this
  r = measureDistance circle_candidate, {x: x, y: y}

  candidate_edge
    .attr('r', r)
    .attr('display', '')

svg.on 'mouseup', ->
  # Add to drawn circles and draw it
  [x, y] = d3.mouse this
  # Set to 1 to avoid NaN cx and cy after dividing by zero
  circle_candidate.r = measureDistance(circle_candidate, {x: x, y: y}) or 1

  circles.push circle_candidate
  added.push {type: 'circle', value: circle_candidate}
  redo.length = 0  # can't redo after creating new stuff

  # Automatically connect the two most recent circles
  # (need to be able to redo)
  if circles.length > 1
    new_connection = [circles[circles.length-2], circles[circles.length-1]]
    connections.push new_connection
    added.push {type: 'connection', value: new_connection}

  # hide candidate
  candidate_group.attr('display', 'none')
  candidate_edge.attr('display', 'none')

  # clear for next mouse event
  circle_candidate = null


## Keybindings

# undo with ctrl+z (or cmd+z for osx)
Mousetrap.bind 'mod+z', ->
  item = added.pop()
  console.log 'undo:', item

  if item != undefined
    redo.push item

    if item.type == 'circle'
      circles.pop()
    else if item.type == 'connection'
      connections.pop()


Mousetrap.bind 'shift+mod+z', ->
  item = redo.pop()
  console.log 'redo:', item

  if item != undefined
    added.push item

    if item.type == 'circle'
      circles.push item.value
    else if item.type == 'connection'
      connections.push item.value


Mousetrap.bind 'space', (event) ->
  event.preventDefault() # don't scroll

  if paused
    dispatcher.unpause seconds
  else
    dispatcher.pause seconds

  paused = not paused


## Update/render loop

# connect lines from circles in order drawn (keep it simple
update = (t) ->
  # console.log 'circles', circles

  selection = circles_group.selectAll('g')
    .data(circles)

  selection.exit()
    .remove()

  g = selection.enter()
        .append('g')
          .attr('transform', (d) -> "translate(#{d.x},#{d.y})")

  g.append('circle')
    .attr('cx', 0)
    .attr('cy', 0)
    .attr('r', (d) -> d.r)
    .attr('fill', "none")
    .attr('stroke', 'black')
    .attr('stroke-witdh', 1)

  g.append('circle')
    .attr('class', 'orbiter')
    .attr('cx', 0)
    .attr('cy', 0)
    .attr('r', 3)
    .attr('fill', "black")
    .attr('stroke', 'black')
    .attr('stroke-witdh', 1)

  selection.select('.orbiter')
    .attr('cx', (d) -> cos(speed / d.r * t) * d.r )
    .attr('cy', (d) -> sin(speed / d.r * t) * d.r )

  locate_orbiter = (circle) ->
    # for a circle return its orbiter location
    # floor to make debugging easier
    return [
      (circle.x + cos(speed / circle.r * t) * circle.r) | 0,
      (circle.y + sin(speed / circle.r * t) * circle.r) | 0
    ]

  orbit_line = (d) ->
    locs = d.map locate_orbiter
    return line locs

  # draw a path from each orbiter back to beginning
  paths = connections_group.selectAll('path')
    .data(connections)
      .attr('d', orbit_line)

  paths.enter()
    .append('path')
      .attr('stroke', 'black')
      .attr('shape-rendering', 'optimizeSpeed')  # https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/shape-rendering
      .attr('d', orbit_line)

  paths.exit().remove()


## Always be animating to provide feedback

dispatcher.on "pause", (seconds) ->
  console.log 'pause start', seconds
  pauses.push [seconds] # push pause start

  # start a timer to measure pause duration
  d3.timer (pause_elapsed) ->
    dispatcher.on "unpause", (seconds) ->
      console.log 'pause end', seconds
      pauses[pauses.length-1].push seconds # add pause end

    if paused
      return false  # keep timing while still paused
    else
      return true


d3.timer (elapsed) ->
  # global space key handler depends on not modifying this
  seconds = (elapsed / 1000) # ms -> s

  # figure out how much time was spent in pauses
  # computing is linear in time with number of pauses
  if pauses.length
    total_pause_elapsed = pauses.map(
        (pause_duration) ->
          if pause_duration.length != 2 # ignore pauses that haven't ended
            return 0
          pause_duration[1] - pause_duration[0]
      ).reduce((x, y) -> x + y)
  else
    total_pause_elapsed = 0

  # depends on dispatcher completing before setting the global pause variable
  # ignore time spent paused
  if paused
    pause_start = pauses[pauses.length-1][0] # linear with pauses
    update pause_start - total_pause_elapsed
  else
    update seconds - total_pause_elapsed

  return false  # keep going


update 0  # Run

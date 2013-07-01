d3 = require 'd3'
Mousetrap = require './mousetrap.js'

pow = Math.pow
cos = Math.cos
sin = Math.sin


measureDistance = (point1, point2) ->
  # point to point line distance for two objects with x and y
  # attributes
  r2 = pow(point1.x - point2.x, 2) + pow(point1.y - point2.y, 2)
  return pow r2, 0.5


svg = d3.select('body')
  .append('svg')
    .attr('height', document.height)
    .attr('width', document.width)


circles = []  # any circles to draw go here
connections = [] # connections between circle orbiters as refs to circles
# expect a sparse graph since people should be too lazy to connect all
# the circles to each other

redo = [] # stack of circles to redo if new circles aren't drawn

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


# data about a circle candidate if dragged out
circle_candidate = null

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
  redo.length = 0  # can't redo after creating new stuff

  # Automatically connect the two most recent circles
  # (need to be able to redo)
  if circles.length > 1
    connections.push [circles[circles.length-2], circles[circles.length-1]]

  # hide candidate
  candidate_group.attr('display', 'none')
  candidate_edge.attr('display', 'none')

  # clear for next mouse event
  circle_candidate = null

# undo with ctrl+z (or cmd+z for osx)
Mousetrap.bind 'mod+z', ->
  redo_circle = circles.pop()
  if redo_circle
    redo.push redo_circle

Mousetrap.bind 'shift+mod+z', ->
  circle = redo.pop()
  if circle != undefined
    circles.push circle


window.pause = false
Mousetrap.bind 'space', (event) ->
  event.preventDefault() # don't scroll
  window.pause = not window.pause

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

  speed = 100

  selection.select('.orbiter')
    .attr('cx', (d) -> cos(speed / d.r * t) * d.r )
    .attr('cy', (d) -> sin(speed / d.r * t) * d.r )

  line = d3.svg.line()

  locate_orbiter = (circle) ->
    # for a circle return its orbiter location
    # floor to make debugging easier
    return [
      (circle.x + cos(speed / circle.r * t) * circle.r) | 0,
      (circle.y + sin(speed / circle.r * t) * circle.r) | 0
    ]

  orbit_line = (d) ->
    locs = d.map locate_orbiter
    # window.pause = true
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


last = 0
d3.timer (elapsed) ->
  if window.pause
    seconds = last
    return false  # keep going

  seconds = (elapsed / 1000)

  update seconds

  last = seconds
  return false  # keep going

update last

# expose for debugging
window.d3 = d3
window.circles = circles
window.connections = connections

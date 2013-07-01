d3 = require 'd3'
Mousetrap = require './mousetrap.js'


measureDistance = (point1, point2) ->
  # point to point line distance for two objects with x and y
  # attributes
  pow = Math.pow
  r2 = pow(point1.x - point2.x, 2) + pow(point1.y - point2.y, 2)
  return pow(r2, 0.5)


svg = d3.select('body')
  .append('svg')
    .attr('height', document.height)  # TODO: handle window resize?
    .attr('width', document.width)


circles = []  # any circles to draw go here

# saved circles
circles_group = svg.append('g')
  .attr('class', 'circles')


# initialize circle candidate (might be better to do this with canvas)
# (todo: look up name for these UI things candidate is terrible)
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
  circle_candidate.r = measureDistance circle_candidate, {x: x, y: y}

  circles.push circle_candidate
  draw_circles()

  # hide candidate
  candidate_group.attr('display', 'none')
  candidate_edge.attr('display', 'none')

  # clear for next mouse event
  circle_candidate = null

# undo with ctrl+z (or cmd+z for osx)
# d3 key events?
Mousetrap.bind 'mod+z', ->
  circles.pop()
  draw_circles()


draw_circles = ->
  console.log 'circles', circles

  selection = circles_group.selectAll('g')
    .data(circles)

  g = selection
      .enter()
        .append('g')
          .attr('transform', (d) -> "translate(#{d.x},#{d.y})")

  g.append('circle')
    .attr('cx', 0)
    .attr('cy', 0)
    .attr('r', (d) -> d.r)
    .attr('fill', "none")
    .attr('stroke', 'black')
    .attr('stroke-witdh', 1)

  # Start the bead at a random angle around the circle (show candidate
  # there too? start from mouse dragend position instead?)  for all
  # entering circles (should be one)
  cos = Math.cos
  sin = Math.sin
  angle = Math.random() * Math.PI * 2

  g.append('circle')
    .attr('cx', (d) -> cos(angle) * d.r )
    .attr('cy', (d) -> sin(angle) * d.r )
    .attr('r', 3)
    .attr('fill', "black")
    .attr('stroke', 'black')
    .attr('stroke-witdh', 1)
    # use d3.timer and update / animation loop instead
    .transition()
      .duration(2000)  # try bumping really high
        .ease('linear')
        # non-constant angular velocity (smaller is slower)
        # choppy for large circles?
        .attrTween('cx', (d) ->
          # d3.ease 'circle' ?
          return (t) -> cos(t * Math.PI * 2) * d.r
        )
        .attrTween('cy', (d) ->
          return (t) -> sin(t * Math.PI * 2) * d.r
        )

  selection
    .exit().remove()


window.d3 = d3

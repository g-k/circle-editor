d3 = require 'd3'
Mousetrap = require './mousetrap.js'

SVG = require './resizable-svg.coffee'
BrushSelector = require './brush-selector.coffee'
Previews = require './previews.coffee'
Undo = require './undo.coffee'
Pause = require './pause.coffee'
PauseButton = require './pause-button.coffee'


cos = Math.cos
sin = Math.sin

orbits = []  # any orbits to draw go here
links = [] # links between orbit orbiters as indexes to orbits
orbiters = [] # for sharing, computed from orbits

svg = SVG.init()

brush_change_events = BrushSelector.bind '#menu'
PauseButton.bind '#pause-button', Pause.events, Pause.pause_resume
save_events = Previews.bind brush_change_events, svg, orbiters
undo_events = Undo.init save_events

d3.select('#undo-button').on 'click', Undo.undo
d3.select('#redo-button').on 'click', Undo.redo

## Keybindings

Mousetrap.bind ['o', 'O'], BrushSelector.select_orbit_brush
Mousetrap.bind ['l', 'L'], BrushSelector.select_link_brush

# undo with ctrl+z (or cmd+z for osx)
Mousetrap.bind 'mod+z', Undo.undo
Mousetrap.bind 'shift+mod+z', Undo.redo

Mousetrap.bind 'space', Pause.pause_resume


save_events.on 'save.main', (preview) ->
  console.log 'saving:', preview

  if preview.type == 'orbit'
    orbits.push preview
  else if preview.type == 'link'
    links.push preview

undo_events.on "undo.main", (item) ->
  if item.type == 'orbit'
    orbits.pop()
  else if item.type == 'link'
    links.pop()

undo_events.on "redo.main", (item) ->
  if item.type == 'orbit'
    orbits.push item
  else if item.type == 'link'
    links.push item


## Update/render loop

orbits_group = svg.select('.orbits')
links_group = svg.select('.links')

speed = 100  # linear velocity of particles in orbits

line = d3.svg.line()

# connect lines from orbits in order drawn (keep it simple)
update = (t) ->
  selection = orbits_group.selectAll('g')
    .data(orbits)

  selection.exit()
    .remove()

  g = selection.enter()
        .append('g')
          .attr('transform', (d) -> "translate(#{d.x},#{d.y})")

  g.append('circle')
    .attr('cx', 0)
    .attr('cy', 0)
    .attr('r', (d) -> d.r)

  g.append('circle')
    .attr('class', 'orbiter')
    .attr('cx', 0)
    .attr('cy', 0)
    .attr('r', 3)

  selection.select('.orbiter')
    .attr('cx', (d) -> cos(speed / d.r * t) * d.r )
    .attr('cy', (d) -> sin(speed / d.r * t) * d.r )

  locate_orbiter = (orbit) ->
    # for a orbit return its orbiter location
    # floor to make a bit faster and debugging easier
    return [
      (orbit.x + cos(speed / orbit.r * t) * orbit.r) | 0,
      (orbit.y + sin(speed / orbit.r * t) * orbit.r) | 0
    ]

  orbits_group
    .selectAll('.orbiter')

  # copy to orbiters in place to provide it to the link handler
  new_orbiters = orbits.map locate_orbiter

  args = [0, new_orbiters.length]
  args.push.apply args, new_orbiters

  orbiters.splice.apply orbiters, args


  orbit_line = (d) ->
    # gets locations for first and second orbiter
    return line [orbiters[d[0]], orbiters[d[1]]]

  # draw a path from each orbiter back to beginning
  paths = links_group.selectAll('path')
    .data(links)
      .attr('d', orbit_line)

  paths.enter()
    .append('path')
      .attr('stroke', 'black')
      .attr('shape-rendering', 'optimizeSpeed')  # https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/shape-rendering
      .attr('d', orbit_line)

  paths.exit().remove()

Pause.run update

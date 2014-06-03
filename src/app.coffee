d3 = require 'd3'
Mousetrap = require './mousetrap.js'

SVG = require './resizable-svg.coffee'
BrushSelector = require './brush-selector.coffee'
OrbitPreview = require './orbit-preview.coffee'
LinkPreview = require './link-preview.coffee'
Undo = require './undo.coffee'
Pause = require './pause.coffee'
PauseButton = require './pause-button.coffee'


orbits = []  # any orbits to draw go here
links = [] # links between orbit orbiters as indexes to orbits

brush_buttons = BrushSelector.bind '#menu'
pause_button = PauseButton.bind '#pause-button', Pause.events

main_events = d3.dispatch "time", "mouse_position", "save"

svg = SVG.init()

Undo.init main_events

# click and drag to draw an orbit or link (modes)
OrbitPreview.bind svg, BrushSelector.events, main_events
LinkPreview.bind svg, BrushSelector.events, main_events


## Keybindings

Mousetrap.bind ['o', 'O'], BrushSelector.select_orbit_brush
Mousetrap.bind ['l', 'L'], BrushSelector.select_link_brush

Mousetrap.bind 'mod+z', Undo.undo  # undo with ctrl+z (or cmd+z for osx)
Mousetrap.bind 'shift+mod+z', Undo.redo

Mousetrap.bind 'space', Pause.pause_resume


Mousetrap.bind 'esc', LinkPreview.cancel
Mousetrap.bind 'esc', OrbitPreview.cancel

## Mousebinding

brush_buttons.on 'click.main', (button) ->
  BrushSelector.events.change_brush button.name

d3.select('#undo-button').on 'click.main', Undo.undo
d3.select('#redo-button').on 'click.main', Undo.redo

pause_button.on 'click.main', Pause.pause_resume

## Event generation and routing

svg.on 'mousemove.main', ->
  main_events.mouse_position d3.mouse this

main_events.on 'save.main', (preview) ->
  console.log 'saving:', preview

  if preview.type == 'orbit'
    orbits.push preview
  else if preview.type == 'link'
    links.push preview

Undo.events.on "undo.main", (item) ->
  if item.type == 'orbit'
    orbits.pop()
  else if item.type == 'link'
    links.pop()

Undo.events.on "redo.main", (item) ->
  if item.type == 'orbit'
    orbits.push item
  else if item.type == 'link'
    links.push item


## Update/render loop

orbits_group = svg.select('.orbits')
links_group = svg.select('.links')

speed = 100  # linear velocity of particles in orbits
line = d3.svg.line()
  .x((d) -> d.x)
  .y((d) -> d.y)


update = (t) ->
  main_events.time t

  cos = Math.cos
  sin = Math.sin

  orbits = orbits.map (d) ->
    # add orbiter positions
    d.orbiter = {
      x: cos(speed / d.r * t) * d.r | 0
      y: sin(speed / d.r * t) * d.r | 0
    }
    # absolute position
    d.orbiter.absolute = {
      x: d.x + d.orbiter.x
      y: d.y + d.orbiter.y
    }
    return d

  selection = orbits_group.selectAll('g')
    .data(orbits)

  selection.exit().remove()

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

  orbiters = selection.select('.orbiter')
    .attr('cx', (d) -> d.orbiter.x)
    .attr('cy', (d) -> d.orbiter.y)

  link_path = (d) ->
    # gets locations for first and second orbiter

    return line [d.start.orbiter.absolute, d.end.orbiter.absolute]

  # draw a path from each orbiter back to beginning
  paths = links_group.selectAll('path')
    .data(links)
      .attr('d', link_path)

  paths.enter()
    .append('path')
      .attr('stroke', 'black')
      .attr('shape-rendering', 'optimizeSpeed')  # https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/shape-rendering
      .attr('d', orbit_line)

  paths.exit().remove()

Pause.run update

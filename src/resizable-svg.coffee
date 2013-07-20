d3 = require 'd3'

## Set svg element size

init = ->
  svg = d3.select('svg')
# everything except IE8: http://compatibility.shwups-cms.ch/de/home/?search=innerWidth
    .attr('height', window.innerHeight)
    .attr('width', window.innerWidth)
# http://stackoverflow.com/questions/9400615/whats-the-best-way-to-make-a-d3-js-visualisation-layout-responsive
    .attr('viewBox', "500 500 #{window.innerWidth} #{window.innerHeight}")
    .attr('preserveAspectRatio', 'xMinYMin')

  d3.select(window).on 'resize', ->
    svg.attr('height', window.innerHeight)
       .attr('width', window.innerWidth)

  return svg


module.exports = init: init

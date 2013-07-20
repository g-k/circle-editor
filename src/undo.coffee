d3 = require 'd3'
Mousetrap = require "./mousetrap.js"

added = [] # stack of orbits or links added
redo = [] # stack of things to read if new orbits or links aren't drawn

dispatcher = d3.dispatch "undo", "redo"


module.exports =
  init: (input) ->
    input.on "save.undo", (item) ->
      added.push item
      redo.length = 0  # can't redo after creating new stuff

    return dispatcher

  undo: ->
    item = added.pop()
    console.log 'undo:', item

    if item != undefined
      redo.push item

      dispatcher.undo item

  redo: ->
    item = redo.pop()
    console.log 'redo:', item

    if item != undefined
      added.push item

      dispatcher.redo item

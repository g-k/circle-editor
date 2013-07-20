An editor for drawing and connecting orbiting points

Based on examples:

http://blog.matthen.com/post/53438334849/a-simple-animation-showing-how-connecting-points
http://beesandbombs.tumblr.com/post/48795316394/secrets-of-the-universe

TODO:

* snap links to nearest orbits
* disable line brush when < 2 circles since no circles to connect
* undo/redo pictures
* pick orbit velocity, direction, and relative phase
* select links and orbits
* delete links and orbits

* only link/unlink when paused with snapping? (link as separate layer? mori or oplog?)
* save and reload? (serialize orbits and links and use data url?)
* export to gif? interactive SVG?
* where to start the orbiter?
  * at a random angle around the circle?
  * show candidate there too?
  * from mouse dragend position?
* multiple orbiters per circle (or draw two circles?)
* allow arbitrary orbits (use svg paths and animate along path?)
* cleaner orbits with d3 svg.line.radial?
* rename preview to proper UI thing
* kind of MVC framework for multiple pages as d3.datum() and sub selections (how to update data?)
* debounce resize event if it proves annoying and eats CPU
* <li><a>backspace or delete to remove item? (requires selection) should it trigger undo?
* pause/unpause timeline?

Bugs:

* mouseend when dragging over something outside the canvas? (mouseexit event when it leaves the svg?)
  * when dragging a preview and mouseout then mouseup occurs off the screen preview should go away

Done:
* show drag preview
* kill current preview on brush change
* resize svg on window resize
* if computing total_pause_elapsed is slowing render loop down cache as a single value and add most recent pause
* pause/unpause buttons

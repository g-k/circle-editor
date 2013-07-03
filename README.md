An editor for drawing and connecting orbiting points

Based on examples:

http://blog.matthen.com/post/53438334849/a-simple-animation-showing-how-connecting-points
http://beesandbombs.tumblr.com/post/48795316394/secrets-of-the-universe

TODO:

* only connect/disconnect when paused with snapping? (connections as separate layer? mori or oplog?)
* save and reload? (serialize circles and connections and use data url?)
* export to gif?
* where to start the orbiter?
  * at a random angle around the circle?
  * show candidate there too?
  * from mouse dragend position?
* resize svg on window resize?
* multiple orbiters per circle (or draw two circles?)
* allow arbitrary orbits (use svg paths and animate along path?)
* cleaner with d3 svg.line.radial?
* rename candidate to proper UI thing
* kind of MVC framework for multiple pages as d3.datum() and sub selections (how to update data?)
* debounce resize event if it proves annoying and eats CPU
* if computing total_pause_elapsed is slowing render loop down cache as a single value and add most recent pause

Bugs:

* mouseend when dragging over something outside the canvas? (mouseexit event when it leaves the svg?)

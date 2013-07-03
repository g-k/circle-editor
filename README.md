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

Bugs:

* resuming starts from a different time (keep track of paused elapsed time too and subtract it? run separate timer when paused and switch back?)
* mouseend when dragging over something outside the canvas?
* debounce resize event if it proves annoying and eats CPU

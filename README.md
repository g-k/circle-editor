An editor for drawing and connecting orbiting points

Based on examples:

http://blog.matthen.com/post/53438334849/a-simple-animation-showing-how-connecting-points
http://beesandbombs.tumblr.com/post/48795316394/secrets-of-the-universe

TODO:

* cancel link preview on mouseout (to hide red dot)
* disable undo/redo buttons when nothing to do
* disable link brush when < 2 circles since no circles to connect
* if esc pressed while previewing a change cancel preview (links done, orbits todo)
* when saving link
  * check that link doesn't already exist
* pause to draw links
* draw whole boxes if enough points how to detect intermediate orbiters?
  * pause during swipe?
  * if continuing from last link end add to existing path?
* hide pause/play?
* find and fix memory leaks (run webkit memory profile)
* fix slow frames
* use page visibility API to pause it

* pick orbit velocity, direction, and relative phase
* lines from other lines (like unconed? lerp demo)
* save and load? (serialize orbits and links and use data url? external db or localstorage?)
* export to gif or interactive SVG?
* where to start the orbiter?
  * at a random angle around the circle?
  * show candidate there too?
  * from mouse dragend position?
* cleaner orbits with d3 svg.line.radial?
* rename preview to proper UI thing
* debounce resize event if it proves annoying and eats CPU
* improve closest orbiter to mouse lookup. quadtree? (stress test)

Bugs:

* mouseend when dragging over something outside the canvas? (mouseexit event when it leaves the svg?)
  * when dragging a preview and mouseout then mouseup occurs off the screen preview should go away

Done:

* when saving link
  * check start and end orbits are different
* snap links to nearest orbits (do orbiters so it's more direct manipulation)?
  * what's the best data structure for dynamic 2D location lookup?
  * or reuse browser events?
* show drag preview
* kill current preview on brush change
* resize svg on window resize
* if computing total_pause_elapsed is slowing render loop down cache as a single value and add most recent pause
* pause/unpause buttons
* undo/redo buttons

Not doing:

* undo/redo pictures?
* pause/unpause timeline?
* select links and orbits
* delete links and orbits
* <li><a>backspace or delete to remove item? (requires selection) should it trigger undo?
* kind of MVC framework for multiple pages as d3.datum() and sub selections (how to update data?)
* multiple orbiters per circle (or just draw two circles?)
* allow arbitrary orbits (use svg paths and animate along path?)
* links as separate layer?
* mori or oplog to store more history?

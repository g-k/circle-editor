An editor for drawing and connecting orbiting points

Based on examples:

http://blog.matthen.com/post/53438334849/a-simple-animation-showing-how-connecting-points
http://beesandbombs.tumblr.com/post/48795316394/secrets-of-the-universe


Controls:

Click and drag to draw to orbit radius

ctrl+z to undo
shift+ctrl+z to redo (if nothing has been drawn)
space to pause/resume


TODO:

* only connect/disconnect when paused? (connections as separate layer?)
* save and reload? (serialize circles and connections and use data url?)
* export to gif?
* where to start the orbiter?
  * at a random angle around the circle?
  * show candidate there too?
  * from mouse dragend position?
* resize svg on window resize?
* rename candidte to proper UI thing
* multiple orbiters per circle (or draw two circles?)

Bugs:

* resuming starts from a different time
* undo/redo connections

###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

# This hybrid algorithm was described to me by Robin Houston. It
# begins with the Aldous-Broder algorithm, to fill out the grid,
# and then switches to Wilson's after the grid is about 1/3
# populated.
#
# This gives you better performance than either algorithm by itself,
# but while intuitively it would seem this preserves the properties
# of the original algorithms, it is not yet certain whether this still
# creates a uniform spanning tree or not.
class Maze.Algorithms.Houston extends Maze.Algorithm
  constructor: (maze, options) ->
    super
    @options = options
    @threshold = 2 * @maze.width * @maze.height / 3

  isCurrent: (x, y) -> @worker.isCurrent(x, y)
  isVisited: (x, y) -> @worker.isVisited(x, y)

  step: ->
    unless @worker?
      @worker = new Maze.Algorithms.AldousBroder(@maze, @options)
      @worker.onUpdate(@updateCallback)
      @worker.onEvent(@eventCallback)

    if @worker.remaining < @threshold
      # kind of messy, need to tell the callback listener that
      # current cell is no longer current, since the algorithm
      # is changing.
      [x, y] = [@worker.x, @worker.y]
      delete @worker.x
      delete @worker.y
      @updateAt x, y
      @eventAt x, y

      # switch to wilsons and redefine the step method so it
      # no longer watches the threshold.
      wilsons = new Maze.Algorithms.Wilson(@maze, @options)
      wilsons.onUpdate(@updateCallback)
      wilsons.onEvent(@eventCallback)
      wilsons.state = 1
      wilsons.remaining = @worker.remaining

      @worker = wilsons
      @step = -> @worker.step()

    @worker.step()

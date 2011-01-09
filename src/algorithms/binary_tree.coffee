###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.Algorithms.BinaryTree extends Maze
  IN: 0x10

  constructor: (width, height, options) ->
    super
    @x = 0
    @y = 0

  step: ->
    return false if @y >= @height

    dirs = []
    dirs.push Maze.Direction.N if @y > 0
    dirs.push Maze.Direction.W if @x > 0

    direction = @randomElement(dirs)
    if direction
      nx = @x + Maze.Direction.dx[direction]
      ny = @y + Maze.Direction.dy[direction]

      @carve @x, @y, direction
      @carve nx, ny, Maze.Direction.opposite[direction]

      @callback this, nx, ny
    else
      @carve @x, @y, @IN

    @callback this, @x, @y

    @x++
    if @x >= @width
      @x = 0
      @y++

    return @y < @height

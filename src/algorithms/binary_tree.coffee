###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.Algorithms.BinaryTree extends Maze.Algorithm
  IN: 0x10

  constructor: (maze, options) ->
    super
    @x = 0
    @y = 0

  step: ->
    return false if @y >= @maze.height

    dirs = []
    dirs.push Maze.Direction.N if @y > 0
    dirs.push Maze.Direction.W if @x > 0

    direction = @rand.randomElement(dirs)
    if direction
      nx = @x + Maze.Direction.dx[direction]
      ny = @y + Maze.Direction.dy[direction]

      @maze.carve @x, @y, direction
      @maze.carve nx, ny, Maze.Direction.opposite[direction]

      @callback @maze, nx, ny
    else
      @maze.carve @x, @y, @IN

    @callback @maze, @x, @y

    @x++
    if @x >= @maze.width
      @x = 0
      @y++

    return @y < @maze.height

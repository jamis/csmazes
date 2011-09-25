###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.Algorithms.BinaryTree extends Maze.Algorithm
  IN: 0x1000

  isCurrent: (x, y) -> @x is x and @y is y

  constructor: (maze, options) ->
    super
    @x = 0
    @y = 0

    switch options.input ? "nw"
      when "nw" then @bias = Maze.Direction.N | Maze.Direction.W
      when "ne" then @bias = Maze.Direction.N | Maze.Direction.E
      when "sw" then @bias = Maze.Direction.S | Maze.Direction.W
      when "se" then @bias = Maze.Direction.S | Maze.Direction.E

    @northBias = (@bias & Maze.Direction.N) != 0
    @southBias = (@bias & Maze.Direction.S) != 0
    @eastBias  = (@bias & Maze.Direction.E) != 0
    @westBias  = (@bias & Maze.Direction.W) != 0

  step: ->
    return false if @y >= @maze.height

    dirs = []
    dirs.push Maze.Direction.N if @northBias and @y > 0
    dirs.push Maze.Direction.S if @southBias and @y+1 < @maze.height
    dirs.push Maze.Direction.W if @westBias and @x > 0
    dirs.push Maze.Direction.E if @eastBias and @x+1 < @maze.width

    direction = @rand.randomElement(dirs)
    if direction
      nx = @x + Maze.Direction.dx[direction]
      ny = @y + Maze.Direction.dy[direction]

      @maze.carve @x, @y, direction
      @maze.carve nx, ny, Maze.Direction.opposite[direction]

      @updateAt nx, ny
    else
      @maze.carve @x, @y, @IN

    [oldX, oldY] = [@x, @y]

    @x++
    if @x >= @maze.width
      @x = 0
      @y++
      @eventAt @x, @y

    @updateAt oldX, oldY
    @updateAt @x, @y

    return @y < @maze.height

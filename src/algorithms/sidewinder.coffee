###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.Algorithms.Sidewinder extends Maze.Algorithm
  IN: 0x1000

  isCurrent: (x, y) -> @x is x and @y is y

  constructor: (maze, options) ->
    super
    @x = 0
    @y = 0
    @runStart = 0
    @state = 0

  step: ->
    return false if @y >= @maze.height

    if @y > 0 && (@x+1 >= @maze.width || @rand.nextBoolean())
      cell = @runStart + @rand.nextInteger(@x - @runStart + 1)
      @maze.carve cell, @y, Maze.Direction.N
      @maze.carve cell, @y-1, Maze.Direction.S
      @updateAt cell, @y
      @updateAt cell, @y-1
      @eventAt @x, @y if @x - @runStart > 0
      @runStart = @x + 1
    else if @x+1 < @maze.width
      @maze.carve @x, @y, Maze.Direction.E
      @maze.carve @x+1, @y, Maze.Direction.W
      @updateAt @x, @y
      @updateAt @x+1, @y
    else
      @maze.carve @x, @y, @IN
      @updateAt @x, @y

    [oldX, oldY] = [@x, @y]

    @x++
    if @x >= @maze.width
      @x = 0
      @runStart = 0
      @y++

    @updateAt oldX, oldY
    @updateAt @x, @y

    return @y < @maze.height

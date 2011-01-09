###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.Algorithms.AldousBroder extends Maze
  IN: 0x10

  constructor: (width, height, options) ->
    super
    @state = 0
    @remaining = @width * @height

  isCurrent: (x, y) -> @x == x && @y == y

  startStep: ->
    @x = @rand.nextInteger(@width)
    @y = @rand.nextInteger(@height)
    @carve @x, @y, @IN
    @callback this, @x, @y
    @remaining--
    @state = 1

  runStep: ->
    if @remaining > 0
      for dir in @randomDirections()
        nx = @x + Maze.Direction.dx[dir]
        ny = @y + Maze.Direction.dy[dir]

        if @isValid(nx, ny)
          [x, y, @x, @y] = [@x, @y, nx, ny]

          if @isBlank(nx, ny)
            @carve x, y, dir
            @carve @x, @y, Maze.Direction.opposite[dir]
            @remaining--

            if @remaining == 0
              delete @x
              delete @y

          @callback this, x, y
          @callback this, nx, ny

          break

    return @remaining > 0

  step: ->
    switch @state
      when 0 then @startStep()
      when 1 then @runStep()

    return @remaining > 0

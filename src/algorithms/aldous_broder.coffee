###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.Algorithms.AldousBroder extends Maze.Algorithm
  IN: 0x1000

  constructor: (maze, options) ->
    super
    @state = 0
    @remaining = @maze.width * @maze.height

  isCurrent: (x, y) -> @x == x && @y == y

  startStep: ->
    @x = @rand.nextInteger(@maze.width)
    @y = @rand.nextInteger(@maze.height)
    @maze.carve @x, @y, @IN
    @updateAt @x, @y
    @remaining--
    @state = 1
    @carvedOnLastStep = true

  runStep: ->
    carved = false

    if @remaining > 0
      for dir in @rand.randomDirections()
        nx = @x + Maze.Direction.dx[dir]
        ny = @y + Maze.Direction.dy[dir]

        if @maze.isValid(nx, ny)
          [x, y, @x, @y] = [@x, @y, nx, ny]

          if @maze.isBlank(nx, ny)
            @maze.carve x, y, dir
            @maze.carve @x, @y, Maze.Direction.opposite[dir]
            @remaining--
            carved = true

            if @remaining == 0
              delete @x
              delete @y

          @updateAt x, y
          @updateAt nx, ny

          break

    @eventAt @x, @y if carved != @carvedOnLastStep
    @carvedOnLastStep = carved

    return @remaining > 0

  step: ->
    switch @state
      when 0 then @startStep()
      when 1 then @runStep()

    return @remaining > 0

###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.Algorithms.RecursiveBacktracker extends Maze.Algorithm
  IN:    0x1000
  STACK: 0x2000

  START: 1
  RUN:   2
  DONE:  3

  constructor: (maze, options) ->
    super
    @state = @START
    @stack = []

  step: ->
    switch @state
      when @START then @startStep()
      when @RUN   then @runStep()

    @state != @DONE

  startStep: ->
    [x, y] = [@rand.nextInteger(@maze.width), @rand.nextInteger(@maze.height)]
    @maze.carve x, y, @IN | @STACK
    @updateAt x, y
    @stack.push x: x, y: y, dirs: @rand.randomDirections()
    @state = @RUN
    @carvedOnLastStep = true

  runStep: ->
    loop
      current = @stack[@stack.length - 1]
      dir = current.dirs.pop()

      nx = current.x + Maze.Direction.dx[dir]
      ny = current.y + Maze.Direction.dy[dir]

      if @maze.isValid(nx, ny)
        if @maze.isBlank(nx, ny)
          @stack.push x: nx, y: ny, dirs: @rand.randomDirections()
          @maze.carve current.x, current.y, dir
          @updateAt current.x, current.y

          @maze.carve nx, ny, Maze.Direction.opposite[dir] | @STACK
          @updateAt nx, ny
          @eventAt nx, ny unless @carvedOnLastStep
          @carvedOnLastStep = true
          break

        else if @canWeave(dir, nx, ny)
          @performWeave dir, current.x, current.y, (x, y) =>
            @stack.push(x:x, y:y, dirs:@rand.randomDirections())
            @eventAt x, y unless @carvedOnLastStep
            @maze.carve x, y, @STACK
          @carvedOnLastStep = true
          break

      if current.dirs.length == 0
        @maze.uncarve current.x, current.y, @STACK
        @updateAt current.x, current.y
        @eventAt current.x, current.y if @carvedOnLastStep
        @stack.pop()
        @carvedOnLastStep = false
        break

    @state = @DONE if @stack.length == 0

  isStack: (x, y) -> @maze.isSet(x, y, @STACK)

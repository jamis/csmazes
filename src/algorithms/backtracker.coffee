###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.Algorithms.RecursiveBacktracker extends Maze.Algorithm
  IN:    0x10
  STACK: 0x20

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
    @callback @maze, x, y
    @stack.push x: x, y: y, dirs: @rand.randomDirections()
    @state = @RUN

  runStep: ->
    loop
      current = @stack[@stack.length - 1]
      dir = current.dirs.pop()

      nx = current.x + Maze.Direction.dx[dir]
      ny = current.y + Maze.Direction.dy[dir]

      if @maze.isValid(nx, ny) && @maze.isBlank(nx, ny)
        @stack.push x: nx, y: ny, dirs: @rand.randomDirections()
        @maze.carve current.x, current.y, dir
        @callback @maze, current.x, current.y

        @maze.carve nx, ny, Maze.Direction.opposite[dir] | @STACK
        @callback @maze, nx, ny
        break

      if current.dirs.length == 0
        @maze.uncarve current.x, current.y, @STACK
        @callback @maze, current.x, current.y
        @stack.pop()
        break

    @state = @DONE if @stack.length == 0

  isStack: (x, y) -> @maze.isSet(x, y, @STACK)

###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.RecursiveBacktracker extends Maze
  IN:    0x10
  STACK: 0x20

  START: 1
  RUN:   2
  DONE:  3

  constructor: (width, height, options) ->
    super
    @state = @START
    @stack = []

  step: ->
    switch @state
      when @START then @startStep()
      when @RUN   then @runStep()

    @state != @DONE

  startStep: ->
    [x, y] = [@rand.nextInteger(@width), @rand.nextInteger(@height)]
    @carve x, y, @IN | @STACK
    @callback this, x, y
    @stack.push x: x, y: y, dirs: @randomDirections()
    @state = @RUN

  runStep: ->
    loop
      current = @stack[@stack.length - 1]
      dir = current.dirs.pop()

      nx = current.x + Maze.Direction.dx[dir]
      ny = current.y + Maze.Direction.dy[dir]

      if @isValid(nx, ny) && @isBlank(nx, ny)
        @stack.push x: nx, y: ny, dirs: @randomDirections()
        @carve current.x, current.y, dir
        @callback this, current.x, current.y

        @carve nx, ny, Maze.Direction.opposite[dir] | @STACK
        @callback this, nx, ny
        break

      if current.dirs.length == 0
        @uncarve current.x, current.y, @STACK
        @callback this, current.x, current.y
        @stack.pop()
        break

    @state = @DONE if @stack.length == 0

  isStack: (x, y) -> @isSet(x, y, @STACK)

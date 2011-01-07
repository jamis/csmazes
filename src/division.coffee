###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.RecursiveDivision extends Maze
  HORIZONTAL: 1
  VERTICAL:   2

  constructor: (width, height, options) ->
    super
    @stack = [ x: 0, y: 0, width: @width, height: @height ]

  chooseOrientation: (width, height) ->
    if width < height
      @HORIZONTAL
    else if height < width
      @VERTICAL
    else if @rand.nextBoolean()
      @HORIZONTAL
    else
      @VERTICAL

  step: ->
    if @stack.length > 0
      region = @stack.pop()
      horizontal = @chooseOrientation(region.width, region.height) == @HORIZONTAL

      # where will the wall be drawn?
      wx = region.x + (if horizontal then 0 else @rand.nextInteger(region.width-2))
      wy = region.y + (if horizontal then @rand.nextInteger(region.height-2) else 0)

      # where will the passage through the wall exist?
      px = wx + (if horizontal then @rand.nextInteger(region.width) else 0)
      py = wy + (if horizontal then 0 else @rand.nextInteger(region.height))

      # what direction will the wall be drawn?
      dx = if horizontal then 1 else 0
      dy = if horizontal then 0 else 1

      # how long will the wall be?
      length = if horizontal then region.width else region.height

      # what direction is perpendicular to the wall?
      dir = if horizontal then Maze.Direction.S else Maze.Direction.E
      odir = Maze.Direction.opposite[dir]

      while length > 0
        if wx != px || wy != py
          @carve wx, wy, dir
          @callback this, wx, wy

          nx = wx + Maze.Direction.dx[dir]
          ny = wy + Maze.Direction.dy[dir]
          @carve nx, ny, odir
          @callback this, nx, ny

        wx += dx
        wy += dy
        length -= 1

      width = if horizontal then region.width else wx - region.x + 1
      height = if horizontal then wy - region.y + 1 else region.height
      if width >= 2 && height >= 2
        @stack.push x: region.x, y: region.y, width: width, height: height

      x = if horizontal then region.x else wx + 1
      y = if horizontal then wy + 1 else region.y
      width = if horizontal then region.width else region.x + region.width - wx - 1
      height = if horizontal then region.y + region.height - wy - 1 else region.height
      if width >= 2 && height >= 2
        @stack.push x: x, y: y, width: width, height: height

    return @stack.length > 0

###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.Algorithms.RecursiveDivision extends Maze.Algorithm
  CHOOSE_REGION: 0
  MAKE_WALL    : 1
  MAKE_PASSAGE : 2

  HORIZONTAL: 1
  VERTICAL:   2

  isCurrent: (x, y) ->
    @region? and
      @region.x <= x < @region.x + @region.width and
      @region.y <= y < @region.y + @region.height

  constructor: (maze, options) ->
    super
    @stack = [ x: 0, y: 0, width: @maze.width, height: @maze.height ]
    @state = @CHOOSE_REGION

  chooseOrientation: (width, height) ->
    if width < height
      @HORIZONTAL
    else if height < width
      @VERTICAL
    else if @rand.nextBoolean()
      @HORIZONTAL
    else
      @VERTICAL

  updateRegion: (region) ->
    for y in [0...region.height]
      for x in [0...region.width]
        @updateAt region.x+x, region.y+y

  step: ->
    switch @state
      when @CHOOSE_REGION then @chooseRegion()
      when @MAKE_WALL     then @makeWall()
      when @MAKE_PASSAGE  then @makePassage()

  chooseRegion: ->
    [priorRegion, @region] = [@region, @stack.pop()]
    @updateRegion priorRegion if priorRegion

    if @region
      @updateRegion @region
      @state = @MAKE_WALL
      true
    else
      false

  makeWall: ->
    @horizontal = @chooseOrientation(@region.width, @region.height) == @HORIZONTAL

    # where will the wall be drawn?
    @wx = @region.x + (if @horizontal then 0 else @rand.nextInteger(@region.width-2))
    @wy = @region.y + (if @horizontal then @rand.nextInteger(@region.height-2) else 0)

    # what direction will the wall be drawn?
    dx = if @horizontal then 1 else 0
    dy = if @horizontal then 0 else 1

    # how long will the wall be?
    length = if @horizontal then @region.width else @region.height

    # what direction is perpendicular to the wall?
    @dir = if @horizontal then Maze.Direction.S else Maze.Direction.E
    @odir = Maze.Direction.opposite[@dir]

    [x, y] = [@wx, @wy]
    while length > 0
      @maze.carve x, y, @dir
      @updateAt x, y

      nx = x + Maze.Direction.dx[@dir]
      ny = y + Maze.Direction.dy[@dir]
      @maze.carve nx, ny, @odir
      @updateAt nx, ny

      x += dx
      y += dy
      length -= 1

    @state = @MAKE_PASSAGE
    true

  makePassage: ->
    # where will the passage through the wall exist?
    px = @wx + (if @horizontal then @rand.nextInteger(@region.width) else 0)
    py = @wy + (if @horizontal then 0 else @rand.nextInteger(@region.height))

    @maze.uncarve px, py, @dir
    @updateAt px, py

    nx = px + Maze.Direction.dx[@dir]
    ny = py + Maze.Direction.dy[@dir]
    @maze.uncarve nx, ny, @odir
    @updateAt nx, ny

    width = if @horizontal then @region.width else @wx - @region.x + 1
    height = if @horizontal then @wy - @region.y + 1 else @region.height
    if width >= 2 && height >= 2
      @stack.push x: @region.x, y: @region.y, width: width, height: height

    x = if @horizontal then @region.x else @wx + 1
    y = if @horizontal then @wy + 1 else @region.y
    width = if @horizontal then @region.width else @region.x + @region.width - @wx - 1
    height = if @horizontal then @region.y + @region.height - @wy - 1 else @region.height
    if width >= 2 && height >= 2
      @stack.push x: x, y: y, width: width, height: height

    @state = @CHOOSE_REGION
    true

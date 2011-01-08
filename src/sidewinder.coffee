###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.Sidewinder extends Maze
  IN: 0x10

  constructor: (width, height, options) ->
    super
    @x = 0
    @y = 0
    @runStart = 0
    @state = 0

  startStep: ->
    @carve @x, @y, @IN
    @callback this, @x, @y
    @state = 1

  runStep: ->
    if @y > 0 && (@x+1 >= @width || @randomBoolean())
      cell = @runStart + @rand.nextInteger(@x - @runStart + 1)
      @carve cell, @y, Maze.Direction.N
      @carve cell, @y-1, Maze.Direction.S
      @callback this, cell, @y
      @callback this, cell, @y-1
      @runStart = @x + 1
    else if @x+1 < @width
      @carve @x, @y, Maze.Direction.E
      @carve @x+1, @y, Maze.Direction.W
      @callback this, @x, @y
      @callback this, @x+1, @y
    else
      @carve @x, @y, @IN
      @callback this, @x, @y

    @x++
    if @x >= @width
      @x = 0
      @runStart = 0
      @y++

  step: ->
    return false if @y >= @height

    switch @state
      when 0 then @startStep()
      when 1 then @runStep()

    return @y < @height

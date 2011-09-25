###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.Algorithms.Eller extends Maze.Algorithm
  IN:         0x1000

  HORIZONTAL: 0
  VERTICAL:   1

  constructor: (maze, options) ->
    super

    @state = new Maze.Algorithms.Eller.State(@maze.width).populate()
    @row = 0
    @pending = true

    @initializeRow()

  initializeRow: ->
    @column = 0
    @mode = @HORIZONTAL

  isFinal: -> @row+1 == @maze.height

  isIn: (x, y) -> @maze.isValid(x, y) && @maze.isSet(x, y, @IN)
  isCurrent: (x, y) -> @column is x and @row is y

  horizontalStep: ->
    if !@state.isSame(@column, @column+1) && (@isFinal() || @rand.nextBoolean())
      @state.merge @column, @column+1

      @maze.carve @column, @row, Maze.Direction.E
      @updateAt @column, @row

      @maze.carve @column+1, @row, Maze.Direction.W
      @updateAt @column+1, @row
    else if @maze.isBlank(@column, @row)
      @maze.carve @column, @row, @IN
      @updateAt @column, @row

    @column += 1

    @updateAt @column-1, @row if @column > 0
    @updateAt @column, @row

    if @column+1 >= @maze.width
      if @maze.isBlank(@column, @row)
        @maze.carve @column, @row, @IN
        @updateAt @column, @row

      if @isFinal()
        @pending = false
        [oldColumn, @column] = [@column, null]
        @updateAt oldColumn, @row # clear the "current" status
      else
        @mode = @VERTICAL
        @next_state = @state.next()
        @verticals = @computeVerticals()
        @eventAt 0, @row

  computeVerticals: ->
    verts = []

    @state.foreach (id, set) =>
      countFromThisSet = 1 + @rand.nextInteger(set.length-1)
      cellsToConnect = @rand.randomizeList(set).slice(0, countFromThisSet)
      verts = verts.concat(cellsToConnect)

    verts.sort (a, b) -> a - b

  verticalStep: ->
    if @verticals.length == 0
      @state = @next_state.populate()
      @row += 1
      oldColumn = @column
      @initializeRow()
      @eventAt 0, @row

      @updateAt oldColumn, @row-1
      @updateAt @column, @row
    else
      [oldColumn, @column] = [@column, @verticals.pop()]
      @updateAt oldColumn, @row

      @next_state.add @column, @state.setFor(@column)

      @maze.carve @column, @row, Maze.Direction.S
      @updateAt @column, @row

      @maze.carve @column, @row+1, Maze.Direction.N
      @updateAt @column, @row+1

  step: ->
    switch @mode
      when @HORIZONTAL then @horizontalStep()
      when @VERTICAL   then @verticalStep()

    @pending

class Maze.Algorithms.Eller.State
  constructor: (@width, @counter) ->
    @counter ?= 0
    @sets = {}
    @cells = []

  next: ->
    new Maze.Algorithms.Eller.State(@width, @counter)

  populate: ->
    cell = 0
    while cell < @width
      unless @cells[cell]
        set = (@counter += 1)
        (@sets[set] ?= []).push(cell)
        @cells[cell] = set
      cell += 1
    this

  merge: (sink, target) ->
    sink_set = @cells[sink]
    target_set = @cells[target]

    @sets[sink_set] = @sets[sink_set].concat(@sets[target_set])
    for cell in @sets[target_set]
      @cells[cell] = sink_set
    delete @sets[target_set]

  isSame: (a, b) ->
    @cells[a] == @cells[b]

  add: (cell, set) ->
    @cells[cell] = set
    (@sets[set] ?= []).push(cell)
    this

  setFor: (cell) -> @cells[cell]

  foreach: (fn) ->
    for id, set of @sets
      fn id, set

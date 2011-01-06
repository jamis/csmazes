###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.Eller extends Maze
  IN:         0x20

  HORIZONTAL: 0
  VERTICAL:   1

  constructor: (width, height, options) ->
    super(width, height, options)

    @state = new Maze.Eller.State(@width).populate()
    @row = 0
    @pending = true

    @initializeRow()

  initializeRow: () ->
    @column = 0
    @mode = @HORIZONTAL

  isFinal: () ->
    @row+1 == @height

  isIn: (x, y) -> @isValid(x, y) && @isSet(x, y, @IN)

  horizontalStep: () ->
    changed = false

    until changed || @column+1 >= @width
      changed = true

      if !@state.isSame(@column, @column+1) && (@isFinal() || @rand.nextBoolean())
        @state.merge @column, @column+1

        @carve @column, @row, Maze.Direction.E
        @callback this, @column, @row

        @carve @column+1, @row, Maze.Direction.W
        @callback this, @column+1, @row
      else if @isBlank(@column, @row)
        @carve @column, @row, @IN
        @callback this, @column, @row
      else
        changed = false

      @column += 1

    if @column+1 >= @width
      if @isBlank(@column, @row)
        @carve @column, @row, @IN
        @callback this, @column, @row

      if @isFinal()
        @pending = false
      else
        @mode = @VERTICAL
        @next_state = @state.next()
        @verticals = @computeVerticals()

  computeVerticals: () ->
    verts = []

    @state.foreach (id, set) =>
      countFromThisSet = 1 + @rand.nextInteger(set.length-1)
      cellsToConnect = @randomizeList(set).slice(0, countFromThisSet)
      verts = verts.concat(cellsToConnect)

    verts.sort (a, b) -> a - b

  verticalStep: () ->
    cell = @verticals.pop()

    @next_state.add cell, @state.setFor(cell)

    @carve cell, @row, Maze.Direction.S
    @callback this, cell, @row

    @carve cell, @row+1, Maze.Direction.N
    @callback this, cell, @row+1

    if @verticals.length == 0
      @state = @next_state.populate()
      @row += 1
      @initializeRow()

  step: () ->
    switch @mode
      when @HORIZONTAL then @horizontalStep()
      when @VERTICAL   then @verticalStep()

    @pending

class Maze.Eller.State
  constructor: (@width, @counter) ->
    @counter ?= 0
    @sets = {}
    @cells = []

  next: () ->
    new Maze.Eller.State(@width, @counter)

  populate: () ->
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

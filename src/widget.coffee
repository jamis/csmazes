###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

Maze.createWidget = (algorithm, width, height, options) ->
  options ?= {}

  updateWalls = (maze, x, y, classes) ->
    classes.push "e" if maze.isEast(x, y)
    classes.push "w" if maze.isWest(x, y)
    classes.push "s" if maze.isSouth(x, y)
    classes.push "n" if maze.isNorth(x, y)

  ACTIONS =
    AldousBroder: (maze, x, y, classes) ->
      if maze.algorithm.isCurrent(x, y)
        classes.push "cursor"
      else if not maze.isBlank(x, y)
        classes.push "in"
        updateWalls maze, x, y, classes

    GrowingTree: (maze, x, y, classes) ->
      if not maze.isBlank(x, y)
        if maze.algorithm.inQueue(x, y)
          classes.push "f"
        else
          classes.push "in"
        updateWalls maze, x, y, classes

    HuntAndKill: (maze, x, y, classes) ->
      if maze.algorithm.isCurrent(x, y)
        classes.push "cursor"
      unless maze.isBlank(x, y)
        classes.push "in"
        updateWalls maze, x, y, classes
        
    Prim: (maze, x, y, classes) ->
      if maze.algorithm.isFrontier(x, y)
        classes.push "f"
      else if maze.algorithm.isInside(x, y)
        classes.push "in"
        updateWalls maze, x, y, classes

    RecursiveBacktracker: (maze, x, y, classes) ->
      if maze.algorithm.isStack(x, y)
        classes.push "f"
      else
        classes.push "in"
      updateWalls maze, x, y, classes

    RecursiveDivision: (maze, x, y, classes) ->
      updateWalls(maze, x, y, classes)

    Wilson: (maze, x, y, classes) ->
      if maze.algorithm.isCurrent(x, y)
        classes.push "cursor"
        updateWalls maze, x, y, classes
      else if not maze.isBlank(x, y)
        classes.push "in"
        updateWalls maze, x, y, classes
      else if maze.algorithm.isVisited(x, y)
        classes.push "f"

    Houston: (maze, x, y, classes) ->
      if maze.algorithm.worker.isVisited?
        ACTIONS.Wilson(maze, x, y, classes)
      else
        ACTIONS.AldousBroder(maze, x, y, classes)

    default: (maze, x, y, classes) ->
      unless maze.isBlank(x, y)
        classes.push "in"
        updateWalls maze, x, y, classes

  defaultCallback = (maze, x, y) ->
    classes = []
    (ACTIONS[algorithm] || ACTIONS.default)(maze, x, y, classes)
    cell = document.getElementById("#{maze.element.id}_y#{y}x#{x}")
    cell.className = classes.join(" ")

  id = options.id || algorithm.toLowerCase()
  options.callback ?= defaultCallback
  options.interval ?= 50

  mazeClass = "maze"
  mazeClass += " " + options.class if options.class

  gridClass = "grid"
  gridClass += " invert" if options.wallwise

  html = """
         <div id="#{id}" class="#{mazeClass}">
           <div id="#{id}_grid" class="#{gridClass}"></div>
           <div class="operations">
             <a id="#{id}_reset" href="#" onclick="document.getElementById('#{id}').mazeReset(); return false;">Reset</a>
             <a id="#{id}_step" href="#" onclick="document.getElementById('#{id}').mazeStep(); return false;">Step</a>
             <a id="#{id}_run" href="#" onclick="document.getElementById('#{id}').mazeRun(); return false;">Run</a>
           </div>
         </div>
         """

  document.write html
  element = document.getElementById(id)

  element.addClassName = (el, name) ->
    classNames = el.className.split(" ")
    for className in classNames
      return if className == name
    el.className += " " + name

  element.removeClassName = (el, name) ->
    if el.className.length > 0
      classNames = el.className.split(" ")
      el.className = ""
      for className in classNames
        if className != name
          el.className += " " if el.className.length > 0
          el.className += className

  element.mazeRun = ->
    if @mazeStepInterval?
      clearInterval @mazeStepInterval
      @mazeStepInterval = null
    else
      @mazeStepInterval = setInterval((=> @mazeStep()), options.interval)

  element.mazeStep = ->
    unless @maze.step()
      if @mazeStepInterval?
        clearInterval @mazeStepInterval
        @mazeStepInterval = null

      @addClassName document.getElementById("#{@id}_step"), "disabled"
      @addClassName document.getElementById("#{@id}_run"), "disabled"

  element.mazeReset = ->
    if @mazeStepInterval?
      clearInterval @mazeStepInterval
      @mazeStepInterval = null

    value = document.getElementById(options.input).value if options.input?

    @maze = new Maze(width, height, Maze.Algorithms[algorithm], callback: options.callback, seed: options.seed, rng: options.rng, input: value)
    @maze.element = this

    grid = ""
    for y in [0...@maze.height]
      row_id = "#{@id}_y#{y}"
      grid += "<div class='row' id='#{row_id}'>"
      for x in [0...@maze.width]
        grid += "<div id='#{row_id}x#{x}'></div>"
      grid += "</div>"

    gridElement = document.getElementById("#{@id}_grid")
    gridElement.innerHTML = grid

    @removeClassName document.getElementById("#{@id}_step"), "disabled"
    @removeClassName document.getElementById("#{@id}_run"), "disabled"

  element.mazeReset()

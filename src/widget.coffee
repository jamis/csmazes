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
    
    GrowingBinaryTree: (maze, x, y, classes) ->
      ACTIONS.GrowingTree(maze, x, y, classes)

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

  updateCallback = (maze, x, y) ->
    classes = []
    (ACTIONS[algorithm] || ACTIONS.default)(maze, x, y, classes)
    cell = document.getElementById("#{maze.element.id}_y#{y}x#{x}")
    cell.className = classes.join(" ")

  eventCallback = (maze, x, y) ->
    maze.element.mazePause() if maze.element.quickStep

  id = options.id || algorithm.toLowerCase()
  options.interval ?= 50

  mazeClass = "maze"
  mazeClass += " " + options.class if options.class

  gridClass = "grid"
  gridClass += " invert" if options.wallwise
  gridClass += " padded" if options.padded

  if options.watch ? true
    watch = "<a id='#{id}_watch' href='#' onclick='document.getElementById(\"#{id}\").mazeQuickStep(); return false;'>Watch</a>"
  else
    watch = ""

  html = """
         <div id="#{id}" class="#{mazeClass}">
           <div id="#{id}_grid" class="#{gridClass}"></div>
           <div class="operations">
             <a id="#{id}_reset" href="#" onclick="document.getElementById('#{id}').mazeReset(); return false;">Reset</a>
             <a id="#{id}_step" href="#" onclick="document.getElementById('#{id}').mazeStep(); return false;">Step</a>
             #{watch}
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

  element.mazePause = ->
    if @mazeStepInterval?
      clearInterval @mazeStepInterval
      @mazeStepInterval = null
      @quickStep = false
      return true

  element.mazeRun = ->
    unless @mazePause()
      @mazeStepInterval = setInterval((=> @mazeStep()), options.interval)

  element.mazeStep = ->
    unless @maze.step()
      @mazePause()
      @addClassName document.getElementById("#{@id}_step"), "disabled"
      @addClassName document.getElementById("#{@id}_watch"), "disabled" if options.watch ? true
      @addClassName document.getElementById("#{@id}_run"), "disabled"

  element.mazeQuickStep = ->
    @quickStep = true
    @mazeRun()

  element.mazeReset = ->
    @mazePause()

    if typeof options.input == "function"
      value = options.input()
    else
      value = options.input

    @maze = new Maze(width, height, Maze.Algorithms[algorithm], seed: options.seed, rng: options.rng, input: value)
    @maze.element = this
    @maze.onUpdate(updateCallback)
    @maze.onEvent(eventCallback)

    grid = ""
    for y in [0...@maze.height]
      row_id = "#{@id}_y#{y}"
      grid += "<div class='row' id='#{row_id}'>"
      for x in [0...@maze.width]
        grid += "<div id='#{row_id}x#{x}'>"
        if options.padded
          grid += "<div class='np'></div>"
          grid += "<div class='wp'></div>"
          grid += "<div class='ep'></div>"
          grid += "<div class='sp'></div>"
          grid += "<div class='c'></div>"
        grid += "</div>"
      grid += "</div>"

    gridElement = document.getElementById("#{@id}_grid")
    gridElement.innerHTML = grid

    @removeClassName document.getElementById("#{@id}_step"), "disabled"
    @removeClassName document.getElementById("#{@id}_watch"), "disabled" if options.watch ? true
    @removeClassName document.getElementById("#{@id}_run"), "disabled"

  element.mazeReset()

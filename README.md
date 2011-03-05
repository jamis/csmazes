CoffeeScript Mazes
==================

There are a lot of different maze algorithms out there, each with different
properties, strengths, weaknesses, and interesting points. The aim of this
project is to develop a library of these algorithms in a format that allows
the inner structure and behavior of them to be studied and observed
visually, by animating them and allowing students to step through them.


Installation
------------

You'll need [CoffeeScript](http://coffeescript.org) installed. Once you've
got that, you can run:

    cake build

This will convert the CoffeeScript sources in the "src" directory, to
Javascript files in the "lib" directory.

At this point you should be able to open the demo in examples/maze.html.
(A possibly-out-of-date version of the demo can be seen
[here](http://jamisbuck.org/mazes), if you want to get an idea of what
csMazes can do.)

If you want to do a piecemeal installation of your own, you'll need at least
these files, included in this order:

* mersenne.js
* maze.js

Further, the "widget.js" includes a script for easily embedding maze animations
on your page; you just need to add the CSS definitions. (See examples/maze.html
for the CSS definitions.)

Once you've included those files, you can include any of the algorithm-specific
files you want.

Also, these files may be safely combined and minified, if you want to reduce
everything to a single file.


Usage
-----

Using the included widget, embedding a maze is as simple as this:

    <script type="text/javascript">
      Maze.createWidget("Prim", 10, 10)
    </script>

This would embed a 10x10 grid that will animate Prim's algorithm. You can also
pass an optional object (hash) with properties to customize how the algorithm
runs, or how the grid is displayed. These properties are supported:

* **id** : used to set the id of the created HTML elements. If not specified,
  the lower-cased   algorithm name will be used.
* **class** : the HTML class attribute to add to the outermost generated
  div. This is in addition to any other classes that the widget itself
  assigns (e.g. "maze").
* **input** : data that should be passed to the maze object upon creation.
  This should be either a string, in which case it is passed directly to the
  maze constructor, or a function, in which case it is invoked first and
  the return value used as the value passed to the maze. The actual format
  of the string is dependent on the algorithm used.
* **interval** : the delay (in milliseconds) between steps when the maze
  is in "run" mode. Defaults to 50ms.
* **wallwise** : a boolean value indicating whether the maze is to be
  displayed as a passage carver (false) or a wall adder (true). The meaning
  of the wall queries is inverted when wallwise is true. Most mazes
  need to have wallwise set to false (the default), but the RecursiveDivision
  algorithm is a wall adder and needs to be rendered with wallwise set to
  true.
* **seed** : an integer value to use as a seed for the random number generated.
  Using the same seed for different animation runs (where the algorithm and
  dimensions are otherwise the same) will always result in the same maze
  being generated.
* **rng** : the random number generator object to use to generate numbers.
  You'll almost never need to use this; but it could be handy if you want to
  generate a series of mazes with the same original seed. If used, this should
  be an instance of MersenneTwister (defined in mersenne.coffee), or should
  at least conform to the same interface.
* **padded** : if true, adds space around each cell. The default is false.
* **weave** : if true, generates a "weave" maze (where passages move over
  and under other passages). This is not supported by all algorithms. For
  best results, use with **padded** set to true.
* **weaveMode** : either, "onePhase" (the default), or "twoPhase". Only
  Kruskal's algorithm currently supports this setting.
* **weaveDensity** : A number between 0 and 100 (default 80), with 100
  meaning "maximum" density". Only used when **weaveMode** is set to
  "twoPhase".

Advanced Usage
--------------

If you're determined to do things the hard way, you can always instantiate
the mazes yourself, setting up the callbacks and rendering things manually.
To instantiate a maze:

    var maze = new Maze(10, 10, Maze.Algorithms.Prim)

This would create a blank 10x10 grid that will generate a maze using Prim's
algorithm. Mazes are generated either step-wise:

    maze.step() // returns false when the maze is completed

Or they can be generated all at once:

    maze.generate() // calls step() repeatedly until done

As with the widget helper, the maze constructor accepts an optional final
parameter, an object, whose properties can be used to customize how the
maze is built. The following properties are understood (and have the same
meaning as their counterparts in the widget helper):

* **input** : a string used as input to the algorithm, which can be used to
  customize its behavior. Not all algorithms use this parameter.
* **seed**
* **rng**
* **weave**
* **weaveMode**
* **weaveDensity**

To indicate interest in the progress of the maze, you can use the onUpdate and
onEvent methods to register callbacks that will be invoked. The onUpdate
callback is triggered every time a cell is changed. The onEvent callback is
triggered whenever an algorithm-dependent "event" occurs (e.g. the recursive
backtracker hits a dead-end and has to backtrack). Both callbacks accept three
parameters: the maze object that caused the callback, and the x and y coordinates
that are relevant.

    maze.onUpdate(function(m, x, y) {
      // update the display, etc.
    });

    maze.onEvent(function(m, x, y) {
      // pause the animation, etc.
    });

License
-------

csMazes is written by Jamis Buck (jamis@jamisbuck.org) and is made available
in the public domain. Do with it what you will.

But please prefer good over evil.

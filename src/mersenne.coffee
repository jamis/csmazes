###
This implementation of the Mersenne Twister is a port of the JavaScript
version by Y. Okada. The JavaScript version was itself a port of a
C implementation, by Takuji Nishimura and Makoto Matsumoto.

CoffeeScript port by: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class MersenneTwister
  N:          624
  M:          397
  MATRIX_A:   0x9908b0df
  UPPER_MASK: 0x80000000
  LOWER_MASK: 0x7fffffff

  constructor: (seed) ->
    @mt = new Array(@N)
    @setSeed seed

  # makes the argument into an unsigned integer, if it is not already one
  unsigned32: (n1) -> if n1 < 0 then (n1 ^ @UPPER_MASK) + @UPPER_MASK else n1

  # emulates underflow of subtracting two 32-bit unsigned integers. both arguments
  # must be non-negative 32-bit integers.
  subtraction32: (n1, n2) ->
    if n1 < n2
      @unsigned32((0x100000000 - (n2 - n1)) % 0xffffffff)
    else
      n1 - n2

  # emulates overflow of adding two 32-bit integers. both arguments must be
  # non-negative 32-bit integers.
  addition32: (n1, n2) -> @unsigned32((n1 + n2) & 0xffffffff)

  # emulates overflow of multiplying two 32-bit integers. both arguments must
  # be non-negative 32-bit integers.
  multiplication32: (n1, n2) ->
    sum = 0
    for i in [0...32]
      if ((n1 >>> i) & 0x1)
        sum = @addition32(sum, @unsigned32(n2 << i))
    sum

  setSeed: (seed) ->
    if !seed || typeof seed == "number"
      @seedWithInteger seed
    else
      @seedWithArray seed

  defaultSeed: ->
    currentDate = new Date()
    currentDate.getMinutes() * 60000 + currentDate.getSeconds() * 1000 + currentDate.getMilliseconds()

  seedWithInteger: (seed) ->
    @seed = seed ? @defaultSeed()
    @mt[0] = @unsigned32(@seed & 0xffffffff)
    @mti = 1

    while @mti < @N
      @mt[@mti] = @addition32(
        @multiplication32(1812433253, @unsigned32(@mt[@mti-1] ^ (@mt[@mti-1] >>> 30))),
        @mti)
      @mti[@mti] = @unsigned32(@mt[@mti] & 0xffffffff)
      @mti++

  seedWithArray: (key) ->
    @seedWithInteger 19650218

    i = 1
    j = 0
    k = if @N > key.length then @N else key.length

    while k > 0
      _m = @multiplication32(@unsigned32(@mt[i-1] ^ (@mt[i-1] >>> 30)), 1664525)
      @mt[i] = @addition32(@addition32(@unsigned32(@mt[i] ^ _m), key[j]), j)
      @mt[i] = @unsigned32(@mt[i] & 0xffffffff)

      i++
      j++

      if i >= @N
        @mt[0] = @mt[@N-1]
        i = 1

      j = 0 if j >= key.length
      k--

    k = @N - 1
    while k > 0
      @mt[i] = @subtraction32(
        @unsigned32(@mt[i] ^ @multiplication32(@unsigned32(@mt[i-1] ^ (@mt[i-1] >>> 30)), 1566083941)), i)
      @mt[i] = @unsigned32(@mt[i] & 0xffffffff)
      i++
      if i >= @N
        @mt[0] = @mt[@N-1]
        i = 1

    @mt[0] = 0x80000000

  nextInteger: (upper) ->
    return 0 if (upper ? 1) < 1

    mag01 = [0, @MATRIX_A]

    if @mti >= @N
      kk = 0

      while kk < @N - @M
        y = @unsigned32((@mt[kk] & @UPPER_MASK) | (@mt[kk+1] & @LOWER_MASK))
        @mt[kk] = @unsigned32(@mt[kk+@M] ^ (y >>> 1) ^ mag01[y & 0x1])
        kk++

      while kk < @N-1
        y = @unsigned32((@mt[kk] & @UPPER_MASK) | (@mt[kk+1] & @LOWER_MASK))
        @mt[kk] = @unsigned32(@mt[kk+@M-@N] ^ (y >>> 1) ^ mag01[y & 0x1])
        kk++

      y = @unsigned32((@mt[@N-1] & @UPPER_MASK) | (@mt[0] & @LOWER_MASK))
      @mt[@N-1] = @unsigned32(@mt[@M-1] ^ (y >>> 1) ^ mag01[y & 0x1])
      @mti = 0

    y = @mt[@mti++]

    y = @unsigned32(y ^ (y >>> 11))
    y = @unsigned32(y ^ ((y << 7) & 0x9d2c5680))
    y = @unsigned32(y ^ ((y << 15) & 0xefc60000))

    @unsigned32(y ^ (y >>> 18)) % (upper ? 0x100000000)

  nextFloat: -> @nextInteger() / 0xffffffff

  nextBoolean: -> @nextInteger() % 2 == 0

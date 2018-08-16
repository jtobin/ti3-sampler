# ti3-sampler  [![BSD License](https://img.shields.io/badge/license-BSD-blue.svg)](https://github.com/jtobin/hnuts/blob/master/LICENSE)

![](/assets/ti3-game-board.jpg)

Sample random board locations in a TI3 game.

Useful for e.g. setting domain counters only on some limited percentage of the
board.  I find chocking the board full of domain counters slows the game down a
little too much, but you still want a few of them there for fun.  A proportion
of about 0.275 tiles seems to strike a very good balance.

Supports three, four, five, and six player games.  The tile coordinates are
just reported in terms of position on the nth ring of the board.  North is one,
and then you just count clockwise from there.

This takes into account the different board configurations for different
players, and so doesn't sample home systems.  Additionally, Mecatol Rex is
always included in the result.

For the three player game, just interpret the provided coordinates as if all
tiles were present on the board.

## Usage

Just clone the repo, install [Stack](https://www.haskellstack.org/), and run
something like:

```
$ stack exec ti3-sampler 4 0.1
Outer 18
Outer 11
Mid 6
Rex
```

The first argument is the number of players -- the second is the desired tile
proportion.


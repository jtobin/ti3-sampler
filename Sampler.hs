{-# OPTIONS_GHC -Wall #-}

import Control.Monad.Primitive
import qualified Data.Map.Strict as MS
import System.Random.MWC
import System.Random.MWC.Distributions (bernoulli)
import System.Environment

data Players =
    Three
  | Four
  | Five
  | Six

data Coord =
    Rex
  | Inner Int
  | Mid Int
  | Outer Int
  deriving (Show, Eq, Ord)

data Tile =
    Special
  | Plain Bool
  deriving Show

type Board = MS.Map Coord Tile

empty :: Board
empty = MS.fromList (zip coords (repeat (Plain False))) where
  coords = mconcat [rex, inner, mid, outer]
  rex    = [Rex]
  inner  = fmap Inner [1..6]
  mid    = fmap Mid [1..12]
  outer  = fmap Outer [1..18]

board :: Players -> Board
board players = case players of
    Three -> MS.alter special Rex
           $ MS.alter special (Outer 4)
           $ MS.alter special (Outer 5)
           $ MS.alter special (Outer 6)
           $ MS.alter special (Outer 9)
           $ MS.alter special (Outer 10)
           $ MS.alter special (Outer 11)
           $ MS.alter special (Outer 15)
           $ MS.alter special (Outer 16)
           $ MS.alter special (Outer 17)
           $ MS.alter special (Outer 1)
           $ MS.alter special (Outer 7)
           $ MS.alter special (Outer 13)
           empty

    Four -> MS.alter special Rex
          $ MS.alter special (Outer 3)
          $ MS.alter special (Outer 8)
          $ MS.alter special (Outer 12)
          $ MS.alter special (Outer 17)
          empty

    Five -> MS.alter special Rex
          $ MS.alter special (Outer 3)
          $ MS.alter special (Outer 7)
          $ MS.alter special (Outer 10)
          $ MS.alter special (Outer 13)
          $ MS.alter special (Outer 17)
          empty

    Six  -> MS.alter special Rex
          $ MS.alter special (Outer 1)
          $ MS.alter special (Outer 4)
          $ MS.alter special (Outer 7)
          $ MS.alter special (Outer 10)
          $ MS.alter special (Outer 13)
          $ MS.alter special (Outer 16)
          empty
  where
    special :: Maybe Tile -> Maybe Tile
    special tile = case tile of
      Just Plain {} -> Just Special
      _             -> tile

primsample :: Double -> Board -> Gen RealWorld -> IO Board
primsample prob brd gen = loop gen mempty (MS.toList brd)
  where
    loop prng acc tiles = case tiles of
      []     -> return (MS.fromList acc)
      (t:ts) -> case t of
        (c, Plain False) -> do
          coin <- bernoulli prob prng
          loop prng ((c, Plain coin):acc) ts

        _ -> loop prng (t:acc) ts

sample :: Players -> Double -> IO Board
sample players prob = withSystemRandom . asGenIO $
  primsample prob (board players)

render :: Board -> [Coord]
render brd = loop mempty (MS.toList brd) where
  loop acc tiles = case tiles of
    []     -> acc
    (t:ts) -> case t of
      (Rex, _)        -> loop (Rex:acc) ts
      (c, Plain True) -> loop (c:acc) ts
      _               -> loop acc ts

main :: IO ()
main = do
  args <- getArgs
  case args of
    (n:p:_) -> do
      let players = case (read n :: Int) of
            3 -> Just Three
            4 -> Just Four
            5 -> Just Five
            6 -> Just Six
            _ -> Nothing

          prob    = read p :: Double

      case players of
        Nothing  -> putStrLn "invalid number of players"
        Just nps -> do
          brd <- sample nps prob
          mapM_ print (render brd)

    _ -> putStrLn "USAGE: ./sample <NPLAYERS> <PROBABILITY>"


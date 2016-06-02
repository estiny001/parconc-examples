# Version 0.4

* Add `stack.yaml`, builds using LTS 4.2 (GHC 7.10.3)
* Various upper bound updates,including `network-2.6`
* Add `README.md`, with build instructions for Stack and Cabal
* Fix `.cabal` problems found by stack
* Build `tmvar.hs`, `windowman.hs` by importing them into a dummy `Main`
  module in `miscmodules.hs`.
* Removed generated `Parse.hs` and `Lex.hs`
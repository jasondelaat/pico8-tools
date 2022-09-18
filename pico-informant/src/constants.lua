-- pico-informant
-- jason delaat

-- pico-informant -------------------------------------------------------
-- an interactive fiction authoring api loosely based on inform6
--
-- copyright (c) 2022 jason delaat
-- mit license: https://github.com/jasondelaat/pico8-tools/blob/release/license
----------------------------------------------------------------------------
--------------------------------
-- pico-if constants
--------------------------------
light = 1
container = 2
open = 4
scenery = 8
static = 16
supporter = 32

max_carried  = 100
function contains(lst, i)
   for l in all(lst) do
      if l == i then
         return true
      end
   end
end
--------------------------------












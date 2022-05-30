-- swaps the order of parameters for a 2-parameter function and
-- returns a curried function which takes the same 2 arguments but in
-- the opposite order
function swap(f)
   return curry(2, function(a, b) return f(b, a) end)
end

-- wraps a function call inside a zero-argument function allowing you
-- to defer the actual execution until a later time.
function defer(f)
   return function(...)
      local args = {...}
      return function()
          return f(unpack(args))
      end
   end
end

function rnd_int(n)
   return flr(n*rnd()) + 1
end

function btn2cont()
   print("press \142 to continue", 24, 120)
end

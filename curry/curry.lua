-- curry -----------------------------------------------------------------
-- copyright (c) 2022 jason delaat
-- mit license: https://github.com/jasondelaat/pico8-tools/blob/release/license
----------------------------------------------------------------------------
-- function currying in lua
-- token count: 67
------------------------------------------------------------------------
function curry(n, f)
   return _helper(n, f, {})
end

function _helper(n, f, argmts)
   return function(...)
      local all_args = {}
      extend(all_args, argmts)
      extend(all_args, {...})
      if #all_args >= n then
         return f(unpack(all_args))
      else
         return _helper(n, f, all_args)
      end
   end
end

function extend(lst, vs)
   foreach(vs, function(v) add(lst, v) end)
end
-- end curry ------------------------------------------------------------------

_push = curry(2, add)
_top = defer(function(stack) return stack[#stack] end)
_pop = defer(
   function(stack)
      local value = stack[#stack]
      deli(stack, #stack)
      return value
   end
)

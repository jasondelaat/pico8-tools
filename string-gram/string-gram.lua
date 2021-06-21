--[[ string-gram
copyright (c) 2021 jason delaat
mit license: https://github.com/jasondelaat/pico8-tools/blob/release/license

implements simple context-free generative text grammar
token count: 104
]]
_syms = {}

function choice(...)
   local args = {...}
   return function()
      return rnd(args)()
   end
end

function lit(c)
   return function()
      return c
   end
end

function register(s, rule)
   _syms[s] = rule
end

function copy(f, n)
   return function()
      local result=''
      for i=1,n do
	 result = result..f()
      end
      return result
   end
end

function seq(...)
   local args = {...}
   return function()
      local result = ''
      for f in all(args) do
	 result = result..f()
      end
      return result
   end
end

function sym(s)
   return function()
      return _syms[s]()
   end
end
-- end string-gram

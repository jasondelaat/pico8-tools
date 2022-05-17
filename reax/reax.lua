-- reax -------------------------------------------------------
-- copyright (c) 2022 jason delaat
-- mit license: https://github.com/jasondelaat/pico8-tools/blob/release/license
----------------------------------------------------------------------------
-- implements reactive streams and provides streams for common player
-- inputs.
-- token count: maximum 259
------------------------------------------------------------------------

-- defines the methods on stream objects
_stream_meta = {
   -- creates a new stream from an existing stream by transforming its
   -- elements with the given function 'f'
   map=function(self, f)
      local s = stream()
      s._map_f = f
      add(self._children, s)
      return s
   end,
   -- creates a new stream from an existing stream consisting of only
   -- those elements for which the function 'f' returns true
   filter=function(self, f)
      local s = stream()
      s._filter_f = f
      add(self._children, s)
      return s
   end,
   -- inserts a value into the stream
   insert=function(self, val)
      if self._filter_f(val) then
         local v = self._map_f(val)
         for c in all(self._children) do
            c:insert(v)
         end
      end
   end
}

-- stream constructor function
function stream()
   local s = {
      _map_f=function(v) return v end,
      _filter_f=function(v) return true end,
      _children={}
   }
   setmetatable(s, {__index=_stream_meta})
   return s
end

function merge(...)
   local s = stream()
   local streams = {...}
   for t in all(streams) do
      add(t._children, s)
   end
   return s
end

-- the global event stream
events = stream()

-- call this function in _update() to have all button presses inserted
-- into the global event stream
function process_events()
   local b = btnp()
   if b > 0 then
      events:insert(b)
   end
end

-- if the devkit keyboard is enabled calling this function in
-- _update() will insert each character into the global event stream
-- as it is typed.
function process_devkey()
   if stat(30) then
      events:insert(stat(31))
   end
end

-- helper function to help define button streams (see below)
function eq(n)
   return function(e)
      return e == n
   end
end

-- individual streams for each button/button-combo. you can define
-- others-with the map() and filter() methods or the merge()
-- function-or delete any that you're not going to use. each stream
-- only catches events for that button and not others.
left = events:filter(eq(1))
right = events:filter(eq(2))
up = events:filter(eq(4))
down = events:filter(eq(8))
o_button = events:filter(eq(16))
x_button = events:filter(eq(32))
up_left = events:filter(eq(5))
down_left = events:filter(eq(9))
up_right = events:filter(eq(6))
down_right = events:filter(eq(10))
-- end-reax -------------------------------------------------------

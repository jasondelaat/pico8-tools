-- MIT License
-- 
-- Copyright (c) 2021 Jason DeLaat
-- 
-- Permission is hereby granted, free of charge, to any person
-- obtaining a copy of this software and associated documentation
-- files (the "Software"), to deal in the Software without
-- restriction, including without limitation the rights to use, copy,
-- modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
-- BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
-- ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
-- CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

----------------------------------------------------------------------------
-- This module implements a reactive, stream based, entity component system.
-- Token Count: 267
----------------------------------------------------------------------------

_draw_queue = {}

function run(self)
   if self.is_child then
      foreach(self._queue, function(e) self._map(e) end)
   end
   foreach(self._children, function(c) c:run() end)
end

function entity_remove(self, e)
   del(self._queue, e)
   foreach(self._children, function(c) c:remove(e) end)
end

function entity_insert(self, e)
   local accepted=true
   for n in all(self._filter) do
      if not e[n] then
	 accepted=false
      end
   end
   if accepted then
      add(self._queue, e)
      foreach(self._children, function(c) c:insert(e) end)
   end
end

function system(self, names, f)
   local s=ecs(names, f, true)
   add(self._children, s)
   return s
end

function draw_entities(self)
   foreach(_draw_queue, function(e) e.draw.fn(e) end)
   _draw_queue = {}
end

function ecs(names, f, is_child)
   new_ecs = {
      _map=f or function(x) return x end,
      _filter=names or {},
      _children={},
      _queue={},
      draw=draw_entities,
      insert=entity_insert,
      system=system,
      run=run,
      remove=entity_remove,
      is_child=is_child
   }
   if not is_child then
      new_ecs:system({'draw'}, function (e) add(_draw_queue, e) end)
   end
   return new_ecs
end

function component_add(self, cmp)
   self[cmp._name]=cmp
   return self
end

function entity()
   return {add=component_add}
end

function component(name, args)
   args=args or {}
   return function(...)
      local cmp={_name=name}
      for i=1,#args do
	 cmp[args[i]]=select(i, ...)
      end
      return cmp
   end
end

draw = component('draw', {'fn'})

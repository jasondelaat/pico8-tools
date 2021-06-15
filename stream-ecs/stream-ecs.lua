-- stream-ecs --------------------------------------------------------------
-- copyright (c) 2021 jason delaat
-- mit license: https://github.com/jasondelaat/pico8-tools/blob/release/license
----------------------------------------------------------------------------
-- this module implements a reactive, stream based, entity component system.
-- token count: 267
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
-- end stream-ecs --------------------------------------------------------------

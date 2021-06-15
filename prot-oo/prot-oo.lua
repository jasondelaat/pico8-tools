-- prot-oo -----------------------------------------------------------------
-- copyright (c) 2021 jason delaat
-- mit license: https://github.com/jasondelaat/pico8-tools/blob/release/license
----------------------------------------------------------------------------
-- implements a basic prototype based object-oriented inheritance model.
-- token count: 72
------------------------------------------------------------------------

object={}
function object:new(...)
   local o=object:create():assign(self)
   if o.init then
      o:init(...)
   end
   return o
end
function object:assign(args)
   for k,v in pairs(args) do
      self[k]=v
   end
   return self
end
function object:create()
   local o={}
   for k,v in pairs(self) do
      o[k]=v
   end
   o.proto=self
   return o
end
-- end prot-oo -----------------------------------------------------------------

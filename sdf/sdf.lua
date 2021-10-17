-- sdf ---------------------------------------------------------------------
-- copyright (c) 2021 jason delaat
-- mit license: https://github.com/jasondelaat/pico8-tools/blob/release/license
----------------------------------------------------------------------------
-- an api for creating and manipulating signed distant fields/functions.
-- token count: 511
------------------------------------------------------------------------

_sdf_base = {
   rotate=function(self, x, y, angle)
      local sdf = _new_sdf()
      sdf._dist = function(x_, y_)
	 local ct = cos(-angle)
	 local st = sin(-angle)
	 local vx = x_ - x
	 local vy = y_ - y
	 return self(
	    x + vx*ct - vy*st,
	    y + vx*st + vy*ct
	 )
      end
      return sdf
   end,
   translate=function(self, x, y)
      local sdf = _new_sdf()
      sdf._dist = function(x_, y_)
	 return self(x_ - x, y_ - y)
      end
      return sdf
   end,
}

_sdf_meta = {
   __index=_sdf_base,
   __add=function(a, b) -- union operator
      local sdf = _new_sdf()
      sdf._dist = function(x, y)
	 return min(a(x, y), b(x, y))
      end
      return sdf
   end,
   __call=function(self, x, y)
      return self._dist(x, y)
   end,
   __or=function(a, b) -- intersection operator
      local sdf = _new_sdf()
      sdf._dist = function(x, y)
	 return max(a(x, y), b(x, y))
      end
      return sdf
   end,
   __sub=function(a, b) -- difference operator
      local sdf = _new_sdf()
      sdf._dist = function(x, y)
	 return max(a(x, y), -b(x, y))
      end
      return sdf
   end,
   __unm=function(a)
      local sdf = _new_sdf()
      sdf._dist = function(x, y)
	 return -a(x, y)
      end
      return sdf
   end,
}

function _new_sdf()
   local sdf = {}
   setmetatable(sdf, _sdf_meta)
   return sdf
end

function sdf_box(x1, y1, x2, y2)
   local bl = {x1, y2}
   local tr = {x2, y1}
   return sdf_polygon({x1, y1}, bl, {x2, y2}, tr)
end

function sdf_circ(x, y, r)
   local sdf = _new_sdf()
   sdf._dist = function(x_, y_)
      return sqrt((x_ - x)^2 + (y_ - y)^2) - r
   end
   return sdf
end

function sdf_line(x1, y1, x2, y2)
   local vx = x2 - x1
   local vy = y2 - y1
   local d = sqrt(vx^2 + vy^2)
   local x, y, w = -vy/d, vx/d, (x1*y2 - y1*x2)/d
   local sdf = _new_sdf()
   sdf._dist = function(x_, y_)
      return x*x_ + y*y_ + w
   end
   return sdf
end

function sdf_parabola(x, y, w)
   local sdf = _new_sdf()
   sdf._dist = function(x_, y_)
      return w*(x_ - x)^2 - (y_ - y)
   end
   return sdf
end

function sdf_polygon(...)
   local points = {...}
   local p1 = points[1]
   local p2 = points[2]
   local poly = sdf_line(p1[1], p1[2], p2[1], p2[2])
   for i=3,#points do
      p1 = points[i-1]
      p2 = points[i]
      poly = poly | sdf_line(p1[1], p1[2], p2[1], p2[2])
   end
   p1 = points[#points]
   p2 = points[1]
   return poly | sdf_line(p1[1], p1[2], p2[1], p2[2])
end

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

moon = sdf_circ(0, 0, 32)
hole = sdf_circ(0, 0, 27):translate(10, 0)
img = moon - hole
img = img:translate(64, 64)


cls(12)
for x=0,127 do
   for y=0,127 do
      local d = img(x, y)
      local sd = img(x - 12*sin(4*y/128)-25, y - 25)
      local wd = img(x - 7*sin(2*y/128)-25, y) % 15
      if wd > 0.4 then
	 pset(x, y, 1)
      else
	 pset(x, y, 12)
      end
      if sd < 0.5 then
	 pset(x, y, 10)
      end
      if abs(d) < 0.5 then
	 c = 0
	 pset(x, y, c)
      --elseif d < -6 then
      --	 pset(x, y, 2)
      --elseif d < -4 then
      --	 c = 8
      --	 pset(x, y, c)
      --elseif d < -2 then
      --	 c = 9
      --	 pset(x, y, c)
      elseif d < -0.5 then
	 c = 10
	 pset(x, y, c)
      --elseif d > 30 then
      --	 pset(x, y, 1)
      end
   end
end

function _draw()end

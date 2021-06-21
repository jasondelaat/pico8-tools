-- individual elements
ground=lit('g')
gap=lit('p')
step_up=lit('u')
step_down=lit('d')
platform_up=lit('f')
platform_down=lit('m')
platform_cont=lit('c')
bookend=lit('e')

-- "pre-authored" features
pit=seq(ground, gap, ground)

-- one chunk of a level
sub_level=choice(
   ground,
   step_up, step_down,
   platform_up, platform_down, platform_cont,
   pit)

-- 50 level chunks, bookended
level=seq(bookend, copy(sub_level, 50), bookend)

function _init()
   t=0
   x=0 -- map x-coordinate
   gy=15 -- ground level y-coordinate
   py=13 -- platform level y-coordinate
   mpx = 0 -- map pixel offset
   li = 7 -- level string index
   lev=level()
   for i=1,6 do
      character_to_tiles[sub(lev, i, i)]()
   end
   x=0
end

function _update60()
   t += 1
   if t>60 then
      mpx -= 1
      if mpx == -32 then
	 scrub()
	 character_to_tiles[sub(lev, li, li)]()
	 if li < #lev then
	    li += 1
	 elseif li == #lev and (#lev*4+8)%24 == x%24 then
	    stop()
	 end
	 mpx = 0
      end
   end
end

function _draw()
   cls(1)
   map(x, 0, mpx, 0, 24-x, 16)
   map(0, 0, (24-x)*8+mpx, 0, x, 16)
end

-- functions for drawing elements
character_to_tiles={
   e=function()
      for i=1,4 do
	 mset(x, gy, 3)
	 x = (x + 1) % 24
      end
   end,
   g=function()
      for i=1,4 do
	 mset(x, gy, 1)
	 x = (x + 1) % 24
      end
   end,
   p=function()
      for i=1,4 do
	 mset(x, gy, 0)
	 x = (x + 1) % 24
      end
   end,
   u=function()
      raise_ground()
      character_to_tiles['g']()
   end,
   d=function()
      lower_ground()
      character_to_tiles['g']()
   end,
   c=function()
      if py < 15 then
	for i=1,4 do
	    mset(x, py, 2)
	    mset(x, gy, 1)
	    x = (x + 1) % 24
	end
      end
   end,
   f=function()
      raise_platforms()
      character_to_tiles['c']()
   end,
   m=function()
      lower_platforms()
      character_to_tiles['c']()
   end
}

function scrub()
   for i=x,min(23, x+3) do
      for j=0,15 do
	 mset(i, j, 0)
      end
   end
   if x+3 >= 24 then
      for i=0,(x+3)%24 do
	 for j=0,15 do
	    mset(i, j, 0)
	 end
      end
   end
end

function raise_ground()
   gy-=2
   if gy < 9 then
      gy = 9
   end
   if py >= gy then
      py = gy - 2
   end
end

function lower_ground()
   gy+=2
   if gy > 15 then
      gy = 15
   end
end

function raise_platforms()
   py-=2
   if py < 7 then
      py = 7
   end
end

function lower_platforms()
   py+=2
   if py > 13 then
      py = 13
   end
   if py >= gy then
      py = gy - 2
   end
end

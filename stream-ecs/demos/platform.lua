-- constants
friction = 0.85
gravity = 0.5

-- functions
function advance_frame(e)
   if e.control.horizontal != 0 then
      e.anim.frame += 1/8
      if e.anim.frame > e.anim.first + e.anim.length - 0.1 then
	 e.anim.frame = e.anim.first
      end
   else
      e.anim.frame = e.anim.first
   end
end

function check_collisions(e)
   -- vertical collisions
   local y = e.phys.y + max(0, 7*e.control.vertical)
   local x1 = e.phys.x + 1
   local x2 = x1 + 5
   if fget(mget(x1/8, y/8), 0) or fget(mget(x2/8, y/8), 0) then
      e.phys.vy = 0
      if e.control.vertical == 1 then
	 e.control.onground = true
	 e.phys.y -= e.phys.y % 8
      else
	 e.phys.y += 8 - (e.phys.y % 8)
      end
   end

   -- horizontal collisions
   local x = e.phys.x + max(0, 7*e.control.horizontal)
   local y1 = e.phys.y + 1
   local y2 = y1 + 5
   if fget(mget(x/8, y1/8), 0) or fget(mget(x/8, y2/8), 0) then
      if e.control.horizontal != 0 then
	 e.phys.x += max(0, -8 * e.control.horizontal) - (x % 8)
      end
   end
end

function draw_player(e)
   spr(e.anim.frame, e.phys.x, e.phys.y, 1, 1, e.control.flip)
end

function get_input(e)
   if btn(0) then
      e.control.horizontal = -1
      e.control.flip = true
   elseif btn(1) then
      e.control.horizontal = 1
      e.control.flip = false
   else
      e.control.horizontal = 0
   end
   if btnp(2) and e.control.onground then
      e.control.vertical = -1
   end
end

function move_player(e)
   e.phys.vx = e.control.horizontal
   e.phys.x += e.phys.vx
   if e.control.vertical < 0 and e.control.onground then
      e.phys.vy = -5
      e.control.onground = false
   end
   e.phys.vy += gravity
   e.phys.y += e.phys.vy
   if e.phys.vy > 0 then
      e.control.vertical = 1
   end
end

-- components
control = component('control', {'horizontal', 'vertical', 'flip', 'onground'})
phys = component('phys', {'x', 'y', 'vx', 'vy'})
anim = component('anim', {'first', 'length', 'frame'})
collision = component('collision', {'horizontal', 'vertical'})

-- entities
player = entity()
   :add(draw(draw_player))
   :add(control(0, 1, false, true))
   :add(phys(8, 48, 0, 0))
   :add(anim(1, 4, 1))
   :add(collision(false, false))

-- systems
world = ecs()

world_control = world
   :system({'control'}, get_input)

world_control
   :system({'phys'}, move_player)
   :system({'collision'}, check_collisions)

world_control
   :system({'anim'}, advance_frame)

-- main
function _init()
   palt(0, false)
   palt(2, true)
   world:insert(player)
   dbg = {}
end

function _draw()
   cls()
   map()
   world:draw()
end

function _update60()
   world:run()
end

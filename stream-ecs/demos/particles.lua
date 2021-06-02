phys = component('phys', {'x0', 'y0', 'vx', 'vy', 'ax', 'ay'})
timer = component('timer', {'t'})
dies_at = component('dies_at', {'t'})

function update_timer(e)
   e.timer.t += 1
end

function draw_particle(e)
   spr(1, e.phys.x, e.phys.y)
end

function update_particle(e)
   local t = e.timer.t
   e.phys.x = e.phys.x0 + e.phys.vx * t + 0.5 * e.phys.ax * t^2
   e.phys.y = e.phys.y0 + e.phys.vy * t + 0.5 * e.phys.ay * t^2

end

function remove_particle(e)
   if e.timer.t == e.dies_at.t then
      world:remove(e)
   end
end

function gen_particle()
   return entity()
      :add(phys(64, 120, rnd() - 0.5, -1 * rnd(2), 0, 0.0177777777))
      :add(timer(0))
      :add(dies_at(200))
      :add(draw(draw_particle))
end

world = ecs()

world_timer = world
   :system({'timer'}, update_timer)

world_timer
   :system({'dies_at'}, remove_particle)

world_timer
   :system({'phys'}, update_particle)

function _update60()
   world:insert(gen_particle())
   world:run()
end

function _draw()
   cls()
   world:draw()
end

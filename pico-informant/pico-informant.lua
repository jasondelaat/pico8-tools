-- pico-informant
-- jason delaat

-- pico-informant -------------------------------------------------------
-- an interactive fiction authoring api loosely based on inform6
--
-- copyright (c) 2022 jason delaat
-- mit license: https://github.com/jasondelaat/pico8-tools/blob/release/license
----------------------------------------------------------------------------
--------------------------------
-- pico-if constants
--------------------------------
light = 1
container = 2
open = 4
scenery = 8
static = 16
supporter = 32

max_carried  = 100
function contains(lst, i)
   for l in all(lst) do
      if l == i then
         return true
      end
   end
end
--------------------------------











-->8
-- pico-if object system
--------------------------------
do
   (function()
         local _location
         local _dictionary = {}
         local _dir_to = function(d)
            return function(_ENV, r)
               exits[d] = r
               return _ENV
            end
         end
         local _object_meta = setmetatable(
            {
               n_to = _dir_to('n'),
               e_to = _dir_to('e'),
               s_to = _dir_to('s'),
               w_to = _dir_to('w'),
               ne_to = _dir_to('ne'),
               se_to = _dir_to('se'),
               nw_to = _dir_to('nw'),
               sw_to = _dir_to('sw'),
               u_to = _dir_to('u'),
               d_to = _dir_to('d'),
               in_to = _dir_to('in'),
               out_to = _dir_to('out')
            }, {__index=_ENV})

         local _global_env = _ENV
         local _ENV = _ENV

         function get_object(s)
            return _dictionary[s]
         end

         function object(n, loc)
            local o = setmetatable(
               {name=n, exits={}, contents={}, attributes=0},
               {__index=_object_meta}
            )
            if loc then
               add(loc.contents, o)
            end
            _ENV = o
            return o
         end

         function description(d)
            description = '\n'..d..'\n'
         end

         function has(i)
            attributes = i
         end

         function name(...)
            local args = {...}
            for n in all(args) do
               _dictionary[n] = _ENV
            end
         end

         function each_turn(f)
            obj_update = f
         end

         function location(o)
            if o then
               _location = o
            end
            return _location
         end

         function story(title, headline)
            _global_env.title_screen = object(title)
            description(headline)
            has(light)
            each_turn(function(_ENV)
                  _global_env.title_screen = nil
            end)
         end

         _global_env.player = object()
   end)()
end
--------------------------------











-->8
-- pico-if messages system
--------------------------------
do
   (function()
         local _messages = ''
         function append_message(m)
            _messages ..= m
         end

         function clear_messages()
            _messages = ''
         end
         
         function display_messages()
            print(_messages)
         end
   end)()
end
--------------------------------











-->8
-- pico-if verb system
--------------------------------
do
   (function()
         local _verbs = {}

         function verb(...)
            local args = {...}
            return function(f)
               for n in all(args) do
                  _verbs[n] = f
               end
            end
         end

         function perform_verb(env, v, o1, o2)
            local verb = _verbs[v]
            if verb then
               verb(env, o1, o2)
            else
               append_message("i'm sorry, i don't understand\nwhat you mean.\n")
            end
         end

         local _go_dir = function(d)
            return function(_ENV)
               local room = exits[d]
               if room then
                  location(room)
                  clear_messages()
               else
                  append_message("you can't go that way.\n")
               end
            end
         end

         verb('n', 'north')(_go_dir('n'))
         verb('e', 'east')(_go_dir('e'))
         verb('s', 'south')(_go_dir('s'))
         verb('w', 'west')(_go_dir('w'))
         verb('ne', 'northeast')(_go_dir('ne'))
         verb('se', 'southeast')(_go_dir('se'))
         verb('nw', 'northwest')(_go_dir('nw'))
         verb('sw', 'southwest')(_go_dir('sw'))
         verb('u', 'up')(_go_dir('u'))
         verb('d', 'down')(_go_dir('d'))
         verb('in')(_go_dir('in'))
         verb('out')(_go_dir('out'))
         verb('inventory', 'i')
         (function(_ENV)
               append_message('you are carrying:\n')
               for _ENV in all(player.contents) do
                  append_message(name)
               end
         end)
         verb('take', 'pick')
         (function(_ENV, obj)
               if obj and contains(contents, obj) and
                  obj.attributes&(static|scenery) == 0 then
                  if #player.contents < max_carried then
                     del(contents, obj)
                     add(player.contents, obj)
                     append_message('you take the '..obj.name..'.\n')
                  else
                     append_message("you can't carry the "..obj.name..'\nat the moment.')
                  end
               else
                  if obj then
                      append_message("you don't see a "..obj.name.." here.\n")
                   else
                      append_message('\nhuh?\n')
                   end
               end
         end)
         verb('put')
         (function(_ENV, obj, target)
               if contains(player.contents, obj) then
                  if contains(contents, target) then
                     if target.attributes&(container|supporter) > 0 then
                        add(target.contents, obj)
                        del(player.contents, obj)
                        append_message('you put the '..obj.name..'\nin the '..target.name..'.\n')
                     else
                        append_message("you can't put that there.")
                     end
                  else
                     append_message("there's no "..target.name..' here.\n')
                  end
               else
                  append_message("you don't have a "..obj.name..'.\n')
               end
         end)
         verb('look', 'l', 'x', 'examine')
         (function(_ENV, obj)
               if obj and
                  (contains(player.contents, obj) or contains(contents, obj))
               then
                  append_message(obj.description)
               else
                  append_message(description)
               end
         end)
        
   end)()
end
--------------------------------











-->8
-- pico-if command parser system
--------------------------------
do
   (function()
         local _command_string = ''

         function command_string()
            return _command_string
         end

         function append_command(c)
            _command_string ..= c
         end

         function clear_command()
            _command_string = ''
         end

         function parse_command(env)
            local v, obj1, obj2 = unpack(split(_command_string, ' '))
            perform_verb(env, v, get_object(obj1), get_object(obj2))
            clear_command()
         end

         function command_backspace()
            _command_string = sub(_command_string, 1, #_command_string - 1)
         end
   end)()
end
--------------------------------











-->8
-- update and draw

poke(0x5f2d, 1)

function _update()
   local _ENV = title_screen or location()
   if stat(30) then
      local key = stat(31)
      if key == '\r' or key == 'p' then
         poke(0x5f30, 1)
      end
      if key == '\r' then
         if _ENV != title_screen then
            parse_command(_ENV)
         end
         if obj_update then
            obj_update(_ENV)
         end
      elseif key == '\b' then
         command_backspace()
      else
         append_command(key)
      end
   end
end

function _draw()
   cls()
   local _ENV = title_screen or location()
   print(name)
   print('--------------------------------')
   if attributes&light > 0 then
      print(description)
   else
      print("It's pitch black. You can't see anything.")
   end
   for _ENV in all(contents) do
      if attributes&scenery == 0 then
         print('you see a '..name)
      end
   end
   display_messages()
   if _ENV != title_screen then
      print('> '..command_string(), 2, 120)
   end
end

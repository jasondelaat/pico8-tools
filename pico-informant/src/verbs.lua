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
               if type(room) == 'string' then
                  append_message(room)
               elseif room then
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
         verb('u', 'up', 'climb')(_go_dir('u'))
         verb('d', 'down')(_go_dir('d'))
         verb('in', 'enter')(_go_dir('in'))
         verb('out')(_go_dir('out'))
         verb('inventory', 'i')
         (function(_ENV)
               append_message('you are carrying:\n')
               for _ENV in all(player.contents) do
                  append_message(name)
               end
         end)
         verb('take', 'pick', 'get')
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
               if not obj or not target then
                  append_message("sorry, i don't know what you\nmean.\n")
                  return
               end
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












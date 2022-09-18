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












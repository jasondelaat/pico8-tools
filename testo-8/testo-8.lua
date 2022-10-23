--------------------------------
-- testo-8: testing framework
-- copyright (c) 2022 jason delaat
-- mit license: https://github.com/jasondelaat/pico8-tools/blob/release/license
--------------------------------
do
   local all_tests = {}

   local function smt(t, mt)
      return setmetatable(t, {__index=mt})
   end

   local function shallow_copy(lst)
      local copy = {}
      for l in all(lst) do
         add(copy, l)
      end
      return copy
   end

   local function filter(f, lst)
      local results = {}
      for l in all(lst) do
         if f(l) then
            add(results, l)
         end
      end
      return results
   end
   
   local execute_meta = {
      execute=function(self)
         local result = self[4](self[3](self[2]()))
         if self._cleanup[1] then
            self._cleanup[1]()
         end
         return {
            result,
            self[1]..self.when_txt..self.result_txt
         }
      end
   }
   
   local when_result_meta
   local result_meta = {
      result=function(self, txt, fn)
         local t = shallow_copy(self)
         t.when_txt = self.when_txt
         t.result_txt = 'result '..txt..'\n'
         t._cleanup = self._cleanup
         add(t, fn)
         add(all_tests, smt(t, execute_meta))
         return smt(self, when_result_meta)
      end
   }
   
   local _cleanup
   local when_meta = {
      when=function(self, txt, fn)
         _cleanup = {}
         local t = shallow_copy(self)
         t.when_txt = 'when '..txt..'\n'
         t[3] = fn
         t._cleanup = _cleanup
         return smt(t, result_meta)
      end
   }
   
   when_result_meta = {
      when=when_meta.when,
      result=result_meta.result,
      cleanup=function(self, f)
         add(_cleanup, f)
         return self
      end
   }
   
   local given_meta = {
      given=function(self, txt, fn)
         local msg = self[1]..'given '..txt..'\n'
         return smt({msg, fn}, when_meta)
      end
   }
   function test(name)
      _cleanup = {}
      local t = smt({name..':\n', _cleanup=_cleanup}, given_meta)
      return t
   end
   
   local function run_tests()
      cls()
      cursor(0, 7)
      local results = {}
      for t in all(all_tests) do
         add(results, t:execute())
      end
      local failures =
         results and filter(function(r) return not r[1] end, results) or 0
      if #failures == 0 then
         print('all '..#all_tests..' tests passed!', 0, 0, 11)
      else
         for f in all(failures) do
            print(f[2])
         end
         rectfill(0, 0, 127, 6, 0)
         print(#failures..'/'..#all_tests..' tests failed:\n', 0, 0, 8)
         cursor(0, 127)
      end
   end

   function _init()
      run_tests()
   end
end
-- end testo-8 ------------------------------

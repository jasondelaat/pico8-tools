-->8
-- testo-8: usage example
--------------------------------
-- some simple functions with
-- errors and some tests, most
-- of which fail.
--------------------------------

function add1(x)
   return x + 2
end

function add2(x)
   return x + 1
end

function plus(x, y)
   return x*y
end

test('example tests')
   :given('the number 1',
          function()
             return 1
         end)
   :when('adding one', add1)
   :result('should be 2',
           function(r)
              return r == 2
          end)
   :result('no really, 2',
           function(r)
              return r == 2
           end
          )
   :when('adding two', add2)
   :result('should be 3',
           function(r)
              return r == 3
          end)

test('addition')
   :given('2 and 3',
          function()
             return 2, 3
          end)
   :when('adding', plus)
   :result('should be 5',
           function(r)
              return r == 5
           end)

global_list = {}
test('make sure to clean up\n properly')
   :given('the number 42', function() return 42 end)
   :when('added to global_list', function(n) add(global_list, n) end)
   :result('len should be 1',
           function()
              return #global_list == 1
          end)
   :when('not doing anything', function()end)
   :result('len should be 0',
           function()
              return #global_list == 0
          end)
   :cleanup(function() global_list = {} end)

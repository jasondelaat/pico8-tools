test('small "bignum" subtraction')
   :given('100 and 40',
          function()
             return bignum(100), bignum(40)
         end)
   :when('subtracted',
         function(a, b)
            return a - b
        end)
   :result('should have length 1',
           function(r)
              return #r == 1
          end)
   :result('1st entry should be 60',
           function(r)
              return r[1] == 60
          end)

test('2^15 - 1')
   :given('2^15 and 1',
          function()
             return bignum_from_list({0, 1}), bignum(1)
         end)
   :when('subtracted',
         function(a, b)
            return a - b
        end)
   :result('should have length 1',
           function(r)
              return #r == 1
          end)
   :result('1st entry should be 2^15-1',
           function(r)
              return r[1] == 2^15-1
          end)

test('cascading borrow')
   :given('2^29 and 1',
          function()
             return bignum_from_list({0, 0, 1}), bignum(1)
         end)
   :when('subtracted',
         function(a, b)
            return a - b
        end)
   :result('should have length 2',
           function(r)
              return #r == 2
          end)
   :result('1st entry should be 2^15-1',
           function(r)
              return r[1] == 2^15-1
          end)
   :result('2nd entry should be 2^15-1',
           function(r)
              return r[2] == 2^15-1
          end)

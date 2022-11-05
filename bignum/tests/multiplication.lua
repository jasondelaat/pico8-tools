--test('split mul')
--   :given('14 and 15',
--          function()
--             return 14, 15
--         end)
--   :when('multiplied with split_mul',
--         function(a, b)
--            return split_mul(a, b)
--        end)
--   :result('carry should be 0',
--           function(carry, rest)
--              return carry == 0
--          end)
--   :result('rest should be 210',
--           function(carry, rest)
--              return rest == 210
--          end)

test('small number multiplication')
   :given('15 and 16',
          function()
             return bignum(15), bignum(16)
         end)
   :when('multiplied',
         function(a, b)
            return a * b
        end)
   :result('should have length 1',
           function(r)
              return #r == 1
          end)
   :result('1st entry should equal 15*16',
           function(r)
              return r[1] == 15*16
          end)

test('big number times a small number')
   :given('2^15 and 12',
          function()
             return bignum_from_list({0, 1}), bignum(12)
         end)
   :when('multiplied',
         function(a, b)
            return a * b
        end)
   :result('should have length 2',
           function(r)
              return #r == 2
          end)
   :result('1st entry should equal 0',
           function(r)
              return r[1] == 0
          end)
   :result('2nd entry should equal 12',
           function(r)
              return r[2] == 12
          end)

test('multiplication overflow')
   :given('2^14+1 and 2',
          function()
             return bignum(2^14+1), bignum(2)
         end)
   :when('multiplied',
         function(a, b)
            return a*b
        end)
   :result('should have length 2',
           function(r)
              return #r == 2
          end)
   :result('1st entry should equal 2',
           function(r)
              return r[1] == 2
          end)
   :result('2nd entry should equal 1',
           function(r)
              return r[2] == 1
          end)


test('multiplication overflow')
   :given('2^15-1 and 2',
          function()
             return bignum(2^15-1), bignum(2)
         end)
   :when('multiplied',
         function(a, b)
            return a*b
        end)
   :result('should have length 2',
           function(r)
              return #r == 2
          end)
   :result('1st entry should equal 2^15-2',
           function(r)
              return r[1] == 2^15-2
          end)
   :result('2nd entry should equal 1',
           function(r)
              return r[2] == 1
          end)

test('multiplication overflow')
   :given('2 and 2^15-1',
          function()
             return bignum(2), bignum(2^15-1)
         end)
   :when('multiplied',
         function(a, b)
            return a*b
        end)
   :result('should have length 2',
           function(r)
              return #r == 2
          end)
   :result('1st entry should equal 2^15-2',
           function(r)
              return r[1] == 2^15-2
          end)
   :result('2nd entry should equal 1',
           function(r)
              return r[2] == 1
          end)


test('multiplication overflow')
   :given('2^15-1 and 2^15-1',
          function()
             return bignum(2^15-1), bignum(2^15-1)
         end)
   :when('multiplied',
         function(a, b)
            return a*b
        end)
   :result('should have length 2',
           function(r)
              return #r == 2
          end)
   :result('1st entry should equal 1',
           function(r)
              return r[1] == 1
          end)
   :result('2nd entry should equal 0b111111111111100',
           function(r)
              return r[2] == 0b111111111111110
          end)

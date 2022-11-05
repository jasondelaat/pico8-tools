test('small bignum addition')
   :given('two small "bignums" (50, 60)',
          function()
             return bignum(50), bignum(60)
         end)
   :when('added',
         function(a, b)
            return a + b
        end)
   :result('should have length 1',
           function(r)
              return #r == 1
          end)
   :result('1st entry == 110',
           function(r)
              return r[1] == 110
          end)

test('2^14 + 2^14')
   :given('2 copies of 2^14',
          function()
             return bignum(2^14), bignum(2^14)
         end)
   :when('added',
         function(a, b)
            return a + b
        end)
   :result('should have length 2',
           function(r)
              return #r == 2
          end)
   :result('1st entry == 0',
           function(r)
              return r[1] == 0
          end)
   :result('2nd entry == 1',
           function(r)
              return r[2] == 1
          end)

test('big + small overflow')
   :given('2^15 - 1 and 1',
          function()
             return bignum(2^15-1), bignum(1)
         end)
   :when('added',
         function(a, b)
            return a + b
        end)
   :result('should have length 2',
           function(r)
              return #r == 2
          end)
   :result('1st entry == 0',
           function(r)
              return r[1] == 0
          end)
   :result('2nd entry == 1',
           function(r)
              return r[2] == 1
          end)

test('cascading overflow')
   :given('2^29-1 and 1',
          function()
             return bignum_from_list({2^15-1, 2^15-1}), bignum(1)
         end)
   :when('added',
         function(a, b)
            return a + b
        end)
   :result('should have length 3',
           function(r)
              return #r == 3
          end)
   :result('1st entry == 0',
           function(r)
              return r[1] == 0
          end)
   :result('2nd entry == 0',
           function(r)
              return r[2] == 0
          end)
   :result('3rd entry == 1',
           function(r)
              return r[3] == 1
          end)

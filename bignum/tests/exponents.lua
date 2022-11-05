test('small number exponents')
   :given('2 and 8',
          function()
             return bignum(2), 8
         end)
   :when('2^8',
         function(x, n)
            return x^n
        end)
   :result('should have length 1',
           function(r)
              return #r == 1
          end)
   :result('should be 256',
           function(r)
              return r[1] == 256
          end)

test('even exponents')
   :given('2 and 16',
          function()
             return bignum(2), 16
         end)
   :when('2^16',
         function(x, n)
            return x^n
        end)
   :result('should have length 2',
           function(r)
              return #r == 2
          end)
   :result('1st entry should be 0',
           function(r)
              return r[1] == 0
          end)
   :result('2nd entry should be 2',
           function(r)
              return r[2] == 2
          end)

test('odd exponents')
   :given('2 and 15',
          function()
             return bignum(2), 15
         end)
   :when('2^15',
         function(x, n)
            return x^n
        end)
   :result('should have length 2',
           function(r)
              return #r == 2
          end)
   :result('1st entry should be 0',
           function(r)
              return r[1] == 0
          end)
   :result('2nd entry should be 1',
           function(r)
              return r[2] == 1
          end)

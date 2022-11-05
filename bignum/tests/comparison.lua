test('bignum equality')
   :given('2 equal large numbers',
          function()
             local n = bignum_from_list({1, 2, 3})
             return n, n
         end)
   :when('compared ==',
         function(a, b)
            return a == b
        end)
   :result('should be true',
           function(r)
              return r
          end)

test('bignum equality')
   :given('2 large numbers of different lengths',
          function()
             return bignum_from_list({1, 2, 3}), bignum_from_list({1, 2})
         end)
   :when('compared ==',
         function(a, b)
            return a == b
        end)
   :result('should be false',
           function(r)
              return not r
          end)

test('bignum equality')
   :given('2 different large numbers of same lengths',
          function()
             return bignum_from_list({1, 2, 3}), bignum_from_list({1, 2, 1})
         end)
   :when('compared ==',
         function(a, b)
            return a == b
        end)
   :result('should be false',
           function(r)
              return not r
          end)

test('< comparison')
   :given('2 equal large numbers',
          function()
             local n = bignum_from_list({1, 2, 3})
             return n, n
         end)
   :when('compared <',
         function(a, b)
            return a < b
        end)
   :result('should be false',
           function(r)
              return not r
          end)

test('< comparison')
   :given('2 large numbers of different length\n (a > b)',
          function()
             return bignum_from_list({1, 2, 3}), bignum_from_list({1, 2})
         end)
   :when('compared <',
         function(a, b)
            return a < b
        end)
   :result('should be false',
           function(r)
              return not r
          end)

test('< comparison')
   :given('2 large numbers of different length\n (a < b)',
          function()
             return bignum_from_list({1, 2}), bignum_from_list({1, 2, 3})
         end)
   :when('compared <',
         function(a, b)
            return a < b
        end)
   :result('should be true',
           function(r)
              return r
          end)

test('< comparison')
   :given('2 large numbers of same length\n (a < b)',
          function()
             return bignum_from_list({1, 2}), bignum_from_list({1, 3})
         end)
   :when('compared <',
         function(a, b)
            return a < b
        end)
   :result('should be true',
           function(r)
              return r
          end)

test('< comparison')
   :given('2 large numbers of same length\n (a > b)',
          function()
             return bignum_from_list({1, 4}), bignum_from_list({1, 3})
         end)
   :when('compared <',
         function(a, b)
            return a < b
        end)
   :result('should be false',
           function(r)
              return not r
          end)

test('less than or equal (<=)')
   :given('2 equal bignums',
          function()
             local n = bignum_from_list({1, 2, 3})
             return n, n
         end)
   :when('compared',
         function(a, b)
            return a <= b
        end)
   :result('should be true',
           function(r)
              return r
          end)

test('less than or equal (<=)')
   :given('2 bignums of different lengths\n (a < b)',
          function()
             return bignum_from_list({1, 2}), bignum_from_list({1, 2, 3})
         end)
   :when('compared',
         function(a, b)
            return a <= b
        end)
   :result('should be true',
           function(r)
              return r
          end)

test('less than or equal (<=)')
   :given('2 bignums of different lengths\n (a > b)',
          function()
             return bignum_from_list({1, 2, 3, 4}), bignum_from_list({1, 2, 3})
         end)
   :when('compared',
         function(a, b)
            return a <= b
        end)
   :result('should be false',
           function(r)
              return not r
          end)

test('less than or equal (<=)')
   :given('2 bignums of same lengths\n (a > b)',
          function()
             return bignum_from_list({1, 2, 4}), bignum_from_list({1, 2, 3})
         end)
   :when('compared',
         function(a, b)
            return a <= b
        end)
   :result('should be false',
           function(r)
              return not r
          end)

test('less than or equal (<=)')
   :given('2 bignums of same lengths\n (a < b)',
          function()
             return bignum_from_list({1, 2, 2}), bignum_from_list({1, 2, 3})
         end)
   :when('compared',
         function(a, b)
            return a <= b
        end)
   :result('should be true',
           function(r)
              return r
          end)

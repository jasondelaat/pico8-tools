-- bignum -------------------------------------------------------
-- copyright (c) 2022 jason delaat
-- mit license: https://github.com/jasondelaat/pico8-tools/blob/release/license
----------------------------------------------------------------------------
-- support for arbitrarily large intergers.
------------------------------------------------------------------------
do
 local bignum_from_list
 
 local function copy(x)
  local c = {}
  for i in all(x) do
   add(c, i)
  end
  return bignum_from_list(c)
 end
 
 function divide(a, b)
  local x = 0
  local total = bignum()
  local quotient = bignum()
  local powers = {}
  while total < a do
   local p2 = x == 0 and bignum(1) or bignum(2) * powers[x-1][1]
   local t = p2 * b
   powers[x] = {p2, t}
   quotient += p2
   total += t
   x += 1
  end
  x -= 1
  while x >= 0 do
   local p2, t = unpack(powers[x])
   quotient -= p2
   total -= t
   if total <= a and a - total < b then
    x = -1
   elseif total < a then
    quotient += p2
    total += t
   end
   x -= 1
  end
  return quotient, (a - total)[1]
 end
 
 function show(n)
  local q = copy(n)
  if q == bignum() then
   return '0'
  else
   local s = ''
   local r
   while q > bignum() do
    q, r = divide(q, bignum(10))
    s = r..s
   end
   return s
  end
 end
 
 local bignum_meta = {
  __mod=function(a, b)
   local _, r = divide(a, b)
   return r
  end,
  __div=function(a, b)
   local q, _ = divide(a, b)
   return q
  end,
  __pow=function(x, n)
   local total = bignum(1)
   local highest_p
   local cache = {}
   for i=0,14 do
    local iter = ((n >> i)&1) == 1 and i
    if iter then
     local y = highest_p and cache[#cache] or copy(x)
     for j=1,iter-(highest_p or 0) do
      y *= y
     end
     add(cache, y)
     highest_p = iter
     total *= y
    end
   end
   return total
  end,
  __mul=function(a, b)
   if a < b then
    a, b = b, a
   end
   local total = bignum()
   local highest_p
   local cache = {}
   for i=0,#b-1 do
    for j=0,14 do
     local x
     local iter = (b[i+1] >> j)&1 == 1 and 15*i+j
     if iter then
      x = highest_p and cache[#cache] or copy(a)
      for k=1,iter-(highest_p or 0) do
       x = x + x
      end
      add(cache, x)
      highest_p = iter
      total += x
     end
    end
   end
   return total
  end,
  __lt=function(a, b)
   if #a < #b then
    return true
   else
    for i=#a,1,-1 do
     if a[i] < (b[i] or 0) then
      return true
     elseif a[i] > (b[i] or 0) then
      return false
     end
    end
   end
  end,
  __eq=function(a, b)
   if #a == #b then
    for i=1,#a do
     if a[i] != b[i] then
      return false
     end
    end
    return true
   end
  end,
  __add=function(a, b)
   local len = max(#a, #b)
   local result = {}
   for i=1,len do
    local x = a[i] or 0
    local y = b[i] or 0
    local carry = result[i] or 0
    local sum = x + y + carry
    if sum < 0 then
     sum = sum & 0b0111111111111111
     result[i+1] = 1
    end
    result[i] = sum
   end
   return bignum_from_list(result)
  end,
  -- doesn't handle negative numbers yet so b must be less than or
  -- equal to a
  __sub=function(a, b)
   local len = max(#a, #b)
   local result = {}
   for i=1,len do
    local x = a[i] or 0
    local y = b[i] or 0
    local borrow = result[i] or 0
    local diff = x - y + borrow
    if diff < 0 then
     diff = diff & 0b0111111111111111
     result[i+1] = -1
    end
    result[i] = diff
   end
   return bignum_from_list(result)
  end
 }
 
 function bignum_from_list(l)
  while l[#l] == 0 and #l > 1 do
   deli(l, #l)
  end
  return setmetatable(l, bignum_meta)
 end
 
 function bignum(n)
  n = n or 0
  return setmetatable({n}, bignum_meta)
 end
 
 function factorial(n)
  local total = bignum(1)
  for i=1,n do
   total *= bignum(i)
  end
  return total
 end
end
-- end bignum -------------------------------------------------------

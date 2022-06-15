-- this lzw compression code is adapted from the example at
-- https://www.rosettacode.org/wiki/LZW_compression#Lua
function ints_to_bin(ints, bits)
   bits = bits or 8
   local bin=''
   for i=0,#ints do
      local int = ints[i]
      if int then
         for j=bits-1,0,-1 do
            bin ..= (int>>j)&1
         end
      end
   end
   while #bin%8 != 0 do
      bin ..= '0'
   end
   local coded=''
   while #bin != 0 do
      local n = tonum('0b'..sub(bin, 1, 8))
      coded ..= chr(n)
      bin = sub(bin, 9)
   end
   return coded
end

function lzw_compress(uncompressed) -- string
   local dictionary, result, dictSize, w, c = {}, {}, 255, ""
   local bit_size = 8
   for i = 0, 255 do
      dictionary[chr(i)] = i
   end
   for i = 1, #uncompressed do
      c = sub(uncompressed, i, i)
      if dictionary[w .. c] then
         w = w .. c
      else
         add(result, dictionary[w])
         dictSize = dictSize + 1
         dictionary[w .. c] = dictSize
         w = c
      end
      if dictSize >= 2^bit_size then
         bit_size += 1
      end
   end
   if w ~= "" then
      add(result, dictionary[w])
   end
   return chr(bit_size)..ints_to_bin(result, bit_size)
end

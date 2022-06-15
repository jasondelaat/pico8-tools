-- this lzw decompression code is adapted from the example at
-- https://www.rosettacode.org/wiki/LZW_compression#Lua
function bin_to_ints(s, bits)
   bits = bits or 8
   local small_ints = {}
   local result = {}
   local bin=''
   for i=1,#s do
      add(small_ints, ord(s, i))
   end
   for int in all(small_ints) do
      for i=7,0,-1 do
         bin ..= (int>>i)&1
      end
   end
   local over = #bin % bits
   if over != 0 then
      bin = sub(bin, 1, #bin - over)
   end
   while #bin != 0 do
      add(result, tonum('0b'..sub(bin,1, bits)))
      bin = sub(bin, bits+1)
   end
   return result
end

function lzw_decompress(compressed) -- string
   local bits = ord(sub(compressed, 1, 1))
   compressed = bin_to_ints(sub(compressed, 2), bits)
   local dictionary, dictSize, entry, w, k = {}, 256, "", chr(compressed[1])
   local result = {w}
   for i = 0, 255 do
      dictionary[i] = chr(i)
   end
   for i = 2, #compressed do
      k = compressed[i]
      if dictionary[k] then
         entry = dictionary[k]
      elseif k == dictSize then
         entry = w .. sub(w, 1, 1)
      else
         return nil, i
      end
      add(result, entry)
      dictionary[dictSize] = w .. sub(entry, 1, 1)
      dictSize = dictSize + 1
      w = entry
   end
   local result_s = ''
   for w in all(result) do
      result_s ..= w
   end
   return result_s
end

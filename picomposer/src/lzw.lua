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

function bin_to_ints(s, bits)
   bits = bits or 8
   local small_ints = {}
   local result = {}
   local bin=''
   for i=1,#s do
      add(small_ints, ord(sub(s, i, i)))
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

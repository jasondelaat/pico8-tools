-- vector distance transform decompression -----------------------------------
-- copyright (c) 2021 jason delaat
-- mit license: https://github.com/jasondelaat/pico8-tools/blob/release/license
----------------------------------------------------------------------------

-->8
-- decompression
function _expand_dists(min_dist, width, vecs, dists)
   local sdf = {}
   local d_index = 1
   for i=1,#vecs do
      local v=vecs[i]
      if v == 0 then
	 sdf[i] = dists[d_index]
	 d_index += 1
      elseif v == 1 then
	 local d1 = sdf[i-1]
	 local d2 = sdf[i-2]
	 sdf[i] = sqrt(2*d1^2 - d2^2 + 2)
      elseif v == 2 then
	 local d1 = sdf[i-width]
	 local d2 = sdf[i-2*width]
	 sdf[i] = sqrt(2*d1^2 - d2^2 + 2)
      elseif v == 3 then
	 local d1 = sdf[i-(width+1)]
	 local d2 = sdf[i-2*(width+1)]
	 sdf[i] = sqrt(2*d1^2 - d2^2)
      elseif v == 4 then
	 local d1 = sdf[i-(width-1)]
	 local d2 = sdf[i-2*(width-1)]
	 sdf[i] = sqrt(2*d1^2 - d2^2 + 4)
      end
   end
   for i=1,#sdf do
      sdf[i] += min_dist
   end
   return sdf
end

function bin_to_int(s) -- should be a 2-character string
   return (ord(s, 1) << 8) | ord(s, 2)
end

function bin_to_lst(s, bits)
   local lst={}
   local in_n = 0
   local n = 0
   for i=1,#s do
      local m = ord(s, i)
      local in_elem = 8
      while in_elem > 0 do
	 local needed = min(bits - in_n, 8)
	 local taken = min(needed, in_elem)
	 n = (n << taken) | (m >> (in_elem - taken))&(2^taken - 1)
	 in_n += taken
	 in_elem -= taken
	 if in_n == bits then
	    add(lst, n)
	    n = 0
	    in_n = 0
	 end
      end
   end
   if n != 0 then
      add(lst, n<<(bits-in_n))
   end
   return lst
end

function vdt_decompress(data)
   local min_dist = bin_to_int(sub(data, 1, 2))
   local dist_bits = ord(data, 3)
   local width = bin_to_int(sub(data, 4, 5))
   local height = bin_to_int(sub(data, 6, 7))
   local vec_length = ceil((1/4)*width*height)
   local vecs = bin_to_lst(sub(data, 8, 7+vec_length), 2)
   local dists = bin_to_lst(sub(data, 8+vec_length), dist_bits)
   return _expand_dists(
      min_dist,
      width,
      vecs,
      dists
   )
end

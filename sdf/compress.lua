-- vector distance transform compression -----------------------------------
-- copyright (c) 2021 jason delaat
-- mit license: https://github.com/jasondelaat/pico8-tools/blob/release/license
----------------------------------------------------------------------------

-->8
-- compression

function save_sdf(sdf, name)
   local bin = escape_binary(sdf)
   printh(name..'="'..bin..'"', name..'.txt', true)
end

_escapes = {}
_escapes['\0'] = '\\000'
_escapes['\r'] = '\\r'
_escapes['\n'] = '\\n'
_escapes['"'] = '\\"'
_escapes['\\'] = '\\\\'
function escape_binary(s)
   local corrected = ""
   for i=1,#s do
      local c = sub(s, i, i)
      local e = _escapes[c]
      if e then
	 corrected ..= e
      else
	 corrected ..= c
      end
   end
   return corrected
end

function _gen_data(sdf, width, height)
   local data = {}
   for y=0,height-1 do
      for x=0,width-1 do
	 add(data, flr(sdf(x, y)))
      end
   end
   local min = _find_min(data)
   local max = _find_max(data)
   return data, min, max
end

function _find_max(sdf_data)
   local md = -30000
   for d in all(sdf_data) do
      if d > md then
   	 md = d
      end
   end
   return md
end

function _find_min(sdf_data)
   local md = 32767
   for d in all(sdf_data) do
      if d < md then
   	 md = d
      end
   end
   for i=1,#sdf_data do
      sdf_data[i] -= md
   end
   return md
end

function _mapi(lst, f)
   local result={}
   for i=1,#lst do
      result[i] = f(lst, i)
   end
   return result
end

function _predict(width, max_error)
   return function(sdf, i)
      local d02 = sdf[i]^2

      local dd1, dd2 = sdf[i-(width+1)], sdf[i-2*(width+1)]
      if dd1 and dd2 and abs(d02 - (2*dd1^2 - dd2^2)) <= max_error then
	 return 3 -- diagonal
      end

      local du1, du2 = sdf[i-width], sdf[i-2*width]
      if du1 and du2 and abs(d02 - (2*du1^2 - du2^2 + 2)) <= max_error then
	 return 2 -- top
      end

      local dl1, dl2 = sdf[i-1], sdf[i-2]
      if dl1 and dl2 and abs(d02 - (2*dl1^2 - dl2^2 + 2)) <= max_error then
	 return 1 -- left
      end

      return 0 -- no match
   end
end

function _filter_dists(sdf, vecs)
   local dists = {}
   for i=1,#vecs do
      if vecs[i] == 0 then
	 add(dists, sdf[i])
      end
   end
   return dists
end

function _calc_vdt(sdf, width, max_error)
   local vecs = _mapi(sdf, _predict(width, max_error))
   local dists = _filter_dists(sdf, vecs)
   return vecs, dists
end

function lst_to_bin(lst, bits)
   local bin=''
   local in_byte = 0
   local n = 0
   local needed
   for e in all(lst) do
      local in_elem = bits
      while in_elem > 0 do
	 needed = min(8 - in_byte, in_elem)
	 n = (n << needed) | ((e >> (in_elem - needed))&(2^needed - 1))
	 in_byte += needed
	 in_elem -= needed
	 if in_byte == 8 then
	    bin ..= chr(n)
	    n = 0
	    in_byte = 0
	 end
      end
   end
   if n != 0 then
      bin ..= chr(n << needed)
   end
   return bin
end

function vdt_compress(sdf, width, height, max_error)
   local sdf_data, min_dist, max_dist = _gen_data(sdf, width, height)
   local vecs, dists = _calc_vdt(sdf_data, width, max_error or 0)
   local dist_bits = max_dist - min_dist > 255 and 16 or 8
   dist_bits = lst_to_bin({dist_bits}, 8)
   min_dist = lst_to_bin({min_dist}, 16)
   width = lst_to_bin({width}, 16)
   height = lst_to_bin({height}, 16)
   vecs = lst_to_bin(vecs, 2)
   dists = lst_to_bin(dists, 8)
   return min_dist..dist_bits..width..height..vecs..dists
end

-- These two pokes create a note in sfx(0) that will never play but
-- the non-empty pattern means that I'm able to 'play' rests when
-- there's no note in the first sfx slot.
poke2(12802, 1537)
poke(12866, 1)

--STOPPED = 1
--PLAYING = 2
--READING = 3
--DONE = 4

album = {}
m_state = 1 --STOPPED
_loop = 1

function load_music(filename, addr)
   addr = addr or 0x8000
   reload(addr, 0, 0x4300, filename)--..'.music.p8')
   local num_songs = peek(addr)
   addr += 1
   for i=1,num_songs do
      local song_len = to_int16(addr)
      local title_len = peek(addr+2)
      local title = ''
      for j=1,title_len do
         title ..= chr(peek(addr+2+j))
      end
      album[title] = {addr+title_len+3, song_len-title_len-1}
      addr += song_len + 2
   end
end

function play(ref, loop)
   if ref then
      _play[m_state](
         ref,
         (loop and type(loop) != 'number' and 0x7fff or loop) or (loop or 1))
   end
end

_play = {
   function() -- STOPPED
      m_state = 3
   end,
   function(ref, loop) -- PLAYING
      local playing = false
      for i=1,#_voices do
         if stat(45 + i) < 0  then
            _v_index[i] += 1
            local note = _voices[i][_v_index[i]]
            playing = playing or note != nil
            if playing then
               poke(12865, note[1])
               poke2(12800, note[2])
               sfx(0)
            end
         else
            playing = true
         end
      end
      if not playing then
         if _loop < loop then
            _loop += 1
            _v_index = {0, 0, 0, 0}
         else
            m_state = 4
            _voices = nil
            _v_index = nil
         end
      end
   end,
   function(ref) -- READING
      if not _voices then
         _voices = {}
         _v_index = {}
         local i=0
         for v_num=1,4 do
            if i < ref[2] then
               add(_voices, {})
               add(_v_index, 0)
               local v_len = to_int16(ref[1]+i)
               local voice = lzw_decompress(read_from_mem(v_len, ref[1]+i+2))
               for j=1,#voice,3 do
                  add(
                     _voices[v_num],
                     {ord(voice, j), (ord(voice, j+1)<<8) + ord(voice, j+2)}
                  )
               end
               i += v_len + 2
            end
         end
      end
      m_state = 2
   end,
   function() end -- DONE
}

function read_from_mem(len, addr)
   local s = ''
   for i=0,len-1 do
      s ..= chr(peek(addr + i))
   end
   return s
end

function to_int16(addr)
   return (peek(addr)<<8) + peek(addr+1)
end

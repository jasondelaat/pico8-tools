function _init()
   load_music()
end

function _update()
   play(album['song 6'])
end

function _draw()
   cls()
   print('now playing: song 6')
   if m_state == 4 then
      print('thanks for listening!')
   end
end

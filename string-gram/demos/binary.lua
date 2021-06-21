empty_or_bin = choice(lit(''), sym('bin'))
bin = choice(
   lit('1'),
   lit('0'),
   seq(lit('1'), sym('bin'), empty_or_bin),
   seq(lit('0'), sym('bin'), empty_or_bin)
)
register('bin', bin)

function _init()
   gen_bin()
end

function gen_bin()
   cls()
   print('press ❎ to regenerate\n')
   for i=1,10 do
      print(bin())
   end
end


function _update()
   if btnp(5) then
      gen_bin()
   end
end


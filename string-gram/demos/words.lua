c = choice(
   lit('m'),
   lit('p'),
   lit('t'),
   lit('f')
)

v = choice(
   lit('a'),
   lit('e'),
   lit('i'),
   lit('o'),
   lit('u')
)

cc_replacements = {
   mp='m-p',
   pt='t',
   tp='t-p',
   ff='fe',
   mm='n',
   mt='nt',
   mf='mph',
   tm='t-m',
   pm='m',
   pf='v',
   fp='ph',
   tt='d',
   tf='f',
   ft='v-t',
   pp='b',
   fm='phin'
}

syl = seq(c, v, c)
word = seq(syl, syl, choice(syl, lit('')))

function post(w)
   local i = 1
   local result = ''
   for j=1,#w-1 do
      s = sub(w, j, j+1)
      r = cc_replacements[s]
      if r then
	 result = result..sub(w, i, j-1)..r
	 i=j+2
      end
   end
   return result..sub(w, i)
end

function _init()
   gen_words()
end

function gen_words()
   cls()
   print('press ❎ to regenerate\n')
   for i=1,10 do
      print(post(word()))
   end
end

function _update()
   if btnp(5) then
      gen_words()
   end
end

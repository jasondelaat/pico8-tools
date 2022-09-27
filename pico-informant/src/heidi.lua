-->8
-- example game: heidi
-- adapted from:
-- 'the inform beginner's guide'
-- https://ifarchive.org/if-archive/infocom/compilers/inform6/manuals/IBG.pdf
--------------------------------

-- defining the title screen
story(
   'heidi',
   "a simple text adventure written\nby roger firth and sonja\nkesserich.\n\nadapted to pico-8 from\nthe inform beginner's guide.\nby jason delaat.\n\n\npress enter to begin.")


-- rooms and objects
before_cottage = object('in front of a cottage')
    description("you stand outside a cottage.\nthe forest stretches east.\n")
    has(light)

forest = object('deep in the forest')
    description("through the dense foliage you\nglimpse a building to the west.\na track heads to the northeast.")
    has(light)

bird = object('baby bird', forest)
    description("too young to fly, the nestling\ntweets helplessly.")
    name('baby', 'bird', 'nestling')

clearing = object('a forest clearing')
    description("a tall sycamore stands in the\nmiddle of this clearing. the\npath winds southwest through the\ntrees.")
    has(light)

nest = object("bird's nest", clearing)
    description("the nest is carefully woven of \ntwigs and moss.\n ")
    name("bird's", 'nest', 'twigs', 'moss')
    has(container|open)

tree = object('tall sycamore tree', clearing)
    description("standing proud in the middle of \n the clearing, the stout tree \n looks easy to climb.\n ")
    name('tall', 'sycamore', 'tree', 'stout', 'proud')
    has(scenery)

top_of_tree = object('at the top of the tree')
    description("you cling precariously to the \ntrunk.")
    has(light)
    each_turn(function(_ENV)
          if contains(branch.contents, nest) then
             print('you win!')
             stop()
          end
    end)

branch = object('wide firm bough', top_of_tree)
    description("it's flat enough to support a \nsmall object.\n ")
    name('wide', 'firm', 'flat', 'bough', 'branch')
    has(static|supporter)


-- connecting the rooms
before_cottage
   :e_to(forest)
   :in_to("it's such a lovely day -- much\ntoo nice to go inside.\n")

forest
   :w_to(before_cottage)
   :ne_to(clearing)

clearing
   :sw_to(forest)
   :u_to(top_of_tree)

top_of_tree
   :d_to(clearing)

-- initialization
function _init()
   location(before_cottage)
   max_carried = 1
end
--------------------------------












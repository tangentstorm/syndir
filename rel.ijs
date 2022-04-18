coinsert  'rel'    NB. make next section available in base locale.

NB. ============================================================
NB. -- relational calculus -------------------------------------
NB. ============================================================
cocurrent 'rel'

NB. helper for tests
is =: dyad : 0
  NB. 5!:5 = linear representation of an object
  if. -. x -: y do. echo (5!:5<'x'),' ~: ',(5!:5<'y') end. x -: y
)

NB. tl makes a function total (defined for all domains)
tl =: :: ]

NB. some test relations (rows separated by ';')
r1 =: > 0 1 ; 0 2 ; 1 3 ; 2 4
r2 =: > 0 1 11 ; 0 2 22 ; 1 3 33 ; 2 4 44
r3 =: > 0 1 11 111; 0 2 22 222; 1 3 33 333; 2 4 44 444


NB. ------------------------------------------------------------
NB.   R ap y : apply dyadic relation R to y
NB. x R ap y : same, but treat n-ary R as dyadic with split at x
NB. ------------------------------------------------------------
ap =: adverb : 0
    }."1 m #~ y  ="1   {."1 m
:
  x }."1 m #~ y -:"1 x {."1 m
)
assert (,. 1 2 ) is r1 ap 0     NB. two-row result for key=0
assert (,. 3   ) is r1 ap 1     NB. one-row result for key=1
assert (0 1 $ _) is r1 ap 9     NB. no results for key=9

NB. dyadic case should let us specify the size of the key
assert (,.  11)    is 2 r2 ap 0 1
assert (,: 11 111) is 2 r3 ap 0 1
assert (,. 111)    is 3 r3 ap 0 1 11

NB. inverse of a binary relation (reverses the direction)
iv =: ( |."_1 ) : ( -@[ |."1 ] )
assert (     r1) is (> 0 1 ; 0 2 ; 1 3 ; 2 4)
assert (  iv r1) is (> 1 0 ; 2 0 ; 3 1 ; 4 2 )
assert (1 iv r1) is (> 1 0 ; 2 0 ; 3 1 ; 4 2 )

r2 =: > 0 1 11 ; 0 2 22 ; 1 3 33 ; 2 4 44
assert (     r2) is (> 0 1 11; 0 2 22; 1 3 33; 2 4 44)
assert (2 iv r2) is (> 1 11 0; 2 22 0; 3 33 1; 4 44 2)


NB. ------------------------------------------------------------
NB.   R ai y : apply inverse of binary relation R to y
NB. x R ai y : same, but treat n-ary R as binary with split at x
NB. ------------------------------------------------------------
ai =: adverb : 0
  ((iv m) ap)  :. (m ap) y
:
  x (((x iv m) ap) :. (m ap)) y
)


r4 =: > 0 1 11 ; 0 2 22 ; 1 2 22
assert (,. 1 11 ,: 2 22) is r4 ap 0    NB. nothing new here.
assert (        ,: 2 22) is r4 ap 1
NB. monadic case: ( a | b c )
assert (,.   0)  is 2 r4 ai 1 11       NB. but ac maps value to key


NB. dyadic case: ( a b | c ) (when x = 2)
assert (,.   0)  is 2 r4 ai 1 11       NB. but ac maps value to key
assert (,. 0 1)  is 2 r4 ai 2 22       NB. (or to multiple keys)


NB. ============================================================
NB. relation class
NB. ============================================================
coclass 'Rel'
coinsert 'relwords'
typeSyms =: s:;: 'int bit nid sym str chr box'

sym2lit =: 4 s: ]
findsplit =: [: -: @: I. (s:<'|') = ]
assert 0 = findsplit s: ;: 'a:int b:int c:int'
assert 1 = findsplit s: ;: 'a:int | b:int c:int'
assert 2 = findsplit s: ;: 'a:int b:int | c:int'

create =: monad : 0
  NB. example:  'sub:int rel:int obj:int' conew 'Rel'
  y =. (' '"_)^:(':'=])"0 y  NB. discard ':' chars
  sp =: findsplit toks =. s: ;: y
  'keys doms' =: |: _2 ]\ toks -. s:<'|'
  for_i. i. # keys do.
    n =. i { keys
    k =. i { doms
    if. -. k e. typeSyms do.
      echo 'unknown type:', sym2lit k
      throw.
    elseif. -. '[[:alpha:]][_[:alnum:]]*' rxeq sym2lit n do.
      echo 'invalid name:', sym2lit n
      throw.
    elseif. 1 do.
      NB. TODO...
    end.
  end.
  nk =: #keys
  ek =: sp & {."1      NB. extract key columns (from arg or data))
  ev =: sp & }."1      NB. extract val columns (from data)
  ke =: (nk-sp) & {."1 NB. extract inverted key (from arg)
  data =: }: ,: i. nk  NB. init empty relation as 0*nkeys array
)


NB. relation verbs

NB. apply relation to arguments to fetch data by key:
rel=: (verb : 'data')
get=: ev@rel #~ (ek@rel) -:"1 ek
ap =: get`rel@.(''-:])

NB. inverse relation (fetch key by val)
ler=: (verb : '(ev,.ek) data')
teg=: ek@rel #~ (ev@rel) -:"1 ke  NB. 
iv =: teg`ler@.(''-:])

NB. insert data into the table
ins=: (verb : 'data =: ~. data, y') $~0:


NB. ============================================================
NB. -- syntax directed editor --------------------------------
NB. ============================================================
NB. based on "a relational program for a syntax directed editor"
NB. by B.J. MacLennan|https://github.com/tangentstorm/maclennan/
cocurrent 'base'
Rel =: conew & 'Rel'

NB. -- the syntax tree -----------------------------------------
tree =: Rel 'node:nid | ord:int child:nid'  NB. connections
udfn =: Rel 'node:nid | nont:sym'           NB. undefined nodes
defn =: Rel 'node:nid | nont:sym altk:chr'  NB. defined nodes

alts =: Rel 'nont:sym  altk:chr | rule:int'
forw =: Rel 'src:sym | dst:sym'             NB. chain alt rules


dict =: Rel 'nont:sym | path:box'
rule =: Rel 'asys:int ssys:int dict:int'
NB. asys =. Rel '' (term | nont)^2 // sequences of non-terminals
NB. ssys =. Rel '' (node | node*int) -> (node|nont|nont*altk)


NB. --- editor functions ---------------------------------------

lang_ind =: 0 : 0
  key:int  cmd:int
  up       cmd_prev
  dn       cmd_next
  n        cmd_succ
  h        cmd_pred
  rt       cmd_in
  lf       cmd_out
  g        cmd_get
  p        cmd_put
  d        cmd_del
  u        cmd_undel
)

lang_dep =: 0 : 0
  key:int  cmd:int
)

process =: lang_ind , lang_dep



N =: 0 NB. current node
move   =: adverb : 'N =: u y'
parent =: fst @ Ti
rsib   =: verb : '(0 1 + ])&.ai__tree y'

NB. positioning commands
cmd_out =: parent tl  move
cmd_in  =: T tl@(,1:) move

T =: ap__tree :. iv__tree
Alts =: ap__alts
Forw =: ap__forw


NB. unparsing
id  =: ]
fst =: {."1
cat =: ,/
rdc =: 2 : 'u/n,y'

NB. rules are templates

NB. dispnt: recursive procedure to display non-terminals
dispnt =: dyad : 0
  'nid rule' =: x
  x unparse (2{rule) ap y
)
danal =: dyad : 0
  'n r' =: x
  try. x dispnt L: _ 0 (0{r) catch. end.
)
disprule =: cat rdc '' @: danal
dispnode =: disprule @: (id ,. (Alts :: Forw)@: fst @: T)
unparse =: T ap :: dispnode


NB. terminals
'ALPHA DIGIT PLUS MINUS STAR SLASH'=:s:'`ALPHA`DIGIT`+`-`*`/'

NB. nonterminals
'NUMBER GROUP'=:s:'`NUMBER`GROUP'

ia=:ins__alts@<
ia 0; ALPHA

lang =: 0 : 0
  digit:'0'..'9'.
)

NB. example language
ins__forw

ins=.ins__tree



NB. tree table
NB. ------------------
NB. 13  (2 ({.;}.)"1 [,.i.@#@],.]) 1 3 4 8
NB. subs =: [: :([: < [) ,. [: (i.@# ;"0 ]) [: s: ' ',]

NB. for (node → non-term) and (node → (non-term × key)) combinations:


as =: 4 :'x;<y'
sym=: 3 :'s:<y'

is =: 4 : 0
  ins__alts(<sym x),y
)
end=: 1 :'<m'
rep=: 1 :'(sym''*'');m'
ref=: sym


'<number>' is (ref'digit')rep end

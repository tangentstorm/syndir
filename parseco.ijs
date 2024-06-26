NB. ------------------------------------------------------------
NB. Parser Combinators for J
NB.
NB. The semantics here are heavily inspired by
NB. Allesandro Warth's ometa system:
NB.
NB.   http://tinlizzie.org/ometa/
NB.
NB. but implemented as parser combinators rather than a standalone language.
NB.
NB. ------------------------------------------------------------
LICENSE =: (0 : 0)
Copyright (c) 2021 Michal J Wallace <http://tangentstorm.com/>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
)


NB. --- structs ------------------------------------------------

NB. sg =. m AT: constructor for setter/getter verbs (accessors).
NB. (sg y) gets item m from struct y
NB. (x sg y) returns copy of y with with m set to x
AT =: {{ m&{:: : (<@[ m} ]) }}

NB. m struct y : create verbs for struct with name m and fields y
NB. m is quoted name, y is space-delimited names
struct =: {{
  NB. constructor for empty struct:
  ". m,'=: (a:#~',(":#fs),'"_) : (;:@',(quote y),')' [ fs =. cut y
  NB. accessors for each field:
  ({{ ". x,'=:',(":y),' AT' }}&>"0 i.@#) fs
  0 0$0}}


NB. --- tree state ---------------------------------------------

NB. you can use whatever tree builder you like (by setting
NB. the 'tb' field in the parse state to a different locale),
NB. provided it implements the methods in the "tree builder
NB. interface" section.

NB. In order to support backtracking, the interface requires
NB. that every method take and return a state memento.

NB. For this default implementation, the the complete state
NB. is just stored in the memento, and the trees built are
NB. just nested boxes.

NB. -- TS --
NB.   nt = node tag
NB.   na = node attributes
NB.   nb = node buffer (grows as we build rules)
NB.   wk = work stack (grows with recursive descent)
'TS' struct 't_nt t_na t_nb t_wk'
tna0 =: (0 2$a:)  NB. initialize dictionary. used here and it 'node'
ts0 =: tna0 t_na TS''


NB. --- parse state --------------------------------------------

NB.   mb = match bit
NB.   ix = current index into the input
NB.   ch = current character, or '' after ix>#S
NB.   mk = mark (start of current token)
NB.   tb = tree builder
NB.   ts = tree state
NB.   ib = input buffer
'S' struct 'mb ix ch mk ib tb ts ib'

NB. treebuilder defaults to this current namespace
tb0 =: coname''

NB. s0 : S. initial parse state
s0 =: 0 mb]  0 ix]  ' 'ch]  0 mk]  tb0 tb]  ts0 ts] S''


NB. even simpler setters for match bit:
I =: 1&mb
O =: 0&mb

NB. 'character buffer' (input from mk to ix)
cb =: ib {~ mk + i.@(ix-mk)


NB. -- "microcode" ---------------------------------------------

NB. u AA v. s->s. apply u at v in y. (where v = (m AT))
AA =: {{ (u v y) v y }}

NB. m AP v. s->s. append m to v=(buffer AT) in y
AP =: {{ ,&m AA v y }}

NB. nx :: state->state = move to next character (ch-:'' if past end)
nx =: {{i ix (i{ ::'' ib y) ch (ix~ 1+ ix) y [ i=. 1+ix y }}
nx =: {{i ix (i{ ::'' ib y) ch y [ i=. 1 + ix y }}

NB. on: string -> s (initial parser state)
NB. everything is stored explicitly inside
NB. the state tuple, to make it easy to backtrack.
on =: {{ ({.y) ch y ib s0 }}

NB. state fw y (micro) : match y chars (where y is int >: 0)
fw =: {{ (*y) mb nx^:y x }}

NB. la : lookahead
la =: ib@] {~ ix@] + i.@[

NB. x tk: s->(item;<s). pop the last item from buffer x in state y.
tk =: {{ ({:u y) ;< (}: AA u) y }}


NB. -- basic match combinators ---------------------------------

NB. nil: s->s. always match, but consume nothing.
nil =: I

NB. any: s->s. matches one input item, unless out of bounds.
any =: {{ f mb nx^:f y [ f =. (#ib y)>ix y }}

NB. u neg: s->s. invert match flag from u and restore everything else
NB. from the original state after running u. This primitive allows
NB. you to implement negative lookahead (or apply it twice to implement
NB. positive lookahead without consuming).
neg =: {{'neg'] y mb~ -. mb u y }}

NB. u end: s->s. matches at end of input.
end =: any neg

NB. r try : s->s. generic error trap. mostly this handles
NB. the case where we're reading past the end of the input.
try =: :: O

NB. m chr: s->s. match literal atom m and advance the index
chr =: {{ y fw m  -: ch y }} try

NB. m chs s->s. match any one item from m and advance ix. ('choose'/'character set')
chs =: {{ y fw m e.~ ch y }} try

NB. m seq: s->s. match each rule in sequence m
seq =: {{'seq'] s=:y
  for_r. m do.
    if. -.mb s=. r`:6 s do. O y return. end.
  end. I s }}

NB. m alt: s->s. try each rule in m until one matches.
NB. This is "Prioritized Choice" from PEG parsers.
NB. It removes some ambiguity, but means you have to think
NB. carefully about how to order your rules. For example,
NB. if your language allows simple strings of letters to be
NB. used as names but also reserves some strings of letters
NB. as keywords, then you must specify the keywords first.
alt =: {{'alt'] s=:y
  for_r. m do.
    if. mb  s=. r`:6 s do. I s return. end.
  end. O y }}


NB. -- extra utilities -----------------------------------------

NB. u opt: s->s. optionally match rule u. succeed either way
opt =: I@:

NB. m lit: s->s like seq for literals only.
NB. this just matches the whole sequence directly vs S.
NB. ,m is so we can match a single character.
lit =: {{ y fw (#m) * m-: (#m=.,m) la y }} try

NB. u rep: s->s. match 1+ repetitions of u
rep =: {{ y (<&ix mb ]) u^:mb^:_ I y }}

NB. u orp: s->s. optionally repeat (match 0+ repetitions of u)}}
orp =: rep opt

NB. u not: s->s. match anything but u.
NB. fail if u matches or end of input, otherwise consume 1 input.
not =: {{ (u neg)`any seq }}

NB. u sep v: s->s. match 1 or more u, separated by v
sep =: {{ u`(v`u seq orp) seq f. }}

NB. -- lexers --------------------------------------------------

NB. !! this implementation makes no sense.
NB. the token buffer only contains one token.
NB.
NB. u scan: string -> tokens | error
NB. applies rule u to (on y) and returns token buffer on success.
NB. scan =: {{ if.mb s=.u on y do. cb s else. ,.'scan failed';<s end. }}

NB. u ifu v: s->s. if u matches, return 1;<(s_old) v (s_new)
ifu =: {{ f mb y v^:f s [ f=.mb s=.u y }}

NB. u tok: s->s move current token to NB if u matches, else fail
NB. (this is overridden later)
NB. tok =: ifu({{ (ix mk (AP nb)~ cb) y }}@])

NB. m sym: s->s alias for 'm lit tok'
NB. sym =: lit tok

NB. u zap: s->s match if u matches, but drop any generated nodes
NB. the only effect that persists is the current (ch,ix,mk).
zap =: ifu(ix@] mk ch@] ch ix@] ix [)


NB. -- parsers -------------------------------------------------

NB. u parse: string -> [node] | error
NB. applies rule u to (on y) and returns node buffer on success.
NB. note that the node buffer is a *list of boxes*, even if there
NB. is only one top-level node. It's a forest, not a tree.
parse =: {{ if.mb s=.u on y do. t_nb ts s else. ,.'parse failed';<s end. }}
NB. !! how to do 'else' for ifu?


NB. tree builder interface
NB. ------------------------------------------------------------

NB. ntup: the state indices to copy (in order) for current node
t_ntup =: (t_nt,t_na,t_nb) i.#ts0

NB. x t_node: ts -> ts: starts a new node in the tree with tag x
NB. node =: {{ x nt a: ntup } (<ntup{y) AP wk y }}
t_node =: {{ x t_nt   tna0 t_na   ''t_nb  (<t_ntup{y) AP t_wk y }}

NB. x t_emit ts -> ts: push item x into the current node buffer
NB.emit =: {{ (<x) AP nb y }}
t_emit =: {{ (<x) AP t_nb y }}

NB. x t_head ts -> ts: set item x to be the head(tag)
t_head =: {{ it t_nt s [ 'it s' =. t_nb tk y }}
t_head =: {{ t_nt&>/(t_nb tk) y }}
t_head =: [: t_nt&>/ (t_nb tk)

NB. x t_attr ts -> ts. take last item and assign as attribute x
t_attr =: {{ (x,&<it) AP t_na yy['it yy' =. t_nb tk y }}

NB. done: s->s. closes current node and makes it an item of previous node-in progress.
NB. done =: {{ (ntup{y) emit (>old) ntup} s [ 'old s'=.wk tk y }}
t_done =: {{ (t_ntup{y) t_emit (>old) t_ntup} s [ 'old s'=.t_wk tk y }}

NB. m tbm1 s -> s. execute tree builder method m on the tree state
tbm1 =: {{ y ts~   (m,'__t')~ ts y [ t =. tb y}}
tbm2 =: {{ y ts~ x (m,'__t')~ ts y [ t =. tb y}}



NB. combinators for tree building.
NB. ------------------------------
NB. tok =: ifu {{ x] (ix y) mk (cb y) emit y }}
tok =: ifu (ix@] mk cb@] 't_emit'tbm2 ])
sym =: lit tok

NB. u elm n : s->s. create node element tagged with n if u matches
NB.elm =: {{ 't_done'tbm1^:mb u n 't_node'tbm2 y }}
elm =: {{
  if.mb s=. u n 't_node'tbm2 y do.'t_done'tbm1 s
  else. O y end. }}

NB. u atr n : s->s. if u matched, move last item to node attribute n.
atr =: {{ if.mb  s=. u y do. I n 't_attr'tbm2 s else. O y end. }}

NB. u tag: s->s. move the last token in node buffer to be the node's tag.
NB. helpful for rewriting infix notation, eg  (a head(+) b) -> (+ (a b))
NB.tag =: {{'tag' if.mb  s=. u y do. I it head s ['it s' =. nb tk s else. O y end. }}
NB. tag =: ifu {{x] it head s ['it s' =. nb tk y }} NB.<- moved to head
tag =: ifu('t_head'tbm1@])


NB. -- common lexers -------------------------------------------

NB. character sets
alpha =: a.{~ , (i.26) +/ a.i.'Aa'
digit =: '0123456789'
hexit =: digit,'AaBbCcDdEeFf'
other =: (32}.127{.a.)-.alpha,digit
paren =: '()'
brack =: '[]'
curly =: '{}'
space =: 32{.a. NB. that's all ascii ctrl chars.

NB. Some predefined tokens
NL =: (CR lit opt)`(LF lit) seq
ALPHA  =: alpha chs
UNDER  =: '_' lit
DIGIT  =: digit chs
NUMBER =: digit rep
IDENT  =: (ALPHA`(ALPHA`DIGIT`UNDER alt orp) seq)
HEXIT  =: hexit chs
LPAREN =: '(' lit
RPAREN =: ')' lit
LBRACK =: '[' lit
RBRACK =: ']' lit
LCURLY =: '{' lit
RCURLY =: '}' lit
WS =: (TAB,' ') chs
WSz =: WS orp zap


NB. generic line splitter
lines =: {{ ,.> NB at s =. (NL not rep) tok sep (NL zap) on y }}


NB. -- j lexer -------------------------------------------------

NB. fragments used by the tokens:
j_op  =: (brack,curly,other-.'_') chs
j_num =: ('_' lit opt)`(DIGIT rep)`(('.'lit)`(DIGIT orp) seq opt) seq
squo =: ''''
squl =: squo lit
j_esc =: (2#squo) lit

NB. full tokens
J_LDEF =: '{{'lit
J_RDEF =: '}}'lit
J_NB  =: (('NB','.')lit)`(NL not rep) seq

J_STR =: squl`(j_esc`(squl not) alt orp)`squl seq
J_OPER =: (j_op`DIGIT`ALPHA alt)`('.:' chs rep) seq
J_OP   =: j_op
J_NUMS =: j_num`('j'lit`j_num seq opt)seq sep (WS rep)
J_TOKEN =: NL`J_LDEF`J_RDEF`LPAREN`RPAREN`J_NB`J_STR`J_OPER`J_NUMS`J_OP`IDENT alt
J_LEXER =: (WS zap)`(J_TOKEN tok) alt orp

J_STR on h=.'''hello'',abc'

NB. c-style strings/numbers
STR_ESC =: ('\'lit)`any seq
DQ =: '"'lit
STR =: DQ`(STR_ESC`(DQ not) alt orp)`DQ seq tok
INT =: DIGIT rep tok


NB. -- parser examples -----------------------------------------

NB. simple pascal -like block
BEGIN  =: 'begin' sym
END =: 'end' sym
nends =: END not orp tok
block =: (BEGIN`nends`END) seq
block on 'begin hello; 2+2; end'

TRACE =: 0
NB. m trace v: s->st. provides a trace of parse rule v if TRACE~:0
trace =: {{
  if. TRACE do. r [ smoutput m; r=.v Y=:y [ smoutput '>> ',m
  else. v y end. }}

NB. s-expressions (lisp-like syntax)
LP =: 'LP' trace (LPAREN zap)
RP =: 'RP' trace (RPAREN zap)
ID =: 'ID' trace (LP`RP`WS`DQ alt not rep tok)

NB. se: s-expression parser
se_a =: ID`STR`INT alt NB. just the atoms
se_p =: 'se' trace (WSz`LP`((se_a tag opt)`se_s seq)`RP seq elm '' sep WSz)
se_s =: se_p`se_a`WSz alt orp
se =: end`se_s alt

NB.se_p =: LP`((se_a tag opt)`(WSz`se_p`se_a alt orp)seq)`RP seq elm ''
NB.se =: (WSz`end seq)`(se_p`se_a alt sep WSz) alt

NB. ll: lisp lexer
ll =: WSz`((LPAREN tok)`(RPAREN tok)`WS`ID`(STR tok) alt)seq orp


NB. -- tree matching -------------------------------------------

NB. u all: s->s. matches if u matches the entire remaining input.
all =: {{ (u f.)`end seq }}

NB. u box: s->s. matches if current value is
box =: {{
  if. 32 = 3!:0 c =. ch y
  do. smoutput 'entering box C:' [ C =: > c
      smoutput c
      f mb nx^:f s [f=.mb s=.u all on > c else. O y end. }}


NB. -- test suite ----------------------------------------------

T =: [:`]@.mb NB. T = assert match
F =: ]`[:@.mb NB. F = assert doesn't match

T any on 'hello'
F any neg on 'hello'
T any neg on ''
T end on ''
F end on 'x'
F 'a' chr on 'xyz'
T 'a' chr on 'abc'
T 'abc' chs on 'cab'
F 'abc' chs on 'xyz'
T ('a'chr)`('b'chr)`('c'chr) seq on 'abc'
F ('a'chr)`('b'chr)`('c'chr) alt on 'xyz'
T ('a'chr)`('b'chr)`('c'chr) alt on 'abc'
T 'ab' lit on 'abc'

T 'ab' lit tok on 'abc'

T 'ab' sym on 'abc'
T '3' lit opt on '1'
T '3' lit opt on '3'
T 'a'lit`('b'lit opt)`('c'lit) seq on 'abc'
T 'a'lit`('b'lit opt)`('c'lit) seq on 'acb'

T ('a'lit rep) on 'aab'
F ('a'lit rep) on 'bba'
T ('a'lit rep)`('b'lit) seq on 'aaab'

T 'x' lit not on 'a'

jsrc =. 0 : 0
avg =: +/ % #  NB. average is sum div len
avg +/\>:i.10  NB. average of first 10 triangle nums (22)
name =. 'Sally O''Malley'
)

[ expect =: (;:jsrc)
[ actual =: J_LEXER parse jsrc
assert expect -: actual

aa=:ALPHA`ALPHA seq tok
actual =: (('abc'lit tok)`(aa atr 'a0')`(aa atr 'a1')seq elm'n' parse 'abcdefg')
expect =: ,<(<'n'),(<2 2$(<'a0'),(<<'de'),(<'a1'),<<'fg'),<,<'abc'
'atr atr elm' assert expect -: actual

actual =: aa tag`aa`aa seq elm'' parse'banana'
expect =: ,<(<<'ba'),(<tna0),<<;._1 ' na na'
'tag elm' assert expect -: actual


NB. -- more examples -------------------------------------------
NB. !! probably should move this elsewhere.

examples =. {{
  nx^:(<#S) hw0 =: on S=.'hello (world 123)'
  'a'lit rep on 'aaa'
  ab =: ('a'lit)`('b'lit)
  ab seq on 'abcat'
  'c'lit opt on 'cat'   NB. 1
  'c'lit opt on 'bat'   NB. 1
  'c'lit on 'bat'       NB. 0
  'a'lit rep on 'aaaahello'
  'a' lit sep (','lit) on 'a,a,a.b'
  ('hello'lit)`(', 'lit zap)`('world'lit) seq on 'hello, world'
  (NL not) rep on 'hello'
  hi =: ('hello'sym)`(', 'lit zap)`('world'sym atr 'who') seq
  [  s =: hi on 'hello, world'
   s =: hi elm 'hi' on 'hello, world'
 }}

examples'' NB. no output, but will complain if anything broke

nil`any`end `:0@ on each '';'x'

lisp =: '(one two (a b c) three) (banana)'
ll parse lisp
se parse lisp
assert 2 = $ se parse lisp


NB. -- tree walker ---------------------------------------------

NB. u t_visit tree -> [result] : apply u to each node of the tree.
t_visit =: {{ (u y),, u t_visit every (#~ (<'boxed')=datatype each) t_nb y }}
assert (;:'a b d g') -: t_nt t_visit ts se on'(a (b c (d e) f (g h))))'


NB. -- decompiler ----------------------------------------------
cocurrent 'decompile'
ar =: 5!:1@<
br =: 5!:2@<
tr =: 5!:4@<
ops =: ;:'nil any lit chs seq alt tok sym zap opt rep orp not sep elm atr tag'
all =: ops,;:'try ifu'
ALL =: toupper each all
(ALL) =: br each all

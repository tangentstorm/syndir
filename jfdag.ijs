NB. tree/dag database stored in a single jfile.
NB. each node is a component
require 'jfiles' NB. jcreate, jerase, jappend, jread, jreplace, jdup, jsize

NB. -- struct builder (see parseco.ijs) --
AT =: {{ m&{:: : (<@[ m} ]) }}
struct =: {{
  ({{ ". x,'=:',(":y),' AT' }}&>"0 i.@#) fs =. cut y
  ". m,'=: (a:#~',(":#fs),'"_) : (;:@',(quote y),')'  }}

NB. -- node structure --------------------

'N' struct 'ntp ntx nkv nup ndn'

D0 =: 2 0$a:
N0 =: D0 nkv N''


NB. -- database api ----------------------

JF =: '.dag.jf'

jfap =: jappend&JF       NB. append
jfr =: [: jread JF;]     NB. read
jfw =: [ jreplace JF;]   NB. write
jfl =: 1 { jsize@JF      NB. length
jf =: jfr : jfw          NB. read/write

wjf =: {{ r[y jf~ r=.u&.> jf y }} NB. with jfile

jfac =: {{ NB. nid jfac text -> nid  : add child
  r =. jfap < y ntx x nup N0
  (ndn~ r ,~ ndn) wjf x
  r }}

jfdag0 =: {{
  assert 0=jfl''
  root =. jfap < '(root)'ntx N0
  meta =. root jfac '(meta)'
  lang =. root jfac '(lang)'
  user =. root jfac '(user)'

  ebnf =. lang jfac 'ebnf'
  gram =. lang jfac 'gram'
  sexp =. lang jfac 'sexp' }}

NB. create and initialize if necessary
(jfdag0@jcreate)^:(-.@fexist) JF

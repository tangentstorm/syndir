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

jfa =: jappend&JF        NB. append
jfr =: [: jread JF;]     NB. read
jfw =: [ jreplace JF;]   NB. write
jfl =: 1 { jsize@JF      NB. length
jf =: jfr : jfw          NB. read/write

wjf =: {{ r[y jf~ r=.u&.> jf y }} NB. with jfile

jfc =: {{ NB. nid jfc text -> nid  : add child
  r =. jfa < y ntx x nup N0
  (ndn~ r ,~ ndn) wjf x
  r }}

{{ (y)=: i.#;:y }}'JF_ROOT JF_META JF_LANGS JF_TREES JF_EBNF JF_JSON'

jf0 =: {{
  assert 0=jfl''
  assert JF_ROOT  = jfa < '(root)'ntx N0
  assert JF_META  = JF_ROOT jfc 'JF_META'
  assert JF_LANGS = JF_ROOT jfc 'JF_LANGS'
  assert JF_TREES = JF_ROOT jfc 'JF_TREES'
  assert JF_EBNF  = JF_LANGS jfc 'ebnf'
  assert JF_JSON  = JF_LANGS jfc 'json' }}

NB. create and initialize if necessary
(jf0@jcreate)^:(-.@fexist) JF

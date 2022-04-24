NB. tree/dag database stored in a single jfile.
NB. each node is a component
require 'jfiles' NB. jcreate, jerase, jappend, jread, jreplace, jdup, jsize

NB. -- struct builder (see parseco.ijs) --
AT =: {{ m&{:: : (<@[ m} ]) }}
struct =: {{
  ({{ ". x,'=:',(":y),' AT' }}&>"0 i.@#) fs =. cut y
  ". m,'=: (a:#~',(":#fs),'"_) : (;:@',(quote y),')'  }}

NB. -- node structure --------------------

'N' struct 'ntp ntx nup ndn'

N0 =: N''

NB. -- database api ----------------------

JF =: '.dag.jf'

jfr =: [: jread JF;]
jfa =: jappend&JF
jfw =: [ jreplace JF;]
jfl =: 1 { jsize@JF NB. length
jf =: jfr : jfw
wjf =: {{ r[y jf~ r=.u&.> jf y }} NB. with jfile


initdag =: {{
  assert 0=jfl''
  jfa < '(root)'ntx  ''nup  (1+i.3)ndn N0
  jfa < '(lang)'ntx 0 nup N0
  jfa < '(docs)'ntx 0 nup N0
  jfa < '(user)'ntx 0 nup N0 }}

NB. create and initialize if necessary
(initdag@jcreate)^:(-.@fexist) JF

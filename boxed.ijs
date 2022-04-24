NB. editor for boxed structures
require 'list.ijs cursor.ijs'
require 'tangentstorm/j-kvm'

coclass 'BoxEd'
coinsert 'Cursor kvm vt'
doc =: 'A simple editor for boxed arrays'

NB. create inherited from Cursor

boxc =: ,(,.<"0 a.{~ 16+i.11),.(8 u: dfh) each cut'250c 252c 2510 251c 253c 2524 2514 2534 2518 2502 2500'
boxe =: {{ y rplc"1 boxc }}


wr =: {{puts 8 u: y}}
cw =: wr
wl =: {{ wr CRLF,~ boxe y }}"1
rk =: rkey
NB. rl =: (1!:1)@1
rl =: {{
  r =. ''
  while. -. (CRLF) e.~ k =. a.{~{.>rkey'' do.
    NB. why exactly is this 255 character getting used?
    r=.(255{a.)-.~r,k
  end.
  r }}


NB. "tab stops" for each item, since they may have different lengths
stops =: {:@$@":\

errmsg =: 13!:12

show =: verb define
  NB.cscr''
  goxy 0 0
  boxes =. value__data
  wl ": boxes          NB. draw the boxed items  !! TODO: fix box chars
  goxy 1 3
  'c w' =. (here&{ , {:) 0,<: stops boxes  NB. cursor, width
  fg _8  NB.cw '|K',
  wr (u:' ',u:8593) {~ c = i. 1+ w  NB. draw arrow for (each?) cursor
  fg _12   NB.cw '|B'
  goxy 0 4
  try. wr"1 ": ". ; }. ,(<,' '),. boxes catch. wr errmsg '' [ fg _1 end. NB. cw |r
  fg _7 NB.cw '|w'
)

prompt =: verb define
  goxy 0 5
  fg _3
  wr y
  fg _7
  raw 0
  ln =: rl''
  raw 1
  ;:ln
)

run =: {{
  cscr'' [ curs 0
  show loop_kvm_ coname''}}

k_p =: k_arrlf =: nudge@_1
k_n =: k_arrrt =: nudge@1

k_q =: {{ break_kvm_ =: 1 }}
k_x =: cscr@del
k_d =: cscr@dup
k_t =: cscr@swap
k_i =: cscr@ins@prompt@'> '

BoxEd_z_ =: conew&'BoxEd'

ed =: BoxEd;:'+/p:i.10'
run__ed''

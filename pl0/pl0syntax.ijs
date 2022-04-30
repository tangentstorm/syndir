NB. hand-written pretty printer for pl0.sx
load'../parseco.ijs'
load'tangentstorm/j-kvm/vt'
load'tangentstorm/j-kvm/cw'
coinsert'cw'
coinsert'vt'

dumps =: {{ 5!:6<'y'}}


is_node =: (3=#) *. 'boxed'-:datatype

pl0 =: ':sx' t_nt 3{.ts se on CRLF -.~ freads'pl0.sx'

cw =: puts
dbg 1
is_node =: (3=#) *. 'boxed'-:datatype
is_rule =: (~:toupper)@{.
draw =: {{
  if. -. is_node y do. y=.>y end.
  if. -. is_node y do. fg'K'
    BAD =: y
    puts '%[',":>y
    puts ']'
    'bad node' throw.
    return.
  end.
  assert is_node y
  select. nt=.>t_nt y
  case. ':sx' do.
    for_child. t_nb y do. draw child end.
  case. ':grammar' do. cw 'grammar ',(;2{::y),CRLF
  case. ':nb' do.
    fg'K'
    cw (;t_nb y),CRLF
  case. ':ref' do.
    nm =. ;t_nb y
    if. is_rule nm do. fg'w' else. fg 'B' end.
    cw nm
  case. ':lit' do.
    fg'g'
    cw (;t_nb y)
  case. ':nil' do.
    fg'K'
    cw '""'
  case. ':def' do.
    fg'W'
    cw (;0{::t_nb y)
    fg'K'
    cw ': ',CRLF,'  '
    for_child. >}.t_nb y do.
      draw child
    end.
    cw CRLF
  fcase. ':rep' do.
  fcase. ':opt' do.
  case.  ':orp' do. s=.'?*+'{~ nt (i."_~) _4[\':opt:orp:rep'
    fg'K'
    cw'('
    for_child. ,t_nb y do. draw child end.
    fg'K'
    cw')',s
  case. ':seq' do.
    for_child. t_nb y do. draw child end.
  case. ':sep' do.
    nb =. t_nb y
    assert (#nb)=2
    draw 0{nb
    fg 'r'
    cw '/'
    draw 1{nb
  case. ':alt' do.
    fg'K'
    cw'('
    for_child. t_nb y do.
      if. child_index > 0 do.
        fg 'K'
        cw '|'
      end.
      draw child
    end.
    fg'K'
    cw')'
  case. do. NB. unhandled
    fg'r'
    cw 'unknown: '
    fg 'R'
    cw >t_nt y
  end.}}


draw pl0
cw fg'w'

NB. boxer: build trees with nested boxes

NB. stacks of like objects
NB. ----------------------------------------------------------
coclass  'Stack'

create =: {{ data =: y }}
pop    =: {{ r [ data =: }. data [ r =. {. data }}
push   =: {{ data =: y , data }}
append =: {{ data =: data , y }}
extend =: append
top    =: {{ > {. data }}    NB. top of stack
result =: {{ data }}
destroy=: codestroy

NB. stacks of boxed objects (mixed types)
NB. ----------------------------------------------------------
coclass  'BoxStack'
coinsert 'Stack'

NB. overrides:
extend =: [: extend_Stack_ f. <
push   =: [:   push_Stack_ f. <
tos    =: [: > top_Stack_  f.
pop    =: [: > pop_Stack_  f.


NB. Boxers build trees of boxed objects.
NB. ---------------------------------------------------------
coclass  'Boxer'

create =: {{
  state =: 0
  depth =: 0
  main  =: '' conew 'BoxStack'
  path  =: '' conew 'BoxStack'
  here  =: main }}

pushstate =: {{
  depth =: depth + 1
  push__path state
  push__path here
  here  =: '' conew 'BoxStack'
  state =: y }}

popstate =: {{
  tmp   =. result__here''
  there =. here
  here  =: pop__path''
  if. # tmp do. extend__here tmp else. extend__here a: end.
  state =: pop__path ''
  depth =: depth - 1
  destroy__there'' }}

append =: {{ append__here y }}
extend =: {{ extend__here y }}
result =: {{ result__main _ }}
destroy=: {{
  coerase here,path
  codestroy'' }}


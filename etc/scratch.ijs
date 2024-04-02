walk =: {{
  if. y -: a: do. return. end. NB. ??
  on_node__x y
  for_box. t_nb y do.
    item =. >box
    if. is_node item do. x walk item
    else. on_leaf__x item end.
  end.
  on_done__x y }}

dbg 1
depth =: 0
on_node =: {{ depth =: 1+depth [ puts ('('&,)^:(*depth) >t_nt y}}
on_leaf =: {{ puts ' ', y }}
on_done =: {{ puts ')', CRLF }}


NB. load pl0.sx into jfdag repo.

load 'tangentstorm/j-kvm/vt'
load '../parseco.ijs ../jfdag.ijs'
coinsert 'vt'

is_node =: (3=#) *. 'boxed'-:datatype

import_tree =: {{
  nid =. x jfc >t_nt y
  for_box. t_nb y do.
    item =. >box
    if. is_node item do. nid import_tree item
    else. nid jfc item end.
  end.
  nid}}


pl0 =: JF_LANGS import_tree 'pl0' t_nt 3{.ts se on CRLF -.~ freads'pl0.sx'

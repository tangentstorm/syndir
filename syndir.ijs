#!/usr/bin/env j
NB. syndir : a syntax directed editor
NB. -----------------------------------------
require 'tangentstorm/j-kvm/ui'
require 'jfdag.ijs'
coinsert'kvm vt'

NB. -- db-ui bridge -------------------------

fetch_items =: {{
  dn =. ndn>jf y
  try. (([: <"1 (<"0 dn),.(ntx L:1)) ; *@#@ndn S:1) jf dn
  catch. 2 $ a:
  end. }}

NB. fetch_items 0
NB. ┌──────────────────────────────────┬─────┐
NB. │┌──────────┬──────────┬──────────┐│0 1 0│
NB. ││┌─┬──────┐│┌─┬──────┐│┌─┬──────┐││     │
NB. │││1│(meta)│││2│(lang)│││3│(user)│││     │
NB. ││└─┴──────┘│└─┴──────┘│└─┴──────┘││     │
NB. │└──────────┴──────────┴──────────┘│     │
NB. └──────────────────────────────────┴─────┘


NB. -- build the tree control ---------------
tree =: UiTree fetch_items 0
'H__tree W__tree' =: _1 0 + gethw_vt_''
TX_BG__tree =: _234
fetch_items__tree =: {{ fetch_items_base_ (0;0) {::C{L }}

nid__tree =: {{ 0{::>C{L }}

NB. extract the label
render_item__tree =: {{
  x render_item_UiTree_ f. 7 u: (0;1){::y }}

NB. line editor control

NB. -- status line  -------------------------

stat =: UiWidget''
tree__stat =: tree_base_
W__stat =: W__tree
XY__stat =: 0,H__tree
render__stat =: {{
  bg _8
  fg _7
  puts ' nid: ', 0":nid__tree''
  ceol''
}}


NB. -- keyboard handler ---------------------

k_nul =: {{ exit 0 [ curs 1 [ raw 0 }} NB. ctrl-space/ctrl-@
k_n =: fwd__tree
k_p =: bak__tree
k_u =: upw__tree
k_q =: {{break_kvm_=:1}}
k_t =: toggle__tree

NB. code to run instead of j prompt
main =: {{
  curs err =. 0
  app =: UiApp tree,stat
  try.  step__app loop_kvm_ 'base'
    NB. codestroy__app''
  catch. err =. 1 end.
  curs 1 [ raw 0  [ reset''
  if. err do. echo dberm'' end. }}

(9!:29) 1 [ 9!:27 'main _ '

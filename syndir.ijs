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


NB. -- tree control -------------------------

tree =: UiTree fetch_items 0
'H__tree W__tree' =: _1 0 + gethw_vt_''
TX_BG__tree =: _234
fetch_items__tree =: {{ fetch_items_base_ (0;0) {::C{L }}

nid__tree =: {{ 0{::>C{L }}
txt__tree =: {{ 1{::>C{L }}
set_txt__tree =: {{ L=:(<(<y)1}>C{L)C}L }}

ind__tree =: {{ 2+C{D }} NB. indentation



NB. extract the label
render_item__tree =: {{
  x render_item_UiTree_ f. 7 u: (0;1){::y }}


NB. line editor control

led =: UiEditWidget''
V__led =: 0
NB.BG__led =: CU_BG__tree
NB.FG__led =: CU_FG__tree

edit_item =: {{
  C__led =: 0
  XY__led =: (C__tree,~ind__tree'') + XY__tree
  W__led =: W__tree - ind__tree''
  B__led =: txt__tree''
  V__led =: 1
  F__app =: led
}}


on_accept__led =: {{
  V =: 0
  tree =. tree_base_ [ app =. app_base_
  F__app =: tree
  set_txt__tree B
  (B & ntx_base_) wjf_base_ nid__tree''
}}

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

cocurrent tree
k_n =: fwd
k_p =: bak
k_u =: upw
k_q =: {{break_kvm_=:1}}
k_t =: toggle
k_e =: edit_item_base_
k_i =: 1&ins_item_base_
k_I =: 0&ins_item_base_
k_c =: 0&ins_child_base_
k_C =: 1&ins_child_base_

cocurrent 'base'

NB. code to run instead of j prompt
app =: UiApp tree,stat,led

(9!:29) 1 [ 9!:27 'run__app _ '

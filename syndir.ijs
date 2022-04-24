NB. syndir : a syntax directed editor
NB. -----------------------------------------
require 'tangentstorm/j-kvm/ui'
require 'jfdag.ijs'
coinsert'kvm vt'

NB. -- db-ui bridge -------------------------

fetch_items =: {{
  try. (ntx L:1 ; *@#@ndn S:1) jf ndn>jf y
  catch. 2 $ a:
  end. }}


NB. -- build the tree control ---------------
tree =: UiTree L['L HC'=.fetch_items 0
HC__tree =: HC
H__tree =: {.gethw_vt_''
TX_BG__tree =: _234
fetch_items__tree =: {{ fetch_items_base_ C{L }}


NB. -- keyboard handler ---------------------

k_nul =: {{ exit 0 [ curs 1 [ raw 0 }} NB. ctrl-space/ctrl-@
k_n =: fwd__tree
k_p =: bak__tree
k_u =: upw__tree
k_q =: {{break_kvm_=:1}}
k_t =: toggle__tree


NB. code to run instead of j prompt
main =: {{
  curs 0
  app =: UiApp ,tree
  step__app loop_kvm_ 'base'
  curs 1 [ raw 0  [ reset''
  NB.codestroy__app''
}}

(9!:29) 1 [ 9!:27 'main _ '

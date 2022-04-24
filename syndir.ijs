NB. syndir : a syntax directed editor
NB. -----------------------------------------
require 'tangentstorm/j-kvm/ui'
coinsert'kvm vt'

NB. -- db-ui bridge -------------------------

fetch_items =: {{
  try.
    [:5
  catch. 2 $ a:
  end. }}


NB. -- build the tree control ---------------
tree =: UiTree fetch_items 0
H__tree =: {.gethw_vt_''
TX_BG__tree =: _234
fetch_items__tree =: {{ fetch_items_base_ C{L }}


NB. -- keyboard handler ---------------------
k_nul =: {{ exit 0 [ curs 1 [ raw 0 }}


NB. code to run instead of j prompt
main =: {{
  curs 0
  app =: UiApp ,tree
  step__app loop_kvm_ 'base'
  curs 1 [ raw 0  [ reset''
  NB.codestroy__app''
}}

(9!:29) 1 [ 9!:27 'main _ '

NB. plain text editor with parser support
require 'tangentstorm/j-kvm/ui'

fnm =: 2 {:: :: '' ARGV
txt =: UiList 'b'freads^:(*@#@]) fnm
grm =: UiList <'grammar goes here'
ast =: UiList <'AST goes here'


NB. -- layout ---------------
'h w' =: gethw_vt_''
'XY__txt XY__grm XY__ast' =: 0,"0(ih=.<.h%3)*i.3
'H__txt H__grm H__ast' =: ih

app =: UiApp txt,grm,ast

NB. tab key to switch widgets
kc_i__app =: {{ R__F=:1 [ F =: W{~(#W)|1+W i.F [ R__F=:1 }}

(9!:29) 1 [ 9!:27 'run__app _'

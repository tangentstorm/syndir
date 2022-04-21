require 'tangentstorm/j-kvm'
require 'sx.ijs dict.ijs unify.ijs stype.ijs'
coinsert 'vt'

NB. G holds the grammar
G=:emptyd

NB. defrule name (text) defines a new rule.
NB. format is: (node template) (patterns) (text template)
defrule=: {{ G =: (y S) put (< sx (0 : 0)) G }}

NB. (rule 'name') fetches the rule from the system as a triple
rule =: {{ ,> G get sym y }}

NB. special formatting symbols:
'SYM_NL SYM_SP'=:sym'\n _'

NB. grammar for a PL0-like language

defrule 'program'
  ($name $imps     $decs  $body)
  (iden  imports?  decl*  block)
  ("program" _ $name ";" \n
    $imps
    $decs \n
    $body ".")
)

defrule 'imports'
  ($mods)
  (iden*)
  ("import" _ ";" \n)
)

defrule 'writeln'
  ($args)
  (expr*)
  ("WriteLn(" $args / ","  ")")
)

defrule 'str'
 ($s) ($s) ("\"" $s "\"")
)



head =: ,@>@{.@,
tail =: }.@,

NB. render nodes, colored according to datatype
render =: RESET,~visit
NB. visit :: [box] -> string
visit =: ;@:(visit_box&.>)
NB. visit_box :: contents -> string
visit_box =: {{
  select. stype y
  case. BOX do.
    if. 1 do. visit y NB. if. #y=1
    else.
      NB. !! todo: this part does not return a string yet.
      'nm r t' =: ,>G get (head y)
      ((;nm) dict tail y) subs t
    end.
  case. TXT do. (FGC _15),y      NB. fg'W'
  case. NUM do. (FGC _14),":y    NB. fg'Y'
  case. SYM do.
    select. y
    case. SYM_NL do. LF
    case. SYM_SP do. ' '
    case. do. (FGC _6), 2 s:y  NB. sym→str  !! fg'c'
    end.
  case. do.
    if. #y do. (FGC _1),":y else. '' end.
  end. }}

NB. an example program
p0 =: 0 : 0
  (program hello ( ) ( )
    (block (writeln (str "hello, world.")) ))
)

NB. sx y -> list of boxes
NB. boxes contain either a symbol
render sx p0

require 'parseco.ijs'

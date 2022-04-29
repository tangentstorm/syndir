NB. sx : s-expression parser
NB.
NB. this uses the 'se' parser in parseco,
NB. and then strips out the (unused) attribute field
NB. and converts lisp symbols to j symbols,
NB. lisp numbers to j numbers.
NB.
NB. (not 100% sure i need those things, but this
NB. matches the older logic in sx-by-hand.ijs)

cocurrent'sx'
require 'cheq.ijs' NB. for unit tests at the end
require 'parseco.ijs'

dumps =: {{5!:6<'y'}}
is_node =: (3=#) *. 'boxed'-:datatype
no_attrs =: {{
  if. is_node y do.
    (t_nt , [: no_attrs each t_nb) y
  else. y end. }}

sx =: {{
  res =. se on y
  if. (-.mb res) +. (ix<<:@#@ib)res do.
    [:'parse failed'
  end.
  to_sym =: {{ if. *./y e.Num_j_ do. 0".y else. s:<y end. }}
  if. mb res do.
    to_sym L:0^:(*@#) no_attrs 3{.ts res
  end. }}


NB. mini test suite
a =: [: assert ]

a        a: = sx ''
a      (<1) = sx '1'
a     (1;2) = sx '1 2'

{{ goterr=.0 try. sx ')...' catch. goterr=.1 end.
   a goterr }}''

NB. ok, now let''s parse a valid s-expression:
cheq sx '1 ( 2(3 4 5  ) 6) 7'
┌─┬─────────────┬─┐
│1│┌─┬───────┬─┐│7│
│ ││2│┌─┬─┬─┐│6││ │
│ ││ ││3│4│5││ ││ │
│ ││ │└─┴─┴─┘│ ││ │
│ │└─┴───────┴─┘│ │
└─┴─────────────┴─┘
)


cheq sx' () (()) (() (())) '
┌┬──┬─────┐
││┌┐│┌┬──┐│
│││││││┌┐││
││└┘│││││││
││  │││└┘││
││  │└┴──┘│
└┴──┴─────┘
)
(0 : 0) NB. previously, it was this... not sure why?
┌──┬────┬─────────┐
│┌┐│┌──┐│┌──┬────┐│
│││││┌┐│││┌┐│┌──┐││
│└┘│││││││││││┌┐│││
│  ││└┘│││└┘│││││││
│  │└──┘││  ││└┘│││
│  │    ││  │└──┘││
│  │    │└──┴────┘│
└──┴────┴─────────┘
)

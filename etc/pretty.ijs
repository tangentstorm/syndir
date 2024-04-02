NB. pretty-printer drawing model

syms =: {{(y)=:s:;:y}}


NB. Tree = (str ; [Tree])

tree =: ('aaa';())


syms 'Text Nest Union Nil'

NB. Doc =
NB. - a:                    // empty doc (nil)
NB. - Text Str              // a string chunk/token (no newline)
NB. - Nest Int Doc          // indent/nest (always on new line)
NB. - Union Doc Doc

nil  =: ,<<Nil
text =: {{<Text;y}}
nest =: {{<Nest;x;y}}
U =: {{<Union;x,y}}

a=.(<Text;'hello'),(<Line;''),(<Nest;1;<Text;'world')
b=.(text'hello'),line,(1 nest (text'world'))
assert a-:b

NB. Doc -> Str
layout =: {{
  select. >{.y=.>y
  case. Nil do. ''
  case. Text do. >{: y
  case. Nest do. 
}}
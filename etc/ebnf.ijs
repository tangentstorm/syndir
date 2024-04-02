require 'tangentstorm/j-kvm/vt'
require 'parseco.ijs'
require 'gramco.ijs'

NB. -- ebnf ---
wsz =: WS orp zap
zw =: {{wsz`(u)`wsz seq}} NB. zap whitespace
zwt =: zw tok
zws =: lit zwt

syntax =: production orp
production =: (IDENT zwt)`('='zws)`expression`('.'zws) seq  elm 'rule'
expression =: term sep ('|'zws)
term =: factor zw rep
factor =: (IDENT zwt)`(J_STR zwt)`sub_factor`opt_factor`orp_factor alt zw
sub_factor =: ('(' zws)`expression`(')' zws) seq
opt_factor =: ('[' zws)`expression`(']' zws) seq
orp_factor =: ('{' zws)`expression`('}' zws) seq

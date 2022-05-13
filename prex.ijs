NB. this file designs a nice syntax for
NB. parsing and regular expressions.
load'parseco.ijs'

boxes =: {{ (x=#y) *. 'boxed'-:datatype  y }}
NB. no_attrs requires top level is an 'elm'
NB. !!why does this need <@t_nt, but only t_nt in sx.ijs?
no_attrs =: {{
  if. 3 boxes y do.
    (<@t_nt , [: no_attrs each t_nb) y
  else. y end. }}


NB. parser combinators for regular expressions
rx_lit =: ALPHA rep tok elm'lit'
rx_chs =: LBRACK`(ALPHA rep)`RBRACK seq elm'chs'

NB. rx_mod =: (nil elm'mod')`('?+*'chs tok tag) seq
rx_grp =: LP`rx_alt`RP seq elm'grp'
rx_trm =: rx_lit`rx_chs`rx_grp alt
rx_opt =: rx_trm`('?'lit zap) seq elm'opt'
rx_rep =: rx_trm`('+'lit zap) seq elm'rep'
rx_orp =: rx_trm`('*'lit zap) seq elm'orp'
rx_seq =: rx_opt`rx_rep`rx_orp`rx_trm alt rep elm'seq'
rx_alt =: rx_seq`('|'lit zap`rx_seq seq orp) seq elm'alt'
rx0 =: rx_alt`end seq elm'rx'

T rx0 on 'a'
T rx0 on '[ab]'
T rx0 on 'ab+'
T rx0 on 'a*b|b?c+'
T rx0 on 'a|b|c'
T rx0 on '(a|b)+'

simp =: {{ NB. simplify rx parse tree
 if. -. 'boxed'-:datatype y do. y return. end.
 h=.{.y [ t=.}.y
 if. h e. ;:'alt seq grp trm' do.
   NB. eliminate these nodes if only one element
   if.1=#t do. simp 0{::t return. end.
 end.
 h,simp each t }}

noa =: [: no_attrs 0{:: t_nb@ts
rx1 =: noa @ rx0 @ on
rx2 =: simp @ rx1
rx =: rx2

encs =: 1|.')(',]
gers =: '`' joinstring (encs each)
jsrc =: {{ NB. jsrc rx pattern -> j source
  h=.{.y [ t=.}.y
  select. h
  case. 'rx' do. jsrc 0{::t
  case. 'alt' do. (gers jsrc&.> t),' alt'
  case. 'seq' do. (gers jsrc&.> t),' seq'
  case. 'lit' do. (quote@;t),' lit'
  case. 'chs' do. (quote@;t),' chs'
  case. 'opt' do. (jsrc 0{::t),' opt'
  case. 'rep' do. (jsrc 0{::t),' rep'
  case. 'orp' do. (jsrc 0{::t),' orp'
  case. do. ,":y return.
  end. }}

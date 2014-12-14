NB. syndir : a syntax directed editor
NB. -----------------------------------------
NB. this file loads all the logic for syndir,
NB. but it doesn't do anything on its own.
NB. use run.ijs (jqt) or boxed.ijs (terminal)
NB. to get an interactive frontend.
NB. ------------------------------------------
NB. TODO: there MUST be a simpler way to load multiple files...
reqs=:'startup list cursor dict graphdb mvars stringdb unify'
3 : 0 ''
 for_req. ;:reqs do. load '~Syn/',(>req),'.ijs' end.
)

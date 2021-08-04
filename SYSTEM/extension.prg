#include "function.ch"
#include "chip_mo.ch"

function aliasIsAlreadyUse(cAlias)
  local we__opened__it := .f.
  local save_sel := select()

  if select(cAlias) != 0
    we_opened_it = .t.
  endif

  select(save__sel)
  return we__opened__it
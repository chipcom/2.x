#include 'function.ch'

function collectFilename(dateOfCase, catalog)
  local fName := ''
  local yearOfCase := Year(dateOfCase)

  if ! Empty(catalog)
    fName := '_mo' + str((dateOfCase - 2020),1) + alltrim(catalog)
  endif

  return fName
#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

** 13.03.23
function code_services_VMP(nYear)
  static arrVMP

  if isnil(arrVMP)
    arrVMP := hb_Hash()
    hb_HSet(arrVMP, 2023, '1.22.')
    hb_HSet(arrVMP, 2022, '1.21.')
    hb_HSet(arrVMP, 2021, '1.20.')
    hb_HSet(arrVMP, 2020, '1.12.')
    hb_HSet(arrVMP, 2019, '1.12.')
    hb_HSet(arrVMP, 2018, '1.12.')
  endif
  return iif(nYear < 2018, '', arrVMP[nYear])

** 13.03.23
function isServiceVMP(lshifr)
  local ret := .f.

  return ret
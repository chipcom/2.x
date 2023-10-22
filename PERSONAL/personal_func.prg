#include 'dbstruct.ch'
#include 'hbhash.ch'
#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 09.09.22 ������� ��� ᯥ樠�쭮�� ��� �� V021 �� ⠡��쭮�� ������ ���㤭���
function get_spec_vrach_V021_by_tabnom(tabnom)
  // tabnom - ⠡���� �����
  local aliasIsUse
  local oldSelect
  local ret := 0

  if tabnom == 0
    return 0
  endif

  aliasIsUse := aliasIsAlreadyUse('TPERS')
  if ! aliasIsUse
    oldSelect := Select()
    R_Use(dir_server + 'mo_pers', dir_server + 'mo_pers', 'TPERS')
  endif

  if TPERS->(dbSeek(str(tabnom, 5)))
    ret := ret_prvs_V015toV021(TPERS->PRVS_NEW)
  endif
  if ! aliasIsUse
    TPERS->(dbCloseArea())
  endif
  Select(oldSelect)
  return ret

// 01.10.21
function get_kod_vrach_by_tabnom(tabnom)
  local aliasIsUse
  local oldSelect, ret := 0

  if tabnom == 0
    return 0
  endif

  aliasIsUse := aliasIsAlreadyUse('TPERS')
  if ! aliasIsUse
    oldSelect := Select()
    R_Use(dir_server + 'mo_pers', dir_server + 'mo_pers', 'TPERS')
  endif

  if TPERS->(dbSeek(str(tabnom,5)))
    ret := TPERS->kod
  endif

  if ! aliasIsUse
    TPERS->(dbCloseArea())
  endif
  Select(oldSelect)
  return ret

// 01.10.21
function get_tabnom_vrach_by_kod(kod)
  local aliasIsUse
  local oldSelect, ret := 0

  if kod == 0
    return ret
  endif
  
  aliasIsUse := aliasIsAlreadyUse('TPERS')
  if ! aliasIsUse
    oldSelect := Select()
    R_Use(dir_server + 'mo_pers', , 'TPERS') 
  endif

  TPERS->(dbGoto(kod))
  if ! (TPERS->(Eof()) .or. TPERS->(Bof()))
    ret := TPERS->tab_nom
  endif

  if ! aliasIsUse
    TPERS->(dbCloseArea())
  endif
  Select(oldSelect)
  return ret

// 21.10.23
// ���� ���㤭��� �� ������ ����� � ��
function find_employee(mkod, dontClose)
  static dbTmp
  local aliasIsUse
  local oldSelect
  local hEmployee
  local aliasPersonal := 'P2'
  local row
  local i

  if mkod <= 0
    return hEmployee
  endif

  Default dontClose TO .f.

  aliasIsUse := aliasIsAlreadyUse(aliasPersonal)
  if ! aliasIsUse
    oldSelect := Select()
    R_Use(dir_server + 'mo_pers', , aliasPersonal)
    if isnil(dbTmp)
      dbTmp := (aliasPersonal)->(dbStruct())
    endif
  endif
  (aliasPersonal)->(dbGoto(mkod))
  if ! ((aliasPersonal)->(Eof()) .or. (aliasPersonal)->(Bof()))
    hEmployee := hb_Hash()
    hb_hCaseMatch(hEmployee, .f.)
    i := 0
    for each row in dbTmp
      ++i
      hb_hSet(hEmployee, row[DBS_NAME], (aliasPersonal)->(FieldGet(i)))
    next
  endif

  if (! aliasIsUse) .and. (! dontClose)
    (aliasPersonal)->(dbCloseArea())
  endif
  Select(oldSelect)

  return hEmployee

#include 'hbhash.ch' 
#include 'function.ch'
#include 'chip_mo.ch'
#include 'edit_spr.ch'

#require 'hbsqlit3'

// =========== T005 ===================
//
// 19.05.23 ������ ���ᨢ �訡�� ����� T005.dbf
function loadT005()
  // �����頥� ���ᨢ �訡�� T005
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // T005 - ���祭� �訡�� �����
  //  1 - code(3)  2 - error(C) 3 - opis(M)
  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'code, ' + ;
        'error, ' + ;
        'opis ' + ;
        'FROM t005')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), alltrim(aTable[nI, 3])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil

    // ������� �� �ࠢ�筨�� _mo_f014.dbf
    for each row in getF014()
      if (j := ascan(_arr, {|x| x[1] == row[1] })) == 0
        AAdd(_arr, {row[1], alltrim(row[2]), alltrim(row[3])} )
      endif
    next
  endif
  return _arr

// 04.08.21 ������ ��ப� ��� ���� ��䥪� � ���ᠭ��� �訡�� ����� �� �ࠢ�筨�� T005.dbf
Function ret_t005(lkod)
  local arrErrors := loadT005()
  local row := {}

  for each row in arrErrors
    if row[1] == lkod
      return '(' + lstr(row[1]) + ') ' + row[2] + ', [' + row[3] + ']'
    endif
  next

  return '�������⭠� ��⥣��� �஢�ન � �����䨪��஬: ' + str(lkod)

// 28.06.22 ������ ��ப� ��� ���� ��䥪� � ���ᠭ��� �訡�� ����� �� �ࠢ�筨�� T005.dbf
Function ret_t005_smol(lkod)
  local arrErrors := loadT005()
  local row := {}

  for each row in arrErrors
    if row[1] == lkod
      return '(' + lstr(row[1]) + ') ' + row[2] 
    endif
  next

  return '�������⭠� ��⥣��� �஢�ન � �����䨪��஬: ' + str(lkod)

// 05.08.21 ������ ���ᨢ ����⥫� �訡�� ��� ���� ��䥪� � ���ᠭ��� �訡�� ����� �� �ࠢ�筨�� T005.dbf
Function retArr_t005(lkod, isEmpty)
  local arrErrors := loadT005()
  local row := {}
  default isEmpty to .f.
   for each row in arrErrors
    if row[1] == lkod
      return row
    endif
  next

  return iif(isEmpty, {}, {'�������⭠� ��⥣��� �஢�ન � �����䨪��஬: ' + str(lkod), '', ''})

// =========== T007 ===================
//
// 02.06.23 ������ ���ᨢ ����� T007.dbf
function loadT007()
  // �����頥� ���ᨢ T007
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // T007 - ���祭�
  // PROFIL_K,  N,  2
  // PK_V020,   N,  2
  // PROFIL,    N,  2
  // NAME,      C,  255
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'profil_k, ' + ;
        'pk_v020, ' + ;
        'profil, ' + ;
        'name ' + ;
        'FROM t007')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), val(aTable[nI, 2]), val(aTable[nI, 3]), alltrim(aTable[nI, 4])})
      next
    endif
    db := nil
  endif
  return _arr

// 04.06.23 ���ᨢ T007 ��� �롮�
function arr_t007() 
  static arr
  static time_load
  local arrT007 := loadT007()
  local row

  if timeout_load(@time_load)
    arr := {}
    for each row in arrT007
      if AScan(arr, {|x| x[2] == row[1]}) == 0
        aadd(arr, {alltrim(row[4]), row[1], row[2]})
      endif
    next
  endif
  return arr

// 02.06.23 ������ ���ᨢ ��䨫�� ���. �����
Function ret_arr_V002_profil_k_t007(lprofil_k)
  local arrT007 := loadT007()
  local arr := {}, row := {}

  for each row in arrT007
    if row[1] == lprofil_k
      aadd(arr, {inieditspr(A__MENUVERT, getV002(), row[3]), row[3]})
    endif
  next

  return arr

// =========== T008 ===================
//
// 23.10.22 ������ ���� �訡�� � ��⮪���� ��ࠡ�⪨ ���.����⮢ T008.xml
function getT008()
  // T008.xml - ���� �訡�� � ��⮪���� ��ࠡ�⪨ ���.����⮢
  // 1 - NAME (C), 2 - CODE (N), 3 - NAME_F (C), 4 - DATE_B (D), 5 - DATE_E (D)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {'���� 㦥 �� ����㦥�', 0, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'���� �� ᮮ⢥����� xsd-�奬�', 1, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'�����४⭮� ��⠭�� ����� �� (codeM � Mcod)', 2, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'�����४�� ��� ��䨫�', 3, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'�����४�� ��� ��䨫� �����', 4, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'�����४�� ��� ��������', 5, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'�����४⭠� �ଠ �������� �� (V014)', 6, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'�����४�� ⨯ ���㬥�� (F008)', 7, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'�����४�� ��� (V005)', 8, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'�����४�� ॥��஢� ��� �� �ਤ��᪮�� ���', 9, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'�����४�� ॣ����樮��� ��� �� �� �����', 10, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'������� ���ࠢ����� ��� � �믨ᠭ���', 11, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'�����४�� ��� ��稭� ���㫨஢����', 12, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'�����४�� ॥��஢� ��� ���', 13, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'��䨫� ����� �� ᮮ⢥����� ��䨫� ��', 14, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'�����४⭠� ��� ��ᯨ⠫���樨', 15, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'������ �� ������� ���ࠢ����� 㦥 �뫠 ����㦥��', 16, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'���������� ᢥ����� � �믮������� ��ꥬ�� ��� ���', 17, '', stod('20160915'), stod('22220101')})
    aadd(_arr, {'���⭠� ��� �⫨筠 �� ⥪�饩', 18, '', stod('20170220'), stod('22220101')})
    aadd(_arr, {'����襭� 㭨���쭮��� ID_D', 19, '', stod('20180829'), stod('22220101')})
    aadd(_arr, {'��� � ����� 䠩�� �� ᮮ⢥����� DATE_R', 20, '', stod('20180907'), stod('22220101')})
    aadd(_arr, {'��� � ����� �� ᮮ⢥����� DATE_R', 21, '', stod('20180907'), stod('22220101')})
    aadd(_arr, {'�ॢ�襭 �ப ����⢨� ���ࠢ����� (30 ����)', 22, '', stod('20180907'), stod('22220101')})
    aadd(_arr, {'�訡�� � ��㣨� ������� 䠩��', 999, '', stod('20140701'), stod('22220101')})
  endif

  return _arr

// =========== T012 ===================
//
// 26.12.22 ������ ���ᠭ�� �訡�� �� �����䨪��� �訡�� ����� ISDErr.xml
function getError_T012(code)
  static arr
  local db
  local aTable
  local nI
  local s := '�訡�� ' + lstr(code) + ': '

  if arr == nil
    arr := hb_hash()
  
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT code, name FROM isderr')
    if len(aTable) > 1
      for nI := 2 to Len(aTable)
        hb_hSet(arr, val(aTable[nI, 1]), alltrim(aTable[nI, 2]))
      next
    endif
    db := nil
  endif

  if hb_hHaskey(arr, code) 
    s += alltrim(arr[code])
  else
    s += '(�������⭠� �訡��)'
  endif

  return s
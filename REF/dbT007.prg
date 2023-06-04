#include 'function.ch'
#include 'chip_mo.ch'

#require 'hbsqlit3'

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

// 28.06.22 ������ ��ப� ��� ���� ��䥪� � ���ᠭ��� �訡�� ����� �� �ࠢ�筨�� T005.dbf
Function ret_t007_smol(lkod)
  local arrErrors := loadT005()
  local row := {}

  for each row in arrErrors
    if row[1] == lkod
      return '(' + lstr(row[1]) + ') ' + row[2] 
    endif
  next

  return '�������⭠� ��⥣��� �஢�ન � �����䨪��஬: ' + str(lkod)

// 05.08.21 ������ ���ᨢ ����⥫� �訡�� ��� ���� ��䥪� � ���ᠭ��� �訡�� ����� �� �ࠢ�筨�� T005.dbf
Function retArr_t007(lkod, isEmpty)
  local arrErrors := loadT005()
  local row := {}
  default isEmpty to .f.
   for each row in arrErrors
    if row[1] == lkod
      return row
    endif
  next

  return iif(isEmpty, {}, {'�������⭠� ��⥣��� �஢�ન � �����䨪��஬: ' + str(lkod), '', ''})

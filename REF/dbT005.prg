#include 'function.ch'
#include 'chip_mo.ch'

#require 'hbsqlit3'

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

// 04.08.21 ������ ���ᨢ �訡�� ����� T005.dbf
function loadT005_1()
  // �����頥� ���ᨢ
  static _T005 := {}
  Local dbName, dbAlias := 'T005'
  local tmp_select := select()
  local row

  // T005.dbf - ���祭� �訡�� �����
  //  1 - KOD(3)  2 - NAME(C) 3 - OPIS(M)
  if len(_T005) == 0
    dbName := '_mo_T005'
    tmp_select := select()
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      AAdd(_T005, {(dbAlias)->KOD, alltrim((dbAlias)->NAME), alltrim((dbAlias)->OPIS)} )

      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)

    // ������� �� �ࠢ�筨�� _mo_f014.dbf
    for each row in getF014()
      if (j := ascan(_T005, {|x| x[1] == row[1] })) == 0
        AAdd(_T005, {row[1], alltrim(row[2]), alltrim(row[3])} )
      endif
    next
  endif

  return _T005

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

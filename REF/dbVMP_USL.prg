#include 'function.ch'
#include 'chip_mo.ch'

// 30.12.22 �����頥� ��� ��㣨 ᮮ⢥�����騩 ���� � ��⮤� ��� � ��������
function getServiceForVMP(lvidvmp, dateSl, hVid, hMethod, model, sDiag)
  // hVid - ��� ��� (��ப�)
  // hMethod - ��⮤ ��� (楫��)
  // model - ������ ��樥�� V022 (楫��)
  // sDiag - �᭮���� �������
  local ret := '', vid := alltrim(hVid), diag := alltrim(sDiag)
  local i := 0, row, arr := {}

  if year(dateSl) < 2021
    return '1.12.' + lstr(lvidvmp)
  endif

  for each row in getVMP_USL(dateSl)
    arr := hb_ATokens(row[5], ';')  // ࠧ��୥� ���ᨢ ࠧ�襭��� ��������� ��� ���
    if row[2] == vid .and. row[3] == hMethod .and. row[4] == model .and. (ascan(arr, diag) > 0)
      ret := row[1]
      exit
    endif
  next
  return ret

// 01.12.21 �����頥� ���ᨢ ᮮ⢥��⢨� ����� � ��⮤�� ��� ��㣠� ����
function getVMP_USL( dateSl)
  static arrVMP_USL := {}

  Local dbName, dbAlias := 'VMP_USL'
  local tmp_select := select()
  
  if len(arrVMP_USL) == 0
    dbName := prefixFileRefName(dateSl) + 'vmp_usl'

    tmp_select := select()
    dbUseArea(.t., 'DBFNTX', dir_exe + dbName, dbAlias , .t., .f.)
  
    //  1 - SHIFR(C)  2 - HVID(C)  3 - HMETHOD(N) 4 - MODEL(N) 5 - DIAGNOZIS(C)
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      aadd(arrVMP_USL, { alltrim((dbAlias)->SHIFR), alltrim((dbAlias)->HVID), (dbAlias)->HMETHOD, (dbAlias)->MODEL, alltrim((dbAlias)->DIAGNOZIS) })
      (dbAlias)->(dbSkip())
    enddo
  
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif
  return arrVMP_USL

***** 11.02.2021
// �����頥� ��� ��㣨 ᮮ⢥�����騩 ���� � ��⮤� ��� � ��������
function getServiceForVMP(hVid, hMethod, model) // sDiag)
  // hVid - ��� ��� (��ப�)
  // hMethod - ��⮤ ��� (楫��)
  // model - ������ ��樥�� V022 (楫��)
  // sDiag - �᭮���� �������
  local ret := '', vid := alltrim(hVid) //, diag := alltrim(sDiag)
  local arrVMP_USL := getVMP_USL()
  local i := 0, row, arr := {}

  for each row in arrVMP_USL
    // arr := hb_ATokens(row[4], ';')  // ࠧ��୥� ���ᨢ ࠧ�襭��� ��������� ��� ���
    if row[2] == vid .and. row[3] == hMethod .and. row[4] == model //(ascan(arr, diag) > 0)
alertx(model,'model')
      ret := row[1]
      // exit
    endif
  next
  return ret

***** 11.02.2021
// �����頥� ���ᨢ ᮮ⢥��⢨� ����� � ��⮤�� ��� ��㣠� ����
function getVMP_USL( dateSl)
  static arrVMP_USL := {}

  Local dbName, dbAlias := 'VMP_USL'
  local tmp_select := select()
  
  if len(arrVMP_USL) == 0
    dbName := '_mo1vmp_usl'
    tmp_select := select()
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )
  
    //  1 - SHIFR(C)  2 - HVID(C)  3 - HMETHOD(N) 4 - MODEL(N) //  4 - DIAGNOZIS(C)
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      aadd(arrVMP_USL, { alltrim((dbAlias)->SHIFR), alltrim((dbAlias)->HVID), (dbAlias)->HMETHOD, (dbAlias)->MODEL })
      (dbAlias)->(dbSkip())
    enddo
  
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif
  return arrVMP_USL

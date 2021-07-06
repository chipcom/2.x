#include 'function.ch'

// 06.07.2021
// �����頥� ���ᨢ ���� �� 㪠������ ����
function getKSLPtable( dateSl )
  Local dbName, dbAlias := 'KSLP_'
  local tmp_select := select()
  local retKSLP := {}
  local aKSLP, row
  local yearSl := year(dateSl)

  static hKSLP, lHashKSLP := .f.

  // �� ������⢨� ���-���ᨢ� ᮧ����� ���
  if !lHashKSLP
    hKSLP := hb_Hash()
    lHashKSLP := .t.
  endif

  // ����稬 ���ᨢ ���� �� ��� �� ����� ��� ��������� ������, ��� ����㧨� ��� �� �ࠢ�筨��
  if hb_HHasKey( hKSLP, yearSl )
    aKSLP := hb_HGet(hKSLP, yearSl)
  else
    aKSLP := {}
    tmp_select := select()
    dbName := '_mo' + str((yearSl - 2020),1) + 'kslp'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      aadd(aKSLP, { (dbAlias)->CODE, alltrim((dbAlias)->NAME), alltrim((dbAlias)->NAME_F), (dbAlias)->COEFF, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())

    Select(tmp_select)
    // �����⨬ � ���-���ᨢ
    hKSLP[yearSl] := aKSLP
  endif

  // �롥६ �������� ���� �� ���
  for each row in aKSLP
    if between(dateSl, row[5], row[6])
      aadd(retKSLP, { row[1], row[2], row[3], row[4], row[5], row[6] })
    endif
  next

  if empty(retKSLP)
    alertx('�� ���� ' + DToC(dateSl) + ' ���� ����������!')
  endif
  return retKSLP
  
// 27.02.2021
// �����頥� ���ᨢ ���� �� 㪠������ ����
function getKSLPtable__( dateSl )
  Local dbName, dbAlias := 'KSLP_'
  local tmp_select := select()
  local tmpKSLP := {}
  
  // static aKSLP, loadKSLP := .f.
  
  // if loadKSLP //�᫨ ���ᨢ ���� ������� ��୥� ���
  //   if (iy := ascan(aKSLP, {|x| x[1] == Year(dateSl) })) > 0 // ���
  //     return aKSLP[ iy, 2 ]
  //   endif
  // endif
  
  if year(dateSl) == 2021 // ���� �� 2021 ���
    tmp_select := select()
    // aKSLP := {}
    dbName := '_mo1kslp'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )
  
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      if between(dateSl, (dbAlias)->DATEBEG, (dbAlias)->DATEEND)
      // if (dateSl >= (dbAlias)->DATEBEG) .and. (dateSl <= (dbAlias)->DATEEND)
        aadd(tmpKSLP, { (dbAlias)->CODE, alltrim((dbAlias)->NAME), alltrim((dbAlias)->NAME_F), (dbAlias)->COEFF, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      endif
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
    // aadd(aKSLP, { Year(dateSl), tmpKSLP })
    // loadKSLP := .t.
  else
    alertx('�� ���� ' + DToC(dateSl) + ' ���� ����������!')
  endif
  return tmpKSLP
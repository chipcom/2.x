#include 'function.ch'
#include 'chip_mo.ch'

// 30.11.21
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
    dbName := prefixFileRefName(dateSl) + 'kslp'

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

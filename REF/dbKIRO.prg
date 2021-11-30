#include 'function.ch'
#include 'chip_mo.ch'

***** 30.11.21
// �����頥� ���ᨢ ���� �� 㪠������ ����
function getKIROtable( dateSl )
  Local dbName, dbAlias := 'KIRO_'
  local tmp_select := select()
  local retKIRO := {}
  local aKIRO, row
  local yearSl := year(dateSl)

  static hKIRO, lHashKIRO := .f.

  // �� ������⢨� ���-���ᨢ� ᮧ����� ���
  if !lHashKIRO
    hKIRO := hb_Hash()
    lHashKIRO := .t.
  endif

  // ����稬 ���ᨢ ���� �� ��� �� ����� ��� ��������� ������, ��� ����㧨� ��� �� �ࠢ�筨��
  if hb_HHasKey( hKIRO, yearSl )
    aKIRO := hb_HGet(hKIRO, yearSl)
  else
    aKIRO := {}
    tmp_select := select()
    dbName := prefixFileRefName(dateSl) + 'kiro'

    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      aadd(aKIRO, { (dbAlias)->CODE, alltrim((dbAlias)->NAME), alltrim((dbAlias)->NAME_F), (dbAlias)->COEFF, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())

    Select(tmp_select)
    // �����⨬ � ���-���ᨢ
    hKIRO[yearSl] := aKIRO
  endif

  // �롥६ �������� ���� �� ���
  for each row in aKIRO
    if between(dateSl, row[5], row[6])
      aadd(retKIRO, { row[1], row[2], row[3], row[4], row[5], row[6] })
    endif
  next

  if empty(retKIRO)
    alertx('�� ���� ' + DToC(dateSl) + ' ���� ����������!')
  endif

  return retKIRO
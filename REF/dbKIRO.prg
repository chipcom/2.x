#include 'function.ch'

***** 27.02.2021
// �����頥� ���ᨢ ���� �� 㪠������ ����
function getKIROtable( dateSl )
  Local dbName, dbAlias := 'KIRO_'
  local tmp_select := select()
  local tmpKIRO := {}

  // static aKIRO, loadKIRO := .f.

  // if loadKIRO //�᫨ ���ᨢ ���� ������� ��୥� ���
  //   if (iy := ascan(aKIRO, {|x| x[1] == Year(dateSl) })) > 0 // ���
  //     return aKIRO[ iy, 2 ]
  //   endif
  // endif

  if year(dateSl) == 2021 // ���� �� 2021 ���
    tmp_select := select()
    // aKIRO := {}
    dbName := '_mo1kiro'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      if between(dateSl, (dbAlias)->DATEBEG, (dbAlias)->DATEEND)
        aadd(tmpKIRO, { (dbAlias)->CODE, alltrim((dbAlias)->NAME), alltrim((dbAlias)->NAME_F), (dbAlias)->COEFF, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      endif
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
    // aadd(aKIRO, { Year(dateSl), tmpKIRO })
    // loadKIRO := .t.
  else
    alertx('�� ���� ' + DToC(dateSl) + ' ���� ����������!')
  endif
  return tmpKIRO
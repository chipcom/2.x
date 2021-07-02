#include 'function.ch'

// 27.02.2021
// �����頥� ���ᨢ ���� �� 㪠������ ����
function getKSLPtable( dateSl )
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
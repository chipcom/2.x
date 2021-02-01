
#include "set.ch"
#include "getexit.ch"
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "..\chip_mo.ch"

// �����頥� ���ᨢ ���� �� 㪠������ ����
function getKIROtable( dateSl )
  Local dbName, dbAlias := 'KIRO_'
  local tmp_select := select()
  local tmpKIRO := {}

  static aKIRO, loadKIRO := .f.

  if loadKIRO //�᫨ ���ᨢ ���� ������� ��୥� ���
    if (iy := ascan(aKIRO, {|x| x[1] == Year(dateSl) })) > 0 // ���
      return aKIRO[ iy, 2 ]
    endif
  endif

  if year(dateSl) == 2021 // ���� �� 2021 ���
    tmp_select := select()
    aKIRO := {}
    // tmpKIRO := {}
    dbName := '_mo1kiro'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      aadd(tmpKIRO, { (dbAlias)->CODE, (dbAlias)->NAME, (dbAlias)->NAME_F, (dbAlias)->COEFF, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
    aadd(aKIRO, { Year(dateSl), tmpKIRO })
    loadKIRO := .t.
  else
    alertx('�� 㪠������ ���� ' + DToC(dateSl) + ' ���� ����������!')
  endif
  return tmpKIRO


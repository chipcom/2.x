#include 'function.ch'
#include 'chip_mo.ch'

***** 13.02.21
// �����頥� ���ᨢ V018 �� 㪠������ ����
function getV018table( dateSl )
  Local dbName, dbAlias := 'V018'
  local tmp_select := select()
  local yearSl := year(dateSl)
  local _arr

  static hV018, lHashV018 := .f.

  // �� ������⢨� ���-���ᨢ� ᮧ����� ���
  if !lHashV018
    hV018 := hb_Hash()
    lHashV018 := .t.
  endif

  // ����稬 ���ᨢ V018 �� ��� �� ����� ��� ��������� ������, ��� ����㧨� ��� �� �ࠢ�筨��
  if hb_HHasKey( hV018, yearSl )
    _arr := hb_HGet(hV018, yearSl)
  else
    _arr := {}
    tmp_select := select()
    dbName := '_mo_V018'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    //  1 - IDHVID(C)  2 - HVIDNAME(C)  3 - DATEBEG(D)  4 - DATEEND(D)
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      if empty((dbAlias)->DATEEND) .or. between(dateSl, (dbAlias)->DATEBEG, (dbAlias)->DATEEND)
        aadd(_arr, { alltrim((dbAlias)->IDHVID), alltrim((dbAlias)->HVIDNAME), ;
                (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      endif
      (dbAlias)->(dbSkip())
    enddo
    asort(_arr,,,{|x,y| x[1] < y[1] })

    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
    // �����⨬ � ���-���ᨢ
    hV018[yearSl] := _arr
  endif
  if empty(_arr)
    alertx('�� ���� ' + DToC(dateSl) + ' V018 ����������!')
  endif
  return _arr

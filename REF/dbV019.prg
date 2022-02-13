#include 'function.ch'
#include 'chip_mo.ch'

***** 13.02.21
// �����頥� ���ᨢ V019
function getV019table( dateSl )
  Local dbName, dbAlias := 'V019'
  local tmp_select := select()
  local yearSl := year(dateSl)
  local _arr

  static hV019, lHashV019 := .f.

  // �� ������⢨� ���-���ᨢ� ᮧ����� ���
  if !lHashV019
    hV019 := hb_Hash()
    lHashV019 := .t.
  endif

  // ����稬 ���ᨢ V019 �� ��� �� ����� ��� ��������� ������, ��� ����㧨� ��� �� �ࠢ�筨��
  if hb_HHasKey( hV019, yearSl )
    _arr := hb_HGet(hV019, yearSl)
  else
    _arr := {}
    tmp_select := select()
    dbName := '_mo_V019'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    //  1 - IDHM(N)  2 - HMNAME(C)  3 - DIAG(M)  4 - HVID(C)  5 - DATEBEG(D)  6 - DATEEND(D)  7 - HGR(N)  8 - IDMODP(N)
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      if empty((dbAlias)->DATEEND) .or. between(dateSl, (dbAlias)->DATEBEG, (dbAlias)->DATEEND)
        aadd(_arr, { (dbAlias)->IDHM, alltrim((dbAlias)->HMNAME), aclone(Split(alltrim((dbAlias)->DIAG), ', ')), ;
            alltrim((dbAlias)->HVID), (dbAlias)->DATEBEG, (dbAlias)->DATEEND, (dbAlias)->HGR, (dbAlias)->IDMODP })
      endif
      (dbAlias)->(dbSkip())
    enddo
    asort(_arr,,,{|x,y| x[1] < y[1] })
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
    // �����⨬ � ���-���ᨢ
    hV019[yearSl] := _arr
  endif
  if empty(_arr)
    alertx('�� ���� ' + DToC(dateSl) + ' V019 ����������!')
  endif
  return _arr

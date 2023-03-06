#include 'function.ch'
#include 'chip_mo.ch'

** 25.01.23
// �����頥� ���ᨢ V019
function getV019( dateSl )
  local yearSl := year(dateSl)
  local _arr
  local db
  local aTable, stmt
  local nI

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
    db := openSQL_DB()
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')

    aTable := sqlite3_get_table(db, 'SELECT ' + ;
      'idhm, ' + ;
      'hmname, ' + ;
      'diag, ' + ;
      'hvid, ' + ;
      'hgr, ' + ;
      'hmodp, ' + ;
      'idmodp, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v019')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
      if (year(ctod(aTable[nI, 8])) <= yearSl) .and. (empty(ctod(aTable[nI, 9])) .or. year(ctod(aTable[nI, 9])) >= yearSl)   // ⮫쪮 �᫨ ���� ����砭�� ����⢨� ����
          aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), ;
            aclone(Split(alltrim(aTable[nI, 3]), ', ')), ;
            alltrim(aTable[nI, 4]), ctod(aTable[nI, 8]), ctod(aTable[nI, 9]), ;
            val(aTable[nI, 5]), val(aTable[nI, 7]) ;
          })
        endif
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
    asort(_arr,,,{|x,y| x[1] < y[1] })
    hV019[yearSl] := _arr
  endif
  // if empty(_arr)
    // alertx('�� ���� ' + DToC(dateSl) + ' V019 ����������!')
  // endif
  return _arr

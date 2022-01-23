******* 23.01.22 ������ ���ᨢ �� �ࠢ�筨�� �����ࠢ� OID 1.2.643.5.1.13.13.11.1358_*.*.xml (������� ����७��)
function get_ed_izm()
  // OID 1.2.643.5.1.13.13.11.1358_*.*.xml - ������� ����७��
  //  2 - ID(N)       // �������� �����䨪��� ������� ����७�� ������୮�� ���, 楫�� �᫮
  //  3 - FULLNAME(C) // ������ ������������, �����
  //  4 - SHOTNAME(C) // ��⪮� ������������, �����;
  //  5 - PRNNAME(C)  // ������������ ��� ����, �����;
  //  6 - MEASUR(C)   // �����୮���, �����;
  //  7 - UCUM(C)     // ��� UCUM, �����;
  //  8 - COEF(C)     // �����樥�� ������, �����, �����樥�� ������ � ࠬ��� ����� ࠧ��୮��.;
  //  9 - CONV_ID(N)  // ��� ������� ����७�� ��� ������, �����᫥���, ��� ������� ����७��, � ������ �����⢫���� ������.;
  // 10 - CONV_NAM(C) // ������ ����७�� ��� ������, �����, ��⪮� ������������ ������� ����७��, � ������ �����⢫���� ������.;
  // 11 - OKEI_COD(N) // ��� ����, �����, ���⢥�����騩 ��� �����ᨩ᪮�� �����䨪��� ������ ����७��.;

  local dbName := '_mo_ed_izm'
  Local dbAlias := '_ED_IZM'
  local tmp_select := select()
  static _arr := {}

  if len(_arr) == 0
    dbUseArea( .t.,, exe_dir + dbName, dbAlias, .f., .f. )
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      if mem_n_V034 == 0
         aadd(_arr, { alltrim((dbAlias)->SHOTNAME), (dbAlias)->ID })
      else
        aadd(_arr, { alltrim((dbAlias)->FULLNAME), (dbAlias)->ID })
      endif  
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _arr

***** 23.01.22 ������ ������������ ������� ����७��
Function ret_ed_izm(id)
  // id - ��� ������� ����७��
  Local i, ret := ''
  // local code

  if ValType(id) == 'C'
    id:= val(alltrim(id))
  elseif ValType(id) == 'N'
    // id := id
  else
    return ret
  endif
  
  if !empty(id) .and. ((i := ascan(get_ed_izm(), {|x| x[2] == id })) > 0)
    ret := get_ed_izm()[i, 1]
  endif
  return ret

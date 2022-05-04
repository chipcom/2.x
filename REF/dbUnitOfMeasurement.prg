
#require 'hbsqlit3'

#define TRACE

******* 23.01.22 ������ ���ᨢ �� �ࠢ�筨�� �����ࠢ� OID 1.2.643.5.1.13.13.11.1358_*.*.xml (������� ����७��)
function get_ed_izm()
  // OID 1.2.643.5.1.13.13.11.1358_*.*.xml - ������� ����७��
  //  1 - ID(N)       // �������� �����䨪��� ������� ����७�� ������୮�� ���, 楫�� �᫮
  //  2 - FULLNAME(C) // ������ ������������, �����
  //  3 - SHOTNAME(C) // ��⪮� ������������, �����;
  //  4 - PRNNAME(C)  // ������������ ��� ����, �����;
  //  5 - MEASUR(C)   // �����୮���, �����;
  //  6 - UCUM(C)     // ��� UCUM, �����;
  //  7 - COEF(C)     // �����樥�� ������, �����, �����樥�� ������ � ࠬ��� ����� ࠧ��୮��.;
  //  8 - CONV_ID(N)  // ��� ������� ����७�� ��� ������, �����᫥���, ��� ������� ����७��, � ������ �����⢫���� ������.;
  //  9 - CONV_NAM(C) // ������ ����७�� ��� ������, �����, ��⪮� ������������ ������� ����७��, � ������ �����⢫���� ������.;
  // 10 - OKEI_COD(N) // ��� ����, �����, ���⢥�����騩 ��� �����ᨩ᪮�� �����䨪��� ������ ����७��.;

  local dbName := '_mo_ed_izm'
  Local dbAlias := '_ED_IZM'
  local tmp_select := select()
  static _arr := {}

  if len(_arr) == 0
    dbUseArea( .t.,, exe_dir + dbName, dbAlias, .f., .f. )
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      if mem_n_V034 == 0
         aadd(_arr, { alltrim((dbAlias)->SHOTNAME), (dbAlias)->ID, CToD(''), CToD('') })
      else
        aadd(_arr, { alltrim((dbAlias)->FULLNAME), (dbAlias)->ID, CToD(''), CToD('') })
      endif  
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif
  return _arr

  function get_ed_izm_sql()
    // OID 1.2.643.5.1.13.13.11.1358_*.*.xml - ������� ����७��
    //  1 - ID(N)       // �������� �����䨪��� ������� ����७�� ������୮�� ���, 楫�� �᫮
    //  2 - FULLNAME(C) // ������ ������������, �����
    //  3 - SHORTNAME(C) // ��⪮� ������������, �����;
  
    local oConn, oStmt, oRs
    static _arr := {}

    if len(_arr) == 0
      oConn := hdbcSQLTConnection():New( exe_dir + 'mzdrav.db', .T. )
      oStmt := oConn:createStatement()
  
      oRs := oStmt:executeQuery( "SELECT id, fullname, shortname FROM UnitOfMeasurement" )
      do while oRs:next()
        if mem_n_V034 == 0
          aadd(_arr, { alltrim(oRs:getString( 'shortname' )), oRs:getNumber( 'id' ) })
        else
          aadd(_arr, { alltrim(oRs:getString( 'fullname' )), oRs:getNumber( 'id' ) })
        endif  
      enddo
      oRs:Close()
      oStmt:Close()
      oConn:Close()
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

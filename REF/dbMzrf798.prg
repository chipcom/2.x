#require 'hbsqlit3'

// 08.01.25 ������ ���ᨢ �� �ࠢ�筨�� �����ࠢ� �� OID 1.2.643.5.1.13.13.99.2.798.xml
function getMzrf798()
  // OID 1.2.643.5.1.13.13.99.2.798.xml - �ࠢ�筨� �ࠪ���⨪ ��᢮�������� ��⨢��� ����� �� ������⢥���� �९��⮢
  //  1 - ID(N) 2 - NAME(C) 3 - NAMEENG(C) 4 - COMMENT(C)
  static _arr := {}
  local dBegin := 0d20220101, dEnd := 0d20241231  // ��� ᮢ���⨬���
  local cmdText
  local db
  local aTable
  local nI

  if len(_arr) == 0
    db := openSQL_DB()
    cmdText := 'SELECT id, name, nameEng, comment FROM mzrf798'
    aTable := sqlite3_get_table(db, cmdText)
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, { val( aTable[ nI, 1 ] ), alltrim( aTable[ nI, 2 ] ), ;
            alltrim( aTable[ nI, 3 ] ), alltrim( aTable[ nI, 4 ] ) } )
      next
    endif
    db := nil
  endif
  return _arr

// 08.01.25 ������ ������������ ��⮤� �������� �९���
Function ret_character_vysv( s_code )
  // s_code - ��� �ࠪ���⨪�

  Local i, ret := ''
  local code
  
  if ValType(s_code) == 'C'
    code := val( s_code )
  elseif ValType( s_code ) == 'N'
    code := s_code
  else
    return ret
  endif

  if !empty( code ) .and. ( ( i := ascan( getMzrf798(), { | x | x[ 1 ] == code } ) ) > 0 )
    ret := getMzrf798()[ i, 2 ]
  endif
  return ret
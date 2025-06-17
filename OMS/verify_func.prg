#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 17.05.25
function diabetes_school_xniz( shifr, nAge, dni, kol_93_1, kol_93_2, rslt, ishod, ta )

  local s

  If ! eq_any( rslt, 314 )
    AAdd( ta, '� ���� "������� ���饭��" ������ ���� "314 �������᪮� �������"' )
  Endif
  If ! eq_any( ishod, 304 )
    AAdd( ta, '� ���� "��室 �����������" ������ ���� "304 ��� ��६��"' )
  Endif

  if eq_any( shifr, '2.92.1', '2.92.2', '2.92.3' )
    s := '��㣠 2.93.1 ����뢠���� �� ����� '
    If nAge < 18 .and. kol_93_1 < 10
      AAdd( ta, s + ' 10 ࠧ' )
    Elseif nAge >= 18 .and. kol_93_1 < 5
      AAdd( ta, s + ' 5 ࠧ' )
    Endif
    If nAge < 18 .and. dni < 10
      AAdd( ta, s + ' 10 ����' )
    Elseif nAge >= 18 .and. dni < 5
      AAdd( ta, s + ' 5 ����' )
    Endif
  else
    s := '��㣠 2.93.2 ����뢠���� �� ����� '
    if eq_any( shifr, '2.92.4', '2.92.5', '2.92.6', '2.92.7', '2.92.10', '2.92.11' )
      // ��� '2.92.11' � �ਪ��� �� ����⭮
      If nAge < 18 .and. dni < 10
        AAdd( ta, s + ' 10 ����' )
      Elseif nAge >= 18 .and. dni < 5
        AAdd( ta, s + ' 5 ����' )
      Endif
      If nAge < 18 .and. kol_93_2 < 10
        AAdd( ta, s + ' 10 ࠧ' )
      Elseif nAge >= 18 .and. kol_93_2 < 5
        AAdd( ta, s + ' 5 ࠧ' )
      Endif
    elseif  shifr == '2.92.8' .or. shifr == '2.92.9'
      If nAge < 18 .and. dni < 10
//        AAdd( ta, s + ' 10 ����' )
      Elseif nAge >= 18 .and. dni < 5
        AAdd( ta, s + ' 5 ����' )
      Endif
      If nAge < 18 .and. kol_93_2 < 10
//        AAdd( ta, s + ' 10 ࠧ' )
      Elseif nAge >= 18 .and. kol_93_2 < 5
        AAdd( ta, s + ' 5 ࠧ' )
      Endif
    elseif  shifr == '2.92.12'
      // �� ����⭮ �� �ਪ���
      If nAge < 18 .and. dni < 10
        AAdd( ta, s + ' 10 ����' )
//      Elseif nAge >= 18 .and. dni < 5
//        AAdd( ta, s + ' 5 ����' )
      Endif
      If nAge < 18 .and. kol_93_2 < 10
        AAdd( ta, s + ' 10 ࠧ' )
//      Elseif nAge >= 18 .and. kol_93_2 < 5
//        AAdd( ta, s + ' 5 ࠧ' )
      Endif
    endif
  endif
  return nil

// 03.05.23
Function kol_dney_lecheniya( dBegin, dEnd, usl_ok )

  Return dEnd - dBegin + iif( usl_ok == USL_OK_HOSPITAL, 0, 1 )

// 25.02.21
// �஢�ઠ ᮮ⢥��⢨� १���� ���� ��室� ���饭��
Function checkrslt_ishod( result, ishod, arr )

  // result - ��� १���� ���饭��
  // ishod - ��� ��室� �����������
  // arr - ���ᨢ ��� ᡮ� �訡�� ᮮ⢥��⢨�
  Local str1 := '��� 㪠������� १���� ���饭��'
  Local str2 := '��室 ����������� �� ����� ����'
  Local str3 := '��室 ����������� ������ ����'
  Local str4 := '��� 㪠������� ��室� �����������'
  Local str5 := '१���� ���饭�� ������ ����'
  Local str := ''
  Local strResult := ''
  Local i, j

  strResult := getrslt_v009( result )
  If strResult == NIL
    AAdd( arr, '�������⭮� ���祭�� १���� ���饭�� ��� ���� ' + Str( result ) )
    Return
  Endif

  If eq_any( result, 102, 103, 104, 105, 106, 107, 108, 110 ) .and. ishod == 101
    str += str1 + ' (' + strResult + ') ' + str2 + ' (' + getishod_v012( 101 ) + ')'
    AAdd( arr, str )
  Endif
  If eq_any( result, 105, 106 ) .and. ishod != 104
    str += str1 + ' (' + strResult + ') ' + str3 + ' (' + getishod_v012( 104 ) + ')'
    AAdd( arr, str )
  Endif

  If eq_any( result, 202, 203, 204, 205, 206, 207, 208 ) .and. ishod == 201
    str += str1 + ' (' + strResult + ') ' + str2 + ' (' + getishod_v012( 201 ) + ')'
    AAdd( arr, str )
  Endif
  If eq_any( result, 205, 206 ) .and. ishod != 204
    str += str1 + ' (' + strResult + ') ' + str3 + ' (' + getishod_v012( 204 ) + ')'
    AAdd( arr, str )
  Endif

  If ( result == 313 ) .and. ( ishod != 305 )
    str += str1 + ' (' + strResult + ') ' + str3 + ' (' + getishod_v012( 305 ) + ')'
    AAdd( arr, str )
  Endif

  If eq_any( result, 407, 408, 409, 410, 411, 412, 413, 414 ) .and. ishod != 402
    str += str1 + ' (' + strResult + ') ' + str3 + ' (' + getishod_v012( 402 ) + ')'
    AAdd( arr, str )
  Endif
  If eq_any( result, 405, 406 ) .and. ishod != 403
    str += str1 + ' (' + strResult + ') ' + str3 + ' (' + getishod_v012( 403 ) + ')'
    AAdd( arr, str )
  Endif

  Return

// 25.03.23
Function dublicate_diagnoze( arrDiagnoze )

  Local aRet := {}
  Local i, cDiagnose
  Local aHash := hb_Hash()

  For i := 1 To Len( arrDiagnoze )
    cDiagnose := AllTrim( arrDiagnoze[ i ] )
    If Empty( cDiagnose )
      Loop
    Endif
    If ! hb_HHasKey( aHash, cDiagnose )
      hb_HSet( aHash, cDiagnose, .t. )
    Else
      AAdd( aRet, { cDiagnose, iif( i < 9, '� ��㯯� "���������騥 ��������": ', '� ��㯯� "�������� �᫮������": ' ) } )
    Endif
  Next

  Return aRet

// 17.09.21 �஢�ઠ ᥪ樨 ���ࠢ����� ��樥��
Function checksectionprescription( arr )

  Local i := 0
  Local lAdd := .f.
  Local flDopObsledovanie := .f.

  r_use( dir_server() + 'mo_pers', dir_server() + 'mo_pers', 'TPERS' )

  If ( m1dopo_na > 0 )
    If ( mtab_v_dopo_na == 0 )
      lAdd := errorfillprescription( lAdd, arr, '�� �������� ⠡���� ����� ��� ���ࠢ��襣� �� �������⥫쭮� ��᫥�������' )
    Else
      lAdd := controlsnils_napr( lAdd, arr, 'TPERS', mtab_v_dopo_na, 1 )
      For i := 1 To 4
        If IsBit( m1dopo_na, i )
          flDopObsledovanie := .t.
          Exit
        Endif
      Next
      If !flDopObsledovanie // �� ��࠭� �������⥫�� ��᫥�������
        lAdd := errorfillprescription( lAdd, arr, '� ���ࠢ����� �� ��࠭� �� ������ �������⥫쭮�� ��᫥�������' )
      Endif
    Endif
  Endif

  If ( m1napr_v_mo > 0 )
    If ( mtab_v_mo == 0 )
      lAdd := errorfillprescription( lAdd, arr, '�� �������� ⠡���� ����� ��� ���ࠢ��襣� � ᯥ樠���⠬' )
    Else
      lAdd := controlsnils_napr( lAdd, arr, 'TPERS', mtab_v_mo, 2 )
      If Empty( arr_mo_spec )
        lAdd := errorfillprescription( lAdd, arr, '� ���ࠢ����� � ᯥ樠���⠬ �� ��࠭� ᯥ樠�쭮��' )
      Endif
    Endif
  Endif

  If ( m1napr_stac > 0 )
    If ( mtab_v_stac == 0 )
      lAdd := errorfillprescription( lAdd, arr, '�� �������� ⠡���� ����� ��� ���ࠢ��襣� �� ��祭��' )
    Else
      lAdd := controlsnils_napr( lAdd, arr, 'TPERS', mtab_v_stac, 3 )
      If !( m1profil_stac > 0 )
        lAdd := errorfillprescription( lAdd, arr, '� ���ࠢ����� �� ��祭�� �� ��࠭ ��䨫�' )
      Endif
    Endif
  Endif

  If ( m1napr_reab > 0 )
    If ( mtab_v_reab == 0 )
      lAdd := errorfillprescription( lAdd, arr, '�� �������� ⠡���� ����� ��� ���ࠢ��襣� �� ॠ�������' )
    Else
      lAdd := controlsnils_napr( lAdd, arr, 'TPERS', mtab_v_reab, 4 )
      If !( m1profil_kojki > 0 )
        lAdd := errorfillprescription( lAdd, arr, '� ���ࠢ����� �� ॠ������� �� ��࠭ ��䨫�' )
      Endif
    Endif
  Endif

  If ( human->VZROS_REB == 0 ) .and. ( m1sank_na > 0 )
    If ( mtab_v_sanat == 0 )
      lAdd := errorfillprescription( lAdd, arr, '�� �������� ⠡���� ����� ��� ���ࠢ��襣� �� ᠭ��୮-����⭮� ��祭��' )
    Else
      lAdd := controlsnils_napr( lAdd, arr, 'TPERS', mtab_v_sanat, 5 )
    Endif
  Endif
  TPERS->( dbCloseArea() )

  Return Nil

// 03.09.21
Function errorfillprescription( lAdd, arr, strError )

  Local strNapr := '��������� �����������:'
  Local fl := lAdd

  Default strError To '������ � ����������'
  If !fl
    AAdd( arr, strNapr )
    fl := .t.
  Endif
  AAdd( arr, strError )

  Return fl

// 17.09.21
Function controlsnils_napr( lAdd, arr, cAlias, nTabNumber, type )

  Local fl := lAdd
  Local strError := ''
  Local endError := ''

  Default Type To 0
  If ( cAlias )->( dbSeek( Str( nTabNumber, 5 ) ) )
    endError := fam_i_o( ( cAlias )->FIO ) + ' [' + lstr( ( cAlias )->tab_nom ) + ']' + ' �� ������ �����'

    If type == 1
      strError := '� ���ࠢ��襣� �� �������⥫쭮� ��᫥������� ��� ' + endError
    Elseif type == 2
      strError := '� ���ࠢ��襣� � ᯥ樠���⠬ ��� ' + endError
    Elseif type == 3
      strError := '� ���ࠢ��襣� �� ��祭�� ��� ' + endError
    Elseif type == 4
      strError := '� ���ࠢ��襣� �� ॠ������� ��� ' + endError
    Elseif type == 5
      strError := '� ���ࠢ��襣� �� ᠭ��୮-���⭮� ��祭�� ��� ' + endError
    Endif

    If Empty( ( cAlias )->SNILS )
      fl := errorfillprescription( fl, arr, strError )
    Endif
  Else
    fl := errorfillprescription( fl, arr, '�� ������ ��� � ⠡���� ����஬: ' + lstr( nTabNumber ) )
  Endif

  Return fl

// 17.09.21
// �������� ��� ��� (����� ����� � ��) � ���ᨢ � �஢�મ�, �� �� ���������
Function addkoddoctortoarray( arr, nCode )

  If AScan( arr, nCode ) == 0
    AAdd( arr, nCode )
  Endif

  Return arr

//
Function valid_number_talon( g, dEnd, lMessage )

  Local strCheck, ret := .f.

  If dEnd < 0d20220101
    Return .t.
  Endif

  If ValType( g ) == 'O'
    strCheck := AllTrim( g:buffer )
  Elseif ValType( g ) == 'C'
    strCheck := AllTrim( g )
  Else
    Return ret
  Endif
  // � ᮮ⢥��⢨� � �ਪ���� �����ࠢ� ���ᨨ �� 30.01.2015 � 29�
  If !( ret := hb_regexLike( '([0-9]{2,}[.][0-9]{4,}[.][0-9]{5,}[.][0-9]{3,})', strCheck, .f. ) )
    If lMessage
      func_error( 4, '������ ����� ⠫��� (蠡��� 99.9999.99999.999)' )
      // g:buffer := g:original
    Endif
  Endif

  Return ret

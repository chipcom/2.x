#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 27.01.25
function mm_SVO()

  return { { '��⥣��� ���������', 0 }, ;
    { '���⭨� ��� 㢮����� � ����� (���⠢��)', 35 }, ;
    { '童� ᥬ� ���⭨�� ���', 65 } }

// 12.01.25
function control_number_phone( get )

  local phoneTemplate := '^((8|\+7)[\- ]?)?(\(?\d{3}\)?[\- ]?)?[\d\- ]{7,10}$'  
//  local phoneTemplate := "^(\s*)?(\+)?([- _():=+]?\d[- _():=+]?){10,14}(\s*)?$"
  local lRet := .f.

  lRet := hb_RegexLike( phoneTemplate, get:Buffer )
  if ! lRet
    func_error( 4, '�� �����⨬� ����� ⥫�䮭�!' )
  endif

  return lRet

// 08.08.24
function razbor_str_fio( mfio )

  local k := 0, i, s := '', s1 := '', aFIO := { '', '', '' }

  mfio := alltrim( mfio )
  For i := 1 To NumToken( mfio, ' ' )
    s1 := AllTrim( Token( mfio, ' ', i ) )
    If ! Empty( s1 )
      ++k
      If k < 3
        aFIO[ k ] := s1
      Else
        s += s1 + ' '
      Endif
    Endif
  Next
  aFIO[ 3 ] := AllTrim( s )
  return aFIO

// 09.08.24
function short_FIO( mfio )

  local aFIO := razbor_str_fio( mfio )

  return 	aFIO[ 1 ] + ' ' + Left( aFIO[2], 1 ) + '.' + if( Empty( aFIO[3] ), '', Left( aFIO[3], 1 ) + '.' )
    
// �஢���� �⤥�쭮 䠬����, ��� � ����⢮ � GET'��
Function valfamimot( ltip, s, par, /*@*/msg)

  Static arr_pole := { '�������', '���', '����⢮' }
  Static arr_char := { ' ', '-', '.', "'", '"' }
  Local fl := .t., i, c, s1 := '', nword := 0, get, r := Row()

  Default par To 1
  s := AllTrim( s )
  For i := 1 To Len( arr_char )
    s := CharOne( arr_char[ i ], s )
  Next
  If Len( s ) > 0
    s := Upper( Left( s, 1 ) ) + SubStr( s, 2 )
  Endif
  For i := 1 To Len( s )
    c := SubStr( s, i, 1 )
    If isralpha( c )
      //
    Elseif AScan( arr_char, c ) > 0
      ++nword
    Else
      s1 += c
    Endif
  Next
  msg := ''
  If !Empty( s1 )
    msg := '� ���� "' + arr_pole[ ltip ] + '" �����㦥�� �������⨬� ᨬ���� "' + s1 + '"'
  Elseif Empty( s ) .and. ltip < 3
    msg := '���⮥ ���祭�� ���� "' + arr_pole[ ltip ] + '" �������⨬�'
  Endif
  If par == 1  // ��� GET-��⥬�
    Private tmp := ReadVar()
    &tmp := PadR( s, 40 )
    If Empty( msg ) .and. nword > 0
      If ( get := get_pointer( tmp ) ) != NIL
        r := get:Row
      Endif
      fl := .f.
      mybell()
      If f_alert( { PadC( '� ���� "' + arr_pole[ ltip ] + '" ����ᥭ� ' + lstr( nword + 1 ) + ' ᫮��', 60, '.' ) }, ;
          { ' ������ � ।���஢���� ', ' �ࠢ��쭮� ���� ' }, ;
          1, 'W+/N', 'N+/N', r + 1, , 'W+/N,N/BG' ) == 2
        fl := .t.
      Endif
    Endif
  Endif
  If !Empty( msg )
    If par == 1  // ��� GET-��⥬�
      fl := func_error( 4, msg )
    Else  // ��� �஢�ન �����
      fl := .f.
    Endif
  Endif

  Return fl

// 02.09.15 ������ �⤥�쭮 䠬����, ��� � ����⢮ � ���ᨢ�
Function retfamimot( ltip, fl_no, is_open_kfio )

  Static cDelimiter := ' .'
  Local i, k := 0, s := '', s1, mfio, tmp_select, ret_arr := { '', '', '' }

  Default fl_no To .t., is_open_kfio To .f.
  If ltip == 1 // �맢��� �� ����⥪�
    mfio := kart->fio
  Else  // �맢��� �� ���� ����
    mfio := human->fio
    If human->kod_k != kart->kod // �᫨ �� �易�� �� relation
      kart->( dbGoto( human->kod_k ) )
    Endif
  Endif
  If kart->MEST_INOG == 9 // �.�. �⤥�쭮 ����ᥭ� �.�.�.
    tmp_select := Select()
    If is_open_kfio
      Select KFIO
    Else
      r_use( dir_server + 'mo_kfio', , 'KFIO' )
      Index On Str( kod, 7 ) to ( cur_dir + 'tmp_kfio' )
    Endif
    find ( Str( kart->kod, 7 ) )
    If Found()
      ret_arr[ 1 ] := AllTrim( kfio->FAM )
      ret_arr[ 2 ] := AllTrim( kfio->IM )
      ret_arr[ 3 ] := AllTrim( kfio->OT )
    Endif
    If !is_open_kfio
      kfio->( dbCloseArea() )
    Endif
    Select ( tmp_select )
  Endif
  If Empty( ret_arr[ 1 ] ) // �� ��直� ��砩 - ���� �� ��諨 � "mo_kfio"
    mfio := AllTrim( mfio )
    For i := 1 To NumToken( mfio, cDelimiter )
      s1 := AllTrim( Token( mfio, cDelimiter, i ) )
      If !Empty( s1 )
        ++k
        If k < 3
          ret_arr[ k ] := s1
        Else
          s += s1 + ' '
        Endif
      Endif
    Next
    ret_arr[ 3 ] := AllTrim( s )
  Endif
  If fl_no .and. Empty( ret_arr[ 3 ] )
    ret_arr[ 3 ] := '���'
  Endif

  Return ret_arr

// 26.10.14 �஢�ઠ �� �ࠢ��쭮��� ����񭭮�� ���
Function val_fio( afio, aerr )

  Local i, k := 0, msg

  Default aerr TO {}
  For i := 1 To 3
    valfamimot( i, afio[ i ], 2, @msg )
    If !Empty( msg )
      ++k
      AAdd( aerr, msg )
    Endif
  Next

  Return ( k == 0 )

function input_polis_OMS(cur_row, mkod)

  // ��६���� mvidpolis, m1vidpolis, mspolis, mnpolis ������ ࠭�� ��� PRIVATE
  default mkod to 0
  @ cur_row, 1 say '����� ���: ���' get mvidpolis ;
    reader {|x|menu_reader(x, mm_vid_polis, A__MENUVERT, , , .f.)}
  @ row(), col() + 3 say '���' get mspolis when m1vidpolis == 1
  @ row(), col() + 3 say '�����' get mnpolis ;
    picture iif(m1vidpolis == 3 .or. m1vidpolis == 1, '9999999999999999', '999999999');
    valid {|| findKartoteka(2, @mkod) ,func_valid_polis(m1vidpolis, mspolis, mnpolis)}

  return nil

// 10.02.17
Function get_fio_kart( k, r, c )

  Local s := '', ret, buf, tmp_keys

  Private fl_write_kartoteka := .f.

  buf := SaveScreen()
  tmp_keys := my_savekey()
  edit_kartotek( mkod_k, r + 1, , .t., mkod )
  my_restkey( tmp_keys )
  If fl_write_kartoteka
    r_use( dir_server + 'kartote2', , 'KART2' )
    Goto ( mkod_k )
    r_use( dir_server + 'kartote_', , 'KART_' )
    Goto ( mkod_k )
    r_use( dir_server + 'kartotek', , 'KART' )
    Goto ( mkod_k )
    M1FIO := 1
    mfio := kart->fio
    mpol := kart->pol
    mdate_r := kart->date_r
    mfio_kart := _f_fio_kart()
    If Type( 'mn_data' ) == 'D'
      If Type( 'm1novor' ) == 'N' .and. Type( 'mdate_r2' ) == 'D' .and. m1novor > 0
        mvozrast := count_years( mdate_r2, mn_data )
      Else
        mvozrast := count_years( mdate_r, mn_data )
      Endif
    Endif
    If Type( 'm1novor' ) == 'N' .and. m1novor > 0
      M1VZROS_REB := 1 // ॡ����
    Else
      M1VZROS_REB := kart->VZROS_REB
    Endif
    mADRES      := kart->ADRES
    mMR_DOL     := kart->MR_DOL
    m1RAB_NERAB := kart->RAB_NERAB
    m1komu      := kart->komu
    mPOLIS      := kart->POLIS
    m1VIDPOLIS  := kart_->VPOLIS
    mSPOLIS     := kart_->SPOLIS
    mNPOLIS     := kart_->NPOLIS
    msmo        := kart_->SMO
    m1okato     := kart_->KVARTAL_D // ����� ��ꥪ� �� ����ਨ ���客����
    mokato      := inieditspr( A__MENUVERT, glob_array_srf, m1okato )
    mkomu       := inieditspr( A__MENUVERT, mm_komu, m1komu )
    mvidpolis   := inieditspr( A__MENUVERT, mm_vid_polis, m1vidpolis )
    If !Empty( mn_data )
      fv_date_r( mn_data, .f. )
    Endif
    f_valid_komu(, -1 )
    m1company   := Int( Val( msmo ) )
    mcompany    := inieditspr( A__MENUVERT, mm_company, m1company )
    If m1company == 34
      mnameismo := ret_inogsmo_name( 1, , .t. ) // ������ � �������
    Elseif !( Left( msmo, 2 ) == '34' )
      m1ismo := msmo
      msmo := '34'
      m1company := 34
      mismo := init_ismo( m1ismo )
    Endif
    If m1company == 34
      If !Empty( mismo )
        mcompany := mismo
      Elseif !Empty( mnameismo )
        mcompany := mnameismo
      Endif
    Endif
    If !Empty( mcompany )
      old_name_smo := PadR( mcompany, 38 )
    Endif
    If m1komu > 0
      m1company := 0
      mcompany := ''
      If eq_any( m1komu, 1, 3 )
        m1company := m1str_crb := kart->STR_CRB
        mcompany := inieditspr( A__MENUVERT, mm_company, m1company )
      Endif
    Endif
    mcompany := PadR( mcompany, 38 )
    If eq_any( is_uchastok, 1, 3 )
      s := amb_kartan()
    Elseif mem_kodkrt == 2
      s := lstr( mkod_k )
    Endif
    If !Empty( s ) .and. ValType( MUCH_DOC ) == 'C'
      If Empty( MUCH_DOC )
        MUCH_DOC := PadR( s, 10 )
      Elseif is_uchastok == 3 .and. !( MUCH_DOC == PadR( s, 10 ) )
        MUCH_DOC := PadR( s, 10 )
      Endif
    Endif
    Close databases
  Endif
  RestScreen( buf )

  Return ret

// 24.02.16
Function _f_fio_kart()

  Return PadR( AllTrim( mfio ) + ' ' + iif( mpol == '�', '(��.)', '(���.)' ), 50 )

// 30.12.24
function check_input_INN( get )


  return check_INN_person( get:buffer, .t. )

/*
������ �஢�ન ���1.������ �஢�ન 10-�� ���筮�� ���.
���.10. 1) ��室�� �ந�������� ����� 9-� ��� ��� �� ᯥ樠��� �����⥫�
           ᮮ��⢥���. 9 �����⥫�� ( 2 4 10 3 5 9 4 6 8 ).
���.10. 2) �����뢠�� �� 9-�� ����稢���� �ந��������.
���.10. 3) ����稢����� �㬬� ����� �� �᫮ 11 � ��������� 楫�� ����
           ��⭮�� �� �������.
���.10. 4) �������� ����稢襥�� �᫮ �� 11.
���.10. 5) �ࠢ������ �᫠ ����稢訥�� �� 蠣� 2 � 蠣� 4, �� ࠧ���,
           � ���� ����஫쭮� �᫮, ���஥ � ������ ࠢ������ 10-� ���
           � ���. (�᫨ ����஫쭮� �᫮ ����稫��� ࠢ�� 10-�, � �⮬
           ��砥 �ਭ����� ����஫쭮� �᫮ ࠢ�� 0.)
*/
// 11.01.25 - �㭪�� �஢�ન �ࠢ��쭮�� ����� ��� ��� 䨧.��� (12 ������)
Function check_INN_person(cInn, is_msg)
  Local a[12], i, val1, v, val2, d11, d12 := -1

  DEFAULT is_msg TO .f.
  if empty(cInn)
//    if is_msg
//      func_error( 4, '���� ��� ������ ���� ��������� 12-⨧���� �����' )
//    endif
    return .t.    //  .f.
  elseif len(alltrim(cInn)) < 12
    if is_msg
      func_error(4, '��� ��� 䨧��᪮�� ��� ������ ���� 12-⨧����')
    endif
    return .f.
  endif
  for i := 1 to 12
    a[i] := int(val(substr(cInn, i, 1)))
  next
  // 1) ��室�� �ந�������� ����� 10-� ��� ��� �� ᯥ樠��� �����⥫�
  //    ᮮ��⢥��� (10-� ���� �ਭ����� �� 0 ????????).
  //    10 �����⥫�� ( 7 2 4 10 3 5 9 4 6 8 ).
  // 2) �����뢠�� �� 10-�� ����稢���� �ந��������.
  val1 := a[ 1] * 7 + ;
          a[ 2] * 2 + ;
          a[ 3] * 4 + ;
          a[ 4] * 10 + ;
          a[ 5] * 3 + ;
          a[ 6] * 5 + ;
          a[ 7] * 9 + ;
          a[ 8] * 4 + ;
          a[ 9] * 6 + ;
          a[10] * 8
  // 3) ����稢����� �㬬� ����� �� �᫮ 11 � ��������� 楫�� ����
  //    ��⭮�� �� �������.
  // 4) �������� ����稢襥�� �᫮ �� 11.
  v := int(int(val1 / 11) * 11)
  // 5) �ࠢ������ �᫠ ����稢訥�� �� 蠣� 2 � 蠣� 4, �� ࠧ���,
  //    � ���� ��ࢮ� ����஫쭮� �᫮, ���஥ � ������ ࠢ������
  //    11-� ��� � ���.(�᫨ ����஫쭮� �᫮ ����稫��� ࠢ�� 10-�,
  //    � �⮬ ��砥 �ਭ����� ����஫쭮� �᫮ ࠢ�� 0.)
  //    �᫨ ����稢襥�� �᫮ �� �� ࠢ�� 11-�� ��� ���, �����
  //    ��� �� ����, �᫨ �� ᮢ������, ⮣�� �����뢠�� ᫥���饥
  //    ����஫쭮� �᫮, ���஥ ������ ���� ࠢ�� 12-�� ��� ���
  if (d11 := val1 - v) == 10
    d11 := 0
  endif
  if d11 == a[11]
    // 6) ��室�� �ந�������� ����� 11-� ��� ��� �� ᯥ樠��� �����⥫�
    //    ᮮ��⢥��� (10-� ���� �ਭ����� �� 0).
    //    11 �����⥫�� ( 3 7 2 4 10 3 5 9 4 6 8 ).
    // 7) �����뢠�� �� 11-�� ����稢���� �ந��������.
    val2 := a[ 1] * 3 + ;
            a[ 2] * 7 + ;
            a[ 3] * 2 + ;
            a[ 4] * 4 + ;
            a[ 5] * 10 + ;
            a[ 6] * 3 + ;
            a[ 7] * 5 + ;
            a[ 8] * 9 + ;
            a[ 9] * 4 + ;
            a[10] * 6 + ;
            a[11] * 8
    // 8) ����稢����� �㬬� ����� �� �᫮ 11 � ��������� 楫�� ����
    //    ��⭮�� �� �������.
    // 9) �������� ����稢襥�� �᫮ �� 11.
    v := int(int(val2 / 11) * 11)
    //10) �ࠢ������ �᫠ ����稢訥�� �� 蠣� 7 � 蠣� 9, �� ࠧ��� � ����
    //    ����஫쭮� �᫮, ���஥ � ������ ࠢ������ 12-� ��� � ���.
    //    (�᫨ ����஫쭮� �᫮ ����稫��� ࠢ�� 10-�, � �⮬ ��砥
    //    �ਭ����� ����஫쭮� �᫮ ࠢ�� 0.) �᫨ ����⠭��� �᫮
    //    ࠢ�� 12-�� ��� ���, � �� ��ࢮ� �⠯� �� ����஫쭮� �᫮
    //    ᮢ���� � 11-�� ��ன ���, ᫥����⥫쭮 ��� ��⠥��� ����.
    if (d12 := val2 - v) == 10
      d12 := 0
    endif
  endif
  if d11 != a[11] .or. d12 != a[12]
    if is_msg
      func_error(2, '�訡�� � ������ ����஫쭮� �㬬� ���')
    endif
    return .f.
  endif
  return .t.

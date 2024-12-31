#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

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
// 30.12.24 - �㭪�� �஢�ન �ࠢ��쭮�� ����� ��� ��� 䨧.��� (12 ������)
Function check_INN_person(cInn, is_msg)
  Local a[12], i, val1, v, val2, d11, d12 := -1

  DEFAULT is_msg TO .f.
  if empty(cInn)
    if is_msg
      func_error( 4, '���� ��� ������ ���� ��������� 12-⨧���� �����' )
    endif
    return .f.
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

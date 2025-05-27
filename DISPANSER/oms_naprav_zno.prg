#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'tbox.ch'

// 14.07.23 �㭪�� ��� when � valid �� ����� ��� � ���� ����
Function f5editusl_napr( get, when_valid, k )

  Local fl := .t., fl1

  If when_valid == 1    // when
    If k == 2     // ���� ��㣨
      If !Empty( mshifr )
        fl := .f.
      Endif
    Endif
  Else  // valid
    If k == 2 // ���� ��㣨
      If !Empty( mshifr ) .and. !( mshifr == get:original )
        mshifr := transform_shifr( mshifr )
        // ᭠砫� �஢�ਬ �� ��� ����樨 �����
        fl1 := .f.
        Select LUSLF
        find ( PadR( mshifr, 20 ) )
        If Found() .and. AllTrim( mshifr ) == AllTrim( luslf->shifr )
          is_usluga_zf := luslf->zf
          tip_onko_napr := luslf->onko_napr
          tip_onko_ksg := luslf->onko_ksg
          fl1 := .t.
          Select MOSU
          Set Order To 3
          find ( PadR( mshifr, 20 ) ) // ���饬 䥤�ࠫ�� ��� ����樨 �����
          If Found()
            If mosu->tip == 0 // �஢��塞, �� ��� �� �⮬�⮫���� 2016 (㤠�񭭠�)
              mu_kod  := mosu->kod
              mname_u := mosu->name
              mshifr1 := mosu->shifr1
              If !Empty( mosu->profil )
                m1PROFIL := mosu->profil
                mPROFIL := PadR( inieditspr( A__MENUVERT, getv002(), m1PROFIL ), 69 )
              Endif
            Else // ���� �⮬�⮫���� 2016
              fl1 := .f.
            Endif
          Else
            mu_kod  := 0
            mname_u := Left( luslf->name, 52 )
            mshifr1 := mshifr
          Endif
        Endif
        If Type( 'is_oncology' ) == 'N'
          If !fl1
            fl := func_error( 4, '���� ' + AllTrim( mshifr ) + ' ��� � ���� ������ 䥤�ࠫ��� ���.' )
          Endif
          Return fl
        Elseif fl1
        Endif
      Endif
    Endif

    If !fl
      &( ReadVar() ) := get:original
    Else
      update_gets()
      Return fl
    Endif
  Endif
  Return fl

// 22.05.24 ���� ���ࠢ����� �� �����७�� �� ��� - ���ᬮ��� ��ᮢ��襭����⭨�
Function fget_napr_zno( k, r, c )

  Local r1, r2, n := 4, tmp_keys, tmp_list, j
  Local strNeedTabNumber := '����室��� 㪠���� ⠡���� ���ࠢ��襣� ���'
  Local recNumberDoctor := 0
  Local oBox, lAlias

  Private mm_napr_v := { { '���', 0 }, ;
    { '� ��������', 1 }, ;
    { '�� ����᫥�������', 3 } }
  Private mm_met_issl := {{'���', 0 }, ;
    { '������ୠ� �������⨪�', 1 }, ;
    { '�����㬥�⠫쭠� �������⨪�', 2 }, ;
    { '��⮤� ��祢�� �������⨪� (����ண����騥)', 3 }, ;
    { '��ண����騥 ��⮤� ��祢�� �������⨪�', 4 } }


  tmp_keys := my_savekey()
  Save gets To tmp_list
  //
  use_base( 'luslf' )
  lAlias := 'MOSU'
  If !( lAlias )->( Used() )
    use_base( 'mo_su' )
  Endif

  Use ( cur_dir() + 'tmp_onkna' ) New Alias TNAPR
  count_napr := LastRec()
  mNAPR_MO := Space( 6 )
  If cur_napr > 0 .and. cur_napr <= count_napr
    Goto ( cur_napr ) // ����� ⥪�饣� ���ࠢ�����
    mNAPR_DATE := tnapr->NAPR_DATE
    mTab_Number := get_tabnom_vrach_by_kod( tnapr->KOD_VR )
    Select TNAPR
    m1NAPR_MO := tnapr->NAPR_MO
    If Empty( m1NAPR_MO )
      mNAPR_MO := Space( 52 )
    Else
      mNAPR_MO := Left( ret_mo( m1NAPR_MO )[ _MO_SHORT_NAME ], 52 )
    Endif
    m1NAPR_V := tnapr->NAPR_V
    m1MET_ISSL := tnapr->MET_ISSL
    mu_kod := iif( m1napr_v == 3, tnapr->U_KOD, 0 )
    mshifr := iif( m1napr_v == 3, tnapr->shifr_u, Space( 20 ) )
    mshifr1 := iif( m1napr_v == 3, tnapr->shifr1, Space( 20 ) )
    mname_u := iif( m1napr_v == 3, tnapr->name_u, Space( 52 ) )
  Else
    cur_napr := 1
    mNAPR_DATE := CToD( '' )
    mTab_Number := 0
    m1NAPR_MO := Space( 6 )
    mNAPR_MO := Space( 52 )
    m1NAPR_V := 0
    m1MET_ISSL := 0
    mu_kod := 0
    mshifr := Space( 20 )
    mshifr1 := Space( 20 )
    mname_u := Space( 52 )
  Endif
  mNAPR_V := inieditspr( A__MENUVERT, mm_napr_v, m1napr_v )
  mMET_ISSL := PadR( inieditspr( A__MENUVERT, mm_MET_ISSL, m1MET_ISSL ), 35 )
  tip_onko_napr := 0
  If r > 12
    j := r -9
  Else
    j := r
  Endif

  oBox := tbox():new( j, 0, j + 9, MaxCol() -2, .t. )
  oBox:ChangeAttr := .t.
  oBox:CaptionColor := color8
  oBox:Caption := '���� ���ࠢ����� �� �����७�� �� ���'
  // oBox:Color := color1
  oBox:Save := .t.
  oBox:view()

  @ 1, 1 TBOX oBox Say '����������� �' Get cur_napr Pict '99' When .f.
  @ 1, Col() TBOX oBox Say '(��' Get count_napr Pict '99' When .f.
  @ 1, Col() TBOX oBox Say ')'
  @ 1, Col() + 1 TBOX oBox Say '(<F5> - ����������/।���஢���� ���ࠢ����� �...)' Color 'G/B'
  @ 2, 3 TBOX oBox Say '��� ���ࠢ�����' Get mNAPR_DATE ;
    valid {|| iif( Empty( mNAPR_DATE ) .or. Between( mNAPR_DATE, mn_data, mk_data ), .t., ;
    func_error( 4, '��� ���ࠢ����� ������ ���� ����� �ப�� ��祭��' ) ) }
  @ 3, 3 TBOX oBox Say '������� ����� ���ࠢ��襣� ���' Get mTab_Number Pict '99999' ;
    valid {| g| iif( !v_kart_vrach( g ), func_error( 4, strNeedTabNumber ), .t. ) }
  @ 4, 3 TBOX oBox Say '� ����� �� ���ࠢ���' Get mnapr_mo Pict '@S52' ;
    reader {| x| menu_reader( x, { {| k, r, c| f_get_mo( k, r, c ) } },A__FUNCTION, , , .f. ) }
  @ 5, 3 TBOX oBox Say '��� ���ࠢ�����' Get mnapr_v ;
    reader {| x| menu_reader( x, mm_napr_v, A__MENUVERT, , , .f. ) } // ; color colget_menu
  @ 6, 5 TBOX oBox Say '��⮤ ���������᪮�� ��᫥�������' Get mmet_issl Pict '@S35' ;
    reader {| x| menu_reader( x, mm_met_issl, A__MENUVERT, , , .f. ) } ;
    When m1napr_v == 3 // ; color colget_menu
  @ 7, 5 TBOX oBox Say '����樭᪠� ��㣠' Get mshifr Pict '@!' ;
    when {| g| m1napr_v == 3 .and. m1MET_ISSL > 0 } ;
    valid {| g|
      Local fl := f5editusl_napr( g, 2, 2 )
      If Empty( mshifr )
        mu_kod  := 0
        mname_u := Space( 52 )
        mshifr1 := mshifr
      Elseif fl .and. tip_onko_napr > 0 .and. tip_onko_napr != m1MET_ISSL
        func_error( 4, '��� �����㣨 �� ᮮ⢥����� ��⮤� ���������᪮�� ��᫥�������' )
      Endif
      Return fl
    }
  @ 8, 7 TBOX oBox Say '��㣠' Get mname_u  Pict '@S52' When .f. Color color14
  //
  Set Key K_F5 To change_num_napr
  myread()
  Set Key K_F5
  oBox := nil

  recNumberDoctor := get_kod_vrach_by_tabnom( mTab_Number )

  Close databases
  If !( emptyany( mNAPR_DATE, m1NAPR_V ) .and. count_napr == 0 )
    If cur_napr == 0
      cur_napr := 1
    Endif
  Endif

  count_napr := save_onko_napr( @cur_napr, ;
    mNAPR_DATE, ;
    recNumberDoctor, ;
    m1NAPR_MO, ;
    m1NAPR_V, ;
    iif( m1NAPR_V == 3, m1MET_ISSL, 0 ), ;
    iif( m1NAPR_V == 3, mu_kod, 0 ), ;
    iif( m1NAPR_V == 3, mshifr, '' ), ;
    iif( m1NAPR_V == 3, mshifr1, '' ), ;
    iif( m1NAPR_V == 3, mname_u, '' ) )

  Restore gets From tmp_list
  my_restkey( tmp_keys )
  Return { 0, '������⢮ ���ࠢ����� - ' + lstr( count_napr ) }

// 06.07.23
Function get_onko_napr( /*@*/n_napr )

  Local count_napr, lAlias, tmp_alias := Select(), lOpened := .f., cur_napr := 0
  Local ret_arr := {}

  lAlias := 'TNAPR'
  If !( lAlias )->( Used() )
    Use ( cur_dir() + 'tmp_onkna' ) New Alias TNAPR
    lOpened := .t.
  Endif
  count_napr := ( lAlias )->( LastRec() )

  If n_napr <= count_napr
    cur_napr := n_napr
    Goto ( cur_napr ) // ����� ⥪�饣� ���ࠢ�����
    AAdd( ret_arr, ( lAlias )->NAPR_DATE )
    AAdd( ret_arr, get_tabnom_vrach_by_kod( ( lAlias )->KOD_VR ) )
    AAdd( ret_arr, ( lAlias )->NAPR_MO )
    AAdd( ret_arr, ( lAlias )->NAPR_V )
    AAdd( ret_arr, ( lAlias )->MET_ISSL )
    AAdd( ret_arr, ( lAlias )->U_KOD )
    AAdd( ret_arr, ( lAlias )->shifr_u )
    AAdd( ret_arr, ( lAlias )->shifr1 )
    AAdd( ret_arr, ( lAlias )->name_u )
  Else
    cur_napr := count_napr + 1
    AAdd( ret_arr, CToD( '' ) )
    AAdd( ret_arr, 0 )
    AAdd( ret_arr, Space( 6 ) )
    AAdd( ret_arr, 0 )
    AAdd( ret_arr, 0 )
    AAdd( ret_arr, 0 )
    AAdd( ret_arr, Space( 20 ) )
    AAdd( ret_arr, Space( 20 ) )
    AAdd( ret_arr, Space( 65 ) )
  Endif
  n_napr := cur_napr
  If lOpened
    ( lAlias )->( dbCloseArea() )
    Select( tmp_alias )
  Endif
  Return ret_arr

// 06.07.23
Function save_onko_napr( /*@*/cur_napr, date_napr, vr_napr, mo_napr, v_napr, met_napr, u_kod, shifr_u, shifr1, name_u)

  Local count_napr := 0, lAlias, tmp_alias := Select(), lOpened := .f.

  lAlias := 'TNAPR'
  If !( lAlias )->( Used() )
    Use ( cur_dir() + 'tmp_onkna' ) New Alias TNAPR
    lOpened := .t.
  Endif
  count_napr := ( lAlias )->( LastRec() )
  If cur_napr <= count_napr
    Goto ( cur_napr ) // ����� ⥪�饣� ���ࠢ�����
  Else
    ( lAlias )->( dbAppend() )
    // append blank
  Endif
  ( lAlias )->NAPR_DATE := date_napr
  ( lAlias )->KOD_VR := vr_napr
  ( lAlias )->NAPR_MO := mo_napr
  ( lAlias )->NAPR_V := v_napr
  ( lAlias )->MET_ISSL := met_napr
  ( lAlias )->U_KOD := u_kod
  ( lAlias )->shifr_u := shifr_u
  ( lAlias )->shifr1 := shifr1
  ( lAlias )->name_u := name_u
  cur_napr := ( lAlias )->( RecNo() )

  count_napr := ( lAlias )->( LastRec() )
  If lOpened
    ( lAlias )->( dbCloseArea() )
    Select( tmp_alias )
  Endif
  Return count_napr

// 18.07.23
Function save_mo_onkna( mkod )

  Local lAlias, tmp_alias := Select(), lOpened := .f.
  Local cur_napr, arr

  arr := {}
  use_base( 'mo_su' )
  Use ( cur_dir() + 'tmp_onkna' ) New Alias TNAPR
  g_use( dir_server + 'mo_onkna', dir_server + 'mo_onkna',  'NAPR' ) // �������ࠢ�����
  find ( Str( mkod, 7 ) )
  Do While napr->kod == mkod .and. !Eof()
    AAdd( arr, RecNo() )
    Skip
  Enddo
  cur_napr := 0
  Select TNAPR
  Go Top
  Do While !Eof()
    If !emptyany( tnapr->NAPR_DATE, tnapr->NAPR_V )
      If tnapr->U_KOD == 0 // ������塞 � ᢮� �ࠢ�筨� 䥤�ࠫ��� ����
        Select MOSU
        Set Order To 3
        find ( tnapr->shifr1 )
        If Found()  // ����୮�, �������� ⮫쪮 ��
          tnapr->U_KOD := mosu->kod
        Else
          Set Order To 1
          find ( Str( -1, 6 ) )
          If Found()
            g_rlock( forever )
          Else
            addrec( 6 )
          Endif
          tnapr->U_KOD := mosu->kod := RecNo()
          mosu->name   := tnapr->name_u
          mosu->shifr1 := tnapr->shifr1
        Endif
      Endif
      Select NAPR
      If++cur_napr > Len( arr )
        addrec( 7 )
        napr->kod := mkod
      Else
        Goto ( arr[ cur_napr ] )
        g_rlock( forever )
      Endif
      napr->NAPR_DATE := tnapr->NAPR_DATE
      napr->NAPR_MO := tnapr->NAPR_MO
      napr->NAPR_V := tnapr->NAPR_V
      napr->MET_ISSL := iif( tnapr->NAPR_V == 3, tnapr->MET_ISSL, 0 )
      napr->U_KOD := iif( tnapr->NAPR_V == 3, tnapr->U_KOD, 0 )
      napr->KOD_VR := tnapr->KOD_VR
    Endif
    Select TNAPR
    Skip
  Enddo
  Select NAPR
  Do While++cur_napr <= Len( arr )
    Goto ( arr[ cur_napr ] )
    deleterec( .t. )
  Enddo

  tnapr->( dbCloseArea() )
  MOSU->( dbCloseArea() )
  NAPR->( dbCloseArea() )
  Return Nil

// 06.07.23 ।���஢��� ��㣮� ���ࠢ����� (�...)
Function change_num_napr()

  Local r, n, fl := .f., tmp_keys, tmp_gets, buf, tmp_color := SetColor()
  Local recNumberDoctor := 0
  Local arr_napr

  If emptyany( mNAPR_DATE, m1NAPR_V )
    func_error( 4, '��� �� ��������� ���ࠢ����� � ' + lstr( cur_napr ) )
    Return .t.
  Endif
  tmp_keys := my_savekey()
  Save gets To tmp_gets
  buf := SaveScreen()
  change_attr()
  r := 4
  If ( n := input_value( r, 33, r + 2, 77, color5, '����������/।���஢���� ���ࠢ����� �', cur_napr, '99' ) ) == NIL
    // �⪠�
  Elseif eq_any( n, 0, cur_napr )
    // ��ࠫ� � �� ���ࠢ�����, �� � ।��������
  Else
    If cur_napr == 0
      cur_napr := 1
    Endif
    recNumberDoctor := get_kod_vrach_by_tabnom( mTab_Number ) // 0

    If Select( 'TNAPR' ) == 0
      Use ( cur_dir() + 'tmp_onkna' ) New Alias TNAPR
    Else
      Select TNAPR
    Endif
    count_napr := LastRec()
    If cur_napr <= count_napr
      Goto ( cur_napr ) // ����� ⥪�饣� ���ࠢ�����
    Else
      Append Blank
    Endif
    tnapr->NAPR_DATE := mNAPR_DATE
    tnapr->NAPR_MO := m1NAPR_MO
    tnapr->NAPR_V := m1NAPR_V
    tnapr->MET_ISSL := m1MET_ISSL
    tnapr->U_KOD := mu_kod
    tnapr->shifr_u := mshifr
    tnapr->shifr1 := mshifr1
    tnapr->name_u := mname_u
    tnapr->KOD_VR := recNumberDoctor
    count_napr := LastRec()

    If n <= count_napr
      cur_napr := n
      Goto ( cur_napr ) // ����� ⥪�饣� ���ࠢ�����
      mNAPR_DATE := tnapr->NAPR_DATE

      mTab_Number := get_tabnom_vrach_by_kod( tnapr->KOD_VR )

      m1NAPR_MO := tnapr->NAPR_MO
      m1NAPR_V := tnapr->NAPR_V
      m1MET_ISSL := iif( m1napr_v == 3, tnapr->MET_ISSL, 0 )
      mu_kod := iif( m1napr_v == 3, tnapr->U_KOD, 0 )
      mshifr := iif( m1napr_v == 3, tnapr->shifr_u, Space( 20 ) )
      mshifr1 := iif( m1napr_v == 3, tnapr->shifr1, Space( 20 ) )
      mname_u := iif( m1napr_v == 3, tnapr->name_u, Space( 65 ) )
    Else
      cur_napr := count_napr + 1
      mNAPR_DATE := CToD( '' )
      mTab_Number := 0
      m1NAPR_MO := Space( 6 )
      mNAPR_MO := Space( 52 )
      m1NAPR_V := 0
      m1MET_ISSL := 0
      mu_kod := 0
      mshifr := Space( 20 )
      mshifr1 := Space( 20 )
      mname_u := Space( 52 )
    Endif

    mNAPR_V := PadR( inieditspr( A__MENUVERT, mm_napr_v, m1napr_v ), 30 )
    mMET_ISSL := PadR( inieditspr( A__MENUVERT, mm_MET_ISSL, m1MET_ISSL ), 35 )
    tip_onko_napr := 0
  Endif

  RestScreen( buf )
  Restore gets From tmp_gets
  my_restkey( tmp_keys )
  SetColor( tmp_color )
  SetCursor()
  Return update_gets()

// 11.06.24 ���� ���ࠢ����� ��᫥ ��ᯠ��ਧ�樨
Function dispans_napr( mk_data, /*@*/j, lAdult, lFull )

  // mk_data - ��� ����砭�� ���� ��ᯠ��ਧ�樨
  // j - ���稪 ��ப �� �࠭�
  // lAdult - �������� ���ࠢ����� �� ᠭ��୮-����⭮� ��祭��
  // lFull - �롮� �� ������� �ࠢ�筨��
  // �ᯮ������� PRIVATE-��६����
  Local strNeedTabNumber := '����室��� 㪠���� ⠡���� ���ࠢ��襣� ���'

  Default lAdult To .f.
  default lFull to .f.

  If mk_data >= 0d20210801  // �� ������ ����
    @ j, 74 Say '���'
    @ ++j, 1 Say Replicate( '�', 78 ) Color color1
    // ���ࠢ����� �� ���������쭮� ��᫥�������
    mdopo_na := iif( Len( mdopo_na ) > 0, SubStr( mdopo_na, 1, 31 ), '' )
    @ ++j, 1 Say '���ࠢ��� �� �������⥫쭮� ��᫥�������' Get mdopo_na ;
      reader {| x| menu_reader( x, mm_dopo_na, A__MENUBIT, , , .f. ) } ;
      valid {|| iif( m1dopo_na == 0, mtab_v_dopo_na := 0, ), update_get( 'mtab_v_dopo_na' ) }
    @ j, 73 Get mtab_v_dopo_na Pict '99999' ;
      valid {| g| iif( ( mtab_v_dopo_na == 0 ) .and. v_kart_vrach( g ), func_error( 4, strNeedTabNumber ), .t. ) } ;
      When m1dopo_na > 0
    // ���ࠢ����� � ����樭��� �࣠������
    @ ++j, 1 Say '���ࠢ���' Get mnapr_v_mo ;
      reader {| x| menu_reader( x, mm_napr_v_mo, A__MENUVERT, , , .f. ) } ;
      valid {|| iif( m1napr_v_mo == 0, ( arr_mo_spec := {}, ma_mo_spec := PadR( '---', 42 ), mtab_v_mo := 0 ), ), update_get( 'ma_mo_spec' ) }
    ma_mo_spec := iif( Len( ma_mo_spec ) > 0, SubStr( ma_mo_spec, 1, 20 ), '' )
    // @ j,col()+1 say '� ᯥ樠���⠬' get ma_mo_spec ;
    // reader {|x|menu_reader(x,{{|k,r,c| fget_spec_DVN(k,r,c,arr_mo_spec)}},A__FUNCTION,,,.f.)} ;
    // when m1napr_v_mo > 0
    If lAdult
      @ j, Col() + 1 Say '� ᯥ樠���⠬' Get ma_mo_spec ;
        reader {| x| menu_reader( x, { {| k, r, c | fget_spec_dvn( k, r, c, arr_mo_spec, lFull ) } }, A__FUNCTION, , , .f. ) } ;
        When m1napr_v_mo > 0
    Else
      @ j, Col() + 1 Say '� ᯥ樠���⠬' Get ma_mo_spec ;
        reader {| x| menu_reader( x, { {| k, r, c| fget_spec_deti( k, r, c, arr_mo_spec ) } }, A__FUNCTION, , , .f. ) } ;
        When m1napr_v_mo > 0
    Endif
    @ j, 73 Get mtab_v_mo Pict '99999' ;
      valid {| g| iif( ( mtab_v_mo == 0 ) .and. v_kart_vrach( g ), func_error( 4, strNeedTabNumber ), .t. ) } ;
      When m1napr_v_mo > 0
    // ���ࠢ����� � ��樮���
    @ ++j, 1 Say '���ࠢ��� �� ��祭��' Get mnapr_stac ;
      reader {| x| menu_reader( x, mm_napr_stac, A__MENUVERT, , , .f. ) } ;
      valid {|| iif( m1napr_stac == 0, ( m1profil_stac := 0, mtab_v_stac := 0, mprofil_stac := Space( 32 ) ), ), update_get( 'mprofil_stac' ) }
    mprofil_stac := iif( Len( mprofil_stac ) > 0, SubStr( mprofil_stac, 1, 27 ), '' )
    @ j, Col() + 1 Say '�� ��䨫�' Get mprofil_stac Picture '@S27' ;
      reader {| x| menu_reader( x, getv002(), A__MENUVERT, , , .f. ) } ;
      When m1napr_stac > 0
    @ j, 73 Get mtab_v_stac Pict '99999' ;
      valid {| g| iif( ( mtab_v_stac == 0 ) .and. v_kart_vrach( g ), func_error( 4, strNeedTabNumber ), .t. ) } ;
      When m1napr_stac > 0
    // ���ࠢ��� �� ॠ�������
    @ ++j, 1 Say '���ࠢ��� �� ॠ�������' Get mnapr_reab ;
      reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
      valid {|| iif( m1napr_reab == 0, ( m1profil_kojki := 0, mtab_v_reab := 0, mprofil_kojki := Space( 30 ) ), ), update_get( 'mprofil_kojki' ) }
    mprofil_kojki := iif( Len( mprofil_kojki ) > 0, SubStr( mprofil_kojki, 1, 25 ), '' )
    @ j, Col() + 1 Say ', ��䨫� �����' Get mprofil_kojki ;
      reader {| x| menu_reader( x, getv020(), A__MENUVERT, , , .f. ) } ;
      When m1napr_reab > 0
    @ j, 73 Get mtab_v_reab Pict '99999' ;
      valid {| g| iif( ( mtab_v_reab == 0 ) .and. v_kart_vrach( g ), func_error( 4, strNeedTabNumber ), .t. ) } ;
      When m1napr_reab > 0
    // ���ࠢ��� �� ᠭ��୮-����⭮� ��祭��
    If lAdult
      @ ++j, 1 Say '���ࠢ��� �� ᠭ��୮-����⭮� ��祭��' Get msank_na ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
        valid {|| iif( m1sank_na == 0, mtab_v_sanat := 0, ), update_get( 'mtab_v_sank' ) }
      @ j, 73 Get mtab_v_sanat Pict '99999' ;
        valid {| g| iif( ( mtab_v_sanat == 0 ) .and. v_kart_vrach( g ), func_error( 4, strNeedTabNumber ), .t. ) } ;
        when ( m1sank_na > 0 )
    Endif
  Else  // �� ���� �ࠢ���� ����
    @ ++j, 1 Say '���ࠢ��� �� �������⥫쭮� ��᫥�������' Get mdopo_na ;
      reader {| x| menu_reader( x, mm_dopo_na, A__MENUBIT, , , .f. ) }
    @ ++j, 1 Say '���ࠢ���' Get mnapr_v_mo ;
      reader {| x| menu_reader( x, mm_napr_v_mo, A__MENUVERT, , , .f. ) } ;
      valid {|| iif( m1napr_v_mo == 0, ( arr_mo_spec := {}, ma_mo_spec := PadR( '---', 42 ) ), ), update_get( 'ma_mo_spec' ) }
    If lAdult
      @ j, Col() + 1 Say '� ᯥ樠���⠬' Get ma_mo_spec ;
        reader {| x| menu_reader( x, { {| k, r, c| fget_spec_dvn( k, r, c, arr_mo_spec ) } }, A__FUNCTION, , , .f. ) } ;
        When m1napr_v_mo > 0
    Else
      @ j, Col() + 1 Say '� ᯥ樠���⠬' Get ma_mo_spec ;
        reader {| x| menu_reader( x, { {| k, r, c| fget_spec_deti( k, r, c, arr_mo_spec ) } }, A__FUNCTION, , , .f. ) } ;
        When m1napr_v_mo > 0
    Endif
    @ ++j, 1 Say '���ࠢ��� �� ��祭��' Get mnapr_stac ;
      reader {| x| menu_reader( x, mm_napr_stac, A__MENUVERT, , , .f. ) } ;
      valid {|| iif( m1napr_stac == 0, ( m1profil_stac := 0, mprofil_stac := Space( 32 ) ), ), update_get( 'mprofil_stac' ) }
    @ j, Col() + 1 Say '�� ��䨫�' Get mprofil_stac ;
      reader {| x| menu_reader( x, getv002(), A__MENUVERT, , , .f. ) } ;
      When m1napr_stac > 0
    @ ++j, 1 Say '���ࠢ��� �� ॠ�������' Get mnapr_reab ;
      reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
      valid {|| iif( m1napr_reab == 0, ( m1profil_kojki := 0, mprofil_kojki := Space( 30 ) ), ), update_get( 'mprofil_kojki' ) }
    @ j, Col() + 1 Say ', ��䨫� �����' Get mprofil_kojki ;
      reader {| x| menu_reader( x, getv020(), A__MENUVERT, , , .f. ) } ;
      When m1napr_reab > 0
    If lAdult
      @ ++j, 1 Say '���ࠢ��� �� ᠭ��୮-����⭮� ��祭��' Get msank_na ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
    Endif
  Endif
  Return Nil

// 27.06.23
Function checktabnumberdoctor( mk_data, lAdult )

  Local ret := .t.
  Local sBeginMsg := '�� �������� ⠡���� ����� ��� ���ࠢ��襣� '

  Default lAdult To .f.

  If mk_data >= 0d20210801
    If ( m1dopo_na > 0 ) .and. ( mtab_v_dopo_na == 0 )
      func_error( 4, sBeginMsg + '�� �������⥫쭮� ��᫥�������' )
      ret := .f.
    Endif
    If ( m1napr_v_mo > 0 ) .and. ( mtab_v_mo == 0 )
      func_error( 4, sBeginMsg + '� ᯥ樠���⠬' )
      ret := .f.
    Endif
    If ( m1napr_stac > 0 ) .and. ( mtab_v_stac == 0 )
      func_error( 4, sBeginMsg + '�� ��祭��' )
      ret := .f.
    Endif
    If ( m1napr_reab > 0 ) .and. ( mtab_v_reab == 0 )
      func_error( 4, sBeginMsg + '�� ॠ�������' )
      ret := .f.
    Endif
    If lAdult .and. ( m1sank_na > 0 ) .and. ( mtab_v_sanat == 0 )
      func_error( 4, sBeginMsg + '�� ᠭ��୮-����⭮� ��祭��' )
      ret := .f.
    Endif
  Endif
  Return ret

// 27.05.22 - ������ �������� �६������ 䠩�� ��� ���ࠢ����� �� ���������
Function create_struct_temporary_onkna()
  Return { ; // �������ࠢ�����
            { 'KOD', 'N',  7, 0 }, ; // ��� ���쭮��
            { 'NAPR_DATE', 'D',  8, 0 }, ; // ��� ���ࠢ�����
            { 'NAPR_MO', 'C',  6, 0 }, ; // ��� ��㣮�� ��, �㤠 �믨ᠭ� ���ࠢ�����
            { 'NAPR_V', 'N',  1, 0 }, ; // ��� ���ࠢ�����:1-� ��������,2-�� ������,3-�� ����᫥�������,4-��� ���.⠪⨪� ��祭��
            { 'MET_ISSL', 'N',  1, 0 }, ; // ��⮤ ���������᪮�� ��᫥�������(�� NAPR_V=3):1-���.�������⨪�;2-�����.�������⨪�;3-���.�������⨪�;4-��, ���, ���������
            { 'SHIFR', 'C', 20, 0 }, ;
            { 'SHIFR_U', 'C', 20, 0 }, ;
            { 'SHIFR1', 'C', 20, 0 }, ;
            { 'NAME_U', 'C', 65, 0 }, ;
            { 'U_KOD', 'N',  6, 0 }, ; // ��� ��㣨
            { 'KOD_VR', 'N',  5, 0 } ;  // ��� ��� (�ࠢ�筨� mo_pers)
          }

// 04.07.23
Function collect_napr_zno( Loc_kod )

  Local count_napr := 0, tmp_select := Select()
  Local lAlias

  Use ( cur_dir() + 'tmp_onkna' ) New Alias TNAPR
  lAlias := 'MOSU'
  If !( lAlias )->( Used() )
    r_use( dir_server + 'mo_su', , 'MOSU' )
  Endif
  lAlias := 'NAPR'
  If ( lAlias )->( Used() )
    ( lAlias )->( dbSelectArea() )
  Else
    r_use( dir_server + 'mo_onkna', dir_server + 'mo_onkna', 'NAPR' ) // �������ࠢ�����
  Endif
  Set Relation To u_kod into MOSU
  find ( Str( Loc_kod, 7 ) )
  Do While napr->kod == Loc_kod .and. !Eof()
    // cur_napr := 1 // �� ।-�� - ᭠砫� ��ࢮ� ���ࠢ����� ⥪�饥
    ++count_napr
    Select TNAPR
    Append Blank
    tnapr->NAPR_DATE := napr->NAPR_DATE
    tnapr->KOD_VR    := napr->KOD_VR
    tnapr->NAPR_MO   := napr->NAPR_MO
    tnapr->NAPR_V    := napr->NAPR_V
    tnapr->MET_ISSL  := napr->MET_ISSL
    tnapr->U_KOD     := napr->U_KOD
    tnapr->shifr_u   := iif( Empty( mosu->shifr ), mosu->shifr1, mosu->shifr )
    tnapr->shifr1    := mosu->shifr1
    tnapr->name_u    := mosu->name
    Select NAPR
    Skip
  Enddo
  Select( tmp_select )
  Return count_napr

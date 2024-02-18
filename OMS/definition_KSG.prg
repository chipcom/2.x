#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'


// 17.02.24 ��।������ ��� �� ��⠫�� ������ ���� ����� - 2019-24 ���
Function definition_ksg( par, k_data2, lDoubleSluch )

  // 䠩�� 'human', 'human_' � 'human_2' ������ � ���� �� �㦭�� �����
  // 'human' ����� ��� ����� �㬬� ����
  // �믮����� use_base('human_u', 'HU') - ��� �����
  // �믮����� use_base('mo_hu', 'MOHU') - ��� �����
  Static ver_year := 0 // ��᫥���� �஢��塞� ���
  Static ad_ksg_3, ad_ksg_4
  Static sp0, sp1, sp6, sp15
  Static a_iskl_1 := { ; // �᪫�祭�� �� �ࠢ�� �1
  { 'st02.010', 'st02.008' }, ;
    { 'st02.011', 'st02.008' }, ;
    { 'st02.010', 'st02.009' }, ;
    { 'st14.001', 'st04.002' }, ;
    { 'st14.004', 'st04.002' }, ;
    { 'st21.001', 'st21.007' }, ;
    { 'st34.002', 'st34.001' }, ;
    { 'st34.002', 'st26.001' }, ;
    { 'st34.006', 'st30.003' }, ;
    { 'st09.001', 'st30.005' }, ;
    { 'st31.002', 'st31.017' }, ;
    { 'st37.001', '' }, ;
    { 'st37.002', '' }, ;
    { 'st37.003', '' }, ;
    { 'st37.004', '' }, ;
    { 'st37.005', '' }, ;
    { 'st37.006', '' }, ;
    { 'st37.007', '' }, ;
    { 'st37.008', '' }, ;
    { 'st37.009', '' }, ;
    { 'st37.010', '' }, ;
    { 'st37.011', '' }, ;
    { 'st37.012', '' }, ;
    { 'st37.013', '' }, ;
    { 'st37.014', '' }, ;
    { 'st37.015', '' }, ;
    { 'st37.016', '' }, ;
    { 'st37.017', '' }, ;
    { 'st37.018', '' }, ;
    { 'ds37.001', '' }, ;
    { 'ds37.002', '' }, ;
    { 'ds37.003', '' }, ;
    { 'ds37.004', '' }, ;
    { 'ds37.005', '' }, ;
    { 'ds37.006', '' }, ;
    { 'ds37.007', '' }, ;
    { 'ds37.008', '' }, ;
    { 'ds37.009', '' }, ;
    { 'ds37.010', '' }, ;
    { 'ds37.011', '' }, ;
    { 'ds37.012', '' };
    }

  Local mdiagnoz, aHirKSG := {}, aTerKSG := {}, fl_cena := .f., lvmp, lvidvmp := 0, lstentvmp := 0, ;
    i, j, k, c, s, ar, ar1, fl, im, lshifr, ln_data, lk_data, lvr, ldni, ldate_r, lpol, lprofil_k, ;
    lfio, cenaTer := 0, cenaHir := 0, ksgHir, ars := {}, arerr := {}, ;
    lksg := '', lcena := 0, osn_diag3, lprofil, ldnej := 0, y := 0, m := 0, d := 0, ;
    osn_diag := Space( 6 ), sop_diag := {}, osl_diag := {}, tmp, lrslt, akslp, akiro, ;
    lad_cr := '', lad_cr1 := '', lis_err := 0, akslp2, lpar_org := 0, lyear, ;
    kol_ter := 0, kol_hir := 0, lkoef, fl_reabil, lkiro := 0, lkslp := '', lbartell := '', ;
    lusl, susl, s_dializ := 0, ahu := {}, amohu := {}, ;
    date_usl := SToD( '20210101' ) // stod('20200101')

  Local iKSLP, newKSLP := '', tmSel
  Local humKSLP := ''
  Local vkiro := 0

  Default par To 1, sp0 To '', sp1 To Space( 1 ), sp6 To Space( 6 ), sp15 To Space( 20 )
  Default lDoubleSluch To .f.
  Private pole

  If par == 1
    uch->( dbGoto( human->LPU ) )
    otd->( dbGoto( human->OTD ) )
    If ( lvmp := human_2->VMP ) == 1
      lvidvmp := human_2->METVMP
    Endif
    lad_cr  := AllTrim( human_2->pc3 )
    lfio    := AllTrim( human->fio )
    ln_data := human->n_data
    If ValType( k_data2 ) == 'D'
      lk_data := k_data2
    Else
      lk_data := human->k_data
    Endif
    lusl    := human_->USL_OK
    ldate_r := iif( human_->NOVOR > 0, human_->date_r2, human->date_r )
    lpol    := iif( human_->NOVOR > 0, human_->pol2,    human->pol )
    lvr     := iif( human->VZROS_REB == 0, 0, 1 ) // 0-�����, 1-ॡ����
    lprofil := human_->profil
    lprofil_k := human_2->profil_k
    lrslt   := human_->rslt_new
    // ���ᨢ ��������� (������ ���)
    mdiagnoz := diag_to_array(,,,, .t. )
    If Len( mdiagnoz ) > 0
      osn_diag := mdiagnoz[ 1 ]
      If Len( mdiagnoz ) > 1
        sop_diag := AClone( mdiagnoz )
        del_array( sop_diag, 1 ) // ��稭�� � 2-�� - ᮯ������騥 ��������
      Endif
    Endif
    If !Empty( human_2->OSL1 )
      AAdd( osl_diag, human_2->OSL1 )
    Endif
    If !Empty( human_2->OSL2 )
      AAdd( osl_diag, human_2->OSL2 )
    Endif
    If !Empty( human_2->OSL3 )
      AAdd( osl_diag, human_2->OSL3 )
    Endif

    If lusl < 3 .and. lVMP == 0 .and. f_is_oncology( 1 ) == 2 .and. Empty( lad_cr )
      If Select( 'ONKSL' ) == 0
        g_use( dir_server + 'mo_onksl', dir_server + 'mo_onksl', 'ONKSL' ) // �������� � ��砥 ��祭�� ���������᪮�� �����������
      Endif
      Select ONKSL
      find ( Str( human->kod, 7 ) )
      lad_cr := AllTrim( onksl->crit )
      If lad_cr == '���'
        lad_cr := ''
      Endif
      lad_cr1 := AllTrim( onksl->crit2 )
      lis_err := onksl->is_err
    Endif
  Else // �� ०��� ������ ��砥�
    If ( lvmp := iif( Empty( ihuman->VID_HMP ), 0, 1 ) ) == 1
      lvidvmp := ihuman->METOD_HMP
    Endif
    lad_cr  := AllTrim( ihuman->ad_cr )
    If lad_cr == '���'
      lad_cr := ''
    Endif
    lad_cr1 := AllTrim( ihuman->ad_cr2 )
    lis_err := ihuman->is_err
    lusl    := ihuman->USL_OK
    lfio    := AllTrim( ihuman->fio )
    ln_data := ihuman->date_1
    If ValType( k_data2 ) == 'D'
      lk_data := k_data2
    Else
      lk_data := ihuman->date_2
    Endif
    ldate_r := iif( ihuman->NOVOR > 0, ihuman->reb_dr,  ihuman->dr )
    lpol    := iif( ihuman->NOVOR > 0, ihuman->reb_pol, ihuman->w )
    lpol    := iif( lpol == 1, '�', '�' )
    lvr     := iif( m1VZROS_REB == 0, 0, 1 ) // 0-�����, 1-ॡ����
    lprofil := ihuman->profil
    lprofil_k := ihuman->profil_k
    lrslt   := ihuman->rslt
    osn_diag := PadR( ihuman->DS1, 6 )
    If !Empty( ihuman->DS2 )
      AAdd( sop_diag, PadR( ihuman->DS2, 6 ) )
    Endif
    If !Empty( ihuman->DS2_2 )
      AAdd( sop_diag, PadR( ihuman->DS2_2, 6 ) )
    Endif
    If !Empty( ihuman->DS2_3 )
      AAdd( sop_diag, PadR( ihuman->DS2_3, 6 ) )
    Endif
    If !Empty( ihuman->DS2_4 )
      AAdd( sop_diag, PadR( ihuman->DS2_4, 6 ) )
    Endif
    If !Empty( ihuman->DS2_5 )
      AAdd( sop_diag, PadR( ihuman->DS2_5, 6 ) )
    Endif
    If !Empty( ihuman->DS2_6 )
      AAdd( sop_diag, PadR( ihuman->DS2_6, 6 ) )
    Endif
    If !Empty( ihuman->DS2_7 )
      AAdd( sop_diag, PadR( ihuman->DS2_7, 6 ) )
    Endif
    mdiagnoz := AClone( sop_diag )
    ins_array( mdiagnoz, 1, osn_diag )
    If !Empty( ihuman->DS3 )
      AAdd( osl_diag, PadR( ihuman->DS3, 6 ) )
    Endif
    If !Empty( ihuman->DS3_2 )
      AAdd( osl_diag, PadR( ihuman->DS3_2, 6 ) )
    Endif
    If !Empty( ihuman->DS3_3 )
      AAdd( osl_diag, PadR( ihuman->DS3_3, 6 ) )
    Endif
  Endif

  //
  lyear := Year( lk_data )
  If eq_any( lad_cr, '60', '61' )
    lbartell := lad_cr
    lad_cr := ''
  Endif
  ldni := ln_data - ldate_r // ��� ॡ񭪠 ������ � ����
  count_ymd( ldate_r, ln_data, @y, @m, @d )
  date_usl := lk_data // !!!!!!!!!!!!�᪮�����஢��� ��᫥ ���!!!!!!!!!!!!!!!
  If lusl == 1 // ��樮���
    If ( ldnej := lk_data - ln_data ) == 0
      ldnej := 1
    Endif
  Endif
  AAdd( ars, lfio + ', �.�.' + full_date( ldate_r ) + iif( lvr == 0, ' (���.', ' (ॡ.' ) + '), ' + iif( lpol == '�', '��.', '���.' ) )
  AAdd( ars, ' �ப ��祭��: ' + date_8( ln_data ) + '-' + date_8( lk_data ) + ' (' + lstr( ldnej ) + '��.)' )
  s := iif( lVMP == 1, '��� ', ' ' )
  If par == 1
    s += AllTrim( substr( otd->name, 1, 30 ) ) + ' / '
  Endif
  s += '��䨫� "' + inieditspr( A__MENUVERT, getv002(), lprofil ) + '"'
  AAdd( ars, s )
  AAdd( ars, ' ��.����.: ' + osn_diag + ;
    iif( Empty( sop_diag ), '', ', ᮯ.����.' + CharRem( ' ', print_array( sop_diag ) ) ) + ;
    iif( Empty( osl_diag ), '', ', ����.��.' + CharRem( ' ', print_array( osl_diag ) ) ) )
  If Empty( osn_diag )
    AAdd( arerr, ' �� ����� �᭮���� �������' )
    Return { ars, arerr, lksg, lcena, {}, {} }
  Endif
  If f_put_glob_podr( lusl, date_usl, arerr ) // �᫨ �� �������� ��� ���ࠧ�������
    Return { ars, arerr, lksg, lcena, {}, {} }
  Endif
  If lvmp > 0
    If lvidvmp == 0
      AAdd( arerr, ' �� ����� ��⮤ ���' )
    Elseif ( AScan( arr_12_VMP, lvidvmp ) == 0 .and. Year( lk_data ) < 2021 )
      AAdd( arerr, ' ��� ��⮤� ��� ' + lstr( lvidvmp ) + ' ��� ��㣨 �����' )
    Else
      lksg := getserviceforvmp( lvidvmp, lk_data, human_2->VIDVMP, human_2->METVMP, human_2->PN5, human->KOD_DIAG )
      AAdd( ars, ' ��� ' + lstr( lvidvmp ) + ' ��⮤� ��� ������� ��㣠 ' + lksg )
      lcena := ret_cena_ksg( lksg, lvr, date_usl )
      If lcena > 0
        AAdd( ars, ' ���������: ��࠭� ��㣠 = ' + lksg + ' � 業�� ' + lstr( lcena, 11, 0 ) )
      Else
        AAdd( arerr, ' ��� ��襩 �� � �ࠢ�筨�� ����� �� ������� ��㣠: ' + lksg )
      Endif
    Endif
    Return { ars, arerr, AllTrim( lksg ), lcena, {}, {} }
  Endif
  lal := create_name_alias( 'LUSL', lyear )
  lalf := create_name_alias( 'LUSLF', lyear )
  If Select( 'LUSLF' ) == 0
    use_base( 'LUSLF' )
  Endif

  // ��⠢�塞 ���ᨢ ��� � ���ᨢ �������権
  If par == 1
    Select HU
    find ( Str( human->kod, 7 ) )
    Do While hu->kod == human->kod .and. !Eof()
      usl->( dbGoto( hu->u_kod ) )
      If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, date_usl ) )
        lshifr := usl->shifr
      Endif
      lshifr := AllTrim( lshifr )
      If Left( lshifr, 5 ) == '60.3.'
        s_dializ += hu->stoim_1
      Endif
      If AScan( ahu, lshifr ) == 0
        AAdd( ahu, lshifr )
      Endif
      If lusl == 2 .and. Left( lshifr, 5 ) == '55.1.'
        ldnej += hu->kol_1
      Endif
      Select HU
      Skip
    Enddo
    If Select( 'MOSU' ) == 0
      r_use( dir_server + 'mo_su', , 'MOSU' )
    Endif
    Select MOHU
    find ( Str( human->kod, 7 ) )
    Do While mohu->kod == human->kod .and. !Eof()
      If mosu->( RecNo() ) != mohu->u_kod
        mosu->( dbGoto( mohu->u_kod ) )
      Endif
      If AScan( amohu, mosu->shifr1 ) == 0
        AAdd( amohu, mosu->shifr1 )
      Endif
      dbSelectArea( lalf )
      find ( PadR( mosu->shifr1, 20 ) )
      If Found() .and. !Empty( &lalf.->par_org )
        lpar_org += Len( list2arr( mohu->zf ) )
      Endif
      Select MOHU
      Skip
    Enddo
  Else
    Select IHU
    find ( Str( ihuman->kod, 10 ) )
    Do While ihu->kod == ihuman->kod .and. !Eof()
      If eq_any( Left( ihu->CODE_USL, 1 ), 'A', 'B' )
        If AScan( amohu, ihu->CODE_USL ) == 0
          AAdd( amohu, ihu->CODE_USL )
        Endif
        dbSelectArea( lalf )
        find ( PadR( ihu->CODE_USL, 20 ) )
        If Found() .and. !Empty( &lalf.->par_org )
          lpar_org += Len( list2arr( ihu->par_org ) )
        Endif
      Else
        If AScan( ahu, AllTrim( ihu->CODE_USL ) ) == 0
          AAdd( ahu, AllTrim( ihu->CODE_USL ) )
        Endif
        If Left( ihu->CODE_USL, 5 ) == '60.3.'
          s_dializ += ihu->SUMV_USL
        Endif
        If lusl == 2 .and. Left( ihu->CODE_USL, 5 ) == '55.1.'
          ldnej += ihu->KOL_USL
        Endif
      Endif
      Select IHU
      Skip
    Enddo
  Endif

  //
  If lvr == 0 //
    lage := '6'
    s := '���.'
  Else
    lage := '5'
    s := '���'
    fl := .t.
    If ldni <= 28
      lage += '1' // ��� �� 28 ����
      s := '0-28��.'
      fl := .f.
    Elseif ldni <= 90
      lage += '2' // ��� �� 90 ����
      s := '29-90��.'
      fl := .f.
    Elseif y < 1 // �� 1 ����
      lage += '3' // ��� �� 91 ��� �� 1 ����
      s := '91����-1���'
      fl := .f.
    Endif
    If y <= 2 // �� 2 ��� �����⥫쭮
      lage += '4' // ��� �� 2 ���
      If fl
        s := '��2��� �����.'
      Endif
    Endif
  Endif
  ars[ 1 ] := lfio + ', �.�. ' + full_date( ldate_r ) + iif( lvr == 0, ' (���.', ' (ॡ.' ) + '), ' + iif( lpol == '�', '��.', '���.' )
  ars[ 2 ] := ' �ப ��祭��: ' + date_8( ln_data ) + '-' + date_8( lk_data ) + ' (' + lstr( ldnej ) + '��.)'

  ars[ 4 ] := ' ��.����.: ' + osn_diag + ;
    iif( Empty( sop_diag ), '', ', ᮯ.����.' + CharRem( ' ', print_array( sop_diag ) ) ) + ;
    iif( Empty( osl_diag ), '', ', ����.��.' + CharRem( ' ', print_array( osl_diag ) ) )
  lsex := iif( lpol == '�', '1', '2' )

  llos := {} // ''
  If ldnej < 4
    AAdd( llos, '1' ) // llos += '1'
  Elseif Between( ldnej, 4, 10 )
    AAdd( llos, '11' )
  Elseif Between( ldnej, 11, 20 )
    AAdd( llos, '12' )
  Elseif Between( ldnej, 21, 30 )
    AAdd( llos, '13' )
  Endif
  /*
  0 - ���� �� �ਬ������
  1 - ���⥫쭮��� ���� 3 �����-��� (���� ��祭��) � ����� � ��樥��� �믮����� ���ࣨ�᪠� ������
      ���� ��㣮� ����⥫��⢮, ��騥�� �����䨪�樮��� ���ਥ� �⭥ᥭ�� ������� ���� ��祭��
      � �����⭮� ��� ��� ����ᨬ��� �� ��⠭�� � १���⠬� ���饭�� �� ����樭᪮� �������
  2 - ���⥫쭮��� ���� 3 �����-��� (���� ��祭��) � �����, �� ���ࣨ�᪮� ��祭�� ���� ��㣮� ����⥫��⢮,
      ��।����饥 �⭥ᥭ�� � ��� �� �஢������� � ���ਥ� �⭥ᥭ�� � ��砥 ���� ��� �������� �� ��� 10
      ��� ����ᨬ��� �� ��⠭�� � १���⠬� ���饭�� �� ����樭᪮� �������;
  3 - ���⥫쭮��� ���� 4 �����-��� (���� ��祭��) � ����� � ��樥��� �믮����� ���ࣨ�᪠� ������
      ���� ��㣮� ����⥫��⢮, ��騥�� �����䨪�樮��� ���ਥ� �⭥ᥭ�� ������� ���� ��祭��
      � �����⭮� ��� � ��⠭�� � १���⠬� ���饭�� �� ����樭᪮� �������
      (�����䨪��� V009) 102, 105, 107, 110, 202, 205, 207
  4 - ���⥫쭮��� ���� 4 �����-��� (���� ��祭��) � �����, �� ���ࣨ�᪮� ��祭�� ���� ��㣮� ����⥫��⢮,
      ��।����饥 �⭥ᥭ�� � ��� �� �஢�������, � ��⠭�� � १���⠬� ���饭�� �� ����樭᪮� �������
      (�����䨪��� V009) 102, 105, 107, 110, 202, 205, 207
  5 - ��砨 � ��ᮡ����� ०��� �������� ������⢥����� �९��� (���� �������� � �奬�) ᮣ��᭮ ������樨
      � �९���� �� ���⥫쭮�� ���� 3 �����-��� (��� ��祭��) � ����� ��� ����ᨬ��� �� १���� ���饭��
      �� ����樭᪮� �������
  6 - ��砨 � ��ᮡ����� ०��� �������� ������⢥����� �९��� (���� �������� � �奬�) ᮣ��᭮ ������樨
      � �९���� �� ���⥫쭮�� ���� 4 �����-��� (��� ��祭��) � ����� � ��⠭�� � १���⠬� ���饭��
      �� ����樭᪮� ������� (�����䨪��� V009) 102, 105, 107, 110, 202, 205, 207
  */
  // aadd(ars, '   �age=' +lage+ ' sex=' +lsex+ ' los=' +print_array(llos))

  nfile := prefixfilerefname( lyear ) + 'k006'
  If Select( 'K006' ) == 0
    r_use( dir_exe + nfile, { cur_dir + nfile, cur_dir + nfile + '_', cur_dir + nfile + 'AD' }, 'K006' )
  Else
    If ver_year == lyear // �஢��塞: �᫨ �� �� ���, �� ⮫쪮 �� �஢��﫨
      // ��祣� �� ���塞
    Else // ���� ��८��뢠�� ����� 䠩� � ����室��� ����� � ⥬ �� ����ᮬ
      k006->( dbCloseArea() )
      r_use( dir_exe + nfile, { cur_dir + nfile, cur_dir + nfile + '_', cur_dir + nfile + 'AD' }, 'K006' )
    Endif
  Endif
  ver_year := lyear
  fl_reabil := ( AScan( ahu, '1.11.2' ) > 0 .or. AScan( ahu, '55.1.4' ) > 0 )
  susl := iif( lusl == 1, 'st', 'ds' )

  // ᮡ�ࠥ� ��� �� ��.�������� (�࠯����᪨� � �������஢����)
  ar := {}
  tmp := {}
  Select K006

  If lprofil == 137   // ���
    Set Order To 3
    K006->( dbGoTop() )
    K006->( dbSeek( Lower( lad_cr ) ) )
    Do While Lower( AllTrim( K006->AD_CR ) ) == Lower( AllTrim( lad_cr ) ) .and. !( 'K006' )->( Eof() )

      lkoef := k006->kz
      dbSelectArea( lal )
      find ( PadR( k006->shifr, 10 ) )
      fl := lkoef > 0 .and. between_date( &lal.->DATEBEG, &lal.->DATEEND, date_usl )
      If fl
        fl := between_date( k006->DATEBEG, k006->DATEEND, date_usl )
      Endif
      j := 0
      j++
      j++
      If fl
        AAdd( ar, { k006->shifr, ; // 1
        0, ;           // 2
          lkoef, ;       // 3
        &lal.->kiros, ; // 4
        osn_diag, ;    // 5
        k006->sy, ;    // 6
        k006->age, ;   // 7
        k006->sex, ;   // 8
        k006->los, ;   // 9
        k006->ad_cr, ; // 10
        '', ;        // 11
          '', ;        // 12
        j, ;           // 13
          &lal.->kslps, ; // 14
        k006->ad_cr1 } ) // 15
      Endif

      K006->( dbSkip() )
    Enddo
  Else
    Set Order To 1
    find ( susl + PadR( osn_diag, 6 ) )
    Do While Left( k006->shifr, 2 ) == susl .and. k006->ds == PadR( osn_diag, 6 ) .and. !Eof()
      lkoef := k006->kz
      dbSelectArea( lal )
      find ( PadR( k006->shifr, 10 ) )
      fl := lkoef > 0 .and. between_date( &lal.->DATEBEG, &lal.->DATEEND, date_usl )
      If fl
        fl := between_date( k006->DATEBEG, k006->DATEEND, date_usl )
      Endif
      If fl
        sds1 := iif( Empty( k006->ds1 ), sp0, AllTrim( k006->ds1 ) + sp6 ) // ᮯ.�������
        sds2 := iif( Empty( k006->ds2 ), sp0, AllTrim( k006->ds2 ) + sp6 ) // �����.�᫮������
      Endif
      j := 0

      // ��-� ����� �� ⠪
      If fl .and. !Empty( k006->sy )
        If ( i := AScan( amohu, k006->sy ) ) > 0
          j += 10
        Else
          fl := .f.
        Endif
      Endif
      // ����� ��-� ����� �� ⠪

      If fl .and. !Empty( k006->age )
        If ( fl := ( k006->age $ lage ) )
          If k006->age == '1'
            j += 5
          Elseif k006->age == '2'
            j += 4
          Elseif k006->age == '3'
            j += 3
          Elseif k006->age == '4'
            j += 2
          Else
            j++
          Endif
        Endif
      Endif
      If fl .and. !Empty( k006->sex )
        fl := ( k006->sex == lsex )
        If fl
          j++
        Endif
      Endif
      If fl .and. !Empty( k006->los )
        fl := AScan( llos, AllTrim( k006->los ) ) > 0  // (k006->los $ llos)
        If fl
          j++
        Endif
      Endif

      If fl
        If Empty( lad_cr ) // � ��砥 ��� ���.�����
          If !Empty( k006->ad_cr ) // � � �ࠢ�筨�� ���� ���.���਩
            fl := .f.
          Endif
        Else // � ��砥 ���� ���.���਩
          If Empty( k006->ad_cr ) // � � �ࠢ�筨�� ��� ���.�����
            fl := .f.
          Else                  // � � �ࠢ�筨�� ���� ���.���਩
            fl := ( AllTrim( lad_cr ) == AllTrim( k006->ad_cr ) )
            If fl
              j++
            Endif
          Endif
        Endif
      Endif
      If fl
        If Empty( lad_cr1 ) // � ��砥 ��� ���.�����2
          If !Empty( k006->ad_cr1 ) // � � �ࠢ�筨�� ���� ���.���਩2
            fl := .f.
          Endif
        Else // � ��砥 ���� ���.���਩2
          If Empty( k006->ad_cr1 ) // � � �ࠢ�筨�� ��� ���.�����2
            fl := .f.
          Else                  // � � �ࠢ�筨�� ���� ���.���਩2
            fl := ( lad_cr1 == AllTrim( k006->ad_cr1 ) )
            If fl
              j++
            Endif
          Endif
        Endif
      Endif
      //
      If fl .and. !Empty( sds1 )
        fl := .f.
        For i := 1 To Len( sop_diag )
          If AllTrim( sop_diag[ i ] ) $ sds1
            fl := .t.
            Exit
          Endif
        Next
        If fl
          j++
        Endif
      Endif
      If fl .and. !Empty( sds2 )
        fl := .f.
        For i := 1 To Len( osl_diag )
          If AllTrim( osl_diag[ i ] ) $ sds2
            fl := .t.
            Exit
          Endif
        Next
        If fl
          j++
        Endif
      Endif
      //
      If fl
        If !Empty( k006->sy ) .and. ( i := AScan( amohu, k006->sy ) ) > 0
          AAdd( tmp, i )
        Endif
        AAdd( ar, { k006->shifr, ; // 1
        0, ;           // 2
          lkoef, ;       // 3
        &lal.->kiros, ; // 4
        osn_diag, ;    // 5
        k006->sy, ;    // 6
        k006->age, ;   // 7
        k006->sex, ;   // 8
        k006->los, ;   // 9
        k006->ad_cr, ; // 10
        sds1, ;        // 11
          sds2, ;        // 12
        j, ;           // 13
          &lal.->kslps, ; // 14
        k006->ad_cr1 } ) // 15
      Endif
      Select K006
      Skip
    Enddo
  Endif
  ar1 := {}
  If lusl == 2 .and. !Empty( lad_cr ) .and. lad_cr == 'mgi'
    Select K006
    Locate For k006->ad_cr == PadR( 'mgi', 20 )
    If Found() // <CODE>ds19.033</CODE>
      lkoef := k006->kz
      dbSelectArea( lal )
      find ( PadR( k006->shifr, 10 ) )
      fl := lkoef > 0 .and. between_date( &lal.->DATEBEG, &lal.->DATEEND, date_usl )
      If fl
        fl := between_date( k006->DATEBEG, k006->DATEEND, date_usl )
      Endif
      If fl
        sds1 := iif( Empty( k006->ds1 ), sp0, AllTrim( k006->ds1 ) + sp6 ) // ᮯ.�������
        sds2 := iif( Empty( k006->ds2 ), sp0, AllTrim( k006->ds2 ) + sp6 ) // �����.�᫮������
        j := 1
        ar := {}
        AAdd( ar1, { k006->shifr, ; // 1
        0, ;           // 2
          lkoef, ;       // 3
        &lal.->kiros, ; // 4
        k006->ds, ;    // 5
        lshifr, ;      // 6
        k006->age, ;   // 7
        k006->sex, ;   // 8
        k006->los, ;   // 9
        k006->ad_cr, ; // 10
        sds1, ;        // 11
          sds2, ;        // 12
        j, ;           // 13
          &lal.->kslps, ; // 14
        k006->ad_cr1 } ) // 15
      Endif
    Endif
  Endif
  If Len( ar ) > 0
    For i := 1 To Len( tmp )
      im := tmp[ i ]
      amohu[ im ] := '' // ������, �⮡� �� ������� � ���ࣨ���� ���
    Next
    For i := 1 To Len( ar )
      ar[ i, 2 ] := ret_cena_ksg( ar[ i, 1 ], lvr, date_usl )
      If ar[ i, 2 ] > 0
        fl_cena := .t.
      Endif
    Next
    aTerKSG := AClone( ar )
    If Len( aTerKSG ) > 1
      ASort( aTerKSG, , , {| x, y| iif( x[ 13 ] == y[ 13 ], x[ 3 ] > y[ 3 ], x[ 13 ] > y[ 13 ] ) } )
    Endif
    /*aadd(ars, '   ����: ' +print_array(aTerKSG[1]))
    for j := 2 to len(aTerKSG)
      aadd(ars, '   �     ' +print_array(aTerKSG[j]))
    next*/
    If ( kol_ter := f_put_debug_ksg( 0, aTerKSG, ars ) ) > 1
      AAdd( ars, ' ��> �롨ࠥ� ���=' + RTrim( aTerKSG[ 1, 1 ] ) + ' [��=' + lstr( aTerKSG[ 1, 3 ] ) + ']' )
    Endif
  Endif
  // ᮡ�ࠥ� ��� �� ��������� (���ࣨ�᪨� � �������஢����)
  ar := ar1
  For im := 1 To Len( amohu )
    If !Empty( lshifr := AllTrim( amohu[ im ] ) )
      _a1 := {}
      Select K006
      Set Order To 2
      find ( susl + PadR( lshifr, 20 ) )
      Do While Left( k006->shifr, 2 ) == susl .and. k006->sy == PadR( lshifr, 20 ) .and. !Eof()
        lkoef := k006->kz
        dbSelectArea( lal )
        find ( PadR( k006->shifr, 10 ) )
        fl := lkoef > 0 .and. between_date( &lal.->DATEBEG, &lal.->DATEEND, date_usl )
        If fl
          fl := between_date( k006->DATEBEG, k006->DATEEND, date_usl )
        Endif
        If fl
          sds1 := iif( Empty( k006->ds1 ), sp0, AllTrim( k006->ds1 ) + sp6 ) // ᮯ.�������
          sds2 := iif( Empty( k006->ds2 ), sp0, AllTrim( k006->ds2 ) + sp6 ) // �����.�᫮������
        Endif
        j := 0
        If fl .and. !Empty( k006->ds )
          fl := ( k006->ds == osn_diag )
          If fl
            j += 10
          Endif
        Endif
        If fl .and. !Empty( k006->age )
          If ( fl := ( k006->age $ lage ) )
            If k006->age == '1'
              j += 5
            Elseif k006->age == '2'
              j += 4
            Elseif k006->age == '3'
              j += 3
            Elseif k006->age == '4'
              j += 2
            Else
              j++
            Endif
          Endif
        Endif
        If fl .and. !Empty( k006->sex )
          fl := ( k006->sex == lsex )
          If fl
            j++
          Endif
        Endif
        If fl .and. !Empty( k006->los )
          fl := AScan( llos, AllTrim( k006->los ) ) > 0  // (k006->los $ llos)
          If fl
            j++
          Endif
        Endif
        If fl .and. !Empty( k006->ad_cr )  // � �ࠢ�筨�� ���� ���.���਩
          fl := .f.
          If !Empty( lad_cr )        // � ��砥 ���� ���.���਩
            fl := ( lad_cr == AllTrim( k006->ad_cr ) )
            If fl
              j++
            Endif
          Endif
        Endif
        If fl .and. !Empty( k006->ad_cr1 )  // � �ࠢ�筨�� ���� ���.���਩2
          fl := .f.
          If !Empty( lad_cr1 )        // � ��砥 ���� ���.���਩2
            fl := ( lad_cr1 == AllTrim( k006->ad_cr1 ) )
            If fl
              j++
            Endif
          Endif
        Endif
        If fl .and. !Empty( sds1 )
          fl := .f.
          For i := 1 To Len( sop_diag )
            If AllTrim( sop_diag[ i ] ) $ sds1
              fl := .t.
              Exit
            Endif
          Next
          If fl
            j++
          Endif
        Endif
        If fl .and. !Empty( sds2 )
          fl := .f.
          For i := 1 To Len( osl_diag )
            If AllTrim( osl_diag[ i ] ) $ sds2
              fl := .t.
              Exit
            Endif
          Next
          If fl
            j++
          Endif
        Endif
        If fl
          AAdd( _a1, { k006->shifr, ; // 1
          0, ;           // 2
            lkoef, ;       // 3
          &lal.->kiros, ; // 4
          k006->ds, ;    // 5
          lshifr, ;      // 6
          k006->age, ;   // 7
          k006->sex, ;   // 8
          k006->los, ;   // 9
          k006->ad_cr, ; // 10
          sds1, ;        // 11
          sds2, ;        // 12
          j, ;           // 13
            &lal.->kslps, ; // 14
          k006->ad_cr1 } ) // 15
        Endif
        Select K006
        Skip
      Enddo
      If Len( _a1 ) > 1 // �᫨ �� ������ ��㣥 ����� ����� ���, ����㥬 �� �뢠��� ���ਥ�
        ASort( _a1, , , {| x, y| iif( x[ 13 ] == y[ 13 ], x[ 3 ] > y[ 3 ], x[ 13 ] > y[ 13 ] ) } )
      Endif
      If Len( _a1 ) > 0
        AAdd( ar, AClone( _a1[ 1 ] ) )
      Endif
    Endif
  Next
  If Len( ar ) > 0
    For i := 1 To Len( ar )
      ar[ i, 2 ] := ret_cena_ksg( ar[ i, 1 ], lvr, date_usl )
      If ar[ i, 2 ] > 0
        fl_cena := .t.
      Endif
    Next
    aHirKSG := AClone( ar )
    If Len( aHirKSG ) > 1
      ASort( aHirKSG, , , {| x, y| iif( x[ 3 ] == y[ 3 ], x[ 13 ] > y[ 13 ], x[ 3 ] > y[ 3 ] ) } )
    Endif
    /*aadd(ars, '   ����: ' +print_array(aHirKSG[1]))
    for j := 2 to len(aHirKSG)
      aadd(ars, '   �     ' +print_array(aHirKSG[j]))
    next*/
    If ( kol_hir := f_put_debug_ksg( 0, aHirKSG, ars ) ) > 1
      AAdd( ars, ' ��> �롨ࠥ� ���=' + RTrim( aHirKSG[ 1, 1 ] ) + ' [��=' + lstr( aHirKSG[ 1, 3 ] ) + ']' )
    Endif
  Endif
  If kol_ter > 0 .and. kol_hir > 0
    aTerKSG[ 1, 1 ] := AllTrim( aTerKSG[ 1, 1 ] )
    aHirKSG[ 1, 1 ] := AllTrim( aHirKSG[ 1, 1 ] )
    // i := int(val(substr(aTerKSG[1,1],2,3)))
    // j := int(val(substr(aHirKSG[1,1],2,3)))
    If !Empty( aTerKSG[ 1, 6 ] ) // �.�. ������� + ��㣠
      lksg  := aTerKSG[ 1, 1 ]
      lcena := aTerKSG[ 1, 2 ]
      lkiro := list2arr( aTerKSG[ 1, 4 ] )
      lkslp := aTerKSG[ 1, 14 ]
      AAdd( ars, ' �롨ࠥ� ���=' + lksg + ' (��.�������+��㣠 ' + RTrim( aTerKSG[ 1, 6 ] ) + ')' )
      // elseif ascan(a_iskl_1, {|x| x[1]==j .and. eq_any(x[2],0,i) .and. lusl==x[3] }) > 0 // �᪫�祭�� �� �ࠢ�� �1
    Elseif AScan( a_iskl_1, {| x| x[ 1 ] == aHirKSG[ 1, 1 ] .and. ( Empty( x[ 2 ] ) .or. x[ 2 ] == aTerKSG[ 1, 1 ] ) } ) > 0 // �᪫�祭�� �� �ࠢ�� �1
      lksg  := aHirKSG[ 1, 1 ]
      lcena := aHirKSG[ 1, 2 ]
      lkiro := list2arr( aHirKSG[ 1, 4 ] )
      lkslp := aHirKSG[ 1, 14 ]
      AAdd( ars, ' � ᮮ⢥��⢨� � ����������� �� ��� �롨ࠥ� ' + aHirKSG[ 1, 1 ] + ' ����� ' + aTerKSG[ 1, 1 ] )
    Else
      If aTerKSG[ 1, 3 ] > aHirKSG[ 1, 3 ] // '�᫨ ����.�� ����� �࠯����᪮�� ��'
        lksg  := aTerKSG[ 1, 1 ]
        lcena := aTerKSG[ 1, 2 ]
        lkiro := list2arr( aTerKSG[ 1, 4 ] )
        lkslp := aTerKSG[ 1, 14 ]
        AAdd( ars, ' �롨ࠥ� ��� =' + aTerKSG[ 1, 1 ] + ' � ������� �����樥�⮬ �����񬪮�� ' + lstr( aTerKSG[ 1, 3 ] ) )
      Else
        lksg  := aHirKSG[ 1, 1 ]
        lcena := aHirKSG[ 1, 2 ]
        lkiro := list2arr( aHirKSG[ 1, 4 ] )
        lkslp := aHirKSG[ 1, 14 ]
        AAdd( ars, ' ��⠢�塞 ���=' + aHirKSG[ 1, 1 ] + ' � �����樥�⮬ �����񬪮�� ' + lstr( aHirKSG[ 1, 3 ] ) )
      Endif
    Endif
  Elseif kol_ter > 0
    aTerKSG[ 1, 1 ] := AllTrim( aTerKSG[ 1, 1 ] )
    lksg  := aTerKSG[ 1, 1 ]
    lcena := aTerKSG[ 1, 2 ]
    lkiro := list2arr( aTerKSG[ 1, 4 ] )
    lkslp := aTerKSG[ 1, 14 ]
  Elseif kol_hir > 0
    aHirKSG[ 1, 1 ] := AllTrim( aHirKSG[ 1, 1 ] )
    lksg  := aHirKSG[ 1, 1 ]
    lcena := aHirKSG[ 1, 2 ]
    lkiro := list2arr( aHirKSG[ 1, 4 ] )
    lkslp := aHirKSG[ 1, 14 ]
  Endif
  akslp := {}
  akiro := {}
  If lksg == 'ds18.001' .and. s_dializ > 0
    lksg := ''
  Endif
  If !Empty( lksg )
    s := ' ���������: ��࠭� ��� = ' + lksg
    If Empty( lcena )
      s += ', �� �� ��।����� 業� � �ࠢ�筨�� �����'
      AAdd( arerr, s )
    Else
      s += ', 業� ' + lstr( lcena, 11, 0 ) + '�. '
      AAdd( ars, s )
      s := ''
      If lksg == 'st38.001' .and. lbartell == '61' // ����᪠� ��⥭�� (�� �ࠢ��� 㦥 ���५� � �� �ਬ������)
        lkslp := ''                                // �.�. � ������ ��� ��� ����
      Endif

      // 06.02.21
      If ( Year( lk_data ) >= 2021 ) .and. ( Lower( SubStr( lksg, 1, 2 ) ) == 'st' .or. Lower( SubStr( lksg, 1, 2 ) ) == 'ds' )
        If !Empty( HUMAN_2->PC1 )
          humKSLP := HUMAN_2->PC1
        Endif
        // ����७�� � ��୮��䨨
        // if Upper(ProcName(1)) == Upper('f_1pac_definition_KSG') .and. ! empty(lkslp)
        If Upper( ProcName( 1 ) ) == Upper( 'f_1pac_definition_KSG' )
          If ! Empty( lkslp )   // 24.02.21
            lkslp := selectkslp( lkslp, humKSLP, ln_data, lk_data, ldate_r, mdiagnoz )
          Endif
          // �������� ����
          tmSel := Select( 'HUMAN_2' )
          If ( tmSel )->( dbRLock() )
            // G_RLock(forever)
            // HUMAN_2->PC1 := m1KSLP
            HUMAN_2->PC1 := lkslp
            ( tmSel )->( dbRUnlock() )
          Endif
          Select( tmSel )
        Else
          lkslp := humKSLP
        Endif
      Endif

      // lkslp - ᮤ�ন� ᯨ᮪ �����⨬�� ����
      akslp := f_cena_kslp( @lcena, ;
        lksg, ;
        ldate_r, ;
        ln_data, ;
        lk_data, ;
        lkslp, ;
        amohu, ;
        lprofil_k, ;
        mdiagnoz, ;
        lpar_org, ;
        lad_cr )
      If Year( lk_data ) >= 2021  // added 29.01.21
        If !Empty( akslp )
          For iKSLP := 1 To Len( akslp ) Step 2
            If iKSLP != 1
              newKSLP += ', '
            Endif
            newKSLP += Str( akslp[ iKSLP ] ) // ����ந� ���� ����
          Next
        Else
          newKSLP := ''
        Endif
        tmSel := Select( 'HUMAN_2' )
        If ( tmSel )->( dbRLock() )
          human_2->pc1 := newKSLP
        Endif
        ( tmSel )->( dbRUnlock() )
      Endif
      If !Empty( akslp )
        // 05.02.21
        s += '  (���� = '
        For iKSLP := 1 To Len( akslp ) Step 2
          If iKSLP != 1
            s += ' + '
          Endif
          s += Str( akslp[ iKSLP + 1 ], 4, 2 )
        Next
        s += ', 業� ' + lstr( lcena, 11, 0 ) + '�.)'
      Endif
      If !Empty( lkiro )
        vkiro := defenition_kiro( lkiro, ldnej, lrslt, lis_err, lksg, lDoubleSluch, lk_data )

        If vkiro > 0
          akiro := f_cena_kiro( @lcena, vkiro, lk_data )
          s += '  (���� = ' + Str( akiro[ 2 ], 4, 2 ) + ', 業� ' + lstr( lcena, 11, 0 ) + '�.)'
        Endif
      Endif
      If !Empty( s )
        AAdd( ars, s )
      Endif
    Endif
  Else
    If lusl == 2 .and. s_dializ > 0
      Return { {}, {}, '', 0, {}, {}, s_dializ }
    Else
      AAdd( arerr, ' ���������: �� ����稫��� ����� ���' + iif( fl_reabil, ' ��� ���� ����樭᪮� ॠ�����樨', '' ) )
    Endif
  Endif

  Return { ars, arerr, AllTrim( lksg ), lcena, akslp, akiro, s_dializ }
// 1     2        3            4      5      6        7

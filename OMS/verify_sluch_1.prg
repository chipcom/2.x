#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

#define BASE_ISHOD_RZD 500  //

// 21.03.25
Function verify_sluch( fl_view )

  local dBegin  // ��� ��砫� ����
  local dEnd    // ��� ����砭�� ����
  local cd1, cd2, ym2
  local yearBegin // ��� ���� ��砫� ����
  local yearEnd // ��� ���� ����砭�� ����
  Local _ocenka := 5, ta := {}, u_other := {}, ssumma := 0, auet, fl, lshifr1, ;
    i, j, k, c, s := ' ', a_srok_lech := {}, a_period_stac := {}, a_disp := {}, ;
    a_period_amb := {}, a_1_11, u_1_stom := '', lprofil, ;
    lbukva, lst, lidsp, a_idsp := {}, a_bukva := {}, t_arr[ 2 ], ltip, lkol, ;
    a_dializ := {}, is_2_88 := .f., a_rec_ffoms := {}, arr_povod := {}, mpovod := 0, ;
    lal, lalf
  Local reserveKSG_1 := .f., reserveKSG_2 := .f.
  Local sbase
  Local arr_uslugi_geriatr := { 'B01.007.001', 'B01.007.003', 'B01.007.003' }, row, rowTmp
  Local flGeriatr := .f.
  Local arrV018, arrV019
  Local arrImplant
  Local arrLekPreparat, arrGroupPrep, mMNN
  Local flLekPreparat := .f.
  Local arrUslugi := {} // ���ᨢ ᮤ�ঠ訩 ���� ��� � ��砥 
  Local lTypeLUMedReab := .f.
  Local aUslMedReab
  Local obyaz_uslugi_med_reab, iUsluga
  Local lTypeLUOnkoDisp := .f.
  Local lDoubleSluch := .f.
  Local iVMP
  Local aDiagnoze_for_check := {}
  Local fl_zolend := .f.
  Local header_error := ''
  Local vozrast, lu_type
  Local kol_dney  // ������⢮ ���� ��祭��
//  Local is_2_92_ := .f., kol_2_93_1 := 0  // 誮�� ������, ���쬮 12-20-154 �� 28.04.23
  Local is_2_92_ := .f. // ����稥 ��� 誮� ��୮�� ������ ��� ����
  Local shifr_2_92 := ''  // ��� ��㣨 �� ��㯯� 誮� ������ � ����
  Local kol_2_93_1 := 0  // ���-�� ��� 誮�� ������, ���쬮 12-20-154 �� 28.04.23
  Local kol_2_93_2 := 0 // ���-�� ��� 誮�� ������ ����, ���쬮 12-20-313 �� 09.06.25

  Local l_mdiagnoz_fill := .f.  // � ���ᨢ� ��������� ���� ������
  Local i_n009, aN009 := getn009()
  Local i_n012, aN012_DS := getds_n012(), ar_N012 := {}, it
  Local aN021, l_n021
  Local usl_found := .f.
  local cuch_doc, gnot_disp, gkod_diag, gusl_ok
  local counter, arr_lfk
  local mPCEL := ''
  local info_disp_nabl := 0, ldate_next
  local s_lek_pr
  local iFind, aCheck, cUsluga, iCount
  local arrPZ

  Default fl_view To .t.

  If Empty( human->k_data )
    Return .t.  // �� �஢�����
  Endif
  
  Private mdate_r := human->date_r, mvozrast, mdvozrast, M1VZROS_REB := human->VZROS_REB, ;
    arr_usl_otkaz := {}, m1novor := 0, mpol := human->pol, mDATE_R2 := CToD( '' ), ;
    is_oncology := 0, is_oncology_smp := 0

  rec_human := human->( RecNo() )

  If human_->NOVOR > 0
    m1novor := 1 // ��� ��८�।������ M1VZROS_REB
    mDATE_R2 := human_->DATE_R2
    mpol := human_->POL2
  Endif

  fv_date_r( human->n_data ) // ��८�।������ M1VZROS_REB
  m1novor := human_->NOVOR // ��� ����� ����祭�� ��⥩ �� ������
  If M1VZROS_REB != human->VZROS_REB  // �᫨ ����୮,
    human->( g_rlock( forever ) )
    human->VZROS_REB := M1VZROS_REB   // � ��१����뢠��
    Unlock
  Endif

  // ��।��塞 ������, �᫨ 0 � ������ �� ����
  vozrast := count_years( iif( human_->NOVOR == 0, human->DATE_R, human_->DATE_R2 ), human->N_DATA )

  // ��⠭���� ����� �� �㦭�� ��०����� � �⤥�����
  uch->( dbGoto( human->LPU ) )
  otd->( dbGoto( human->OTD ) )
  lu_type := otd->TIPLU

  // �뢮��� ᮮ�饭�� � ������ ��ப�
  s := fam_i_o( human->fio ) + ' '
  If !Empty( otd->short_name )
    s += '[' + AllTrim( otd->short_name ) + '] '
  Endif
  s += date_8( human->n_data ) + '-' + date_8( human->k_data )
  @ MaxRow(), 0 Say PadR( ' ' + s, 50 ) Color 'G+/R'

  // ��������� ��� �뢮�� � ��⮪�� �訡��
  header_error := fio_plus_novor() + ' ' + AllTrim( human->kod_diag ) + ' ' + ;
    date_8( human->n_data ) + '-' + date_8( human->k_data ) + ;
    ' (' + count_ymd( human->date_r, human->n_data ) + ')' + hb_eol()
  header_error += AllTrim( uch->name ) + '/' + AllTrim( otd->name ) + '/��䨫� �� "' + ;
    AllTrim( inieditspr( A__MENUVERT, getv002(), human_->profil ) ) + '"'

  glob_kartotek := human->kod_k
  dBegin := human->n_data
  dEnd := human->k_data
  cd1 := dtoc4( dBegin )
  cd2 := dtoc4( dEnd )
  yearBegin := Year( dBegin )
  yearEnd := Year( dEnd )

  arrPZ := get_array_PZ( yearEnd )

  ym2 := Left( DToS( dEnd ), 6 )

  kol_dney := kol_dney_lecheniya( human->n_data, human->k_data, human_->usl_ok )
  cuch_doc := human->uch_doc

  // �஢�ઠ �� ��⠬
  If Year( human->date_r ) < 1900
    AAdd( ta, '��� ஦�����: ' + full_date( human->date_r ) + ' ( < 1900�.)' )
  Endif
  If human->date_r > human->n_data
    AAdd( ta, '��� ஦�����: ' + full_date( human->date_r ) + ;
      ' > ���� ��砫� ��祭��: ' + full_date( human->n_data ) )
  Endif
  If human->n_data > human->k_data
    AAdd( ta, '��� ��砫� ��祭��: ' + full_date( human->n_data ) + ;
      ' > ���� ����砭�� ��祭��: ' + full_date( human->k_data ) )
  Endif
  If yearEnd - yearBegin > 1
    AAdd( ta, '�६� ��祭�� ��⠢��� ' + lstr( human->k_data - human->n_data ) + ' ����' )
  Endif
  If human->k_data > sys_date
    AAdd( ta, '��� ����砭�� ��祭�� > ��⥬��� ����: ' + full_date( human->k_data ) )
  Endif
  If human_->NOVOR > 0
    If Empty( human_->DATE_R2 )
      AAdd( ta, '�� ������� ��� ஦����� ����஦�������' )
    Elseif human_->DATE_R2 > human->n_data
      AAdd( ta, '��� ஦����� ����஦�������: ' + full_date( human_->DATE_R2 ) + ' ����� ���� ��砫� ��祭��: ' + full_date( human->n_data ) )
    Elseif human->n_data - human_->DATE_R2 > 60
      AAdd( ta, '����஦������� ����� ���� ����楢' )
    Endif
  Endif

  If human_->usl_ok == USL_OK_POLYCLINIC
    s := '���㫠�୮� �����'
  Elseif human_->usl_ok == USL_OK_AMBULANCE // 4
    s := '����� �맮��'
  Else
    s := '���ਨ �������'
  Endif
  If Empty( CharRepl( '0', human->uch_doc, Space( 10 ) ) )
    AAdd( ta, '�� �������� ����� ' + s + ': ' + human->uch_doc )
  Else
    For i := 1 To Len( human->uch_doc )
      c := SubStr( human->uch_doc, i, 1 )
      If Between( c, '0', '9' )
        // ����,
      Elseif isletter( c )
        // �㪢� ���᪮�� � ��⨭᪮�� ��䠢��,
      Elseif Empty( c )
        // �஡��,
      Elseif eq_any( c, '.', '/', '\', '-', '|', '_', ' + ' )
        // �窠,��ਧ��⠫�� ࠧ����⥫�, ���⨪���� � �������� ࠧ����⥫�,������ ����ન�����, ���� ' + '
      Else
        AAdd( ta, '�������⨬� ᨬ��� "' + c + '" � ����� ' + s + ': ' + human->uch_doc )
      Endif
    Next
  Endif

  //
  // ��������� ��������
  //
  mdiagnoz := diag_to_array(, , , , .t. )
  If Len( mdiagnoz ) == 0 .or. Empty( mdiagnoz[ 1 ] )
    AAdd( ta, '�� ��������� ���� "�������� �������"' )
  Endif

  l_mdiagnoz_fill := ( Len( mdiagnoz ) > 0 )

  If l_mdiagnoz_fill
    If mdiagnoz[ 1 ] == 'Z00.2' .and. !( vozrast >= 1 .and. vozrast < 14 )
      AAdd( ta, '�᭮���� ������� Z00.2 �����⨬ ⮫쪮 ��� ������ �� ���� �� 14 ���' )
    Elseif mdiagnoz[ 1 ] == 'Z00.3' .and. !( vozrast >= 14 .and. vozrast < 18 )
      AAdd( ta, '�᭮���� ������� Z00.3 �����⨬ ⮫쪮 ��� ������ �� 14 �� 18 ���' )
    Elseif mdiagnoz[ 1 ] == 'Z00.1' .and. ( vozrast >= 1 )
      AAdd( ta, '�᭮���� ������� Z00.1 �����⨬ ⮫쪮 ��� ������ �� ����' )
    Endif
  Endif

  If glob_otd[ 4 ] != TIP_LU_DVN_COVID
    If Len( aDiagnoze_for_check := dublicate_diagnoze( fill_array_diagnoze() ) ) > 0
      For i := 1 To Len( aDiagnoze_for_check )
        AAdd( ta, 'ᮢ�����騩 ������� ' + aDiagnoze_for_check[ i, 2 ] + aDiagnoze_for_check[ i, 1 ] )
      Next
    Endif
  Endif

  If Select( 'MKB_10' ) == 0
    r_use( dir_exe() + '_mo_mkb', cur_dir + '_mo_mkb', 'MKB_10' )
  Endif
  Select MKB_10
  For i := 1 To Len( mdiagnoz )
    mdiagnoz[ i ] := PadR( mdiagnoz[ i ], 6 )
    find ( mdiagnoz[ i ] )
    If Found()
      If !Between( human->ishod, 101, 305 ) .and. i == 1 .and. !between_date( mkb_10->dbegin, mkb_10->dend, human->k_data )
        AAdd( ta, '�᭮���� ������� �� �室�� � ���' )
      Endif
      If !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
        AAdd( ta, '��ᮢ���⨬���� �������� �� ���� ' + AllTrim( mdiagnoz[ i ] ) )
      Endif
    Else
      AAdd( ta, '�� ������ ������� ' + AllTrim( mdiagnoz[ i ] ) + ' � �ࠢ�筨�� ���-10' )
    Endif
  Next
  mdiagnoz3 := {}
  If !Empty( human_2->OSL1 )
    AAdd( mdiagnoz3, human_2->OSL1 )
  Endif
  If !Empty( human_2->OSL2 )
    AAdd( mdiagnoz3, human_2->OSL2 )
  Endif
  If !Empty( human_2->OSL3 )
    AAdd( mdiagnoz3, human_2->OSL3 )
  Endif
  ar := {}
  Select MKB_10
  For i := 1 To Len( mdiagnoz3 )
    If Left( mdiagnoz3[ i ], 3 ) == 'R52'
      AAdd( ar, i )
    Endif
    mdiagnoz3[ i ] := PadR( mdiagnoz3[ i ], 6 )
    find ( mdiagnoz3[ i ] )
    If Found()
      If !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
        AAdd( ta, '��ᮢ���⨬���� �������� �� ���� ' + AllTrim( mdiagnoz3[ i ] ) )
      Endif
    Else
      AAdd( ta, '�� ������ ������� ' + AllTrim( mdiagnoz3[ i ] ) + ' � �ࠢ�筨�� ���-10' )
    Endif
  Next
  If human_->USL_OK == USL_OK_HOSPITAL ; // 1 - ��樮���
    .and. ( AScan( mdiagnoz, {| x| Left( x, 3 ) == 'P07' } ) > 0 .or. AScan( mdiagnoz3, {| x| Left( x, 3 ) == 'P07' } ) > 0 ) ;
      .and. mvozrast == 0 .and. human_2->VNR == 0
    AAdd( ta, '��� �������� P07.* �� 㪠��� ��� ������襭���� (������᭮��) ॡ񭪠' )
  Endif
  If mvozrast > 0 .and. l_mdiagnoz_fill .and. Left( mdiagnoz[ 1 ], 1 ) == 'P'
    AAdd( ta, '��� �᭮����� �������� ' + mdiagnoz[ 1 ] + ' ������ ������ ���� ����� ����' )
  Endif
  If l_mdiagnoz_fill .and. human_->USL_OK == USL_OK_HOSPITAL ; // 1 - ��樮���
    .and. ( mdiagnoz[ 1 ] = 'U07.1' .or. mdiagnoz[ 1 ] = 'U07.2' ) ;  // �஢�ਬ �� ������� COVID-19
    .and. Empty( HUMAN_2->PC4 ) ;                                 // ��� ���������
      .and. ( count_years( human->DATE_R, human->k_data ) >= 18 ) ;   // �஢�ਬ �� ������ ����� 18 ���
    .and. !check_diag_pregant()   // �஢�ਬ, �� �� ��६����
    AAdd( ta, '��� �������� U07.1 ��� U07.2 ��� �᫮��� ��樮��� �� 㪠��� ��� ��樥��' )
  Endif
  If !Empty( HUMAN_2->PC4 ) .and. Val( HUMAN_2->PC4 ) < 0.3
    AAdd( ta, '��� ��樥�� �� ����� ���� ����� 300 �ࠬ�' )
  Endif
  //
  //
  // ��������� ������������� ��������
  //
  If AScan( getvidud(), {| x | x[ 2 ] == kart_->vid_ud } ) == 0
    If human_->vpolis < 3
      AAdd( ta, '�� ��������� ���� "��� 㤮�⮢�७�� ��筮��"' )
    Endif
  Else
    If Empty( kart_->nom_ud )
      If human_->vpolis < 3
        AAdd( ta, '������ ���� ��������� ���� "����� 㤮�⮢�७�� ��筮��" ��� "' + ;
          inieditspr( A__MENUVERT, getvidud(), kart_->vid_ud ) + '"' )
      Endif
      // elseif !eq_any(kart_->vid_ud, 9, 18, 21, 24) .and. !ver_number(kart_->nom_ud)
      // aadd(ta, '���� '����� 㤮�⮢�७�� ��筮��' ������ ���� ��஢�')
    Endif
    If !Empty( kart_->nom_ud )
      s := Space( 80 )
      If !val_ud_nom( 2, kart_->vid_ud, kart_->nom_ud, @s )
        AAdd( ta, s )
      Endif
    Endif
    If eq_any( kart_->vid_ud, 1, 3, 14 ) .and. Empty( kart_->ser_ud )
      AAdd( ta, '�� ��������� ���� "����� 㤮�⮢�७�� ��筮��" ��� "' + ;
        inieditspr( A__MENUVERT, getvidud(), kart_->vid_ud ) + '"' )
    Endif
    If human_->usl_ok < USL_OK_AMBULANCE .and. eq_any( kart_->vid_ud, 3, 14 ) .and. ;
        !Empty( kart_->ser_ud ) .and. Empty( del_spec_symbol( kart_->mesto_r ) ) .and. human_->vpolis < 3
      AAdd( ta, iif( kart_->vid_ud == 3, '��� ᢨ�-�� � ஦�����', '��� ��ᯮ�� ��' ) + ;
        ' ��易⥫쭮 ���������� ���� "���� ஦�����"' )
    Endif
    If !Empty( kart_->ser_ud )
      s := Space( 80 )
      If !val_ud_ser( 2, kart_->vid_ud, kart_->ser_ud, @s )
        AAdd( ta, s )
      Endif
    Endif
    If human_->usl_ok < USL_OK_AMBULANCE .and. human_->vpolis < 3 .and. !eq_any( Left( human_->OKATO, 2 ), '  ', '18' ) // �����த���
      If Empty( kart_->kogdavyd )
        AAdd( ta, '��� �����த��� ��� ������ ����� ��易⥫쭮 ���������� ���� "��� �뤠� ���㬥��, 㤮�⮢����饣� ��筮���"' )
      Endif
      If Empty( kart_->kemvyd ) .or. ;
          Empty( del_spec_symbol( inieditspr( A__POPUPMENU, dir_server + 's_kemvyd', kart_->kemvyd ) ) )
        AAdd( ta, '��� �����த��� ��� ������ ����� ��易⥫쭮 ���������� ���� "������������ �࣠��, �뤠�襣� ���㬥��, 㤮�⮢����騩 ��筮���"' )
      Endif
    Endif
  Endif
  val_fio( retfamimot( 2, .f. ), ta )

//  Select HUMAN
//  Set Order To 1
//  dbGoto( rec_human )
//  g_rlock( forever )
  human_->( g_rlock( forever ) )
  human_2->( g_rlock( forever ) )

  //
  // �஢�ਬ ����� �ॡ뢠��� � ���
  //
  kart_->( g_rlock( forever ) )
  s := AllTrim( kart_->okatog )
  If mo_nodigit( s )
    AAdd( ta, '����஢� ᨬ���� � ����� ॣ����樨' )
  Endif
  If Len( s ) == 0
    If human_->vpolis < 3
      AAdd( ta, '�� �������� ��� ����� � ���� "���� ॣ����樨"' )
    Endif
  Elseif Len( s ) > 0 .and. Len( s ) < 11
    kart_->okatog := PadR( s, 11, '0' )
  Endif
  s := AllTrim( kart_->okatop )
  If mo_nodigit( s )
    AAdd( ta, '����஢� ᨬ���� � ����� �ॡ뢠���' )
  Endif
  If Len( s ) > 0 .and. Len( s ) < 11
    kart_->okatop := PadR( s, 11, '0' )
  Endif
  If !Empty( kart->snils )
    s := Space( 80 )
    If !val_snils( kart->snils, 2, @s )
      AAdd( ta, s + ' � ��樥��' )
    Endif
  Endif
  human_->SPOLIS := val_polis( human_->SPOLIS )
  human_->NPOLIS := val_polis( human_->NPOLIS )
  valid_sn_polis( human_->vpolis, human_->SPOLIS, human_->NPOLIS, ta, Between( human_->smo, '34001', '34007' ) )
  //
  If Select( 'SMO' ) == 0
    r_use( dir_exe() + '_mo_smo', cur_dir + '_mo_smo2', 'SMO' )
    // index on smo to (sbase+ '2')
  Endif
  Select SMO
  If AllTrim( human_->smo ) == '34'
    If Empty( human_->OKATO )
      AAdd( ta, '�� ����� ��ꥪ� ��, � ���஬ �����客�� ��樥��' )
    Elseif Empty( ret_inogsmo_name( 2 ) )
      AAdd( ta, '�� ������� �����த��� ���客�� ��������' )
    Endif
  Else
    Select SMO
    find ( human_->smo )
    If Found()
      human_->OKATO := smo->okato
    Else
      AAdd( ta, '�� ������� ��� � ����� "' + human_->smo + '"' )
    Endif
  Endif
  
  gnot_disp := ( human->ishod < 100 )
  gkod_diag := human->kod_diag
  gusl_ok := human_->usl_ok
  
  Private is_disp_19 := !( dEnd < 0d20190501 )
  Private is_disp_21 := !( dEnd < 0d20210101 )
  Private is_disp_24 := !( dEnd < 0d20240901 )


  arrUslugi := collect_uslugi( rec_human )   // �롥६ �� ���� ��� ����

  lTypeLUMedReab := ( otd->tiplu == TIP_LU_MED_REAB )
  lTypeLUOnkoDisp := ( otd->tiplu == TIP_LU_ONKO_DISP )

  If ! lTypeLUOnkoDisp
    is_oncology := f_is_oncology( 1, @is_oncology_smp )
  Endif
  //

  reserveKSG_1 := exist_reserve_ksg( human->kod, 'HUMAN', ( HUMAN->ishod == 89 .or. HUMAN->ishod == 88 ) )

  lal := create_name_alias( 'lusl', yearEnd )
  lalf := create_name_alias( 'luslf', yearEnd )
  //
  If gusl_ok == USL_OK_AMBULANCE // 4 - �᫨ '᪮�� ������'
    Select HUMAN
    Set Order To 3
    find ( DToS( dEnd ) + cuch_doc )
    Do While human->k_data == dEnd .and. cuch_doc == human->uch_doc .and. !Eof()
      fl := human_->usl_ok == USL_OK_AMBULANCE .and. glob_kartotek == human->kod_k .and. rec_human != human->( RecNo() )
      If fl .and. human->schet > 0 .and. eq_any( human_->oplata, 2, 9 )
        fl := .f. // ���� ���� ��� �� ���� ��� ���⠢��� ����୮
      Endif
      If fl
        AAdd( ta, '"' + AllTrim( cuch_doc ) + '" ����� � ����� �맮�� �� ' + ;
          date_8( human->k_data ) + ' ' + AllTrim( human->fio ) )
      Endif
      Skip
    Enddo
  Endif
  // ��ᬮ�� ��㣨� ��砥� ������� ���쭮��
  Select HUMAN
  Set Order To 2
  find ( Str( glob_kartotek, 7 ) )
  Do While human->kod_k == glob_kartotek .and. !Eof()
    fl := ( rec_human != human->( RecNo() ) .and. Year( human->k_data ) > 2019 ) // ���� ��� �� ᬮ�ਬ �����
    If fl .and. human->schet > 0 .and. eq_any( human_->oplata, 2, 9 )
      fl := .f. // ���� ���� ��� �� ���� (� ���⠢��� ����୮)
    Endif
    If fl .and. m1novor != human_->NOVOR
      fl := .f. // ���� ���� �� ����஦������� (��� �������)
    Endif
    If fl .and. gnot_disp .and. human->ishod < 100 ; // �᫨ �� ��ᯠ��ਧ���
      .and. gusl_ok == human_->usl_ok ; // �᫨ � �� �᫮��� �������� �����
      .and. !Empty( gkod_diag ) .and. Left( gkod_diag, 3 ) == Left( human->kod_diag, 3 )  // �� �� �᭮���� �������
      If ( k := dBegin - human->k_data ) >= 0 // � ��砩 ������ ࠭�� �஢��塞���
        If gusl_ok == USL_OK_AMBULANCE  // 4 - ᪮�� ������
          If k < 2
            AAdd( a_rec_ffoms, { human->( RecNo() ), 0, k } )
          Endif
        Else // �����������, ��㣫������ � ������� ��樮���
          If k < 31 // � �祭�� 30 ����
            AAdd( a_rec_ffoms, { human->( RecNo() ), 0, k } )
          Endif
        Endif
      Endif
    Endif
    // �᫨ �������� ��祭�� ��४�뢠���� � ��樮��� � ������� ��樮���
    If fl .and. eq_any( human_->USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL )

      reserveKSG_2 := exist_reserve_ksg( human->kod, 'HUMAN', ( HUMAN->ishod == 89 .or. HUMAN->ishod == 88 ) )

      fl1 := ( Left( DToS( human->k_data ), 6 ) == ym2 )   // ���� � �� �� ����� ����砭�� ��祭��
      fl2 := overlap_diapazon( human->n_data, human->k_data, dBegin, dEnd ) // ��४�뢠���� �������� ��祭��
      fl3 := .t.
      k := 0
      If is_alldializ .and. ( fl1 .or. fl2 ) .and. Year( human->k_data ) > 2018 // ���� ��� �� ᬮ�ਬ �����
        Select HU
        find ( Str( human->kod, 7 ) )
        Do While hu->kod == human->kod .and. !Eof()
          lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
          If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
            lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
            If Left( lshifr, 5 ) == '60.3.' .or. Left( lshifr, 6 ) == '60.10.' // ������
              If human_->USL_OK == USL_OK_DAY_HOSPITAL  // 2 - ������ � ������� ��樮���
                fl3 := .f.
                If fl1
                  k := 2
                Endif
              Elseif fl2 // ������ � ��樮���
                k := 1
              Endif
              Exit
            Endif
          Endif
          Select HU
          Skip
        Enddo
        If k > 1
          AAdd( a_dializ, { human->n_data, human->k_data, human_->USL_OK, human->OTD, k } ) // ������� �� � ��㣫.��樮���
        Endif
      Endif
      If k < 2 .and. fl2 .and. fl3 .and. iif( is_alldializ, Year( human->k_data ) > 2018, .t. ) .and. ! ( reserveKSG_1 .or. reserveKSG_2 ) // � ��⮬ ��������� ��������� ������� ��砥�
        AAdd( a_srok_lech, { human->n_data, human->k_data, human_->USL_OK, human->OTD, k } )
      Endif
    Endif
    // �᫨ �������� ��祭�� ���筮 ��४�뢠����
    If fl .and. human->n_data <= dEnd .and. dBegin <= human->k_data
      is_period_amb := .f.
      // ��樮���
      If human_->USL_OK == USL_OK_HOSPITAL  // 1
        AAdd( a_period_stac, { human->n_data, ;
          human->k_data, ;
          human_->USL_OK, ;
          human->OTD, ;
          human->kod_diag, ;
          human_->profil, ;
          human_->RSLT_NEW, ;
          human_->ISHOD_NEW, ;
          k } )
        // �����������
      Elseif human_->USL_OK == USL_OK_POLYCLINIC .and. human->ishod < 101 ;
          .and. !( human_->profil == 60 .and. glob_mo[ _MO_KOD_TFOMS ] == '103001' ) // �� ���������
        is_period_amb := .t.
      Endif
      Select HU
      find ( Str( human->kod, 7 ) )
      Do While hu->kod == human->kod .and. !Eof()
        // �᫨ ��㣠 � ⮬ �� ��������� ��祭��
        If Between( hu->date_u, cd1, cd2 )
          AAdd( u_other, { hu->u_kod, hu->date_u, hu->kol_1, hu_->profil, 0, human->n_data, human->k_data, human->OTD } )
        Endif
        If is_period_amb
          lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
          If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
            lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
            If eq_any( Left( lshifr, 5 ), '2.80.', '2.82.', '60.4.', '60.5.', '60.6.', '60.7.', '60.8.', '60.9.' )
              is_period_amb := .f.
              Exit
              // elseif lshifr == '60.3.1' // ����.������
            Elseif eq_any( lshifr, '60.3.1', '60.3.12', '60.3.13' )  // 04.12.22
              AAdd( a_dializ, { human->n_data, human->k_data, human_->USL_OK, human->OTD, 3 } ) // ������� �� � ��㣫.��樮���
              Exit
            Endif
          Endif
        Endif
        Select HU
        Skip
      Enddo
      If is_period_amb
        AAdd( a_period_amb, { human->n_data, human->k_data, human_->profil, human->OTD, human->( RecNo() ) } )
      Endif
      Select MOHU
      find ( Str( human->kod, 7 ) )
      Do While mohu->kod == human->kod .and. !Eof()
        If Between( mohu->date_u, cd1, cd2 ) // ��㣠 � ⮬ �� ��������� ��祭��
          AAdd( u_other, { mohu->u_kod, mohu->date_u, mohu->kol_1, mohu->profil, 1 } )
        Endif
        Skip
      Enddo
    Endif
    // ��ᯠ��ਧ���/��䨫��⨪� ���᫮�� ��ᥫ����
    If fl .and. Between( human->ishod, 201, 205 )
      // �᫨ ��� ��砫� ⥪�饣� ��祭�� = ���� ��砫� ��諮�� ��祭��
      If Year( human->n_data ) == Year( dBegin ) // ��� ��ᯠ��ਧ�樨
        AAdd( a_disp, { human->ishod - 200, human->n_data, human->k_data, human_->RSLT_NEW } )
      Endif
      // ��� ��䨫��⨪�
      If human->ishod == 203 .and. count_years( human->date_r, human->n_data ) == mvozrast
        AAdd( a_disp, { human->ishod - 200, human->n_data, human->k_data, human_->RSLT_NEW } )
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  Select HUMAN
  Set Order To 1
  dbGoto( rec_human )
  g_rlock( forever )
  human_->( g_rlock( forever ) )
  human_2->( g_rlock( forever ) )
//  uch->( dbGoto( human->LPU ) )
//  otd->( dbGoto( human->OTD ) )

  If Year( human->k_data ) == 2022 .and. !Empty( HUMAN_2->PC1 )
    If AllTrim( human_2->PC1 ) == '2' // ���� 2 - ���� ��������� �।�⠢�⥫� ��� 2022 ����
      If human_->PROFIL != 12 .and. human_->PROFIL != 18  // �����⨬� ��� ��䨫�� '����⮫����' � '���᪠� ���������'
        AAdd( ta, '��� ��࠭���� ���� = 2, ��䨫� �������� ��� ������ ���� ��� "����⮫����" ��� "���᪠� ���������"' )
      Endif
    Endif
  Endif

  If Year( human->k_data ) == 2022 .and. !Empty( HUMAN_2->PC1 )
    If AllTrim( human_2->PC1 ) == '3' // ���� 3 - ���� 75 ��� ��� 2022 ����
      For Each row in arr_uslugi_geriatr
        If AScan( arrUslugi, row ) > 0 // �஢�ਬ �� ��㣨 ����
          flGeriatr := .t.
        Endif
      Next
      If !flGeriatr
        AAdd( ta, '��� ��࠭���� ���� = 3, � ᯨ᪥ ��� ��� ���� ����室��� ����稥 ����� �� ��� B01.007.001, B01.007.002 ��� B01.007.003' )
      Endif
    Endif
  Endif

  s := ''
  If l_mdiagnoz_fill .and. f_oms_beremenn( mdiagnoz[ 1 ], human->k_data ) == 3 .and. Between( human_2->pn2, 1, 4 )
    s := 'R52.' + { '0', '1', '2', '9' }[ human_2->pn2 ]
  Endif
  If !emptyall( s, ar )
    If Empty( ar )
      human_2->OSL3 := s
    Else
      fl := .t.
      For i := 3 To 1 Step -1
        pole := 'human_2->OSL' + lstr( i )
        If Left( &pole, 3 ) == 'R52'
          If fl
            fl := .f.
            If !( AllTrim( pole ) == s )
              &pole := s  // ᠬ� ��᫥���� - ��१���襬
            Endif
          Else
            &pole := ''   // ��⠫�� - ���⨬
          Endif
        Endif
      Next
    Endif
  Endif

  //
  d := human->k_data - human->n_data
  adiag := {}
  kkd := kds := kvp := kuet := kkt := ksmp := 0
  mpztip := mpzkol := kol_uet := 0
  kkd_1_11 := kkd_1_12 := kol_ksg := 0
  is_reabil := is_dializ := is_perito := is_s_dializ := is_eko := fl_stom := fl_dop_ob_em := .f.
  If is_dop_ob_em
    fl_dop_ob_em := ( human->reg_lech == 9 )
  Endif
  au_lu := {} ; au_flu := {} ; au_lu_ne := {} ; arr_perso := {} ; arr_unit := {}
  arr_onkna := {} ; arr_mo_spec := {}
  m1dopo_na := m1napr_v_mo := m1napr_stac := m1profil_stac := m1napr_reab := m1profil_kojki := 0

  m1sank_na := 0
  mtab_v_dopo_na := mtab_v_mo := mtab_v_stac := mtab_v_reab := mtab_v_sanat := 0

  is_kt := is_mrt := is_uzi := is_endo := is_gisto := is_mgi := is_g_cit := is_pr_skr := is_covid := .f.
  is_71_1 := is_71_2 := is_71_3 := is_dom := .f.
  kvp_2_78 := kvp_2_79 := kvp_2_89 := kol_2_3 := kol_2_60 := kol_2_4 := kol_2_6 := kol_55_1 := 0
  kvp_70_5 := kvp_70_6 := kvp_70_3 := kvp_72_2 := kvp_72_3 := kvp_72_4 := 0
  is_2_78 := is_2_79 := is_2_80 := is_2_81 := is_2_82 := .f.
  is_2_83 := is_2_84 := is_2_85 := is_2_86 := is_2_87 := is_2_88 := is_2_89 := .f.
  a_2_89 := Array( 15 )
  AFill( a_2_89, 0 )
  is_disp_DDS := is_disp_DVN := is_disp_DVN3 := is_prof_PN := is_neonat := is_pren_diagn := .f.

  is_disp_DVN_COVID := .f.
  is_disp_DRZ := .f.
  is_exist_Prescription := .f.  // ������� ���� ���ࠢ����� ��� ��ᯠ��ਧ�権

  is_70_3 := is_70_5 := is_70_6 := is_72_2 := is_72_3 := is_72_4 := .f.
  lstkol := 0 ; lstshifr := shifr_ksg := '' ; cena_ksg := 0
  midsp := musl_ok := mRSLT_NEW := mprofil := mvrach := m1lis := 0
  lvidpoms := ''
  // ॠ������� - ��� 䨧�����୮�� ��ᯠ��� � ��㣨�
  arr_lfk := { '3.1.5', '3.1.19', '3.4.31', ;
    '4.2.153', '4.11.136', ;
    '7.12.5', '7.12.6', '7.12.7', '7.2.2', ;
    '13.1.1', ;
    '14.2.3', ;
    '16.1.17', '16.1.18', ;
    '19.1.1', '19.1.2', '19.1.3', '19.1.5', '19.1.6', '19.1.7', '19.1.9', '19.1.11', '19.1.12', '19.1.29', '19.1.30', '19.1.31', '19.1.32', '19.1.33', '19.1.34', '19.1.35', '19.1.36', '19.1.37', '19.1.38', ;
    '19.2.1', '19.2.2', '19.2.4', '19.2.5', '19.3.1', '19.5.1', '19.5.2', '19.5.19', '19.6.1', '19.6.2', '19.7.1', ;
    '19.3.1', ;
    '20.1.1', '20.1.2', '20.1.3', '20.1.4', '20.1.5', '20.1.6', '20.2.1', '20.2.2', '20.2.3', '20.2.4', ;
    '21.1.1', '21.1.2', '21.1.3', '21.1.4', '21.1.5', '21.2.1', ;
    '22.1.1', '22.1.2', '22.1.3' }
  //
  f_put_glob_podr( human_->USL_OK, dEnd, ta ) // ��������� ��� ���ࠧ�������
  musl_ok := USL_OK_POLYCLINIC  // 3 - �-�� �� 㬮�砭��
  ldnej := 0
  pr_amb_reab := .f.
  If human_->USL_OK < USL_OK_AMBULANCE  // �� ᪮�� ������
    Select HU
    find ( Str( human->kod, 7 ) )
    Do While hu->kod == human->kod .and. !Eof()
      lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
      If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
        lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
        If eq_any( Left( lshifr, 5 ), '1.11.', '55.1.' )
          ldnej += hu->kol_1
        Elseif Left( lshifr, 5 ) == '2.89.'
          pr_amb_reab := .t.
        Endif
      Endif
      Select HU
      Skip
    Enddo
  Endif
  // �஢�ਬ �� �⠯ �� �� 㣫㡫����� ��ᯠ��ਧ�樨 ��᫥ COVID
  // If eq_any( human->ishod, 401, 402 )
  If is_sluch_dispanser_COVID( human->ishod )
    is_disp_DVN_COVID := .t.
    is_exist_Prescription := .t.
  Endif

  // �஢�ਬ �� �⠯ �� �� ��ᯠ��ਧ�樨 ९த�⨢���� ���஢��
  // If eq_any( human->ishod, BASE_ISHOD_RZD + 1, BASE_ISHOD_RZD + 2 )
  If is_sluch_dispanser_DRZ( human->ishod )
    is_disp_DRZ := .t.
    is_exist_Prescription := .t.
  Endif

  d_sroks := ''

  Select HU
  find ( Str( human->kod, 7 ) )
  If ! Found()
    add_string( header_error )
    AAdd( ta, '��� ���� ��������� ᯨ᮪ ��������� ���' )
    For i := 1 To Len( ta )
      For j := 1 To perenos( t_arr, ta[ i ], 78 )
        If j == 1
          add_string( iif( i == 1, ' ', '- ' ) + t_arr[ j ] )
        Else
          add_string( PadL( AllTrim( t_arr[ j ] ), 80 ) )
        Endif
      Next
    Next
    Return .f.
  Endif

  lshifr := ''
  lshifr1 := ''
  Do While hu->kod == human->kod .and. !Eof()
    lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
    If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data, @auet, @lbukva, @lst, @lidsp, @s )
      If Empty( hu->kol_1 )
        AAdd( ta, '�� ��������� ���� "������⢮ ���" ��� "' + AllTrim( usl->shifr ) + '"' )
      Endif
      lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
      If hu->STOIM_1 > 0 .or. lTypeLUOnkoDisp .or. Left( lshifr, 3 ) == '71.'  // ᪮�� ������
        If !Empty( lbukva ) .and. AScan( a_bukva, {| x| x[ 1 ] == lbukva } ) == 0
          AAdd( a_bukva, { lbukva, lshifr } )
        Endif
        If !Empty( lidsp ) .and. AScan( a_idsp, {| x| x[ 1 ] == lidsp } ) == 0
          AAdd( a_idsp, { lidsp, lshifr } )
        Endif
      Endif
      If lst == 1
        k := 0 ; lstshifr := '' ; lstkol := hu->kol_1
        For i := 1 To Len( lshifr )
          If !Empty( c := SubStr( lshifr, i, 1 ) )
            lstshifr += c
            If c == '.' ; ++k ; Endif
            If k == 2 ; exit ; Endif // ��� �窨 � ��� ��㣨
          Endif
        Next
      Endif
      otd->( dbGoto( hu->OTD ) )
      hu->( g_rlock( forever ) )
      hu_->( g_rlock( forever ) )
      If hu->is_edit == -1 .and. AllTrim( lshifr ) == '4.27.2'
        hu->is_edit := 0 // ��ࠢ����� ��砫쭮� �訡��
      Elseif hu->is_edit == 0 .and. is_lab_usluga( lshifr )
        hu->is_edit := -1
        hu->kod_vr := hu->kod_as := 0
        lprofil := iif( Left( lshifr, 5 ) == '4.16.', 6, 34 )
        If Select( 'MOPROF' ) == 0
          r_use( dir_exe() + '_mo_prof', cur_dir + '_mo_prof', 'MOPROF' )
          // index on shifr+ str(vzros_reb, 1) + str(profil, 3) to (sbase)
        Endif
        Select MOPROF
        find ( PadR( lshifr, 20 ) + Str( iif( human->vzros_reb == 0, 0, 1 ), 1 ) )
        If Found()
          lprofil := moprof->profil
        Endif
        hu_->profil := lprofil
      Endif
      // if left(lshifr, 5) == '60.8.' .and. hb_main_curOrg:Kod_Tfoms != '805903'
      If Left( lshifr, 5 ) == '60.8.' .and. ! is_volgamedlab()
        hu_->profil := 15   // ���⮫���� �� �᪫�祭�� "�����������"
        mprvs := hu_->PRVS := -13 // ������᪠� ������ୠ� �������⨪�
      Elseif Empty( hu->kod_vr )
        If eq_any( AllTrim( lshifr ), '4.20.2' )
          // �� ���������� ��� ���
        Elseif pr_amb_reab .and. Left( lshifr, 2 ) == '4.' .and. ( Left( hu_->zf, 6 ) == '999999' .or. Left( hu_->zf, 6 ) != glob_mo[ _MO_KOD_TFOMS ] )
          // �� ���������� ��� ���
        Elseif hu->is_edit == -1
          If human_->USL_OK == USL_OK_POLYCLINIC
            hu_->PRVS := iif( hu_->profil == 34, -13, -54 )
          Else
            AAdd( ta, '������ୠ� ��㣠 "' + AllTrim( usl->shifr ) + '" ����� ���� ������� ⮫쪮 � �����������' )
          Endif
        Elseif hu->is_edit == 0 .and. ( ! is_disp_DVN_COVID ) .and. ( ! is_disp_DRZ ) // ��ࠢ���� ��� 㣫㡫����� ��ᯠ��ਧ�樨 � ���
          AAdd( ta, '�� ��������� ���� "���, ������訩 ���� ' + AllTrim( usl->shifr ) + '"' )
        Endif
      Else
        If Empty( mvrach ) .and. !( AScan( kod_LIS, glob_mo[ _MO_KOD_TFOMS ] ) > 0 .and. eq_any( human_->profil, 6, 34 ) )
          mvrach := hu->kod_vr
        Endif
        pers->( dbGoto( hu->kod_vr ) )
        mprvs := -ret_new_spec( pers->prvs, pers->prvs_new )
        If Empty( mprvs ) .and. ( ! is_disp_DVN_COVID ) .and. ( ! is_disp_DRZ ) // ��ࠢ���� ��� 㣫㡫����� ��ᯠ��ਧ�樨 � ���
          AAdd( ta, '��� ᯥ樠�쭮�� � �ࠢ�筨�� ���ᮭ��� � "' + AllTrim( pers->fio ) + '"' )
        Elseif hu_->PRVS != mprvs
          hu_->PRVS := mprvs
        Endif
        If hu_->PRVS > 0 .and. ret_v004_v015( hu_->PRVS ) == 0
          AAdd( ta, '�� ������� ᯥ樠�쭮�� � �ࠢ�筨�� V015 � "' + AllTrim( pers->fio ) + '"' )
        Endif
        If AllTrim( lshifr ) == '1.11.1' .and. human_->profil == 28 .and. human_2->profil_k == 24
          // ��䨫� '��䥪樮��� �������' � ��䨫� ����� '��䥪樮���'
        Else // �஢��塞 �� ᯥ樠�쭮���
          uslugaaccordanceprvs( lshifr, human->vzros_reb, hu_->prvs, ta, usl->shifr, hu->kod_vr )
        Endif
      Endif
      If Empty( mprofil )
        mprofil := usl->profil
        If Empty( mprofil )
          mprofil := hu_->profil
        Endif
      Endif
      If Empty( hu_->profil )
        hu_->profil := usl->profil
        If Empty( hu_->profil )
          hu_->profil := otd->profil
        Endif
      Endif
      If hu_->profil > 0 .and. hu_->profil != correct_profil( hu_->profil )
        hu_->profil := correct_profil( hu_->profil )
      Endif
      If !valid_guid( hu_->ID_U )
        hu_->ID_U := mo_guid( 3, hu_->( RecNo() ) )
      Endif
      mdate := c4tod( hu->date_u )

      If !Empty( hu->kod_vr ) .and. mdate >= human->n_data
        arr_perso := addkoddoctortoarray( arr_perso, hu->kod_vr )
      Endif

      mdate_u1 := dtoc4( human->n_data )
      mdate_u2 := hu->date_u
      alltrim_lshifr := AllTrim( lshifr )
      left_lshifr_2 := Left( lshifr, 2 )
      left_lshifr_3 := Left( lshifr, 3 )
      left_lshifr_4 := Left( lshifr, 4 )
      left_lshifr_5 := Left( lshifr, 5 )
      If hu->kol_1 > 1 .and. AScan( arr_lfk, alltrim_lshifr ) > 0
        mdate_u2 := dtoc4( mdate + hu->kol_1 - 1 )
      Endif
      // �஢��塞 �� ��䨫�
      lprofil := uslugaaccordanceprofil( lshifr, human->vzros_reb, hu_->profil, ta, usl->shifr )
      If human_->USL_OK == USL_OK_AMBULANCE .and. lprofil != hu_->profil
        hu_->profil := lprofil
      Endif
      dbSelectArea( lal )
      find ( PadR( lshifr, 10 ) )
      If Found() .and. !Empty( &lal.->unit_code ) .and. AScan( arr_unit, &lal.->unit_code ) == 0
        AAdd( arr_unit, &lal.->unit_code )
      Endif
      AAdd( au_lu, { lshifr, ;    // 1 ��� ��㣨
        mdate, ;                  // 2 ��� �।��⠢�����
        hu_->profil, ;            // 3 ��䨫� ��㣨
        hu_->PRVS, ;              // 4 ��� ᯥ樠�쭮�� ���
        AllTrim( usl->shifr ), ;  // 5
        hu->kol_1, ;              // 6 ������⢮ �।��⠢�����
        c4tod( mdate_u2 ), ;      // 7
        hu_->kod_diag, ;          // 8
        hu->( RecNo() ), ;        // 9 - ����� �����
        hu->is_edit, ;            // 10
        hu_->date_end  } )        // 11 - ��� ����砭�� �।��⠢����� ��㣨
      kodKSG := ''
      If is_ksg( lshifr )
        If !Empty( s ) .and. ',' $ s
          lvidpoms := s
        Endif
        shifr_ksg := kodKSG := alltrim_lshifr
        cena_ksg := hu->u_cena
        If SubStr( kodKSG, 3, 2 ) == '37'
          is_reabil := .t.
        Elseif kodKSG == 'ds02.005'
          is_eko := .t.
        Endif
        kol_ksg += hu->kol_1
      Endif
      If !Empty( kodKSG ) // ���
        If Left( kodKSG, 2 ) == 'st'
          musl_ok := USL_OK_HOSPITAL  // 1 - ��樮���
          midsp := 33
        Else
          musl_ok := USL_OK_DAY_HOSPITAL  // 2 - ������� ��樮���
          midsp := 33
        Endif
        mdate_u2 := dtoc4( human->k_data )
      Elseif left_lshifr_2 == '1.'
        musl_ok := USL_OK_HOSPITAL  // 1 - ��樮���
        mdate_u2 := dtoc4( human->k_data )
        If left_lshifr_5 == '1.11.'
          kkd += hu->kol_1
          kkd_1_11 += hu->kol_1
          hu_->PZKOL := hu->kol_1
          If mdate + hu->kol_1 <= dEnd
            mdate_u2 := dtoc4( mdate + hu->kol_1 )
          Endif
        Else
          If left_lshifr_5 == code_services_vmp( yearEnd )
            midsp := 18 // �����祭�� ��砩 � ��㣫����筮� ��樮���
            kkd_1_12 += hu->kol_1
            kol_ksg += hu->kol_1
            hu_->PZKOL := d
            If ! value_public_is_vmp( yearEnd )
              AAdd( ta, 'ࠡ�� � ��㣮� ' + alltrim_lshifr + ' ����饭� � ��襩 ��' )
            Endif
          Endif
        Endif
        hu_->PZTIP := 1
      Elseif left_lshifr_3 == '55.'
        musl_ok := USL_OK_DAY_HOSPITAL  // 2  // ��.��樮���
        mdate_u2 := dtoc4( human->k_data )
        If left_lshifr_5 == '55.1.' // ���-�� ��樥��-����
          kds += hu->kol_1
          kol_55_1 += hu->kol_1
          hu_->PZKOL := hu->kol_1
          If mdate + hu->kol_1 - 1 <= dEnd
            mdate_u2 := dtoc4( mdate + hu->kol_1 - 1 )
          Endif
        Else
          // �訡��
        Endif
        hu_->PZTIP := 2
      Elseif alltrim_lshifr == '56.1.723' .and. human->ishod == 202 .and. !is_disp_19 // ��ன �⠯ ��� - ���� ��㣠
        is_disp_DVN := .t.
        is_exist_Prescription := .t.
      elseif eq_any( alltrim_lshifr, '7.2.706', '7.57.704', '7.61.704' ) // ��㣨 � �ਬ������� ��
        mpovod := 7 // 2.3-�������᭮� ��᫥�������
        mIDSP := 28 // �� ����樭��� ����
      Elseif eq_any( left_lshifr_5, '60.4.', '60.5.', '60.6.', '60.7.', '60.8.', '60.9.' ) .or. ;
          eq_any( alltrim_lshifr, '4.20.702', '4.15.746' ) // ���
        If alltrim_lshifr == '4.15.746' // �७�⠫�� �ਭ���
          mpovod := 1 // 1.0-���饭�� �� �����������
        Else
          mpovod := 7 // 2.3-�������᭮� ��᫥�������
        Endif
        mIDSP := 4 // ��祡��-���������᪠� ��楤�� 
        kkt += hu->kol_1
        hu_->PZTIP := 5
        hu_->PZKOL := hu->kol_1
        musl_ok := USL_OK_POLYCLINIC  // 3 - �-��
        If left_lshifr_5 == '60.4.'
          is_kt := .t.
        Elseif left_lshifr_5 == '60.5.'
          is_mrt := .t.
        Elseif left_lshifr_5 == '60.6.'
          is_uzi := .t.
        Elseif left_lshifr_5 == '60.7.'
          is_endo := .t.
        Elseif left_lshifr_5 == '60.8.'
          is_gisto := .t.
        Elseif left_lshifr_5 == '60.9.'
          is_mgi := .t.
          shifr_mgi := alltrim_lshifr
        Elseif alltrim_lshifr == '4.20.702'
          is_g_cit := .t.
        Elseif alltrim_lshifr == '4.15.746'
          is_pr_skr := .t.
        Endif
      Elseif left_lshifr_5 == '60.3.' .or. left_lshifr_5 == '60.10'// ������
        mIDSP := 4 // ��祡��-���������᪠� ��楤��
        kkt += hu->kol_1
        hu_->PZTIP := 5
        hu_->PZKOL := hu->kol_1
        mdate_u2 := dtoc4( human->k_data )
        If eq_any( alltrim_lshifr, '60.3.1', '60.3.12', '60.3.13' )  // 04.12.22
          mpovod := 10 // 3.0
          musl_ok := USL_OK_POLYCLINIC  // 3 - �-��
          is_perito := .t.
        Elseif eq_any( alltrim_lshifr, '60.3.9', '60.3.10', '60.3.11' ) // 01.12.21
          musl_ok := USL_OK_DAY_HOSPITAL  // 2 - ������� ��樮���
          is_dializ := .t.
        ElseIf eq_any( alltrim_lshifr, '60.3.19', '60.3.20', '60.3.21' )  // 16.02.24
          mpovod := 10 // 3.0
          musl_ok := USL_OK_POLYCLINIC  // 3 - �-��
          is_dializ := .t.
        Else
          musl_ok := USL_OK_HOSPITAL  // 1 - ��樮���
          is_s_dializ := .t.
        Endif
      Elseif eq_any( left_lshifr_5, '71.1.', '71.2.', '71.3.' )  // ᪮�� ������
        musl_ok := USL_OK_AMBULANCE // 4 - ���
        mIDSP := 24 // �맮� ᪮ன ����樭᪮� �����
        If left_lshifr_5 == '71.1.'
          is_71_1 := .t.
        Elseif left_lshifr_5 == '71.2.'
          is_71_2 := .t.
        Else
          is_71_3 := .t.
        Endif
        hu_->PZTIP := 6
        hu_->PZKOL := hu->kol_1
        ksmp += hu->kol_1
      Elseif left_lshifr_2 == '4.'
        If left_lshifr_5 == '4.26.'
          is_neonat := .t.
        Endif
        If alltrim_lshifr == '4.17.785' // �������୮-��������᪮� ��᫥������� ������ � ᫨���⮩ �����窨 ��ᮣ��⪨, �⮣��⪨ � �⤥�塞��� ���孨� ���⥫��� ��⥩ �� ���� ��஭������ COVID-19 (�� �᪫�祭��� ���-��⥬)
          is_covid := .t.
        Endif
        If eq_any( hu->is_edit, 1, 2 ) .and. dBegin <= c4tod( mdate_u2 )
          m1lis := hu->is_edit
        Endif
      Else
        musl_ok := USL_OK_POLYCLINIC  // 3 - �-��
        mIDSP := 1 // ���饭�� � �����������
        mpztip := 3
        mpzkol := hu->kol_1
        If hu->KOL_RCP < 0
          is_dom := .t.
        Endif
        If left_lshifr_4 == '2.3.'
          kol_2_3++
        Elseif left_lshifr_4 == '2.6.'
          kol_2_6++
        Elseif left_lshifr_5 == '2.60.'
          kol_2_60++
        Elseif eq_any( alltrim_lshifr, '2.4.1', '2.4.2' )
          kol_2_4++
        Elseif eq_any( alltrim_lshifr, '2.92.1', '2.92.2', '2.92.3' ) .or. ;
          eq_any( alltrim_lshifr, '2.92.4', '2.92.5', '2.92.6', '2.92.7', '2.92.8', '2.92.9', '2.92.10', '2.92.11', '2.92.12', '2.92.13' )
          is_2_92_ := .t.
          mpovod := 10 // 3.0
          If vozrast >= 18 .and. alltrim_lshifr == '2.92.3'
            AAdd( ta, '��㣠 2.92.3 ����뢠���� ⮫쪮 ���� ��� �����⪠�' )
          Elseif vozrast < 18 .and. eq_any( alltrim_lshifr, '2.92.1', '2.92.2' )
            AAdd( ta, '��㣠 ' + alltrim_lshifr + ' ����뢠���� ⮫쪮 �����' )
          Endif
        Elseif alltrim_lshifr == '2.93.1'
          kol_2_93_1++
        Elseif alltrim_lshifr == '2.93.2'
          kol_2_93_2++
        Elseif left_lshifr_5 == '2.76.'
          mpovod := 7 // 2.3
          mIDSP := 12 // �������᭠� ��㣠 業�� ���஢��
        Elseif left_lshifr_5 == '2.78.'
          mpovod := 10 // 3.0 ���饭�� �� �����������
          d_sroks := AfterAtNum( '.', alltrim_lshifr )
          If between_shifr( alltrim_lshifr, '2.78.54', '2.78.60' )
            fl_stom := .t.
            mpztip := 4
          Else
            ++kvp_2_78
            is_2_78 := .t.
            mIDSP := 17 // �����祭�� ��砩 � �����������
            If eq_any( alltrim_lshifr, '2.78.90', '2.78.91' ) .and. Len( mdiagnoz ) > 0 .and. Left( mdiagnoz[ 1 ], 1 ) == 'Z'
              mpovod := 11 // 3.1 ���饭�� � ���.楫��
            Elseif l_mdiagnoz_fill .and. ;
              ( ( alltrim_lshifr == '2.78.107' .and. ( human->k_data >= 0d20230101 ) ) .or. ;
              ( eq_any(alltrim_lshifr, '2.78.109', '2.78.110', '2.78.111', '2.78.112' ) .and. ( human->k_data >= 0d20240101 ) ) )
              // ��������� �������᭠� ��㣠 2.78.107 02.2023
              // ��������� ��㣨 2.78.109, 2.78.110, 2.78.111, 2.78.112 01.2024
              mpovod := 4 // 1.3
              If ! check_diag_usl_disp_nabl( mdiagnoz[ 1 ], alltrim_lshifr, human->k_data ) //, .f. )
                AAdd( ta, '� ��㣥 ' + alltrim_lshifr + ' ������ ����� �����⨬� ������� ��� ��ᯠ��୮�� �������' )
              Endif
              if between_diag( mdiagnoz[ 1 ], ;
                  'E10.0', 'E10.9') .and. alltrim_lshifr == '2.78.111' .and. ;
                  human->k_data >= 0d20240426 // ᮣ��᭮ ����� 09-20-180 �� 26.04.24
                AAdd( ta, '��� �������� ' + alltrim( mdiagnoz[ 1 ] ) + ' ᫥��� �ᯮ�짮���� ��㣨 2.78.61-63, 2.78.68-69, 2.78.71, 2.78.80, 2.78.86 ��� ��ᯠ��୮�� �������' )
              endif
            Endif
          Endif
          mdate_u2 := dtoc4( human->k_data )
        Elseif left_lshifr_5 == '2.79.'
          d_sroks := AfterAtNum( '.', alltrim_lshifr )
          If between_shifr( alltrim_lshifr, '2.79.44', '2.79.50' ) .or. eq_any( alltrim_lshifr, '2.79.79', '2.79.80' )
            mpovod := 8 // 2.5 - ���஭��
          Else
            mpovod := 9 // 2.6
          Endif
          If between_shifr( alltrim_lshifr, '2.79.59', '2.79.64' )
            fl_stom := .t.
            mpztip := 4
          Else
            is_2_79 := .t.
            If alltrim_lshifr == '2.79.51'
              is_pren_diagn := .t.
            Else
              kvp_2_79++
            Endif
          Endif
        Elseif left_lshifr_5 == '2.80.'
          d_sroks := AfterAtNum( '.', alltrim_lshifr )
          mpovod := 2 // 1.1
          If between_shifr( alltrim_lshifr, '2.80.34', '2.80.38' )
            fl_stom := .t.
            mpztip := 4
          Else
            is_2_80 := .t.
          Endif
        Elseif left_lshifr_5 == '2.81.'
          mpovod := 1 // 1.0
          is_2_81 := .t.
        Elseif left_lshifr_5 == '2.82.'
          If alltrim_lshifr == '2.82.10' .and. hu_->profil == 90
            AAdd( ta, '��� ��㣨 2.82.10 ४�������� ���⠢���� ��䨫� "祫��⭮-��楢�� ���ࣨ�"' )
          Endif
          mpovod := 2 // 1.1
          is_2_82 := .t.
          mIDSP := 22 // ���饭�� � ��񬭮� �����
        Elseif left_lshifr_5 == '2.83.'
          is_disp_DDS := .t.
          is_2_83 := .t.
          is_exist_Prescription := .t.
        Elseif left_lshifr_5 == '2.84.'
          mIDSP := 11 // ��ᯠ��ਧ���
          is_disp_DVN := .t.
          is_2_84 := .t.
          is_exist_Prescription := .t.
        Elseif left_lshifr_5 == '7.80.'
          mIDSP := 30 // 㣫㡫����� ��ᯠ��ਧ��� ��᫥ COVID
          is_disp_DVN_COVID := .t.
          is_exist_Prescription := .t.
        Elseif left_lshifr_5 == '70.9.'
          mIDSP := 30 // ��ᯠ��ਧ��� ९த�⨢���� ���஢��
          is_disp_DRZ := .t.
          is_exist_Prescription := .t.
        Elseif left_lshifr_5 == '2.85.' // ��䨫��⨪� ��ᮢ��襭����⭨�
          is_prof_PN := .t.
          is_2_85 := .t.
          is_exist_Prescription := .t.
        Elseif left_lshifr_5 == '2.87.'
          is_disp_DDS := .t.
          is_2_87 := .t.
          is_exist_Prescription := .t.
        Elseif left_lshifr_5 == '2.88.'
          d_sroks := AfterAtNum( '.', alltrim_lshifr )
          mpovod := 1 // 1.0
          If between_shifr( alltrim_lshifr, '2.88.46', '2.88.51' )
            fl_stom := .t.
            mpztip := 4
          Else
            is_2_88 := .t.
            If between_shifr( alltrim_lshifr, '2.88.111', '2.88.118' ) .and. ( human->k_data < 0d20220201 )
              If is_dom
                is_dom := .f. // �⮡� ��� ��㣨 � ��஭�����ᮬ (�� ����) �� ������ ����� ���饭��
              Else
                AAdd( ta, '��㣠 ' + alltrim_lshifr + ' ����� ���� ������� ⮫쪮 "�� ����"' )
              Endif
            Endif
          Endif
        Elseif left_lshifr_5 == '2.89.'
          mpovod := 10 // 3.0
          ++kvp_2_89
          is_2_89 := .t.
          i := 3
          k := Int( Val( AfterAtNum( '.', alltrim_lshifr ) ) )
          If     eq_any( k, 1, 13 )
            i := 1  // ��.����.������
          Elseif eq_any( k, 3, 14 )
            i := 3  // �थ筮-��㤨��� ��⮫����
          Elseif eq_any( k, 4, 15 )
            i := 4  // 業�ࠫ쭠� ��ࢭ�� ��⥬�
          Elseif eq_any( k, 5, 16 )
            i := 5  // ������᪠� ��ࢭ�� ��⥬�
          Elseif eq_any( k, 6, 17 )
            i := 6  // ࠪ ����筮� ������
          Elseif eq_any( k, 7, 18 )
            i := 7  // ࠪ ���᪨� ������� �࣠���
          Elseif eq_any( k, 8, 19 )
            i := 8  // �ண���⠫�� ࠪ
          Elseif eq_any( k, 9, 20 )
            i := 9  // ����४⠫�� ࠪ
          Elseif eq_any( k, 10, 21 )
            i := 10 // ࠪ ������ � �஭客
          Elseif eq_any( k, 11, 22 )
            i := 11 // ���宫� ������ � 襨
          Elseif eq_any( k, 12, 23 )
            i := 12 // ���宫� ��饢���, ���㤪�
          Elseif k == 24
            i := 13 // 2.89.24 '���饭�� � 楫�� ����樭᪮� ॠ�����樨 ��樥�⮢ �� ��祭�� �࣠��� ��堭��, ��᫥ COVID-19'
          Elseif k == 25
            i := 14 // 2.89.25 '���饭�� � 楫�� ����樭᪮� ॠ�����樨 ��樥�⮢ �� ��祭�� �࣠��� ��堭��'
          Elseif k == 26
            i := 15 // 2.89.26 '���饭�� � 楫�� ����樭᪮� ॠ�����樨 ��樥�⮢ �� ��祭�� �࣠��� ��堭��, ��᫥ COVID-19 � ��-�� ⥫�����樭�'
          Endif
          a_2_89[ i ] := 1
          mdate_u2 := dtoc4( human->k_data )
        Elseif left_lshifr_5 == '2.90.'
          mIDSP := 11 // ��ᯠ��ਧ���
          is_disp_DVN := .t.
          is_exist_Prescription := .t.
        Elseif left_lshifr_5 == '7.80.'  // 㣫㡫����� ��ᯠ��ਧ��� ��᫥ COVID
          mIDSP := 30 // '��� ᯮᮡ� ������' '30 - �� ���饭�� (�����祭�� ��砩)'
          is_disp_DVN_COVID := .t.
          is_exist_Prescription := .t.
        Elseif left_lshifr_5 == '70.9.'  // ��ᯠ��ਧ��� ९த�⨢���� ���஢��
          mIDSP := 30 // '��� ᯮᮡ� ������' '30 - �� ���饭�� (�����祭�� ��砩)'
          is_disp_DRZ := .t.
          is_exist_Prescription := .t.
        Elseif left_lshifr_5 == '2.91.'
          mIDSP := 29 // �� ���饭�� � �����������
          is_prof_PN := .t.
          is_exist_Prescription := .t.
        Elseif eq_any( left_lshifr_5, '70.3.', '70.7.', '72.1.', '72.5.', '72.6.', '72.7.' ) // ��ᯠ��ਧ��� ������
          is_disp_DVN := .t.
          is_exist_Prescription := .t.
          If eq_any( left_lshifr_5, '70.3.', '70.7.' )
            mIDSP := 11 // ��ᯠ��ਧ���
          Else
            is_disp_DVN3 := .t.
            is_exist_Prescription := .t.
            mIDSP := 17 // �����祭�� ��砩 � �����������
          Endif
          ++kvp_70_3
          is_70_3 := .t.
          mdate_u2 := dtoc4( human->k_data )
        Elseif left_lshifr_5 == '72.2.' // ��䨫��⨪� ��ᮢ��襭����⭨�
          is_prof_PN := .t.
          ++kvp_72_2
          is_72_2 := .t.
          mdate_u2 := dtoc4( human->k_data )
          is_exist_Prescription := .t.
        Elseif left_lshifr_5 == '70.5.' // ��ᯠ��ਧ��� ��⥩-���
          is_disp_DDS := .t.
          mIDSP := 11 // ��ᯠ��ਧ���
          ++kvp_70_5
          is_70_5 := .t.
          mdate_u2 := dtoc4( human->k_data )
          is_exist_Prescription := .t.
        Elseif left_lshifr_5 == '70.6.' // ��ᯠ��ਧ��� ��⥩-���
          is_disp_DDS := .t.
          mIDSP := 11 // ��ᯠ��ਧ���
          ++kvp_70_6
          is_70_6 := .t.
          mdate_u2 := dtoc4( human->k_data )
          is_exist_Prescription := .t.
        Endif
        If is_usluga_disp_nabl( alltrim_lshifr )
          mpovod := 4 // 1.3-��ᯠ��୮� �������
          ldate_next := c4tod( human->DATE_OPL )
          info_disp_nabl := val( substr( human_->DISPANS, 2, 1 ) )  // ����稬 ᢥ����� �� ��ᯠ��୮�� ������� �� �᭮����� �����������
          if ! ( eq_any( info_disp_nabl, 4, 6 ) ) // ᮣ��᭮ ����� ����� 09-20-615 �� 21.11.24
            If Empty( ldate_next )
              AAdd( ta, '��� ��㣨 ' + alltrim_lshifr + ' �� ��������� "��� ᫥���饩 � ��樥�� ��� ��ᯠ��୮�� �������"' )
            Elseif ldate_next < dEnd
              AAdd( ta, '��� ��㣨 ' + alltrim_lshifr + ' "��� ᫥���饩 � ��樥�� ��� ��ᯠ��୮�� �������" ����� ���� ����砭�� ��祭��' )
            Endif
          endif
        Endif
        kvp += hu->kol_1
        hu_->PZTIP := mPZTIP
        hu_->PZKOL := mPZKOL
      Endif
      If musl_ok == USL_OK_POLYCLINIC // 3
        If is_disp_DDS .or. is_disp_DVN .or. is_prof_PN .or. is_disp_DVN_COVID .or. is_disp_DRZ
          //
        Elseif mpovod > 0 .and. AScan( arr_povod, {| x| x[ 1 ] == mpovod } ) == 0
          AAdd( arr_povod, { mpovod, alltrim_lshifr } )
        Endif
      Elseif !( hu->date_u == mdate_u1 ) .and. Len( au_lu ) == 1
        AAdd( ta, '��� ��㣨 ' + alltrim_lshifr + ' ������ ࠢ������ ��� ��砫� ��祭��' )
      Endif
      hu_->date_u2 := mdate_u2
      If Empty( hu_->kod_diag ) .and. l_mdiagnoz_fill
        hu_->kod_diag := mdiagnoz[ 1 ]
      Endif
      Select MKB_10
      find ( PadR( hu_->kod_diag, 6 ) )
      If !Found()
        AAdd( ta, '�� ������ ������� ' + AllTrim( hu_->kod_diag ) + '(' + AllTrim( usl->shifr ) + ') � �ࠢ�筨�� ���-10' )
      Endif
      AAdd( adiag, hu_->kod_diag )
      ATail( au_lu )[ 7 ] := c4tod( mdate_u2 )
      ATail( au_lu )[ 8 ] := hu_->kod_diag
      If Empty( kodKSG ) // ��� ��� 業� ��९஢�ਬ ��⮬ �१ definition_ksg()
        fl_del := fl_uslc := .f.
        v := fcena_oms( lshifr, ( human->vzros_reb == 0 ), human->k_data, @fl_del, @fl_uslc )
        If fl_uslc  // �᫨ ��諨 � �ࠢ�筨�� �����
          If fl_del
            AAdd( ta, '���� �� ���� ' + RTrim( lshifr ) + ' ��������� � �ࠢ�筨�� �����' )
          Elseif !( Round( v, 2 ) == Round( hu->u_cena, 2 ) )
            AAdd( ta, '�訡�� � 業� ��㣨[' + ;
              iif( human->vzros_reb == 0, '���', 'ॡ' ) + ;
              ']: ' + RTrim( lshifr ) + ': ' + lstr( hu->u_cena, 9, 2 ) + ;
              ', ������ ����: ' + lstr( v, 9, 2 ) )
          Endif
          If !( Round( hu->u_cena * hu->kol_1, 2 ) == Round( hu->stoim_1, 2 ) )
            AAdd( ta, '��㣠 ' + RTrim( lshifr ) + ': �㬬� ��ப� ' + ;
              lstr( hu->stoim_1 ) + ' �� ࠢ�� �ந�������� ' + ;
              lstr( hu->u_cena ) + ' * ' + lstr( hu->kol_1 ) )
          Endif
        Elseif is_disp_DVN_COVID .and. eq_any( AllTrim( lshifr ), 'A12.09.005', 'A12.09.001', 'B03.016.003', 'B03.016.004', ;
            'A06.09.007', 'B01.026.002', 'B01.047.002', 'B01.047.006' )
        Elseif is_disp_DRZ .and. eq_any_new( AllTrim( lshifr ), ;
            'B01.001.001', 'B01.001.002', 'B01.053.001', 'B01.053.002', ;
            'B01.057.001', 'B01.057.002', 'B03.053.002', ;
            'A01.20.006', 'A02.20.001', ;
            'A04.20.001', 'A04.20.001.001', ;
            'A04.20.002', 'A04.21.001', 'A04.28.003', ;
            'A08.20.017', 'A08.20.017.001', 'A08.20.017.002', ;
            'A12.20.001', ;
            'A26.20.009.002', 'A26.20.034.001', 'A26.21.035.001', 'A26.21.036.001' )
          // //////
        Else
          AAdd( ta, '�� ������� ��㣠 ' + RTrim( lshifr ) + iif( human->vzros_reb == 0, ' ��� ������', ' ��� ��⥩' ) + ' � �ࠢ�筨�� �����' )
        Endif
      Endif
      If is_disp_DVN_COVID .or. is_disp_DRZ
        If hu->kod_vr != 0  // ��������� ��� ���
          ssumma += hu->stoim_1
        Endif
      Else
        ssumma += hu->stoim_1
      Endif
    Else
      AAdd( au_lu_ne, { usl->shifr, ;        // 1
        lshifr1, ;           // 2
        usl->name, ;         // 3
        c4tod( hu->date_u ), ; // 4
      hu->kol_1 } )         // 5
    Endif
    Select HU
    Skip
  Enddo
  If !is_mgi .and. AScan( kod_LIS, glob_mo[ _MO_KOD_TFOMS ] ) > 0
    If eq_any( human_->profil, 6, 34 )
      human->KOD_DIAG := 'Z01.7' // �ᥣ��
    Endif
    mdiagnoz := diag_to_array(, , , , .t. )
    Select HU
    find ( Str( human->kod, 7 ) )
    Do While hu->kod == human->kod .and. !Eof()
      hu_->( g_rlock( forever ) )
      If l_mdiagnoz_fill .and. eq_any( human_->profil, 6, 34 )
        hu_->kod_diag := mdiagnoz[ 1 ]
      Endif
      Skip
    Enddo
  Elseif is_covid
    If l_mdiagnoz_fill .and. !( PadR( mdiagnoz[ 1 ], 5 ) == 'Z01.7' )
      AAdd( ta, '��� ��㣨 4.17.785 �᭮���� ������� ������ ���� Z01.7' )
    Endif
    If Empty( human_->NPR_MO )
      AAdd( ta, '��� ��㣨 4.17.785 ������ ���� ��������� ���� "���ࠢ���� ��"' )
    Elseif Empty( human_2->NPR_DATE )
      If glob_mo[ _MO_KOD_TFOMS ] == ret_mo( human_->NPR_MO )[ _MO_KOD_TFOMS ]
        human_2->NPR_DATE := dBegin
      Else
        AAdd( ta, '������ ���� ��������� ���� "��� ���ࠢ�����"' )
      Endif
    Elseif human_2->NPR_DATE > dBegin
      AAdd( ta, '"��� ���ࠢ�����" ����� "���� ��砫� ��祭��"' )
    Elseif human_2->NPR_DATE + 60 < dBegin
      AAdd( ta, '���ࠢ����� ����� ���� ����楢' )
    Endif
    If !eq_any( human_->RSLT_NEW, 314 )
      AAdd( ta, '� ���� "������� ���饭��" ������ ���� "314 �������᪮� �������"' )
    Endif
    If !eq_any( human_->ISHOD_NEW, 304 )
      AAdd( ta, '� ���� "��室 �����������" ������ ���� "304 ��� ��६��"' )
    Endif
  Endif

  checkrslt_ishod( human_->RSLT_NEW, human_->ISHOD_NEW, ta )

  If Len( arr_povod ) > 0
    If Len( arr_povod ) > 1
      AAdd( ta, 'ᬥ訢���� 楫�� ���饭�� � ��砥 ' + print_array( arr_povod ) )
    Else
//      If is_dom .and. arr_povod[ 1, 1 ] == 1
//        arr_povod[ 1, 1 ] := 3 // 1.2 - ��⨢��� ���饭��, �.�. �� ����
//      Endif
      If is_disp_DDS .or. is_disp_DVN .or. is_prof_PN .or. is_disp_DVN_COVID .or. is_disp_DRZ
        //
      Elseif human_->usl_ok == USL_OK_POLYCLINIC .and. l_mdiagnoz_fill
        If Len( a_idsp ) == 1 .and. a_idsp[ 1, 1 ] != 28 // �.�. idsp �� ࠢ�� '�� ����樭��� ���� � �����������'
          If eq_any( arr_povod[ 1, 1 ], 1, 2, 4, 10 ) // 1.0, 1.1, 1.3, 3.0
            If !Between( Left( mdiagnoz[ 1 ], 1 ), 'A', 'U' )
              AAdd( ta, '��� ���饭�� (���饭��) �� ������ ����������� �᭮���� ������� ������ ���� A00-T98 ��� U04,U07' )
            Endif
          Elseif eq_any( arr_povod[ 1, 1 ], 9, 11 ) // 2.6, 3.1
            If !( Left( mdiagnoz[ 1 ], 1 ) == 'Z' )
              AAdd( ta, '��� ���饭�� (���饭��) � ��䨫����᪮� 楫�� �᭮���� ������� ������ ���� Z00-Z99' )
            Endif
          Endif
        Endif
        If arr_povod[ 1, 1 ] == 4 .and. l_mdiagnoz_fill .and. ( Left( mdiagnoz[ 1 ], 1 ) == 'C' .or. Between( Left( mdiagnoz[ 1 ], 3 ), 'D00', 'D09' ) .or. Between( Left( mdiagnoz[ 1 ], 3 ), 'D45', 'D47' ) )
          k := ret_prvs_v021( human_->PRVS )
          If !eq_any( k, 9, 19, 41 )  // ��� �᪫�祭�� ������� ����⮫����, ᯥ樠�쭮��� - 9
            AAdd( ta, '��ᯠ��୮� ������� �� ��� �����⢫��� ⮫쪮 ���-�������� (���᪨� ��������), � � ���� ���� �⮨� ᯥ樠�쭮��� "' + inieditspr( A__MENUVERT, getv021(), k ) + '"' )
          Endif
        Endif
      Endif
    Endif
  Endif
  //
  If l_mdiagnoz_fill .and. human->OBRASHEN == '1'
    For i := 1 To Len( mdiagnoz )
      If Left( mdiagnoz[ i ], 1 ) == 'C' .or. Between( Left( mdiagnoz[ i ], 3 ), 'D00', 'D09' ) .or. Between( Left( mdiagnoz[ i ], 3 ), 'D45', 'D47' )
        AAdd( ta, AllTrim( mdiagnoz[ i ] ) + ' �᭮���� (��� ᮯ������騩) ������� - ���������, ���⮬� � ���� "�����७�� �� ���" �� ������ ����� "��"' )
        Exit
      Endif
    Next
    For i := 1 To Len( mdiagnoz3 )
      If Left( mdiagnoz3[ i ], 1 ) == 'C' .or. Between( Left( mdiagnoz3[ i ], 3 ), 'D00', 'D09' ) .or. Between( Left( mdiagnoz3[ i ], 3 ), 'D45', 'D47' )
        AAdd( ta, AllTrim( mdiagnoz3[ i ] ) + ' ������� �᫮������ - ���������, ���⮬� � ���� "�����७�� �� ���" �� ������ ����� "��"' )
        Exit
      Endif
    Next
  Endif
  fl := ( AScan( mdiagnoz, {| x| PadR( x, 5 ) == 'Z03.1' } ) > 0 )
  If is_disp_DDS .or. is_disp_DVN .or. is_prof_PN .or. is_disp_DVN_COVID .or. is_disp_DRZ
    If is_oncology == 2
      is_oncology := 1
    Endif
    If fl  .and. ! eq_any( human_->RSLT_NEW, 375, 376, 377, 378, 379 ) // ��� ��� �᪫�砥� ᮣ��᭮ ���쬠 09-20-214 �� 21.05.24
      AAdd( ta, '�� ��ᯠ��ਧ�樨 �� ������ ���� �᭮����� (��� ᮯ������饣�) �������� Z03.1 "������� �� �����७�� �� �������⢥���� ���宫�"' )
    Endif
  Else
    For i := 1 To Len( au_lu )
      If !Between( au_lu[ i, 2 ], dBegin, dEnd )
        AAdd( ta, '��㣠 ' + au_lu[ i, 5 ] + '(' + date_8( au_lu[ i, 2 ] ) + ') �� �������� � �������� ��祭��' )
      Endif
    Next
    If human_->usl_ok < USL_OK_AMBULANCE .and. fl .and. !( human->OBRASHEN == '1' )
      If is_oncology > 0 // ��������� - ���ࠢ�����
        AAdd( ta, '�᭮���� (��� ᮯ������騩) ������� Z03.1 "������� �� �����७�� �� �������⢥���� ���宫�", �� ���� ���� � ⠪ ���������᪨�' )
      Else
        AAdd( ta, '�᫨ �᭮���� (��� ᮯ������騩) ������� Z03.1 "������� �� �����७�� �� �������⢥���� ���宫�", � � ���� "�����७�� �� ���" ������ ����� "��"' )
      Endif
    Endif
  Endif
  If is_oncology_smp > 0 // ᯥ樠�쭮 ��� ᪮ன �����
    Select ONKCO
    find ( Str( human->kod, 7 ) )
    If Found()
      If Between( onkco->PR_CONS, 1, 3 ) .and. !Between( onkco->DT_CONS, dBegin, dEnd )
        AAdd( ta, '��� ���ᨫ�㬠 �� ��������� ������ ���� ����� �ப�� ��祭��' )
      Endif
    Else
      addrec( 7 )
      onkco->kod := human->kod
      onkco->PR_CONS := 0 // 0-��������� ����室������
      onkco->DT_CONS := CToD( '' )
      Unlock
    Endif
  Endif
  If is_oncology > 0 // ��������� - ���ࠢ�����
    If is_disp_DDS .or. is_disp_DVN .or. is_prof_PN
      //
    Elseif human->OBRASHEN == '1' .and. AScan( mdiagnoz, {| x| PadR( x, 5 ) == 'Z03.1' } ) == 0
      AAdd( ta, '�� "�����७�� �� ���" � ���� ���� ��易⥫쭮 ������ ���� �᭮���� (��� ᮯ������騩) ������� "Z03.1 ������� �� �����७�� �� �������⢥���� ���宫�"' )
    Endif
    i := 0
    arr := {}
    Select ONKNA // �������ࠢ�����
    find ( Str( human->kod, 7 ) )
    Do While onkna->kod == human->kod .and. !Eof()
      ++i
      AAdd( arr, { onkna->NAPR_DATE, ;
        onkna->NAPR_MO, ;
        onkna->NAPR_V, ;
        iif( onkna->NAPR_V == 3, onkna->MET_ISSL, 0 ), ;
        iif( onkna->NAPR_V == 3, onkna->U_KOD, 0 ), ;
        '', ;
        onkna->( RecNo() ), ;
        onkna->KOD_VR } )
      If !Between( onkna->NAPR_DATE, dBegin, dEnd )
        AAdd( ta, '��� ���ࠢ����� ������ ���� ����� �ப�� ��祭�� (���ࠢ����� ' + lstr( i ) + ')' )
      Elseif !Empty( s := verify_dend_mo( onkna->NAPR_MO, onkna->NAPR_DATE ) )
        AAdd( ta, '�������ࠢ����� � ��: ' + s )
      Endif
      If onkna->NAPR_V == 3
        If Empty( onkna->MET_ISSL )
          AAdd( ta, '�� ��।��� "��⮤ �����.��᫥�������" ��� ���ࠢ����� ' + lstr( i ) )
        Elseif Empty( onkna->KOD_VR )
          AAdd( ta, '��������� ⠡���� ����� ���ࠢ��襣� ��� ��� ���ࠢ����� ' + lstr( i ) )
        Elseif Empty( onkna->U_KOD )
          AAdd( ta, '�� ��।����� "����樭᪠� ��㣠" ��� ���ࠢ����� ' + lstr( i ) )
        Else
          Select MOSU
          Goto ( onkna->U_KOD )
          If Empty( mosu->shifr1 )
            AAdd( ta, '�� ��।����� "����樭᪠� ��㣠" ��� ���ࠢ����� ' + lstr( i ) )
          Else
            dbSelectArea( lalf )
            find ( PadR( mosu->shifr1, 20 ) )
            If Found()
              If onkna->MET_ISSL != &lalf.->onko_napr
                AAdd( ta, '�� �� ��⮤ ���������᪮�� ��᫥������� � ��㣥 ' + ;
                  AllTrim( iif( Empty( mosu->shifr ), mosu->shifr1, mosu->shifr ) ) + ' ��� ���ࠢ����� ' + lstr( i ) )
              Endif
            Else
              AAdd( ta, '��㣠 ' + AllTrim( iif( Empty( mosu->shifr ), mosu->shifr1, mosu->shifr ) ) + ;
                ' �� ������� � �ࠢ�筨�� (��� ���ࠢ����� ' + lstr( i ) + ')' )
            Endif
          Endif
        Endif
      Endif
      Select ONKNA
      Skip
    Enddo
    If eq_any( human_->RSLT_NEW, 308, 309 )
      If AScan( arr, {| x| eq_any( x[ 3 ], 1, 4 ) } ) == 0
        AAdd( ta, '�� "�����७�� �� ���" ��� ���������᪮� �������� � ���� ���� � १����� ��祭�� "308 ���ࠢ��� �� ���������" ��� "309 ���ࠢ��� �� ��������� � ��㣮� ���" ��易⥫쭮 ������ ���� ���ࠢ����� "� ��������" ��� "��� ��।������ ⠪⨪� ��祭��"' )
      Endif
    Elseif human_->RSLT_NEW == 315
      If AScan( arr, {| x| x[ 3 ] == 3 } ) == 0
        AAdd( ta, '�� "�����७�� �� ���" ��� ���������᪮� �������� � ���� ���� � १���� ��祭�� "315 ���ࠢ��� �� ��᫥�������" ��易⥫쭮 ������ ���� ���ࠢ����� "�� ����᫥�������"' )
      Endif
    Endif
    If Len( arr ) > 0
      arr_onkna := AClone( arr )
    Endif
    For i := 1 To Len( arr )  // �饬 �㡫����� ���ࠢ�����
      s := DToS( arr[ i, 1 ] ) + arr[ i, 2 ] + Str( arr[ i, 3 ], 1 ) + Str( arr[ i, 4 ], 1 ) + Str( arr[ i, 5 ], 6 )
      arr[ i, 6 ] := s
      If i > 1 .and. ( j := AScan( arr, {| x| s == x[ 6 ] }, 1, i - 1 ) ) > 0
        Select ONKNA
        Goto ( arr[ i, 7 ] )
        deleterec( .t. )  // 㤠�塞 �㡫���� ���ࠢ�����
      Endif
    Next
  Endif
  //
  Select MOHU
  find ( Str( human->kod, 7 ) )
  Do While mohu->kod == human->kod .and. !Eof()
    lshifr := mosu->shifr1
    dbSelectArea( lalf )
    find ( PadR( lshifr, 20 ) )
    usl_found := Found()
    s := AllTrim( mosu->shifr1 ) + iif( Empty( mosu->shifr ), '', '(' + AllTrim( mosu->shifr ) + ')' )
    If mosu->tip == 5
      AAdd( ta, '��㣠 "' + s + '" 㤠���� � 2017 ����' )
    Endif
    If Empty( mohu->kol_1 )
      AAdd( ta, '�� ��������� ���� "������⢮ ���" ��� "' + s + '"' )
    Endif
    mdate := c4tod( mohu->date_u )
    If !Between( mdate, dBegin, dEnd )
      If usl_found .and. &lalf.->telemed == 1 .and. mdate < dBegin
        // ࠧ��蠥��� ����뢠�� ࠭��
      Elseif eq_any( Left( lshifr, 4 ), 'A06.', 'A12.', 'B01.', 'B03.' )
        // ࠧ��蠥��� ����뢠�� ࠭��
      Elseif eq_any( alltrim( lshifr ), 'A04.20.001', 'A04.20.001.001', 'A08.20.017', 'A08.20.017.001', 'A08.20.017.002' )
        // �ய�� ��㣨
      Else
        AAdd( ta, '��㣠 ' + s + ' (' + date_8( mdate ) + ') �� �������� � �������� ��祭��' )
      Endif
    Endif
    otd->( dbGoto( mohu->OTD ) )
    mohu->( g_rlock( forever ) )
    If Empty( mohu->kod_vr ) .and. ( ! is_disp_DVN_COVID ) .and. ( ! is_disp_DRZ ) // ��ࠢ���� ��� 㣫㡫����� ��ᯠ��ਧ�樨 � ���
      If usl_found .and. &lalf.->telemed == 1
        If !( mohu->PRVS == human_->PRVS )
          mohu->PRVS := human_->PRVS // ��� ⥫�����樭� ᯥ樠�쭮��� �����㥬 �� ����
        Endif
        If !( mohu->profil == human_->profil )
          mohu->profil := human_->profil // ��� ⥫�����樭� ��䨫� �����㥬 �� ����
        Endif
      Else
        AAdd( ta, '�� ��������� ���� "���, ������訩 ���� ' + s + '"' )
      Endif
    Else

      arr_perso := addkoddoctortoarray( arr_perso, mohu->kod_vr )

      If Empty( mvrach ) .and. !( AScan( kod_LIS, glob_mo[ _MO_KOD_TFOMS ] ) > 0 .and. eq_any( human_->profil, 6, 34 ) )
        mvrach := mohu->kod_vr
      Endif
      pers->( dbGoto( mohu->kod_vr ) )
      mprvs := -ret_new_spec( pers->prvs, pers->prvs_new )
      If Empty( mprvs ) .and. ( ! is_disp_DVN_COVID ) .and. ( ! is_disp_DRZ ) // ��ࠢ���� ��� 㣫㡫����� ��ᯠ��ਧ�樨 � ���
        AAdd( ta, '��� ᯥ樠�쭮�� � �ࠢ�筨�� ���ᮭ��� � "' + AllTrim( pers->fio ) + '"' )
      Elseif mohu->PRVS != mprvs
        mohu->PRVS := mprvs
      Endif
      If mohu->PRVS > 0 .and. ret_v004_v015( mohu->PRVS ) == 0
        AAdd( ta, '�� ������� ᯥ樠�쭮�� � �ࠢ�筨�� V015 � "' + AllTrim( pers->fio ) + '"' )
      Endif
    Endif
    If Empty( mprofil )
      mprofil := mosu->profil
      If Empty( mprofil )
        mprofil := mohu->profil
      Endif
    Endif
    If Empty( mohu->profil )
      mohu->profil := mosu->profil
      If Empty( mohu->profil )
        mohu->profil := otd->profil
      Endif
    Endif
    If Empty( mohu->profil )
      if ! Empty( mohu->kod_vr )
        AAdd( ta, '��� ��㣨 ' + s + ' �� ��������� ���� "��䨫�"' )
      endif
    Elseif mohu->profil != correct_profil( mohu->profil )
      mohu->profil := correct_profil( mohu->profil )
    Endif
    ltip_onko := 0
    If usl_found
      If !Empty( &lalf.->par_org )
        If Empty( mohu->zf )
          AAdd( ta, '� ��㣥 ' + s + ' �� ������� �࣠�� (��� ⥫�), �� ������ �믮����� ������' )
        Else
          a1 := list2arr( mohu->zf )
          a2 := list2arr( &lalf.->par_org )
          s1 := ''
          For i := 1 To Len( a2 )
            If AScan( a1, a2[ i ] ) > 0
              s1 += lstr( a2[ i ] ) + ','
            Endif
          Next
          If !Empty( s1 )
            s1 := Left( s1, Len( s1 ) - 1 )
          Endif
          If Empty( s1 ) .or. !( s1 == AllTrim( mohu->zf ) )
            AAdd( ta, '� ��㣥 ' + s + ' �����४⭮ ������� �࣠�� (��� ⥫�) ' + AllTrim( mohu->zf ) )
          Endif
        Endif
      Endif
      ltip_onko := &lalf.->onko_ksg
      Do Case
      Case human_->usl_ok == USL_OK_HOSPITAL  // 1
        if &lalf.->tip == 2
          AAdd( ta, '��㣠 ' + s + ' �⭮���� � �⮬�⮫����᪨�' )
        Endif
      Case human_->usl_ok == USL_OK_DAY_HOSPITAL  // 2
        if &lalf.->tip == 2
          AAdd( ta, '��㣠 ' + s + ' �⭮���� � �⮬�⮫����᪨�' )
        Endif
      Case human_->usl_ok == USL_OK_POLYCLINIC
        If fl_stom
          If Empty( &lalf.->tip )
            AAdd( ta, '��㣠 ' + s + ' �� �⭮���� � �⮬�⮫����᪨�' )
          Else
            // �஢��塞 �� ��䨫�
            uslugaaccordanceprofil( lshifr, human->vzros_reb, mohu->profil, ta, mosu->shifr )
            // �஢��塞 �� ᯥ樠�쭮���
            uslugaaccordanceprvs( lshifr, human->vzros_reb, mohu->prvs, ta, mosu->shifr, mohu->kod_vr )
          Endif
          if &lalf.->zf == 1  // ��易⥫�� ���� �㡭�� ����
            arr_zf := stverifyzf( mohu->zf, human->date_r, dBegin, ta, s )
            stverifykolzf( arr_zf, mohu->kol_1, ta, s )
          Endif
        elseif &lalf.->telemed == 0 .and. ! eq_any_new( AllTrim( &lalf.->shifr ), ;
            'A01.20.006', 'A01.20.002', 'A01.20.003', 'A01.20.005', 'A02.20.001', 'A02.20.003', 'A02.20.005', ;
            'A04.10.002', 'A04.12.006.002', ;
            'A04.20.001', 'A04.20.001.001', 'A04.20.002', ;
            'A04.21.001', 'A04.28.003', ;
            'A06.09.005', 'A06.09.007', ;
            'A08.20.017', 'A08.20.017.001', 'A08.20.017.002', ;
            'A09.05.051.001', 'A09.20.011',  ;
            'A12.09.001', 'A12.09.005', 'A12.20.001', ;
            'A23.30.023', ;
            'A26.20.009.002', 'A26.20.034.001', 'A26.21.035.001', 'A26.21.036.001', ;
            'B01.001.001', 'B01.001.002', ;
            'B03.016.003', 'B03.016.004', ;
            'B01.026.001', 'B01.026.002', ;
            'B01.053.001', 'B01.053.002', ;
            'B01.057.001', 'B01.057.002', ;
            'B03.053.002', ;
            'B01.070.009', 'B01.070.010', ;
            'A25.28.001.001', 'A25.28.001.002', ;
            'A06.09.007.002', 'A06.20.004', 'A06.09.006.001' ;
          )
          AAdd( ta, '���� ' + s + ' ����� ������� ��� ���㫠�୮� �����' )
        Endif
      Case human_->usl_ok == USL_OK_AMBULANCE // 4
        if &lalf.->telemed == 0
          AAdd( ta, '���� ' + s + ' ����� ������� ��� ᪮ன �����' )
        Endif
      Endcase
    Else
      AAdd( ta, '��㣠 ' + s + ' �� ������� � �ࠢ�筨��' )
    Endif
    If !valid_guid( mohu->ID_U )
      mohu->ID_U := mo_guid( 4, mohu->( RecNo() ) )
    Endif
    mohu->date_u2 := mohu->date_u
    If Empty( mohu->kod_diag ) .and. l_mdiagnoz_fill
      mohu->kod_diag := mdiagnoz[ 1 ]
    Endif
    Select MKB_10
    find ( PadR( mohu->kod_diag, 6 ) )
    If !Found()
      AAdd( ta, '�� ������ ������� ' + AllTrim( mohu->kod_diag ) + ' � �ࠢ�筨�� ���-10' )
    Endif
    AAdd( au_flu, { lshifr, ;               // 1
      mdate, ;                // 2
      mohu->profil, ;         // 3
      mohu->PRVS, ;           // 4
      mosu->shifr, ;          // 5
      mohu->kol_1, ;          // 6
      c4tod( mohu->date_u2 ), ; // 7
    mohu->kod_diag, ;       // 8
      mohu->( RecNo() ), ;      // 9
    ltip_onko, ;            // 10 ⨯ ���������᪮�� ��祭��
      .f. } )                  // 11 ⨯ ���������᪮�� ��祭�� �⠢�� � ����
    Select MOHU
    Skip
  Enddo
  v := 0
  If is_oncology == 2 // ���������
    Select ONKSL
    find ( Str( human->kod, 7 ) )
    Select ONKCO
    find ( Str( human->kod, 7 ) )
    If Found()
      If Between( onkco->PR_CONS, 1, 3 ) .and. !Between( onkco->DT_CONS, dBegin, dEnd )
        AAdd( ta, '��� ���ᨫ�㬠 �� ��������� ������ ���� ����� �ப�� ��祭��' )
      Endif
    Else
      addrec( 7 )
      onkco->kod := human->kod
      onkco->PR_CONS := 0 // 0-��������� ����室������
      onkco->DT_CONS := CToD( '' )
      Unlock
    Endif
    fl := .t.
    If l_mdiagnoz_fill .and. Between( onksl->ds1_t, 0, 4 )
      If Empty( onksl->STAD )
        AAdd( ta, '���������: �� ������� �⠤�� �����������' )
      Else
        f_verify_tnm( 2, onksl->STAD, mdiagnoz[ 1 ], ta )
      Endif
    Endif
    If kkt > 0 .and. onksl->ds1_t != 5
      AAdd( ta, '���������: ��� �⤥���� ���������᪨� ��� � ���� "����� ���饭��" ������ ���� ���⠢���� "�������⨪�"' )
    Endif
    If Len( arr_povod ) > 0 .and. arr_povod[ 1, 1 ] == 4 .and. onksl->ds1_t != 4
      AAdd( ta, '���������: � ��砥 ��ᯠ��୮�� ������� � ���� "����� ���饭��" ������ ���� ���⠢���� "��ᯠ��୮� �������"' )
    Endif
    If l_mdiagnoz_fill .and. onksl->ds1_t == 0 .and. human->vzros_reb == 0
      If Empty( onksl->ONK_T )
        fl := .f. ; AAdd( ta, '���������: �� ������� �⠤�� ����������� T' )
      Endif
      If Empty( onksl->ONK_N )
        fl := .f. ; AAdd( ta, '���������: �� ������� �⠤�� ����������� N' )
      Endif
      If Empty( onksl->ONK_M )
        fl := .f. ; AAdd( ta, '���������: �� ������� �⠤�� ����������� M' )
      Endif
      If fl
        fl := f_verify_tnm( 3, onksl->ONK_T, mdiagnoz[ 1 ], ta )
      Endif
      If fl
        fl := f_verify_tnm( 4, onksl->ONK_N, mdiagnoz[ 1 ], ta )
      Endif
      If fl
        fl := f_verify_tnm( 5, onksl->ONK_M, mdiagnoz[ 1 ], ta )
      Endif
    Endif
    // ���⮫����
    If is_gisto .and. onksl->b_diag != 98
      AAdd( ta, '��� ���� ���� �� ���⮫���� ��易⥫�� ���� १���⮢ ���⮫����' )
    Endif
    If is_mgi .and. onksl->b_diag != 98
      AAdd( ta, '��� ���� ���� �� �������୮� ����⨪� ��易⥫�� ���� १���⮢ ���㭮����娬��' )
    Endif
    If onksl->b_diag == 0 // �⪠�
      // �� ��⠢����� ॥��� ᠬ����⥫쭮 ��������� ���� ��⨢���������� id_prot = 0
    Elseif onksl->b_diag == 7 // �� ��������
      // �� ��⠢����� ॥��� ᠬ����⥫쭮 ��������� ���� ��⨢���������� id_prot = 7
    Elseif onksl->b_diag == 8 // ��⨢���������
      // �� ��⠢����� ॥��� ᠬ����⥫쭮 ��������� ���� ��⨢���������� id_prot = 8
    Elseif onksl->b_diag == -1 // �믮����� (�� 1 ᥭ���� 2018 ����)
      // �� ��⠢����� ॥��� ���� B_DIAG �� ����������
    Elseif l_mdiagnoz_fill .and. eq_any( onksl->b_diag, 97, 98 ) // �믮�����
      ar_N009 := {}
      If !is_mgi
        For i_n009 := 1 To Len( aN009 )
          If between_date( aN009[ i_n009, 4 ], aN009[ i_n009, 5 ], dEnd ) .and. PadR( mdiagnoz[ 1 ], 3 ) == Left( aN009[ i_n009, 2 ], 3 )
            AAdd( ar_N009, { '', aN009[ i_n009, 3 ], {} } )
          Endif
        Next
      Endif
      // ���㭮����娬��/��થ��
      mm_N012 := {}
      ar_N012 := {}
      If ( it := AScan( aN012_DS, {| x| Left( x[ 1 ], 3 ) == PadR( mdiagnoz[ 1 ], 3 ) } ) ) > 0
        ar_N012 := AClone( aN012_DS[ it, 2 ] )
        For i_n012 := 1 To Len( ar_N012 )
          AAdd( mm_N012, { '', ar_N012[ i_n012 ], {} } )
        Next
      Endif
      If is_mgi
        If ( i := AScan( glob_MGI, {| x| x[ 1 ] == shifr_mgi } ) ) > 0 // ��㣠 �室�� � ᯨ᮪ �����
          If ( j := AScan( ar_N012, {| x| x[ 2 ] == glob_MGI[ i, 2 ] } ) ) > 0 // �� ������� �������� ��������� ����室��� ��થ�
            tmp_arr := {}
            AAdd( tmp_arr, AClone( ar_N012[ j ] ) )
            ar_N012 := AClone( tmp_arr ) // ��⠢�� � ���ᨢ� ⮫쪮 ���� �㦭� ��� ��થ�
          Else
            ar_N012 := {}
          Endif
        Else
          ar_N012 := {}
        Endif
      Endif
      arr_onkdi0 := {}
      arr_onkdi1 := {}
      arr_onkdi2 := {}
      ngist := nimmun := 0 ; fl_krit_date := .f.
      Select ONKDI
      find ( Str( human->kod, 7 ) )
      If Found()
        If Empty( onkdi->DIAG_DATE ) .and. is_gisto
          AAdd( arr_onkdi0, .f. )
        Else
          // if is_gisto .and. onkdi->DIAG_DATE != dBegin
          // aadd(ta, '��� ���⮫���� ��� ����� ���ਠ�� ' + date_8(onkdi->DIAG_DATE) + '�. �� ࠢ����� ��� ��砫� ��祭�� ' + date_8(dBegin) + '�.')
          // elseif onkdi->DIAG_DATE < 0d20180901
          // fl_krit_date := .t.
          // //aadd(ta, '��� ����� ���ਠ�� ' + date_8(onkdi->DIAG_DATE) + '�. ����� ����������� ����')
          // endif
        Endif
        Do While onkdi->kod == human->kod .and. !Eof()
          If onkdi->DIAG_TIP == 1
            AAdd( arr_onkdi1, { onkdi->DIAG_DATE, onkdi->DIAG_TIP, onkdi->DIAG_CODE, onkdi->DIAG_RSLT } )
            If onkdi->DIAG_RSLT > 0
              ++ngist
            Endif
          Elseif onkdi->DIAG_TIP == 2
            AAdd( arr_onkdi2, { onkdi->DIAG_DATE, onkdi->DIAG_TIP, onkdi->DIAG_CODE, onkdi->DIAG_RSLT } )
            If onkdi->DIAG_RSLT > 0
              ++nimmun
            Endif
          Endif
          Skip
        Enddo
      Endif
      If fl_krit_date // �믮����� (�� 1 ᥭ���� 2018 ����)
        Select ONKDI // �� ��⠢����� ॥��� ���� B_DIAG �� ����������
        Do While .t.
          find ( Str( human->kod, 7 ) )
          If !Found() ; exit ; Endif
          deleterec( .t. )
        Enddo
        Select ONKSL
        g_rlock( forever )
        onksl->b_diag := -1
        Unlock
      Else
        If Len( arr_onkdi0 ) > 0
          AAdd( ta, '�� ��������� ��� ����� ���ਠ��' )
        Endif
        If is_gisto .and. emptyall( Len( ar_N009 ), Len( ar_N012 ) ) .and. ( onksl->DS1_T != 5 )  // ���⨥ ���⮫���� � �ࠢ�筨�� �����
          If Empty( ngist )
            AAdd( ta, '��� ���㫠�୮�� ���� �� ����� ���⮫����᪮�� ���ਠ�� ��易⥫쭮 ���������� ���� "�������� ���⮫����"' )
          Endif
        Else
          If is_mgi
            If Len( arr_onkdi1 ) > 0
              AAdd( ta, '��� ���� ���� �� �������୮� ����⨪� �� ������ ����������� ⠡��� ���⮫����' )
            Endif
          Elseif Len( arr_onkdi1 ) != Len( ar_N009 )  .and. ( onksl->DS1_T != 5 )
            AAdd( ta, '�訡�� ���������� ⠡���� ���⮫����' )
          Endif
          If Len( arr_onkdi2 ) != Len( ar_N012 )
            AAdd( ta, '�訡�� ���������� ⠡���� ���㭮����娬��' )
          Elseif is_mgi .and. Len( ar_N012 ) > 0 .and. Len( arr_onkdi2 ) != 1
            AAdd( ta, '��� ���� ���� �� �������୮� ����⨪� ��������� ⮫쪮 ���� ��થ� �� ���㭮����娬��' )
          Endif
          If onksl->b_diag == 98
            If ngist != Len( ar_N009 )
              AAdd( ta, '�� �� ���⮫���� ���������' )
            Endif
            If nimmun != Len( ar_N012 )
              AAdd( ta, '�� �� ���㭮����娬�� ���������' )
            Endif
          Endif
        Endif
      Endif
    Endif
    //
    Select ONKPR
    find ( Str( human->kod, 7 ) )
    Do While onkpr->kod == human->kod .and. !Eof()
      If !Between( onkpr->PROT, 0, 8 )  // ���� ����� �� �ࠢ�筨�� N001.xml
        AAdd( ta, '�����४⭮ ����ᠭ� ��⨢���������� � �஢������ (�⪠� �� �஢������)' )
      Elseif onkpr->D_PROT > dEnd
        AAdd( ta, AllTrim( Lower( inieditspr( A__MENUVERT, getn001(), n1->prot_name ) ) ) + ' - ��� ॣ����樨 ����� ���� ����砭�� ��祭��' )
      Endif
      Select ONKPR
      Skip
    Enddo
    // ��㣠 ��易⥫쭠 ��� ��樮��� � �������� ��樮��� �� �஢������ ��⨢����宫����� ��祭��
    If human_->usl_ok < USL_OK_POLYCLINIC // 3
      arr_onk_usl := {}
      Select ONKUS
      find ( Str( human->kod, 7 ) )
      Do While onkus->kod == human->kod .and. !Eof()
        If Between( onkus->USL_TIP, 1, 6 )
          AAdd( arr_onk_usl, onkus->USL_TIP )
          k := iif( onkus->USL_TIP == 4, 3, onkus->USL_TIP )
          If ( i := AScan( au_flu, {| x| x[ 10 ] == k } ) ) > 0
            If onkus->USL_TIP == 1
              If Empty( onkus->HIR_TIP )
                AAdd( ta, '�� �������� ⨯ ���ࣨ�᪮�� ��祭��' )
              Endif
            Elseif onkus->USL_TIP == 2
              If Empty( onkus->LEK_TIP_V )
                AAdd( ta, '�� �������� 横� ������⢥���� �࠯��' )
              Endif
              If Empty( onkus->LEK_TIP_L )
                AAdd( ta, '�� ��������� ����� ������⢥���� �࠯��' )
              Endif
            Elseif Between( onkus->USL_TIP, 3, 4 )
              If Empty( onkus->LUCH_TIP )
                AAdd( ta, '�� �������� ⨯ ' + iif( onkus->USL_TIP == 3, '', '娬��' ) + '��祢�� �࠯��' )
              Endif
            Endif
            au_flu[ i, 11 ] := .t.
          Elseif eq_any( onkus->USL_TIP, 1, 3, 4 )
            AAdd( ta, '�� ������� ��㣠 ��� ��࠭���� ⨯� ���������᪮�� ��祭�� (' + ;
              { '����.', '', '��祢��', '娬����祢��' }[ onkus->USL_TIP ] + ')' )
          Endif
          If onkus->USL_TIP == 5 .and. onksl->ds1_t != 6
            AAdd( ta, '��� ��࠭���� ������ ���饭�� ����� ������� "ᨬ�⮬���᪮� ��祭��"' )
          Elseif onkus->USL_TIP == 6 .and. onksl->ds1_t != 5
            AAdd( ta, '��� ��࠭���� ������ ���饭�� ����� ������� ��祭�� "�������⨪�"' )
          Endif
        Endif
        Select ONKUS
        Skip
      Enddo
      If Empty( arr_onk_usl )
        //
        // ���������஢�� �६���� 13.02.22 ���� �� ࠧ������
        //
        // if iif(human_2->VMP == 1, .t., between(onksl->ds1_t, 0, 2)) .and. empty(alltrim(human_2->PC3))
        // aadd(ta, '�� ������� ���������᪮� ��祭��')
        // endif
      Elseif eq_ascan( arr_onk_usl, 2, 4 )
        If Empty( onksl->crit )
          AAdd( ta, '�� ������� �奬� ������⢥���� �࠯��' )
        Else
          // ��ࠢ���� ��室� �� ������ �ࠢ�筨�� Q015 13.01.23
          // if human->vzros_reb  > 0 .or. is_lymphoid(mdiagnoz[1]) // �᫨ ॡ񭮪 ��� ��� �஢�⢮ୠ� ��� ���䮨����
          If human->vzros_reb  > 0 // �᫨ ॡ񭮪
            If AllTrim( onksl->crit ) == '���'
              // ��� �ࠢ��쭮
            Else
              AAdd( ta, '��� ��⥩ ����� �奬� ��祭�� ����室��� 㪠�뢠�� "��� �奬� ������⢥���� �࠯��"' )
            Endif
          Else
            If AllTrim( onksl->crit ) == '���'
              AAdd( ta, '����� 㪠�뢠�� "��� �奬�", ����室��� 㪠�뢠�� �奬�' )
            Else
              // ��� �ࠢ��쭮
            Endif
          Endif
        Endif
        If Empty( onksl->wei )
          AAdd( ta, '�� ������� ���� ⥫� ��� ��࠭���� ⨯� ���������᪮�� ��祭��' )
        Elseif !( onksl->wei < 500 )
          AAdd( ta, '᫨誮� ������ ���� ⥫� ��� ��࠭���� ⨯� ���������᪮�� ��祭��' )
        Endif
        If Empty( onksl->hei )
          AAdd( ta, '�� ������ ��� ��樥�� ��� ��࠭���� ⨯� ���������᪮�� ��祭��' )
        Elseif !( onksl->hei < 260 )
          AAdd( ta, '᫨誮� ����让 ��� ��樥�� ��� ��࠭���� ⨯� ���������᪮�� ��祭��' )
        Endif
        If Empty( onksl->bsa )
          AAdd( ta, '�� ������� ���頤� �����孮�� ⥫� ��� ��࠭���� ⨯� ���������᪮�� ��祭��' )
        Elseif !( onksl->bsa < 6 )
          AAdd( ta, '᫨誮� ������ ���頤� �����孮�� ⥫� ��� ��࠭���� ⨯� ���������᪮�� ��祭��' )
        Endif
        arr_lek := {}
        fl := .t.
        // fl_zolend := .t.
        Select ONKLE
        find ( Str( human->kod, 7 ) )
        Do While onkle->kod == human->kod .and. !Eof()
          If Empty( onkle->REGNUM )
            AAdd( ta, '�� ������ �����䨪��� ������⢥����� �९��� - ��।������ c��᮪ ������⢥���� �९��⮢' )
            fl := .f.
            Exit
          Else
            If Empty( onkle->CODE_SH )
              AAdd( ta, '�� ������� �奬� ������⢥���� �࠯�� � ������⢠� - ��।������ c��᮪ ������⢥���� �९��⮢' )
              fl := .f.
              Exit
            Else
              If ( i := AScan( arr_lek, {| x| x[ 1 ] == onkle->REGNUM .and. x[ 2 ] == onkle->CODE_SH } ) ) == 0
                AAdd( arr_lek, { onkle->REGNUM, onkle->CODE_SH } )
              Endif
            Endif
            If Empty( onkle->DATE_INJ )
              AAdd( ta, '�� ������� ��� �������� �९��� - ��।������ c��᮪ ������⢥���� �९��⮢' )
              fl := .f.
              Exit
            Elseif !Between( onkle->DATE_INJ, dBegin, dEnd )
              AAdd( ta, '��� �������� �९��� ��室�� �� �ப� ��祭�� - ��।������ c��᮪ ������⢥���� �९��⮢' )
              fl := .f.
              Exit
            Endif
          Endif
          Select ONKLE
          Skip
        Enddo
        If fl
          If Empty( arr_lek )
            AAdd( ta, '�� �������� c��᮪ ������⢥���� �९��⮢' )
          Else
            // if fl_zolend
            // aadd(ta, '� ��⠢� ���� �������� 娬���࠯�� �� ����� ���� �ਬ���� ������ ���� �९��� �� ᯨ᪠ (�����஭���� ��᫮�, �����஭���� ��᫮�, �����஭���� ��᫮�, ����஭���� ��᫮� ��� �����㬠�)')
            // endif
            aN021 := getn021( dEnd )
            n := 0
            l_n021 := .f.
            For Each row in aN021
              If row[ 2 ] == onksl->crit
                l_n021 := .t.
                If ( i := AScan( arr_lek, {| x| x[ 1 ] == row[ 3 ] } ) ) > 0
                  ++n
                  // elseif onksl->is_err == 0
                  // aadd(ta, '�� �� �ᥬ �९��⠬ ������� ���� - ��।������ c��᮪ ������⢥���� �९��⮢')
                  // fl := .f.
                  // exit
                Endif
              Endif
            Next
            If l_n021
              If n != Len( arr_lek )
                AAdd( ta, '��।������ c��᮪ ������⢥���� �९��⮢' )
              Endif
            Endif
          Endif
        Endif
      Endif
    Endif
  Endif
  If is_mgi .and. l_mdiagnoz_fill .and. !( Left( mdiagnoz[ 1 ], 1 ) == 'C' )
    AAdd( ta, '��� ���� ���� �� �������୮� ����⨪� �᭮���� ������� ������ ���� C00-C97' )
  Endif
  mpztip := mpzkol := 0
  If !( Round( human->cena_1, 2 ) == Round( ssumma, 2 ) )
    AAdd( ta, '�㬬� ���� ' + lstr( human->cena_1 ) + ' �� ࠢ�� �㬬� ��� ' + lstr( ssumma ) )
    AAdd( ta, '�믮���� ������������������ � ��।������ ��㣨 � ���� ����' )
  Endif
  If Empty( au_lu )
    If Empty( au_flu )
      AAdd( ta, '�� ������� �� ����� ��㣨' )
    Else
      AAdd( ta, '�� ������� �᭮���� ��㣠, �� ������� ��������� �����ࠢ� ��' )
    Endif
  Endif
  If Empty( human_->profil )
    human_->profil := mprofil  // ᭠砫� ��䨫� �� ��ࢮ� ��㣨
  Endif
  If Empty( human_->profil )
    otd->( dbGoto( human->OTD ) )
    human_->profil := otd->profil  // �᫨ ���, � �� �⤥�����
  Endif
  If !Empty( human_->profil ) .and. human_->profil != correct_profil( human_->profil )
    human_->profil := correct_profil( human_->profil )
  Endif
  If l_mdiagnoz_fill .and. Left( mdiagnoz[ 1 ], 3 ) == 'O04' .and. eq_any( human_->profil, 136, 137 ) // �������� � �����������
    If !Between( human_2->pn2, 1, 2 )
      AAdd( ta, '��� �������� ' + AllTrim( mdiagnoz[ 1 ] ) + ' ��易⥫쭮 ���������, �����⢥���� ���뢠��� ��६������ �஢������� �� ����樭᪨� ��������� ��� ���' )
    Elseif human_2->pn2 == 1 .and. ( Len( mdiagnoz ) < 2 .or. Empty( mdiagnoz[ 2 ] ) )
      AAdd( ta, '��� �������� ' + AllTrim( mdiagnoz[ 1 ] ) + ' (�����⢥���� ���뢠��� ��६������ �� ����樭᪨� ���������) �� 㪠��� ᮯ������騩 �������' )
    Endif
  Endif
  If Empty( human_->VRACH ) .and. !( AScan( kod_LIS, glob_mo[ _MO_KOD_TFOMS ] ) > 0 .and. eq_any( human_->profil, 6, 34 ) )
    human_->VRACH := mvrach // ��� �� ��ࢮ� ��㣨
  Endif
  If AScan( kod_LIS, glob_mo[ _MO_KOD_TFOMS ] ) > 0 .and. eq_any( human_->profil, 6, 34 )
    mpzkol := Len( au_lu )
  Endif
  If AScan( kod_LIS, glob_mo[ _MO_KOD_TFOMS ] ) > 0 .and. eq_any( human_->profil, 6, 34 )
    If !Empty( human_2->PN3 )
      human->UCH_DOC := lstr( human_2->PN3 ) // ORDER �� ��� ��१����뢠�� (���� ��ࠢ���)
    Endif
    If !is_mgi
      human_->VRACH := 0
    Endif
    human_->PRVS := iif( human_->profil == 34, -13, -54 )
  Elseif human_->profil == 15   // ���⮫����
    human_->PRVS := -13 // ������᪠� ������ୠ� �������⨪�
  Elseif Empty( human_->VRACH )
    AAdd( ta, '�� ��������� ���� "���騩 ���"' )
  Else
    pers->( dbGoto( human_->VRACH ) )
    mprvs := -ret_new_spec( pers->prvs, pers->prvs_new )
    If Empty( mprvs ) .and. ( ! is_disp_DVN_COVID ) .and. ( ! is_disp_DRZ ) // ��ࠢ���� ��� 㣫㡫����� ��ᯠ��ਧ�樨 � ���
      AAdd( ta, '��� ᯥ樠�쭮�� � �ࠢ�筨�� ���ᮭ��� � "' + AllTrim( pers->fio ) + '"' )
    Elseif human_->PRVS != mprvs
      human_->PRVS := mprvs
    Endif
    If human_->PRVS > 0 .and. ret_v004_v015( human_->PRVS ) == 0
      AAdd( ta, '�� ������� ᯥ樠�쭮�� � �ࠢ�筨�� � "' + AllTrim( pers->fio ) + '"' )
    Endif

    arr_perso := addkoddoctortoarray( arr_perso, human_->VRACH )

  Endif
  For i := 1 To Len( arr_perso )
    pers->( dbGoto( arr_perso[ i ] ) )
    If pers->tab_nom != 0 // �������� ��� 㣫㡫����� ��ᯠ��ਧ�樨
      mvrach := fam_i_o( pers->fio ) + ' [' + lstr( pers->tab_nom ) + ']'
      If Empty( pers->snils )
        AAdd( ta, '�� ������ ����� � ��� - ' + mvrach )
      Else
        s := Space( 80 )
        If !val_snils( pers->snils, 2, @s )
          AAdd( ta, s + ' � ��� - ' + mvrach )
        Endif
      Endif
    Endif
  Next
  If Empty( human_->USL_OK )
    human_->USL_OK := musl_ok
  Elseif mUSL_OK > 0 .and. human_->USL_OK != mUSL_OK
    AAdd( ta, '� ���� "�᫮��� ��������" ������ ���� "' + inieditspr( A__MENUVERT, getv006(), mUSL_OK ) + '"' )
  Endif
  If human_->USL_OK == USL_OK_POLYCLINIC // ��� �����������
    s := Space( 80 )
    If !vr_pr_1_den( 2, @s, u_other )
      AAdd( ta, s )
    Endif
  Endif
  If human_->USL_OK == USL_OK_HOSPITAL .and. SubStr( human_->FORMA14, 1, 1 ) == '0'
    If Empty( human_->NPR_MO )
      AAdd( ta, '�� �������� ��ᯨ⠫���樨 ������ ���� ��������� ���� "���ࠢ���� ��"' )
    Elseif Empty( human_2->NPR_DATE )
      If glob_mo[ _MO_KOD_TFOMS ] == ret_mo( human_->NPR_MO )[ _MO_KOD_TFOMS ]
        human_2->NPR_DATE := dBegin
      Else
        AAdd( ta, '������ ���� ��������� ���� "��� ���ࠢ����� �� ��ᯨ⠫�����"' )
      Endif
    Elseif human_2->NPR_DATE > dBegin
      AAdd( ta, '"��� ���ࠢ����� �� ��ᯨ⠫�����" ����� "���� ��砫� ��祭��"' )
    Elseif human_2->NPR_DATE + 60 < dBegin
      AAdd( ta, '���ࠢ����� �� ��ᯨ⠫����� ����� ���� ����楢' )
    Endif
  Endif
  If eq_any( human_->USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL )
    i := human_2->p_per
    If !Between( human_2->p_per, 1, 4 ) // �᫨ �� �������
      i := iif( SubStr( human_->FORMA14, 2, 1 ) == '1', 2, 1 )
    Elseif SubStr( human_->FORMA14, 2, 1 ) == '1' // �᫨ ᪮�� ������
      i := 2
    Elseif !( SubStr( human_->FORMA14, 2, 1 ) == '1' ) // �᫨ �� ᪮�� ������
      If i == 2 // �᫨ ᪮�� ������
        i := 1
      Endif
    Endif
    If i != human_2->p_per
      human_2->p_per := i
    Endif
  Endif
  If kkt == 0 .and. eq_any( human_->USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL ) .and. Len( a_srok_lech ) > 0
    For i := 1 To Len( a_srok_lech )
      otd->( dbGoto( a_srok_lech[ i, 4 ] ) )
      If a_srok_lech[ i, 5 ] == 0
        otd->( dbGoto( a_srok_lech[ i, 4 ] ) )
        AAdd( ta, '����祭�� ' + date_8( a_srok_lech[ i, 1 ] ) + '-' + date_8( a_srok_lech[ i, 2 ] ) + ;
          iif( Empty( otd->short_name ), '', ' [' + AllTrim( otd->short_name ) + ']' ) )
      Endif
    Next
  Endif
  If fl_stom
    mpzkol := 1
    If f_vid_p_stom( au_lu, ta, , , dEnd, @ltip, @lkol, @is_2_88, au_flu )
      Do Case
      Case ltip == 1 // � ��祡��� 楫��
        mpztip := 65
        If lkol < 2
          AAdd( ta, '�� ���饭�� �� ������ ����������� ������ ���� �� ����� ���� ���饭�� � ����-�⮬�⮫���' )
        Elseif AScan( au_lu, {| x| AllTrim( x[ 1 ] ) == '2.78.55' } ) > 0 .and. ;
            eq_any( Left( human->KOD_DIAG, 3 ), 'K05', 'K06' ) .and. lkol < 5
          AAdd( ta, '�� ���饭�� �� ������ ����������� ��த��� ������ ���� �� ����� ���� ���饭�� � ����-�⮬�⮫���' )
        Elseif human->KOD_DIAG == 'Z01.2'
          AAdd( ta, '�᭮���� ������� Z01.2 �ਬ������ �� ���饭�� � ��䨫����᪮� 楫�� � �⮬�⮫����, � � ��砥 - �� ������ �����������' )
        Endif
      Case ltip == 2 // � ��䨫����᪮� 楫�� ��� ࠧ���� �� ������ �����������
        mpztip := 63
        If lkol != 1
          AAdd( ta, '�� ���饭�� � ��䨫����᪮� 楫�� ������ ���� ���� ���饭�� � ����-�⮬�⮫���' )
        Elseif is_2_88 .and. human->KOD_DIAG == 'Z01.2'
          AAdd( ta, '�� ࠧ���� ���饭�� �� ������ ����������� � �⮬�⮫���� �᭮���� ������� �� ������ ���� Z01.2' )
        Elseif !is_2_88 .and. !( human->KOD_DIAG == 'Z01.2' )
          AAdd( ta, '�� ���饭�� � ��䨫����᪮� 楫�� � �⮬�⮫���� �᭮���� ������� �ᥣ�� Z01.2' )
        Endif
        If !is_2_88
          human_->RSLT_NEW := 314
          human_->ISHOD_NEW := 304
        Endif
      Case ltip == 3 // �� �������� ���⫮���� �����
        mpztip := 64
        If lkol != 1
          AAdd( ta, '�� ���⫮���� ���饭�� ������ ���� ���� ���饭�� � ����-�⮬�⮫���' )
        Elseif human->KOD_DIAG == 'Z01.2'
          AAdd( ta, '�᭮���� ������� Z01.2 �ਬ������ �� ���饭�� � ��䨫����᪮� 楫�� � �⮬�⮫����, � � ��砥 - ���⫮����' )
        Endif
      Endcase
      If ltip > 1 .and. dBegin != dEnd
        AAdd( ta, iif( ltip == 2, '�� ���饭�� � ��䨫����᪮� 楫��', '�� ���⫮���� ���饭��' ) + ' ��� ����砭�� ������ ࠢ������ ��� ��砫� ��祭��' )
      Endif
    Endif
  Endif
  If human_->USL_OK == USL_OK_HOSPITAL  // 1 - ��樮���
    If human_2->VNR > 0 .and. !Between( human_2->VNR, 301, 2499 )
      AAdd( ta, '��� ������襭���� ॡ񭪠 ������ ���� ����� 300 � � ����� 2500 �' )
    Endif
    For i := 1 To 3
      pole := 'human_2->VNR' + lstr( i )
      if &pole > 0 .and. !Between( &pole, 301, 2499 )
        AAdd( ta, '��� ' + lstr( i ) + '-�� ������襭���� ॡ񭪠 ������ ���� ����� 300 � � ����� 2500 �' )
      Endif
    Next
    If kol_ksg > 1
      AAdd( ta, '������� ����� ����� ���' )
    Endif
    mpztip := 52 // 52, '���砩 ��ᯨ⠫���樨', '���.���.'}, ;
    mpzkol := kkd_1_11
    If ( i := dEnd - dBegin ) == 0
      i := 1
    Endif
    If kkd_1_11 != i
      AAdd( ta, '������⢮ �����-���� 1.11.* ������ ࠢ������ ' + lstr( i ) )
    Elseif is_reabil // ॠ�������
      mpztip := 53 // 53, '��砩 ��ᯨ⠫���樨 �� ॠ�����樨', '���.ॠ�.'}, ;
      If human_2->VMP == 1 // �᫨ ��⠭����� ���
        AAdd( ta, '�� ॠ�����樨 �� ����� ���� ������� ���' )
      Endif
      a_1_11 := {}
      For i := 1 To Len( au_lu )
        If Left( au_lu[ i, 1 ], 5 ) == '1.11.'
          If !( AllTrim( au_lu[ i, 1 ] ) == '1.11.2' )
            AAdd( ta, '����ୠ� ��㣠 ' + au_lu[ i, 1 ] )
          Endif
          AAdd( a_1_11, { au_lu[ i, 2 ], ;
            au_lu[ i, 7 ], ;
            au_lu[ i, 3 ], ;
            au_lu[ i, 4 ], ;
            au_lu[ i, 6 ] } )
        Endif
      Next
      If Len( a_1_11 ) == 1
        If a_1_11[ 1, 1 ] != dBegin
          AAdd( ta, '��� ��砫� ��㣨 1.11.2 ������ ࠢ������ ��� ��砫� ��祭��' )
        Endif
        If a_1_11[ 1, 2 ] != dEnd
          AAdd( ta, '��� ����砭�� ��㣨 1.11.2 ������ ࠢ������ ��� ����砭�� ��祭��' )
        Endif
      Else
        AAdd( ta, '��㣠 1.11.2 ������ ��������� ���� ࠧ' )
      Endif
    Else // ��⠫�� �����-���
      a_1_11 := {}
      For i := 1 To Len( au_lu )
        If Left( au_lu[ i, 1 ], 5 ) == '1.11.'
          If !( AllTrim( au_lu[ i, 1 ] ) == '1.11.1' )
            AAdd( ta, '����ୠ� ��㣠 ' + au_lu[ i, 1 ] )
          Endif
          AAdd( a_1_11, { au_lu[ i, 2 ], ;
            au_lu[ i, 7 ], ;
            au_lu[ i, 3 ], ;
            au_lu[ i, 4 ], ;
            au_lu[ i, 6 ] } )
        Endif
      Next
      If Len( a_1_11 ) > 0
        ASort( a_1_11, , , {| x, y| x[ 1 ] < y[ 1 ] } )
        If a_1_11[ 1, 1 ] != dBegin
          AAdd( ta, '��� ��砫� ��ࢮ� ��㣨 1.11.1 ������ ࠢ������ ��� ��砫� ��祭��' )
        Endif
        For i := 2 To Len( a_1_11 )
          If a_1_11[ i - 1, 2 ] != a_1_11[ i, 1 ]
            AAdd( ta, '��� ��砫� ' + lstr( i ) + '-� ��㣨 1.11.1 ������ ࠢ������ ' + date_8( a_1_11[ i - 1, 2 ] ) )
          Endif
        Next
        If ATail( a_1_11 )[ 2 ] != dEnd
          AAdd( ta, '��� ����砭�� ��᫥���� ��㣨 1.11.1 ������ ࠢ������ ��� ����砭�� ��祭��' )
        Endif
      Endif
    Endif
    fl := .t.
    If Empty( human_->profil )
      AAdd( ta, '� ��砥 �� ���⠢��� ��䨫�' )
    Elseif Empty( human_->PRVS )
      AAdd( ta, '� ���饣� ��� � ��砥 �� ���⠢���� ᯥ樠�쭮���' )
    Elseif is_reabil // ॠ�������
      a_1_11 := {}
      For i := 1 To Len( au_lu )
        If Left( au_lu[ i, 1 ], 5 ) == '1.11.'
          AAdd( a_1_11, { AllTrim( au_lu[ i, 8 ] ), ;
            au_lu[ i, 3 ], ;
            au_lu[ i, 4 ] } )
        Endif
      Next
      fl := .f.
      For i := 1 To Len( a_1_11 )
        If l_mdiagnoz_fill .and. AllTrim( mdiagnoz[ 1 ] ) == a_1_11[ i, 1 ] .and. human_->PRVS == a_1_11[ i, 3 ]
          fl := .t.
          Exit
        Endif
      Next
    Else // ��⠫�� �����-���
      If human_->profil == 158
        AAdd( ta, '� ��砥 ����� �ᯮ�짮���� ��䨫� ��: ' + inieditspr( A__MENUVERT, getv002(), 158 ) )
      Endif
      a_1_11 := {}
      For i := 1 To Len( au_lu )
        If Left( au_lu[ i, 1 ], 5 ) == '1.11.'
          AAdd( a_1_11, { AllTrim( au_lu[ i, 8 ] ), ;
            au_lu[ i, 3 ], ;
            au_lu[ i, 4 ] } )
        Endif
      Next
      For i := 1 To Len( au_flu )
        AAdd( a_1_11, { AllTrim( au_flu[ i, 8 ] ), ;
          au_flu[ i, 3 ], ;
          au_flu[ i, 4 ] } )
      Next
      fl := .f.
      For i := 1 To Len( a_1_11 )
        If l_mdiagnoz_fill .and. AllTrim( mdiagnoz[ 1 ] ) == a_1_11[ i, 1 ] .and. ;
            human_->profil == a_1_11[ i, 2 ] .and. human_->PRVS == a_1_11[ i, 3 ]
          If a_1_11[ i, 2 ] == 158
            AAdd( ta, '� ��㣥 ����� �ᯮ�짮���� ��䨫� ��: ' + inieditspr( A__MENUVERT, getv002(), 158 ) )
          Endif
          fl := .t. ; Exit
        Endif
      Next
    Endif
    ar_1_19_1 := {} ; fl_19 := .f.
    For i := 1 To Len( au_lu )
      If Left( au_lu[ i, 1 ], 5 ) == '1.19.'
        If l_mdiagnoz_fill .and. AllTrim( mdiagnoz[ 1 ] ) == AllTrim( au_lu[ i, 8 ] ) .and. ;
            human_->profil == au_lu[ i, 3 ] .and. human_->PRVS == au_lu[ i, 4 ]
          fl_19 := .t.
        Endif
        AAdd( ar_1_19_1, au_lu[ i, 2 ] )
        If au_lu[ i, 6 ] > 1
          AAdd( ta, '� ��㣥 1.19.1 (' + DToC( au_lu[ i, 2 ] ) + ') ������⢮ ����� 1' )
        Endif
      Endif
    Next
    If !( fl .or. fl_19 )
      AAdd( ta, '� ����� �� ��� 1.11.*(1.19.1) ������ ��������� �������+��䨫�+��� �� ����' )
    Endif
    For j := 1 To Len( ar_1_19_1 )
      fl := .t.
      For i := 1 To Len( au_lu )
        If Left( au_lu[ i, 1 ], 5 ) == '1.11.' .and. eq_any( ar_1_19_1[ j ], au_lu[ i, 2 ], au_lu[ i, 7 ] )
          fl := .f.
          Exit
        Endif
      Next
      If fl
        AAdd( ta, '��� ��㣨 1.19.1 (' + DToC( ar_1_19_1[ j ] ) + ') ��易⥫쭮 ������ ࠢ������ ��� ��砫�/����砭�� ����� �� ��� 1.11.1/1.11.2' )
      Endif
    Next
    If human_2->VMP == 1 // �஢�ਬ ���
      If is_MO_VMP  // �᫨ ���� ��㣨 ��� ��� ��०�����
        arrV018 := getv018( human->k_data )
        arrV019 := getv019( human->k_data )
        If !Empty( ar_1_19_1 )
          AAdd( ta, '�� �������� ��� �� ����� ���� �ਬ����� ��㣠 1.19.1' )
        Endif
        If Empty( human_2->TAL_NUM )
          AAdd( ta, '��� �������, �� �� ������ ����� ⠫��� �� ���' )
        Elseif ( human->k_data > 0d20220101 ) .and. !Empty( human_2->TAL_NUM ) .and. !valid_number_talon( human_2->TAL_NUM, human->k_data, .f. )
          AAdd( ta, '��� �������, �� �ଠ� ����� ⠫��� �� ��� �� ��७ (蠡��� 99.9999.99999.999)' )
        Endif
        If Empty( human_2->TAL_D )
          AAdd( ta, '��� �������, �� �� ������� ��� �뤠� ⠫��� �� ���' )
        Elseif !eq_any( Year( human_2->TAL_D ), yearEnd - 1, yearEnd, yearEnd + 1 )
          AAdd( ta, '��� �뤠� ⠫��� �� ��� (' + date_8( human_2->TAL_D ) + ') ������ ���� � ⥪�饬 ��� ��諮� ����' )
        Endif
        If Empty( human_2->TAL_P )
          AAdd( ta, '��� �������, �� �� ������� ��� ������㥬�� ��ᯨ⠫���樨 � ᮮ⢥��⢨� � ⠫���� �� ���' )
        Elseif !eq_any( Year( human_2->TAL_P ), yearEnd - 1, yearEnd, yearEnd + 1 )
          AAdd( ta, '��� ������㥬�� ��ᯨ⠫���樨 � ᮮ⢥��⢨� � ⠫���� �� ��� (' + date_8( human_2->TAL_P ) + ') ������ ���� � ⥪�饬 ��� ��諮� ����' )
        Endif
        If Empty( human_2->VIDVMP )
          AAdd( ta, '��� �������, �� �� ����� ��� ���' )
        Elseif AScan( arrV018, {| x| x[ 1 ] == AllTrim( human_2->VIDVMP ) } ) == 0
          AAdd( ta, '�� ������ ��� ��� "' + human_2->VIDVMP + '" � �ࠢ�筨�� V018' )
        Elseif Empty( human_2->METVMP )
          AAdd( ta, '��� �������, ����� ��� ���, �� �� ����� ��⮤ ���' )
        Elseif ( ( i := AScan( arrV019, {| x| x[ 1 ] == human_2->METVMP } ) ) > 0 ) .and. ( Year( human->k_data ) == 2020 )
          If arrV019[ i, 4 ] == AllTrim( human_2->VIDVMP )
            If !( ! ( l_mdiagnoz_fill ) .or. Empty( mdiagnoz[ 1 ] ) )
              fl := .f.
              s := PadR( mdiagnoz[ 1 ], 6 )
              For j := 1 To Len( arrV019[ i, 3 ] )
                If Left( s, Len( arrV019[ i, 3, j ] ) ) == arrV019[ i, 3, j ]
                  fl := .t.
                  Exit
                Endif
              Next
              If fl
                If Empty( mpztip := ret_pz_vmp( human_2->METVMP, human->k_data ) )
                  mpztip := 1
                Endif
              Else
                AAdd( ta, '�᭮���� ������� ' + s + ', � � ��⮤� ��� "' + lstr( human_2->METVMP ) + '.' + AllTrim( arrV019[ i, 2 ] ) + '"' )
                AAdd( ta, '�Ĥ����⨬� ��������: ' + print_array( arrV019[ i, 3 ] ) )
              Endif
            Endif
          Else
            AAdd( ta, '��⮤ ��� ' + lstr( human_2->METVMP ) + ' �� ᮮ⢥����� ���� ��� ' + human_2->VIDVMP )
          Endif
          // elseif ((i := ascan(arrV019, {|x| x[1] == human_2->METVMP .and. x[8] == human_2->PN5 })) > 0) .and. (year(human->k_data)>=2021)
        Elseif ( ( i := AScan( arrV019, {| x| x[ 1 ] == human_2->METVMP .and. x[ 8 ] == human_2->PN5 .and. x[ 4 ] == AllTrim( human_2->VIDVMP ) } ) ) > 0 ) .and. ( Year( human->k_data ) >= 2021 )
          If ( arrV019[ i, 4 ] == AllTrim( human_2->VIDVMP ) ) // .or. (arrV019[i, 4] == '26' .and. alltrim(human_2->VIDVMP) == '27')

            If !( !( l_mdiagnoz_fill ) .or. Empty( mdiagnoz[ 1 ] ) )
              fl := .f. ; s := PadR( mdiagnoz[ 1 ], 6 )
              For j := 1 To Len( arrV019[ i, 3 ] )
                If Left( s, Len( arrV019[ i, 3, j ] ) ) == arrV019[ i, 3, j ]
                  fl := .t. ; Exit
                Endif
              Next
              If fl
                If Empty( mpztip := ret_pz_vmp( human_2->METVMP, human->k_data ) )
                  mpztip := 1
                Endif
              Else
                AAdd( ta, '�᭮���� ������� ' + s + ', � � ��⮤� ��� "' + lstr( human_2->METVMP ) + '.' + AllTrim( arrV019[ i, 2 ] ) + '"' )
                AAdd( ta, '�Ĥ����⨬� ��������: ' + print_array( arrV019[ i, 3 ] ) )
              Endif
            Endif
          Else
            AAdd( ta, '��⮤ ��� ' + lstr( human_2->METVMP ) + ' �� ᮮ⢥����� ���� ��� ' + human_2->VIDVMP )
          Endif
        Else
          AAdd( ta, '�� ������ ��⮤ ��� ' + lstr( human_2->METVMP ) + ' � �ࠢ�筨�� V019' )
        Endif
      Else
        human_2->VMP     := 0
        human_2->VIDVMP  := ''
        human_2->METVMP  := 0
        human_2->TAL_NUM := ''
        human_2->TAL_D   := CToD( '' )
        human_2->TAL_P   := CToD( '' )
      Endif
    Endif
    // ������� ��ਮ�, �᫨ ��稫�� � ��樮���
    AAdd( a_period_stac, { human->n_data, ;
      human->k_data, ;
      human_->USL_OK, ;
      human->OTD, ;
      human->kod_diag, ;
      human_->profil, ;
      human_->RSLT_NEW, ;
      human_->ISHOD_NEW, ;
      iif( is_s_dializ, 1, 0 ) } )
  Elseif human_->USL_OK == USL_OK_DAY_HOSPITAL .and. kol_ksg > 0 // ������� ��樮���
    If kol_ksg > 1
      AAdd( ta, '������� ����� ����� ���' )
    Endif
    mpztip := 55 // 55, '��砩 ��祭��', '���.��祭'}, ;
    mpzkol := kol_55_1
    If Empty( kol_55_1 )
      AAdd( ta, '�� ������� ��㣠 ��樥��-���� 55.1.*' )
    Elseif is_reabil // ॠ�������
      a_1_11 := {}
      For i := 1 To Len( au_lu )
        If Left( au_lu[ i, 1 ], 5 ) == '55.1.'
          If !( AllTrim( au_lu[ i, 1 ] ) == '55.1.4' )
            AAdd( ta, '����ୠ� ��㣠 ' + RTrim( au_lu[ i, 1 ] ) + ', ������ ���� 55.1.4' )
          Endif
          AAdd( a_1_11, { au_lu[ i, 2 ], ;  // 1-mdate
          au_lu[ i, 7 ], ;  // 2-c4tod(mdate_u2)
          au_lu[ i, 3 ], ;  // 3-hu_->profil
          au_lu[ i, 4 ], ;  // 4-hu_->PRVS
          au_lu[ i, 6 ], ;  // 5-hu->kol_1
          au_lu[ i, 9 ] } )  // 6-����� �����
        Endif
      Next
      If Len( a_1_11 ) == 1
        If a_1_11[ 1, 1 ] != dBegin
          AAdd( ta, '��� ��砫� ��㣨 55.1.4 ������ ࠢ������ ��� ��砫� ��祭��' )
        Endif
        If a_1_11[ 1, 2 ] != dEnd
          Select HU
          Goto ( a_1_11[ 1, 6 ] )
          hu_->( my_rec_lock( a_1_11[ 1, 6 ] ) )
          hu_->date_u2 := cd2
        Endif
      Else
        AAdd( ta, '��㣠 55.1.4 ������ ��������� ���� ࠧ' )
      Endif
    Else // ��⠫�� �����-���
      a_1_11 := {}
      s := ''
      For i := 1 To Len( au_lu )
        If Left( au_lu[ i, 1 ], 5 ) == '55.1.'
          If Empty( s )
            s := au_lu[ i, 1 ]
          Endif
          If !( au_lu[ i, 1 ] == s ) // �� ᬥ訢��� ࠧ�� 55.1.*
            AAdd( ta, '����ୠ� ��㣠 ' + au_lu[ i, 1 ] )
          Elseif !eq_any( AllTrim( au_lu[ i, 1 ] ), '55.1.1', '55.1.2', '55.1.3' )
            AAdd( ta, '����ୠ� ��㣠 ' + RTrim( au_lu[ i, 1 ] ) )
          Endif
          AAdd( a_1_11, { au_lu[ i, 2 ], ;   // 1-mdate
          au_lu[ i, 7 ], ;   // 2-c4tod(mdate_u2)
          au_lu[ i, 3 ], ;   // 3-hu_->profil
          au_lu[ i, 4 ], ;   // 4-hu_->PRVS
          au_lu[ i, 6 ], ;   // 5-hu->kol_1
          au_lu[ i, 9 ] } )   // 6-����� �����
        Endif
      Next
      If ( k := Len( a_1_11 ) ) > 0
        ASort( a_1_11, , , {| x, y| x[ 1 ] < y[ 1 ] } )
        If a_1_11[ 1, 1 ] != dBegin
          AAdd( ta, '��� ��砫� ��ࢮ� ��㣨 55.1.* ������ ࠢ������ ��� ��砫� ��祭��' )
        Endif
        For i := 2 To k
          // 1-��� ����砭�� �।.��㣨 = ��� ��砫� ᫥�.��㣨 ����� 1
          a_1_11[ i - 1, 2 ] := a_1_11[ i, 1 ] - 1
          // 2-��� ����砭�� �।.��㣨 = ��� ��砫� �।.��㣨 + ��� - 1
          d := a_1_11[ i - 1, 1 ] + a_1_11[ i - 1, 5 ] - 1
          If d > a_1_11[ i - 1, 2 ]
            AAdd( ta, '��� ��砫� ' + lstr( i ) + '-� ��㣨 55.1.* ������ ࠢ������ ' + date_8( d + 1 ) )
          Endif
        Next
        If Empty( ta ) // ��� �訡��
          For i := 1 To k
            Select HU
            Goto ( a_1_11[ i, 6 ] )
            hu_->( my_rec_lock( a_1_11[ i, 6 ] ) )
            If i == k
              a_1_11[ i, 2 ] := dEnd   // ��� ��᫥���� ��㣨
              hu_->date_u2 := cd2 // ���⠢�� ���� ����砭�� ��祭��
              d := a_1_11[ i, 1 ] + a_1_11[ i, 5 ] - 1
              If d > dEnd
                AAdd( ta, '��� ����砭�� ��᫥���� ��㣨 55.1.* ����� ���� ����砭�� ��祭�� ' + date_8( d ) )
              Endif
            Else
              hu_->date_u2 := dtoc4( a_1_11[ i, 2 ] ) // ��९�襬 ���� ����砭��
            Endif
          Next
        Endif
      Endif
    Endif
    If Empty( human_->profil )
      AAdd( ta, '� ��砥 �� ���⠢��� ��䨫�' )
    Elseif Empty( human_->PRVS )
      AAdd( ta, '� ���饣� ��� � ��砥 �� ���⠢���� ᯥ樠�쭮���' )
    Elseif is_reabil // ॠ�������
      a_1_11 := {}
      For i := 1 To Len( au_lu )
        If Left( au_lu[ i, 1 ], 5 ) == '55.1.'
          AAdd( a_1_11, { AllTrim( au_lu[ i, 8 ] ), ;
            au_lu[ i, 3 ], ;
            au_lu[ i, 4 ] } )
        Endif
      Next
      fl := .f.
      For i := 1 To Len( a_1_11 )
        If l_mdiagnoz_fill .and. AllTrim( mdiagnoz[ 1 ] ) == a_1_11[ i, 1 ] .and. human_->PRVS == a_1_11[ i, 3 ]
          fl := .t.
          Exit
        Endif
      Next
      If !fl
        AAdd( ta, '� ��㣥 55.1.4 ������ ��������� �������+��� �� ����' )
      Endif
    Else // ��⠫�� �����-���
      a_1_11 := {}
      For i := 1 To Len( au_lu )
        If Left( au_lu[ i, 1 ], 5 ) == '55.1.'
          AAdd( a_1_11, { AllTrim( au_lu[ i, 8 ] ), ;
            au_lu[ i, 3 ], ;
            au_lu[ i, 4 ] } )
        Endif
      Next
      For i := 1 To Len( au_flu )
        AAdd( a_1_11, { AllTrim( au_flu[ i, 8 ] ), ;
          au_flu[ i, 3 ], ;
          au_flu[ i, 4 ] } )
      Next
      fl := .f.
      For i := 1 To Len( a_1_11 )
        If l_mdiagnoz_fill .and. AllTrim( mdiagnoz[ 1 ] ) == a_1_11[ i, 1 ] .and. ;
            human_->profil == a_1_11[ i, 2 ] .and. human_->PRVS == a_1_11[ i, 3 ]
          fl := .t.
          Exit
        Endif
      Next
      If !fl
        AAdd( ta, '� ����� �� ��� 55.1.* ������ ��������� �������+��䨫�+��� �� ����' )
      Endif
    Endif
    If !Empty( lvidpoms )
      If AScan( au_lu, {| x| AllTrim( x[ 1 ] ) == '55.1.2' } ) > 0 .or. ;
          AScan( au_lu, {| x| AllTrim( x[ 1 ] ) == '55.1.3' } ) > 0
        //
        //
        If AScan( au_lu, {| x| AllTrim( x[ 1 ] ) == '55.1.3' } ) > 0
          lvidpoms := ret_vidpom_st_dom_licensia( human_->USL_OK, lvidpoms, lprofil )
        Endif
      Else // ⮫쪮 ��� ��.��樮��� �� ��樮��� ᬮ�ਬ ��業���
        lvidpoms := ret_vidpom_licensia( human_->USL_OK, lvidpoms )
      Endif
      If ',' $ lvidpoms
        If AScan( au_lu, {| x| AllTrim( x[ 1 ] ) == '55.1.1' } ) > 0 .or. ;
            AScan( au_lu, {| x| AllTrim( x[ 1 ] ) == '55.1.4' } ) > 0 .or. ;
            AScan( au_lu, {| x| AllTrim( x[ 1 ] ) == '55.1.6' } ) > 0
          If !( '31' $ lvidpoms )
            AAdd( ta, '��� ���=' + shifr_ksg + ' � �ࠢ�筨�� �006 �� ����� ��� ����� 31' )
          Endif
        Else
          If eq_any( human_->PROFIL, 57, 68, 97 ) // �࠯��,�������,��� ���.�ࠪ⨪�
            If !( '12' $ lvidpoms )
              AAdd( ta, '��� ���=' + shifr_ksg + ' � �ࠢ�筨�� �006 �� ����� ��� ����� 12; ' + ;
                '����⭮, � ��砥 �� ����� ����� ��䨫� "�࠯���", "�������", "��� ���.�ࠪ⨪�"' )
            Endif
          Else
            If !( '13' $ lvidpoms )
              AAdd( ta, '��� ���=' + shifr_ksg + ' � �ࠢ�筨�� �006 �� ����� ��� ����� 13; ' + ;
                '���⠢�� � ��砥 ��䨫� "�࠯���", "�������", "��� ���.�ࠪ⨪�" ' + ;
                '��� ������ � ����� �� �訡�� � �ࠢ�筨��' )
            Endif
          Endif
        Endif
      Endif
    Endif
  Endif
  If Len( a_period_stac ) > 0 // .and. !is_s_dializ .and. !is_dializ .and. !is_perito
    Select HU
    find ( Str( human->kod, 7 ) )
    Do While hu->kod == human->kod .and. !Eof()
      AAdd( u_other, { hu->u_kod, hu->date_u, hu->kol_1, hu_->profil, 0, human->n_data, human->k_data, human->OTD } )
      Select HU
      Skip
    Enddo
    Select HU
    Set Relation To
    For i := 1 To Len( u_other )
      If u_other[ i, 5 ] == 0
        usl->( dbGoto( u_other[ i, 1 ] ) )
        lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
        If is_usluga_tfoms( usl->shifr, lshifr1, u_other[ i, 7 ] )
          mdate := c4tod( u_other[ i, 2 ] )
          If ( k := AScan( a_period_stac, {| x| x[ 1 ] < mdate .and. mdate < x[ 2 ] } ) ) > 0
            lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
            If ( Left( lshifr, 2 ) == '2.' .or. eq_any( Left( lshifr, 3 ), '60.', '70.', '71.', '72.' ) ) ;
                .and. !( Left( lshifr, 5 ) == '60.3.' ) ;
                .and. !( Left( lshifr, 6 ) == '60.10.' ) ;
                .and. is_2_stomat( lshifr, , .t. ) == 0 // �� �⮬�⮫����
              otd->( dbGoto( u_other[ i, 8 ] ) )
              AAdd( ta, '��㣠 ' + AllTrim( usl->shifr ) + ' �� ' + date_8( mdate ) + ' � ��砥 ' + ;
                date_8( u_other[ i, 6 ] ) + '-' + date_8( u_other[ i, 7 ] ) + ;
                iif( Empty( otd->short_name ), '', ' [' + AllTrim( otd->short_name ) + ']' ) )
              otd->( dbGoto( a_period_stac[ k, 4 ] ) )
              AAdd( ta, '�>���ᥪ����� 222 � ��砥� ���.��祭�� ' + ;
                date_8( a_period_stac[ k, 1 ] ) + '-' + date_8( a_period_stac[ k, 2 ] ) + ;
                iif( Empty( otd->short_name ), '', ' [' + AllTrim( otd->short_name ) + ']' ) )
            Endif
          Endif
        Endif
      Endif
    Next i
    Select HU
    Set Relation To RecNo() into HU_, To u_kod into USL
  Endif

  u_other := {}
  lshifr := ''
  lshifr1 := ''

  If eq_any( human_->USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL ) .and. kol_ksg > 0 .and. human_2->VMP == 0 // �� ���
    k_data2 := human->k_data
    If human->ishod == 88
      s := '�� ������� ��砩 - �� ����稢����� ' + date_8( k_data2 ) + '; '
      Select HUMAN
      Goto ( human_2->pn4 ) // ��뫪� �� 2-� ���� ����
      k_data2 := human->k_data // ��९�ᢠ����� ���� ����砭�� ��祭��
      Goto ( rec_human )
      lDoubleSluch := .t.
    Else
      s := ''
    Endif
    arr_ksg := definition_ksg( 1, k_data2, lDoubleSluch )
    If Empty( arr_ksg[ 2 ] ) // ��� �訡��
      If shifr_ksg == arr_ksg[ 3 ] // ��� ��।����� �ࠢ��쭮
        If !( Round( cena_ksg, 2 ) == Round( arr_ksg[ 4 ], 2 ) ) // �� � 業�
          AAdd( ta, s + '� �/� ��� ���=' + arr_ksg[ 3 ] + ' �⮨� 業� ' + lstr( cena_ksg, 10, 2 ) + ', � ������ ���� ' + lstr( arr_ksg[ 4 ], 10, 2 ) )
        Else
          put_str_kslp_kiro( arr_ksg, .f. )
        Endif
      Else // �� �� ��� ���
        AAdd( ta, s + '� �/� �⮨� ���=' + AllTrim( shifr_ksg ) + '(' + lstr( cena_ksg, 10, 2 ) + '), � ������ ���� ' + arr_ksg[ 3 ] + '(' + lstr( arr_ksg[ 4 ], 10, 2 ) + ')' )
      Endif
    Else
      AEval( arr_ksg[ 2 ], {| x| AAdd( ta, s + x ) } )
    Endif
  Endif
  // �஢�ਬ ��ਮ�, �᫨ ��稫�� ���㫠�୮
  If human_->USL_OK == USL_OK_POLYCLINIC .and. human->ishod < 101 ;// �� ��ᯠ��ਧ���
    .and. m1novor == human_->NOVOR ;
      .and. !( is_2_80 .or. is_2_82 ) ;// �� ���⫮���� ������
    .and. !( AScan( kod_LIS, glob_mo[ _MO_KOD_TFOMS ] ) > 0 .and. eq_any( human_->profil, 6, 34 ) ) ; // �� ���2
    .and. kkt == 0 ; // �� �⤥�쭮 ����� ���.��楤��
    .and. Len( a_period_amb ) > 0
    For i := 1 To Len( a_period_amb )
//      If a_period_amb[ i, 3 ] == human_->profil .and. !( human_->profil != 122 .or. human_->profil != 21 ) // �஬� ���ਭ������
      If a_period_amb[ i, 3 ] == human_->profil .and. ! ( human_->profil == 122 .or. human_->profil == 21 ) // �஬� ���ਭ������
        AAdd( ta, '����� ��砩 ���ᥪ����� � ��砥� ���㫠�୮�� ��祭��' )
        otd->( dbGoto( a_period_amb[ i, 4 ] ) )
        AAdd( ta, '�>� ⥬ �� ��䨫�� ' + ;
          date_8( a_period_amb[ i, 1 ] ) + '-' + date_8( a_period_amb[ i, 2 ] ) + ;
          iif( Empty( otd->short_name ), '', ' [' + AllTrim( otd->short_name ) + ']' ) )
        // aadd(ta, '�>����� �/� - ������ � ' + lstr(human->(recno())) + ', ���� �/� - ������ � ' + lstr(a_period_amb[i, 5]))
      Endif
    Next
  Endif
  If mRSLT_NEW > 0
    human_->RSLT_NEW := mRSLT_NEW // ������� ���.��ᯠ��ਧ���
  Endif
  //
  If is_2_78
    mIDSP := 17 // �����祭�� ��砩 � �����������
    If kvp_2_78 > 1
      AAdd( ta, '� ��砥 �ਬ����� ' + lstr( kvp_2_78 ) + ' ��㣨 "2.78.*" (������ ���� ����)' )
    Endif
  Endif
  If is_disp_DDS // is_70_5 .or. is_70_6
    mIDSP := 11 // ��ᯠ��ਧ���
    If kvp_70_5 > 1
      AAdd( ta, '� ��砥 �ਬ����� ' + lstr( kvp_70_5 ) + ' ��㣨 "70.5.*" (������ ���� ����)' )
    Endif
    If kvp_70_6 > 1
      AAdd( ta, '� ��砥 �ਬ����� ' + lstr( kvp_70_6 ) + ' ��㣨 "70.6.*" (������ ���� ����)' )
    Endif
  Endif
  If is_disp_DVN // is_70_3
    mIDSP := 11 // ��ᯠ��ਧ���
    If is_disp_DVN3 // ��䨫��⨪�
      mIDSP := 17 // �����祭�� ��砩 � �����������
    Endif
    If kvp_70_3 > 1
      AAdd( ta, '� ��砥 �ਬ����� ' + lstr( kvp_70_3 ) + ' ��� "���.�." (������ ���� ����)' )
    Endif
  Endif
  If is_prof_PN // is_72_2
    If is_72_2
      a_idsp := { { 30, '�� �����祭�� ��砩 � �����������' } }
    Else
      a_idsp := { { 29, '�� ���饭�� � �����������' } }
    Endif
    If kvp_72_2 > 1
      AAdd( ta, '� ��砥 �ਬ����� ' + lstr( kvp_72_2 ) + ' ��㣨 "72.2.*" (������ ���� ����)' )
    Endif
  Endif
  If ( k := Len( a_idsp ) ) == 0 .and. is_dializ
    If Empty( kodKSG )
      a_idsp := { { 28, '�� ����樭��� ����' } }
    Else // ���
      a_idsp := { { 33, '�� �����祭�� ��砩' } }
    Endif
    k := 1
  Endif
  If lTypeLUOnkoDisp
    a_idsp := { { 29, '�� ���饭�� � �����������' } }
    k := 1
  Endif
  If k == 0
    AAdd( ta, '�� � ����� �� ��� � �ࠢ�筨�� ����� �� ��⠭����� ᯮᮡ ������' )
  Elseif k == 1
    midsp := human_->IDSP := a_idsp[ 1, 1 ]
  Else
    ASort( a_idsp, , , {| x, y| x[ 1 ] < y[ 1 ] } )
    If Len( a_idsp ) == 2 .and. a_idsp[ 1, 1 ] == 28 .and. a_idsp[ 2, 1 ] == 33 .and. is_dializ
      del_array( a_idsp, 1 ) // 㤠���� 1-� ����� ���ᨢ�
      midsp := human_->IDSP := a_idsp[ 1, 1 ]
    Else
      AAdd( ta, 'ᬥ訢���� ᯮᮡ�� ������: ' + ;
        lstr( a_idsp[ 1, 1 ] ) + '-' + AllTrim( a_idsp[ 1, 2 ] ) + ' � ' + ;
        lstr( a_idsp[ 2, 1 ] ) + '-' + AllTrim( a_idsp[ 2, 2 ] ) )
    Endif
  Endif
  If ( k := Len( a_bukva ) ) == 0
    AAdd( ta, '�� � ����� �� ��� � �ࠢ�筨�� T002 �� ��⠭������ �㪢� ����' )
  Elseif k == 1
    //
  Else
    AAdd( ta, 'ᬥ訢���� �㪢 ����: ' + ;
      a_bukva[ 1, 1 ] + '-' + AllTrim( a_bukva[ 1, 2 ] ) + ' � ' + ;
      a_bukva[ 2, 1 ] + '-' + AllTrim( a_bukva[ 2, 2 ] ) )
  Endif
  If is_disp_DDS .or. is_disp_DVN .or. is_prof_PN .or. is_disp_DVN_COVID .or. is_disp_DRZ
    //
  Elseif l_mdiagnoz_fill .and. AScan( adiag, mdiagnoz[ 1 ] ) == 0
    AAdd( ta, '�᭮���� ������� ' + RTrim( mdiagnoz[ 1 ] ) + ' �� ����砥��� �� � ����� ��㣥' )
  Endif
  //
  If Empty( human_->USL_OK )
    AAdd( ta, '�� ��������� ���� "�᫮��� ��������"' )
  Endif
  If Empty( human_->PROFIL )
    AAdd( ta, '�� ��������� ���� "��䨫�"' )
  Elseif eq_any( human_->USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL )
    If Empty( human_2->profil_k )
      AAdd( ta, '� ��砥 �� ���⠢��� ��䨫� �����' )
    Else
      If Select( 'PRPRK' ) == 0
        r_use( dir_exe() + '_mo_prprk', cur_dir + '_mo_prprk', 'PRPRK' )
        // index on str(profil, 3) + str(profil_k, 3) to (cur_dir+ sbase)
      Endif
      Select PRPRK
      find ( Str( human_->profil, 3 ) + Str( human_2->profil_k, 3 ) )
      If Found()
        If !Empty( prprk->vozr )
          If human->vzros_reb == 0
            If prprk->vozr == '�'
              AAdd( ta, '������ ��樥�� �� ᮮ⢥����� ��䨫� �����' )
            Endif
          Else
            If prprk->vozr == '�'
              AAdd( ta, '������ ��樥�� �� ᮮ⢥����� ��䨫� �����' )
            Endif
          Endif
        Endif
        If !Empty( prprk->pol ) .and. !( human->pol == prprk->pol )
          AAdd( ta, '���祭�� ���� "���" �� ᮮ⢥����� ��䨫� �����' )
        Endif
      Else
        s := ''
        Select PRPRK
        find ( Str( human_->profil, 3 ) )
        Do While prprk->profil == human_->profil .and. !Eof()
          s += '"' + inieditspr( A__MENUVERT, getv020(), prprk->profil_k ) + '" '
          Skip
        Enddo
        If Empty( s )
          AAdd( ta, '��䨫� ����樭᪮� ����� �� ����稢����� � ���' )
        Else
          AAdd( ta, '��䨫� ���.����� �� ᮮ⢥����� ��䨫� �����; �����⨬� ��䨫� �����: ' + s )
        Endif
      Endif
    Endif
  Endif
  If Empty( human_->IDSP )
    AAdd( ta, '�� ��������� ���� "���ᮡ ������"' )
  Endif
  If Empty( human_->RSLT_NEW )
    AAdd( ta, '�� ��������� ���� "������� ���饭��"' )
  Elseif Int( Val( Left( lstr( human_->RSLT_NEW ), 1 ) ) ) != human_->USL_OK
    AAdd( ta, '� ���� "������� ���饭��" �⮨� ����୮� ���祭��' )
  Endif
  If Empty( human_->ISHOD_NEW )
    AAdd( ta, '�� ��������� ���� "��室 �����������"' )
  Elseif Int( Val( Left( lstr( human_->ISHOD_NEW ), 1 ) ) ) != human_->USL_OK
    AAdd( ta, '� ���� "��室 �����������" �⮨� ����୮� ���祭��' )
  Endif
  If is_2_82
    If human_->profil == 134
      AAdd( ta, '� ��砥 �� ������ ���� ��䨫� "��񬭮�� �⤥�����"' )
    Endif
  Endif
  If is_disp_DDS .or. is_disp_DVN .or. is_prof_PN .or. is_pren_diagn .or. kol_ksg > 0 ;
      .or. is_2_89 .or. is_reabil ;
      .or. is_disp_DVN_COVID .or. is_disp_DRZ  // .or. is_s_dializ
    If is_reabil  // �஢���� �஢��� �� ��䨫� �� ॠ�����樨
      If human_->profil != 158
        AAdd( ta, '� ��砥 ���� �ᯮ�짮���� ��䨫� ��: ' + inieditspr( A__MENUVERT, getv002(), 158 ) )
      Endif

      For i := 1 To Len( au_lu )
        If au_lu[ i, 3 ] == 158 .and. AllTrim( au_lu[ i, 1 ] ) != shifr_ksg
          AAdd( ta, '����� � ��㣥 ' + AllTrim( au_lu[ i, 1 ] ) + ' �ᯮ�짮���� ��䨫� ��: ' + inieditspr( A__MENUVERT, getv002(), au_lu[ i, 3 ] ) )
        Endif
      Next

      If is_reabil_slux
        t_arr := { '1331.0', '1332.0', '1333.0', '1335.0', '2127.0', '2128.0', '2130.0' }
        For i := 1 To Len( t_arr )
          If t_arr[ i ] == shifr_ksg .and. !Between( human_2->PN1, 1, 3 )
            human_2->PN1 := 1
            // aadd(ta, '� ��砥 ॠ�����樨 ��� ���=' + shifr_ksg+ ' ����室��� ��������� ���� '��� ���.ॠ�����樨'')
          Endif
        Next
      Endif
    Endif
  Else
    If human_->profil == 158
      AAdd( ta, '� ��砥 ����� �ᯮ�짮���� ��䨫� ��: ' + inieditspr( A__MENUVERT, getv002(), 158 ) )
    Endif
    arr_profil := { human_->profil }
    For i := 1 To Len( au_lu )
      If au_lu[ i, 10 ] >= 0 .and. AScan( arr_profil, au_lu[ i, 3 ] ) == 0
        AAdd( arr_profil, au_lu[ i, 3 ] )
      Endif
    Next
    For i := 1 To Len( au_flu )
      If AScan( arr_profil, au_flu[ i, 3 ] ) == 0
        AAdd( arr_profil, au_flu[ i, 3 ] )
      Endif
    Next
    If Len( arr_profil ) > 1
      If human_->USL_OK == USL_OK_AMBULANCE // 4 - �᫨ ᪮�� ������
        human_->profil := au_lu[ 1, 3 ]
      Else
        AAdd( ta, '� ��砥 �ᯮ�짮��� ��䨫� ��: ' + inieditspr( A__MENUVERT, getv002(), arr_profil[ 1 ] ) )
        For i := 2 To Len( arr_profil )
          AAdd( ta, '                  � � ��㣥 ��: ' + inieditspr( A__MENUVERT, getv002(), arr_profil[ i ] ) )
        Next
      Endif
    Elseif Empty( arr_profil[ 1 ] )
      AAdd( ta, '� ��砥 �� ���⠢��� ��䨫�' )
    Endif
    //
    If AScan( kod_LIS, glob_mo[ _MO_KOD_TFOMS ] ) > 0 .and. eq_any( human_->profil, 6, 34 )
      // �� �஢�����
    Else
      arr_prvs := { human_->PRVS }
      For i := 1 To Len( au_lu )
        If au_lu[ i, 10 ] >= 0 .and. AScan( arr_prvs, au_lu[ i, 4 ] ) == 0
          AAdd( arr_prvs, au_lu[ i, 4 ] )
        Endif
      Next
      For i := 1 To Len( au_flu )
        If AScan( arr_prvs, au_flu[ i, 4 ] ) == 0
          AAdd( arr_prvs, au_flu[ i, 4 ] )
        Endif
      Next
      If Len( arr_prvs ) > 1 .and. !is_gisto
        AAdd( ta, '� ��砥 �ᯮ�짮���� ࠧ�� ᯥ樠�쭮�� ��祩' )
      Endif
    Endif
  Endif
  If lstkol > 0
    lstshifr += '*'
    If lstkol > 1
      AAdd( ta, '���-�� ��� ' + lstshifr + ' (' + lstr( lstkol ) + ') ����� 1' )
    Endif
    If Len( au_lu ) > 1 .and. kol_ksg == 0
      If is_2_78 .or. is_2_89 .or. is_70_5 .or. is_70_6 .or. is_70_3 .or. is_72_2 .or. is_2_92_ .or. is_disp_DRZ
        //
      Else
        AAdd( ta, '�஬� ��㣨 ' + lstshifr + ' � ���� ��� �� ������ ���� ��㣨� ��� �����' )
      Endif
    Endif

    // �஢�ઠ 誮�� ������
//    If kol_2_93_1 > 0 .and. ! is_2_92_
//      AAdd( ta, '� ��砥 ���室��� ' + iif( vozrast < 18, '��㣠 2.92.3', '���� �� ��� 2.92.1 ��� 2.92.2' ) )
//    Endif
    If kol_2_93_1 > 0 .and. ! is_2_92_
      AAdd( ta, '� ��砥 ���室��� ' + iif( vozrast < 18, '��㣠 2.92.3', '���� �� ��� 2.92.1 ��� 2.92.2' ) )
    Endif
    If kol_2_93_2 > 0 .and. ! is_2_92_
      AAdd( ta, '� ��砥 ���室��� + ���� �� ��� 2.92.4, 2.92.5, 2.92.6, 2.92.7, 2.92.8, 2.92.9, 2.92.10, 2.92.11, 2.92.12 ��� 2.92.13' )
    Endif

    If is_2_92_
      diabetes_school_xniz( shifr_2_92, vozrast, kol_dney, kol_2_93_1, kol_2_93_2, human_->RSLT_NEW, human_->ISHOD_NEW, ta )
/*
      If !eq_any( human_->RSLT_NEW, 314 )
        AAdd( ta, '� ���� "������� ���饭��" ������ ���� "314 �������᪮� �������"' )
      Endif
      If !eq_any( human_->ISHOD_NEW, 304 )
        AAdd( ta, '� ���� "��室 �����������" ������ ���� "304 ��� ��६��"' )
      Endif

      s := '��㣠 2.93.1 ����뢠���� �� ����� '
      If vozrast < 18 .and. kol_2_93_1 < 10
        AAdd( ta, s + ' 10 ࠧ' )
      Elseif vozrast >= 18 .and. kol_2_93_1 < 5
        AAdd( ta, s + ' 5 ࠧ' )
      Endif
      If vozrast < 18 .and. kol_dney < 10
        AAdd( ta, s + ' 10 ����' )
      Elseif vozrast >= 18 .and. kol_dney < 5
        AAdd( ta, s + ' 5 ����' )
      Endif
*/
      // ����� �஢�ન 誮�� ������
    Endif
  Endif
  s := '2.60.*'
  If is_2_78
    is_1_den := is_last_den := .f.
    zs := oth_usl := 0
    am := {}
    For i := 1 To Len( au_lu )
      If Left( au_lu[ i, 1 ], 5 ) == '2.78.'
        ++zs
      Elseif Left( au_lu[ i, 1 ], 4 ) == '2.60'
        If dBegin == au_lu[ i, 2 ]
          is_1_den := .t.
        Endif
        If dEnd == au_lu[ i, 2 ]
          is_last_den := .t.
        Endif
        If ( j := AScan( am, {| x| x[ 1 ] == Month( au_lu[ i, 2 ] ) } ) ) == 0
          AAdd( am, { Month( au_lu[ i, 2 ] ), 0 } ) ; j := Len( am )
        Endif
        am[ j, 2 ] ++
      Elseif au_lu[ i, 10 ] >= 0 .and. !( AllTrim( au_lu[ i, 1 ] ) == '4.27.2' )
        ++oth_usl
      Endif
    Next
    j := Len( am )
    If !is_last_den .and. j > 0
      ASort( am, , , {| x, y| x[ 1 ] < y[ 1 ] } )
      If Month( dEnd ) - am[ j, 1 ] > 1 .and. Year( dBegin ) == Year( dEnd )
        AAdd( ta, '� �।��饬 ����� �� ������� ��祡��� ��񬮢' )
      Endif
    Endif
    If zs > 1
      AAdd( ta, '� ���� ��� ����� ����� ��㣨 "�����祭�� ��砩"' )
    Endif
    If oth_usl > 0
      AAdd( ta, '�஬� ��㣨 ' + lstshifr + ' � ' + s + ' � ���� ��� �� ������ ���� ��㣨� ���' )
    Endif
    If kol_2_60 == 0
      AAdd( ta, '�� ������� �� ����� ��㣨 ' + s )
    Else
      If !is_1_den
        AAdd( ta, '��ࢠ� ��㣠 ' + s + ' ������ ���� ������� � ���� ���� ��祭��' )
      Elseif human_->RSLT_NEW != 302
        If kol_2_60 < 2
          AAdd( ta, '�஬� ��㣨 ' + lstshifr + ' � ���� ��� ������ ���� �� ����� ���� ��� ' + s )
        Endif
        If !is_last_den
          AAdd( ta, '��᫥���� ��㣠 ' + s + ' ������ ���� ������� � ��᫥���� ���� ��祭��' )
        Endif
      Endif
    Endif
  Elseif kvp_2_79 > 1
    s := '2.79.*'
    AAdd( ta, '��㣠 ' + s + ' ������ ���� �����⢥���� � ��砥' )
  Elseif is_2_89 // ����樭᪠� ॠ������� (䨧������� ��ᯠ��� � ��㣨�)
    If dBegin == dEnd
      AAdd( ta, '�६� ��祭�� �� ������ ࠢ������ ������ ���' )
    Endif
    If Empty( human_->NPR_MO )
      AAdd( ta, '�� ��������� "���ࠢ���� ��", � ���ன ��樥�� ���� �ਪ९�����' )
    Else
      If Empty( human_2->NPR_DATE )
        AAdd( ta, '������ ���� ��������� ���� "��� ���ࠢ����� �� ��祭��"' )
      Elseif human_2->NPR_DATE > dBegin
        AAdd( ta, '"��� ���ࠢ����� �� ��祭��" ����� "���� ��砫� ��祭��"' )
      Elseif human_2->NPR_DATE + 60 < dBegin
        AAdd( ta, '���ࠢ����� �� ��祭�� ����� ���� ����楢' )
      Endif
      // 10.07.23 ��᫥ ������ �맣���
      // if !(eq_any(glob_mo[_MO_KOD_TFOMS], '103001', '104401') .or. ret_mo(human_->NPR_MO)[_MO_IS_UCH])
      // aadd(ta, '������� "���ࠢ���� ��", ����� �� ����� �ࠢ� �ਪ९���� ��樥�⮢')
      // endif
    Endif
    aps := {} // ��⠭�� ��䨫� � ᯥ樠�쭮��
    human_->profil := 158  // ����樭᪮� ॠ�����樨
    is_1_den := is_last_den := .f.
    zs := km := oth_usl := 0
    s := ''
    shifr_zs := ''
    For i := 1 To Len( au_lu )
      If Left( au_lu[ i, 1 ], 5 ) == '2.89.'
        shifr_zs := au_lu[ i, 1 ]
        Exit
      Endif
    Next
    For i := 1 To Len( au_lu )
      alltrim_lshifr := AllTrim( au_lu[ i, 1 ] )
      left_lshifr_2 := Left( au_lu[ i, 1 ], 2 )
      left_lshifr_3 := Left( au_lu[ i, 1 ], 3 )
      left_lshifr_4 := Left( au_lu[ i, 1 ], 4 )
      left_lshifr_5 := Left( au_lu[ i, 1 ], 5 )
      If !Between( au_lu[ i, 2 ], dBegin, dEnd )
        AAdd( ta, '��� ��㣨 ' + alltrim_lshifr + ' ��� ��������� ��祭�� (' + date_8( au_lu[ i, 2 ] ) + ')' )
      Endif
      If l_mdiagnoz_fill .and. !( AllTrim( mdiagnoz[ 1 ] ) == AllTrim( au_lu[ i, 8 ] ) )
        AAdd( ta, '� ��㣥 ' + alltrim_lshifr + ' ������ ����� �᭮���� �������' )
      Endif
      If left_lshifr_5 == '2.89.'
        zs += au_lu[ i, 6 ]
      Elseif left_lshifr_4 == '2.6.'  // .and. (! lTypeLUMedReab)
        If dBegin == au_lu[ i, 2 ]
          is_1_den := .t.
        Elseif dEnd == au_lu[ i, 2 ]
          is_last_den := .t.
        Endif
        If au_lu[ i, 6 ] != 1
          AAdd( ta, '� ��㣥 ' + alltrim_lshifr + ' ������⢮ �� ������ ���� ����� 1' )
        Endif
      Elseif AScan( arr_lfk, alltrim_lshifr ) > 0
        ++km
        If eq_any( alltrim_lshifr, '4.2.153', '4.11.136', '3.4.31' ) .and. au_lu[ i, 6 ] != 1
          AAdd( ta, '� ��㣥 ' + alltrim_lshifr + ' ������⢮ �� ������ ���� ����� 1' )
        Endif
        If au_lu[ i, 6 ] > 1 .and. au_lu[ i, 2 ] + au_lu[ i, 6 ] - 1 > dEnd
          AAdd( ta, '��� ����砭�� ��㣨 ' + alltrim_lshifr + ' ����� ���� ����砭�� ��祭��' )
        Endif
        //
        fl_not_2_89 := .f.
        If lTypeLUMedReab
          obyaz_uslugi_med_reab := compulsory_services( list2arr( human_2->PC5 )[ 1 ], list2arr( human_2->PC5 )[ 2 ], M1VZROS_REB == 0, iif( len( list2arr( human_2->PC5 ) ) > 2, list2arr( human_2->PC5 )[ 3 ], 0 ) )
          For Each row in arrUslugi // �஢�ਬ �� ��㣨 ����
            If ( iUsluga := AScan( obyaz_uslugi_med_reab, {| x| AllTrim( x ) == AllTrim( row ) } ) ) > 0
              hb_ADel( obyaz_uslugi_med_reab, iUsluga, .t. )
            Endif
          Next
          If Len( obyaz_uslugi_med_reab ) > 0
            For Each row in obyaz_uslugi_med_reab
              AAdd( ta, '��������� ��易⥫쭠� ��㣠 ��� ����樭᪮� ॠ�����樨 "' + AllTrim( row ) + '"' )
            Next
          Endif

          aUslMedReab := ret_usluga_med_reab( alltrim_lshifr, list2arr( human_2->PC5 )[ 1 ], list2arr( human_2->PC5 )[ 2 ], M1VZROS_REB == 0, iif( len( list2arr( human_2->PC5 ) ) > 2, list2arr( human_2->PC5 )[ 3 ], 0 ) )
          If aUslMedReab != Nil .and. Len( aUslMedReab ) != 0
            If aUslMedReab[ 3 ] > au_lu[ i, 6 ]
              AAdd( ta, '��� ��㣨 ' + alltrim_lshifr + ' �ॡ���� ������ ' + lstr( aUslMedReab[ 3 ] ) + ' �।��⠢�����!' )
            Endif
            If aUslMedReab[ 3 ] > 1 .and. ( count_days( au_lu[ i, 2 ], au_lu[ i, 11 ] ) < aUslMedReab[ 3 ] )
              AAdd( ta, '������⢮ ���� �믮������ ��㣨 ����� ������⢠ ����७�� ��㣨!' )
            Endif
          Endif
        Else
          If left_lshifr_3 == '20.' // ���
            atmp := { '20.1.2', '20.1.1', '20.1.3', '20.1.1', '20.1.1' }
            For j := 6 To 12
              AAdd( atmp, '20.1.4' )
            Next
            For j := 13 To 14
              AAdd( atmp, '20.1.5' )
            Next
            AAdd( atmp, '20.2.3' ) // j=15 ��� � ��-��� ⥫�����樭�
            If AScan( atmp, alltrim_lshifr ) > 0
              For j := 1 To 15
                If a_2_89[ j ] == 1 .and. !( alltrim_lshifr == atmp[ j ] )
                  fl_not_2_89 := .t.
                Endif
              Next
            Endif
            If alltrim_lshifr == '20.2.1' .and. emptyall( a_2_89[ 1 ], a_2_89[ 4 ], a_2_89[ 5 ] )
              fl_not_2_89 := .t.
            Elseif alltrim_lshifr == '20.2.2' .and. Empty( a_2_89[ 3 ] )
              fl_not_2_89 := .t.
            Endif
          Elseif left_lshifr_3 == '21.' // ���ᠦ
            // �஬� ���������
            atmp := { '21.1.2', '21.1.1', '21.1.3', '21.1.1', '21.1.1' }
            If AScan( atmp, alltrim_lshifr ) > 0
              For j := 1 To Len( atmp )
                If a_2_89[ j ] == 1 .and. !( alltrim_lshifr == atmp[ j ] )
                  fl_not_2_89 := .t.
                Endif
              Next
            Endif
            // ���������
            If alltrim_lshifr == '21.1.4' .and. emptyall( a_2_89[ 6 ], a_2_89[ 7 ], a_2_89[ 9 ], a_2_89[ 10 ] )
              fl_not_2_89 := .t.
            Endif
            If alltrim_lshifr == '21.2.1' .and. emptyall( a_2_89[ 6 ], a_2_89[ 7 ], a_2_89[ 8 ], a_2_89[ 9 ], a_2_89[ 11 ] )
              fl_not_2_89 := .t.
            Endif
            // 2.89.25 '���饭�� � 楫�� ����樭᪮� ॠ�����樨 ��樥�⮢ �� ��祭�� �࣠��� ��堭��'
            If alltrim_lshifr == '21.1.5' .and. Empty( a_2_89[ 14 ] )
              fl_not_2_89 := .t.
            Endif
          Elseif left_lshifr_3 == '22.' // �䫥���࠯��
            // �஬� ���������
            atmp := { '22.1.2', '22.1.1', '22.1.3', '22.1.1', '22.1.1' }
            If AScan( atmp, alltrim_lshifr ) > 0
              For j := 1 To 5
                If a_2_89[ j ] == 1 .and. !( alltrim_lshifr == atmp[ j ] )
                  fl_not_2_89 := .t.
                Endif
              Next
            Endif
          Endif
          If zs > 1
            AAdd( ta, '� ���� ��� ����� ����� ��㣨 2.89.* "�����祭�� ��砩"' )
          Endif
          If kol_2_6 < 2
            AAdd( ta, '�஬� ��㣨 ' + lstshifr + ' � ���� ��� ������ ���� ��� � ����� ��� 2.6.*' )
          Endif
        Endif
        If fl_not_2_89
          AAdd( ta, '��㣠 ' + alltrim_lshifr + ' �� �室�� � ����� ��� ��� ���饭�� � 楫�� ����樭᪮� ॠ�����樨 ' + shifr_zs )
        Endif
      Else
        s += alltrim_lshifr + ' '
        ++oth_usl
      Endif
    Next
    If oth_usl > 0
      AAdd( ta, '� ���� ��� �� ������ ���� ������ ���: ' + s )
    Endif
    If kol_2_6 > 0
      If !is_1_den
        AAdd( ta, '��ࢠ� ��㣠 2.6.* ������ ���� ������� � ���� ���� ��祭��' )
      Endif
      If !is_last_den
        AAdd( ta, '��᫥���� ��㣠 2.6.* ������ ���� ������� � ��᫥���� ���� ��祭��' )
      Endif
    Endif
    If km == 0
      AAdd( ta, '� ���� ��� ��� �� ����� ��㣨 "���������"' )
    Endif
  Elseif is_70_5 .or. is_70_6 .or. is_70_3 .or. is_72_2
    //
  Elseif kol_2_60 > 0
    AAdd( ta, '����� � ��㣠�� ' + s + ' ������ ���� ��㣠 "�����祭�� ��砩"' )
  Endif
  d := human->k_data - human->n_data
  If kkd > 0
    If Empty( d ) .and. kkd == 1
      // ��-������ ���� �����-����
    Elseif kkd > d
      AAdd( ta, '���-�� �����-���� (' + lstr( kkd ) + ') �ॢ�蠥� �ப ��祭�� �� ' + lstr( kkd - d ) )
    Elseif kkd < d
      AAdd( ta, '���-�� �����-���� (' + lstr( kkd ) + ') ����� �ப� ��祭�� �� ' + lstr( d - kkd ) )
    Endif
  Elseif kds > 0
    If kds > ( d + 1 )
      AAdd( ta, '���-�� ��� �������� ��樮��� (' + lstr( kds ) + ') �ॢ�蠥� �ப ��祭�� �� ' + lstr( kds - ( d + 1 ) ) )
    Endif
    If is_eko
      If human_->PROFIL != 137
        AAdd( ta, '��� ���=' + shifr_ksg + ' ��䨫� ������ ���� �� "�������� � ����������� (�ᯮ�짮����� �ᯮ����⥫��� ९த�⨢��� �孮�����)"' )
      Endif
      a_1_11 := {}
      For i := 1 To Len( au_flu )
        AAdd( a_1_11, AllTrim( au_flu[ i, 1 ] ) )
      Next
      j := 1 // ���� - 1 �奬�
      If AScan( a_1_11, 'A11.20.031' ) > 0  // �ਮ
        j := 6  // 6 �奬�
        If AScan( a_1_11, 'A11.20.028' ) > 0 // ��⨩ �⠯
          j := 2   // 2 �奬�
        Endif
      Elseif AScan( a_1_11, 'A11.20.025.001' ) > 0  // ���� �⠯
        j := 3  // 3 �奬�
        If AScan( a_1_11, 'A11.20.036' ) > 0  // �������騩 ��ன �⠯
          j := 4  // 4 �奬�
        Elseif AScan( a_1_11, 'A11.20.028' ) > 0  // �������騩 ��⨩ �⠯
          j := 5  // 5 �奬�
        Endif
      Elseif AScan( a_1_11, 'A11.20.030.001' ) > 0  // ⮫쪮 �⢥��� �⠯
        j := 7  // 7 �奬�
      Endif
      ashema := { ;
        { 'A11.20.017' }, ;
        { 'A11.20.017', 'A11.20.028', 'A11.20.031' }, ;
        { 'A11.20.017', 'A11.20.025.001' }, ;
        { 'A11.20.017', 'A11.20.025.001', 'A11.20.036' }, ;
        { 'A11.20.017', 'A11.20.025.001', 'A11.20.028' }, ;
        { 'A11.20.017', 'A11.20.031' }, ;
        { 'A11.20.017', 'A11.20.030.001' };
        }
      If ( k := Len( ashema[ j ] ) ) == ( n := Len( a_1_11 ) )
        //
      Elseif k > n
        AAdd( ta, '� ���� ���� �� ��� �� 墠⠥� ��� ' + print_array( a_1_11 ) )
      Elseif k < n
        For i := 1 To k
          If ( n := AScan( a_1_11, ashema[ j, i ] ) ) > 0
            del_array( a_1_11, n )
          Endif
        Next
        If Len( a_1_11 ) > 0
          AAdd( ta, '� ���� ���� �� ��� ��譨� ��㣨 ' + print_array( a_1_11 ) )
        Endif
      Endif
    Endif
  Elseif kkt > 0 .and. !is_s_dializ .and. !is_dializ .and. !is_perito
    mPZTIP := 66 // 66, '�-��᫥�������', '�-��᫥�.'}, ;
    mPZKOL := kkt
    If !emptyall( kkd, kds, kvp, ksmp )
      AAdd( ta, '�஬� ��� 60.* � ���� ��� �� ������ ���� ��㣨� ��� �����' )
    Endif
    If human_->USL_OK != USL_OK_POLYCLINIC
      AAdd( ta, '� ���� "�᫮��� ��������" ������ ���� "�����������"' )
    Endif
    If is_kt
      s := '��'
    Elseif is_mrt
      s := '���'
    Elseif is_uzi
      s := '��� ���'
    Elseif is_endo
      s := '��᪮���'
    Elseif is_gisto
      s := '���⮫����'
    Elseif is_mgi
      s := '�������୮� ����⨪�'
    Elseif is_g_cit
      s := '������⭮� �⮫����'
      mPZTIP := 68 // 68, '������⭠� �⮫����', '����.�⮫'}, ;
    Elseif is_pr_skr
      s := '�७�⠫쭮�� �ਭ����'
      mPZTIP := 67 // 67, '�७�⠫�� �ਭ���', '�७.�ਭ'}, ;
    Endif
    If Empty( human_->NPR_MO )
      AAdd( ta, '��� ' + s + ' ������ ���� ��������� "���ࠢ���� ��"' )
    Elseif Empty( human_2->NPR_DATE )
      If glob_mo[ _MO_KOD_TFOMS ] == ret_mo( human_->NPR_MO )[ _MO_KOD_TFOMS ]
        human_2->NPR_DATE := dBegin
      Else
        AAdd( ta, '������ ���� ��������� ���� "��� ���ࠢ�����"' )
      Endif
    Elseif human_2->NPR_DATE > dBegin
      AAdd( ta, '"��� ���ࠢ�����" ����� "���� ��砫� ��祭��"' )
    Elseif human_2->NPR_DATE + 60 < dBegin
      AAdd( ta, '���ࠢ����� ����� ���� ����楢' )
    Endif
    If !eq_any( human_->RSLT_NEW, 314 )
      AAdd( ta, '� ���� "������� ���饭��" ������ ���� "314 �������᪮� �������"' )
    Endif
    If !eq_any( human_->ISHOD_NEW, 304 )
      AAdd( ta, '� ���� "��室 �����������" ������ ���� "304 ��� ��६��"' )
    Endif
    If is_g_cit .or. is_pr_skr
      If kkt > 1
        AAdd( ta, '���-�� ��� ' + s + ' (' + lstr( kkt ) + ') �� ������ ���� ����� 1' )
      Endif
      If human_->PROFIL != 34
        AAdd( ta, '��� ' + s + ' ��䨫� ������ ���� ����������� ������������ �����������' )
      Endif
    Else
      If is_oncology == 2
        // ����� ���饭�� - �������⨪� 㦥 �஢�७ ���
      Elseif PadR( mdiagnoz[ 1 ], 5 ) == 'Z03.1'
        // if is_gisto
        // aadd(ta, '��� ' + s + ' �� ����� ���� ��⠭����� �᭮���� ������� 'Z03.1 ������� �� �����७�� �� �������⢥���� ���宫�'')
        // endif
      Elseif is_kt
        If !( PadR( mdiagnoz[ 1 ], 5 ) == 'Z01.6' )
          AAdd( ta, '��� ' + s + ' �᭮���� ������� ������ ���� Z01.6' )
        Endif
      Elseif is_mrt .or. is_uzi .or. is_endo
        If !( PadR( mdiagnoz[ 1 ], 5 ) == 'Z01.8' )
          AAdd( ta, '��� ' + s + ' �᭮���� ������� ������ ���� Z01.8' )
        Endif
      Elseif is_gisto
        AAdd( ta, '��� ' + s + ' �᭮���� ������� �� ����� ���� ' + RTrim( mdiagnoz[ 1 ] ) + ;
          ' (�஬� ���������᪮�� �������� ࠧ�蠥��� �ᯮ�짮���� ⮫쪮 Z03.1)' )
      Endif
    Endif
    fl := .t.
    For i := 1 To Len( au_lu )
      If au_lu[ i, 2 ] == dBegin
        fl := .f. ; Exit
      Endif
    Next
    If fl
      AAdd( ta, '��� ' + s + ' ���� �� ��� ������ ���� ������� � ���� ��砫� ��祭��' )
    Endif
  Elseif kvp > 0
    mPZKOL := kvp - kvp_2_78 - kvp_2_89
    If mIDSP == 12
      mPZTIP := 60 // 60, '���饭�� ��䨫����᪮� ����� ���஢��', '�����.��'}, ;
      If kvp > 1 // �������᭠� ��㣠 業�� ���஢��
        AAdd( ta, '� 業�� ���஢�� ������� ' + lstr( kvp ) + ' ��㣨 (������ ���� ����)' )
      Endif
    Endif
    If dEnd > dBegin
      If is_2_88
        If Month( dBegin ) == Month( dEnd )
          AAdd( ta, '��� ������ ��㣨 �ப ��祭�� - ���� ����' )
        Elseif Month( dEnd ) - Month( dBegin ) > 1 .and. Year( dBegin ) == Year( dEnd )
          AAdd( ta, '��� ������ ��㣨 �ப ��祭�� �� ����� ���� ����� �����' )
        Endif
      Elseif is_2_80 .or. is_2_81 .or. is_2_82 .or. is_pren_diagn
        AAdd( ta, '��� ������ ��㣨 �ப ��祭�� - ���� ����' )
      Endif
    Endif
    If kvp > 1 .and. ( is_2_80 .or. is_2_81 .or. is_2_82 .or. is_2_88 )
      AAdd( ta, '������⢮ ��� ������ ���� ࠢ�� 1' )
    Endif
    If is_2_78 .or. is_2_89
      // mpztip := 59 // 59, '���饭��', '���.����.'}, ;
      mPZKOL := 1 // ???
    Elseif is_2_79 .or. is_2_81 .or. is_2_88
      // mpztip := 57 // 57, '���饭�� ��䨫����᪮�', '���.���.'}, ;
    Elseif is_2_80 .or. is_2_82
      // mpztip := 58 // 58, '���饭�� ���⫮����', '���.����.'}, ;
    Endif
  Elseif ksmp > 0
    mpztip := 51 // 51, '�맮� ���', '�맮� ���'}, ;
    mpzkol := ksmp
    If ksmp > 1
      AAdd( ta, '������⢮ ��� ��� ������ ���� ࠢ�� 1' )
    Endif
    If Len( au_lu ) > 1
      AAdd( ta, '�஬� ��㣨 71.* � ���� ��� �� ������ ���� ��㣨� ��� �����' )
    Endif
    If human_->USL_OK != USL_OK_AMBULANCE // 4
      AAdd( ta, '��� ��㣨 ��� �᫮��� ������ ���� "����� ������"' )
    Endif
    If human_->IDSP != 24
      AAdd( ta, '��� ��㣨 ��� ᯮᮡ ������ ������ ���� "�맮� ᪮ன ����樭᪮� �����"' )
    Endif
    If dBegin < dEnd
      AAdd( ta, '��� ᪮ன ����� ��� ��砫� ������ ࠢ������ ��� ����砭�� ��祭��' )
    Endif
    If ( is_komm_smp() .and. dEnd < 0d20190501 ) .or. ( is_komm_smp() .and. dEnd > 0d20220101 ) // �᫨ �� �������᪠� ᪮��
      If is_71_1
        AAdd( ta, '��� �������᪮� ��� ����室��� �ਬ����� ��㣨 71.2.*' )
      Endif
    Elseif Empty( human_->OKATO ) .or. human_->OKATO == '18000'
      If is_71_2
        AAdd( ta, '��� ��樥�⮢, �����客����� �� ����ਨ ������ࠤ᪮� ������,' )
        AAdd( ta, '����室��� �ਬ����� ��㣨 71.1.*' )
      Endif
    Else
      If is_71_1
        AAdd( ta, '��� ��樥�⮢, �����客����� �� �।����� ������ࠤ᪮� ������,' )
        AAdd( ta, '����室��� �ਬ����� ��㣨 71.2.*' )
      Endif
    Endif
  Endif
  If is_dializ
    s := '�����������'
    If kds > 0 .and. kol_ksg == 0
      AAdd( ta, '��� ' + s + ' �� �������� ��樥��-����' )
    Endif
    If !eq_any( human_->PROFIL, 56 ) // ����������
      AAdd( ta, '��� ' + s + ' ��䨫� ������ ���� ����������' )
    Endif
    If !eq_any( ret_old_prvs( human_->PRVS ), 112207, 113412 ) // ����������
      AAdd( ta, '��� ' + s + ' ᯥ樠�쭮��� ��� ������ ���� ����������' )
    Endif
    If glob_mo[ _MO_KOD_TFOMS ] == '101004' // ���
      If Empty( AllTrim( human_->NPR_MO ) )
        human_->NPR_MO := glob_mo[ _MO_KOD_TFOMS ] // ����᫮��� ���⠢�塞 ���ࠢ����� ��
        human_2->( g_rlock( forever ) )
        human_2->NPR_DATE := dBegin
        human_2->( dbUnlock() )
      Endif
    Elseif ! glob_mo[ _MO_KOD_TFOMS ] == '141023' // �� ���쭨� 15, �६���� ���� �� ࠧ��६��
      human_->NPR_MO := glob_mo[ _MO_KOD_TFOMS ] // ����᫮��� ���⠢�塞 ���ࠢ����� ��
      human_2->( g_rlock( forever ) )
      human_2->NPR_DATE := dBegin
      human_2->( dbUnlock() )
    Endif
    mpztip := 56 // 56, '��砩 �������', '���.����.'}, ;
    mpzkol := kkt
  Endif
  If is_perito
    s := '��� ��������������� ������� '
    If human_->PROFIL != 56
      AAdd( ta, s + '��䨫� ������ ���� ����������' )
    Endif
    If !eq_any( ret_old_prvs( human_->PRVS ), 112207, 113412 ) // ����������
      AAdd( ta, s + 'ᯥ樠�쭮��� ��� ������ ���� ����������' )
    Endif
    If glob_mo[ _MO_KOD_TFOMS ] == '101004' // ���
      If Empty( AllTrim( human_->NPR_MO ) )
        human_->NPR_MO := glob_mo[ _MO_KOD_TFOMS ] // ����᫮��� ���⠢�塞 ���ࠢ����� ��
        human_2->( g_rlock( forever ) )
        human_2->NPR_DATE := dBegin
        human_2->( dbUnlock() )
      Endif
    Elseif ! glob_mo[ _MO_KOD_TFOMS ] == '141023' // �� ���쭨� 15, �६���� ���� �� ࠧ��६��
      human_->NPR_MO := glob_mo[ _MO_KOD_TFOMS ] // ����᫮��� ���⠢�塞 ���ࠢ����� ��
      human_2->( g_rlock( forever ) )
      human_2->NPR_DATE := dBegin
      human_2->( dbUnlock() )
    Endif
    mpztip := 56 // 56, '��砩 �������', '���.����.'}, ;
    mpzkol := kkt
  Endif
  If is_s_dializ
    s := '��㣨 ������� � ��樮���'
    If glob_mo[ _MO_KOD_TFOMS ] == '101004' // ���
      If Empty( AllTrim( human_->NPR_MO ) )
        human_->NPR_MO := glob_mo[ _MO_KOD_TFOMS ] // ����᫮��� ���⠢�塞 ���ࠢ����� ��
        human_2->( g_rlock( forever ) )
        human_2->NPR_DATE := dBegin
        human_2->( dbUnlock() )
      Endif
    Elseif ! glob_mo[ _MO_KOD_TFOMS ] == '141023' // �� ���쭨� 15, �६���� ���� �� ࠧ��६��
      human_->NPR_MO := glob_mo[ _MO_KOD_TFOMS ] // ����᫮��� ���⠢�塞 ���ࠢ����� ��
      human_2->( g_rlock( forever ) )
      human_2->NPR_DATE := dBegin
      human_2->( dbUnlock() )
    Endif
    mpztip := 54 // 54, '��砩 ���', '��砩 ���'}, ;
    mpzkol := kkt
    For i := 1 To Len( a_dializ )
      j := a_dializ[ i, 5 ] - 1
      If !Between( j, 1, 2 )
        j := 1
      Endif
      If overlap_diapazon( a_dializ[ i, 1 ], a_dializ[ i, 2 ], dBegin, dEnd ) .or. eq_any( dBegin, a_dializ[ i, 1 ], a_dializ[ i, 2 ] ) ;
          .or. eq_any( dEnd, a_dializ[ i, 1 ], a_dializ[ i, 2 ] )
        AAdd( ta, '��㣠 ������� � ��樮��� ���ᥪ����� � ��砥� ' + { '����', '���⮭���쭮�� ' }[ j ] + '������� ' + date_8( a_dializ[ i, 1 ] ) + '-' + date_8( a_dializ[ i, 2 ] ) )
      Endif
    Next
    For i := 1 To Len( a_srok_lech )
      otd->( dbGoto( a_srok_lech[ i, 4 ] ) )
      If a_srok_lech[ i, 5 ] == 1
        otd->( dbGoto( a_srok_lech[ i, 4 ] ) )
        AAdd( ta, '����祭�� � ��������� �������� ' + date_8( a_srok_lech[ i, 1 ] ) + '-' + date_8( a_srok_lech[ i, 2 ] ) + ;
          iif( Empty( otd->short_name ), '', ' [' + AllTrim( otd->short_name ) + ']' ) )
      Endif
    Next
  Endif
  If is_disp_DDS //
    metap := 1
    m1mobilbr := 0
    human->OBRASHEN := ''
    tip_lu := iif( !Empty( human->ZA_SMO ), TIP_LU_DDS, TIP_LU_DDSOP )
    If yearBegin != yearEnd
      AAdd( ta, '��� ��砫� � ����砭�� ���� ������ ���� � ����� ����' )
    Endif
    If eq_any( human->ishod, 101, 102 )
      metap := human->ishod -100
      read_arr_dds( human->kod )
    Else
      AAdd( ta, '��ᯠ��ਧ��� ��⥩-��� ���� ������� �१ ᯥ樠��� �࠭ �����' )
    Endif
    is_1_den := is_last_den := .f. ; zs := kvp := 0 ; oth_usl := ''
    For i := 1 To Len( au_lu )
      If au_lu[ i, 3 ] == 0
        AAdd( ta, '� ��㣥 ' + AllTrim( au_lu[ i, 1 ] ) + ' �� ���⠢��� ��䨫�' )
      Endif
      If au_lu[ i, 4 ] == 0
        AAdd( ta, '� ��㣥 ' + AllTrim( au_lu[ i, 1 ] ) + ' �� ���⠢���� ᯥ�-�� ���' )
      Endif
      If au_lu[ i, 2 ] > dEnd
        AAdd( ta, '��㣠 ' + au_lu[ i, 5 ] + '(' + date_8( au_lu[ i, 2 ] ) + ') �� �������� � �������� ��祭��' )
      Endif
      If is_issl_dds( au_lu[ i ], mvozrast, ta )
        s := '��㣠 ' + au_lu[ i, 5 ] + '(' + date_8( au_lu[ i, 2 ] ) + ')'
        If AllTrim( au_lu[ i, 1 ] ) == '7.61.3'
          If au_lu[ i, 2 ] < AddMonth( dBegin, -12 )
            AAdd( ta, '��ண��� ������� ����� 1 ���� �����' )
          Endif
        Elseif mvozrast < 2
          If au_lu[ i, 2 ] < AddMonth( dBegin, -1 )
            AAdd( ta, s + ' ������� ����� 1 ����� �����' )
          Endif
        Else
          If au_lu[ i, 2 ] < AddMonth( dBegin, -3 )
            AAdd( ta, s + ' ������� ����� 3 ����楢 �����' )
          Endif
        Endif
        If dBegin == au_lu[ i, 2 ]
          is_1_den := .t.
        Endif
      Else
        s := '��㣠 ' + au_lu[ i, 5 ] + '-' + inieditspr( A__MENUVERT, getv002(), au_lu[ i, 3 ] ) + '(' + date_8( au_lu[ i, 2 ] ) + ')'
        If is_osmotr_dds_1_etap( au_lu[ i ], mvozrast, metap, mpol, tip_lu ) // eq_any(alltrim(au_lu[i, 5]),'2.3.1','2.4.1') // + 2.4.1-��娠��
          If eq_any( au_lu[ i, 3 ], 68, 57 ) // ������� (��� ��饩 �ࠪ⨪�)
            If au_lu[ i, 2 ] < dBegin
              AAdd( ta, '��� �ᬮ�� ������� �� I �⠯� �� �������� � �������� ��祭��' )
            Endif
          Elseif mvozrast < 2
            If au_lu[ i, 2 ] < AddMonth( dBegin, -1 )
              AAdd( ta, s + ' ������� ����� 1 ����� �����' )
            Endif
          Else
            If au_lu[ i, 2 ] < AddMonth( dBegin, -3 )
              AAdd( ta, s + ' ������� ����� 3 ����楢 �����' )
            Endif
          Endif
        Elseif au_lu[ i, 2 ] < dBegin
          AAdd( ta, s + ' �� �������� � �������� ��祭��' )
        Endif
        If eq_any( Left( au_lu[ i, 1 ], 5 ), '70.5.', '70.6.' )
          ++zs
          s := ret_shifr_zs_dds( tip_lu )
          If !( AllTrim( au_lu[ i, 1 ] ) == s )
            AAdd( ta, '� �/� ��㣠 ' + AllTrim( au_lu[ i, 1 ] ) + ', � ������ ���� ' + s + ;
              ' ��� ������ ' + lstr( mvozrast ) + ' ' + s_let( mvozrast ) )
          Endif
        Elseif is_osmotr_dds( au_lu[ i ], mvozrast, ta, metap, mpol, tip_lu )
          If eq_any( Left( au_lu[ i, 1 ], 5 ), '2.83.', '2.87.' )
            ++kvp
          Elseif Left( au_lu[ i, 1 ], 4 ) == '2.3.'
            ++kvp
          Endif
          If dBegin == au_lu[ i, 2 ]
            is_1_den := .t.
          Endif
          If dEnd == au_lu[ i, 2 ]
            is_last_den := .t.
          Endif
        Else
          oth_usl += AllTrim( au_lu[ i, 1 ] ) + ' '
        Endif
      Endif
    Next
    If metap == 1 .and. zs > 1
      AAdd( ta, '� ���� ��� ����� ����� ��㣨 "�����祭�� ��砩"' )
    Elseif metap == 2 .and. zs > 0
      AAdd( ta, '��� I � II �⠯�� ��� �� ������ ���� ��� "�����祭�� ��砩"' )
    Endif
    If !Empty( oth_usl )
      AAdd( ta, '� ���� ��� ��� ��譨� ��㣨: ' + oth_usl )
    Endif
    If !is_1_den
      // aadd(ta, '���� ��祡�� �ᬮ�� ������ ���� ������ � ���� ���� ��祭��')
    Endif
    If !is_last_den
      AAdd( ta, '��᫥���� ��祡�� �ᬮ�� ������ ���� ������ � ��᫥���� ���� ��祭��' )
    Endif
    k := 0
    For counter := dBegin To dEnd
      If is_work_day( counter )
        ++k
      Endif
    Next
    If metap == 1 .and. k > 10
      AAdd( ta, '�ப ��� I �⠯� ������ ��⠢���� �� ����� 10 ࠡ��� ���� (� ��� ' + lstr( k ) + ')' )
    Elseif metap == 2 .and. k > 45
      AAdd( ta, '�ப ��� I � II �⠯� ������ ��⠢���� �� ����� 45 ࠡ��� ���� (� ��� ' + lstr( k ) + ')' )
    Endif
  Endif
  If is_prof_PN //
    human_->profil := 151  // ����樭᪨� �ᬮ�ࠬ ��䨫����᪨�
    metap := 1
    m1mobilbr := 0
    If yearBegin != yearEnd
      AAdd( ta, '��� ��砫� � ����砭�� ���� ������ ���� � ����� ����' )
    Endif
    If eq_any( human->ishod, 301, 302 )
      metap := human->ishod -300
      license_for_dispans( 2, dBegin, ta )
    Else
      AAdd( ta, '��䨫��⨪� ��ᮢ��襭����⭨� ���� ������� �१ ᯥ樠��� �࠭ �����' )
    Endif
    mperiod := ret_period_pn( mdate_r, dBegin, dEnd )
    If Between( mperiod, 1, 31 )
      np_oftal_2_85_21( mperiod, dEnd ) // �������� ��� 㤠���� ��⠫쬮���� � ���ᨢ ��� ��ᮢ��襭����⭨� ��� 12 ����楢
      read_arr_pn( human->kod )
      kol_d_otkaz := 0
      If ValType( arr_usl_otkaz ) == 'A'
        For j := 1 To Len( arr_usl_otkaz )
          ar := arr_usl_otkaz[ j ]
          If ValType( ar ) == 'A' .and. Len( ar ) > 9 .and. ValType( ar[ 5 ] ) == 'C' .and. ;
              ValType( ar[ 10 ] ) == 'C' .and. ar[ 10 ] $ 'io'
            lshifr := AllTrim( ar[ 5 ] )
            If ar[ 10 ] == 'i' // ��᫥�������
              If ( i := AScan( np_arr_issled, {| x| ValType( x[ 1 ] ) == 'C' .and. x[ 1 ] == lshifr } ) ) > 0
                If is_issled_pn( { lshifr, ar[ 6 ], ar[ 4 ], ar[ 2 ] }, mperiod, ta, human->pol, dEnd )
                  ++kol_d_otkaz
                Endif
              Endif
            Elseif ( i := AScan( np_arr_osmotr, {| x| ValType( x[ 1 ] ) == 'C' .and. x[ 1 ] == lshifr } ) ) > 0 // �ᬮ���
              If is_osmotr_pn( { lshifr, ar[ 6 ], ar[ 4 ], ar[ 2 ] }, mperiod, ta, metap, human->pol, dEnd, m1mobilbr )
                ++kol_d_otkaz
              Endif
            Endif
          Endif
        Next j
      Endif
      is_1_den := is_last_den := .f.
      zs := kvp := 0
      oth_usl := kod_zs := ''
      is_neonat := .f.
      For i := 1 To Len( au_lu )
        If au_lu[ i, 3 ] == 0
          AAdd( ta, '� ��㣥 ' + AllTrim( au_lu[ i, 1 ] ) + ' �� ���⠢��� ��䨫�' )
        Endif
        If au_lu[ i, 4 ] == 0
          AAdd( ta, '� ��㣥 ' + AllTrim( au_lu[ i, 1 ] ) + ' �� ���⠢���� ᯥ�-�� ���' )
        Endif
        If au_lu[ i, 2 ] > dEnd
          AAdd( ta, '��㣠 ' + au_lu[ i, 5 ] + '(' + date_8( au_lu[ i, 2 ] ) + ') �� �������� � �������� ��祭��' )
        Endif
        If is_issled_pn( au_lu[ i ], mperiod, ta, mpol, dEnd )
          s := '��㣠 ' + au_lu[ i, 5 ] + '(' + date_8( au_lu[ i, 2 ] ) + ')'
          If mvozrast < 2
            If Left( au_lu[ i, 5 ], 5 ) == '4.26.'
              is_neonat := .t.
            Endif
            If au_lu[ i, 2 ] < AddMonth( dBegin, -1 )
              AAdd( ta, s + ' ������� ����� 1 ����� �����' )
            Endif
          Else
            If au_lu[ i, 2 ] < AddMonth( dBegin, -3 )
              AAdd( ta, s + ' ������� ����� 3 ����楢 �����' )
            Endif
          Endif
          If dBegin == au_lu[ i, 2 ]
            is_1_den := .t.
          Endif
        Else
          s := '��㣠 ' + au_lu[ i, 5 ] + '-' + inieditspr( A__MENUVERT, getv002(), au_lu[ i, 3 ] ) + '(' + date_8( au_lu[ i, 2 ] ) + ')'
          If eq_any( au_lu[ i, 3 ], 68, 57 ) .and. !( au_lu[ i, 5 ] == '2.4.2' )// ��祡�� ��� - ������� (��� ��饩 �ࠪ⨪�)
            If au_lu[ i, 2 ] < dBegin
              AAdd( ta, '��� �ᬮ�� ������� �� �������� � �������� ��祭��' )
            Endif
          Elseif is_1_etap_pn( au_lu[ i ], mperiod, metap, dEnd, m1mobilbr ) // �᫨ ��㣠 �� 1 �⠯�
            If mvozrast < 2
              If au_lu[ i, 2 ] < AddMonth( dBegin, -1 )
                AAdd( ta, s + ' ������� ����� 1 ����� �����' )
              Endif
            Else
              If au_lu[ i, 2 ] < AddMonth( dBegin, -3 )
                AAdd( ta, s + ' ������� ����� 3 ����楢 �����' )
              Endif
            Endif
          Elseif au_lu[ i, 2 ] < AddMonth( dBegin, -3 )  //dBegin
            AAdd( ta, s + ' �� �������� � �������� ��祭��' )
          Endif
          If Left( au_lu[ i, 1 ], 5 ) == '72.2.'
            ++zs
            kod_zs := AllTrim( au_lu[ i, 1 ] )
          Elseif eq_any( au_lu[ i, 3 ], 68, 57 ) // ������� (��� ��饩 �ࠪ⨪�)
            ++kvp
            If dBegin == au_lu[ i, 2 ]
              is_1_den := .t.
            Endif
            If dEnd == au_lu[ i, 2 ]
              is_last_den := .t.
            Endif
          Elseif is_osmotr_pn( au_lu[ i ], mperiod, ta, metap, mpol, dEnd, m1mobilbr )
            If eq_any( Left( au_lu[ i, 1 ], 4 ), '2.3.', '2.4.', '2.85', '2.91' )
              ++kvp
            Endif
            If dBegin == au_lu[ i, 2 ]
              is_1_den := .t.
            Endif
            If dEnd == au_lu[ i, 2 ]
              is_last_den := .t.
            Endif
          Elseif !( metap == 2 .and. is_lab_usluga( au_lu[ i, 1 ] ) )
//            oth_usl += AllTrim( au_lu[ i, 1 ] ) + ' '
          Endif
        Endif
      Next
      If metap == 1 .and. zs == 1
        s := ret_shifr_zs_pn( mperiod, dEnd )
        If !( kod_zs == s )
          AAdd( ta, '� �/� ��㣠 ' + kod_zs + ', � ������ ���� ' + s + ' ��� ������ ' + lstr( mvozrast ) + ' ' + s_let( mvozrast ) )
        Endif
      Elseif metap == 1 .and. zs > 1
        AAdd( ta, '� ���� ��� ����� ����� ��㣨 "�����祭�� ��砩"' )
      Elseif metap == 2 .and. zs > 0
        AAdd( ta, '��� �����⠯��� ��䨫��⨪� ��ᮢ��襭����⭨� �� ������ ���� ��� "�����祭�� ��砩"' )
      Endif
      If !Empty( oth_usl )
        AAdd( ta, '� ���� ��� �� ��譨� ��㣨: ' + oth_usl )
      Endif
      If !is_1_den
        // aadd(ta, '���� ��祡�� �ᬮ�� ������ ���� ������ � ���� ���� ��祭��')
      Endif
      If !is_last_den
        AAdd( ta, '��᫥���� ��祡�� �ᬮ�� ������ ���� ������ � ��᫥���� ���� ��祭��' )
      Endif
      k := 0
      For counter := dBegin To dEnd
        If is_work_day( counter )
          ++k
        Endif
      Next
      If metap == 1 .and. k > 20
        AAdd( ta, '�ப �� I �⠯� ������ ��⠢���� 20 ࠡ��� ���� (� ��� ' + lstr( k ) + ')' )
      Elseif metap == 2 .and. k > 45
        AAdd( ta, '�ப �� I � II �⠯� ������ ��⠢���� 45 ࠡ��� ���� (� ��� ' + lstr( k ) + ')' )
      Endif
      // �஢�ਬ, �믮����� ��易⥫�� ��㣨 (� �������)
      ar := AClone( np_arr_1_etap[ mperiod, 5 ] )
      For i := 1 To Len( ar ) // ��᫥�������
        lshifr := AllTrim( ar[ i ] )
        If AScan( au_lu, {| x| AllTrim( x[ 1 ] ) == lshifr } ) > 0
          // ��㣠 �������
        Elseif AScan( arr_usl_otkaz, {| x| ValType( x ) == 'A' .and. ValType( x[ 5 ] ) == 'C' .and. AllTrim( x[ 5 ] ) == lshifr } ) > 0
          // ��㣠 � �⪠���
        Else
          s := ''
          If ( j := AScan( np_arr_issled, {| x| x[ 1 ] == lshifr } ) ) > 0
            s := np_arr_issled[ j, 3 ]
          Endif
          AAdd( ta, '�����४⭮ ����ᠭ� ��᫥������� ' + lshifr + ' ' + s + ' (��।������)' )
        Endif
      Next
      ar := AClone( np_arr_1_etap[ mperiod, 4 ] )
      For i := 1 To Len( ar ) // �ᬮ��� 1 -�� �⠯�
        lshifr := AllTrim( ar[ i ] )
        If ( j := AScan( np_arr_osmotr, {| x| x[ 1 ] == lshifr } ) ) > 0
          fl := .f.
          If AScan( au_lu, {| x| AllTrim( x[ 1 ] ) == lshifr } ) > 0
            fl := .t. // ��㣠 �������
          Elseif AScan( arr_usl_otkaz, {| x| ValType( x ) == 'A' .and. ValType( x[ 5 ] ) == 'C' .and. AllTrim( x[ 5 ] ) == lshifr } ) > 0
            fl := .t. // ��㣠 � �⪠���
          Elseif !Empty( np_arr_osmotr[ j, 2 ] ) .and. !( np_arr_osmotr[ j, 2 ] == human->pol )
            Loop
          Else
            For k := 1 To Len( au_lu )
              // �஢��塞 ⮫쪮 �㫥�� ��㣨
              If eq_any( Left( au_lu[ k, 1 ], 4 ), '2.3.', '2.4.' )
                If ValType( np_arr_osmotr[ j, 4 ] ) == 'N'
                  If au_lu[ k, 3 ] == np_arr_osmotr[ j, 4 ]
                    fl := .t. // ��㣠 ������� (��諨 �� ��䨫�)
                    Exit
                  Endif
                Elseif AScan( np_arr_osmotr[ j, 4 ], au_lu[ k, 3 ] ) > 0
                  fl := .t. // ��㣠 ������� (��諨 �� ��䨫�)
                  Exit
                Endif
              Endif
            Next k
          Endif
          If !fl .and. dEnd < 0d20191101
            If mperiod == 16 .and. np_arr_osmotr[ j, 1 ] == '2.4.2' // 2 ����
              fl := .t. // ��㣠 �� ������ ���� �������
            Elseif mperiod == 20 .and. np_arr_osmotr[ j, 1 ] == '2.85.24' // 6 ���
              fl := .t. // ��㣠 �� ������ ���� �������
            Endif
          Endif
          If !fl
            AAdd( ta, '�����४⭮ ����ᠭ ��祡�� �ᬮ�� 1-�� �⠯� "' + np_arr_osmotr[ j, 3 ] + ' (��।������)' )
          Endif
        Endif
      Next i
      If Empty( ta ) // �᫨ ���� ��� �訡��
        fl := .f.
        For i := 1 To Len( au_lu )
          If eq_any( au_lu[ i, 3 ], 68, 57 ) ; // ������� (��� ��饩 �ࠪ⨪�)
            .and. Left( au_lu[ i, 1 ], 4 ) == '2.3.' // �� 1-�� �⠯�
            fl := .t. ; Exit
          Endif
        Next i
        If !fl
          AAdd( ta, '�����४⭮ ����ᠭ ��祡�� �ᬮ�� ������� �� 1-�� �⠯� (��।������)' )
        Endif
      Endif
    Else
      AAdd( ta, '�� 㤠���� ��।����� �����⭮� ��ਮ� ��� ��䨫��⨪� ��ᮢ��襭����⭥��' )
    Endif
  Endif
  If is_disp_DVN //
    m1mobilbr := 0
    human_->profil := 151  // ����樭᪨� �ᬮ�ࠬ ��䨫����᪨�
    ret_arr_vozrast_dvn( dEnd )
    ret_arrays_disp( dEnd )
    m1g_cit := m1veteran := m1dispans := 0 ; is_prazdnik := f_is_prazdnik_dvn( dBegin )

    For i := 1 To 5
      sk := lstr( i )
      pole_diag := 'mdiag' + sk
      pole_1pervich := 'm1pervich' + sk
      pole_1dispans := 'm1dispans' + sk
      pole_dn_dispans := 'mdndispans' + sk
      Private &pole_diag := Space( 6 )
      Private &pole_1pervich := 0
      Private &pole_1dispans := 0
      Private &pole_dn_dispans := CToD( '' )
    Next
    m1dopo_na := 0
    m1napr_v_mo := 0
    arr_mo_spec := {}
    m1napr_stac := 0
    m1profil_stac := 0
    m1napr_reab := 0
    m1profil_kojki := 0
    is_disp_nabl := .f.
    arr_nazn := {}
    read_arr_dvn( human->kod )
    If m1dopo_na > 0
      AAdd( arr_nazn, { 3, {} } ) ; j := Len( arr_nazn )
      For i := 1 To 4
        If IsBit( m1dopo_na, i )
          AAdd( arr_nazn[ j, 2 ], i )
        Endif
      Next
    Endif
    If Between( m1napr_v_mo, 1, 2 ) .and. !Empty( arr_mo_spec )
      AAdd( arr_nazn, { m1napr_v_mo, {} } ) ; j := Len( arr_nazn )
      For i := 1 To Min( 3, Len( arr_mo_spec ) )
        AAdd( arr_nazn[ j, 2 ], arr_mo_spec[ i ] )
      Next
    Endif
    If Between( m1napr_stac, 1, 2 ) .and. m1profil_stac > 0
      AAdd( arr_nazn, { iif( m1napr_stac == 1, 5, 4 ), m1profil_stac } )
    Endif
    If m1napr_reab == 1 .and. m1profil_kojki > 0
      AAdd( arr_nazn, { 6, m1profil_kojki } )
    Endif
    For i := 1 To 5
      sk := lstr( i )
      pole_diag := 'mdiag' + sk
      pole_1pervich := 'm1pervich' + sk
      pole_1dispans := 'm1dispans' + sk
      pole_dn_dispans := 'mdndispans' + sk
      arr_diag := { AllTrim( &pole_diag ), &pole_1pervich, &pole_1dispans, &pole_dn_dispans }
      // ����⢨� �� ����� � ���� ����
      If arr_diag[ 2 ] == 0 // '࠭�� �����'
        arr_diag[ 2 ] := 2  // �����塞, ��� � ���� ���� ���
      Endif
      If arr_diag[ 3 ] > 0 // '���.������� ��⠭������' � '࠭�� �����'
        If arr_diag[ 2 ] == 2 // '࠭�� �����'
          arr_diag[ 3 ] := 1 // � '���⮨�'
        Else
          arr_diag[ 3 ] := 2 // � '����'
        Endif
      Endif
      // ����⢨� �� ����� � ॥���
      s := 3 // �� �������� ��ᯠ��୮�� �������
      If arr_diag[ 2 ] == 1 // �����
        If arr_diag[ 3 ] == 2
          s := 2 // ���� �� ��ᯠ��୮� �������
        Endif
      Elseif arr_diag[ 2 ] == 2 // ࠭��
        If arr_diag[ 3 ] == 1
          s := 1 // ��⮨� �� ��ᯠ��୮� �������
        Elseif arr_diag[ 3 ] == 2
          s := 2 // ���� �� ��ᯠ��୮� �������
        Endif
      Endif
      If !Empty( arr_diag[ 1 ] ) .and. diag_in_list_dn( arr_diag[ 1 ] )
        If Empty( arr_diag[ 4 ] )
          If s == 2
            AAdd( ta, '�� ������� ��� ᫥���饣� ����� ��� ' + arr_diag[ 1 ] )
          Endif
        Elseif arr_diag[ 4 ] > dEnd
          If s == 1
            is_disp_nabl := .t.
          Endif
        Else
          AAdd( ta, '�����४⭠� ��� ᫥���饣� ����� ��� ' + arr_diag[ 1 ] )
        Endif
      Endif
    Next
    If yearBegin != yearEnd
      AAdd( ta, '��� ��砫� � ����砭�� ���� ������ ���� � ����� ����' )
    Endif
    For i := 1 To Len( au_lu_ne )
      s := AllTrim( au_lu_ne[ i, 1 ] )
      If !Empty( au_lu_ne[ i, 2 ] )
        s += '(' + AllTrim( au_lu_ne[ i, 2 ] ) + ')'
      Endif
      s += ' ' + AllTrim( au_lu_ne[ i, 3 ] )
      AAdd( ta, '����ୠ� ��㣠 "' + s + '" �� ' + date_8( au_lu_ne[ i, 4 ] ) + '�.' )
    Next
    metap := 3
    If Between( human->ishod, 201, 205 )
      metap := human->ishod -200
      license_for_dispans( 1, dBegin, ta )
    Else
      AAdd( ta, '��ᯠ��ਧ���/��䨫��⨪� ������ ���� ������� �१ ᯥ樠��� �࠭ �����' )
    Endif
    If m1veteran == 1
      If metap == 3
        AAdd( ta, '��䨫��⨪� ������ �� �஢���� ���࠭�� ��� (�����������)' )
      Else
        mdvozrast := ret_vozr_dvn_veteran( mdvozrast, dEnd )
      Endif
    Endif
    is_prof_disp := .f.
    // �᫨ �� ���ᬮ��
    If metap == 3 .and. AScan( ret_arr_vozrast_dvn( dEnd ), mdvozrast ) > 0 // � ������ ��ᯠ��ਧ�樨
      metap := 1 // �ॢ�頥� � ��ᯠ��ਧ���
      is_prof_disp := .t.
    Endif
    For i := 1 To Len( a_disp )
      // {human->ishod-200, human->n_data, human->k_data, human_->RSLT_NEW}
      If overlap_diapazon( a_disp[ i, 2 ], a_disp[ i, 3 ], dBegin, dEnd )
        AAdd( ta, '����祭�� � ' + iif( a_disp[ i, 1 ] == 3, '��䨫��⨪�� ', '��ᯠ��ਧ�樥� ' ) + ;
          date_8( a_disp[ i, 2 ] ) + '-' + date_8( a_disp[ i, 3 ] ) )
      Endif
    Next
    If metap == 2 .and. AScan( a_disp, {| x| x[ 1 ] == 1 } ) == 0
      AAdd( ta, '�� II �⠯ ��ᯠ��ਧ�樨, �� ��������� ��砩 I �⠯� ��ᯠ��ਧ�樨' )
    Elseif metap == 5 .and. AScan( a_disp, {| x| x[ 1 ] == 4 } ) == 0
      AAdd( ta, '�� II �⠯ ��ᯠ��ਧ�樨, �� ��������� ��砩 I �⠯� ��ᯠ��ਧ�樨 ࠧ � 2 ����' )
    Endif
    // �⬥⨬ ��易⥫�� ��㣨
    arr1 := Array( count_dvn_arr_usl, 5 )
    afillall( arr1, 0 )
    arr2 := Array( count_dvn_arr_umolch, 5 )
    afillall( arr2, 0 )
    For i := 1 To count_dvn_arr_usl
      fl_ekg := .f.
      i_otkaz := 0
      If f_is_usl_oms_sluch_dvn( i, metap, iif( metap == 3 .and. !is_disp_19, mvozrast, mdvozrast ), mpol, , @i_otkaz, @fl_ekg )
        arr1[ i, 2 ] := 1
        arr1[ i, 3 ] := i_otkaz
        arr1[ i, 5 ] := iif( fl_ekg, 1, 0 ) // 1 - ����易⥫�� ������
      Endif
    Next
    For i := 1 To count_dvn_arr_umolch
      If f_is_umolch_sluch_dvn( i, metap, iif( metap == 3 .and. !is_disp_19, mvozrast, mdvozrast ), mpol )
        arr2[ i, 2 ] := 1
      Endif
    Next
    // �⬥⨬ �믮������ ��㣨
    For j := 1 To Len( au_lu )
      lshifr := AllTrim( au_lu[ j, 1 ] )
      fl := .t.
      If !is_disp_19 .and. ( ( lshifr == '2.3.3' .and. au_lu[ j, 3 ] == 3 ) .or.  ; // �����᪮�� ����
        ( lshifr == '2.3.1' .and. au_lu[ j, 3 ] == 136 ) )  ; // �������� � �����������
        .and. ( i := AScan( dvn_arr_usl, {| x| ValType( x[ 2 ] ) == 'C' .and. x[ 2 ] == '4.1.12' } ) ) > 0
        arr1[ i, 1 ] ++
        fl := .f.
      Endif
      If fl
        For i := 1 To count_dvn_arr_umolch
          If arr2[ i, 1 ] == 0 .and. dvn_arr_umolch[ i, 2 ] == lshifr
            arr2[ i, 1 ] ++
            fl := .f.
            Exit
          Endif
        Next
      Endif
      If fl
        For i := 1 To count_dvn_arr_usl
          If metap == 2 .and. ValType( dvn_arr_usl[ i, 2 ] ) == 'C' .and. dvn_arr_usl[ i, 2 ] == lshifr
            s := '"' + dvn_arr_usl[ i, 2 ] + ' ' + dvn_arr_usl[ i, 1 ] + '"'
            If ValType( dvn_arr_usl[ i, 3 ] ) == 'N'
              If dvn_arr_usl[ i, 3 ] != 2
                AAdd( ta, '�� ���� �믮�����, � �믮����� ' + s )
              Endif
            Else
              If AScan( dvn_arr_usl[ i, 3 ], 2 ) == 0
                AAdd( ta, '�� ���� �믮�����, � �믮����� ' + s )
              Endif
            Endif
          Endif
          If arr1[ i, 1 ] == 0
            If ValType( dvn_arr_usl[ i, 2 ] ) == 'C'
              If dvn_arr_usl[ i, 2 ] == '4.20.1'
                If lshifr == '4.20.1'
                  m1g_cit := 1
                Elseif lshifr == '4.20.2'
                  m1g_cit := 2 ; fl := .f.
                Endif
              Endif
              If dvn_arr_usl[ i, 2 ] == lshifr
                fl := .f.
              Endif
            Endif
            If fl .and. Len( dvn_arr_usl[ i ] ) > 11 .and. ValType( dvn_arr_usl[ i, 12 ] ) == 'A'
              If AScan( dvn_arr_usl[ i, 12 ], {| x| x[ 1 ] == lshifr .and. x[ 2 ] == au_lu[ j, 3 ] } ) > 0
                fl := .f.
              Endif
            Endif
            If !fl
              arr1[ i, 1 ] ++
              Exit
            Endif
          Endif
        Next
      Endif
      If fl .and. !is_disp_19 .and. AScan( dvn_700, {| x| x[ 2 ] == lshifr } ) > 0
        fl := .f. // � �㫥��� ��㣥 ��������� ��㣠 � 業�� �� '700'
      Endif
      If fl .and. !eq_any( Left( lshifr, 5 ), '70.3.', '70.7.', '72.1.', '72.5.', '72.6.', '72.7.' )
        AAdd( ta, lshifr + ' - �����४⭠� ����ன�� � �ࠢ�筨�� ��� ��� �����' )
      Endif
    Next j
    is_1_den := is_last_den := .f.
    zs := kvp := 0
    oth_usl := ''
    mv := iif( metap == 3 .and. !is_disp_19, mvozrast, mdvozrast )
    kod_spec_ter := 0
    If eq_any( metap, 1, 4 )
      For i := 1 To Len( au_lu )
        If eq_any( au_lu[ i, 3 ], 97, 57, 42 ) // ��䨫� �࠯��� (��� ��饩 �ࠪ⨪�)
          kod_spec_ter := au_lu[ i, 4 ]  // ᯥ樠�쭮��� �࠯��� (��� ��饩 �ࠪ⨪�)
          Exit
        Endif
      Next
    Elseif eq_any( metap, 2, 5 ) // ����ઠ �� ��易⥫쭮� ��⠭�� ��� ��ண� �⠯�
      ar := Array( Len( dvn_2_etap ), 2 )
      afillall( ar, 0 )
      For i := 1 To Len( au_lu )
        lshifr := AllTrim( au_lu[ i, 1 ] )
        For j := 1 To Len( dvn_2_etap )
          If AScan( dvn_2_etap[ j, 1 ], lshifr ) > 0 .and. Between( mdvozrast, dvn_2_etap[ j, 3 ], dvn_2_etap[ j, 4 ] )
            ar[ j, 1 ] := 1
          Elseif AScan( dvn_2_etap[ j, 2 ], lshifr ) > 0 .and. Between( mdvozrast, dvn_2_etap[ j, 3 ], dvn_2_etap[ j, 4 ] )
            ar[ j, 2 ] := 1
          Endif
        Next
      Next
      For j := 1 To Len( dvn_2_etap )
        If Empty( ar[ j, 1 ] ) .and. !Empty( ar[ j, 2 ] )
          If Len( dvn_2_etap[ j, 2 ] ) == 1
            s := '��� ��㣨 ' + dvn_2_etap[ j, 2, 1 ]
          Else
            s := '��� ��� ' + print_array( dvn_2_etap[ j, 2 ] )
          Endif
          s += ' ��易⥫쭮 ����稥 ��㣨 '
          If Len( dvn_2_etap[ j, 1 ] ) == 1
            s += dvn_2_etap[ j, 1, 1 ]
          Else
            s += print_array( dvn_2_etap[ j, 1 ] )
          Endif
          s += ' (� ������ �� ' + lstr( dvn_2_etap[ j, 3 ] ) + ' �� ' + lstr( dvn_2_etap[ j, 4 ] ) + ' ���)'
          AAdd( ta, s )
          // elseif !empty(ar[j, 1]) .and. empty(ar[j, 2])
          // aadd(ta, '��� ��㣨 ' + print_array(dvn_2_etap[j, 1]) + ' ��易⥫쭮 ����稥  ��� ' + print_array(dvn_2_etap[j, 2]))
        Endif
      Next
    Endif
    a_4_20_1 := { 0, 0 }
    For i := 1 To Len( au_lu )
      lshifr := AllTrim( au_lu[ i, 1 ] )
      Do Case
      Case lshifr == '4.1.12' // �ᬮ�� ����મ�, ���⨥ ����� (�᪮��)
        a_4_20_1[ 1 ] := 3
      Case eq_any( lshifr, '4.20.1', '4.20.2' ) // ���-� ���⮣� �⮫����᪮�� ���ਠ��
        a_4_20_1[ 2 ] := 3
        If lshifr == '4.20.2' .and. au_lu[ i, 7 ] < dBegin
          m1g_cit := 1
        Endif
      Endcase
    Next
    // ���� � �஢�ઠ �⪠���
    kol_d_usl := kol_d_otkaz := kol_n_date := kol_ob_otkaz := 0
    If ValType( arr_usl_otkaz ) == 'A'
      For j := 1 To Len( arr_usl_otkaz )
        ar := arr_usl_otkaz[ j ]
        If ValType( ar ) == 'A' .and. Len( ar ) >= 10 .and. ValType( ar[ 5 ] ) == 'C'
          lshifr := AllTrim( ar[ 5 ] )
          For i := 1 To count_dvn_arr_usl
            If ValType( dvn_arr_usl[ i, 2 ] ) == 'C' .and. ;
                ( dvn_arr_usl[ i, 2 ] == lshifr .or. ( Len( dvn_arr_usl[ i ] ) > 11 .and. ValType( dvn_arr_usl[ i, 12 ] ) == 'A' ;
                .and. AScan( dvn_arr_usl[ i, 12 ], {| x| x[ 1 ] == lshifr } ) > 0 ) )
              If ValType( ar[ 10 ] ) == 'N' .and. Between( ar[ 10 ], 1, 2 )
                ++kol_d_usl
                arr1[ i, 4 ] := ar[ 10 ] // 1-�⪠�, 2-�������������
                If lshifr == '4.1.12' // �ᬮ�� ����મ�, ���⨥ ����� (�᪮��)
                  a_4_20_1[ 1 ] := ar[ 10 ]
                Endif
                If ar[ 10 ] == 1
                  ++kol_d_otkaz
                  If is_disp_19 .and. eq_any( lshifr, '4.8.4', '4.14.66', '7.57.3', '2.3.1', '2.3.3', '4.1.12', '4.20.1', '4.20.2' )
                    ++kol_ob_otkaz // ���-�� �⪠��� �� ��易⥫��� ���
                  Endif
                  // ausl := {lshifr,mdate,hu_->profil,hu_->PRVS}
                  is_usluga_dvn( { lshifr, ar[ 9 ], ar[ 4 ], ar[ 2 ] }, mv, ta, metap, mpol, kod_spec_ter )
                  // �஢��塞 �� ᯥ樠�쭮���
                  uslugaaccordanceprvs( lshifr, human->vzros_reb, ar[ 2 ], ta, lshifr, iif( ValType( ar[ 1 ] ) == 'N', ar[ 1 ], 0 ) )
                Endif
              Endif
            Endif
          Next i
        Endif
      Next j
    Endif
    If kol_ob_otkaz > 0 .and. metap == 1 .and. !is_prof_disp
      AAdd( ta, '�����४⭮ ����ᠭ ��砩 ��䮮ᬮ�� � ��� ��ᯠ��ਧ�樨 - ��।������' )
    Endif
    If !eq_any( metap, 2, 5 ) // �஢�ਬ, �믮����� ��易⥫�� ��㣨 (� �������)
      For i := 1 To count_dvn_arr_usl
        s := '"' + iif( ValType( dvn_arr_usl[ i, 2 ] ) == 'C', dvn_arr_usl[ i, 2 ] + ' ', '' )
        s += dvn_arr_usl[ i, 1 ] + '"'
        If arr1[ i, 2 ] == 0 // �� ���� �믮�����
          If arr1[ i, 1 ] > 1
            AAdd( ta, '�� ���� �믮�����, � �믮����� ' + s )
          Endif
        Elseif arr1[ i, 2 ] == 1 // ���� �믮�����
          If eq_any( arr1[ i, 4 ], 1, 2 ) ;// �⪠�, ����������
            .and. ValType( dvn_arr_usl[ i, 2 ] ) == 'C' .and. dvn_arr_usl[ i, 2 ] == '4.1.12'
            If a_4_20_1[ 2 ] == 3
              AAdd( ta, '�� ������ ���� ��㣨 "4.20.1 ��᫥������� ���⮣� �⮫����᪮�� ���ਠ��", �.�. � ��㣥 ' + s + ' �⮨� ' + { '�����', '�������������' }[ arr1[ i, 4 ] ] + ' - ��।������' )
            Endif
          Endif
          If arr1[ i, 1 ] == 0 .and. arr1[ i, 5 ] == 0 // ��� + ��易⥫�� ������
            If arr1[ i, 4 ] == 2 .and. arr1[ i, 3 ] < 2 // '����������', ࠧ��� '�⪠�'
              AAdd( ta, '������� ��⠭������ "�������������" �������� ��㣨 ' + s )
            Elseif arr1[ i, 4 ] == 0 // �� �⪠�
              fl := .t.
              If ValType( dvn_arr_usl[ i, 2 ] ) == 'C'
                If dvn_arr_usl[ i, 2 ] == '4.20.1' .and. a_4_20_1[ 1 ] < 3
                  fl := .f.
                Endif
              Endif
              If fl
                AAdd( ta, '�� ������� ��㣠 ' + s )
              Endif
            Endif
          Elseif arr1[ i, 1 ] > 1
            AAdd( ta, '�믮����� ����� ����� ��㣨 ' + s )
          Endif
        Endif
      Next
      For i := 1 To count_dvn_arr_umolch
        s := '"' + dvn_arr_umolch[ i, 2 ] + ' ' + dvn_arr_umolch[ i, 1 ] + '"'
        If arr2[ i, 2 ] == 0 // �� ���� �믮�����
          If arr2[ i, 1 ] > 1
            AAdd( ta, '�� ���� �믮�����, � �믮����� ' + s )
          Endif
        Elseif arr2[ i, 2 ] == 1 // ���� �믮�����
          If Empty( arr2[ i, 1 ] )
            AAdd( ta, '��� ��㣨 ' + s )
          Elseif arr2[ i, 1 ] > 1
            AAdd( ta, '����� ����� ��㣨 ' + s )
          Endif
        Endif
      Next
    Endif
    k700 := kkt := kzad := 0
    For i := 1 To Len( au_lu )
      hu->( dbGoto( au_lu[ i, 9 ] ) )       // 9 - ����� �����
      lshifr := AllTrim( au_lu[ i, 1 ] )
      If Left( lshifr, 4 ) == '2.3.' .and. !Empty( au_lu[ i, 3 ] )
        s := '��㣠 ' + au_lu[ i, 5 ] + '-' + inieditspr( A__MENUVERT, getv002(), au_lu[ i, 3 ] ) + '(' + date_8( au_lu[ i, 2 ] ) + ')'
      Else
        s := '��㣠 ' + au_lu[ i, 5 ] + '(' + date_8( au_lu[ i, 2 ] ) + ')'
      Endif
      If au_lu[ i, 3 ] == 0
        AAdd( ta, s + ' - �� ���⠢��� ��䨫�' )
      Endif
      If au_lu[ i, 4 ] == 0
        AAdd( ta, s + ' - �� ���⠢���� ᯥ�-�� ���' )
      Endif
      If au_lu[ i, 2 ] > dEnd
        AAdd( ta, s + ' �� �������� � �������� ��祭��' )
      Endif
      If is_usluga_dvn( au_lu[ i ], mv, ta, metap, mpol, kod_spec_ter )
        If metap == 1 .and. Empty( hu->u_cena ) .and. !eq_any( Left( lshifr, 5 ), '4.20.', '2.90.' )
          ++kol_d_usl
        Elseif metap == 3 .and. !( lshifr == '56.1.14' )
          ++kol_d_usl
        Endif
        If dBegin == au_lu[ i, 2 ]
          is_1_den := .t.
        Endif
        If metap == 2
          If eq_any( lshifr, '7.2.701', '7.2.702', '7.2.703', '7.2.704', '7.2.705' )
            ++kkt
          Endif
          If eq_any( lshifr, '10.6.710', '10.4.701' )
            ++kzad
          Endif
        Endif
        If !eq_any( metap, 2, 5 ) .and. au_lu[ i, 2 ] < dBegin .and. !eq_any( lshifr, '4.20.1', '4.20.2' )
          If is_disp_19
            If Year( au_lu[ i, 2 ] ) < Year( dBegin ) // ���-�� ��� ��� �⪠�� �믮����� ࠭��
              ++kol_n_date                 // ��砫� �஢������ ��ᯠ��ਧ�樨 � �� �ਭ������� ⥪�饬� �������୮�� ����
            Endif
          Else
            ++kol_n_date // ��⥭� ࠭�� ��������� ��㣠
          Endif
        Endif
        If eq_any( metap, 2, 5 ) .and. au_lu[ i, 2 ] < dBegin
          AAdd( ta, s + ' �� �������� � �������� ��祭��' )
        Elseif Left( lshifr, 2 ) == '2.' .and. eq_any( au_lu[ i, 3 ], 97, 57, 42 )
          If au_lu[ i, 2 ] != dEnd
            AAdd( ta, s + ' - �࠯��� ������ �஢����� �ᬮ�� ��᫥����' )
          Endif
        Elseif AllTrim( au_lu[ i, 1 ] ) == '7.61.3' .and. !is_disp_19
          If eq_any( Year( au_lu[ i, 2 ] ), yearBegin, yearBegin - 1 )
            // � �祭�� �।�����饣� �������୮�� ���� ���� ���� �஢������ ��ᯠ��ਧ�樨 �஢������� ��ண���
          Else
            AAdd( ta, '��ண��� ������� � ������諮� �������୮� ����' )
          Endif
        Else
          If au_lu[ i, 2 ] < AddMonth( dBegin, -12 )
            AAdd( ta, s + ' ������� ����� 1 ���� �����' )
          Endif
        Endif
        If Left( lshifr, 5 ) == '2.84.'
          ++kvp
        Elseif eq_any( Left( lshifr, 4 ), '2.3.', '2.90' )
          ++kvp
        Endif
        If dBegin == au_lu[ i, 2 ]
          is_1_den := .t.
        Endif
        If dEnd == au_lu[ i, 2 ]
          is_last_den := .t.
        Endif
      Elseif AScan( dvn_700, {| x| x[ 2 ] == lshifr } ) > 0
        ++k700 // � �㫥��� ��㣥 ��������� ��㣠 � 業�� �� '700'
      Elseif eq_any( Left( lshifr, 5 ), '70.3.', '70.7.', '72.1.', '72.5.', '72.6.', '72.7.' )
        ++zs
        If is_prof_disp
          s := ret_shifr_zs_dvn( 3, mv, mpol, dEnd )
        Else
          s := ret_shifr_zs_dvn( metap, mv, mpol, dEnd )
        Endif
        If !( lshifr == s )
          AAdd( ta, '� �/� ��㣠 ' + lshifr + ', � ������ ���� ' + s + ' ��� ������ ' + lstr( mv ) + ' ' + s_let( mv ) + '. ��।������!' )
        Endif
      Else
        oth_usl += lshifr + ' '
      Endif
    Next
    If kkt > 1
      AAdd( ta, 'ࠧ�蠥��� �믮����� ⮫쪮 ���� ��楤��� ७⣥����䨨� ��� �� �࣠��� ��㤭�� ���⪨' )
    Endif
    If kzad > 1
      AAdd( ta, '�� ࠧ�蠥��� ᮢ���⭮ �ਬ����� ४�ᨣ��������᪮��� � ४�஬���᪮���' )
    Endif
    If AScan( ret_arr_vozrast_dvn( dEnd ), mdvozrast ) > 0
      If metap > 2
        AAdd( ta, '� ' + lstr( mdvozrast ) + s_let( mdvozrast ) + ' �஢������ ��ᯠ��ਧ���, � �஢����� ��䨫��⨪�' )
      Endif
    Else
      If eq_any( metap, 1, 2 )
        AAdd( ta, '� ' + lstr( mvozrast ) + s_let( mvozrast ) + ' �஢������ ��䨫��⨪�, � �஢����� ��ᯠ��ਧ���' )
      Endif
    Endif
    Do Case
    Case metap == 1 .or. ( metap == 3 .and. is_disp_19 )
      If zs > 1
        AAdd( ta, '� ���� ��� ����� ����� ��㣨 "�����祭�� ��砩"' )
      Elseif emptyall( zs, k700 ) .and. !is_disp_19
        AAdd( ta, '� ���� ��� ��� � 業��' )
      Endif
      If ( i := AScan( dvn_85, {| x| x[ 1 ] == kol_d_usl } ) ) > 0
        If is_disp_19
          k := dvn_85[ i, 1 ] - dvn_85[ i, 2 ]
          If kol_n_date + kol_d_otkaz <= k // �⪠�� + ࠭�� ������� ����� 15%
            If zs == 0
              AAdd( ta, '� ���� ��� ������ ���� ��㣠 "�����祭�� ��砩" - ��।������' )
            Endif
          Else
            AAdd( ta, '����� ��砩 �� ����� ���� ��ࠢ��� � �����, �.�. ������� ����� 85% ��� (������� � ��諮� �������୮� ����-' + lstr( kol_n_date ) + ', �⪠���-' + lstr( kol_d_otkaz ) + ', �ᥣ� ���뢠���� ���-' + lstr( kol_d_usl ) + ')' )
          Endif
        Else
          If ( k := dvn_85[ i, 1 ] - dvn_85[ i, 2 ] ) < kol_d_otkaz
            AAdd( ta, '�⪠�� ��樥�� ��⠢���� ' + lstr( kol_d_otkaz / kol_d_usl * 100, 5, 0 ) + '% (������ ���� �� ����� 15%)' )
            AAdd( ta, '�⪠���-' + lstr( kol_d_otkaz ) + ', �ᥣ� ���뢠���� ���-' + lstr( kol_d_usl ) )
          Elseif kol_n_date + kol_d_otkaz <= k // �⪠�� + ࠭�� ������� ����� 15%
            If zs == 0 .or. k700 > 0
              AAdd( ta, '� ���� ��� ������ ���� ��㣠 "�����祭�� ��砩" - ��।������' )
            Endif
          Else
            If zs > 0 .or. Empty( k700 )
              AAdd( ta, '� ���� ��� �� ������ ���� ��㣨 "�����祭�� ��砩" - ��।������' )
            Endif
          Endif
        Endif
      Else
        AAdd( ta, '᫨誮� ����� �⪠���-' + lstr( kol_d_otkaz ) + ' ���-' + lstr( kol_d_usl ) )
      Endif
    Case metap == 4
      If zs > 1
        AAdd( ta, '� ���� ��� ����� ����� ��㣨 "�����祭�� ��砩"' )
      Elseif emptyall( zs, k700 )
        AAdd( ta, '� ���� ��� ��� ��� � 業��' )
      Endif
    Case eq_any( metap, 2, 5 )
      If zs > 0
        AAdd( ta, '��� II �⠯� ��� �� ������ ���� ��� "�����祭�� ��砩"' )
      Endif
    Case metap == 3 .and.  !is_disp_19
      If zs > 1
        AAdd( ta, '� ���� ��� ����� ����� ��㣨 "�����祭�� ��砩"' )
      Endif
      If ( i := AScan( prof_vn_85, {| x| x[ 1 ] == kol_d_usl } ) ) > 0
        If prof_vn_85[ i, 1 ] - prof_vn_85[ i, 2 ] < kol_d_otkaz
          AAdd( ta, '�⪠�� ��樥�� ��⠢���� ' + lstr( kol_d_otkaz / kol_d_usl * 100, 5, 0 ) + '% (������ ���� �� ����� 15%)' )
          AAdd( ta, '�⪠���-' + lstr( kol_d_otkaz ) + ', �ᥣ� ���뢠���� ���-' + lstr( kol_d_usl ) )
        Endif
      Else
        AAdd( ta, '᫨誮� ����� �⪠���-' + lstr( kol_d_otkaz ) )
      Endif
    Endcase
    If !Empty( oth_usl )
      AAdd( ta, '� ���� ��� ��� ��譨� ��㣨: ' + oth_usl )
    Endif
    If !is_1_den
      // aadd(ta, '���� ��祡�� �ᬮ�� ������ ���� ������ � ���� ���� ��祭��')
    Endif
    If !is_last_den
      AAdd( ta, '��᫥���� ��祡�� �ᬮ�� ������ ���� ������ � ��᫥���� ���� ��祭��' )
    Endif
    If metap != 3 .and. eq_any( human_->RSLT_NEW, 317, 318, 355, 356 )
      adiag_talon := Array( 16 )
      For i := 1 To 16
        adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
      Next
      am := {}
      For i := 1 To Len( mdiagnoz )
        If !Empty( mdiagnoz[ i ] ) .and. eq_any( adiag_talon[ i * 2 ], 1, 2 )
          AAdd( am, mdiagnoz[ i ] ) // ���ᨢ ��������� � ��ᯠ��ਧ�樥�
        Endif
      Next
      Do Case
      Case human_->RSLT_NEW == 317 // {'�஢����� ��ᯠ��ਧ��� - ��᢮��� I ��㯯� ���஢��'   , 1, 317}
        If !Empty( am )
          AAdd( ta, '��� I ��㯯� ���஢�� �� ������ ���� ��⠭������� ��ᯠ��୮�� ���� ' + print_array( am ) )
        Endif
      Case human_->RSLT_NEW == 318 // {'�஢����� ��ᯠ��ਧ��� - ��᢮��� II ��㯯� ���஢��'  , 2, 318}
        fl := .f.
        For i := 1 To Len( am )
          If Left( am[ i ], 3 ) == 'E78'
            fl := .t.
          Else
            AAdd( ta, '��� II ��㯯� ���஢�� ��ᯠ���� ���� ����� ���� ��⠭����� ⮫쪮 ��� �����宫���ਭ����, � �� ��� ' + am[ i ] )
          Endif
        Next
        If fl .and. m1dispans != 3 // {'���⪮�� �࠯��⮬', 3}
          AAdd( ta, '��� II ��㯯� ���஢�� "��ᯠ��୮� ������� ��⠭������" ����� ���� ⮫쪮 "���⪮�� �࠯��⮬"' )
        Endif
      Case human_->RSLT_NEW == 355 // {'�஢����� ��ᯠ��ਧ��� - ��᢮��� III� ��㯯� ���஢��', 3, 355}
        If Empty( am )
          AAdd( ta, '��� III� ��㯯� ���஢�� ��易⥫쭮 ������ ���� ��⠭����� ��ᯠ���� ����' )
        Endif
      Case human_->RSLT_NEW == 356 // {'�஢����� ��ᯠ��ਧ��� - ��᢮��� III� ��㯯� ���஢��', 4, 356}
        If Empty( am )
          AAdd( ta, '��� III� ��㯯� ���஢�� ��易⥫쭮 ������ ���� ��⠭����� ��ᯠ���� ����' )
        Endif
      Endcase
    Endif
  Endif

  If is_disp_DVN_COVID
    If ( human->k_data < 0d20210701 )
      AAdd( ta, '㣫㡫����� ��ᯠ��ਧ��� ��᫥ COVID ��砫��� � 01 ��� 2021 ����' )
    Endif
    m1dopo_na := 0
    m1napr_v_mo := 0
    arr_mo_spec := {}
    m1napr_stac := 0
    m1profil_stac := 0
    m1napr_reab := 0
    m1profil_kojki := 0
    is_disp_nabl := .f.
    arr_nazn := {}
    read_arr_dvn_covid( human->kod )
  Endif

  If is_disp_DRZ
    If ( human->k_data < 0d20240301 )
      AAdd( ta, '��ᯠ��ਧ��� ९த�⨢���� ���஢�� ��砫��� � 01 ���� 2024 ����' )
    Endif
    m1dopo_na := 0
    m1napr_v_mo := 0
    arr_mo_spec := {}
    m1napr_stac := 0
    m1profil_stac := 0
    m1napr_reab := 0
    m1profil_kojki := 0
    is_disp_nabl := .f.
    arr_nazn := {}
    read_arr_drz( human->kod )
    If eq_any( human_->RSLT_NEW, 376, 377 ) .and. ;
        ( m1dopo_na == 0 ) .and. ( m1napr_v_mo == 0 ) .and. ( m1napr_stac == 0 ) .and. ( m1napr_reab == 0 )
      AAdd( ta, '��� ��࠭��� ������ �������� �� ��࠭� �����祭�� (���ࠢ�����) ��� ��樥��' )
    endif
    If ( ( human->ishod - BASE_ISHOD_RZD ) == 1 ) .and. ;
        eq_any( human_->RSLT_NEW, 378, 379 ) .and. ;
        ( ( m1dopo_na != 0 ) .or. ( m1napr_v_mo != 0 ) .or. ( m1napr_stac != 0 ) .or. ( m1napr_reab != 0 ) )
      AAdd( ta, '�� ���ࠢ����� �� II �⠯ �� ����᪠���� �����祭�� (���ࠢ�����) ��� ��樥��' )
    Endif

  Endif

  //
  // �������� ����� � ������������ ���������� ��� ��� ��� 60.4.583, 60.4.584
  //
  fl := .f.
  iFind := 0
  iCount := 0
  cUsluga := ''
  aCheck := { { '7.2.706', 'A06.09.007.002' }, { '7.57.704', 'A06.20.004' }, { '7.61.704', 'A06.09.006.001' }, { '60.4.583', 'A06.09.005' }, { '60.4.584', 'A06.23.004' } }
  for counter := 1 to len( arrUslugi )
    if ( iFind := AScan( aCheck, {| x | x[ 1 ] == arrUslugi[ counter ] } ) ) > 0
      iCount := counter
      cUsluga := aCheck[ iFind, 2 ]
      fl := .t.
      exit
    endif
  next
  if fl
    if Empty( human_2->NPR_DATE )
      AAdd( ta, '��� ��㣨 ' + arrUslugi[ iFind ] + ' ��易⥫쭮 ���ࠢ�����' )
    endif
    if ( human_->USL_OK != USL_OK_POLYCLINIC )
      AAdd( ta, '��㣠 ' + arrUslugi[ iFind ] + ' ����뢠���� ⮫쪮 � ���㫠���� �᫮����' )
    endif
    if ( AllTrim( mdiagnoz[ 1 ] ) != 'Z01.8' ) .and. SubStr( arrUslugi[ iCount ], 1, 5 ) != '60.4.'
      AAdd( ta, '��� ��㣨 ' + arrUslugi[ iCount ] + ' ����室��� ����� �᭮���� ������� Z01.8, ' ;
        + '� ��� ��࠭ ' + AllTrim( mdiagnoz[ 1 ] ) + '!' )
    endif
    if AScan( arrUslugi, cUsluga ) > 0
      AAdd( ta, '� ��砥 ����室��� 㤠���� ���� ' + cUsluga )
    endif
  endif

  //
  // �������� ������������� ����������
  //
  If ( eq_any( AllTrim( mdiagnoz[ 1 ] ), 'U07.1', 'U07.2' ) .and. ( count_years( human->DATE_R, human->k_data ) >= 18 ) ;
      .and. !check_diag_pregant() .and. Empty( human_->DATE_R2 ) ) ;
      .or. ( is_oncology == 2 .and. iif( substr( lower( ONKSL->crit ), 1, 2 ) == 'sh', .t., .f. ) )
    If ( human_->USL_OK == USL_OK_HOSPITAL ) .and. ( human->k_data >= 0d20220101 )
      flLekPreparat := ( human_->PROFIL != 158 ) .and. ( human_->VIDPOM != 32 ) ;
        .and. ( Lower( AllTrim( human_2->PC3 ) ) != 'stt5' )
    Elseif ( human_->USL_OK == USL_OK_POLYCLINIC ) .and. ( human->k_data >= 0d20220401 )
      flLekPreparat := ( human_->PROFIL != 158 ) .and. ( human_->VIDPOM != 32 ) ;
        .and. ( get_idpc_from_v025_by_number( human_->povod ) == '3.0' )
    elseIf ( human_->USL_OK == USL_OK_HOSPITAL .or. human_->USL_OK == USL_OK_DAY_HOSPITAL ) ;
        .and. ( human->k_data >= 0d20250101 ) .and. is_oncology == 2
      flLekPreparat := .t.
    Endif
  Endif

  If flLekPreparat
    arrLekPreparat := collect_lek_pr( rec_human ) // �롥६ ������⢥��� �९����
    If Len( arrLekPreparat ) == 0  // ���⮩ ᯨ᮪ ������⢥���� �९��⮢
      if is_oncology == 2
        AAdd( ta, '��� ��࠭���� ���� 娬���࠯�� ' + alltrim( lower( ONKSL->crit ) ) + ' ����室�� ���� ������⢥���� �९��⮢' )
      else
        AAdd( ta, '��� ��������� U07.1 � U07.2 ����室�� ���� ������⢥���� �९��⮢' )
      endif
    Else  // �� ���⮩ �஢�ਬ ���
      For Each row in arrLekPreparat
        If Empty( row[ 1 ] )
          AAdd( ta, '�� 㪠���� ��� ��ꥪ樨' )
        Endif
        If ! between_date( human->n_data, human->k_data, row[ 1 ] )
          AAdd( ta, '��� ��ꥪ樨 �� �室�� � ��ਮ� ����' )
        Endif
        if is_oncology == 2
          s_lek_pr := AllTrim( get_lek_pr_by_id( row[ 3 ] ) )
          If Empty( row[ 5 ] )
            AAdd( ta, '���: ' + dtoc( row[ 1 ] ) + ' ��� "' + s_lek_pr + '" �� ������� ������⢮ ������⢥����� �९��� (�������饣� ����⢠)' )
          Endif
          If Empty( row[ 9 ] )
            AAdd( ta, '���: ' + dtoc( row[ 1 ] ) + ' ��� "' + s_lek_pr + '" �� ������� ������⢮ ����室�������� (��������� + �⨫���஢������) ������⢥����� �९���' )
          Endif
          If Empty( row[ 10 ] )
            AAdd( ta, '���: ' + dtoc( row[ 1 ] ) + ' ��� "' + s_lek_pr + '" �� ������� 䠪��᪠� �⮨����� ���. �९��� �� ������� ����७��' )
          Endif
        else    // ��� COVID19
          If Empty( row[ 2 ] )
            AAdd( ta, '����� �奬� ��祭��' )
          Endif
          If Empty( row[ 8 ] )
            AAdd( ta, '����� �奬� ᮮ⢥��⢨� �९��⠬' )
          Endif
          If ( arrGroupPrep := get_group_prep_by_kod( AllTrim( row[ 8 ] ), row[ 1 ] ) ) != nil
            mMNN := iif( arrGroupPrep[ 3 ] == 1, .t., .f. )
            If mMNN
              If Empty( row[ 3 ] )
                AAdd( ta, '��� "' + AllTrim( arrGroupPrep[ 2 ] ) + '" �� ��࠭ ������⢥��� �९���' )
              Endif
              If Empty( row[ 4 ] )
                AAdd( ta, '��� "' + AllTrim( arrGroupPrep[ 2 ] ) + '" �� ��࠭� ������ ����७��' )
              Endif
              If Empty( row[ 5 ] )
                AAdd( ta, '��� "' + AllTrim( arrGroupPrep[ 2 ] ) + '" �� ��࠭� ���� �९���' )
              Endif
              If Empty( row[ 6 ] )
                AAdd( ta, '��� "' + AllTrim( arrGroupPrep[ 2 ] ) + '" �� ��࠭ ᯮᮡ �������� �९���' )
              Endif
              If Empty( row[ 7 ] )
                AAdd( ta, '��� "' + AllTrim( arrGroupPrep[ 2 ] ) + '" �� ������⢮ ��ꥪ権 � ����' )
              Endif
            endif
          Endif
        Endif
      Next
    Endif
  Endif

  //
  // �������� ���������� ��������� "109-��祭�� �த������", ������ 356
  // ���쬮 �.�.��⮭���� 26.11.24
  //
  if ( human_->USL_OK == USL_OK_HOSPITAL ) .and. ( human_->RSLT_NEW == 109 ) // ��祭�� �த������
    fl := .f.
    for counter := 1 to len( arrUslugi )
      if ! eq_any( arrUslugi[ counter ], 'st19.090', 'st19.091', 'st19.092', 'st19.093', ;
          'st19.094', 'st19.095', 'st19.096', 'st19.097', 'st19.098', 'st19.099', ;
          'st19.100', 'st19.101', 'st19.102' )
        fl := .t.
      endif
    next
    if fl
      AAdd( ta, '��� ��࠭���� ��� �� �����⨬� �ਬ������ १���� ���饭�� "109-��祭�� �த������"' )
    endif
  endif

  //
  // �������� ����������� ���. ����������, ������ 348
  //
  // if ((substr(human_->OKATO, 1, 2) != '34') .and. (human_->USL_OK == USL_OK_HOSPITAL .or. human_->USL_OK == USL_OK_DAY_HOSPITAL)  ;
  // .and. substr(human_->FORMA14, 1, 1) == '0')
  // if  substr(ret_mo(human_->NPR_MO)[_MO_KOD_FFOMS], 1, 2) == '34'
  // aadd(ta, '��� �������� ��ᯨ⠫���樨 �����த��� ��樥�⮢ �ॡ���� ���ࠢ����� �� ����樭᪮�� ��०����� ��㣮�� ॣ����')
  // endif
  // endif

  //
  // �������� ��� ������� ��������� Z00-Z99 � �����������
  //
  If human_->USL_OK == USL_OK_POLYCLINIC .and. between_diag( mdiagnoz[ 1 ], 'Z00', 'Z99' ) ;
      .and. ( ! diagnosis_for_replacement( mdiagnoz[ 1 ], human_->USL_OK ) )

    If lu_type == TIP_LU_STD .and. human_->RSLT_NEW != 314 .and. human_->RSLT_NEW != 308 .and. human_->RSLT_NEW != 309 ;
        .and. human_->RSLT_NEW != 311 .and. human_->RSLT_NEW != 315 .and. human_->RSLT_NEW != 305 .and. human_->RSLT_NEW != 306
      AAdd( ta, '��� �������� "' + mdiagnoz[ 1 ] + '" १���� ���饭�� ������ ���� 314 ��� 308 ��� 309 ��� 311 ��� 315 ��� 305 ��� 306' )
    Endif
    If lu_type == TIP_LU_STD .and. human_->ISHOD_NEW != 304 .and. human_->ISHOD_NEW != 306
      AAdd( ta, '��� �������� "' + mdiagnoz[ 1 ] + '" ��室 ����������� ������ ���� "304-��� ��६��" ��� "306-�ᬮ��"' )
    Endif

  Endif
  //
  // �������� ������������� ���������
  //
  If Year( human->k_data ) > 2021
    For Each row in arrUslugi // �஢�ਬ �� ��㣨 ����
      If service_requires_implants( row, human->k_data )
        // �஢�ਬ ����稥 ������⮢
        arrImplant := collect_implantant( human->kod )
        If ! Empty( arrImplant )
          For Each rowTmp in arrImplant
            If Empty( rowTmp[ 3 ] )
              AAdd( ta, '�� 㪠���� ��� ��⠭���� ������⠭�' )
            Endif
            If ! between_date( human->n_data, human->k_data, rowTmp[ 3 ] )
              AAdd( ta, '��� ��⠭���� ������⠭� �� �室�� � ��ਮ� ����' )
            Endif
            If Empty( rowTmp[ 4 ] )
              AAdd( ta, '��� ������⠭� ����室��� 㪠���� ��� ���' )
            Endif
            If Empty( rowTmp[ 5 ] )
              AAdd( ta, '��� ������⠭� ����室��� 㪠���� �਩�� �����' )
            Endif
          Next
        Else
          AAdd( ta, '��� ��㣨 ' + row + ' ��易⥫쭮 㪠����� ������⠭⮢' )
        Endif
      Endif
    Next
  Endif

  //
  // �������� ����������� ������
  //
  If is_exist_Prescription
    If human->k_data >= 0d20210801
      checksectionprescription( ta )
    Endif
  Endif
  //

  If is_pren_diagn //
    human_->PROFIL := 106 // ���ࠧ�㪮��� �������⨪�
    If human->n_data != human->k_data
      AAdd( ta, '��� ����砭�� ��祭�� ������ ᮢ������ � ��⮩ ��砫� ��祭��' )
    Endif
    If human->ishod != 99
      AAdd( ta, '�७�⠫쭠� �������⨪� �������� �१ ᯥ樠��� �࠭ �����' )
    Endif
    k1 := k2 := 0 ; oth_usl := ''
    For i := 1 To Len( au_lu )
      If eq_any( AllTrim( au_lu[ i, 1 ] ), '2.79.51', '8.30.3' )
        k1 += au_lu[ i, 6 ]
      Elseif AllTrim( au_lu[ i, 1 ] ) == '4.26.6'
        k1 += au_lu[ i, 6 ]
      Elseif AllTrim( au_lu[ i, 1 ] ) == '2.5.1'
        k2 += au_lu[ i, 6 ]
      Else
        oth_usl += AllTrim( au_lu[ i, 1 ] ) + ' '
      Endif
    Next
    If k1 != 3
      AAdd( ta, '� ���� ��� ����୮� ������⢮ ��易⥫��� ���' )
    Endif
    If k2 > 1
      AAdd( ta, '� ���� ��� ������ ���� �� ����� ����� ��㣨 2.5.1' )
    Endif
    If !Empty( oth_usl )
      AAdd( ta, '� ���� ��� �७�⠫쭮� �������⨪� ��譨� ��㣨: ' + oth_usl )
    Endif
  Endif
  If human_->USL_OK == USL_OK_AMBULANCE .and. !( is_71_1 .or. is_71_2 .or. is_71_3 )
    AAdd( ta, '��� �᫮��� "����� ������" �� ������� ��㣨 ���' )
  Endif
  If !Empty( u_1_stom )
    // ��ᬮ�� ��㣨� ��砥� ������� ���쭮��
    Select HUMAN
    Set Order To 2
    find ( Str( glob_kartotek, 7 ) )
    Do While human->kod_k == glob_kartotek .and. !Eof()
      If ( fl := ( yearEnd == Year( human->k_data ) .and. rec_human != human->( RecNo() ) ) )
        //
      Endif
      If fl .and. human->schet > 0 .and. eq_any( human_->oplata, 2, 9 )
        fl := .f. // ���� ���� ��� �� ���� ��� ���⠢��� ����୮
      Endif
      If fl .and. m1novor != human_->NOVOR
        fl := .f. // ���� ���� �� ����஦������� (��� �������)
      Endif
      If fl .and. human_->idsp == 4 // ��祡��-���������᪠� ��楤��
        Select HU
        find ( Str( human->kod, 7 ) )
        Do While hu->kod == human->kod .and. !Eof()
          lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
          If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
            lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
            If f_is_1_stom( lshifr )
              AAdd( ta, '������� ��㣠 ��ࢨ筮�� �⮬�⮫����᪮�� ��� ' + u_1_stom + ',' )
              AAdd( ta, ' � � ��砥 ' + date_8( human->n_data ) + '-' + date_8( human->k_data ) + ' 㦥 �뫠 ������� ��㣠 ' + lshifr )
            Endif
          Endif
          Select HU
          Skip
        Enddo
      Endif
      Select HUMAN
      Skip
    Enddo
    Select HUMAN
    Set Order To 1
    human->( dbGoto( rec_human ) )
  Endif

  If human_->oplata == 2
    AAdd( ta, '������ �� ����� � �訡��� � ��� �� ��।���஢��' )
  Endif
  If Len( arr_unit ) > 1
//    If Select( 'MOUNIT' ) == 0
//      sbase := prefixfilerefname( yearEnd ) + 'unit'
//      r_use( dir_exe() + sbase, cur_dir + sbase, 'MOUNIT' )
//    Endif
    s := 'ᮢ��㯭���� ��� ������ ���� �� ����� ���⭮� ������� ����, � � ������ ��砥: '
//    Select MOUNIT
    For i := 1 To Len( arr_unit )
//      find ( Str( arr_unit[ i ], 3 ) )
//      If Found()
//        s += AllTrim( mounit->name ) + ', '
//      Endif
      if ( iFind := AScan( arrPZ, { | x | x[ 2 ] == arr_unit[ i ] } ) ) > 0
//        s += arrPZ[ iFind, 3 ] + ', '
        s += arrPZ[ iFind, PZ_ARRAY_NAME ] + ', '
      endif
    Next
    AAdd( ta, Left( s, Len( s ) -2 ) )
  Endif
  If fl_view .and. !is_s_dializ .and. !is_dializ .and. !is_perito .and. Len( a_rec_ffoms ) > 0 // ����� ��������
    ltip := 0
    s := ''
    i := 1
    ASort( a_rec_ffoms, , , {| x, y| x[ 3 ] < y[ 3 ] } )
    If gusl_ok == USL_OK_POLYCLINIC // 3 - �����������
      If is_2_78
        ltip := 1
      Elseif is_2_80
        ltip := 2
      Elseif is_2_88
        ltip := 3
      Elseif is_2_89
        ltip := 4
      Endif
      If ltip == 0
        i := 0
      Else
        fl := .f.
        For i := 1 To Len( a_rec_ffoms )
          Select HU
          find ( Str( a_rec_ffoms[ i, 1 ], 7 ) )
          Do While hu->kod == a_rec_ffoms[ i, 1 ] .and. !Eof()
            lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
            If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
              lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
              left_lshifr_5 := Left( lshifr, 5 )
              If left_lshifr_5 == '2.78.'
                If !between_shifr( lshifr, '2.78.54', '2.78.60' )
                  a_rec_ffoms[ i, 2 ] := 1
                  s := AfterAtNum( '.', lshifr )
                  fl := .t.
                Endif
              Elseif left_lshifr_5 == '2.80.'
                If !between_shifr( lshifr, '2.80.34', '2.80.38' )
                  If ltip == 2 // �᫨ ��諮� � ����� ��祭�� '2.80.'
                    a_rec_ffoms[ i, 2 ] := 2
                    s := AfterAtNum( '.', lshifr )
                    fl := .t.
                  Endif
                Endif
              Elseif left_lshifr_5 == '2.88.'
                If !between_shifr( lshifr, '2.88.46', '2.88.51' )
                  a_rec_ffoms[ i, 2 ] := 3
                  s := AfterAtNum( '.', lshifr )
                  fl := .t.
                Endif
              Elseif left_lshifr_5 == '2.89.'
                a_rec_ffoms[ i, 2 ] := 4
                s := AfterAtNum( '.', lshifr )
                fl := .t.
              Endif
            Endif
            If fl
              Exit
            Endif
            Select HU
            Skip
          Enddo
          If fl
            Exit
          Endif
        Next
        If !fl
          i := 0
        Endif
      Endif
    Endif
    If i > 0
      Select D_SROK
      Append Blank
      d_srok->kod   := human->kod
      d_srok->tip   := ltip
      d_srok->tips  := d_sroks
      d_srok->otd   := human->otd
      d_srok->kod1  := a_rec_ffoms[ i, 1 ]
      d_srok->tip1  := a_rec_ffoms[ i, 2 ]
      d_srok->tip1s := s
      d_srok->dni   := a_rec_ffoms[ i, 3 ]
    Endif
  Endif
  If Len( arr_unit ) == 0 .and. ! lTypeLUOnkoDisp // .and. ! is_disp_DVN_COVID
    AAdd( ta, '�� � ����� �� ��� �� �����㦥� ��� ����-������' )
  Endif
  If is_disp_DDS .or. is_disp_DVN .or. is_prof_PN
    If eq_any( human_->RSLT_NEW, 317, 321, 332, 343, 347, 375 )
      If human->OBRASHEN == '1' // �����७�� �� ���
        AAdd( ta, '��ࢠ� ��㯯� �� ����� ���� ��᢮��� ��樥��� � �����७��� �� ���' )
      Endif
    Elseif eq_any( human_->RSLT_NEW, 323, 324, 325, 334, 335, 336, 349, 350, 351, 355, 356, 373, 374, 357, 358, 377, 379 )
      fl := !Empty( arr_onkna )
      If !fl .and. m1dopo_na > 0
        fl := .t.
      Endif
      If !fl .and. Between( m1napr_v_mo, 1, 2 ) .and. !Empty( arr_mo_spec )
        fl := .t.
      Endif
      If !fl .and. Between( m1napr_stac, 1, 2 ) .and. m1profil_stac > 0
        fl := .t.
      Endif
      If !fl .and. m1napr_reab == 1 .and. m1profil_kojki > 0
        fl := .t.
      Endif
      If !fl
        AAdd( ta, '��樥�� � ��㯯�� ���஢�� ����襩 2 ������ ���� ���ࠢ��� �� ���.��᫥�������, � ᯥ樠���⠬, �� ��祭�� ��� �� ॠ�������' )
      Endif
    Endif
  Endif
  arr := { 301, 305, 308, 314, 315, 317, 318, 321, 322, 323, 324, 325, 332, 333, 334, 335, 336, 343, 344, 347, 348, 349, 350, ;
    351, 353, 355, 356, 357, 358, 361, 362, 363, 364, 365, 366, 367, 368, 369, 370, 371, 372, 373, 374, ;
    375, 376, 377, 378, 379 }
  If human_->ISHOD_NEW == 306 .and. AScan( arr, human_->RSLT_NEW ) == 0
    AAdd( ta, '��� ��室� ����������� "306/�ᬮ��" �����४�� १���� ���饭�� "' + ;
      inieditspr( A__MENUVERT, getv009(), human_->RSLT_NEW ) + '"' )
  Endif
  If !emptyany( human_->NPR_MO, human_2->NPR_DATE ) .and. !Empty( s := verify_dend_mo( human_->NPR_MO, human_2->NPR_DATE, .t. ) )
    AAdd( ta, '���ࠢ���� ��: ' + s )
  Endif
  // mpovod := iif(len(arr_povod) == 1, arr_povod[1, 1], 0)
  If ( is_disp_DDS .or. is_disp_DVN .or. is_prof_PN ) .and. ;
      ( Between( dEnd, 0d20200320, 0d20200906 ) .or. Between( dBegin, 0d20200320, 0d20200906 ) )
    AAdd( ta, '��砩 �� ����� ���� ���� ࠭�� 7 ᥭ����' )
  Endif
  If Len( ta ) > 0
    _ocenka := 0
    If AScan( kod_LIS, glob_mo[ _MO_KOD_TFOMS ] ) > 0 .and. Type( 'old_npr_mo' ) == 'C'
      If !( old_npr_mo == human_->NPR_MO )
        If !( old_npr_mo == '000000' )
          verify_ff( -1, .t., 80 ) // ����᫮��� ��ॢ�� ��࠭���
        Endif
        add_string( Replicate( '=', 80 ) )
        add_string( '���ࠢ����� �� ��: ' + human_->NPR_MO + ' ' + ret_mo( human_->NPR_MO )[ _MO_SHORT_NAME ] )
        add_string( Replicate( '=', 80 ) )
      Endif
      old_npr_mo := human_->NPR_MO
    Endif
    verify_ff( 80 - Len( ta ) -3, .t., 80 )
    // �뢮� ��������� ��樥��
    add_string( '' )
    add_string( header_error )
    add_string( '' )

    If human->cena_1 == 0 ; // �᫨ 業� �㫥���
      .and. eq_any( human->ishod, 201, 202 ) // ��ᯠ��ਧ��� ���᫮�� ��ᥫ����
      ASize( ta, 1 ) // �⮡� �� �뢮���� �����᫥��� ��ப�
      AAdd( ta, '�� ��।����� �㬬� ���� - ��।������' )
    Endif
    For i := 1 To Len( ta )
      For j := 1 To perenos( t_arr, ta[ i ], 78 )
        If j == 1
          add_string( '- ' + t_arr[ j ] )
        Else
          add_string( PadL( AllTrim( t_arr[ j ] ), 80 ) )
        Endif
      Next
    Next
  Else
    If is_disp_DDS .or. is_prof_PN .or. is_disp_DVN
      mpzkol := 1
    Elseif AScan( kod_LIS, glob_mo[ _MO_KOD_TFOMS ] ) > 0 .and. eq_any( human_->profil, 6, 34 )
      mpzkol := Len( au_lu ) // ���-�� ��������
    Endif
    If Len( arr_unit ) == 1
//      If Select( 'MOUNIT' ) == 0
//        sbase := prefixfilerefname( yearEnd ) + 'unit'
//        r_use( dir_exe() + sbase, cur_dir + sbase, 'MOUNIT' )
//      Endif
//      Select MOUNIT
//      find ( Str( arr_unit[ 1 ], 3 ) )
//      If Found() .and. mounit->pz > 0
//        mpztip := mounit->pz
//      Endif
      if ( iFind := AScan( arrPZ, { | x | x[ 2 ] == arr_unit[ 1 ] } ) ) > 0
//        mpztip := arrPZ[ iFind, 1 ]
        mpztip := arrPZ[ iFind, PZ_ARRAY_ID ]
      endif
    Endif
    human_->POVOD := iif( Len( arr_povod ) > 0, arr_povod[ 1, 1 ], 1 )
    human_->PZTIP := mpztip
    human_->PZKOL := iif( mpzkol > 0, mpzkol, 1 )
  Endif
  alltrim_lshifr := alltrim( lshifr )
  If ( between_shifr( alltrim_lshifr, '2.88.111', '2.88.119' ) .and. ( human->k_data >= 0d20220201 ) )
    arr_povod[ 1, 1 ] := 1
    human_->POVOD := arr_povod[ 1, 1 ]
  Endif
  // ���� �᫮��� ᮣ��᭮ ᮮ⢥��⢨� ��� 楫� ���饭�� ᮣ��᭮ ⠡��� Excel �� 15.02.24
  if ( between_shifr( alltrim_lshifr, '2.88.1', '2.88.119' ) .and. ( human->k_data >= 0d20240201 ) )
    arr_povod[ 1, 1 ] := 1
    If is_dom .and. between_shifr( alltrim_lshifr, '2.88.46', '2.88.51' )
      arr_povod[ 1, 1 ] := 3 // 1.2 - ��⨢��� ���饭��, �.�. �� ����
    Endif
    human_->POVOD := arr_povod[ 1, 1 ]
  Endif

//  if ( human_->USL_OK == USL_OK_POLYCLINIC ) .and. empty( human_->P_CEL ) .and. ( len( arr_povod ) == 1 )
  if ( human_->USL_OK == USL_OK_POLYCLINIC ) .and. ( len( arr_povod ) == 1 )
    for counter := 1 to len( arrUslugi )
      mPCEL := getPCEL_usl( arrUslugi[ counter ] )
      human_->P_CEL := mPCEL
    next
  endif

  If !valid_guid( human_->ID_PAC )
    human_->ID_PAC := mo_guid( 1, human_->( RecNo() ) )
  Endif
  If !valid_guid( human_->ID_C )
    human_->ID_C := mo_guid( 2, human_->( RecNo() ) )
  Endif
  human_->ST_VERIFY := _ocenka // �஢�७
  If fl_view
    // dbUnLockAll()
  Endif

  Return ( _ocenka >= 5 )

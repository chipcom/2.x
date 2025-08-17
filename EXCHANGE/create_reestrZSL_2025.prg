#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'tfile.ch'

Static Sreestr_sem := '����� � ॥��ࠬ�'
Static Sreestr_err := '� ����� ������ � ॥��ࠬ� ࠡ�⠥� ��㣮� ���짮��⥫�.'
static err_admin := '����� � ����� ०�� ࠧ�襭 ⮫쪮 ������������ ��⥬�!'

// 16.08.25
Function create_reestrZSL_2025()

  Local mnyear, mnmonth, k := 0, k1 := 0
  Local buf := save_maxrow(), arr, adbf,  i           // , arr_m
  local lenPZ := 0  // ���-�� ��ப ���� ������ �� ��� ��⠢����� ॥���
  Local tip_lu
  Local t_smo   //, arr_smo := {}
  Local lshifr1, lbukva, c
  Local p_array_PZ

  private arr_m // ���� �� ���� ��� ��।���
  Private pkol := 0, psumma := 0, ;
    CODE_LPU := glob_mo[ _MO_KOD_TFOMS ], ;
    CODE_MO  := glob_mo[ _MO_KOD_FFOMS ]
//  private p_array_PZ

  If ! hb_user_curUser:isadmin()
    Return func_error( 4, err_admin )
  Endif

  // �६����
//  If find_unfinished_reestr_sp_tk()
//    Return func_error( 4, '����⠩��� ᭮��' )
//  Endif
//

  If ( arr_m := year_month( T_ROW, T_COL + 5, , 3 ) ) == NIL
    Return Nil
  Endif
  // !!! ��������
  If DONT_CREATE_REESTR_YEAR == arr_m[ 1 ]
    Return func_error( 4, '������� �� ' + Str( DONT_CREATE_REESTR_YEAR, 4 ) + ' ��� ������㯭�' )
  Endif
//  If !myfiledeleted( cur_dir() + 'tmpb' + sdbf() )
//    Return Nil
//  Endif
//  If !myfiledeleted( cur_dir() + 'tmp' + sdbf() )
//    Return Nil
//  Endif

  arr := { '�।�०�����!', ;
           '', ;
           '�� �६� ��⠢����� ॥���', ;
           '���� �� ������ ࠡ���� � ����� ���' }
  n_message( arr, , 'GR+/R', 'W+/R', , , 'G+/R' )
  
  stat_msg( '��������, ࠡ���...' )
  adbf := { ;
    { 'kod_tmp',  'N',  6, 0 }, ;
    { 'kod_human','N',  7, 0 }, ;
    { 'fio',      'C', 50, 0 }, ;
    { 'n_data',   'D',  8, 0 }, ;
    { 'k_data',   'D',  8, 0 }, ;
    { 'cena_1',   'N', 11, 2 }, ;
    { 'PZKOL',    'N',  3, 0 }, ;
    { 'PZ',       'N',  3, 0 }, ;
    { 'ishod',    'N',  3, 0 }, ;
    { 'tip',      'N',  1, 0 }, ;  // 1 - ����� ॥���, 2 -��ᯠ��ਧ���
    { 'yes_del',  'L',  1, 0 }, ;  // ���� �� 㤠���� ��᫥ �������⥫쭮� �஢�ન
    { 'PLUS',     'L',  1, 0 }, ;  // ����砥��� �� � ���
    { 'KOD_SMO',  'C',  5, 0 }, ;  // ��� ���
    { 'BUKVA',    'C',  1, 0 } ;   // �㪢� ���
  }
//  dbCreate( cur_dir() + 'tmpb', adbf )
//  Use ( cur_dir() + 'tmpb' ) new

  dbCreate( 'mem:tmpb', adbf, , .t., 'TMPB' )
  Index On FIELD->KOD_SMO + Str( FIELD->kod_human, 7 ) to ( 'mem:tmpb' )

  mnyear := arr_m[ 1 ]
  mnmonth := arr_m[ 3 ]

  adbf := { ;
    { 'MIN_DATE',    'D',     8,     0 }, ;
    { 'DNI',         'N',     3,     0 }, ;
    { 'NYEAR',       'N',     4,     0 }, ; // ����� ���;;
    { 'NMONTH',      'N',     2,     0 }, ; // ����� �����;;
    { 'KOL',         'N',     6,     0 }, ;
    { 'SUMMA',       'N',    15,     2 }, ;
    { 'KOD',         'N',     6,     0 }, ;
    { 'KOD_SMO',     'C',     5,     0 } ;
  }

  p_array_PZ := get_array_pz( mnyear )  // ����稬 ���ᨢ ����-������ �� ��� ��⠢����� ॥���
  lenPZ := len( p_array_PZ )

  For i := 0 To lenPZ   // ��� ⠡���� _moXunit 03.02.23
    AAdd( adbf, { 'PZ' + lstr( i ), 'N', 9, 2 } )
  Next i


  dbCreate( 'mem:a_smo', adbf, , .t., 'A_SMO' )
  Index On FIELD->kod_smo to ( 'mem:a_smo' )

  r_use( dir_server() + 'mo_otd', , 'OTD' )
  r_use( dir_server() + 'human_', , 'HUMAN_' )
  r_use( dir_server() + 'human', dir_server() + 'humand', 'HUMAN' )
  Set Relation To RecNo() into HUMAN_

  r_use( dir_server() + 'uslugi', , 'USL' )
  r_use( dir_server() + 'human_u_', , 'HU_' )
  r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
////  r_use( dir_server() + 'human_u', { dir_server() + 'human_u', ;
////    dir_server() + 'human_uk', ;
////    dir_server() + 'human_ud', ;
////    dir_server() + 'human_uv', ;
////    dir_server() + 'human_ua' }, 'HU' )
  Set Relation To RecNo() into HU_, To FIELD->u_kod into USL
  r_use( dir_server() + 'mo_su', , 'MOSU' )
  r_use( dir_server() + 'mo_hu', dir_server() + 'mo_hu', 'MOHU' )
  Set Relation To FIELD->u_kod into MOSU

  human->( dbSeek( DToS( arr_m[ 5 ] ), .t. ) )
  Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
    If ++k1 % 100 == 0
      @ MaxRow(), 1 Say lstr( k1 ) Color cColorSt2Msg
      @ Row(), Col() Say '/' Color 'W/R'
      @ Row(), Col() Say lstr( k ) Color cColorStMsg
    Endif
    OTD->( dbGoto( human->OTD ) )
    If ! ( OTD->( Eof() ) ) .and. ! ( OTD->( Bof() ) )
      tip_lu := OTD->TIPLU
    Else
      tip_lu := 0
    Endif
    If human->tip_h == B_STANDART .and. emptyall( human_->reestr, human->schet ) ;
        .and. ( human->cena_1 > 0 .or. human_->USL_OK == 4 .or. tip_lu == TIP_LU_ONKO_DISP ) ;
        .and. Val( human_->smo ) > 0 .and. human_->ST_VERIFY >= 5       // � �஢�ਫ�

      if empty( human_->smo )
        human->( dbSkip() )
        loop
      endif

      t_smo := iif( SubStr( AllTrim( human_->smo ), 1, 2 ) == '34', human_->smo, '34   ' )
      if ! A_SMO->( dbSeek( t_smo ) )
        A_SMO->( dbAppend() )
        A_SMO->nyear := mnyear
        A_SMO->nmonth := mnmonth
        A_SMO->min_date := arr_m[ 6 ]
        A_SMO->kod_smo := t_smo
      endif

      tmpb->( dbAppend() )
//      tmpb->kod_tmp := 1
      tmpb->kod_human := human->kod
      tmpb->fio := human->fio
      tmpb->n_data := human->n_data
      tmpb->k_data := human->k_data
      tmpb->cena_1 := human->cena_1
      tmpb->PZKOL := human_->pzkol
//      tmpb->PZ := 
      tmpb->ishod := human->ishod
      tmpb->tip := iif( is_dispanserizaciya( human->ishod ), 2, 1 ) // 1 - ����� ॥���, 2 -��ᯠ��ਧ���
//      tmpb->yes_del :=  // ���� �� 㤠���� ��᫥ �������⥫쭮� �஢�ન
      tmpb->PLUS := .t.  // ����砥��� �� � ���
      tmpb->kod_smo := t_smo

      // ��室�� �㪢� ��� ��� ����
      c := ' '
      hu->( dbSeek( Str( human->kod, 7 ), .t. ) )
      Do While hu->kod == human->kod .and. ! hu->( Eof() )
        lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
        lbukva := ' '
        If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data, , @lbukva )
          lshifr1 := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
          If hu->STOIM_1 > 0 .or. Left( lshifr1, 3 ) == '71.' .or. Left( lshifr1, 5 ) == '2.5.2'  // ᪮�� ������ � ���⠭���� ���� ��樥�⮢ �� ���. ����.
            If !Empty( lbukva )
              c := lbukva
              Exit
            Endif
          Endif
        Endif
        hu->( dbSkip() )
      Enddo
      tmpb->BUKVA := c

      ++k
      If A_SMO->kol < 999999
//        ++k
        If ! exist_reserve_ksg( human->kod, 'HUMAN', (HUMAN->ishod == 89 .or. HUMAN->ishod == 88) )
          A_SMO->kol++
          A_SMO->min_date := Min( A_SMO->min_date, human->k_data )
        Endif
        A_SMO->summa += human->cena_1
      Endif
    Endif
    Select HUMAN
    human->( dbSkip() )
  Enddo
  A_SMO->( dbGoTop() )
  do while ! A_SMO->( Eof() )
    k1 := Date() - A_SMO->min_date
    A_SMO->dni := iif( Between( k1, 1, 999 ), k1, 0 )
    A_SMO->( dbSkip() )
  Enddo
  Select A_SMO

  close_use_base( 'lusl' )
  close_use_base( 'luslc' )
  close_use_base( 'luslf' )
  close_list_alias( { 'OTD', 'HUMAN_', 'HUMAN', 'USL', 'USL1', 'HU_', 'HU', 'MOSU', 'MOHU' } )

  If k == 0
    rest_box( buf )
    func_error( 4, '��� ��樥�⮢ ��� ����祭�� � ॥��� � ��⮩ ����砭�� ' + arr_m[ 4 ] )
  Else
//    Use ( cur_dir() + 'A_SMO' ) new
//    k := Date() - A_SMO->min_date
//    A_SMO->dni := iif( Between( k, 1, 999 ), k, 0 )

//    dbSelectArea( 'A_SMO' )
    A_SMO->( dbGoTop() )
    rest_box( buf )
    If alpha_browse( T_ROW, 2, T_ROW + len( smo_volgograd() ) + 2, 77, 'f1create_reestr_2025', color0, ;
        '���믨ᠭ�� ॥���� ��砥�', 'R/BG', , , , , 'f2create_reestr_2025', , ;
        { '�', '�', '�', 'N/BG,W+/N,B/BG,W+/B,R/BG', .t., 180 } )
      rest_box( buf )
    endif
  endif
  close_list_alias( { 'HUMAN_', 'HUMAN', 'MO_OTD' } )

  close_list_alias( { 'A_SMO', 'TMPB' } )
  dbDrop( 'mem:a_smo' )  /* �᢮����� ������ */
  hb_vfErase( 'mem:a_smo.ntx' )  /* �᢮����� ������ �� �����᭮�� 䠩�� */
  dbDrop( 'mem:tmpb' )  /* �᢮����� ������ */
  hb_vfErase( 'mem:tmpb.ntx' )  /* �᢮����� ������ �� �����᭮�� 䠩�� */
  return nil

// 13.08.25
Function f1create_reestr_2025( oBrow )

  Local oColumn, n := 36, n1 := 20, blk

  // mm_month - public ���ᨢ �������� ����楢
  oColumn := TBColumnNew( '���', {|| Str( A_SMO->nyear, 4 ) + ' ' } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( '�����', {|| ' ' + mm_month()[ A_SMO->nmonth ] + ' ' } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( '��������', {|| substr( inieditspr( A__MENUVERT, smo_volgograd(), Val( A_SMO->kod_smo ) ), 1, 20 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( '���;max', {|| put_val( A_SMO->dni, 3 ) } )
  oColumn:defColor := { 5, 5 }
  oColumn:colorBlock := {|| { 5, 5 } }
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( Center( '���-��;������', 14 ), {|| Str( A_SMO->kol, 10 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( Center( '�㬬�;��砥�', 15 ), {|| Str( A_SMO->summa, 15, 2 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  status_key( '^<Esc>^ ��室;  ^<Enter>^ ��⠢��� ॥��� ��砥�;  ^<F9>^ ����� ᯨ᪠ ��樥�⮢' )
  Return Nil

// 13.08.25
Function f2create_reestr_2025( nKey, oBrow )

  Local rec, ret := -1, tmpSelect

  rec := A_SMO->( RecNo() )
  tmpSelect := Select()
  Do Case
  Case nkey == K_ENTER
      If Date() < SToD( StrZero( A_SMO->nyear, 4 ) + StrZero( A_SMO->nmonth, 2 ) + '11' )
        func_error( 10, '������� ' + date_8( Date() ) + ', � ॥���� ࠧ�蠥��� ���뫠�� � 11 �᫠' )
      Else  //  if mo_lock_task( X_OMS )
        control_and_create_schet_2025( A_SMO->kod_smo )
        dbSelectArea( 'A_SMO' )
        A_SMO->( dbGoto( rec ) )
        ret := 0
      endif
  Case nkey == K_F9
    print_list_pacients( A_SMO->kod_smo, A_SMO->nyear, A_SMO->nmonth )
  Endcase
  Select( tmpSelect )
  Return ret

// 14.08.25
function print_list_pacients( kod_smo, nyear, nmonth )

  Local buf, nfile := cur_dir() + 'spisok.txt', j
  Local ft

    buf := save_maxrow()
    mywait()
    ft := tfiletext():new( nfile, , .t., , .t. )
    ft:add_string( '' )
    ft:add_string( '���᮪ ��樥�⮢ �� ������ ��ਮ� ' + mm_month()[ nmonth ] + ' ' + Str( nyear, 4 ) + ' ����', FILE_CENTER, ' ' )
    ft:add_string( '' )

    j := 0
    tmpb->( dbGoTop() )
    Do While !tmpb->( Eof() )
      if tmpb->kod_smo == kod_smo
        ft:add_string( Str( ++j, 5 ) + '. ' + PadR( tmpb->fio, 47 ) + date_8( tmpb->n_data ) + '-' + ;
          date_8( tmpb->k_data ) )
      endif
      tmpb->( dbSkip() )
    Enddo
    Select A_SMO
    rest_box( buf )
    ft := nil
    viewtext( nfile, , , , .t., , , 2 )
    return nil

// 16.08.25
function control_and_create_schet_2025( kod_smo )

  // �� ࠡ�� �ᯮ���� ᮧ����� ������ A_SMO � TMPB

  Local k := 0, k1 := 0, fl, i, _k
  Local buf := save_maxrow()
  local lenPZ := 0  // ���-�� ��ப ���� ������ �� ��� ��⠢����� ॥���
  local arrKolSl
  Local j, pole
  Local nameArr
  Local p_tip_reestr  // ⨯ �ନ�㥬��� ������ ��砥�
  Local cFor, bFor, aBukva
  Local tip_lu
  Local t_smo   //, arr_smo := {}
  Local mnyear, mnmonth, bSaveHandler, arr, adbf
//  Local arr_m

  fl := .t.
//  bSaveHandler := ErrorBlock( {| x| Break( x ) } )

//  Begin Sequence
//    r_use( dir_server() + 'human' )
//    Index On Str( FIELD->schet, 6 ) + Str( FIELD->tip_h, 1 ) + Upper( SubStr( FIELD->fio, 1, 20 ) ) to ( dir_server() + 'humans' ) progress
//    Index On Str( if( FIELD->kod > 0, FIELD->kod_k, 0 ), 7 ) + Str( FIELD->tip_h, 1 ) to ( dir_server() + 'humankk' ) progress
//    Index On DToS( FIELD->k_data ) + FIELD->uch_doc to ( dir_server() + 'humand' ) progress
//    human->( dbCloseArea() )
//    r_use( dir_server() + 'human_u' )
//    Index On Str( FIELD->kod, 7 ) + FIELD->date_u to ( dir_server() + 'human_u' ) progress
//    human_u->( dbCloseArea() )
//    r_use( dir_server() + 'mo_hu' )
//    Index On Str( FIELD->kod, 7 ) + FIELD->date_u to ( dir_server() + 'mo_hu' ) progress
//    mo_hu->( dbCloseArea() )
//    r_use( dir_server() + 'human_3' )
//    Index On Str( FIELD->kod, 7 ) to ( dir_server() + 'human_3' ) progress
//    Index On Str( FIELD->kod2, 7 ) to ( dir_server() + 'human_32' ) progress
//    human_3->( dbCloseArea() )
//    r_use( dir_server() + 'mo_onkna' )
//    Index On Str( FIELD->kod, 7 ) to ( dir_server() + 'mo_onkna' ) progress
//    mo_onkna->( dbCloseArea() )
//    r_use( dir_server() + 'mo_onksl' )
//    Index On Str( FIELD->kod, 7 ) to ( dir_server() + 'mo_onksl' ) progress
//    mo_onksl->( dbCloseArea() )
//    r_use( dir_server() + 'mo_onkco' )
//    Index On Str( FIELD->kod, 7 ) to ( dir_server() + 'mo_onkco' ) progress
//    mo_onkco->( dbCloseArea() )
//    r_use( dir_server() + 'mo_onkdi' )
//    Index On Str( FIELD->kod, 7 ) + Str( FIELD->diag_tip, 1 ) + Str( FIELD->diag_code, 3 ) to ( dir_server() + 'mo_onkdi' ) progress
//    mo_onkdi->( dbCloseArea() )
//    r_use( dir_server() + 'mo_onkpr' )
//    Index On Str( FIELD->kod, 7 ) + Str( FIELD->prot, 1 ) to ( dir_server() + 'mo_onkpr' ) progress
//    mo_onkpr->( dbCloseArea() )
//    r_use( dir_server() + 'mo_onkus' )
//    Index On Str( FIELD->kod, 7 ) + Str( FIELD->usl_tip, 1 ) to ( dir_server() + 'mo_onkus' ) progress
//    mo_onkus->( dbCloseArea() )
//    r_use( dir_server() + 'mo_onkle' )
//    Index On Str( FIELD->kod, 7 ) + FIELD->regnum + FIELD->code_sh + DToS( FIELD->date_inj ) to ( dir_server() + 'mo_onkle' ) progress
//    mo_onkle->( dbCloseArea() )
//  RECOVER USING error
//    fl := func_error( 10, '�������� ���।�������� �訡�� �� ��२�����஢����!' )
//  End
//  ErrorBlock( bSaveHandler )

//        dbCloseAll()  // Close databases

  If fl
    // arr_m - PRIVATE ��६�����
    arrKolSl := verify_oms_2025( kod_smo, arr_m, .f. )
    clrline( MaxRow(), color0 )
    If arrKolSl[ 1 ] == 0 .and. arrKolSl[ 2 ] == 0
      // ��砥� ���
    Elseif arrKolSl[ 1 ] > 0 .and. arrKolSl[ 2 ] == 0
      p_tip_reestr := 1
    Elseif arrKolSl[ 1 ] == 0 .and. arrKolSl[ 2 ] > 0
      p_tip_reestr := 2
//    Elseif f_alert( { '', ;
    Elseif ( p_tip_reestr := f_alert( { '', ;
          PadC( '�롥�� ⨯ ॥��� ��砥� ��� ��ࠢ�� � �����', 70, '.' ), ;
          '' }, ;
          { ' ������ ~�����(' + lstr( arrKolSl[ 1 ] ) + ')', ' ������ �� ~��ᯠ��ਧ�樨(' + lstr( arrKolSl[ 2 ] ) + ')' }, ;
          1, 'W/RB', 'G+/RB', MaxRow() -6,, 'BG+/RB,W+/R,W+/RB,GR+/R' ) ) == 0
      rest_box( buf )
      return nil
    Endif
    mywait()
    _k := A_SMO->kol
    A_SMO->kol := 0
    A_SMO->summa := 0
    A_SMO->min_date := SToD( StrZero( A_SMO->nyear, 4 ) + StrZero( A_SMO->nmonth, 2 ) + '01' )
    For i := 0 To lenPZ
      pole := 'A_SMO->PZ' + lstr( i )
      &pole := 0
    Next
    r_use( dir_server() + 'human_3', { dir_server() + 'human_3', dir_server() + 'human_32' }, 'HUMAN_3' )
    Set Order To 2
    r_use( dir_server() + 'human_',, 'HUMAN_' )
    r_use( dir_server() + 'human', dir_server() + 'humank', 'HUMAN' )

    Set Relation To RecNo() into HUMAN_

//    Use ( cur_dir() + 'tmpb' ) new
//    SELECT tmpb
    dbSelectArea( 'tmpb' )

    Set Relation To FIELD->kod_human into HUMAN //, To FIELD->kod_human into HUMAN_
//    Go Top
    tmpb->( dbSeek( kod_smo, .t. ) )
    Do While ! ( tmpb->( Eof() ) ) .and. ( tmpb->kod_smo == kod_smo )
      If human_->ST_VERIFY >= 5 .and. tmpb->tip == p_tip_reestr
        A_SMO->kol++
        If tmpb->ishod == 89
          Select HUMAN_3
          find ( Str( human->kod, 7 ) )
          A_SMO->summa += human_3->cena_1
          A_SMO->min_date := Min( A_SMO->min_date, human_3->k_data )
          k := human_3->PZKOL
          Select TMPB
        Else
          A_SMO->summa += human->cena_1
          A_SMO->min_date := Min( A_SMO->min_date, human->k_data )
          k := human_->PZKOL
        Endif
        j := human_->PZTIP
        tmpb->fio := human->fio
        tmpb->PZ := j
        pole := 'A_SMO->PZ' + lstr( j )
        nameArr := get_array_PZ( A_SMO->nyear )
        If ( i := AScan( nameArr, {| x| x[ 1 ] == j } ) ) > 0 .and. !Empty( nameArr[ i, 5 ] )
          &pole := &pole + 1 // ���� �� ����
        Else
          if A_SMO->nyear > 2018
            &pole := &pole + k // ���� �� �����栬 ����-������
          else
            &pole := &pole + human_->PZKOL
          endif
        Endif
      Else
        tmpb->yes_del := .t. // 㤠���� ��᫥ �������⥫쭮� �஢�ન
      Endif
      tmpb->( dbSkip() )
    Enddo

    close_list_alias( { 'K006', 'PRPRK', 'HUMAN_3', 'HUMAN_', 'HUMAN' } )

    If A_SMO->kol == 0
      func_error( 4, '��᫥ �������⥫쭮� �஢�ન ������ ������� � ॥���' )
    Else
      If _k != A_SMO->kol
//        dbSelectArea( 'tmpb' )
//        Delete For yes_del
//        tmpb->( __dbPack() )
      Endif
      If A_SMO->nyear >= 2025
        cFor := 'FIELD->tip == ' + AllTrim( str( p_tip_reestr, 1 ) ) + '.and. FIELD->kod_smo == "' + kod_smo + '"'
        bFor := &( '{||' + cFor + '}' )
        tmpb->( __dbCopy( 'mem:tmp', , bFor ) )
        dbUseArea( .t., , 'mem:tmp', 'TMP', .t. )
// ᮡ�६ ����� ������
        aBukva := {}
        INDEX ON ( FIELD->BUKVA ) TO ( 'mem:bukva' ) unique
        tmp->( dbGoTop() )
        while ! tmp->( Eof() )
          AAdd( aBukva, tmp->BUKVA )
          tmp->( dbSkip() )
        end do
        tmp->( ordListClear() )
        hb_vfErase( 'mem:bukva.ntx' )  /* �᢮����� ������ �� �����᭮�� 䠩�� */
        tmp->( dbGoTop() )
//
        create1reestr_2025( A_SMO->( RecNo() ), A_SMO->nyear, A_SMO->nmonth, kod_smo, p_tip_reestr, aBukva )
        
        close_list_alias( { 'TMP' } )
        dbDrop( 'mem:tmp' )  /* �᢮����� ������ */
        hb_vfErase( 'mem:tmp.ntx' )  /* �᢮����� ������ �� �����᭮�� 䠩�� */

      Else
        func_error( 10, '������ ࠭�� ������ 2025 ���� �� �ନ�����!' )
      Endif
    Endif
  Endif
  rest_box( buf )
  return nil
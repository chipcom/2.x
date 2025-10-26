#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// 28.12.21
Function pripisnoe_naselenie( k )
  Static si1 := 1, si2 := 1, si3 := 1
  Local mas_pmt, mas_msg, mas_fun, j, r, nuch, nsmo

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { "��ᬮ�� ~䠩��� �ਪ९�����", ;
      "~�����⮢�� � ᮧ����� 䠩��� �ਪ९�����", ;
      "����� ~������ �� �ਪ९�����", ;
      "�������� 䠩�� ~ᢥન � �����", ;
      "~������஢���� ���⪮� ᯨ᪮�", ;
      "~������ WQ2...DBF, ���⠭���� ���⪮�, ��ࠢ��" }
    mas_msg := { "��ᬮ�� 䠩��� �ਪ९����� (� �⢥⮢ �� ���), ������ 䠩��� ��� �����", ;
      "�����⮢�� 䠩��� �ਪ९����� � ᮧ����� �� ��� ��ࠢ�� � �����", ;
      "����� ������ �� �ਪ९����� �� ��樥���, ��� �� �ਪ९�񭭮�� � ��襩 ��", ;
      "�������� 䠩�� ᢥન � ����� �� �ਪ९�񭭮�� ��ᥫ���� (���쬮 � 04-18-20)", ;
      "������஢���� ����� ���⪠ ��� ��࠭���� ᯨ᪠ ��樥�⮢", ;
      "������ DBF-䠩�� �� �����, ���⠭���� ���⪮�, ᮧ����� 䠩�� �ਪ९�����" }
    mas_fun := { "pripisnoe_naselenie(11)", ;
      "pripisnoe_naselenie(12)", ;
      "pripisnoe_naselenie(13)", ;
      "pripisnoe_naselenie(14)", ;
      "pripisnoe_naselenie(15)", ;
      "pripisnoe_naselenie(16)" }
    If T_ROW > 8
      r := T_ROW - Len( mas_pmt ) -3
    Else
      r := T_ROW
    Endif
    popup_prompt( r, T_COL + 5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    view_reestr_pripisnoe_naselenie()
  Case k == 12
    preparation_for_pripisnoe_naselenie()
  Case k == 13
    kartoteka_z_prikreplenie()
  Case k == 14
    If hb_user_curUser:isadmin()
      str_sem := "�������� 䠩�� ᢥન � �����"
      If g_slock( str_sem )
        pripisnoe_naselenie_create_sverka()
        g_sunlock( str_sem )
      Else
        func_error( 4, err_slock() )
      Endif
    Else
      func_error( 4, err_admin() )
    Endif
  Case k == 15
    edit_uchast_spisok()
  Case k == 16 // ������ WQ2...DBF
    mas_pmt := { "~������ WQ2...ZIP", ;
      "~��ᬮ�� ��᫥����� ������஢������ 䠩��", ;
      "������஢���� ~���⪮�", ;
      "~�������� 䠩��� �ਪ९�����" }
    mas_msg := { "������ ������ 䠩�� WQ2...ZIP (��᫥ ��� ����権 � �।��騬 ���⠭��)", ;
      "��ᬮ�� �ਪ९��� � ��襬� �� ��樥�⮢, ��᫠���� � ��᫥���� 䠩��", ;
      "������஢���� ���⪮� ��樥�⠬, ��᫠��� � ��᫥���� 䠩��", ;
      "�������� 䠩�� �ਪ९����� �� ��樥�⮢ ��᫥����� 䠩�� WQ... ��� ��ࠢ��" }
    mas_fun := { "pripisnoe_naselenie(31)", ;
      "pripisnoe_naselenie(32)", ;
      "pripisnoe_naselenie(33)", ;
      "pripisnoe_naselenie(34)" }
    popup_prompt( T_ROW - 3 -Len( mas_pmt ), T_COL + 5, si3, mas_pmt, mas_msg, mas_fun )
  Case k == 21
    spisok_pripisnoe_naselenie( 1 )
  Case k == 22
    spisok_pripisnoe_naselenie( 2 )
  Case k == 23
    spisok_pripisnoe_naselenie( 3 )
  Case k == 31
    wq_import()
  Case k == 32
    wq_view()
  Case k == 33
    wq_edit_uchast()
  Case k == 34
    wq_prikreplenie()
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Elseif Between( k, 21, 29 )
      si2 := j
    Elseif Between( k, 31, 39 )
      si2 := j
    Endif
  Endif

  Return Nil

// 11.03.13
Function view_reestr_pripisnoe_naselenie()
  Local buf := SaveScreen()

  Private goal_dir := dir_server() + dir_XML_MO() + hb_ps()

  g_use( dir_server() + "mo_krtf",, "KRTF" )
  g_use( dir_server() + "mo_krtr",, "KRTR" )
  Index On DToS( dfile ) to ( cur_dir() + "tmp_krtr" ) DESCENDING
  Go Top
  If Eof()
    func_error( 4, "��� ��⠢������ 䠩��� �ਪ९�����" )
  Else
    alpha_browse( T_ROW, 0, 23, 79, "f1_view_r_pr_nas", color0,,,,,,, ;
      "f2_view_r_pr_nas",, { '�', '�', '�', "N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R", .t., 180 } )
  Endif
  Close databases
  RestScreen( buf )

  Return Nil

// 14.07.15
Function f1_view_r_pr_nas( oBrow )
  Local oColumn, ;
    blk := {| _s| _s := goal_dir + AllTrim( krtr->FNAME ), ;
    iif( hb_FileExists( _s + scsv() ) .or. hb_FileExists( _s + szip() ), ;
    iif( Empty( krtr->date_out ), { 3, 4 }, { 1, 2 } ), ;
    { 5, 6 } ) }

  oColumn := TBColumnNew( "��� 䠩��", {|| full_date( krtr->dfile ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "���-��;���-��", {|| Str( krtr->kol, 6 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " ������������ 䠩��", {|| PadR( krtr->FNAME, 20 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "�ਬ�砭��", {|| f11_view_r_pr_nas() } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " �⢥�;����祭", {|| PadC( iif( krtr->ANSWER == 1, "��", "" ), 7 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "�ਪ�;�����", {|| put_val( krtr->kol_p, 6 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " WQ", {|| krtr->wq } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  status_key( "^<Esc>^ - ��室;  ^<F5>^ - ������ ��� �����;  ^<F3>^ - ���ଠ�� � 䠩�� �ਪ९�����" )

  Return Nil

// 03.11.14
Function f11_view_r_pr_nas()
  Local s := ""

  If !( hb_FileExists( goal_dir + AllTrim( krtr->FNAME ) + scsv() ) .or. ;
      hb_FileExists( goal_dir + AllTrim( krtr->FNAME ) + szip() ) )
    krtf->( dbGoto( krtr->kod_f ) )
    If Empty( krtf->TWORK2 )
      s := "�� �������"
    Else
      s := "��� 䠩��"
    Endif
  Elseif Empty( krtr->date_out )
    s := "�� ����ᠭ"
  Else
    s := "���. " + lstr( krtr->NUMB_OUT ) + " ࠧ"
  Endif

  Return PadR( s, 11 )

// 24.03.15
Function f2_view_r_pr_nas( nKey, oBrow )
  Local pss := Space( 10 ), tmp_pss := my_parol()
  Local ret := -1, rec := krtr->( RecNo() ), tmp_color := SetColor(), r, r1, r2, ;
    s, buf := SaveScreen(), arr, i, k, mdate, t_arr[ 2 ], arr_pmt := {}

  krtf->( dbGoto( krtr->kod_f ) )
  Do Case
  Case nKey == K_CTRL_F10 .and. eq_any( krtf->TIP_OUT, _CSV_FILE_REESTR, _CSV_FILE_SVERKAZ ) .and. krtr->ANSWER == 0
    pss := get_parol(,,,,, "N/W", "W/N*" )
    If LastKey() == K_ENTER .and. AScan( tmp_pss, Crypt( pss, gpasskod ) ) > 0 ;
        .and. f_esc_enter( "���㫨஢���� 䠩��", .t. )
      krtf->( dbGoto( krtr->kod_f ) )
      zip_file := AllTrim( krtr->FNAME ) + iif( krtf->TIP_OUT == _CSV_FILE_REESTR, scsv(), szip() )
      str_sem := "f2_view_r_pr_nas_K_CTRL_F12"
      If g_slock( str_sem )
        mywait()
        i := 0
        Use ( dir_server() + "mo_krtp" ) New Alias KRTP
        Index On Str( reestr, 6 ) to ( cur_dir() + "tmp_k" )
        Do While .t.
          @ MaxRow(), 0 Say Str( i / krtr->KOL * 100, 6, 2 ) + "%" Color cColorWait
          find ( Str( krtr->KOD, 6 ) )
          If !Found() ; exit ; Endif
          deleterec( .t. )
          If++i % 5000 == 0
            Commit
          Endif
        Enddo
        Commit
        Pack
        krtp->( dbCloseArea() )
        Select KRTF
        deleterec()
        Select KRTR
        deleterec()
        Delete File ( goal_dir + zip_file )
        g_sunlock( str_sem )
        stat_msg( "���� �ᯥ譮 ���㫨஢��!" ) ; mybell( 2, OK )
        Return 1
      Endif
    Endif
  Case nKey == K_CTRL_F12
    If Empty( krtf->TWORK2 ) // �� ����ᠭ
      zip_file := AllTrim( krtr->FNAME ) + iif( krtf->TIP_OUT == _CSV_FILE_REESTR, scsv(), szip() )
      If krtr->ANSWER > 0
        func_error( 4, "�⢥� ��� ������� 䠩�� 㦥 �� ���⠭ - ���㫨஢���� ����饭�!" )
      Elseif hb_FileExists( goal_dir + zip_file )
        func_error( 4, "����� 䠩� 㦥 ᮧ��� � 楫���� ��⠫��� - ���㫨஢���� ����饭�!" )
      Elseif f_esc_enter( "���㫨஢���� 䠩��", .t. )
        str_sem := "f2_view_r_pr_nas_K_CTRL_F12"
        If g_slock( str_sem )
          mywait()
          i := 0
          Use ( dir_server() + "mo_krtp" ) New Alias KRTP
          Index On Str( reestr, 6 ) to ( cur_dir() + "tmp_k" )
          Do While .t.
            @ MaxRow(), 0 Say Str( i / krtr->KOL * 100, 6, 2 ) + "%" Color cColorWait
            find ( Str( krtr->KOD, 6 ) )
            If !Found() ; exit ; Endif
            deleterec( .t. )
            If++i % 5000 == 0
              Commit
            Endif
          Enddo
          Commit
          Pack
          krtp->( dbCloseArea() )
          Select KRTF
          deleterec()
          Select KRTR
          deleterec()
          Delete File ( goal_dir + zip_file )
          g_sunlock( str_sem )
          stat_msg( "���� �ᯥ譮 ���㫨஢��!" ) ; mybell( 2, OK )
          Return 1
        Endif
      Endif
    Else
      func_error( 4, "����� 䠩� ���㫨஢��� ����饭�!" )
    Endif
  Case nKey == K_F5
    If f_esc_enter( "����� 䠩�� �� " + date_8( krtr->dfile ) )
      Private p_var_manager := "copy_schet"
      s := manager( T_ROW, T_COL + 5, MaxRow() -2,, .t., 2, .f.,,, ) // "norton" ��� �롮� ��⠫���
      If !Empty( s )
        If Upper( s ) == Upper( goal_dir )
          func_error( 4, "�� ��ࠫ� ��⠫��, � ���஬ 㦥 ����ᠭ ����� 䠩�! �� �������⨬�." )
        Else
          zip_file := AllTrim( krtr->FNAME ) + iif( Left( krtr->FNAME, 2 ) == "MO", scsv(), szip() )
          If hb_FileExists( goal_dir + zip_file )
            mywait( '����஢���� "' + zip_file + '" � ��⠫�� "' + s + '"' )
            // copy file (goal_dir+zip_file) to (hb_OemToAnsi(s)+zip_file)
            Copy File ( goal_dir + zip_file ) to ( s + zip_file )
            // if hb_fileExists(hb_OemToAnsi(s)+zip_file)
            If hb_FileExists( s + zip_file )
              krtr->( g_rlock( forever ) )
              krtr->DATE_OUT := sys_date
              If krtr->NUMB_OUT < 99
                krtr->NUMB_OUT++
              Endif
              //
              krtf->( dbGoto( krtr->kod_f ) )
              krtf->( g_rlock( forever ) )
              krtf->DREAD := sys_date
              krtf->TREAD := hour_min( Seconds() )
            Else
              func_error( 4, "�訡�� ����� 䠩�� " + s + zip_file )
            Endif
          Else
            func_error( 4, "�� �����㦥� 䠩� " + goal_dir + zip_file )
          Endif
          Unlock
          Commit
          stat_msg( "������ �����襭�!" ) ; mybell( 2, OK )
        Endif
      Endif
    Endif
    Select KRTR
    ret := 0
  Case nKey == K_F3
    f3_view_r_pr_nas( oBrow )
    ret := 0
  Endcase
  SetColor( tmp_color )
  RestScreen( buf )

  Return ret

// 30.03.23
Function f3_view_r_pr_nas( oBrow )
  Static si := 1, snfile := '', sarr_mo, sarr_err, sjmo, sjerr
  Local i, j, r := Row(), r1, r2, buf := save_maxrow(), fl := .f., ii, ;
    mm_func := { -1 }, mm_menu

  Private fl_csv := .f., mm_err := {}

  If krtf->TIP_OUT == _CSV_FILE_SVERKAZ
    mm_err := { { '�� ����� ⥪�饣� ���客����', 708 }, ; // !!!
    { '�ਪ९����� � �� ���������', 709 }, ; //
    { '����� �� ���� ������� ���ଠ樨', -99 } } // !!!
  Endif
  If Left( krtr->FNAME, 2 ) == "MO"
    fl_csv := .t.
    mm_menu := { "~���᮪ ��樥�⮢ � 䠩�� �ਪ९�����" }
    If krtr->ANSWER == 1
      AAdd( mm_func, -2 ) ; AAdd( mm_menu, "���᮪ ~�ਪ९���� ��樥�⮢" )
      AAdd( mm_func, -3 ) ; AAdd( mm_menu, "���᮪ ~�� �ਪ९���� ��樥�⮢" )
    Endif
  Else
    mm_menu := { "~���᮪ ��樥�⮢ � 䠩�� ᢥન" }
    If !( snfile == AllTrim( krtr->FNAME ) )
      fl := .t.
      snfile := AllTrim( krtr->FNAME )
      sarr_mo := {} ; sjmo := 1
      sarr_err := {} ; sjerr := 1
    Endif
  Endif
  mywait()
  Select KRTF
  Index On FNAME to ( cur_dir() + "tmp_krtf" ) For reestr == krtr->kod .and. Empty( TIP_OUT )
  Go Top
  Do While !Eof()
    AAdd( mm_func, krtf->kod )
    AAdd( mm_menu, "��⮪�� ~�⥭�� " + RTrim( krtf->FNAME ) + iif( Empty( krtf->TWORK2 ), "-������ �� ���������", "" ) )
    Skip
  Enddo
  Select KRTF
  Set Index To
  If !fl_csv .and. krtr->ANSWER == 1
    AAdd( mm_func, -2 ) ; AAdd( mm_menu, "���᮪ ��樥�⮢, �ਪ९���� � ~��襩 ��" )
    AAdd( mm_func, -4 ) ; AAdd( mm_menu, "���᮪ ��樥�⮢, �ਪ९���� � ~��㣨� ��" )
    AAdd( mm_func, -3 ) ; AAdd( mm_menu, "���᮪ �������� �� ����� � ����� ~�訡��" )
    If fl
      ii := 0
      r_use( dir_server() + "mo_krte",, "KRTE" )
      Index On Str( rees_zap, 6 ) to ( cur_dir() + "tmp_krte" ) For reestr == krtr->kod
      r_use( dir_server() + "mo_kartp", dir_server() + "mo_kartp", "KARTP" )
      r_use( dir_server() + "mo_krtp",, "KRTP" )
      Index On Str( rees_zap, 6 ) to ( cur_dir() + "tmp_krtp" ) For reestr == krtr->kod
      Go Top
      Do While !Eof()
        @ MaxRow(), 0 Say Str( ++ii / krtr->kol * 100, 6, 2 ) + "%" Color cColorWait
        If Empty( md_prik := krtp->D_PRIK1 )
          If Empty( md_prik := krtp->D_PRIK )
            md_prik := krtr->DFILE // ��� ᮢ���⨬��� � ��ன ���ᨥ�
          Endif
        Endif
        Select KRTE
        find ( Str( krtp->REES_ZAP, 6 ) )
        Do While krtp->REES_ZAP == krte->REES_ZAP .and. !Eof()
          If AScan( sarr_err, krte->REFREASON ) == 0
            AAdd( sarr_err, krte->REFREASON )
          Endif
          Skip
        Enddo
        If krtp->OPLATA == 3
          Select KARTP
          find ( Str( krtp->KOD_K, 7 ) + DToS( md_prik ) )
          If Found() .and. AScan( sarr_mo, kartp->MO_PR ) == 0
            AAdd( sarr_mo, kartp->MO_PR )
          Endif
        Endif
        Select KRTP
        Skip
      Enddo
      krte->( dbCloseArea() )
      kartp->( dbCloseArea() )
      krtp->( dbCloseArea() )
      ASort( sarr_err )
      For j := 1 To Len( sarr_err )
        If AScan( mm_err, {| x| x[ 2 ] == sarr_err[ j ] } ) > 0
          sarr_err[ j ] := Str( sarr_err[ j ], 3 ) + " " + inieditspr( A__MENUVERT, mm_err, sarr_err[ j ] )
        Else
          sarr_err[ j ] := Str( sarr_err[ j ], 3 ) + ' ' + inieditspr( A__MENUVERT, get_err_csv_prik(), sarr_err[ j ] )
        Endif
      Next
      ASort( sarr_mo )
      For j := 1 To Len( sarr_mo )
        sarr_mo[ j ] += " " + ret_mo( sarr_mo[ j ] )[ _MO_SHORT_NAME ]
      Next
    Endif
  Endif
  If r <= 12
    r1 := r + 1 ; r2 := r1 + Len( mm_menu ) + 1
  Else
    r2 := r - 1 ; r1 := r2 - Len( mm_menu ) -1
  Endif
  rest_box( buf )
  If Len( mm_menu ) == 1
    i := 1
  Else
    i := popup_prompt( r1, 10, si, mm_menu,,, color5 )
  Endif
  If i > 0
    si := i
    If mm_func[ i ] < 0
      If !fl_csv .and. mm_func[ i ] == -4
        If !Empty( sarr_mo )
          If r <= 12
            r1 := r + 1 ; r2 := r1 + Len( sarr_mo ) + 1
            If r2 > MaxRow() -2
              r2 := MaxRow() -2
            Endif
          Else
            r2 := r - 1 ; r1 := r2 - Len( sarr_mo ) -1
            If r1 < 2
              r1 := 2
            Endif
          Endif
          Do While ( j := popup_scr( r1, 10, r2, 77, sarr_mo, sjmo, color5, .t.,,, ;
              '�롥��, � ������ �� �ਪ९�� ��樥��', "B/W" ) ) > 0
            sjmo := j
            f31_view_r_pr_nas( Abs( mm_func[ i ] ), mm_menu[ i ], sarr_mo[ j ] )
          Enddo
        Endif
      Elseif !fl_csv .and. mm_func[ i ] == -3
        If !Empty( sarr_err )
          If r <= 12
            r1 := r + 1 ; r2 := r1 + Len( sarr_err ) + 1
            If r2 > MaxRow() -2
              r2 := MaxRow() -2
            Endif
          Else
            r2 := r - 1 ; r1 := r2 - Len( sarr_err ) -1
            If r1 < 2
              r1 := 2
            Endif
          Endif
          Do While ( j := popup_scr( r1, 10, r2, 77, sarr_err, sjerr, color5, .t.,,, ;
              '�롥�� ��� �訡�� ������ �� �����', "B/W" ) ) > 0
            sjerr := j
            f31_view_r_pr_nas( Abs( mm_func[ i ] ), mm_menu[ i ], sarr_err[ j ] )
          Enddo
        Endif
      Else
        f31_view_r_pr_nas( Abs( mm_func[ i ] ), mm_menu[ i ] )
      Endif
    Else
      krtf->( dbGoto( mm_func[ i ] ) )
      viewtext( devide_into_pages( dir_server() + dir_XML_TF() + hb_ps() + AllTrim( krtf->FNAME ) + stxt(), 60, 80 ),,,, .t.,,, 2 )
    Endif
  Endif
  Select KRTR

  Return Nil

// 04.11.14
Function f31_view_r_pr_nas( reg, s, s1 )
  Local fl := .t., buf := save_maxrow(), n_file := cur_dir() + "prikspis.txt", lmo, lerr, ;
    i, j, k, ii, ar[ 2 ]

  mywait()
  fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  add_string( Center( CharRem( "~", s ), 80 ) )
  If fl_csv
    add_string( Center( "( 䠩� �ਪ९����� �� " + full_date( krtr->dfile ) + " )", 80 ) )
  Else
    Default s1 To ""
    s1 := AllTrim( s1 )
    add_string( Center( "( 䠩� ᢥન �� " + full_date( krtr->dfile ) + " )", 80 ) )
    If reg == 4
      lmo := Left( s1, 6 )
      add_string( Center( CharOne( '"', '���᮪ �ਪ९���� � "' + s1 + '"' ), 80 ) )
    Elseif reg == 3
      lerr := Int( Val( s1 ) )
      For i := 1 To perenos( ar, '���᮪ �������� �� ����� � �訡��� "' + s1 + '"', 80 )
        add_string( Center( AllTrim( ar[ i ] ), 80 ) )
      Next
    Endif
  Endif
  add_string( "" )
  r_use( dir_server() + "mo_krte",, "KRTE" )
  If reg == 3 .or. !fl_csv
    Index On Str( rees_zap, 6 ) to ( cur_dir() + "tmp_krte" ) For reestr == krtr->kod
  Endif
  // ᯨ᮪ �ਪ९����� �� ��樥��� �� �६���
  r_use( dir_server() + "mo_kartp", dir_server() + "mo_kartp", "KARTP" )
  r_use( dir_server() + "kartote2",, "KART2" )
  r_use( dir_server() + "kartotek",, "KART" )
  Set Relation To RecNo() into KART2
  r_use( dir_server() + "mo_krtp",, "KRTP" )
  Set Relation To kod_k into KART
  Index On Str( rees_zap, 6 ) to ( cur_dir() + "tmp_krtp" ) For reestr == krtr->kod
  ii := k := 0
  Go Top
  Do While !Eof()
    @ MaxRow(), 0 Say Str( ++ii / krtr->kol * 100, 6, 2 ) + "%" Color cColorWait
    If Empty( md_prik := krtp->D_PRIK1 )
      If Empty( md_prik := krtp->D_PRIK )
        md_prik := krtr->DFILE // ��� ᮢ���⨬��� � ��ன ���ᨥ�
      Endif
    Endif
    fl := .f.
    Do Case
    Case reg == 1
      fl := .t.
    Case reg == 2
      fl := ( krtp->OPLATA == 1 )
    Case reg == 3 .and. fl_csv
      fl := ( krtp->OPLATA == 2 )
    Case reg == 3 .and. !fl_csv
      Select KRTE
      find ( Str( krtp->REES_ZAP, 6 ) )
      Do While krtp->REES_ZAP == krte->REES_ZAP .and. !Eof()
        If lerr == krte->REFREASON
          fl := .t. ; Exit
        Endif
        Skip
      Enddo
    Case reg == 4
      If krtp->OPLATA == 3
        Select KARTP
        find ( Str( krtp->KOD_K, 7 ) + DToS( md_prik ) )
        fl := Found() .and. lmo == kartp->MO_PR
      Endif
    Endcase
    If fl
      ++k
      s := lstr( krtp->REES_ZAP ) + ". " + AllTrim( kart->fio ) + ;
        " (�.�." + full_date( kart->date_r ) + ") "
      If reg == 1
        If fl_csv
          s += "����� �� �ਪ९����� � " + date_8( md_prik )
        Endif
      Elseif krtp->OPLATA == 2 .and. !Empty( kart2->MO_PR )
        If kart2->MO_PR == glob_mo[ _MO_KOD_TFOMS ]
          s += '࠭�� �ਪ९�� � ��襩 ��'
        Else
          s += '࠭�� �ਪ९�� � ' + ret_mo( kart2->MO_PR )[ _MO_SHORT_NAME ]
        Endif
      Elseif eq_any( krtp->OPLATA, 1, 3 ) // reg == 2
        s += "��������" + iif( kart->pol == "�", "��", "���" ) + " � " + date_8( md_prik )
      Endif
      verify_ff( 60, .t., 80 )
      add_string( s )
      If reg == 3 .and. fl_csv
        Select KRTE
        find ( Str( krtp->REES_ZAP, 6 ) )
        Do While krtp->REES_ZAP == krte->REES_ZAP .and. !Eof()
          s := Space( Len( lstr( krtp->REES_ZAP ) ) + 2 ) + lstr( krte->REFREASON ) + ' ' + ;
            inieditspr( A__MENUVERT, get_err_csv_prik(), krte->REFREASON )
          verify_ff( 60, .t., 80 )
          add_string( s )
          Skip
        Enddo
      Endif
    Endif
    Select KRTP
    Skip
  Enddo
  If reg == 3 .and. !fl_csv
    add_string( "=== �⮣� ��樥�⮢ - " + lstr( k ) + " 祫." )
  Endif
  krte->( dbCloseArea() )
  kartp->( dbCloseArea() )
  kart2->( dbCloseArea() )
  kart->( dbCloseArea() )
  krtp->( dbCloseArea() )
  FClose( fp )
  rest_box( buf )
  viewtext( n_file,,,, .t.,,, 2 )

  Return Nil

// 25.10.25
Function preparation_for_pripisnoe_naselenie()
  Local i, j, k, aerr, buf := SaveScreen(), blk, t_arr[ BR_LEN ], cur_year, t_polis, ;
    str_sem := "preparation_for_pripisnoe_naselenie"

  mywait()
  g_use( dir_server() + "mo_krtp",, "KRTP" )
  Index On kod_k to ( cur_dir() + "tmp_k" ) For reestr == 0
  dbCreate( cur_dir() + "tmp_krtp", { ;
    { "rec",   "N", 8, 0 }, ; // ����� ����� � 䠩�� "mo_krtp"
  { "uchast", "N", 2, 0 }, ; // ���⮪
  { "D_PRIK", "D", 8, 0 }, ; // ��� �ਪ९�����
  { "S_PRIK", "N", 1, 0 }, ; // ᯮᮡ �ਪ९�����: 1-�� ����� ॣ����樨, 2-�� ��筮�� ������, 3-
  { "KOD_K", "N", 7, 0 };  // ��� ��樥�� �� 䠩�� "kartotek"
  } )
  Use ( cur_dir() + "tmp_krtp" ) new
  use_base( "kartotek" )
  Set Order To 0
  Select KRTP
  Go Top
  Do While !Eof()
    If Empty( krtp->d_prik )
      g_rlock( forever )
      krtp->d_prik := sys_date
      Unlock
    Endif
    kart->( dbGoto( krtp->kod_k ) )
    Select TMP_KRTP
    Append Blank
    tmp_krtp->rec := krtp->( RecNo() )
    tmp_krtp->kod_k := krtp->kod_k
    tmp_krtp->uchast := kart->uchast
    tmp_krtp->s_prik := krtp->s_prik
    tmp_krtp->d_prik := krtp->d_prik
    Select KRTP
    Skip
  Enddo
  Commit
  Select KRTP
  Index On Str( reestr, 6 ) to ( cur_dir() + "tmp_k" )
  Select TMP_KRTP
  Set Relation To kod_k into KART
  Index On Str( kod_k, 7 ) to ( cur_dir() + "tmp_krtp" )
  Index On Upper( kart->fio ) + DToS( kart->date_r ) + Str( kod_k, 7 ) to ( cur_dir() + "tmp2krtp" )
  Set Index to ( cur_dir() + "tmp2krtp" ), ( cur_dir() + "tmp_krtp" )
  Go Top
  RestScreen( buf )
  If LastRec() == 0 .and. ;
      f_alert( { "� ����� ������ �� �⬥祭� �� ������ ��樥��", ;
      "��� �ਪ९�����", "" }, ;
      { " �⪠� ", " ����� �����⮢�� 䠩�� �ਪ९����� " }, ;
      1, "N+/G*", "N/G*", MaxRow() -8,, "N/G*" ) != 2
    Close databases
    Return Nil
  Endif
  If !g_slock( str_sem )
    Close databases
    Return func_error( 4, "� ����� ������ � �⨬ ०���� ࠡ�⠥� ��㣮� ���짮��⥫�." )
  Endif
  Private tr := T_ROW
  box_shadow( tr - 4, 47, tr - 2, 77, "B/W*" )
  t_arr[ BR_TOP ] := tr
  t_arr[ BR_BOTTOM ] := MaxRow() -1
  t_arr[ BR_LEFT ] := 0
  t_arr[ BR_RIGHT ] := 79
  t_arr[ BR_COLOR ] := color5
  t_arr[ BR_TITUL ] := "�����⮢�� 䠩�� �ਪ९�����"
  t_arr[ BR_TITUL_COLOR ] := "B/W"
  t_arr[ BR_ARR_BROWSE ] := { "�", "�", "�", "N/W,W+/N,B/W,W+/B,RB/W,W+/RB", .t., 72 }
  blk := {|| iif( kart->uchast > 0, iif( tmp_krtp->s_prik == 2, { 1, 2 }, { 3, 4 } ), { 5, 6 } ) }
  Private arr_prik := { { "�� ����� ॣ����樨", 1 }, ;
    { "���/�-� ��� ���. �/�", 2 }, ;
    { "���/�-� � �����. �/�", 3 } }
  Private arr_prik1 := { { "�� ��筮�� ������ (��� ��������� ���� ��⥫��⢠)", 2 }, ;
    { "�� ��筮�� ������ (� �裡 � ���������� ���� ��⥫��⢠)", 3 } }
  t_arr[ BR_COLUMN ] := { { Center( "�.�.�.", 32 ), {|| Left( kart->fio, 32 ) }, blk }, ;
    { "   ���; ஦�����", {|| full_date( kart->date_r ) }, blk }, ;
    { "��", {|| Str( kart->uchast ) }, blk }, ;
    { "   ���; ������", {|| full_date( tmp_krtp->d_prik ) }, blk }, ;
    { "���ᮡ �ਪ९�����", {|| PadR( inieditspr( A__MENUVERT, arr_prik, tmp_krtp->s_prik ), 20 ) }, blk } }
  t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ ��室 ^<Enter>^ ।-��� ���� � ᯮᮡ�/��ᬮ�� ^<Ins>^ �������� ^<Del>^ 㤠����" ) }
  t_arr[ BR_STEP_FUNC ] := {|| f3_p_f_prikreplenie() }
  t_arr[ BR_EDIT ] := {| nk, ob| f1_p_f_prikreplenie( nk, ob, "edit" ) }
  If LastRec() == 0
    Keyboard Chr( K_INS )
  Endif
  edit_browse( t_arr )
  RestScreen( buf )
  If tmp_krtp->( LastRec() ) > 0
    mywait()
    cur_year := Year( sys_date )
    r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
    Go Bottom
    If !Empty( human->k_data )
      cur_year := Year( human->k_data )
    Endif
    Use
    cFileProtokol := cur_dir() + "prot.txt"
    StrFile( Space( 10 ) + "���᮪ �訡��" + hb_eol() + hb_eol(), cFileProtokol )
    ii := i := 0
    r_use( dir_server() + "mo_otd",, "OTD" )
    r_use( dir_server() + "mo_pers",, "P2" )
    r_use( dir_server() + "mo_uchvr",, "UV" )
    Index On Str( uch, 2 ) to ( cur_dir() + "tmp_uv" )
    Select TMP_KRTP
    Go Top
    Do While !Eof()
      ++ii

      aerr := {}
      if ii > 24999  // ��࠭�祭�� !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        AAdd( aerr, '�ॢ�襭� ���-�� ��樥�⮢ � �����. ����� 25 000. ����� ᮧ���� ᫥���騩 �����' )
      endif  
      If Empty( kart->date_r )
        AAdd( aerr, '�� ��������� ���� "��� ஦�����"' )
      Elseif kart->date_r >= sys_date
        AAdd( aerr, '��� ஦����� ����� ᥣ����譥� ����' )
      Elseif Year( kart->date_r ) < 1900
        AAdd( aerr, "��� ஦�����: " + full_date( kart->date_r ) + " ( < 1900�.)" )
      Endif
      if len(AllTrim( kart2->KOD_MIS )) != 16 .or. len(AllTrim( kart_->NPOLIS  )) != 16 
        AAdd( aerr, '�� ���� ����� ���' )
      endif  
      If kart2->MO_PR == glob_mo[ _MO_KOD_TFOMS ]
        AAdd( aerr, '����� ��樥�� 㦥 �ਪ९�� � ��襩 �� � ' + ;
          iif( Empty( kart2->pc4 ), full_date( kart2->DATE_PR ), AllTrim( kart2->pc4 ) ) + "�." )
      Endif
      If Empty( tmp_krtp->uchast )
        AAdd( aerr, '�� ��������� ���� "����� ���⪠"' )
      Else
        Select UV
        find ( Str( tmp_krtp->uchast, 2 ) )
        If Found() .and. !emptyall( uv->vrach, uv->vrachv, uv->vrachd )
          If count_years( kart->date_r, sys_date ) < 18 // ���
            If emptyall( uv->vrach, uv->vrachd )
              AAdd( aerr, "�� ���⪥ " + lstr( kart->uchast ) + " �� �ਢ易� ���⪮�� ��� � ����" )
            Else
              If !Empty( uv->vrach )
                p2->( dbGoto( uv->vrach ) )
              Else
                p2->( dbGoto( uv->vrachd ) )
              Endif
              f1_p_f_pripisnoe_naselenie( aerr )
            Endif
          Else
            If emptyall( uv->vrach, uv->vrachv )
              AAdd( aerr, "�� ���⪥ " + lstr( kart->uchast ) + " �� �ਢ易� ���⪮�� ��� � �����" )
            Else
              If !Empty( uv->vrach )
                p2->( dbGoto( uv->vrach ) )
              Else
                p2->( dbGoto( uv->vrachv ) )
              Endif
              f1_p_f_pripisnoe_naselenie( aerr )
            Endif
          Endif
        Else
          AAdd( aerr, "� ����� " + lstr( kart->uchast ) + " �� �ਢ易� ���⪮�� ���" )
        Endif
      Endif
      valid_sn_polis( kart_->vpolis, kart_->SPOLIS, kart_->NPOLIS, aerr, Between( kart_->smo, '34001', '34007' ) )
      If AScan( getvidud(), {| x| x[ 2 ] == kart_->vid_ud } ) == 0
        AAdd( aerr, '�� ��������� ���� "��� 㤮�⮢�७�� ��筮��"' )
      Else
        If Empty( kart_->nom_ud )
          AAdd( aerr, '������ ���� ��������� ���� "����� 㤮�⮢�७�� ��筮��"' )
        Elseif !ver_number( kart_->nom_ud )
          AAdd( aerr, '���� "����� 㤮�⮢�७�� ��筮��" ������ ���� ��஢�' )
        Endif
        If !Empty( kart_->nom_ud )
          s := Space( 80 )
          If !val_ud_nom( 2, kart_->vid_ud, kart_->nom_ud, @s )
            AAdd( aerr, s )
          Endif
        Endif
        If eq_any( kart_->vid_ud, 1, 3, 14 ) .and. Empty( kart_->ser_ud )
          AAdd( aerr, '�� ��������� ���� "����� 㤮�⮢�७�� ��筮��"' )
        Endif
        If eq_any( kart_->vid_ud, 3, 14 ) .and. Empty( del_spec_symbol( kart_->mesto_r ) )
          AAdd( aerr, iif( kart_->vid_ud == 3, '��� ᢨ�-�� � ஦�����', '��� ��ᯮ�� ��' ) + ;
            ' ��易⥫쭮 ���������� ���� "���� ஦�����"' )
        Endif
        If !Empty( kart_->ser_ud )
          s := Space( 80 )
          If !val_ud_ser( 2, kart_->vid_ud, kart_->ser_ud, @s )
            AAdd( aerr, s )
          Endif
        Endif
      Endif
      If !Empty( kart_->kogdavyd ) .and. kart_->kogdavyd < kart->date_r
        AAdd( aerr, '��� �뤠� ���㬥��, 㤮�⮢����饣� ��筮���, ����� ���� ஦�����' )
      Endif
      val_fio( retfamimot( 1, .f. ), aerr )
      If !Empty( kart->snils )
        s := Space( 80 )
        If !val_snils( kart->snils, 2, @s )
          AAdd( aerr, s )
        Endif
      Endif
      Select KRTP
      Goto ( tmp_krtp->rec )
      If !eq_any( krtp->S_PRIK, 1, 2, 3 )
        AAdd( aerr, '������ ᯮᮡ �ਪ९�����' )
      Endif
      If Empty( krtp->D_PRIK )
        AAdd( aerr, '�� ��������� ���� "��� ������"' )
      Elseif krtp->D_PRIK > sys_date
        AAdd( aerr, '��� ������ ����� ᥣ����譥� ����' )
      Elseif Year( krtp->D_PRIK ) < cur_year
        AAdd( aerr, "��� ������: " + full_date( krtp->D_PRIK ) + " - ���� ���" )
      Endif
      If !Empty( aerr )
        StrFile( lstr( ++i ) + ". " + AllTrim( kart->fio ) + " " + full_date( kart->date_r ) + hb_eol(), cFileProtokol, .t. )
        AEval( aerr, {| x| StrFile( " - " + x + hb_eol(), cFileProtokol, .t. ) } )
      Endif
      Select TMP_KRTP
      Skip
    Enddo
    j := tmp_krtp->( LastRec() )
    Close databases
    RestScreen( buf )
    k := 1
    If i > 0
      viewtext( devide_into_pages( cFileProtokol, 60, 80 ),,,, .t.,,, 2 )
    Else
      k := f_alert( { "� ����� ������ �⬥祭� " + lstr( ii ) + " ��樥�⮢ ��� �ਪ९�����", ;
        "" }, ;
        { " �⪠� ", " ������� 䠩� �ਪ९����� " }, ;
        1, "N+/GR*", "N/GR*", MaxRow() -7,, "N/GR*" )
    Endif
    j := 0
    If k == 2
      k := f_alert( { PadC( "�롥��, ����� ��ࠧ�� ᮧ������ 䠩� �ਪ९�����", 70, "." ), ;
        "" }, ;
        { " ���쪮 �� ������ ", " ������� ��樥�⮢ � ���������� � ���⪠ " }, ;
        1, "N+/G*", "N/G*", MaxRow() -7,, "N/G*" )
      If k == 1
        k := 2
      Elseif k == 2
        If ( k := find_change_snils( @j ) ) == 3
          k := f_alert( { PadC( "�롥��, ����� ��ࠧ�� ᮧ������ 䠩� �ਪ९�����", 70, "." ), ;
            "" }, ;
            { " ���쪮 �� ������ ", " ������� " + lstr( j ) + " ��樥�⮢ � ���������� ��-�� " }, ;
            1, "N+/G*", "N/G*", MaxRow() -7,, "N/G*" )
          If k == 1
            k := 2 ; j := 0
          Elseif k == 2
            k := 3
          Endif
        Endif
      Endif
    Endif
    If k > 1
      s := "MO2"
      g_use( dir_server() + "mo_krtr",, "KRTR" )
      Locate For DFILE == sys_date .and. Left( FNAME, 3 ) == s
      If Found()
        func_error( 4, "���� �ਪ९����� � ��⮩ " + full_date( sys_date ) + "�. 㦥 �� ᮧ���" )
      Elseif f_esc_enter( "ᮧ����� 䠩�� �ਪ९�����", .t. )
        mywait()
        s += glob_mo[ _MO_KOD_TFOMS ] + DToS( sys_date )
        n_file := s + scsv()
        r_use( dir_exe() + "_mo_podr", cur_dir() + "_mo_podr", "PODR" )
        find ( glob_mo[ _MO_KOD_TFOMS ] )
        loidmo := AllTrim( podr->oidmo )
        Select KRTR
        Index On Str( kod, 6 ) to ( cur_dir() + "tmp_krtr" )
        addrec( 6 )
        krtr->KOD := RecNo()
        krtr->FNAME := s
        krtr->DFILE := sys_date
        krtr->DATE_OUT := CToD( "" )
        krtr->NUMB_OUT := 0
        krtr->KOL := ii + j
        krtr->KOL_P := 0
        krtr->ANSWER := 0  // 0-�� �뫮 �⢥�, 1-�� ���⠭ �⢥�
        g_use( dir_server() + "mo_krtf",, "KRTF" )
        Index On Str( kod, 6 ) to ( cur_dir() + "tmp_krtf" )
        addrec( 6 )
        krtf->KOD   := RecNo()
        krtf->FNAME := krtr->FNAME
        krtf->DFILE := krtr->DFILE
        krtf->TFILE := hour_min( Seconds() )
        krtf->TIP_IN := 0
        krtf->TIP_OUT := _CSV_FILE_REESTR
        krtf->REESTR := krtr->KOD
        krtf->DWORK := sys_date
        krtf->TWORK1 := hour_min( Seconds() ) // �६� ��砫� ��ࠡ�⪨
        krtf->TWORK2 := ""                  // �६� ����砭�� ��ࠡ�⪨
        //
        krtr->KOD_F := krtf->KOD
        Unlock
        Commit
        //
        blk := {| _s| iif( Empty( _s ), '', '"' + _s + '"' ) }
        Delete File ( n_file )
        fp := FCreate( n_file )
        //
        r_use( dir_server() + "mo_otd",, "OTD" )
        r_use( dir_server() + "mo_pers",, "P2" )
        r_use( dir_server() + "mo_uchvr",, "UV" )
        Index On Str( uch, 2 ) to ( cur_dir() + "tmp_uv" )
        g_use( dir_server() + "mo_krtp",, "KRTP" )
        use_base( "kartotek" )
        Set Order To 0
        Use ( cur_dir() + "tmp_krtp" ) new
        Set Relation To kod_k into KART
        Index On Upper( kart->fio ) + DToS( kart->date_r ) + Str( kod_k, 7 ) to ( cur_dir() + "tmp2krtp" )
        i := 0
        Go Top
        Do While !Eof()
          ++i
          @ MaxRow(), 0 Say Str( i / ( ii + j ) * 100, 6, 2 ) + "%" Color cColorWait
          If !Empty( tmp_krtp->uchast )
            Select UV
            find ( Str( tmp_krtp->uchast, 2 ) )
            If Found()
              If count_years( kart->date_r, sys_date ) < 18 // ���
                If !Empty( uv->vrach )
                  p2->( dbGoto( uv->vrach ) )
                Else
                  p2->( dbGoto( uv->vrachd ) )
                Endif
              Else
                If !Empty( uv->vrach )
                  p2->( dbGoto( uv->vrach ) )
                Else
                  p2->( dbGoto( uv->vrachv ) )
                Endif
              Endif
            Endif
            Select OTD
            Goto ( p2->otd )
          Endif
          Select KRTP
          Goto ( tmp_krtp->rec )
          g_rlock( forever )
          krtp->REESTR   := krtr->KOD
          krtp->REES_ZAP := i
          krtp->OPLATA   := 0
          krtp->UCHAST   := tmp_krtp->uchast     // ����� ���⪠
          krtp->SNILS_VR := p2->snils      // ����� ���⪮���� ���
          krtp->KOD_PODR := AllTrim( otd->kod_podr ) // ��� ���ࠧ������� �� ��ᯮ��� ���
          krtp->D_PRIK1  := CToD( "" )       // ��� �ਪ९�����
          Unlock
          //
          s1 := iif( i == 1, "", hb_eol() )
          // 1 - ����� ����� � 䠩�� � 10.06.19�.
          s1 += Eval( blk, lstr( i ) ) + ";"
          // 2 - ����⢨�
          s := "�"
          s1 += Eval( blk, s ) + ";"
          // 3 - ��� ⨯� ����
          s := iif( kart_->vpolis == 3, "�", iif( kart_->vpolis == 2, "�", "�" ) )
          // � - �㬠��� ����� ��� ������� ��ࠧ� � - �����஭�� ����� ��� ������� ��ࠧ�
          // � ? �६����� ᢨ��⥫��⢮ � ? ����� ��ண� ��ࠧ� � ? � ��⠢� ���
          s1 += Eval( blk, s ) + ";"
          // 4 - c��� � ����� ����
          if len(AllTrim( kart2->KOD_MIS )) == 16
            t_polis := alltrim(kart2->KOD_MIS)
          else
            t_polis :=  alltrim(kart_->NPOLIS)
          endif    
          s := t_polis
          //s := iif( kart_->vpolis == 3, "", ;
          //  iif( kart_->vpolis == 2, AllTrim( kart_->NPOLIS ), ;
          //  AllTrim( kart_->SPOLIS ) + " � " + AllTrim( kart_->NPOLIS ) ) )
          s1 += Eval( blk, f_s_csv( s ) ) + ";"
          // 5 - ����� ����� ����� ���
          s := iif( kart_->vpolis == 3, AllTrim( kart_->NPOLIS ), "" )
          s1 += Eval( blk, s ) + ";"
          arr_fio := retfamimot( 1, .f. )
          // 6 - ������� �����客������ ���
          s1 += Eval( blk, f_s_csv( arr_fio[ 1 ] ) ) + ";"
          // 7 - ��� �����客������ ���
          s1 += Eval( blk, f_s_csv( arr_fio[ 2 ] ) ) + ";"
          // 8 - � - ����⢮ �����客������ ���
          s1 += Eval( blk, f_s_csv( arr_fio[ 3 ] ) ) + ";"
          // 9 - �� - ��� ஦����� �����客������ ���
          s1 += Eval( blk, DToS( kart->date_r ) ) + ";"
          // 10 - ���- ���� ஦����� �����客������ ���
          s := iif( eq_any( kart_->vid_ud, 3, 14 ), AllTrim( del_spec_symbol( kart_->mesto_r ) ), "" )
          s1 += Eval( blk, f_s_csv( s ) ) + ";"
          // 11 - � - ��� ���㬥��, 㤮�⮢����饣� ��筮���
          s1 += Eval( blk, lstr( kart_->vid_ud ) ) + ";"
          // 12 - � - ����� ��� ��� � ����� ���㬥��, 㤮�⮢����饣� ��筮���.
          s := AllTrim( kart_->ser_ud ) + " � " + AllTrim( kart_->nom_ud )
          s1 += Eval( blk, f_s_csv( s ) ) + ";"
          // 13 - � - ��� �뤠� ���㬥��, 㤮�⮢����饣� ��筮���
          s := iif( Empty( kart_->kogdavyd ), "", DToS( kart_->kogdavyd ) )
          s1 += Eval( blk, s ) + ";"
          // 14 - � - ������������ �࣠��, �뤠�襣� ���㬥��
          s := AllTrim( inieditspr( A__POPUPMENU, dir_server() + "s_kemvyd", kart_->kemvyd ) )
          s1 += Eval( blk, f_s_csv( s ) ) + ";"
          // 15 - � - ����� �����客������ ���
          s1 += Eval( blk, AllTrim( kart->snils ) ) + ";"
          // 16 - �� - �����䨪��� ��
          s1 += Eval( blk, glob_mo[ _MO_KOD_TFOMS ] ) + ";"
          // 17 - �� - ���ᮡ �ਪ९�����
          s1 += Eval( blk, lstr( krtp->S_PRIK ) ) + ";"
          // 18 - ��� -��� �ਪ९����� (��१�ࢨ஢����� ����)
          s := ""
          s1 += Eval( blk, s ) + ";"
          // 19 - �� - ��� ������ �����客������
          s1 += Eval( blk, DToS( krtp->D_PRIK ) ) + ";"
          // 20 - ��� - ��� ��९�����
          s1 += Eval( blk, "" ) + ";"
          // 21 - �� - ��� ��
          s1 += Eval( blk, f_s_csv( loidmo ) ) + ";"
          // 22 - �� - ��� ���ࠧ������� �� "��ᯮ�� ���" ���� 0
          s := AllTrim( otd->kod_podr )
          if len(s) > 0
            s1 += Eval( blk, f_s_csv( s ) ) + ";"
          else
            s1 += Eval( blk,"0" ) + ";"
          endif  
          // 23 - �� - ����� ���⪠
          s := lstr( tmp_krtp->uchast )
          s1 += Eval( blk, s ) + ";"
          // 24 - �� - ����� ���
          s := p2->snils
          s1 += Eval( blk, s ) + ";"
          // 25 -�� - ��⥣��� ��� (1-���  2-䥫���)
          s := iif( p2->kateg == 1, "1", "2" )
          s1 += Eval( blk, s )
          //
          FWrite( fp, hb_OEMToANSI( s1 ) )
          //
          Select TMP_KRTP
          Skip
        Enddo
        If k == 3 // ��᫥ ᬥ�� ���⪠
          Select KRTP
          Index On Str( reestr, 6 ) to ( cur_dir() + "tmp_krtp" )
          Use ( cur_dir() + "tmpu" ) new
          Set Relation To kod into KART
          Go Top
          Do While !Eof()
            ++i
            @ MaxRow(), 0 Say Str( i / ( ii + j ) * 100, 6, 2 ) + "%" Color cColorWait
            p2->( dbGoto( tmpu->kodp ) )
            otd->( dbGoto( p2->otd ) )
            Select KRTP
            addrec( 6 )
            krtp->REESTR   := krtr->KOD      // ��� ॥���;�� 䠩�� "mo_krtr"
            krtp->KOD_K    := tmpu->kod      // ��� ��樥�� �� 䠩�� "kartotek"
            krtp->D_PRIK   := sys_date       // ��� �ਪ९����� (������)
            krtp->S_PRIK   := 2              // ᯮᮡ �ਪ९�����: 1-�� ����� ॣ����樨, 2-�� ��筮�� ������ (��� ��������� �/�), 3-�� ��筮�� ������ (� �裡 � ���������� �/�)
            krtp->UCHAST   := kart->uchast   // ����� ���⪠
            krtp->SNILS_VR := p2->snils      // ����� ���⪮���� ���
            krtp->KOD_PODR := AllTrim( otd->kod_podr ) // ��� ���ࠧ������� �� ��ᯮ��� ���
            krtp->REES_ZAP := i              // ����� ��ப� � ॥���
            krtp->OPLATA   := 0              // ⨯ ������;᭠砫� 0, 1-�ਪ९��, 2-�訡��
            krtp->D_PRIK1  := CToD( "" )       // ��� �ਪ९�����
            Unlock
            //
            s1 := iif( i == 1, "", hb_eol() )
            // 1 - ����� ����� � 䠩�� � 10.06.19�.
            s1 += Eval( blk, lstr( i ) ) + ";"
            // 2 - ����⢨�
            s := "�" // 
            s1 += Eval( blk, s ) + ";"
            // 3 - ��� ⨯� ����
            s := iif( kart_->vpolis == 3, "�", iif( kart_->vpolis == 2, "�", "�" ) )
            s1 += Eval( blk, s ) + ";"
            // 4 - ���� � ����� ����
             if len(AllTrim( kart2->KOD_MIS )) == 16
              t_polis := alltrim(kart2->KOD_MIS)
             else
              t_polis :=  alltrim(kart_->NPOLIS)
             endif    
             s := t_polis
            //s := iif( kart_->vpolis == 3, AllTrim( kart2->KOD_MIS ), ;
            //  iif( kart_->vpolis == 2, AllTrim( kart2->KOD_MIS ) ,  AllTrim( kart2->KOD_MIS ) ) )
            //s := iif( kart_->vpolis == 3, "", ;
            //  iif( kart_->vpolis == 2, AllTrim( kart_->NPOLIS ), ;
            //  AllTrim( kart_->SPOLIS ) + " � " + AllTrim( kart_->NPOLIS ) ) )
            s1 += Eval( blk, f_s_csv( s ) ) + ";"
            // 5 - ����� ����� ����� ���
            s := iif( kart_->vpolis == 3, AllTrim( kart_->NPOLIS ), "" )
            s1 += Eval( blk, s ) + ";"
            arr_fio := retfamimot( 1, .f. )
            // 6 - ������� �����客������ ���
            s1 += Eval( blk, f_s_csv( arr_fio[ 1 ] ) ) + ";"
            // 7 - ��� �����客������ ���
            s1 += Eval( blk, f_s_csv( arr_fio[ 2 ] ) ) + ";"
            // 8 - ����⢮ �����客������ ���
            s1 += Eval( blk, f_s_csv( arr_fio[ 3 ] ) ) + ";"
            // 9 - ��� ஦����� �����客������ ���
            s1 += Eval( blk, DToS( kart->date_r ) ) + ";"
            // 10 - ���� ஦����� �����客������ ���
            s := iif( eq_any( kart_->vid_ud, 3, 14 ), AllTrim( del_spec_symbol( kart_->mesto_r ) ), "" )
            s1 += Eval( blk, f_s_csv( s ) ) + ";"
            fl := AScan( getvidud(), {| x| x[ 2 ] == kart_->vid_ud } ) == 0
            If !fl
              If Empty( kart_->nom_ud )
                fl := .t. // ������ ���� ��������� ���� "����� 㤮�⮢�७�� ��筮��"
              Elseif !ver_number( kart_->nom_ud )
                fl := .t. // ���� "����� 㤮�⮢�७�� ��筮��" ������ ���� ��஢�
              Elseif !val_ud_nom( 2, kart_->vid_ud, kart_->nom_ud )
                fl := .t.
              Endif
            Endif
            If !fl .and. eq_any( kart_->vid_ud, 1, 3, 14 ) .and. Empty( kart_->ser_ud )
              fl := .t. // �� ��������� ���� "����� 㤮�⮢�७�� ��筮��"
            Endif
            If !fl .and. !Empty( kart_->ser_ud ) .and. !val_ud_ser( 2, kart_->vid_ud, kart_->ser_ud )
              fl := .t.
            Endif
            If fl
              // 11 - ��� ���㬥��, 㤮�⮢����饣� ��筮���
              s1 += Eval( blk, "" ) + ";"
              // 12 - ����� ��� ��� � ����� ���㬥��, 㤮�⮢����饣� ��筮���.
              s1 += Eval( blk, "" ) + ";"
            Else
              // 11 - ��� ���㬥��, 㤮�⮢����饣� ��筮���
              s1 += Eval( blk, lstr( kart_->vid_ud ) ) + ";"
              // 12 - ����� ��� ��� � ����� ���㬥��, 㤮�⮢����饣� ��筮���.
              s := AllTrim( kart_->ser_ud ) + " � " + AllTrim( kart_->nom_ud )
              s1 += Eval( blk, f_s_csv( s ) ) + ";"
            Endif
            // 13 - ��� �뤠� ���㬥��, 㤮�⮢����饣� ��筮���
            lkogdavyd := kart_->kogdavyd
            If !Empty( kart_->kogdavyd ) .and. !Between( kart_->kogdavyd, kart->date_r, sys_date )
              If kart_->vid_ud == 3 // ᢨ�_�� � ஦�����
                lkogdavyd := kart->date_r
              Else
                lkogdavyd := CToD( "" )
              Endif
            Endif
            s := iif( Empty( lkogdavyd ), "", DToS( lkogdavyd ) )
            s1 += Eval( blk, s ) + ";"
            // 14 - ������������ �࣠��, �뤠�襣� ���㬥��
            s := AllTrim( inieditspr( A__POPUPMENU, dir_server() + "s_kemvyd", kart_->kemvyd ) )
            s1 += Eval( blk, f_s_csv( s ) ) + ";"
            // 15 - ����� �����客������ ���
            If !Empty( lsnils := kart->snils ) .and. !val_snils( kart->snils, 2 )
              lsnils := ""
            Endif
            s1 += Eval( blk, AllTrim( lsnils ) ) + ";"
            // 16 - �����䨪��� ��
            s1 += Eval( blk, glob_mo[ _MO_KOD_TFOMS ] ) + ";"
            // 17 - ���ᮡ �ਪ९�����
            s1 += Eval( blk, lstr( krtp->S_PRIK ) ) + ";"
            // 18 - ��� �ਪ९����� (��१�ࢨ஢����� ����)
            s := ""
            s1 += Eval( blk, s ) + ";"
            // 19 - ��� ������
            s1 += Eval( blk, DToS( krtp->D_PRIK ) ) + ";"
            // 20 - ��� ��९�����
            s1 += Eval( blk, "" ) + ";"
            // 21 ��� ��
            s1 += Eval( blk, f_s_csv( loidmo ) ) + ";"
            // 22 ��� ���ࠧ�������
            s := AllTrim( otd->kod_podr )
            if len(s) > 0
              s1 += Eval( blk, f_s_csv( s ) ) + ";"
            else
              s1 += Eval( blk,"0" ) + ";"
            endif  
            // 23 ����� ���⪠
            s := lstr( kart->uchast )
            s1 += Eval( blk, s ) + ";"
            // 24 ����� ���
            s := p2->snils
            s1 += Eval( blk, s ) + ";"
            // 25 ��⥣��� ���
            s := iif( p2->kateg == 1, "1", "2" )
            s1 += Eval( blk, s )
            //
            FWrite( fp, hb_OEMToANSI( s1 ) )
            //
            Select TMPU
            Skip
          Enddo
        Endif
        FClose( fp )
        If hb_FileExists( n_file )
          chip_copy_zipxml( n_file, dir_server() + dir_XML_MO(), .t. )
          Keyboard Chr( K_HOME ) + Chr( K_ENTER )
          Select KRTF
          g_rlock( forever )
          krtf->KOL := ii + j
          krtf->TWORK2 := hour_min( Seconds() ) // �६� ����砭�� ��ࠡ�⪨
        Else
          func_error( 4, "�訡�� ᮧ����� 䠩�� " + n_file )
        Endif
      Endif
    Endif
  Endif
  Close databases
  g_sunlock( str_sem )

  Return Nil

// 11.10.15
Function f1_p_f_pripisnoe_naselenie( aerr )
  Local s := Space( 80 ), lfio := '"' + AllTrim( p2->fio ) + '"'

  If p2->kateg != 1
    AAdd( aerr, "� ᯥ樠���� " + lfio + " � �ࠢ�筨�� ���ᮭ��� ��⥣��� ������ ���� ����" )
  Elseif Empty( p2->snils )
    AAdd( aerr, "�� ������ ����� � ��� " + lfio + " � �ࠢ�筨�� ���ᮭ���" )
  Elseif !val_snils( p2->snils, 2, @s )
    AAdd( aerr, s + " � ��� " + lfio + " � �ࠢ�筨�� ���ᮭ���" )
  Endif
  If Empty( p2->otd )
    AAdd( aerr, "�� ���⠢���� �⤥����� � ��� " + lfio + " � �ࠢ�筨�� ���ᮭ���" )
  Else
    Select OTD
    Goto ( p2->otd )
    If Empty( otd->kod_podr )
      AAdd( aerr, '� ��."' + AllTrim( otd->name ) + '" �� ���⠢��� ��� ���ࠧ�������' )
    Endif
  Endif

  Return Nil

// 09.09.25
Function kartoteka_z_prikreplenie()
  Static srec := 0
  Local blk, t_arr[ BR_LEN ]

  Private str_find := "1", muslovie := "kart->kod > 0", z_rec := 0

  t_arr[ BR_TOP ] := 2
  t_arr[ BR_BOTTOM ] := MaxRow() -1
  t_arr[ BR_LEFT ] := 0
  t_arr[ BR_RIGHT ] := MaxCol()
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := "����⥪� - �ਪ९�����"
  t_arr[ BR_TITUL_COLOR ] := "BG+/GR"
  t_arr[ BR_ARR_BROWSE ] := { "�", "�", "�", "N/BG,W+/N,B/BG,W+/B,R/BG,W+/R", .t., 72 }
  t_arr[ BR_ARR_BLOCK ] := { {|| findfirst( str_find ) }, ;
    {|| findlast( str_find ) }, ;
    {| _n| skippointer( _n, muslovie ) }, ;
    str_find, muslovie;
    }
  blk := {|| iif( kart2->mo_pr == glob_MO[ _MO_KOD_TFOMS ], { 1, 2 }, ;
    iif( Empty( kart2->mo_pr ), { 3, 4 }, { 5, 6 } ) ) }
  t_arr[ BR_COLUMN ] := { { Center( "�.�.�.", 35 ), {|| Left( kart->fio, 32 ) }, blk }, ;
    { "��� ஦�.", {|| full_date( kart->date_r ) }, blk }, ;
    { " �ਪ९�����", {|| PadR( inieditspr( A__MENUVERT, glob_arr_mo(), kart2->mo_pr ), 34 ) }, blk } }
  t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ - ��室; ^^ ��� ���.�㪢� - ����; ^<F9>^ - ����� ������ �� �ਪ९�����" ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f1_k_z_prikreplenie( nk, ob, "edit" ) }
  use_base( "kartotek" )
  Set Order To 2
  If srec > 0
    Goto ( srec )
  Else
    find ( str_find )
  Endif
  edit_browse( t_arr )
  If z_rec > 0
    srec := z_rec
  Endif
  Close databases

  Return Nil

// 29.03.23
Function f1_k_z_prikreplenie( nKey, oBrow, regim )
  Local j, s, ret := -1

  If regim == "edit" .and. nKey == K_F9
    If kart2->mo_pr == glob_MO[ _MO_KOD_TFOMS ]
      func_error( 1, "����� ��樥�� 㦥 �ਪ९�� � ��襬� ��" )
    Endif
    z_rec := kart->( RecNo() )
    delfrfiles()
    dbCreate( fr_titl, { ;
      { "name_org", "C", 130, 0 }, ;
      { "adres_org", "C", 110, 0 }, ;
      { "fio", "C", 60, 0 }, ;
      { "fam_io", "C", 30, 0 }, ;
      { "pol", "C", 10, 0 }, ;
      { "date_r", "C", 120, 0 }, ;
      { "pasport", "C", 250, 0 }, ;
      { "adres_p", "C", 250, 0 }, ;
      { "adres_g", "C", 250, 0 }, ;
      { "smo", "C", 100, 0 }, ;
      { "ruk_fio", "C", 60, 0 }, ;
      { "ruk", "C", 20, 0 } } )
    r_use( dir_server() + "organiz",, "ORG" )
    Use ( fr_titl ) New Alias FRT
    Append Blank
    frt->name_org := glob_MO[ _MO_SHORT_NAME ] + " (" + glob_MO[ _MO_KOD_TFOMS ] + ")"
    frt->adres_org := AllTrim( org->adres )
    frt->fio := kart->fio
    frt->fam_io := fam_i_o( kart->fio )
    frt->pol := iif( kart->pol == "�", "��᪮�", "���᪨�" )
    frt->date_r := full_date( kart->date_r ) + "�. " + AllTrim( kart_->mesto_r )
    s := ''
    If kart_->vid_ud > 0
      s := get_name_vid_ud( kart_->vid_ud, , ': ' )
      If !Empty( kart_->ser_ud )
        s += CharOne( " ", AllTrim( kart_->ser_ud ) ) + " "
      Endif
      If !Empty( kart_->nom_ud )
        s += AllTrim( kart_->nom_ud ) + " "
      Endif
      If !Empty( kart_->kogdavyd )
        s += "�뤠� " + full_date( kart_->kogdavyd ) + "�. "
      Endif
      If !Empty( kart_->kemvyd )
        s += inieditspr( A__POPUPMENU, dir_server() + "s_kemvyd", kart_->kemvyd )
      Endif
    Endif
    frt->pasport := s
    frt->adres_g := ret_okato_ulica( kart->adres, kart_->okatog )
    If emptyall( kart_->okatop, kart_->adresp )
      frt->adres_p := frt->adres_g
    Else
      frt->adres_p := ret_okato_ulica( kart_->adresp, kart_->okatop )
    Endif
    s := AllTrim( inieditspr( A__MENUVERT, glob_arr_smo, Int( Val( kart_->smo ) ) ) ) + ", ����� "
    s += AllTrim( RTrim( kart_->SPOLIS ) + " " + kart_->NPOLIS ) + " (" + ;
      AllTrim( inieditspr( A__MENUVERT, mm_vid_polis, kart_->VPOLIS ) ) + ")"
    frt->smo := s
    frt->ruk_fio := AllTrim( iif( Empty( org->ruk_fio ), org->ruk, org->ruk_fio ) )
    frt->ruk := AllTrim( org->ruk )
    Close databases
    call_fr( "mo_zprik" )
    //
    use_base( "kartotek" )
    Set Order To 2
    Goto ( z_rec )
    ret := 0
  Endif

  Return ret

// 11.09.17 ᮧ���� 䠩�(�) ᢥન
Function pripisnoe_naselenie_create_sverka()
  Local ii := 0, s, buf := SaveScreen(), fl, af := {}, arr_fio, ta, fl_polis, fl_pasport

  If !f_esc_enter( "ᮧ����� 䠩�� ᢥન", .t. )
    Return Nil
  Endif
  clrline( MaxRow(), color0 )
  dbCreate( cur_dir() + "tmp", { { "kod", "N", 7, 0 } } )
  Use ( cur_dir() + "tmp" ) new
  hGauge := gaugenew(,,, "���⠢����� ᯨ᪠ ��� ����祭�� � 䠩� ᢥન", .t. )
  gaugedisplay( hGauge )
  curr := 0
  r_use( dir_server() + "mo_kfio",, "KFIO" )
  Index On Str( kod, 7 ) to ( cur_dir() + "tmp_kfio" )
  r_use_base( "kartotek" )
  Set Order To 2
  find ( "1" )
  Do While kart->kod > 0 .and. !Eof()
    gaugeupdate( hGauge, ++curr / LastRec() )
    fl := .t.
    If Empty( kart->date_r )
      fl := .f. // �� ��������� ���� "��� ஦�����"
    Elseif kart->date_r >= sys_date
      fl := .f. // ��� ஦����� ����� ᥣ����譥� ����
    Elseif Year( kart->date_r ) < 1900
      fl := .f. // ��� ஦����� < 1900�.
    Endif
    If fl
      fl := Between( kart_->vpolis, 1, 3 ) .and. !Empty( kart_->NPOLIS )
    Endif
    If fl
      arr_fio := retfamimot( 1, .f., .t. )
      If val_fio( arr_fio ) .and. !( Len( arr_fio[ 2 ] ) < 2 .and. Len( arr_fio[ 3 ] ) < 2 )
        //
      Else
        fl := .f.
      Endif
    Endif
    If !fl .and. kart2->mo_pr == glob_MO[ _MO_KOD_TFOMS ]
      fl := .t.
    Endif
    If fl
      Select TMP
      Append Blank
      tmp->kod := kart->kod
      If tmp->( RecNo() ) % 100 == 0
        @ MaxRow(), 1 Say lstr( tmp->( RecNo() ) ) Color color0
        If tmp->( RecNo() ) % 2000 == 0
          Commit
        Endif
      Endif
    Endif
    Select KART
    Skip
  Enddo
  ii := tmp->( LastRec() )
  Close databases
  closegauge( hGauge )
  i := -1
  arr := {}
  Do While ii > 0
    k := Min( ii, 99999 ) ; i++
    AAdd( arr, { k, sys_date - i, 0 } )
    ii -= k
  Enddo
  fl := .f.
  s := "SZ2"
  r_use( dir_server() + "mo_krtr",, "KRTR" )
  Index On DToS( DFILE ) to ( cur_dir() + "tmp_krtr" ) For Left( FNAME, 3 ) == s
  ar := {}
  For i := 1 To Len( arr )
    n_file := s + glob_mo[ _MO_KOD_TFOMS ] + DToS( arr[ i, 2 ] ) + scsv()
    s1 := ""
    find ( DToS( arr[ i, 2 ] ) )
    If Found()
      s1 := " - 㦥 �� ᮧ���"
      fl := .t.
    Endif
    AAdd( ar, n_file + " (" + lstr( arr[ i, 1 ] ) + " 祫.)" + s1 )
  Next
  Close databases
  clrline( MaxRow(), color0 )
  ar2 := { " ��室 " } ; s1 := "䠩�" + iif( Len( arr ) == 1, "�", "��" )
  If fl
    ins_array( ar, 1, "����� ᮧ����� " + s1 + " ᢥન:" )
  Else
    ins_array( ar, 1, "���⢥न� ᮧ����� " + s1 + " ᢥન:" )
    AAdd( ar2, " �������� " + s1 + " ᢥન " )
  Endif
  If Len( ar ) < 8
    AAdd( ar, "" )
    If Len( ar ) < 8
      ins_array( ar, 2, "" )
    Endif
  Endif
  If f_alert( ar, ar2, 1, "GR+/R", "W+/R",,, "GR+/R,N/BG" ) == 2
    mywait()
    blk := {| _s| iif( Empty( _s ), '', '"' + _s + '"' ) }
    g_use( dir_server() + "mo_krtr",, "KRTR" )
    Index On Str( kod, 6 ) to ( cur_dir() + "tmp_krtr" )
    g_use( dir_server() + "mo_krtf",, "KRTF" )
    Index On Str( kod, 6 ) to ( cur_dir() + "tmp_krtf" )
    g_use( dir_server() + "mo_krtp",, "KRTP" )
    Index On Str( reestr, 6 ) to ( cur_dir() + "tmp_k" )
    r_use( dir_server() + "mo_kfio", cur_dir() + "tmp_kfio", "KFIO" )
    r_use_base( "kartotek" )
    Set Order To 0
    Use ( cur_dir() + "tmp" ) new
    Set Relation To kod into KART
    curr := 0
    RestScreen( buf )
    For i := 1 To Len( arr )
      n_file := "SZ2" + glob_mo[ _MO_KOD_TFOMS ] + DToS( arr[ i, 2 ] )
      Select KRTR
      addrec( 6 )
      krtr->KOD := RecNo()
      krtr->FNAME := n_file
      krtr->DFILE := arr[ i, 2 ]
      krtr->DATE_OUT := CToD( "" )
      krtr->NUMB_OUT := 0
      krtr->KOL := arr[ i, 1 ]
      krtr->KOL_P := 0
      krtr->ANSWER := 0  // 0-�� �뫮 �⢥�, 1-�� ���⠭ �⢥�
      //
      Select KRTF
      addrec( 6 )
      krtf->KOD   := RecNo()
      krtf->FNAME := krtr->FNAME
      krtf->DFILE := krtr->DFILE
      krtf->TFILE := hour_min( Seconds() )
      krtf->TIP_IN := 0
      krtf->TIP_OUT := _CSV_FILE_SVERKAZ
      krtf->REESTR := krtr->KOD
      krtf->DWORK := sys_date
      krtf->TWORK1 := hour_min( Seconds() ) // �६� ��砫� ��ࠡ�⪨
      krtf->TWORK2 := ""                  // �६� ����砭�� ��ࠡ�⪨
      //
      krtr->KOD_F := krtf->KOD
      dbUnlockAll()
      Commit
      //
      n_file += scsv()
      Delete File ( n_file )
      fp := FCreate( n_file )
      //
      hGauge := gaugenew(,,, "�������� 䠩�� ᢥન " + n_file, .t. )
      gaugedisplay( hGauge )
      For ii := 1 To arr[ i, 1 ]
        gaugeupdate( hGauge, ii / arr[ i, 1 ] )
        ++curr
        Select TMP
        Goto ( curr )
        arr_fio := retfamimot( 1, .f., .t. )
        fl_polis := fl_pasport := .t.
        If Empty( kart_->SPOLIS )
          ta := {}
          valid_sn_polis( kart_->vpolis, "", kart_->NPOLIS, ta, .t. )
          fl_polis := Empty( ta ) // �㭪�� �஢�ન �� ���㫠 �訡��
        Else
          fl_polis := .f. // ���� ��� ����� => �����த���
        Endif
        If !eq_any( kart_->vid_ud, 1, 3, 14 )
          fl_pasport := .f. // �� � � ���� "��� 㤮�⮢�७�� ��筮��"
        Else
          If Empty( kart_->nom_ud )
            fl_pasport := .f. // ������ ���� ��������� ���� "����� 㤮�⮢�७�� ��筮��"
          Elseif !val_ud_nom( 2, kart_->vid_ud, kart_->nom_ud )
            fl_pasport := .f.
          Endif
          If fl_pasport .and. !Empty( kart_->ser_ud ) .and. !val_ud_ser( 2, kart_->vid_ud, kart_->ser_ud )
            fl_pasport := .f.
          Endif
        Endif
        Select KRTP
        addrec( 6 )
        krtp->REESTR   := krtr->KOD // ��� ॥���;�� 䠩�� "mo_krtr"
        krtp->KOD_K    := kart->kod // ��� ��樥�� �� 䠩�� "kartotek"
        krtp->D_PRIK   := sys_date  // ��� �ਪ९����� (������)
        krtp->S_PRIK   := 0         // ᯮᮡ �ਪ९�����: 1-�� ����� ॣ����樨, 2-�� ��筮�� ������ (��� ��������� �/�), 3-�� ��筮�� ������ (� �裡 � ���������� �/�)
        krtp->REES_ZAP := ii        // ����� ��ப� � ॥���
        krtp->OPLATA   := 0         // ⨯ ������;᭠砫� 0, 1-�ਪ९��, 2-�訡��
        krtp->D_PRIK1  := CToD( "" )  // ��� �ਪ९�����
        //
        s1 := iif( ii == 1, "", hb_eol() ) + Eval( blk, lstr( ii ) ) + ";" // � ��砫� - ����� �� ���浪�
        // 1 - ��� ⨯� ����
        s := iif( kart_->vpolis == 3, "�", iif( kart_->vpolis == 2, "�", "�" ) )
        s1 += Eval( blk, s ) + ";"
        If kart_->vpolis < 3
          s := AllTrim( kart_->SPOLIS ) + AllTrim( kart_->NPOLIS )
          If Empty( s )
            s :=  iif( kart_->vpolis == 2, "123456789", "34" )
          Endif
          If kart_->vpolis == 2
            s := PadR( s, 9, "0" )
          Else
            s := PadR( s, 16, "0" )
          Endif
        Else
          s := ""
        Endif
        s1 += Eval( blk, s ) + ";"
        // 3 - ����� ����� ����� ���
        s := iif( kart_->vpolis == 3, AllTrim( kart_->NPOLIS ), "" )
        s1 += Eval( blk, s ) + ";"
        /*if fl_polis
          // 2 - ���� � ����� ���� (⮫쪮 ����� - ��� �������)
          s := iif(kart_->vpolis < 3, alltrim(kart_->NPOLIS), "")
          s1 += eval(blk,s)+";"
          // 3 - ����� ����� ����� ���
          s := iif(kart_->vpolis == 3, alltrim(kart_->NPOLIS), "")
          s1 += eval(blk,s)+";"
        else
          s1 += ";;"
        endif*/
        // 4 - ������� �����客������ ���
        s1 += Eval( blk, arr_fio[ 1 ] ) + ";"
        // 5 - ��� �����客������ ���
        s1 += Eval( blk, arr_fio[ 2 ] ) + ";"
        // 6 - ����⢮ �����客������ ���
        s1 += Eval( blk, arr_fio[ 3 ] ) + ";"
        // 7 - ��� ஦����� �����客������ ���
        s1 += Eval( blk, DToS( kart->date_r ) ) + ";"
        If fl_pasport
          // 8 - ��� ���㬥��, 㤮�⮢����饣� ��筮���
          s := lstr( kart_->vid_ud )
          s1 += Eval( blk, s ) + ";"
          // 9 - ����� ��� ��� � ����� ���㬥��, 㤮�⮢����饣� ��筮���.
          s := AllTrim( kart_->ser_ud ) + " � " + AllTrim( kart_->nom_ud )
          s1 += Eval( blk, s ) + ";"
        Else
          s1 += ";;"
        Endif
        // 10 - ����� �����客������ ���
        s := ""
        If !Empty( kart->snils ) .and. val_snils( kart->snils, 2 )
          s := kart->snils
        Endif
        s1 += Eval( blk, s )  // ��� ";", �.�. ��᫥���� ����
        //
        FWrite( fp, hb_OEMToANSI( s1 ) )
        If ii % 3000 == 0
          dbUnlockAll()
          Commit
        Endif
      Next ii
      FClose( fp )
      name_zip := AllTrim( krtr->FNAME ) + szip()
      Select KRTR
      g_rlock( forever )
      krtr->KOL := arr[ i, 1 ]
      Select KRTF
      g_rlock( forever )
      krtf->KOL := arr[ i, 1 ]
      krtf->TWORK2 := hour_min( Seconds() ) // �६� ����砭�� ��ࠡ�⪨
      dbUnlockAll()
      Commit
      If hb_FileExists( n_file )
        If chip_create_zipxml( name_zip, { n_file }, .t. )
          stat_msg( "���� ᢥન " + n_file + " ᮧ���!" ) ; mybell( 1, OK )
        Endif
      Else
        func_error( 4, "�訡�� ᮧ����� 䠩�� " + n_file )
      Endif
    Next i
    Close databases
    Keyboard Chr( K_HOME ) + Chr( K_ENTER )
  Endif
  RestScreen( buf )

  Return Nil

// 05.07.15 ����஥ ।���஢���� ���⪮� ᯨ᪮�
Function edit_uchast_spisok()
  Local flag := .t. // 䨫���
  Local arr_pr := { { "� ��襬� ��", 0 }, ;
    { "�� ��樥���", 1 } }
  Local arr_sr := { { "�� ���", 0 }, ;
    { "�� �����", 1 }, ;
    { "�� ����� ࠡ���", 2 } }
  Local arr_voz := { { "�� ��樥���", 0 }, ;
    { "�����", 1 }, ;
    { "���", 2 } }
  Local t_okato, t_rec, len_fio, buf := SaveScreen()
  // ����� ���⪠
  Local fl_uchast := 0
  // �����/���񭮪
  Local fl_vzros_reb := 0 // �� 㬮�砭�� �����
  // ���� - ��ᥫ�� �㭪� �ய�᪠
  Local fl_okato := okato_umolch
  // �ਪ९�����
  Local fl_pr := 0 //
  // 䨫��� �����
  Local fl_adres := Space( 20 ) //
  // 䨫��� ���������
  Local fl_dol := Space( 20 ) //
  // 䨫��� ���
  Local fl_fio := Space( 20 ) //
  // ����஢���
  Local fl_sort := 0

  // ������ -����⮢��
  Private mfl_vzros_reb, m1fl_vzros_reb := fl_vzros_reb, ;
    muchast := "�� ��樥���", m1uchast := 0, ;
    mokatog := Space( 10 ), m1okatog := Space( 11 ), ;
    mokatop := Space( 10 ), m1okatop := Space( 11 ), ;
    mfl_pr, m1fl_pr := fl_pr, ;
    mfl_adres := fl_adres, mfl_dol := fl_dol, ;
    mfl_fio := fl_fio,;
    mfl_sort, m1fl_sort := fl_sort
  mfl_vzros_reb := inieditspr( A__MENUVERT, arr_voz, m1fl_vzros_reb )
  mfl_pr   := inieditspr( A__MENUVERT, arr_pr, m1fl_pr )
  mfl_sort := inieditspr( A__MENUVERT, arr_sr, m1fl_sort )
  //
  Private arr_uchast := {}
  SetColor( cDataCGet )
  ix := 12
  clrlines( ix, 23 )
  @ ix, 0 To ix, 79
  str_center( ix, " ����� ��� ��⠢����� ᯨ᪠ " )
  ++ix
  @ ++ix, 3 Say "���⮪ (���⪨)" Get muchast ;
    reader {| x| menu_reader( x, ;
    { {|k, r, c| get_uchast( r + 1, c ) } }, A__FUNCTION,,, .f. ) }
  @ ++ix, 3 Say "�ਪ९�����" Get mfl_pr ;
    reader {| x| menu_reader( x, arr_pr, A__MENUVERT,,, .f. ) }
  @ ++ix, 3 Say "������" Get mfl_vzros_reb  ;
    reader {| x| menu_reader( x, arr_voz, A__MENUVERT,,, .f. ) }
  @ ++ix, 3 Say "���� ॣ����樨 (�����)" Get mokatog ;
    reader {| x| menu_reader( x, { {| k, r, c| get_okato_ulica( k, r, c, { k, mokatog, } ) } }, A__FUNCTION,,, .f. ) }
  @ ++ix, 3 Say "���� �ॡ뢠��� (�����)" Get mokatop ;
    reader {| x| menu_reader( x, { {| k, r, c| get_okato_ulica( k, r, c, { k, mokatop, } ) } }, A__FUNCTION,,, .f. ) }
  @ ++ix, 3 Say "���� (�����ப� ��� 蠡���)" Get mfl_adres Pict "@!"
  @ ++ix, 3 Say "���� ࠡ��� (�����ப� ��� 蠡���)" Get mfl_dol Pict "@!"
  @ ++ix, 3 Say "������� (��砫�� �㪢�)" Get mfl_fio Pict "@!"
  @ ++ix, 3 Say "��� ���஢��� ᯨ᮪ ��樥�⮢" Get mfl_sort  ;
    reader {| x| menu_reader( x, arr_sr, A__MENUVERT,,, .f. ) }
  status_key( "^<Esc>^ - ��室;  ^<PgDn>^ - ���⢥ত���� ����� � ᮧ����� ᯨ᪠ ��樥�⮢" )
  myread()
  If LastKey() == K_ESC .or. !f_esc_enter( 1 )
    RestScreen( buf )
    Return Nil
  Endif
  mywait()
  dbCreate( cur_dir() + "tmp_krtp", { { "KOD_K", "N", 7, 0 } } )
  Use ( cur_dir() + "tmp_krtp" ) new
  // ������ �� ���
  If !Empty( mfl_fio )
    mfl_fio := Upper( AllTrim( mfl_fio ) )
    len_fio := Len( mfl_fio )
  Endif
  Index On Str( kod_k, 7 ) to ( cur_dir() + "tmp_wq" )
  use_base( "kartotek" )
  Go Top
  Do While !Eof()
    flag := ( kart->kod > 0 .and. !( Left( kart2->PC2, 1 ) == '1' ) )
    // ���⪨
    If flag .and. !Empty( muchast )
      flag := f_is_uchast( arr_uchast, kart->uchast )
    Endif
    // �����/���񭮪
    If flag .and. m1fl_vzros_reb > 0
      If m1fl_vzros_reb == 1 // �����
        If !( count_years( kart->date_r, sys_date ) >= 18 )
          flag := .f.
        Endif
      Else // ���
        If !( count_years( kart->date_r, Date() ) < 18 )
          flag := .f.
        Endif
      Endif
    Endif
    // ����
    If flag .and. !Empty( m1okatog )
      s := m1okatog
      For i := 1 To 3
        If Right( s, 3 ) == '000'
          s := Left( s, Len( s ) -3 )
        Else
          Exit
        Endif
      Next
      flag := ( Left( kart_->okatog, Len( s ) ) == s )
    Endif
    If flag .and. !Empty( m1okatop )
      s := m1okatop
      For i := 1 To 3
        If Right( s, 3 ) == '000'
          s := Left( s, Len( s ) -3 )
        Else
          Exit
        Endif
      Next
      flag := ( Left( kart_->okatop, Len( s ) ) == s )
    Endif
    If flag .and. m1fl_pr == 0 // �ਪ९�� � ���
      flag := ( kart2->mo_pr == glob_MO[ _MO_KOD_TFOMS ] )
    Endif
    // ������ �� �����
    If flag .and. !Empty( mfl_adres )
      If "*" $  mfl_adres .or. "?" $ mfl_adres
        flag := Like( AllTrim( mfl_adres ), Upper( kart->adres ) )
      Else
        flag := ( AllTrim( mfl_adres ) $ Upper( kart->adres ) )
      Endif
    Endif
    // ������ �� ࠡ��
    If flag .and. !Empty( mfl_dol )
      If "*" $  mfl_dol .or. "?" $ mfl_dol
        flag := Like( AllTrim( mfl_dol ), Upper( kart->mr_dol ) )
      Else
        flag := ( AllTrim( mfl_dol ) $ Upper( kart->mr_dol ) )
      Endif
    Endif
    // ������ �� ���
    If flag .and. !Empty( mfl_fio )
      flag := ( mfl_fio == Upper( Left( kart->fio, len_fio ) ) )
    Endif
    // ������塞 ������
    If flag
      Select TMP_KRTP
      Append Blank
      tmp_krtp->KOD_K := kart->( RecNo() )
    Endif
    Select KART
    Skip
  Enddo
  Private ku := tmp_krtp->( LastRec() )
  Close databases
  If ku == 0
    RestScreen( buf )
    Return func_error( 4, "�� ������� �᫮��� �⡮� ��祣� �� �������!" )
  Endif
  //
  Private TIP_uchast  := 1 // 1-���� 2-ࠡ��
  g_use( dir_server() + "kartotek", { dir_server() + "kartotek", ;
    dir_server() + "kartoten", ;
    dir_server() + "kartotep", ;
    dir_server() + "kartoteu" }, "KART" )
  Set Order To 0
  Use ( cur_dir() + "tmp_krtp" ) new
  Set Relation To kod_k into KART
  // ��⠭�������� ५���
  If m1fl_sort ==  0 // �� 䨮
    Index On Upper( kart->fio ) to ( cur_dir() + "tmp_ru" )
  Elseif m1fl_sort ==  1 // �� �����
    Index On Upper( kart->adres ) to ( cur_dir() + "tmp_ru" )
  Else
    Index On Upper( kart->mr_dol ) to ( cur_dir() + "tmp_ru" )
    TIP_uchast := 2 // 1-���� 2-ࠡ��
  Endif
  alpha_browse( 2, 0, 23, 79, "f1_vvod_uchast_spisok", color0, "������஢���� ���⪠ (" + lstr( ku ) + " 祫.)", "BG+/GR", ;
    .t., .t.,,, "f2_vvod_uchast_spisok",, ;
    { "�", "�", "�", "N/BG,W+/N,B/BG,W+/B,R/BG,BG/R", .t., 180, "*+" } )
  Close databases
  RestScreen( buf )

  Return Nil

// 29.05.15
Function f1_vvod_uchast_spisok( oBrow )
  Local oColumn, blk

  oColumn := TBColumnNew( Center( "���", 30 ), {|| PadR( kart->fio, 30 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "��� ஦�.", {|| full_date( kart->date_r ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "��", {|| Str( kart->uchast, 2 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  If TIP_uchast  == 1
    oColumn := TBColumnNew( Center( "����", 31 ), {|| PadR( kart->adres, 31 ) } )
  Else
    oColumn := TBColumnNew( Center( "���� ࠡ���", 31 ), {|| PadR( kart->mr_dol, 31 ) } )
  Endif
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  status_key( "^<Esc>^ - ��室;  ^<Enter>^ - ।���஢���� ���⪠;  ^<F9>^ - ����� ᯨ᪠" )

  Return Nil


// 28.12.21
Function f2_vvod_uchast_spisok( nKey, oBrow )
  Local j := 0, flag := -1, buf := save_maxrow(), buf1, fl := .f., ;
    nr := Row(), c1, rec, mkod, buf0, tmp_color := SetColor(), t_vr, ;
    vp := Int( Val( lstr( Day( sys_date ) ) + StrZero( Month( sys_date ), 2 ) ) )

  Private  much, old_uch

  Do Case
  Case nKey == K_F10
    If ku > 10000
      func_error( 4, "���誮� ����� ��樥�⮢ � ᯨ᪥" )
    Elseif ! hb_user_curUser:isadmin()
      func_error( 4, err_admin() )
    Elseif ( much := input_value( 18, 5, 20, 74, color1, ;
        "������ ����� ���⪠ ��� ���⠭���� �ᥬ ��樥�⠬ �� ᯨ᪠", 0, "99" ) ) != NIL ;
        .and. much > 0 ;// .and. involved_password(1,vp,"ᬥ�� ����� ���⪠ �ᥬ ��樥�⠬ �� ᯨ᪠") ;
      .and. f_alert( { PadC( "�롥�� ����⢨�", 60, "." ) }, ;
        { " �⪠� ", " ������� ����� ���⪠ �ᥬ ��樥�⠬ " }, ;
        1, "W+/N", "N+/N", MaxRow() -2,, "W+/N,N/BG" ) == 2
      mywait()
      rec := tmp_krtp->( RecNo() )
      Go Top
      Do While !Eof()
        kart->( g_rlock( forever ) )
        kart->uchast := much
        kart->( dbUnlock() )
        Skip
      Enddo
      rest_box( buf )
      Select TMP_KRTP
      Goto ( rec )
      flag := 0
      stat_msg( '���⮪ ������ �ᥬ ��樥�⠬!' ) ; mybell( 1, OK )
    Endif
  Case nKey == K_F9
    mywait()
    rec := tmp_krtp->( RecNo() )
    f3_vvod_uchast_spisok( TIP_uchast )
    rest_box( buf )
    Select TMP_KRTP
    Goto ( rec )
    flag := 0
  Case nKey == K_ENTER
    old_uch := much := kart->uchast
    c1 := 44
    @ nr, c1 Get much Pict "99" Color "GR+/R"
    myread()
    If LastKey() != K_ESC .and. old_uch != much
      kart->( g_rlock( forever ) )
      kart->uchast := much
      kart->( dbUnlock() )
      Keyboard Chr( K_TAB )
    Endif
    flag := 0
  Otherwise
    Keyboard ""
  Endcase

  Return flag

// 28.05.15
Function f3_vvod_uchast_spisok( tip )
  // tip - 1 ����
  // 2 ���� ࠡ���
  Local sh, HH := 78, name_file := cur_dir() + "reg_prip.txt", i := 0, arr_title, s

  s := { "����", "���� ࠡ���" }[ tip ]
  arr_title := { ;
    "����������������������������������������������������������������������������������������������������������������", ;
    "� �/����-��               �.�.�                    ���� ஦�.�" + Center( s, 50 ), ;
    "����������������������������������������������������������������������������������������������������������������" }
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  sh := Len( arr_title[ 1 ] )
  add_string( "" )
  add_string( Center( "���᮪ ��樥�⮢ (��� ����� ���⪠)", sh ) )
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  Select TMP_KRTP
  Go Top
  Do While !Eof()
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    add_string( Str( ++i, 5 ) + Str( kart->uchast, 4 ) + "  " + PadR( kart->fio, 40 ) + " " + ;
      full_date( kart->date_r ) + " " + ;
      AllTrim( iif( tip == 1, kart->adres, kart->mr_dol ) ) )
    Select TMP_KRTP
    Skip
  Enddo
  FClose( fp )
  viewtext( name_file,,,, .t.,,, 6 )

  Return Nil

// 09.09.25 ��ᬮ��/����� �ਪ९�񭭮�� ��ᥫ����
Function spisok_pripisnoe_naselenie( par )
  Static sj, smo := "      "
  Local i, j, k, s, arr := {}, n_file := cur_dir() + "pr_nas" + lstr( par ) + stxt(), ll := 0, ;
    ret_arr, sh := 120, HH := 57, buf := save_maxrow() // 81 b 80

  If Empty( arr_mo )
    mywait()
    r_use( dir_server() + "kartotek",, "KART" )
    r_use( dir_server() + "kartote2",, "KART2" )
    Set Relation To RecNo() into KART
    Index On mo_pr to ( cur_dir() + "tmp_kart2" ) For !kart->( Eof() ) .and. kart->kod > 0
    Go Top
    Do While !Eof()
      If ( i := AScan( arr_mo, {| x| x[ 2 ] == kart2->mo_pr } ) ) == 0
        AAdd( arr_mo, { "", kart2->mo_pr, 0, 0 } ) ; i := Len( arr_mo )
      Endif
      arr_mo[ i, 3 ] ++
      If Left( kart2->PC2, 1 ) == "1"
        arr_mo[ i, 4 ] ++
      Endif
      Skip
    Enddo
    Close databases
    For i := 1 To Len( arr_mo )
      If ( j := AScan( glob_arr_mo(), {| x| x[ _MO_KOD_TFOMS ] == arr_mo[ i, 2 ] } ) ) > 0
        arr_mo[ i, 1 ] := Str( arr_mo[ i, 3 ], 6 ) + " 祫. " + arr_mo[ i, 2 ] + " " + glob_arr_mo()[ j, _MO_SHORT_NAME ]
        If arr_mo[ i, 2 ] == glob_MO[ _MO_KOD_TFOMS ]
          AAdd( arr, i )
        Endif
      Else
        AAdd( arr_no, arr_mo[ i, 2 ] )
        AAdd( arr, i )
      Endif
    Next
    ASort( arr )
    For i := Len( arr ) To 1 Step -1
      del_array( arr_mo, arr[ i ] )
    Next
    ASort( arr_mo,,, {| x, y| x[ 2 ] < y[ 2 ] } )
    rest_box( buf )
  Endif
  If ( j := f_alert( { "", ;
      "�롥�� ���冷� ���஢�� ��室���� ���㬥��", ;
      "" }, ;
      { " �� ~��� ", " �� ~����� " }, ;
      sj, "W/RB", "G+/RB", 18,, "BG+/RB,W+/R,W+/RB,GR+/R" ) ) == 0
    Return Nil
  Endif
  sj := j
  mywait()
  fl := .t.
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "kartote_",, "KART_" )
  r_use( dir_server() + "kartote2",, "KART2" )
  Set Relation To RecNo() into KART
  Set Index to ( cur_dir() + "tmp_kart2" )
  Do Case
  Case par == 1
    find ( glob_MO[ _MO_KOD_TFOMS ] )
    Index On iif( sj == 1, "", Str( kart->uchast, 2 ) ) + Upper( kart->fio ) + DToS( kart->date_r ) to ( cur_dir() + "tmp_kart" ) ;
      While kart2->mo_pr == glob_MO[ _MO_KOD_TFOMS ]
  Case par == 2
    popup_2array( arr_mo, 2, 2, smo, 1, @ret_arr, "�롮� �� �ਪ९�����", "B/BG" )
    If ValType( ret_arr ) == "A"
      smo := ret_arr[ 2 ]
      find ( ret_arr[ 2 ] )
      Index On iif( sj == 1, "", Str( kart->uchast, 2 ) ) + Upper( kart->fio ) + DToS( kart->date_r ) to ( cur_dir() + "tmp_kart" ) ;
        While kart2->mo_pr == ret_arr[ 2 ]
    Else
      fl := .f.
    Endif
  Case par == 3
    Index On iif( sj == 1, "", Str( kart->uchast, 2 ) ) + Upper( kart->fio ) + DToS( kart->date_r ) to ( cur_dir() + "tmp_kart" ) ;
      For !kart->( Eof() ) .and. kart->kod > 0 .and. AScan( arr_no, kart2->mo_pr ) > 0
  Endcase
  If fl
    arr_title := { ;
      "������������������������������������������������������������������������������������������������������������������������������������������������������������", ;
      "��                    �.�.�                         ���� ஦�.�                                      ����                                     ��ਪ९���", ;
      "������������������������������������������������������������������������������������������������������������������������������������������������������������" }
    sh := Len( arr_title[ 1 ] )
    fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( "" )
    Do Case
    Case par == 1
      add_string( Center( "���⠢ ����⥪� (�ਪ९��� � ��襩 ��)", sh ) )
    Case par == 2
      add_string( Center( "���⠢ ����⥪� (�ਪ९��� � " + SubStr( ret_arr[ 1 ], 13 ) + ")", sh ) )
    Case par == 3
      add_string( Center( "���⠢ ����⥪� (�� �ਪ९��� �� � ����� ��)", sh ) )
    Endcase
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    k := k1 := 0
    Go Top
    Do While !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      KART_->( dbGoto( kart->kod ) )
      ll := Len( AllTrim( kart->adres ) )
      ll2 := Len( AllTrim( ret_okato_ulica( "", kart_->okatog, 1, 2 ) ) )
      If ll2 > ( 29 + 50 -ll )
        // ���� १���
        ll1 := PadR( AllTrim( ret_okato_ulica( "", kart_->okatog, 3, 2 ) ), 29 + 50 -ll ) + " " + PadR( kart->adres, ll )
      Else
        ll1 := PadR( AllTrim( ret_okato_ulica( "", kart_->okatog, 3, 2 ) ) + " " + AllTrim( kart->adres ), 80 )
      Endif

      add_string( put_val( kart->uchast, 2 ) + " " + ;
        iif( Left( kart2->PC2, 1 ) == "1", PadR( kart->fio, 45 ) + " ����", PadR( kart->fio, 50 ) ) + " " + ;
        full_date( kart->date_r ) + " " + ll1 + " " + ;
        iif( par == 3, "", iif( Empty( kart2->pc4 ), full_date( kart2->DATE_PR ), AllTrim( kart2->pc4 ) ) ) )
      ++k
      If Left( kart2->PC2, 1 ) == "1"
        ++k1
      Endif
      Skip
    Enddo
    add_string( Replicate( "-", sh ) )
    add_string( "�⮣�: " + lstr( k ) + " 祫. (� �.�. 㬥૮ - " + lstr( k1 ) + ")" )
    FClose( fp )
    Private yes_albom := .t.
    viewtext( n_file,,,, .t.,,, 6 )
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 25.03.18 ������� ������⢠ �ਪ९�񭭮�� ��ᥫ���� �� ���⪠�
Function kol_uch_pripisnoe_naselenie()
  Local sh, HH := 60, name_file := cur_dir() + "uch_prik.txt", arr_title, i, j, k, arr1 := {}, arr2 := {}, ;
    fl, arr, buf := save_maxrow()

  mywait()
  r_use( dir_exe() + "_okatos", cur_dir() + "_okats", "SELO" )
  r_use( dir_exe() + "_okatoo", cur_dir() + "_okato", "OBLAST" )
  r_use_base( "kartotek" )
  Set Order To
  Go Top
  Do While !Eof()
    @ MaxRow(), 0 Say Str( RecNo() / LastRec() * 100, 6, 2 ) + "%" Color cColorWait
    If kart->kod > 0 .and. !( Left( kart2->PC2, 1 ) == '1' ) .and. kart2->mo_pr == glob_MO[ _MO_KOD_TFOMS ] // �ਪ९�� � ���
      v := iif( count_years( kart->date_r, sys_date ) < 18, 2, 1 )
      j := iif( kart->pol == "�", 2, 3 )
      k := 4 // ��த
      fl := .f.
      If kart_->gorod_selo == 2
        fl := .t.  // ��諨
        k := 5   // ᥫ�
      Endif
      If !fl .and. !Empty( okato_rajon( kart_->okatog, @arr ) )
        If arr[ 5 ] == 1 // ��த
          fl := .t.  // ��諨
          k := 4   // ��த
        Endif
      Endif
      If !fl
        Select SELO
        find ( PadR( kart_->okatog, 11, '0' ) )
        If Found()
          fl := .t.  // ��諨
          k := iif( selo->selo == 0, 5, 4 )
        Endif
        If !fl
          Select OBLAST
          find ( PadR( kart_->okatog, 5, '0' ) )
          If Found()
            fl := .t.  // ��諨
            k := iif( oblast->selo == 0, 5, 4 )
          Endif
        Endif
      Endif
      If v == 1
        If ( i := AScan( arr1, {| x| x[ 1 ] == kart->uchast } ) ) == 0
          AAdd( arr1, { kart->uchast, 0, 0, 0, 0 } ) ; i := Len( arr1 )
        Endif
        arr1[ i, j ] ++
        arr1[ i, k ] ++
      Else
        If ( i := AScan( arr2, {| x| x[ 1 ] == kart->uchast } ) ) == 0
          AAdd( arr2, { kart->uchast, 0, 0, 0, 0 } ) ; i := Len( arr2 )
        Endif
        arr2[ i, j ] ++
        arr2[ i, k ] ++
      Endif
    Endif
    Select KART
    Skip
  Enddo
  Close databases
  rest_box( buf )
  If Len( arr1 ) == 0 .and. Len( arr2 ) == 0
    func_error( 4, "�� �����㦥�� ��樥�⮢, �ਪ९���� � ��襩 ��" )
  Else
    arr := Array( 5 )
    ASort( arr1,,, {| x, y| x[ 1 ] < y[ 1 ] } )
    ASort( arr2,,, {| x, y| x[ 1 ] < y[ 1 ] } )
    arr_title := { ;
      "���������������������������������������������������������������������", ;
      "� ���⪠�  ��稭�  �  ���騭�  �   ��த   �   ᥫ�    �   �ᥣ�   ", ;
      "���������������������������������������������������������������������" }
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    sh := Len( arr_title[ 1 ] )
    add_string( glob_mo[ _MO_SHORT_NAME ] )
    add_string( "" )
    add_string( Center( "������⢮ �ਪ९���� ��樥�⮢", sh ) )
    add_string( Center( "[ �� ���ﭨ� �� " + date_8( sys_date ) + "�. ]", sh ) )
    AEval( arr_title, {| x| add_string( x ) } )
    If Len( arr1 ) > 0
      If verify_ff( HH - 2, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      AFill( arr, 0 )
      add_string( "" )
      add_string( PadC( "�����", sh, "_" ) )
      For i := 1 To Len( arr1 )
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( Str( arr1[ i, 1 ], 7 ) + put_val( arr1[ i, 2 ], 12 ) + put_val( arr1[ i, 3 ], 12 ) + ;
          put_val( arr1[ i, 4 ], 12 ) + put_val( arr1[ i, 5 ], 12 ) + put_val( arr1[ i, 2 ] + arr1[ i, 3 ], 12 ) )
        For j := 2 To 5
          arr[ j ] += arr1[ i, j ]
        Next
      Next
      add_string( Replicate( "�", sh ) )
      add_string( " �⮣�:" + put_val( arr[ 2 ], 12 ) + put_val( arr[ 3 ], 12 ) + ;
        put_val( arr[ 4 ], 12 ) + put_val( arr[ 5 ], 12 ) + put_val( arr[ 2 ] + arr[ 3 ], 12 ) )
    Endif
    If Len( arr2 ) > 0
      If verify_ff( HH - 2, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      AFill( arr, 0 )
      add_string( "" )
      add_string( PadC( "���", sh, "_" ) )
      For i := 1 To Len( arr2 )
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( Str( arr2[ i, 1 ], 7 ) + put_val( arr2[ i, 2 ], 12 ) + put_val( arr2[ i, 3 ], 12 ) + ;
          put_val( arr2[ i, 4 ], 12 ) + put_val( arr2[ i, 5 ], 12 ) + put_val( arr2[ i, 2 ] + arr2[ i, 3 ], 12 ) )
        For j := 2 To 5
          arr[ j ] += arr2[ i, j ]
        Next
      Next
      add_string( Replicate( "�", sh ) )
      add_string( " �⮣�:" + put_val( arr[ 2 ], 12 ) + put_val( arr[ 3 ], 12 ) + ;
        put_val( arr[ 4 ], 12 ) + put_val( arr[ 5 ], 12 ) + put_val( arr[ 2 ] + arr[ 3 ], 12 ) )
    Endif
    FClose( fp )
    viewtext( name_file,,,, .t.,,, 1 )
  Endif

  Return Nil

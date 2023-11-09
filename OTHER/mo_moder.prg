// mo_moder.prg - ���ଠ�� �� ����୨��樨
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

#define _MD_USL   1 // ���� ��㣨 �����祭���� ����
#define _MD_DIAG  2 // �᭮���� �������
#define _MD_OTD   3 // �⤥�����, ��� ������� ��㣠
#define _MD_VRACH 4 // ���, ������訩 ����
#define _MD_SMO   5 // ���客�� ��������
#define _MD_SCHET 6 // ����
#define _MD_HUMAN 7 // � ���.���., ���, �ப� ��祭��

//
Function modern_statist( k )
  Static si1 := 1, sds := 1, ssp := 1
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { "~�����祭�� ��砨 (������� �����)", ;
      "~�����祭�� ��砨 (������� �����)", ;
      "���㡫����� ~��ᯠ��ਧ��� �����⪮�" }
    mas_msg := { "����⨪� �� �����祭�� ���� � 㪠������ �㬬 ������ �����", ;
      "����⨪� �� �����祭�� ���� � 㪠������ �㬬 ������ �����", ;
      "����⨪� �� 㣫㡫����� ��ᯠ��ਧ�樨 �����⪮�" }
    mas_fun := { "modern_statist(11)", ;
      "modern_statist(12)", ;
      "modern_statist(13)" }
    popup_prompt( T_ROW, T_COL - 5, si1, mas_pmt, mas_msg, mas_fun )
  Case Between( k, 11, 19 )
    mas_pmt := { "�� ��� ~�믨᪨ ���", ;
      "�� ~����⭮�� ��ਮ��", ;
      "�� ��� ~ॣ����樨 ���" }
    If ( j := popup_prompt( T_ROW, T_COL - 5, sds, mas_pmt,,, "B/BG,W+/B,N/BG,BG+/B" ) ) > 0
      sds := j
      Private pds := j
      mas_pmt := { "~���᮪ ��⮢", ;
        "� ��ꥤ������� �� ~�ਭ���������" }
      If eq_any( k, 11, 12 )
        AAdd( mas_pmt, "�������ਠ��� ~�����" )
      Endif
      If ( j := popup_prompt( T_ROW, T_COL - 5, ssp, mas_pmt ) ) > 0
        ssp := j
        Do Case
        Case k == 11
          f1zs_modern_statist( 2, ssp )
        Case k == 12
          f1zs_modern_statist( 1, ssp )
        Case k == 13
          f1udp_modern_statist( ssp )
        Endcase
      Endif
    Endif
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Endif
  Endif

  Return Nil

//
Function f1zs_modern_statist( k2, k3 )
  // k2 - 1-�����, 2-�����
  // k3 = 1 - ���᮪ ��⮢
  // k3 = 2 - � ��ꥤ������� �� �ਭ���������
  // k3 = 3 - �������ਠ��� �����
  Local ktmp := 0, arr_m, hGauge, fl, anv, v_doplata, r_doplata, lshifr, ;
    pole, polen, rec, lsmo, lotd, lvrach, ldiag, lsumma, llen, _js := 1, ;
    buf := save_maxrow(), sh, HH := 57, arr_title, reg_print, t_arr[ 2 ], ;
    name_file := "modern_z" + stxt, pp[ 8 ], spp[ 8 ], old_smo := -1, i, j, k, s, ;
    s1, is_20_11, sdate := SToD( "20121120" )

  If ( arr_m := year_month(,, .f. ) ) == NIL
    Return Nil
  Endif
  If pds == 2 .and. !( arr_m[ 5 ] == BoM( arr_m[ 5 ] ) .and. arr_m[ 6 ] == EoM( arr_m[ 6 ] ) )
    Return func_error( 4, "����訢���� ��ਮ� ������ ���� ��⥭ ������" )
  Endif
  If k3 == 3 .and. ( ( _js := popup_prompt( T_ROW, T_COL - 5, 1, ;
      { "�� �ᥬ ��⠬", "� ������������ �롮� ��⮢" } ) ) == 0 .or. ;
      Empty( anv := f2zs_modern_statist() ) )
    Return Nil
  Endif
  If r_use( dir_server + "schet_",, "SCHET_" ) .and. ;
      r_use( dir_server + "schet",, "SCHET" ) .and. ;
      r_use( dir_server + "schetd",, "SD" )
    //
    hGauge := gaugenew(,,, "���� ���ଠ樨", .t. )
    gaugedisplay( hGauge )
    Select SD
    Index On Str( kod, 6 ) to ( cur_dir + "tmp_sd" )
    dbCreate( cur_dir + "tmp", { ;
      { "is", "N", 1, 0 }, ;
      { "smo", "N", 5, 0 }, ;
      { "kol", "N", 6, 0 }, ;
      { "ot_per", "C", 5, 0 }, ;
      { "PDATE", "C", 4, 0 }, ;
      { "NOMER_S", "C", 15, 0 }, ;
      { "summa", "N", 13, 2 }, ;
      { "a_s", "C", 100, 0 }, ;
      { "schetf", "N", 6, 0 };
      } )
    Use ( cur_dir + "tmp" ) new
    Select SCHET
    Set Relation To RecNo() into SCHET_
    Go Top
    Do While !Eof()
      gaugeupdate( hGauge, RecNo() / LastRec() )
      If schet_->IS_DOPLATA == 1 // ���� �����⮩?;0-���, 1-�� ��� IFIN=1 ��� 2
        If pds == 1
          fl := Between( schet_->dschet, arr_m[ 5 ], arr_m[ 6 ] )
        Elseif pds == 2
          fl := between_otch_period( schet_->dschet, schet_->NYEAR, schet_->NMONTH, arr_m[ 5 ], arr_m[ 6 ] )
        Else
          fl := ( schet_->NREGISTR == 0 .and. Between( date_reg_schet(), arr_m[ 5 ], arr_m[ 6 ] ) )
        Endif
        If fl .and. schet_->IFIN == k2 // 1-�����, 2-�����
          Select TMP
          Append Blank
          tmp->is := 1
          tmp->smo := Val( schet_->smo )
          tmp->schetf := schet->kod
          tmp->pdate := schet->pdate
          tmp->nomer_s := schet_->nschet
          tmp->kol := schet->kol
          tmp->summa := schet->summa
          tmp->ot_per := put_otch_period()
          arr := {}
          Select SD
          find ( Str( schet->kod, 6 ) )
          Do While schet->kod == sd->kod .and. !Eof()
            AAdd( arr, sd->kod2 )
            Skip
          Enddo
          tmp->a_s := arr2list( arr )
        Endif
      Endif
      Select SCHET
      Skip
    Enddo
    closegauge( hGauge )
    ktmp := tmp->( LastRec() )
    Close databases
    If ktmp == 0
      func_error( 4, "�� �����㦥�� ��⮢ �� ����୨��樨 " + arr_m[ 4 ] )
    Endif
  Endif
  Close databases
  If ktmp > 0 .and. k3 == 3
    If _js == 2 .and. !f6zs_modern_statist()
      Return Nil
    Endif
    mywait()
    adbf := { ;
      { "kol", "N", 6, 0 }, ;
      { "summaf", "N", 13, 2 }, ;
      { "summao", "N", 13, 2 };
      }
    llen := Len( anv )
    For i := 1 To 7
      AAdd( adbf, { "kod" + lstr( i ), "C", 10, 0 } )
      AAdd( adbf, { "name" + lstr( i ), "C", 255, 0 } )
    Next
    dbCreate( cur_dir + "tmp1", adbf )
    Use ( cur_dir + "tmp1" ) New Alias TMP
    Index On kod1 + kod2 + kod3 + kod4 + kod5 + kod6 + kod7 to ( cur_dir + "tmp1" )
    use_base( "lusl" )
    r_use( dir_server + "mo_otd",, "OTD" )
    r_use( dir_server + "mo_pers",, "PERSO" )
    r_use( dir_exe + "_mo_mkb", cur_dir + "_mo_mkb", "DIAG" )
    r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
    r_use( dir_server + "human_",, "HUMAN_" )
    r_use( dir_server + "human", dir_server + "humans", "HUMAN" )
    Set Relation To RecNo() into HUMAN_
    r_use( dir_server + "uslugi",, "USL" )
    r_use( dir_server + "schet_",, "SCHET_" )
    r_use( dir_server + "schet",, "SCHET" )
    Set Relation To RecNo() into SCHET_
    r_use( dir_server + "schetd", cur_dir + "tmp_sd", "SD" )
    Use ( cur_dir + "tmp" ) New Alias tmps
    Index On pdate to ( cur_dir + "tmp" ) For is == 1
    Go Top
    Do While !Eof()
      schet->( dbGoto( tmps->schetf ) )
      rec := schet->( RecNo() )
      lsmo := schet_->smo
      If schet_->NREGISTR == 0 // ��ॣ����஢���� ���
        is_20_11 := ( date_reg_schet() >= sdate )
      Else
        is_20_11 := ( schet_->DSCHET > SToD( "20121210" ) ) // 10.12.2012�.
      Endif
      Select SD
      find ( Str( tmps->schetf, 6 ) )
      Do While sd->kod == tmps->schetf .and. !Eof()
        schet->( dbGoto( sd->kod2 ) )
        Select HUMAN
        find ( Str( sd->kod2, 6 ) )
        Do While human->schet == sd->kod2 .and. !Eof()
          lshifr := "" ; v_doplata := r_doplata := lotd := lvrach := 0
          ret_zak_sl( @lshifr, @v_doplata, @r_doplata, @lotd, @lvrach, iif( is_20_11, sdate, nil ) )
          If iif( k2 == 1, !Empty( r_doplata ), .t. )
            ldiag := diag_for_xml(, .t.,,, .t. )[ 1 ]
            lsumma := iif( k2 == 2, v_doplata, r_doplata )
            For k := 1 To llen
              s := ""
              For i := 1 To llen - k + 1
                Do Case
                Case anv[ i, 2 ] == _MD_USL
                  s += PadR( lshifr, 10 )
                Case anv[ i, 2 ] == _MD_DIAG
                  s += PadR( ldiag, 10 )
                Case anv[ i, 2 ] == _MD_OTD
                  s += PadR( lstr( lotd ), 10 )
                Case anv[ i, 2 ] == _MD_VRACH
                  s += PadR( lstr( lvrach ), 10 )
                Case anv[ i, 2 ] == _MD_SMO
                  s += PadR( lsmo, 10 )
                Case anv[ i, 2 ] == _MD_SCHET
                  s += PadR( lstr( tmps->schetf ), 10 )
                Case anv[ i, 2 ] == _MD_HUMAN
                  s += PadR( lstr( human->kod ), 10 )
                Endcase
              Next
              Select TMP
              find ( PadR( s, llen * 10 ) )
              If !Found()
                Append Blank
                For i := 1 To llen - k + 1
                  pole := "tmp->kod" + lstr( i )
                  polen := "tmp->name" + lstr( i )
                  Do Case
                  Case anv[ i, 2 ] == _MD_USL
                    &pole := lshifr
                    Select LUSL
                    find ( PadR( lshifr, 10 ) )
                    &polen := RTrim( lshifr ) + " " + lusl->name
                  Case anv[ i, 2 ] == _MD_DIAG
                    &pole := ldiag
                    s1 := AllTrim( ldiag ) + " "
                    Select DIAG
                    find ( PadR( ldiag, 6 ) )
                    Do While diag->shifr == PadR( ldiag, 6 ) .and. !Eof()
                      s1 += AllTrim( diag->name ) + " "
                      Skip
                    Enddo
                    &polen := s1
                  Case anv[ i, 2 ] == _MD_OTD
                    &pole := lstr( lotd )
                    otd->( dbGoto( lotd ) )
                    &polen := otd->name
                  Case anv[ i, 2 ] == _MD_VRACH
                    &pole := lstr( lvrach )
                    perso->( dbGoto( lvrach ) )
                    &polen := AllTrim( perso->fio ) + " [" + lstr( perso->tab_nom ) + "]"
                  Case anv[ i, 2 ] == _MD_SMO
                    &pole := lsmo
                    &polen := f4_view_list_schet( 0, lsmo, 0 )
                  Case anv[ i, 2 ] == _MD_SCHET
                    &pole := lstr( tmps->schetf )
                    &polen := tmps->nomer_s + " �� " + date_8( c4tod( tmps->pdate ) )
                  Case anv[ i, 2 ] == _MD_HUMAN
                    &pole := lstr( human->kod )
                    &polen := AllTrim( human->uch_doc ) + " " + ;
                      AllTrim( human->fio ) + " " + ;
                      date_8( human->n_data ) + "-" + date_8( human->k_data ) + ;
                      " (" + lstr( human->k_data - human->n_data ) + "�/�)"
                  Endcase
                Next
              Endif
              tmp->kol++
              tmp->summaf += lsumma
              tmp->summao += human->cena_1
            Next
          Endif
          //
          Select HUMAN
          Skip
        Enddo
        Select SD
        Skip
      Enddo
      Select TMPS
      Skip
    Enddo
    //
    arr_title := { ;
      "��������������������������������������������������������������������������������" }
    For i := 1 To llen
      s := PadR( Space( ( i - 1 ) * 2 ) + anv[ i, 1 ], 48 ) + "�"
      If i == llen
        s += " ���.�������" + { "�����", "�����" }[ k2 ] + "��㬬� �� ���"
      Else
        s += "     �            �"
      Endif
      AAdd( arr_title, s )
    Next
    AAdd( arr_title, ;
      "��������������������������������������������������������������������������������" )
    HH := 80
    reg_print := f_reg_print( arr_title, @sh, 2 )
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( "" )
    add_string( Center( "���ଠ�� �� ����୨��樨 (�����祭�� ��砨)", sh ) )
    If pds == 1
      s := "��� �믨᪨ ��⮢"
    Elseif pds == 2
      s := "����� ��ਮ�"
    Else
      s := "��� ॣ����樨 ��⮢"
    Endif
    add_string( Center( "[ " + s + " " + arr_m[ 4 ] + " ]", sh ) )
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    Select TMP
    Index On Left( name1, 20 ) + Left( name2, 20 ) + Left( name3, 20 ) + ;
      Left( name4, 20 ) + Left( name5, 20 ) + Left( name6, 20 ) + Left( name7, 20 ) to ( cur_dir + "tmp1" )
    Go Top
    Do While !Eof()
      k := 12 ; s := tmp->name7
      If Empty( tmp->name2 )
        k := 0 ; s := tmp->name1
      Elseif Empty( tmp->name3 )
        k := 2 ; s := tmp->name2
      Elseif Empty( tmp->name4 )
        k := 4 ; s := tmp->name3
      Elseif Empty( tmp->name5 )
        k := 6 ; s := tmp->name4
      Elseif Empty( tmp->name6 )
        k := 8 ; s := tmp->name5
      Elseif Empty( tmp->name7 )
        k := 10 ; s := tmp->name6
      Endif
      j := perenos( t_arr, s, 48 -k )
      If verify_ff( HH - j + 1, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( PadR( Space( k ) + t_arr[ 1 ], 48 ) + put_val( tmp->kol, 6 ) + ;
        put_kope( tmp->summaf, 13 ) + put_kope( tmp->summao, 13 ) )
      For i := 2 To j
        add_string( PadL( AllTrim( t_arr[ i ] ), 48 ) )
      Next
      Select TMP
      Skip
    Enddo
    Close databases
    FClose( fp )
    rest_box( buf )
    viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Elseif ktmp > 0
    r_use( dir_server + "schet_",, "SCHET_" )
    r_use( dir_server + "schet",, "SCHET" )
    Set Relation To RecNo() into SCHET_
    Use ( cur_dir + "tmp" ) new
    If k3 == 1
      Index On pdate + nomer_s to ( cur_dir + "tmp" )
    Else
      Index On Str( smo, 5 ) + pdate + nomer_s to ( cur_dir + "tmp" )
    Endif
    s1 := { "����� ", "����� " }[ k2 ]
    arr_title := { ;
      "���������������������������������������������������������������������������������������������������������", ;
      "����  ���  � ����� ���� ��� ���.��㬬� ������                    ������ �᭮������ ���.��㬬� ���� ", ;
      "��ਮ�  ��� � ������� " + s1 + "����쭳   " + s1 + "   � ������������ ���   �  ���� ���    ����쭳    ���     ", ;
      "���������������������������������������������������������������������������������������������������������" }
    reg_print := f_reg_print( arr_title, @sh )
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( "" )
    add_string( Center( Expand( "������ ������" ), sh ) )
    add_string( Center( "�� ����୨��樨 (�����祭�� ��砨)", sh ) )
    If pds == 1
      s := "��� �믨᪨ ��⮢"
    Elseif pds == 2
      s := "����� ��ਮ�"
    Else
      s := "��� ॣ����樨 ��⮢"
    Endif
    add_string( Center( "[ " + s + " " + arr_m[ 4 ] + " ]", sh ) )
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    AFill( spp, 0 ) ; AFill( pp, 0 ) ; pj := 0
    Select TMP
    Go Top
    Do While !Eof()
      If k3 == 2 .and. tmp->smo != old_smo
        If pj > 0
          If verify_ff( HH - 2, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
          add_string( Space( 21 ) + Replicate( "-", sh - 21 ) )
          add_string( PadL( "�⮣�:", 30 ) + ;
            put_val( pp[ 1 ], 6 ) + put_kope( pp[ 2 ], 13 ) + Space( 37 ) + ;
            put_val( pp[ 5 ], 6 ) + put_kope( pp[ 6 ], 13 ) )
          add_string( "" )
        Endif
        pj := 0 ; AFill( pp, 0 )
      Endif
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      arr := list2arr( tmp->a_s )
      schet->( dbGoto( tmp->schetf ) )
      s := put_otch_period() + " " + ;
        date_8( schet_->dschet ) + " " + ;
        schet_->nschet + ;
        put_val( schet->kol, 6 ) + put_kope( schet->summa, 13 ) + ;
        " " + PadR( f4_view_list_schet(), 21 )
      spp[ 1 ] += schet->kol   ; pp[ 1 ] += schet->kol
      spp[ 2 ] += schet->summa ; pp[ 2 ] += schet->summa
      If Len( arr ) > 0
        schet->( dbGoto( arr[ 1 ] ) )
        s += schet_->nschet + ;
          put_val( schet->kol, 6 ) + put_kope( schet->summa, 13 )
        spp[ 5 ] += schet->kol   ; pp[ 5 ] += schet->kol
        spp[ 6 ] += schet->summa ; pp[ 6 ] += schet->summa
      Endif
      add_string( s )
      For i := 2 To Len( arr )
        schet->( dbGoto( arr[ i ] ) )
        s := Space( 71 )
        s += schet_->nschet + ;
          put_val( schet->kol, 6 ) + put_kope( schet->summa, 13 )
        add_string( s )
        spp[ 5 ] += schet->kol   ; pp[ 5 ] += schet->kol
        spp[ 6 ] += schet->summa ; pp[ 6 ] += schet->summa
      Next
      ++pj
      old_smo := tmp->smo
      Select TMP
      Skip
    Enddo
    If verify_ff( HH - 2, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    If k3 == 2 .and. pj > 0
      add_string( Space( 21 ) + Replicate( "-", sh - 21 ) )
      add_string( PadL( "�⮣�:", 30 ) + ;
        put_val( pp[ 1 ], 6 ) + put_kope( pp[ 2 ], 13 ) + Space( 37 ) + ;
        put_val( pp[ 5 ], 6 ) + put_kope( pp[ 6 ], 13 ) )
    Endif
    If verify_ff( HH - 2, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    If spp[ 1 ] > 0
      add_string( Replicate( "�", sh ) )
      add_string( PadL( "�ᥣ�:", 30 ) + ;
        put_val( spp[ 1 ], 6 ) + put_kope( spp[ 2 ], 13 ) + Space( 37 ) + ;
        put_val( spp[ 5 ], 6 ) + put_kope( spp[ 6 ], 13 ) )
    Endif
    Close databases
    FClose( fp )
    rest_box( buf )
    viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Endif

  Return Nil

//
Function f2zs_modern_statist()
  Local arr_por, buf := SaveScreen(), ret_arr := {}, ;
    mas2 := { { 1, "�" }, { 2, PadR( "������������", 31 ) } }, ;
    mas_p := { { 1, 0 }, }, ;
    blk := {| b, ar, nDim, nElem, nKey| f3zs_modern_statist( b, ar, nDim, nElem, nKey ) }

  arr_por := { { 1, "���� ��㣨 �����祭���� ����", _MD_USL  }, ;
    { 2, "�᭮���� �������               ", _MD_DIAG }, ;
    { 3, "�⤥�����, ��� ������� ��㣠  ", _MD_OTD  }, ;
    { 4, "���, ������訩 ����         ", _MD_VRACH }, ;
    { 5, "���客�� ��������             ", _MD_SMO  }, ;
    { 6, "���� (� � ���)                ", _MD_SCHET } }
  arrn_browse( T_ROW, T_COL - 5, T_ROW + 9, T_COL + 33, arr_por, mas2, 1,, color1, ;
    "����� ���浪� ���祢�� �����", color8, .t.,, ;
    mas_p, blk, { .f., .f., .f. } )
  dbCreate( cur_dir + "tmp", { { "name", "C", 31, 0 }, { "plus", "L", 1, 0 }, { "nv", "N", 2, 0 } } )
  Use ( cur_dir + "tmp" ) new
  For i := 1 To Len( arr_por )
    Append Blank
    Replace name With arr_por[ i, 2 ], nv With arr_por[ i, 3 ]
    If i < 3
      Replace plus With .t.
    Endif
  Next
  Append Blank
  Replace name With "� ���.���., ���, �ப� ��祭��", nv With _MD_HUMAN
  Go Top
  RestScreen( buf )
  If alpha_browse( T_ROW, T_COL - 5, T_ROW + 10, T_COL + 33, "f4zs_modern_statist", color0, ;
      "���᮪ ����� ��� �����", "BG+/GR", ;
      .t., .t.,,, "f5zs_modern_statist",, ;
      { '�', '�', '�', "N/BG,W+/N,B/BG,W+/B",, 300 } )
    dbEval( {|| AAdd( ret_arr, { name, nv } ) }, {|| plus } )
  Endif
  Close databases
  RestScreen( buf )

  Return ret_arr

//
Function f3zs_modern_statist( b, ar, nDim, nElem, nKey )
  Local nRow := Row(), nCol := Col(), flag := .f., i

  Private tmp

  If nKey == K_ENTER .or. Between( nKey, 48, 57 )
    tmp := ar[ nElem, 1 ]
    @ nRow, nCol Get tmp Picture "9"
    myread( { "confirm" } )
    If LastKey() != K_ESC .and. tmp > 0 .and. tmp != ar[ nElem, 1 ]
      If ( i := AScan( ar, {| x| x[ 1 ] == tmp } ) ) == 0
        func_error( 4, "����蠥��� ������� ⮫쪮 �����, ���������騥 � ⠡���." )
      Else
        If nElem > i  // ����⠢����� "�����" �� ⠡���
          AEval( parr, {| x, j| parr[ j, 1 ] := j + 1 }, i, nElem - i )
        Else          // ����⠢����� "����" �� ⠡���
          AEval( parr, {| x, j| parr[ j, 1 ] := j - 1 }, nElem + 1, i - nElem )
        Endif
        parr[ nElem, 1 ] := tmp
        flag := .t.
        ASort( parr,,, {| x, y| x[ 1 ] < y[ 1 ] } )
        b:refreshall() ; b:gotop() ; ieval( tmp - 1, {|| b:down() } )
      Endif
    Endif
  Else
    Keyboard ""
  Endif
  @ nRow, nCol Say ""

  Return flag

//
Function f4zs_modern_statist( oBrow )
  Local oColumn, n := 31, blk_color := {|| if( tmp->plus, { 1, 2 }, { 3, 4 } ) }

  oColumn := TBColumnNew( " ", {|| if( tmp->plus, "", " " ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( Center( "������������ ����", n ), {|| tmp->name } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " ", {|| if( tmp->plus, "", " " ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  status_key( "^<Esc>^ �⪠�  ^<Enter>^ ��砫� ���᪠  ^<Ins>^ �⬥��� ���� ��� ����祭�� � �����" )

  Return Nil

//
Function f5zs_modern_statist( nKey, oBrow )
  Local k := -1

  If nkey == K_INS
    Replace tmp->plus With !tmp->plus
    k := 0
    Keyboard Chr( K_TAB )
  Endif

  Return k

//
Function f6zs_modern_statist()
  Local k, buf24 := save_maxrow(), t_arr[ BR_LEN ], blk

  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := 11
  t_arr[ BR_RIGHT ] := 67
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := "�롮� ��⮢ ��� �������ਠ�⭮�� �����"
  t_arr[ BR_TITUL_COLOR ] := "B/BG"
  t_arr[ BR_ARR_BROWSE ] := { '�', '�', '�', "N/BG,W+/N,B/BG,W+/B", .t. }
  blk := {|| iif( tmp->is == 1, { 1, 2 }, { 3, 4 } ) }
  t_arr[ BR_COLUMN ] := { { ' ', {|| iif( tmp->is == 1, '', ' ' ) }, blk }, ;
    { "��/�.", {|| tmp->ot_per }, blk }, ;
    { "����� ����", {|| tmp->nomer_s }, blk }, ;
    { "  ���", {|| date_8( c4tod( tmp->pdate ) ) }, blk }, ;
    { " ���.", {|| put_val( tmp->kol, 6 ) }, blk }, ;
    { " �㬬� ����", {|| put_kop( tmp->summa, 13 ) }, blk } }
  t_arr[ BR_EDIT ] := {| nk, ob| f7zs_modern_statist( nk, ob, "edit" ) }
  t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ ��室 ��� ����;  ^<+,-,Ins>^ �⬥��� ���� ��� �������" ) }
  Use ( cur_dir + "tmp" ) new
  Index On pdate + nomer_s to ( cur_dir + "tmp" )
  edit_browse( t_arr )
  k := 0
  dbEval( {|| ++k }, {|| tmp->is == 1 } )
  Use

  Return ( k > 0 )

//
Function f7zs_modern_statist( nKey, oBrow, regim )
  Local k := -1, rec, fl

  If regim == "edit"
    Do Case
    Case nkey == K_INS
      Replace tmp->is With if( tmp->is == 1, 0, 1 )
      k := 0
      Keyboard Chr( K_TAB )
    Case nkey == 43 .or. nkey == 45  // + ��� -
      fl := ( nkey == 43 )
      rec := RecNo()
      tmp->( dbEval( {|| tmp->is := iif( fl, 1, 0 ) } ) )
      Goto ( rec )
      k := 0
    Endcase
  Endif

  Return k

//
Function f1udp_modern_statist( k3 )
  // k3 = 1 - ���᮪ ��⮢
  // k3 = 2 - � ��ꥤ������� �� �ਭ���������
  Static sa_usl
  Local k := 0, arr_m, hGauge, fl, ;
    buf := save_maxrow(), sh, HH := 57, arr_title, reg_print, ;
    name_file := "modern_u" + stxt, pp[ 8 ], spp[ 8 ], old_smo := -1, s

  If ( arr_m := year_month(,, .f. ) ) == NIL
    Return Nil
  Endif
  If pds == 2 .and. !( arr_m[ 5 ] == BoM( arr_m[ 5 ] ) .and. arr_m[ 6 ] == EoM( arr_m[ 6 ] ) )
    Return func_error( 4, "����訢���� ��ਮ� ������ ���� ��⥭ ������" )
  Endif
  If r_use( dir_server + "human_",, "HUMAN_" ) .and. ;
      r_use( dir_server + "human", dir_server + "humans", "HUMAN" ) .and. ;
      r_use( dir_server + "human_u", dir_server + "human_u", "HU" ) .and. ;
      r_use( dir_server + "uslugi",, "USL" ) .and. ;
      r_use( dir_server + "schet_",, "SCHET_" ) .and. ;
      r_use( dir_server + "schet",, "SCHET" )
    //
    hGauge := gaugenew(,,, "���� ���ଠ樨", .t. )
    gaugedisplay( hGauge )
    dbCreate( cur_dir + "tmp", { ;
      { "smo", "N", 5, 0 }, ;
      { "schet", "N", 6, 0 };
      } )
    Use ( cur_dir + "tmp" ) new
    Select HUMAN
    Set Relation To RecNo() into HUMAN_
    Select SCHET
    Set Relation To RecNo() into SCHET_
    Go Top
    Do While !Eof()
      gaugeupdate( hGauge, RecNo() / LastRec() )
      If schet_->IS_MODERN == 1 // ���� ����୨��樥�?;0-���, 1-�� ��� IFIN=1
        If pds == 1
          fl := Between( schet_->dschet, arr_m[ 5 ], arr_m[ 6 ] )
        Elseif pds == 2
          fl := between_otch_period( schet_->dschet, schet_->NYEAR, schet_->NMONTH, arr_m[ 5 ], arr_m[ 6 ] )
        Else
          fl := ( schet_->NREGISTR == 0 .and. Between( date_reg_schet(), arr_m[ 5 ], arr_m[ 6 ] ) )
        Endif
        If fl
          fl := .f.
          Select HUMAN
          find ( Str( schet->kod, 6 ) )
          Do While human->schet == schet->kod .and. !Eof()
            Select HU
            find ( Str( human->kod, 7 ) )
            Do While hu->kod == human->kod .and. !Eof()
              usl->( dbGoto( hu->u_kod ) )
              If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
                lshifr := usl->shifr
              Endif
              If Left( lshifr, 5 ) == "70.1." // ���.��ᯠ��ਧ���
                fl := .t. ; Exit
              Endif
              Select HU
              Skip
            Enddo
            If fl ; exit ; Endif
            Select HUMAN
            Skip
          Enddo
        Endif
        If fl
          Select TMP
          Append Blank
          tmp->smo := Val( schet_->smo )
          tmp->schet := schet->kod
        Endif
      Endif
      Select SCHET
      Skip
    Enddo
    closegauge( hGauge )
    k := tmp->( LastRec() )
    Close databases
    If k == 0
      func_error( 4, "�� �����㦥�� ��⮢ �� ����୨��樨 " + arr_m[ 4 ] )
    Endif
  Endif
  Close databases
  If k > 0
    r_use( dir_server + "schet_",, "SCHET_" )
    r_use( dir_server + "schet",, "SCHET" )
    Set Relation To RecNo() into SCHET_
    Use ( cur_dir + "tmp" ) new
    Set Relation To schet into SCHET
    If k3 == 1
      Index On schet->pdate + schet_->nschet to ( cur_dir + "tmp" )
    Else
      Index On Str( smo, 5 ) + schet->pdate + schet_->nschet to ( cur_dir + "tmp" )
    Endif
    arr_title := { ;
      "����������������������������������������������������������������������", ;
      " ����� ����   ����.��  ���  � ���.� �㬬� ���⠳ ������������ ���   ", ;
      "����������������������������������������������������������������������" }
    reg_print := f_reg_print( arr_title, @sh )
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( "" )
    add_string( Center( Expand( "������ ������" ), sh ) )
    add_string( Center( "�� 㣫㡫����� ��ᯠ��ਧ�樨 �����⪮�", sh ) )
    If pds == 1
      s := "��� �믨᪨ ��⮢"
    Elseif pds == 2
      s := "����� ��ਮ�"
    Else
      s := "��� ॣ����樨 ��⮢"
    Endif
    add_string( Center( "[ " + s + " " + arr_m[ 4 ] + " ]", sh ) )
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    AFill( spp, 0 ) ; AFill( pp, 0 ) ; pj := 0
    Select TMP
    Go Top
    Do While !Eof()
      If k3 == 2 .and. tmp->smo != old_smo
        If pj > 0
          If verify_ff( HH - 2, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
          add_string( Space( 21 ) + Replicate( "-", sh - 21 ) )
          add_string( PadL( "�⮣�:", 30 ) + ;
            put_val( pp[ 1 ], 6 ) + put_kope( pp[ 2 ], 13 ) )
          add_string( "" )
        Endif
        pj := 0 ; AFill( pp, 0 )
      Endif
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( schet_->nschet + " " + ;
        put_otch_period() + " " + ;
        date_8( schet_->dschet ) + ;
        put_val( schet->kol, 6 ) + put_kope( schet->summa, 13 ) + ;
        " " + f4_view_list_schet() )
      ++pj
      old_smo := tmp->smo
      spp[ 1 ] += schet->kol   ; pp[ 1 ] += schet->kol
      spp[ 2 ] += schet->summa ; pp[ 2 ] += schet->summa
      Select TMP
      Skip
    Enddo
    If verify_ff( HH - 2, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    If k3 == 2 .and. pj > 0
      add_string( Space( 21 ) + Replicate( "-", sh - 21 ) )
      add_string( PadL( "�⮣�:", 30 ) + ;
        put_val( pp[ 1 ], 6 ) + put_kope( pp[ 2 ], 13 ) )
    Endif
    If verify_ff( HH - 2, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    If spp[ 1 ] > 0
      add_string( Replicate( "�", sh ) )
      add_string( PadL( "�ᥣ�:", 30 ) + ;
        put_val( spp[ 1 ], 6 ) + put_kope( spp[ 2 ], 13 ) )
    Endif
    Close databases
    FClose( fp )
    rest_box( buf )
    viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Endif

  Return Nil

// 12.10.14 ��� - ���������� ��� ।���஢���� ���� (���� ���)
Function oms_sluch_dvn13( Loc_kod, kod_kartotek, f_print )
  // Loc_kod - ��� �� �� human.dbf (�᫨ =0 - ���������� ���� ���)
  // kod_kartotek - ��� �� �� kartotek.dbf (�᫨ =0 - ���������� � ����⥪�)
  // f_print - ������������ �㭪樨 ��� ����
  Static st_N_DATA, st_K_DATA
  Local bg := {| o, k| get_mkb10( o, k, .t. ) }, arr_del := {}, mrec_hu := 0, ;
    buf := SaveScreen(), tmp_color := SetColor(), a_smert := {}, ;
    p_uch_doc := "@!", pic_diag := "@K@!", arr_usl := {}, ;
    i, j, k, s, colget_menu := "R/W", colgetImenu := "R/BG", ;
    pos_read := 0, k_read := 0, count_edit := 0, ar, larr, lu_kod, ;
    tmp_help := chm_help_code, fl_write_sluch := .f., mu_cena

  //
  Default st_N_DATA To sys_date, st_K_DATA To sys_date
  Default Loc_kod To 0, kod_kartotek To 0
  //
  If kod_kartotek == 0 // ���������� � ����⥪�
    If ( kod_kartotek := edit_kartotek( 0,,, .t. ) ) == 0
      Return Nil
    Endif
  Endif
  chm_help_code := 3002
  Private P_BEGIN_RSLT := 342, D_BEGIN_RSLT := 316, D_BEGIN_RSLT2 := 351
  Private mfio := Space( 50 ), mpol, mdate_r, madres, mvozrast, mdvozrast, ;
    M1VZROS_REB, MVZROS_REB, m1novor := 0, ;
    m1company := 0, mcompany, mm_company, ;
    mkomu, M1KOMU := 0, M1STR_CRB := 0, ; // 0-���,1-��������,3-�������/���,5-���� ���
  msmo := "34001", rec_inogSMO := 0, ;
    mokato, m1okato := "", mismo, m1ismo := "", mnameismo := Space( 100 ), ;
    mvidpolis, m1vidpolis := 1, mspolis := Space( 10 ), mnpolis := Space( 20 )
  Private mkod := Loc_kod, mtip_h, is_talon := .f., mshifr_zs := "", ;
    mkod_k := kod_kartotek, fl_kartotek := ( kod_kartotek == 0 ), ;
    M1LPU := glob_uch[ 1 ], MLPU, ;
    M1OTD := glob_otd[ 1 ], MOTD, ;
    M1FIO_KART := 1, MFIO_KART, ;
    MRAB_NERAB, M1RAB_NERAB := 0, ; // 0-ࠡ���騩, 1 -��ࠡ���騩
  mveteran, m1veteran := 0, ;
    mmobilbr, m1mobilbr := 0, ;
    MUCH_DOC    := Space( 10 ),; // ��� � ����� ��⭮�� ���㬥��
  MKOD_DIAG   := Space( 5 ),; // ��� 1-�� ��.�������
  MKOD_DIAG2  := Space( 5 ),; // ��� 2-�� ��.�������
  MKOD_DIAG3  := Space( 5 ),; // ��� 3-�� ��.�������
  MKOD_DIAG4  := Space( 5 ),; // ��� 4-�� ��.�������
  MSOPUT_B1   := Space( 5 ),; // ��� 1-�� ᮯ������饩 �������
  MSOPUT_B2   := Space( 5 ),; // ��� 2-�� ᮯ������饩 �������
  MSOPUT_B3   := Space( 5 ),; // ��� 3-�� ᮯ������饩 �������
  MSOPUT_B4   := Space( 5 ),; // ��� 4-�� ᮯ������饩 �������
  MDIAG_PLUS  := Space( 8 ),; // ���������� � ���������
  adiag_talon[ 16 ],; // �� ���⠫��� � ���������
  m1rslt  := 317,; // १���� (��᢮��� I ��㯯� ���஢��)
  m1ishod := 306,; // ��室 = �ᬮ��
  MN_DATA := st_N_DATA,; // ��� ��砫� ��祭��
  MK_DATA := st_K_DATA,; // ��� ����砭�� ��祭��
  MVRACH := Space( 10 ),; // 䠬���� � ���樠�� ���饣� ���
  M1VRACH := 0, MTAB_NOM := 0, m1prvs := 0, ; // ���, ⠡.� � ᯥ�-�� ���饣� ���
  m1povod  := 4, ;   // ��䨫����᪨�
    m1travma := 0, ;
    m1USL_OK :=  3, ; // �����������
  m1VIDPOM :=  1, ; // ��ࢨ筠�
  m1PROFIL := 97, ; // 97-�࠯��,57-���� ���.�ࠪ⨪� (ᥬ���.���-�),42-��祡��� ����
  m1IDSP   := 11, ; // ���.��ᯠ��ਧ���
  mcena_1 := 0
  //
  Private arr_usl_dop := {}, arr_usl_otkaz := {}
  Private metap := 0, ;  // 1-���� �⠯, 2-��ன �⠯, 3-��䨫��⨪�
  mndisp, ;
    mWEIGHT := 0, ;   // ��� � ��
  mHEIGHT := 0, ;   // ��� � �
    mOKR_TALII := 0, ; // ���㦭���� ⠫�� � �
  mtip_mas, m1tip_mas := 0, ;
    mkurenie, m1kurenie := 0, ; //
  mriskalk, m1riskalk := 0, ; //
  mpod_alk, m1pod_alk := 0, ; //
  mpsih_na, m1psih_na := 0, ; //
  mfiz_akt, m1fiz_akt := 0, ; //
  mner_pit, m1ner_pit := 0, ; //
  mprof_ko, m1prof_ko := 0, ; //
  maddn, m1addn := 0, mad1 := 120, mad2 := 80, ; // ��������
  mholestdn, m1holestdn := 0, mholest := 0, ; // "99.99"
  mglukozadn, m1glukozadn := 0, mglukoza := 0, ; // "99.99"
  mssr := 0, ; // "99"
  mgruppa, m1gruppa := 9      // ��㯯� ���஢��
  Private mvar, m1var
  Private mm_ndisp := { { "��ᯠ��ਧ��� I  �⠯", 1 }, ;
    { "��ᯠ��ਧ��� II �⠯", 2 }, ;
    { "��䨫����᪨� �ᬮ��", 3 } }
  Private mm_prof_ko := { { "�������㠫쭮�", 0 }, ;
    { "��㯯����", 1 } }
  Private mm_gruppaP := { { "��᢮��� I ��㯯� ���஢��",1 }, ;
    { "��᢮��� II ��㯯� ���஢��",2 }, ;
    { "��᢮��� III ��㯯� ���஢��", 3 } }
  Private mm_gruppaD := AClone( mm_gruppaP )
  AAdd( mm_gruppaD, { "���ࠢ��� �� 2 �⠯, �।���⥫쭮 ��᢮��� I ��㯯� ���஢��", 11 } )
  AAdd( mm_gruppaD, { "���ࠢ��� �� 2 �⠯, �।���⥫쭮 ��᢮��� II ��㯯� ���஢��", 12 } )
  AAdd( mm_gruppaD, { "���ࠢ��� �� 2 �⠯, �।���⥫쭮 ��᢮��� III ��㯯� ���஢��", 13 } )
  Private mm_otkaz := { { "_�믮�����", 0 }, ;
    { "�⪠� ���.", 1 }, ;
    { "����������", 2 } }
  Private mm_otkaz1 := { mm_otkaz[ 1 ], mm_otkaz[ 2 ] }
  Private mm_pervich := { { "�����", 1 }, ;
    { "_࠭��_", 0 } }
  Private mm_stadia  := { { "࠭���", 0 }, ;
    { "�����.", 1 } }
  Private mm_dispans := { { "࠭�� ���.", 1 }, ;
    { "����.���.", 2 }, ;
    { "�� ��⠭��", 0 } }
  Private mm_usl := { { "���㫠��", 0 }, ;
    { "��樮���", 1 }, ;
    { "ᯥ�.���", 2 }, ;
    { "� �.�.���", 3 } }
  //
  Private pole_diag, pole_pervich, pole_1pervich, ;
    pole_stadia, pole_1stadia, ;
    pole_dispans, pole_1dispans, ;
    pole_dop, pole_1dop, pole_gde, ;
    pole_usl, pole_1usl, ;
    pole_san, pole_1san
  For i := 1 To 5
    sk := lstr( i )
    pole_diag := "mdiag" + sk
    pole_pervich := "mpervich" + sk
    pole_1pervich := "m1pervich" + sk
    pole_stadia := "mstadia" + sk
    pole_1stadia := "m1stadia" + sk
    pole_dispans := "mdispans" + sk
    pole_1dispans := "m1dispans" + sk
    pole_dop := "mdop" + sk
    pole_gde := "mgde" + sk
    pole_1dop := "m1dop" + sk
    pole_usl := "musl" + sk
    pole_1usl := "m1usl" + sk
    pole_san := "msan" + sk
    pole_1san := "m1san" + sk
    Private &pole_diag := Space( 6 )
    Private &pole_pervich := Space( 7 )
    Private &pole_1pervich := 0
    Private &pole_stadia := Space( 6 )
    Private &pole_1stadia := 0
    Private &pole_dispans := Space( 10 )
    Private &pole_1dispans := 0
    Private &pole_dop := Space( 9 )
    Private &pole_1dop := 0
    Private &pole_gde := Space( 4 )
    Private &pole_usl := Space( 9 )
    Private &pole_1usl := 0
    Private &pole_san := Space( 3 )
    Private &pole_1san := 0
  Next
  For i := 1 To count_dvn_arr_usl13
    mvar := "MTAB_NOMv" + lstr( i )
    Private &mvar := 0
    mvar := "MTAB_NOMa" + lstr( i )
    Private &mvar := 0
    mvar := "MDATE" + lstr( i )
    Private &mvar := CToD( "" )
    mvar := "MKOD_DIAG" + lstr( i )
    Private &mvar := Space( 6 )
    mvar := "MOTKAZ" + lstr( i )
    Private &mvar := mm_otkaz[ 1, 1 ]
    mvar := "M1OTKAZ" + lstr( i )
    Private &mvar := mm_otkaz[ 1, 2 ]
  Next
  //
  AFill( adiag_talon, 0 )
  r_use( dir_server + "human_2",, "HUMAN_2" )
  r_use( dir_server + "human_",, "HUMAN_" )
  r_use( dir_server + "human",, "HUMAN" )
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2
  If mkod_k > 0
    r_use( dir_server + "kartote2",, "KART2" )
    Goto ( mkod_k )
    r_use( dir_server + "kartote_",, "KART_" )
    Goto ( mkod_k )
    r_use( dir_server + "kartotek",, "KART" )
    Goto ( mkod_k )
    M1FIO       := 1
    mfio        := kart->fio
    mpol        := kart->pol
    mdate_r     := kart->date_r
    M1VZROS_REB := kart->VZROS_REB
    mADRES      := kart->ADRES
    mMR_DOL     := kart->MR_DOL
    m1RAB_NERAB := kart->RAB_NERAB
    mPOLIS      := kart->POLIS
    m1VIDPOLIS  := kart_->VPOLIS
    mSPOLIS     := kart_->SPOLIS
    mNPOLIS     := kart_->NPOLIS
    m1okato     := kart_->KVARTAL_D    // ����� ��ꥪ� �� ����ਨ ���客����
    msmo        := kart_->SMO
    m1MO_PR     := kart2->MO_PR
    If kart->MI_GIT == 9
      m1komu    := kart->KOMU
      m1str_crb := kart->STR_CRB
    Endif
    If eq_any( is_uchastok, 1, 3 )
      MUCH_DOC := PadR( amb_kartan(), 10 )
    Elseif mem_kodkrt == 2
      MUCH_DOC := PadR( lstr( mkod_k ), 10 )
    Endif
    If AllTrim( msmo ) == '34'
      mnameismo := ret_inogsmo_name( 1,, .t. ) // ������ � �������
    Endif
    // �஢�ઠ ��室� = ������
    Select HUMAN
    Set Index to ( dir_server + "humankk" )
    find ( Str( mkod_k, 7 ) )
    Do While human->kod_k == mkod_k .and. !Eof()
      If human_->oplata != 9 .and. human_->NOVOR == 0
        If RecNo() != Loc_kod .and. is_death( human_->RSLT_NEW ) .and. Empty( a_smert )
          a_smert := { "����� ���쭮� 㬥�!", ;
            "��祭�� � " + full_date( human->N_DATA ) + ;
            " �� " + full_date( human->K_DATA ) }
        Endif
        If Loc_kod == 0 .and. Between( human->ishod, 201, 203 )
          M1RAB_NERAB := human->RAB_NERAB // 0-ࠡ���騩, 1-��ࠡ���騩, 2-������.����
          read_arr_dvn( human->kod, .f. )
        Endif
      Endif
      Select HUMAN
      Skip
    Enddo
    Set Index To
  Endif
  If Empty( mWEIGHT )
    mWEIGHT := iif( mpol == "�", 70, 55 )   // ��� � ��
  Endif
  If Empty( mHEIGHT )
    mHEIGHT := iif( mpol == "�", 170, 160 )  // ��� � �
  Endif
  If Empty( mOKR_TALII )
    mOKR_TALII := iif( mpol == "�", 94, 80 ) // ���㦭���� ⠫�� � �
  Endif
  If Loc_kod > 0
    Select HUMAN
    Goto ( Loc_kod )
    M1LPU       := human->LPU
    M1OTD       := human->OTD
    M1FIO       := 1
    mfio        := human->fio
    mpol        := human->pol
    mdate_r     := human->date_r
    MTIP_H      := human->tip_h
    M1VZROS_REB := human->VZROS_REB
    MADRES      := human->ADRES         // ���� ���쭮��
    MMR_DOL     := human->MR_DOL        // ���� ࠡ��� ��� ��稭� ���ࠡ�⭮��
    M1RAB_NERAB := human->RAB_NERAB     // 0-ࠡ���騩, 1-��ࠡ���騩, 2-������.����
    mUCH_DOC    := human->uch_doc
    m1VRACH     := human_->vrach
    MKOD_DIAG0  := human_->KOD_DIAG0
    MKOD_DIAG   := human->KOD_DIAG
    MKOD_DIAG2  := human->KOD_DIAG2
    MKOD_DIAG3  := human->KOD_DIAG3
    MKOD_DIAG4  := human->KOD_DIAG4
    MSOPUT_B1   := human->SOPUT_B1
    MSOPUT_B2   := human->SOPUT_B2
    MSOPUT_B3   := human->SOPUT_B3
    MSOPUT_B4   := human->SOPUT_B4
    MDIAG_PLUS  := human->DIAG_PLUS
    MPOLIS      := human->POLIS         // ��� � ����� ���客��� �����
    For i := 1 To 16
      adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
    Next
    m1VIDPOLIS  := human_->VPOLIS
    mSPOLIS     := human_->SPOLIS
    mNPOLIS     := human_->NPOLIS
    If Empty( Val( msmo := human_->SMO ) )
      m1komu := human->KOMU
      m1str_crb := human->STR_CRB
    Else
      m1komu := m1str_crb := 0
    Endif
    m1okato    := human_->OKATO  // ����� ��ꥪ� �� ����ਨ ���客����
    mn_data    := human->N_DATA
    mk_data    := human->K_DATA
    mcena_1    := human->CENA_1
    If ( metap := human->ishod - 200 ) == 3 // ��䨫��⨪�
      m1GRUPPA := human_->RSLT_NEW - P_BEGIN_RSLT
    Elseif human_->RSLT_NEW > D_BEGIN_RSLT2 // ���ࠢ��� �� II �⠯
      m1GRUPPA := human_->RSLT_NEW - D_BEGIN_RSLT2 + 10
    Else // ��ᯠ��ਧ��� I ��� II �⠯
      m1GRUPPA := human_->RSLT_NEW - D_BEGIN_RSLT
      If Between( human_->RSLT_NEW, 318, 319 ) .and. human_2->PN1 == 1
        // ���塞 १���� ��祭�� � 11 ������ 2014 ���� - ���ࠢ��� �� II �⠯
        m1GRUPPA := human_->RSLT_NEW - D_BEGIN_RSLT + 10
      Endif
    Endif
    //
    larr := Array( 2, count_dvn_arr_usl13 ) ; afillall( larr, 0 )
    r_use( dir_server + "uslugi",, "USL" )
    use_base( "human_u" )
    find ( Str( Loc_kod, 7 ) )
    Do While hu->kod == Loc_kod .and. !Eof()
      usl->( dbGoto( hu->u_kod ) )
      If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, mk_data ) )
        lshifr := usl->shifr
      Endif
      lshifr := AllTrim( lshifr )
      If eq_any( Left( lshifr, 5 ), "70.3.", "72.1." )
        mshifr_zs := lshifr
      Else
        fl := .t.
        If lshifr == "2.3.3" .and. hu_->PROFIL == 3 ; // �����᪮�� ����
          .and. ( i := AScan( dvn_arr_usl13, {| x| ValType( x[ 2 ] ) == "C" .and. x[ 2 ] == "4.20.1" } ) ) > 0
          fl := .f. ; larr[ 1, i ] := hu->( RecNo() )
        Endif
        If fl
          For i := 1 To count_dvn_arr_umolch13
            If Empty( larr[ 2, i ] ) .and. dvn_arr_umolch13[ i, 2 ] == lshifr
              fl := .f. ; larr[ 2, i ] := hu->( RecNo() ) ; Exit
            Endif
          Next
        Endif
        If fl
          For i := 1 To count_dvn_arr_usl13
            If Empty( larr[ 1, i ] )
              If ValType( dvn_arr_usl13[ i, 2 ] ) == "C"
                If dvn_arr_usl13[ i, 2 ] == lshifr
                  fl := .f.
                Endif
              Elseif Len( dvn_arr_usl13[ i ] ) > 11
                If AScan( dvn_arr_usl13[ i, 12 ], {| x| x[ 1 ] == lshifr .and. x[ 2 ] == hu_->PROFIL } ) > 0
                  fl := .f.
                Endif
              Endif
              If !fl
                larr[ 1, i ] := hu->( RecNo() ) ; Exit
              Endif
            Endif
          Next
        Endif
        If fl
          n_message( { "�����४⭠� ����ன�� � �ࠢ�筨�� ���:", ;
            AllTrim( usl->name ), ;
            "��� ��㣨 � �ࠢ�筨�� " + usl->shifr, ;
            "��� ����� - " + opr_shifr_tfoms( usl->shifr1, usl->kod, mk_data ) },, ;
            "GR+/R", "W+/R",,, "G+/R" )
        Endif
      Endif
      AAdd( arr_usl, hu->( RecNo() ) )
      Select HU
      Skip
    Enddo
    r_use( dir_server + "mo_pers",, "P2" )
    For i := 1 To count_dvn_arr_usl13
      If !Empty( larr[ 1, i ] )
        hu->( dbGoto( larr[ 1, i ] ) )
        If hu->kod_vr > 0
          p2->( dbGoto( hu->kod_vr ) )
          mvar := "MTAB_NOMv" + lstr( i )
          &mvar := p2->tab_nom
        Endif
        If hu->kod_as > 0
          p2->( dbGoto( hu->kod_as ) )
          mvar := "MTAB_NOMa" + lstr( i )
          &mvar := p2->tab_nom
        Endif
        mvar := "MDATE" + lstr( i )
        &mvar := c4tod( hu->date_u )
        If !Empty( hu_->kod_diag ) .and. !( Left( hu_->kod_diag, 1 ) == "Z" )
          mvar := "MKOD_DIAG" + lstr( i )
          &mvar := hu_->kod_diag
        Endif
        m1var := "M1OTKAZ" + lstr( i )
        If hu_->PROFIL == 3 .and. ;
            ValType( dvn_arr_usl13[ i, 2 ] ) == "C" .and. dvn_arr_usl13[ i, 2 ] == "4.20.1"
          &m1var := 2 // ������������� �믮������
        Endif
        mvar := "MOTKAZ" + lstr( i )
        &mvar := inieditspr( A__MENUVERT, mm_otkaz, &m1var )
      Endif
    Next
    If AllTrim( msmo ) == '34'
      mnameismo := ret_inogsmo_name( 2, @rec_inogSMO, .t. ) // ������ � �������
    Endif
    read_arr_dvn( Loc_kod )
    If ValType( arr_usl_otkaz ) == "A"
      For j := 1 To Len( arr_usl_otkaz )
        ar := arr_usl_otkaz[ j ]
        If ValType( ar ) == "A" .and. Len( ar ) >= 5 .and. ValType( ar[ 5 ] ) == "C"
          lshifr := AllTrim( ar[ 5 ] )
          If ( i := AScan( dvn_arr_usl13, {| x| ValType( x[ 2 ] ) == "C" .and. x[ 2 ] == lshifr } ) ) > 0
            If ValType( ar[ 1 ] ) == "N" .and. ar[ 1 ] > 0
              p2->( dbGoto( ar[ 1 ] ) )
              mvar := "MTAB_NOMv" + lstr( i )
              &mvar := p2->tab_nom
            Endif
            If ValType( ar[ 3 ] ) == "N" .and. ar[ 3 ] > 0
              p2->( dbGoto( ar[ 3 ] ) )
              mvar := "MTAB_NOMa" + lstr( i )
              &mvar := p2->tab_nom
            Endif
            mvar := "MDATE" + lstr( i )
            &mvar := mn_data
            If Len( ar ) >= 9 .and. ValType( ar[ 9 ] ) == "D"
              &mvar := ar[ 9 ]
            Endif
            m1var := "M1OTKAZ" + lstr( i )
            &m1var := 1
            If Len( ar ) >= 10 .and. ValType( ar[ 10 ] ) == "N" .and. Between( ar[ 10 ], 1, 2 )
              &m1var := ar[ 10 ]
            Endif
            mvar := "MOTKAZ" + lstr( i )
            &mvar := inieditspr( A__MENUVERT, mm_otkaz, &m1var )
          Endif
        Endif
      Next
    Endif
    For i := 1 To 5
      f_valid_diag_oms_sluch_dvn13(, i )
    Next
  Endif
  If !( Left( msmo, 2 ) == '34' ) // �� ������ࠤ᪠� �������
    m1ismo := msmo ; msmo := '34'
  Endif
  is_talon := .t.
  Close databases
  fv_date_r( iif( Loc_kod > 0, mn_data, ) )
  MFIO_KART := _f_fio_kart()
  mndisp    := inieditspr( A__MENUVERT, mm_ndisp, metap )
  mrab_nerab := inieditspr( A__MENUVERT, menu_rab, m1rab_nerab )
  mvzros_reb := inieditspr( A__MENUVERT, menu_vzros, m1vzros_reb )
  mlpu      := inieditspr( A__POPUPMENU, dir_server + "mo_uch", m1lpu )
  motd      := inieditspr( A__POPUPMENU, dir_server + "mo_otd", m1otd )
  mvidpolis := inieditspr( A__MENUVERT, mm_vid_polis, m1vidpolis )
  mokato    := inieditspr( A__MENUVERT, glob_array_srf, m1okato )
  mkomu     := inieditspr( A__MENUVERT, mm_komu, m1komu )
  mismo     := init_ismo( m1ismo )
  f_valid_komu(, -1 )
  If m1komu == 0
    m1company := Int( Val( msmo ) )
  Elseif eq_any( m1komu, 1, 3 )
    m1company := m1str_crb
  Endif
  mcompany := inieditspr( A__MENUVERT, mm_company, m1company )
  If m1company == 34
    If !Empty( mismo )
      mcompany := PadR( mismo, 38 )
    Elseif !Empty( mnameismo )
      mcompany := PadR( mnameismo, 38 )
    Endif
  Endif
  mveteran := inieditspr( A__MENUVERT, mm_danet, m1veteran )
  mmobilbr := inieditspr( A__MENUVERT, mm_danet, m1mobilbr )
  mgruppa  := inieditspr( A__MENUVERT, mm_gruppaD, m1gruppa )
  mkurenie := inieditspr( A__MENUVERT, mm_danet, m1kurenie )
  mriskalk := inieditspr( A__MENUVERT, mm_danet, m1riskalk )
  mpod_alk := inieditspr( A__MENUVERT, mm_danet, m1pod_alk )
  If m1pod_alk == 0 ; m1psih_na := 0 ; Endif
  mpsih_na := inieditspr( A__MENUVERT, mm_danet, m1psih_na )
  mfiz_akt := inieditspr( A__MENUVERT, mm_danet, m1fiz_akt )
  mner_pit := inieditspr( A__MENUVERT, mm_danet, m1ner_pit )
  maddn    := inieditspr( A__MENUVERT, mm_danet, m1addn )
  mholestdn := inieditspr( A__MENUVERT, mm_danet, m1holestdn )
  mglukozadn := inieditspr( A__MENUVERT, mm_danet, m1glukozadn )
  mtip_mas := ret_tip_mas( mWEIGHT, mHEIGHT, @m1tip_mas )
  mprof_ko := inieditspr( A__MENUVERT, mm_prof_ko, m1prof_ko )
  ret_ndisp( Loc_kod, kod_kartotek )
  //
  If !Empty( f_print )
    return &( f_print + "(" + lstr( Loc_kod ) + "," + lstr( kod_kartotek ) + ")" )
  Endif
  //
  str_1 := " ���� ��ᯠ��ਧ�樨/���ᬮ�� ���᫮�� ��ᥫ����"
  If Loc_kod == 0
    str_1 := "����������" + str_1
    mtip_h := yes_vypisan
  Else
    str_1 := "������஢����" + str_1
  Endif
  SetColor( color8 )
  @ 0, 0 Say PadC( str_1, 80 ) Color "B/BG*"
  Private gl_area := { 1, 0, MaxRow() -1, MaxCol(), 0 }
  SetColor( cDataCGet )
  make_diagp( 1 )  // ᤥ���� "��⨧����" ��������
  Private num_screen := 1
  Do While .t.
    Close databases
    j := 1
    myclear( j )
    If yes_num_lu == 1 .and. Loc_kod > 0
      @ j, 50 Say PadL( "���� ��� � " + lstr( Loc_kod ), 29 ) Color color14
    Endif
    @ j, 0 Say "��࠭ " + lstr( num_screen ) Color color8
    If num_screen > 1
      s := AllTrim( mfio ) + " (" + lstr( mvozrast ) + " " + s_let( mvozrast ) + ")"
      @ j, 80 -Len( s ) Say s Color color14
    Endif
    If num_screen == 1
      // ++j; @ j,1 say "��०�����" get mlpu when .f. color cDataCSay
      // @ row(),col()+2 say "�⤥�����" get motd when .f. color cDataCSay
      //
      ++j; @ j, 1 Say "���" Get mfio_kart ;
        reader {| x| menu_reader( x, { {| k, r, c| get_fio_kart( k, r, c ) } }, A__FUNCTION,,, .f. ) } ;
        valid {| g, o| update_get( "mdate_r" ), ;
        update_get( "mkomu" ), update_get( "mcompany" ) }
      @ Row(), Col() + 5 Say "�.�." Get mdate_r When .f. Color color14
      ++j; @ j, 1 Say " ������騩?" Get mrab_nerab ;
        reader {| x| menu_reader( x, menu_rab, A__MENUVERT,,, .f. ) }
      @ j, 40 Say "���࠭ ��� (���������)?" Get mveteran ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) }
      ++j; @ j, 1 Say " �ਭ���������� ����" Get mkomu ;
        reader {| x| menu_reader( x, mm_komu, A__MENUVERT,,, .f. ) } ;
        valid {| g, o| f_valid_komu( g, o ) } ;
        Color colget_menu
      @ Row(), Col() + 1 Say "==>" Get mcompany ;
        reader {| x| menu_reader( x, mm_company, A__MENUVERT,,, .f. ) } ;
        When m1komu < 5 ;
        valid {| g| func_valid_ismo( g, m1komu, 38 ) }
      ++j; @ j, 1 Say " ����� ���: ���" Get mspolis When m1komu == 0
      @ Row(), Col() + 3 Say "�����"  Get mnpolis When m1komu == 0
      @ Row(), Col() + 3 Say "���"    Get mvidpolis ;
        reader {| x| menu_reader( x, mm_vid_polis, A__MENUVERT,,, .f. ) } ;
        When m1komu == 0 ;
        Valid func_valid_polis( m1vidpolis, mspolis, mnpolis )
      //
      ++j; @ j, 1 Say "�ப�" Get mn_data ;
        valid {| g| f_k_data( g, 1 ), ;
        iif( mvozrast < 18, func_error( 4, "�� �� ����� ��樥��!" ), nil ), ;
        ret_ndisp( Loc_kod, kod_kartotek ) ;
        }
      @ Row(), Col() + 1 Say "-"   Get mk_data valid {| g| f_k_data( g, 2 ) }
      @ Row(), Col() + 7 Get mndisp When .f. Color color14
      ++j; @ j, 1 Say "� ���㫠�୮� �����" Get much_doc Picture "@!" ;
        When !( is_uchastok == 1 .and. is_task( X_REGIST ) ) ;
        .or. mem_edit_ist == 2
      @ j, Col() + 5 Say "�����쭠� �ਣ���?" Get mmobilbr ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) }
      ++j; @ j, 1 Say "��७��" Get mkurenie ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) }
      @ j, 15 Say "����⭮ ���㡭�� ���ॡ����� ��������" Get mriskalk ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) }
      ++j; @ j, 1 Say " ����ᨬ���� �� ��������/��મ⨪��" Get mpod_alk ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) }
      @ j, Col() + 2 Say "���ࠢ��� � ��娠���/��મ����" Get mpsih_na ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) }
      ++j; @ j, 1 Say " ������ 䨧��᪠� ��⨢�����" Get mfiz_akt ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) }
      @ j, Col() + 5 Say "���樮���쭮� ��⠭��" Get mner_pit ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) }
      ++j; @ j, 1 Say "���" Get mWEIGHT Pict "999" ;
        valid {|| iif( Between( mWEIGHT, 30, 200 ),, func_error( 4, "��ࠧ㬭� ���" ) ), ;
        mtip_mas := ret_tip_mas( mWEIGHT, mHEIGHT ), ;
        update_get( "mtip_mas" ) }
      @ Row(), Col() + 1 Say "��, ���" Get mHEIGHT Pict "999" ;
        valid {|| iif( Between( mHEIGHT, 40, 250 ),, func_error( 4, "��ࠧ㬭� ���" ) ), ;
        mtip_mas := ret_tip_mas( mWEIGHT, mHEIGHT ), ;
        update_get( "mtip_mas" ) }
      @ Row(), Col() + 1 Say "�, ���㦭���� ⠫��" Get mOKR_TALII  Pict "999" ;
        valid {|| iif( Between( mOKR_TALII, 40, 200 ),, func_error( 4, "��ࠧ㬭�� ���祭�� ���㦭��� ⠫��" ) ), .t. }
      @ Row(), Col() + 1 Say "�"
      @ Row(), Col() + 5 Get mtip_mas Color color14 When .f.
      ++j; @ j, 1 Say " ���ਠ�쭮� ��������" Get mad1 Pict "999" ;
        valid {|| iif( Between( mad1, 60, 220 ),, func_error( 4, "��ࠧ㬭�� ��������" ) ), .t. }
      @ Row(), Col() Say "/" Get mad2 Pict "999";
        valid {|| iif( Between( mad1, 40, 180 ),, func_error( 4, "��ࠧ㬭�� ��������" ) ), ;
        iif( mad1 > mad2,, func_error( 4, "��ࠧ㬭�� ��������" ) ), ;
        .t. }
      @ Row(), Col() + 1 Say "�� ��.��.    ����⥭������ �࠯��" Get maddn ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) }
      ++j; @ j, 1 Say " ��騩 宫���ਭ" Get mholest Pict "99.99" ;
        valid {|| iif( Empty( mholest ) .or. Between( mholest, 3, 8 ),, func_error( 4, "��ࠧ㬭�� ���祭�� 宫���ਭ�" ) ), .t. }
      @ Row(), Col() + 1 Say "�����/�     �������������᪠� �࠯��" Get mholestdn ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) }
      ++j; @ j, 1 Say " ����" Get mglukoza Pict "99.99" ;
        valid {|| iif( Empty( mglukoza ) .or. Between( mglukoza, 2.2, 25 ),, func_error( 4, "����᪮� ���祭�� ����" ) ), .t. }
      @ Row(), Col() + 1 Say "�����/�     ������������᪠� �࠯��" Get mglukozadn ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) }
      ++j; @ j, 1 Say "������������������������������������������������������������������������������"
      ++j; @ j, 1 Say "���������������⠤�ﳤ��.����.��ॡ�� ���.��祭�ﳭ㦤. � ᠭ.-���. ���-�"
      ++j; @ j, 1 Say "������������������������������������������������������������������������������"
      // 1       9        18     25         36        46        56
      ++j; @ j, 1  Get mdiag1 Picture pic_diag ;
        reader {| o| mygetreader( o, bg ) } ;
        valid  {| g| iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
        f_valid_diag_oms_sluch_dvn13( g, 1 ), ;
        .f. ) }
      @ j, 9  Get mpervich1 ;
        reader {| x| menu_reader( x, mm_pervich, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag1 )
      @ j, 18 Get mstadia1 ;
        reader {| x| menu_reader( x, mm_stadia, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag1 )
      @ j, 25 Get mdispans1 ;
        reader {| x| menu_reader( x, mm_dispans, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag1 )
      @ j, 36 Get mdop1 ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag1 ) ;
        valid  {| g| f_valid_diag_oms_sluch_dvn13( g, 1 ) }
      @ j, 40 Get mgde1 Color color1 When .f.
      @ j, 46 Get musl1 ;
        reader {| x| menu_reader( x, mm_usl, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag1 ) .and. m1dop1 == 1
      @ j, 56 Get msan1 ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag1 )
      //
      ++j; @ j, 1  Get mdiag2 Picture pic_diag ;
        reader {| o| mygetreader( o, bg ) } ;
        valid  {| g| iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
        f_valid_diag_oms_sluch_dvn13( g, 2 ), ;
        .f. ) }
      @ j, 9  Get mpervich2 ;
        reader {| x| menu_reader( x, mm_pervich, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag2 )
      @ j, 18 Get mstadia2 ;
        reader {| x| menu_reader( x, mm_stadia, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag2 )
      @ j, 25 Get mdispans2 ;
        reader {| x| menu_reader( x, mm_dispans, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag2 )
      @ j, 36 Get mdop2 ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag2 ) ;
        valid  {| g| f_valid_diag_oms_sluch_dvn13( g, 2 ) }
      @ j, 40 Get mgde2 Color color1 When .f.
      @ j, 46 Get musl2 ;
        reader {| x| menu_reader( x, mm_usl, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag2 ) .and. m1dop2 == 1
      @ j, 56 Get msan2 ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag2 )
      //
      ++j; @ j, 1  Get mdiag3 Picture pic_diag ;
        reader {| o| mygetreader( o, bg ) } ;
        valid  {| g| iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
        f_valid_diag_oms_sluch_dvn13( g, 3 ), ;
        .f. ) }
      @ j, 9  Get mpervich3 ;
        reader {| x| menu_reader( x, mm_pervich, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag3 )
      @ j, 18 Get mstadia3 ;
        reader {| x| menu_reader( x, mm_stadia, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag3 )
      @ j, 25 Get mdispans3 ;
        reader {| x| menu_reader( x, mm_dispans, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag3 )
      @ j, 36 Get mdop3 ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag3 ) ;
        valid  {| g| f_valid_diag_oms_sluch_dvn13( g, 3 ) }
      @ j, 40 Get mgde3 Color color1 When .f.
      @ j, 46 Get musl3 ;
        reader {| x| menu_reader( x, mm_usl, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag3 ) .and. m1dop3 == 1
      @ j, 56 Get msan3 ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag3 )
      //
      ++j; @ j, 1  Get mdiag4 Picture pic_diag ;
        reader {| o| mygetreader( o, bg ) } ;
        valid  {| g| iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
        f_valid_diag_oms_sluch_dvn13( g, 4 ), ;
        .f. ) }
      @ j, 9  Get mpervich4 ;
        reader {| x| menu_reader( x, mm_pervich, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag4 )
      @ j, 18 Get mstadia4 ;
        reader {| x| menu_reader( x, mm_stadia, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag4 )
      @ j, 25 Get mdispans4 ;
        reader {| x| menu_reader( x, mm_dispans, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag4 )
      @ j, 36 Get mdop4 ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag4 ) ;
        valid  {| g| f_valid_diag_oms_sluch_dvn13( g, 4 ) }
      @ j, 40 Get mgde4 Color color1 When .f.
      @ j, 46 Get musl4 ;
        reader {| x| menu_reader( x, mm_usl, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag4 ) .and. m1dop4 == 1
      @ j, 56 Get msan4 ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag4 )
      //
      ++j; @ j, 1  Get mdiag5 Picture pic_diag ;
        reader {| o| mygetreader( o, bg ) } ;
        valid  {| g| iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
        f_valid_diag_oms_sluch_dvn13( g, 5 ), ;
        .f. ) }
      @ j, 9  Get mpervich5 ;
        reader {| x| menu_reader( x, mm_pervich, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag5 )
      @ j, 18 Get mstadia5 ;
        reader {| x| menu_reader( x, mm_stadia, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag5 )
      @ j, 25 Get mdispans5 ;
        reader {| x| menu_reader( x, mm_dispans, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag5 )
      @ j, 36 Get mdop5 ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag5 ) ;
        valid  {| g| f_valid_diag_oms_sluch_dvn13( g, 5 ) }
      @ j, 40 Get mgde5 Color color1 When .f.
      @ j, 46 Get musl5 ;
        reader {| x| menu_reader( x, mm_usl, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag5 ) .and. m1dop5 == 1
      @ j, 56 Get msan5 ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
        When !Empty( mdiag5 )
      //
      ++j; @ j, 1 Say "��������������������������������������� �㬬��� �थ筮-��㤨��� ��" Get mssr Pict "99" ;
        valid {|| iif( Between( mssr, 0, 47 ),, func_error( 4, "��ࠧ㬭�� ���祭�� �㬬�୮�� �थ筮-��㤨�⮣� �᪠" ) ), .t. }
      @ Row(), Col() Say "%"
      status_key( "^<Esc>^ ��室 ��� ����� ^<PgDn>^ �� 2-� ��࠭���" )
      If !Empty( a_smert )
        n_message( a_smert,, "GR+/R", "W+/R",,, "G+/R" )
      Endif
    Elseif num_screen == 2
      ret_ndisp( Loc_kod, kod_kartotek )
      ++j; @ j, 8 Get mndisp When .f. Color color14
      If mvozrast != mdvozrast
        s := "(� " + lstr( Year( mn_data ) ) + " ���� �ᯮ������ " + lstr( mdvozrast ) + " " + s_let( mdvozrast ) + ")"
        @ j, 80 -Len( s ) Say s Color color14
      Endif
      ++j; @ j, 1 Say "�������������������������������������������������������������������" + iif( metap == 2, "", "�����������" ) Color color8
      ++j; @ j, 1 Say "������������ ��᫥�������                   ���� ����᳤�� ���" + iif( metap == 2, "", "��믮������" ) Color color8
      ++j; @ j, 1 Say "�������������������������������������������������������������������" + iif( metap == 2, "", "�����������" ) Color color8
      If mem_por_ass == 0
        @ j - 1, 52 Say Space( 5 )
      Endif
      fl_vrach := .t.
      For i := 1 To count_dvn_arr_usl13
        fl_diag := .f.
        i_otkaz := 0
        If f_is_usl_oms_sluch_dvn13( i, metap, iif( metap == 3, mvozrast, mdvozrast ), mpol, ;
            @fl_diag, @i_otkaz )
          If fl_diag .and. fl_vrach
            ++j; @ j, 1 Say "������������������������������������������������������������������������������" Color color8
            ++j; @ j, 1 Say "������������ �ᬮ�஢                       ���� ����᳤�� ��㣳�������   " Color color8
            ++j; @ j, 1 Say "������������������������������������������������������������������������������" Color color8
            If mem_por_ass == 0
              @ j - 1, 52 Say Space( 5 )
            Endif
            fl_vrach := .f.
          Endif
          mvarv := "MTAB_NOMv" + lstr( i )
          mvara := "MTAB_NOMa" + lstr( i )
          mvard := "MDATE" + lstr( i )
          If Empty( &mvard )
            &mvard := mn_data
          Endif
          mvarz := "MKOD_DIAG" + lstr( i )
          mvaro := "MOTKAZ" + lstr( i )
          ++j; @ j, 1 Say dvn_arr_usl13[ i, 1 ]
          @ j, 46 get &mvarv Pict "99999" valid {| g| v_kart_vrach( g ) }
          If mem_por_ass > 0
            @ j, 52 get &mvara Pict "99999" valid {| g| v_kart_vrach( g ) }
          Endif
          @ j, 58 get &mvard
          If fl_diag
            @ j, 69 get &mvarz Picture pic_diag ;
              reader {| o| mygetreader( o, bg ) } Valid val1_10diag( .t., .f., .f., mn_data, mpol )
          Elseif i_otkaz == 1
            @ j, 69 get &mvaro ;
              reader {| x| menu_reader( x, mm_otkaz1, A__MENUVERT,,, .f. ) }
          Elseif eq_any( i_otkaz, 2, 3 )
            @ j, 69 get &mvaro ;
              reader {| x| menu_reader( x, mm_otkaz, A__MENUVERT,,, .f. ) }
          Endif
        Endif
      Next
      ++j; @ j, 1 Say Replicate( "�", 78 ) Color color8
      If metap == 2
        ++j; @ j, 1 Say "��䨫����᪮� �������஢����" Get mprof_ko ;
          reader {| x| menu_reader( x, mm_prof_ko, A__MENUVERT,,, .f. ) }
      Endif
      ++j; @ j, 1 Say "������ ���ﭨ� ��������"
      @ j, Col() + 1 Get mGRUPPA ;
        reader {| x| menu_reader( x, iif( metap == 1, mm_gruppaD, mm_gruppaP ), A__MENUVERT,,, .f. ) }
      status_key( "^<Esc>^ ��室 ��� ����� ^<PgUp>^ �� 1-� ��࠭��� ^<PgDn>^ ������" )
    Endif
    count_edit += myread()
    If num_screen == 2
      If LastKey() == K_PGUP
        k := 3
        --num_screen
      Else
        k := f_alert( { PadC( "�롥�� ����⢨�", 60, "." ) }, ;
          { " ��室 ��� ����� ", " ������ ", " ������ � ।���஢���� " }, ;
          iif( LastKey() == K_ESC, 1, 2 ), "W+/N", "N+/N", MaxRow() -2,, "W+/N,N/BG" )
      Endif
    Else
      If LastKey() == K_PGUP
        k := 3
        If num_screen > 1
          --num_screen
        Endif
      Elseif LastKey() == K_ESC
        If ( k := f_alert( { PadC( "�롥�� ����⢨�", 60, "." ) }, ;
            { " ��室 ��� ����� ", " ������ � ।���஢���� " }, ;
            1, "W+/N", "N+/N", MaxRow() -2,, "W+/N,N/BG" ) ) == 2
          k := 3
        Endif
      Else
        k := 3
        ++num_screen
        If mvozrast < 18
          num_screen := 1
          func_error( 4, "�� �� ����� ��樥��!" )
        Elseif metap == 0
          num_screen := 1
          func_error( 4, "�஢���� �ப� ��祭��!" )
        Endif
      Endif
    Endif
    If k == 3
      Loop
    Elseif k == 2
      num_screen := 1
      If m1komu < 5 .and. Empty( m1company )
        If m1komu == 0     ; s := "���"
        Elseif m1komu == 1 ; s := "��������"
        else               ; s := "������/��"
        Endif
        func_error( 4, '�� ��������� ������������ ' + s )
        Loop
      Endif
      If m1komu == 0 .and. Empty( mnpolis )
        func_error( 4, '�� �������� ����� �����' )
        Loop
      Endif
      If Empty( mn_data )
        func_error( 4, "�� ������� ��� ��砫� ��祭��." )
        Loop
      Endif
      If mvozrast < 18
        func_error( 4, "��䨫��⨪� ������� �� ���᫮�� ��樥���!" )
        Loop
      Endif
      If Empty( mk_data )
        func_error( 4, "�� ������� ��� ����砭�� ��祭��." )
        Loop
      Elseif mk_data < SToD( "20130601" )
        func_error( 4, "��� ����砭�� ��祭�� �� ������ ���� ࠭�� 1 ��� 2013 ����" )
        Loop
      Elseif mk_data > SToD( "20150331" )
        func_error( 4, "��� ����砭�� ��祭�� �� ������ ���� ����� 31 ���� 2015 ����" )
        Loop
      Endif
      If Empty( CharRepl( "0", much_doc, Space( 10 ) ) )
        func_error( 4, '�� �������� ����� ���㫠�୮� �����' )
        Loop
      Endif
      If Empty( mWEIGHT )
        func_error( 4, "�� ����� ���." )
        Loop
      Endif
      If Empty( mHEIGHT )
        func_error( 4, "�� ����� ���." )
        Loop
      Endif
      If Empty( mOKR_TALII )
        func_error( 4, "�� ������� ���㦭���� ⠫��." )
        Loop
      Endif
      If m1veteran == 1
        If metap == 3
          func_error( 4, "��䨫��⨪� ������ �� �஢���� ���࠭�� ��� (�����������)" )
          Loop
          // elseif M1RAB_NERAB == 2 // 2-��㤥��
          // func_error(4,"��㤥�� �� ����� ���� ���࠭�� ��� (�����������)")
          // loop
          // elseif year(mdate_r) > 1945
          // func_error(4,"���誮� ������� ���࠭ ��� (���������)")
          // loop
        Endif
      Endif
      //
      mdef_diagnoz := iif( metap == 2, "Z01.8 ", "Z00.8 " )
      r_use( dir_exe + "_mo_mkb", cur_dir + "_mo_mkb", "MKB_10" )
      r_use( dir_server + "mo_pers", dir_server + "mo_pers", "P2" )
      num_screen := 2
      max_date1 := mn_data
      fl := .t.
      k := ku := 0
      arr_osm1 := Array( count_dvn_arr_usl13, 10 ) ; afillall( arr_osm1, 0 )
      For i := 1 To count_dvn_arr_usl13
        fl_diag := fl_ekg := .f.
        i_otkaz := 0
        If f_is_usl_oms_sluch_dvn13( i, metap, iif( metap == 3, mvozrast, mdvozrast ), mpol, ;
            @fl_diag, @i_otkaz, @fl_ekg )
          mvart := "MTAB_NOMv" + lstr( i )
          If Empty( &mvart ) .and. ( metap == 2 .or. fl_ekg ) // ���, �� ����� ���
            Loop                                        // � ����易⥫�� ������
          Endif
          mvara := "MTAB_NOMa" + lstr( i )
          mvard := "MDATE" + lstr( i )
          mvarz := "MKOD_DIAG" + lstr( i )
          mvaro := "M1OTKAZ" + lstr( i )
          if &mvard == mn_data
            k := i
          Endif
          ar := dvn_arr_usl13[ i ]
          If i_otkaz == 2 .and. &mvaro == 2 // �᫨ ��᫥������� ����������
            arr_osm1[ i, 5 ] := ar[ 2 ] // ��� ��㣨
            arr_osm1[ i, 9 ] := iif( Empty( &mvard ), mn_data, &mvard )
            arr_osm1[ i, 10 ] := &mvaro
          Elseif Empty( &mvard )
            fl := func_error( 4, '�� ������� ��� ��㣨 "' + LTrim( ar[ 1 ] ) + '"' )
          Elseif Empty( &mvart )
            fl := func_error( 4, '�� ������ ��� � ��㣥 "' + LTrim( ar[ 1 ] ) + '"' )
          Else
            Select P2
            find ( Str( &mvart, 5 ) )
            If Found()
              arr_osm1[ i, 1 ] := p2->kod
              arr_osm1[ i, 2 ] := p2->prvs
            Endif
            If !Empty( &mvara )
              Select P2
              find ( Str( &mvara, 5 ) )
              If Found()
                arr_osm1[ i, 3 ] := p2->kod
              Endif
            Endif
            If ValType( ar[ 10 ] ) == "N"
              arr_osm1[ i, 4 ] := ar[ 10 ] // ��䨫�
            Else
              If Len( ar[ 10 ] ) == Len( ar[ 11 ] ) ; // ���-�� ��䨫�� = ���-�� ᯥ�-⥩
                .and. arr_osm1[ i, 2 ] > 0 ; // � ��諨 ᯥ樠�쭮���
                .and. ( j := AScan( ar[ 11 ], arr_osm1[ i, 2 ] ) ) > 0
                // ���� ��䨫�, ᮮ⢥�����騩 ᯥ樠�쭮��
              Else
                j := 1 // �᫨ ���, ���� ���� ��䨫� �� ᯨ᪠
              Endif
              arr_osm1[ i, 4 ] := ar[ 10, j ] // ��䨫�
            Endif
            ++ku
            If ValType( ar[ 2 ] ) == "C"
              arr_osm1[ i, 5 ] := ar[ 2 ] // ��� ��㣨
            Else
              If Len( ar[ 2 ] ) >= metap
                j := metap
              Else
                j := 1
              Endif
              arr_osm1[ i, 5 ] := ar[ 2, j ] // ��� ��㣨
              If i == count_dvn_arr_usl13 // ��᫥���� ��㣠 �� ���ᨢ� - �࠯���
                If metap == 2
                  j := 0
                  For j1 := 1 To i - 1
                    If !Empty( arr_osm1[ j1, 5 ] ) .and. eq_any( arr_osm1[ j1, 5 ], "4.12.170", "4.12.171", "4.12.173", "10.3.13" )
                      j := j1 ; Exit
                    Endif
                  Next
                  If j == 0 // �᫨ �� ��諨 �� ����� ��㣨 �� ᯨ᪠
                    arr_osm1[ i, 5 ] := "2.84.7" // ���塞 ��� ��㣨 ��� �࠯���
                  Endif
                  If arr_osm1[ i, 2 ] == 2002 // ᯥ樠�쭮���-䥫���
                    fl := func_error( 4, "������ �� ����� �������� �࠯��� �� II �⠯� ��ᯠ��ਧ�樨" )
                  Endif
                Else // 1 � 3 �⠯
                  If arr_osm1[ i, 2 ] == 1110 // ᯥ樠�쭮���-��� ��饩 �ࠪ⨪�
                    arr_osm1[ i, 5 ] := "2.3.2" // ��� ��㣨
                  Elseif arr_osm1[ i, 2 ] == 2002 // ᯥ樠�쭮���-䥫���
                    arr_osm1[ i, 5 ] := "2.3.3" // ��� ��㣨
                  Endif
                Endif
              Endif
            Endif
            If !fl_diag .or. Empty( &mvarz ) .or. Left( &mvarz, 1 ) == "Z"
              arr_osm1[ i, 6 ] := mdef_diagnoz
            Else
              arr_osm1[ i, 6 ] := &mvarz
              Select MKB_10
              find ( PadR( arr_osm1[ i, 6 ], 6 ) )
              If Found() .and. !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
                fl := func_error( 4, "��ᮢ���⨬���� �������� �� ���� " + arr_osm1[ i, 6 ] )
              Endif
            Endif
            If i_otkaz > 0
              arr_osm1[ i, 10 ] := &mvaro
              If i_otkaz == 3 .and. &mvaro == 2 // ���-� ��.���ਠ��,4.20.1
                arr_osm1[ i, 5 ] := "2.3.3" // ��� 䥫���-�����
                arr_osm1[ i, 4 ] := 3 // ��䨫� - �����᪮�� ����
                arr_osm1[ i, 10 ] := 0 // ��� �⪠��
              Endif
            Endif
            arr_osm1[ i, 9 ] := &mvard
            max_date1 := Max( max_date1, arr_osm1[ i, 9 ] )
          Endif
        Endif
        If !fl ; exit ; Endif
      Next
      If !fl
        Loop
      Endif
      If metap == 2
        If ku < 2
          func_error( 4, "�� II �⠯� ��易⥫�� �ᬮ�� �࠯��� � ��� �����-���� ��㣨." )
          Loop
        Endif
        If k == 0
          func_error( 4, "��� ��ࢮ�� �ᬮ�� (��᫥�������) ������ ࠢ������ ��� ��砫� ��祭��." )
          Loop
        Endif
      Endif
      If emptyany( arr_osm1[ count_dvn_arr_usl13, 1 ], arr_osm1[ count_dvn_arr_usl13, 9 ] )
        fl := func_error( 4, '�� ����� ��� �࠯��� (��� ��饩 �ࠪ⨪�)' )
      Elseif arr_osm1[ count_dvn_arr_usl13, 9 ] < mk_data
        fl := func_error( 4, '��࠯��� (��� ��饩 �ࠪ⨪�) ������ �஢����� �ᬮ�� ��᫥����!' )
      Endif
      If !fl
        Loop
      Endif
      If Between( m1GRUPPA, 1, 3 )
        m1rslt := iif( metap == 3, P_BEGIN_RSLT, D_BEGIN_RSLT ) + m1GRUPPA
      Elseif Between( m1GRUPPA, 11, 13 )
        m1rslt := D_BEGIN_RSLT2 + m1GRUPPA -10
      Else
        func_error( 4, "�� ������� ������ ���ﭨ� ��������" )
        Loop
      Endif
      //
      err_date_diap( mn_data, "��� ��砫� ��祭��" )
      err_date_diap( mk_data, "��� ����砭�� ��祭��" )
      //
      If mem_op_out == 2 .and. yes_parol
        box_shadow( 19, 10, 22, 69, cColorStMsg )
        str_center( 20, '������ "' + fio_polzovat + '".', cColorSt2Msg )
        str_center( 21, '���� ������ �� ' + date_month( sys_date ), cColorStMsg )
      Endif
      mywait()
      //
      If metap == 2
        i := count_dvn_arr_usl13
        m1vrach  := arr_osm1[ i, 1 ]
        m1prvs   := arr_osm1[ i, 2 ]
        m1assis  := arr_osm1[ i, 3 ]
        m1PROFIL := arr_osm1[ i, 4 ]
        MKOD_DIAG := PadR( arr_osm1[ i, 6 ], 6 )
      Else  // metap := 1,3
        AAdd( arr_osm1, Array( 10 ) ) ; i := Len( arr_osm1 )
        arr_osm1[ i, 1 ] := arr_osm1[ i - 1, 1 ]
        arr_osm1[ i, 2 ] := arr_osm1[ i - 1, 2 ]
        arr_osm1[ i, 3 ] := arr_osm1[ i - 1, 3 ]
        arr_osm1[ i, 4 ] := arr_osm1[ i - 1, 4 ]
        arr_osm1[ i, 5 ] := ret_shifr_zs_dvn13( metap, iif( metap == 3, mvozrast, mdvozrast ), mpol )
        arr_osm1[ i, 6 ] := arr_osm1[ i - 1, 6 ]
        arr_osm1[ i, 9 ] := mn_data
        arr_osm1[ i, 10 ] := 0
        m1vrach  := arr_osm1[ i, 1 ]
        m1prvs   := arr_osm1[ i, 2 ]
        m1assis  := arr_osm1[ i, 3 ]
        m1PROFIL := arr_osm1[ i, 4 ]
        MKOD_DIAG := PadR( arr_osm1[ i, 6 ], 6 )
      Endif
      Select MKB_10
      find ( MKOD_DIAG )
      If Found() .and. !between_date( mkb_10->dbegin, mkb_10->dend, mk_data )
        MKOD_DIAG := mdef_diagnoz // �᫨ ������� �� �室�� � ���, � 㬮�砭��
      Endif
      For i := 1 To count_dvn_arr_umolch13
        If f_is_umolch_sluch_dvn13( i, metap, iif( metap == 3, mvozrast, mdvozrast ), mpol )
          AAdd( arr_osm1, Array( 10 ) ) ; j := Len( arr_osm1 )
          arr_osm1[ j, 1 ] := m1vrach
          arr_osm1[ j, 2 ] := m1prvs
          arr_osm1[ j, 3 ] := m1assis
          arr_osm1[ j, 4 ] := m1PROFIL
          arr_osm1[ j, 5 ] := dvn_arr_umolch13[ i, 2 ]
          arr_osm1[ j, 6 ] := mdef_diagnoz
          arr_osm1[ j, 9 ] := iif( dvn_arr_umolch13[ i, 8 ] == 0, mn_data, mk_data )
          arr_osm1[ j, 10 ] := 0
        Endif
      Next
      make_diagp( 2 )  // ᤥ���� "��⨧����" ��������
      //
      use_base( "lusl" )
      use_base( "luslc" )
      use_base( "uslugi" )
      r_use( dir_server + "uslugi1", { dir_server + "uslugi1", ;
        dir_server + "uslugi1s" }, "USL1" )
      mcena_1 := mu_cena := 0
      arr_usl_dop := {}
      arr_usl_otkaz := {}
      For i := 1 To Len( arr_osm1 )
        If ValType( arr_osm1[ i, 5 ] ) == "C"
          arr_osm1[ i, 7 ] := foundourusluga( arr_osm1[ i, 5 ], mk_data, arr_osm1[ i, 4 ], M1VZROS_REB, @mu_cena )
          arr_osm1[ i, 8 ] := mu_cena
          mcena_1 += mu_cena
          If arr_osm1[ i, 10 ] == 0
            AAdd( arr_usl_dop, arr_osm1[ i ] )
          Else
            AAdd( arr_usl_otkaz, arr_osm1[ i ] )
          Endif
        Endif
      Next
      //
      use_base( "human" )
      If Loc_kod > 0
        find ( Str( Loc_kod, 7 ) )
        mkod := Loc_kod
        g_rlock( forever )
      Else
        add1rec( 7 )
        mkod := RecNo()
        Replace human->kod With mkod
      Endif
      Select HUMAN_
      Do While human_->( LastRec() ) < mkod
        Append Blank
      Enddo
      Goto ( mkod )
      g_rlock( forever )
      //
      Select HUMAN_2
      Do While human_2->( LastRec() ) < mkod
        Append Blank
      Enddo
      Goto ( mkod )
      g_rlock( forever )
      //
      st_N_DATA := MN_DATA
      glob_perso := mkod
      If m1komu == 0
        msmo := lstr( m1company )
        m1str_crb := 0
      Else
        msmo := ""
        m1str_crb := m1company
      Endif
      //
      human->kod_k      := glob_kartotek
      human->TIP_H      := B_STANDART // 3-��祭�� �����襭�
      human->FIO        := MFIO          // �.�.�. ���쭮��
      human->POL        := MPOL          // ���
      human->DATE_R     := MDATE_R       // ��� ஦����� ���쭮��
      human->VZROS_REB  := M1VZROS_REB   // 0-�����, 1-ॡ����, 2-�����⮪
      human->ADRES      := MADRES        // ���� ���쭮��
      human->MR_DOL     := MMR_DOL       // ���� ࠡ��� ��� ��稭� ���ࠡ�⭮��
      human->RAB_NERAB  := M1RAB_NERAB   // 0-ࠡ���騩, 1-��ࠡ���騩, 2-��㤥��
      human->KOD_DIAG   := mkod_diag     // ��� 1-�� ��.�������
      human->diag_plus  := mdiag_plus    //
      human->KOMU       := M1KOMU        // �� 0 �� 5
      human_->SMO       := msmo
      human->STR_CRB    := m1str_crb
      human->POLIS      := make_polis( mspolis, mnpolis ) // ��� � ����� ���客��� �����
      human->LPU        := M1LPU         // ��� ��०�����
      human->OTD        := M1OTD         // ��� �⤥�����
      human->UCH_DOC    := MUCH_DOC      // ��� � ����� ��⭮�� ���㬥��
      human->N_DATA     := MN_DATA       // ��� ��砫� ��祭��
      human->K_DATA     := MK_DATA       // ��� ����砭�� ��祭��
      human->CENA := human->CENA_1 := MCENA_1 // �⮨����� ��祭��
      human->ishod      := 200 + metap
      human->bolnich    := 0
      human->date_b_1   := ""
      human->date_b_2   := ""
      human_->RODIT_DR  := CToD( "" )
      human_->RODIT_POL := ""
      s := "" ; AEval( adiag_talon, {| x| s += Str( x, 1 ) } )
      human_->DISPANS   := s
      human_->STATUS_ST := ""
      // human_->POVOD     := m1povod
      // human_->TRAVMA    := m1travma
      human_->VPOLIS    := m1vidpolis
      human_->SPOLIS    := LTrim( mspolis )
      human_->NPOLIS    := LTrim( mnpolis )
      human_->OKATO     := "" // �� ���� ������� �� ����� � ��砥 �����த����
      human_->NOVOR     := 0
      human_->DATE_R2   := CToD( "" )
      human_->POL2      := ""
      human_->USL_OK    := m1USL_OK
      human_->VIDPOM    := m1VIDPOM
      human_->PROFIL    := m1PROFIL
      human_->IDSP      := iif( metap == 3, 17, 11 )
      human_->NPR_MO    := ''
      human_->FORMA14   := '0000'
      human_->KOD_DIAG0 := ''
      human_->RSLT_NEW  := m1rslt
      human_->ISHOD_NEW := m1ishod
      human_->VRACH     := m1vrach
      human_->PRVS      := m1prvs
      human_->OPLATA    := 0 // 㡥�� "2", �᫨ ��।���஢��� ������ �� ॥��� �� � ��
      human_->ST_VERIFY := 0 // ᭮�� ��� �� �஢�७
      If Loc_kod == 0  // �� ����������
        human_->ID_PAC    := mo_guid( 1, human_->( RecNo() ) )
        human_->ID_C      := mo_guid( 2, human_->( RecNo() ) )
        human_->SUMP      := 0
        human_->SANK_MEK  := 0
        human_->SANK_MEE  := 0
        human_->SANK_EKMP := 0
        human_->REESTR    := 0
        human_->REES_ZAP  := 0
        human->schet      := 0
        human_->SCHET_ZAP := 0
        human->kod_p   := kod_polzovat    // ��� ������
        human->date_e  := c4sys_date
      Else // �� ।���஢�����
        human_->kod_p2  := kod_polzovat    // ��� ������
        human_->date_e2 := c4sys_date
      Endif
      put_0_human_2()
      Private fl_nameismo := .f.
      If m1komu == 0 .and. m1company == 34
        human_->OKATO := m1okato // ����� ��ꥪ� �� ����ਨ ���客����
        If Empty( m1ismo )
          If !Empty( mnameismo )
            fl_nameismo := .t.
          Endif
        Else
          human_->SMO := m1ismo  // �����塞 "34" �� ��� �����த��� ���
        Endif
      Endif
      If fl_nameismo .or. rec_inogSMO > 0
        g_use( dir_server + "mo_hismo",, "SN" )
        Index On Str( kod, 7 ) to ( cur_dir + "tmp_ismo" )
        find ( Str( mkod, 7 ) )
        If Found()
          If fl_nameismo
            g_rlock( forever )
            sn->smo_name := mnameismo
          Else
            deleterec( .t. )
          Endif
        Else
          If fl_nameismo
            addrec( 7 )
            sn->kod := mkod
            sn->smo_name := mnameismo
          Endif
        Endif
      Endif
      i1 := Len( arr_usl )
      i2 := Len( arr_usl_dop )
      use_base( "human_u" )
      For i := 1 To i2
        Select HU
        If i > i1
          add1rec( 7 )
          hu->kod := human->kod
        Else
          Goto ( arr_usl[ i ] )
          g_rlock( forever )
        Endif
        mrec_hu := hu->( RecNo() )
        hu->kod_vr  := arr_usl_dop[ i, 1 ]
        hu->kod_as  := arr_usl_dop[ i, 3 ]
        hu->u_koef  := 1
        hu->u_kod   := arr_usl_dop[ i, 7 ]
        hu->u_cena  := arr_usl_dop[ i, 8 ]
        hu->is_edit := 0
        hu->date_u  := dtoc4( arr_usl_dop[ i, 9 ] )
        hu->otd     := m1otd
        hu->kol := hu->kol_1 := 1
        hu->stoim := hu->stoim_1 := arr_usl_dop[ i, 8 ]
        hu->KOL_RCP := 0
        Select HU_
        Do While hu_->( LastRec() ) < mrec_hu
          Append Blank
        Enddo
        Goto ( mrec_hu )
        g_rlock( forever )
        If i > i1 .or. !valid_guid( hu_->ID_U )
          hu_->ID_U := mo_guid( 3, hu_->( RecNo() ) )
        Endif
        hu_->PROFIL := arr_usl_dop[ i, 4 ]
        hu_->PRVS   := arr_usl_dop[ i, 2 ]
        hu_->kod_diag := arr_usl_dop[ i, 6 ]
        hu_->zf := ""
        Unlock
      Next
      If i2 < i1
        For i := i2 + 1 To i1
          Select HU
          Goto ( arr_usl[ i ] )
          deleterec( .t., .f. )  // ���⪠ ����� ��� ����⪨ �� 㤠�����
        Next
      Endif
      save_arr_dvn( mkod )
      write_work_oper( glob_task, OPER_LIST, iif( Loc_kod == 0, 1, 2 ), 1, count_edit )
      fl_write_sluch := .t.
      Close databases
      stat_msg( "������ �����襭�!", .f. )
    Endif
    Exit
  Enddo
  Close databases
  SetColor( tmp_color )
  RestScreen( buf )
  chm_help_code := tmp_help
  If fl_write_sluch // �᫨ ����ᠫ� - ����᪠�� �஢���
    If Type( "fl_edit_DVN" ) == "L"
      fl_edit_DVN := .t.
    Endif
    If !Empty( Val( msmo ) )
      verify_oms_sluch( glob_perso )
    Endif
  Endif

  Return Nil

// 15.06.13
Function f_valid_diag_oms_sluch_dvn13( get, k )
  Local sk := lstr( k )

  Private pole_diag := "mdiag" + sk, ;
    pole_pervich := "mpervich" + sk, ;
    pole_1pervich := "m1pervich" + sk, ;
    pole_stadia := "mstadia" + sk, ;
    pole_1stadia := "m1stadia" + sk, ;
    pole_dispans := "mdispans" + sk, ;
    pole_1dispans := "m1dispans" + sk, ;
    pole_dop := "mdop" + sk, ;
    pole_1dop := "m1dop" + sk, ;
    pole_gde := "mgde" + sk, ;
    pole_usl := "musl" + sk, ;
    pole_1usl := "m1usl" + sk, ;
    pole_san := "msan" + sk, ;
    pole_1san := "m1san" + sk

  If get == Nil .or. !( &pole_diag == get:original )
    If Empty( &pole_diag )
      &pole_pervich := Space( 7 )
      &pole_1pervich := 0
      &pole_stadia := Space( 6 )
      &pole_1stadia := 0
      &pole_dispans := Space( 10 )
      &pole_1dispans := 0
      &pole_dop := Space( 9 )
      &pole_1dop := 0
      &pole_usl := Space( 9 )
      &pole_1usl := 0
      &pole_san := Space( 3 )
      &pole_1san := 0
      &pole_gde := Space( 4 )
    Else
      &pole_pervich := inieditspr( A__MENUVERT, mm_pervich, &pole_1pervich )
      &pole_stadia := inieditspr( A__MENUVERT, mm_stadia, &pole_1stadia )
      &pole_dispans := inieditspr( A__MENUVERT, mm_dispans, &pole_1dispans )
      &pole_dop := inieditspr( A__MENUVERT, mm_danet, &pole_1dop )
      &pole_san := inieditspr( A__MENUVERT, mm_danet, &pole_1san )
      if &pole_1dop == 0
        &pole_gde := Space( 4 )
        &pole_usl := Space( 9 )
        &pole_1usl := 0
      Else
        &pole_gde := "���:"
        &pole_usl := inieditspr( A__MENUVERT, mm_usl, &pole_1usl )
      Endif
    Endif
  Endif
  update_get( pole_pervich )
  update_get( pole_stadia )
  update_get( pole_dispans )
  update_get( pole_dop )
  update_get( pole_gde )
  update_get( pole_usl )
  update_get( pole_san )

  Return .t.

// 13.06.13 ࠡ��� �� ��㣠 ��� � ����ᨬ��� �� �⠯�, ������ � ����
Function f_is_usl_oms_sluch_dvn13( i, _etap, _vozrast, _pol, ;
    /*@*/_diag,/*@*/_otkaz,/*@*/_ekg)
  Local fl := .f., ar := dvn_arr_usl13[ i ]

  If ValType( ar[ 3 ] ) == "N"
    fl := ( ar[ 3 ] == _etap )
  Else
    fl := AScan( ar[ 3 ], _etap ) > 0
  Endif
  _diag := ( ar[ 4 ] == 1 )
  _otkaz := 0
  If _etap != 2 .and. ar[ 5 ] == 1
    _otkaz := 1 // ����� ����� �⪠�
    If ValType( ar[ 2 ] ) == "C" .and. eq_any( ar[ 2 ], "7.57.3", "7.61.3", "4.20.1" )
      _otkaz := 2 // ����� ����� �������������
      If ar[ 2 ] == "4.20.1" // ���-� ���⮣� �⮫����᪮�� ���ਠ��
        _otkaz := 3 // �������� �� ��� 䥫���-�����
      Endif
    Endif
  Endif
  If fl .and. Len( ar ) > 5 .and. _etap == 1
    i := iif( _pol == "�", 6, 7 )
    If ValType( ar[ i ] ) == "N"
      fl := ( ar[ i ] != 0 )
      If ar[ i ] < 0  // ���
        _ekg := ( _vozrast < Abs( ar[ i ] ) ) // ����易⥫�� ������
      Endif
    Else
      fl := AScan( ar[ i ], _vozrast ) > 0
    Endif
  Endif
  If fl .and. Len( ar ) > 7 .and. eq_any( _etap, 2, 3 )
    i := iif( _pol == "�", 8, 9 )
    If ValType( ar[ i ] ) == "N"
      fl := ( ar[ i ] != 0 )
    Else
      fl := Between( _vozrast, ar[ i, 1 ], ar[ i, 2 ] )
    Endif
  Endif

  Return fl

// 18.06.13 ࠡ��� �� ��㣠 (㬮�砭��) ��� � ����ᨬ��� �� �⠯�, ������ � ����
Function f_is_umolch_sluch_dvn13( i, _etap, _vozrast, _pol )
  Local fl := .f., ar := dvn_arr_umolch13[ i ]

  If ValType( ar[ 3 ] ) == "N"
    fl := ( ar[ 3 ] == _etap )
  Else
    fl := AScan( ar[ 3 ], _etap ) > 0
  Endif
  If fl .and. Len( ar ) > 4 .and. _etap == 1
    i := iif( _pol == "�", 4, 5 )
    If ValType( ar[ i ] ) == "N"
      fl := ( ar[ i ] != 0 )
    Else
      fl := AScan( ar[ i ], _vozrast ) > 0
    Endif
  Endif
  If fl .and. Len( ar ) > 6 .and. _etap == 3
    i := iif( _pol == "�", 6, 7 )
    If ValType( ar[ i ] ) == "N"
      fl := ( ar[ i ] != 0 )
    Else
      fl := Between( _vozrast, ar[ i, 1 ], ar[ i, 2 ] )
    Endif
  Endif

  Return fl

// 05.06.13 ������ ��� ��㣨 �����祭���� ���� ��� ���
Function ret_shifr_zs_dvn13( _etap, _vozrast, _pol )
  Local lshifr := ""

  If _etap == 1
    If _pol == "�"
      If _vozrast == 36
        lshifr := "70.3.8"
      Elseif _vozrast == 39
        lshifr := "70.3.9"
      Elseif _vozrast == 42
        lshifr := "70.3.10"
      Elseif _vozrast == 45
        lshifr := "70.3.11"
      Elseif _vozrast == 48
        lshifr := "70.3.12"
      Elseif eq_any( _vozrast, 54, 60, 66, 72, 78, 84, 90, 96 )
        lshifr := "70.3.13"
      Elseif eq_any( _vozrast, 51, 57, 63, 69, 75, 81, 87, 93, 99 )
        lshifr := "70.3.14"
      Else // 21,24,27,30,33
        lshifr := "70.3.7"
      Endif
    Else
      If _vozrast == 39
        lshifr := "70.3.2"
      Elseif _vozrast == 42
        lshifr := "70.3.3"
      Elseif _vozrast == 45
        lshifr := "70.3.4"
      Elseif eq_any( _vozrast, 48, 54, 60, 66, 72, 78, 84, 90, 96 )
        lshifr := "70.3.5"
      Elseif eq_any( _vozrast, 51, 57, 63, 69, 75, 81, 87, 93, 99 )
        lshifr := "70.3.6"
      Else // 21,24,27,30,33,36
        lshifr := "70.3.1"
      Endif
    Endif
  Else // _etap == 3
    If _pol == "�"
      If _vozrast < 45
        lshifr := "72.1.4"
      Else
        lshifr := "72.1.5"
      Endif
    Else
      If _vozrast < 39
        lshifr := "72.1.1"
      Elseif _vozrast < 45
        lshifr := "72.1.2"
      Else
        lshifr := "72.1.3"
      Endif
    Endif
  Endif

  Return lshifr

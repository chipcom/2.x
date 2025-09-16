// mo_omsid.prg - ���ଠ�� �� ��ᯠ��ਧ�樨 � ���
#include "inkey.ch"
#include "fastreph.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// #define MONTH_UPLOAD 8 //����� ��� ���㧪� R11

Static lcount_uch  := 1
Static mas1pmt := { "~�� �������� ��砨", ;
    "��砨 � ���⠢������ ~����", ;
    "��砨 � ��~ॣ����஢����� ����" }

// 12.04.24 ��ᯠ��ਧ���, ��䨫��⨪� � ����ᬮ���
Function dispanserizacia( k )

  Static si1 := 1, si2 := 1, sj := 1, sj1 := 1
  Local mas_pmt, mas_msg, mas_fun, j, j1

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { "~���-����", ;
      "~���᫮� ��ᥫ����", ;
      "~��ᮢ��襭����⭨�", ;
      "~������� ���ଠ��", ;
      "~���த�⨢��� ���஢�" }
    mas_msg := { "���ଠ�� �� ��ᯠ��ਧ�樨 ��⥩-���", ;
      "���ଠ�� �� ��ᯠ��ਧ�樨 � ��䨫��⨪� ���᫮�� ��ᥫ����", ;
      "���ଠ�� �� ����樭᪨� �ᬮ�ࠬ ��ᮢ��襭����⭨�", ;
      "������ ���㬥��� �� �ᥬ ����� ��ᯠ��ਧ�樨 � ��䨫��⨪�", ;
      "�஢������ ��ᯠ��ਧ�樨 ९த�⨢���� ���஢��" }
    mas_fun := { "dispanserizacia(11)", ;
      "dispanserizacia(12)", ;
      "dispanserizacia(13)", ;
      "dispanserizacia(14)", ;
      "dispanserizacia(15)" }
    popup_prompt( T_ROW, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    inf_dds()
  Case k == 12
    inf_dvn()
  Case k == 13
    inf_dnl()
  Case k == 14
    inf_disp()
  Case k == 15
    inf_drz()
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Endif
  Endif

  Return Nil

// 23.09.20 ���ଠ�� �� ��ᯠ��ਧ�樨 ��⥩-���
Function inf_dds( k )

  Static si1 := 1, si2 := 1, sj := 1, sj1 := 1, sj2 := 1
  Local mas_pmt, mas_msg, mas_fun, j, j1

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { "~���� ��ᯠ��ਧ�樨", ;
      "~���᮪ ��樥�⮢", ;
      "����� ��� ���~��ࠢ�", ;
      "��ଠ � 030-�/�/~�-13", ;
      "XML-䠩� ��� ~���⠫� ����" }
    mas_msg := { "��ᯥ�⪠ ����� ��ᯠ��ਧ�樨 (���⭠� �ଠ � 030-�/�/�-13)", ;
      "��ᯥ�⪠ ᯨ᪠ ��樥�⮢, ����� �஢����� ��ᯠ��ਧ��� ��⥩-���", ;
      "��ᯥ�⪠ ࠧ����� ᢮��� ��� �����ࠢ� ������ࠤ᪮� ������", ;
      "�������� � ��ᯠ��ਧ�樨 ��ᮢ��襭����⭨� (����⭠� �ଠ � 030-�/�/�-13)", ;
      "�������� XML-䠩�� ��� ����㧪� �� ���⠫ �����ࠢ� ��" }
    mas_fun := { "inf_DDS(11)", ;
      "inf_DDS(12)", ;
      "inf_DDS(13)", ;
      "inf_DDS(14)", ;
      "inf_DDS(15)" }
    popup_prompt( T_ROW, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
  Case Between( k, 11, 19 )
    If ( j := popup_prompt( T_ROW, T_COL -5, sj, ;
        { "��室�騥�� � ��樮���", "��室�騥�� ��� ������" } ) ) == 0
      Return Nil
    Endif
    sj := j
    Private p_tip_lu := iif( j == 1, TIP_LU_DDS, TIP_LU_DDSOP )
    Do Case
    Case k == 11
      inf_dds_karta()
    Case k == 12
      If ( j1 := popup_prompt( T_ROW, T_COL -5, 3, mas1pmt ) ) > 0
        inf_dds_svod( 1,, j1 )
      Endif
    Case k == 13
      If ( j1 := popup_prompt( T_ROW, T_COL -5, 1, mas1pmt ) ) > 0
        If ( j := popup_prompt( T_ROW, T_COL -5, sj2, ;
            { "�뢮� ⠡���� � ᯨ᪮� ��⥩", ;
            "�뢮� � Excel ��� �����", ;
            "�뢮� ⠡���� � ����� �14-05/50", ;
            "�뢮� ⠡���� 2510" } ) ) > 0
          sj2 := j
          If j > 2
            inf_dds_svod2( j, j1 )
          Else
            inf_dds_svod( 2, j, j1 )
          Endif
        Endif
      Endif
    Case k == 14
      If ( j1 := popup_prompt( T_ROW, T_COL -5, 1, mas1pmt ) ) > 0
        inf_dds_030dso( j1 )
      Endif
    Case k == 15
      If ( j1 := popup_prompt( T_ROW, T_COL -5, 1, mas1pmt ) ) > 0
        inf_dds_xmlfile( j1 )
      Endif
    Endcase
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Elseif Between( k, 21, 29 )
      si2 := j
    Endif
  Endif

  Return Nil

// 12.07.13 ��ᯥ�⪠ ����� ��ᯠ��ਧ�樨 (���⭠� �ଠ � 030-�/�/�-13)
Function inf_dds_karta()

  Local arr_m, buf := save_maxrow(), blk, t_arr[ BR_LEN ]

  If ( arr_m := year_month( T_ROW, T_COL -5 ) ) != NIL
    mywait()
    If f0_inf_dds( arr_m, .f. )
      r_use( dir_server() + "human",, "HUMAN" )
      Use ( cur_dir() + "tmp" ) new
      Set Relation To kod into HUMAN
      Index On Upper( human->fio ) to ( cur_dir() + "tmp" )
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + "human_",, "HUMAN_" ), ;
        r_use( dir_server() + "human",, "HUMAN" ), ;
        dbSetRelation( "HUMAN_", {|| RecNo() }, "recno()" ), ;
        r_use( cur_dir() + "tmp", cur_dir() + "tmp" ), ;
        dbSetRelation( "HUMAN", {|| kod }, "kod" );
        }
      Eval( blk_open )
      Go Top
      t_arr[ BR_TOP ] := T_ROW
      t_arr[ BR_BOTTOM ] := 23
      t_arr[ BR_LEFT ] := 0
      t_arr[ BR_RIGHT ] := 79
      t_arr[ BR_TITUL ] := "��ᯠ��ਧ��� ��⥩-��� " + arr_m[ 4 ]
      t_arr[ BR_TITUL_COLOR ] := "B/BG"
      t_arr[ BR_COLOR ] := color0
      t_arr[ BR_ARR_BROWSE ] := { '�', '�', '�', "N/BG,W+/N,B/BG,W+/B", .t. }
      blk := {|| iif( human->schet > 0, { 1, 2 }, { 3, 4 } ) }
      t_arr[ BR_COLUMN ] := { { " �.�.�.", {|| PadR( human->fio, 39 ) }, blk }, ;
        { "��� ஦�.", {|| full_date( human->date_r ) }, blk }, ;
        { "� ��.�����", {|| human->uch_doc }, blk }, ;
        { "�ப� ���-�", {|| Left( date_8( human->n_data ), 5 ) + "-" + Left( date_8( human->k_data ), 5 ) }, blk }, ;
        { "�⠯", {|| iif( human->ishod == 101, " I  ", "I-II" ) }, blk } }
      t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ - ��室;  ^<Enter>^ - �ᯥ���� ����� ��ᯠ��ਧ�樨" ) }
      t_arr[ BR_EDIT ] := {| nk, ob| f1_inf_dds_karta( nk, ob, "edit" ) }
      edit_browse( t_arr )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 11.03.19
Function f0_inf_dds( arr_m, is_schet, is_reg, is_snils )

  Local fl := .t.

  Default is_schet To .t., is_reg To .f., is_snils To .f.
  If !del_dbf_file( cur_dir() + "tmp" + sdbf() )
    Return .f.
  Endif
  dbCreate( cur_dir() + "tmp", { { "kod", "N", 7, 0 }, ;
    { "is", "N", 1, 0 } } )
  Use ( cur_dir() + "tmp" ) new
  r_use( dir_server() + "schet_",, "SCHET_" )
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "human_",, "HUMAN_" )
  r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
  Set Relation To RecNo() into HUMAN_, To kod_k into KART
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Index On kod to ( cur_dir() + "tmp_h" ) ;
    For iif( p_tip_lu == TIP_LU_DDS, !Empty( za_smo ), Empty( za_smo ) ) .and. ;
    eq_any( ishod, 101, 102 ) .and. iif( is_schet, schet > 0, .t. ) ;
    While human->k_data <= arr_m[ 6 ] ;
    PROGRESS
  Go Top
  Do While !Eof()
    fl := .t.
    If is_reg
      fl := .f.
      Select SCHET_
      Goto ( human->schet )
      If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // ⮫쪮 ��ॣ����஢����
        fl := .t.
      Endif
    Endif
    If fl .and. ret_koef_from_rak( human->kod ) > 0
      Select TMP
      Append Blank
      tmp->kod := human->kod
      tmp->is := iif( is_snils .and. Empty( kart->snils ), 0, 1 )
    Endif
    Select HUMAN
    Skip
  Enddo
  fl := .t.
  If tmp->( LastRec() ) == 0
    fl := func_error( 4, "�� ������� �/� �� ��ᯠ��ਧ�樨 ��⥩-��� " + arr_m[ 4 ] )
  Endif
  Close databases

  Return fl

// 05.07.13
Function f1_inf_dds_karta( nKey, oBrow, regim )

  Local ret := -1, lkod_h, lkod_k, rec := tmp->( RecNo() ), buf := save_maxrow()

  If regim == "edit" .and. nKey == K_ENTER
    mywait()
    lkod_h := human->kod
    lkod_k := human->kod_k
    Close databases
    oms_sluch_dds( p_tip_lu, lkod_h, lkod_k, "f2_inf_DDS_karta" )
    Eval( blk_open )
    Goto ( rec )
    rest_box( buf )
  Endif

  Return ret

// 13.09.25
Function f2_inf_dds_karta( Loc_kod, kod_kartotek, lvozrast )

  Static st := "     ", ub := "<u><b>", ue := "</b></u>", sh := 88
  Local adbf, s, i, j, k, y, m, d, fl, mm_danet, blk := {| s| __dbAppend(), field->stroke := s }
  local mm_invalid5 := mm_invalid5()

  delfrfiles()
  r_use( dir_server() + "mo_stdds" )
  If Type( "m1stacionar" ) == "N" .and. m1stacionar > 0
    Goto ( m1stacionar )
  Endif
  r_use( dir_server() + "kartote_",, "KART_" )
  Goto ( kod_kartotek )
  r_use( dir_server() + "kartotek",, "KART" )
  Goto ( kod_kartotek )
  r_use( dir_server() + "mo_pers",, "P2" )
  Goto ( m1vrach )
  r_use( dir_server() + "organiz",, "ORG" )
  adbf := { { "name", "C", 130, 0 }, ;
    { "prikaz", "C", 50, 0 }, ;
    { "forma", "C", 50, 0 }, ;
    { "titul", "C", 100, 0 }, ;
    { "fio", "C", 50, 0 }, ;
    { "k_data", "C", 40, 0 }, ;
    { "vrach", "C", 40, 0 }, ;
    { "glavn", "C", 40, 0 } }
  dbCreate( fr_titl, adbf )
  Use ( fr_titl ) New Alias FRT
  Append Blank
  frt->name := glob_mo[ _MO_SHORT_NAME ]
  frt->fio := mfio
  frt->k_data := date_month( mk_data )
  frt->vrach := fam_i_o( p2->fio )
  frt->glavn := fam_i_o( org->ruk )
  adbf := { { "stroke", "C", 2000, 0 } }
  dbCreate( fr_data, adbf )
  Use ( fr_data ) New Alias FRD
  If p_tip_lu == TIP_LU_PN // ��䨫��⨪� ��ᮢ��襭����⭨�
    frt->prikaz := "�� 21.12.2012�. � 1346�"
    frt->forma  := "030-��/�-12"
    frt->titul  := "���� ��䨫����᪮�� ����樭᪮�� �ᬮ�� ��ᮢ��襭����⭥��"
    s := st + "1. �������, ���, ����⢮ ��ᮢ��襭����⭥��: " + ub + AllTrim( mfio ) + ue + "."
    frd->( Eval( blk, s ) )
    s := st + "���: " + f3_inf_dds_karta( { { "��.", "�" }, { "���.", "�" } }, mpol, "/", ub, ue )
    frd->( Eval( blk, s ) )
    s := st + "��� ஦�����: " + ub + date_month( mdate_r, .t. ) + ue + "."
    frd->( Eval( blk, s ) )
    s := st + "2. ����� ��易⥫쭮�� ����樭᪮�� ���客����: "
    s += "��� " + iif( Empty( mspolis ), Replicate( "_", 15 ), ub + AllTrim( mspolis ) + ue )
    s += " � " + ub + AllTrim( mnpolis ) + ue + "."
    frd->( Eval( blk, s ) )
    s := st + "���客�� ����樭᪠� �࣠������: " + ub + AllTrim( mcompany ) + ue + "."
    frd->( Eval( blk, s ) )
    s := st + "3. ���客�� ����� �������㠫쭮�� ��楢��� ���: "
//    s += iif( Empty( kart->snils ), Replicate( "_", 25 ), ub + Transform( kart->SNILS, picture_pf ) + ue ) + "."
    s += iif( Empty( kart->snils ), Replicate( "_", 25 ), ub + Transform_SNILS( kart->SNILS ) + ue ) + "."
    frd->( Eval( blk, s ) )
    s := st + "4. ���� ���� ��⥫��⢠: "
    If emptyall( kart_->okatog, kart->adres )
      s += Replicate( "_", 50 ) + " " + Replicate( "_", sh ) + "."
    Else
      s += ub + ret_okato_ulica( kart->adres, kart_->okatog, 1, 2 ) + ue + "."
    Endif
    frd->( Eval( blk, s ) )
    s := st + "5. ��⥣���: " + f3_inf_dds_karta( mm_kateg_uch(), m1kateg_uch, "; ", ub, ue )
    frd->( Eval( blk, s ) )
    s := st + "6. ������ ������������ ����樭᪮� �࣠����樨, � ���ன " + ;
      "��ᮢ��襭����⭨� ����砥� ��ࢨ��� ������-ᠭ����� ������: "
    s += ub + ret_mo( m1MO_PR )[ _MO_FULL_NAME ] + ue + "."
    frd->( Eval( blk, s ) )
    s := st + "7. �ਤ��᪨� ���� ����樭᪮� �࣠����樨, � ���ன " + ;
      "��ᮢ��襭����⭨� ����砥� ��ࢨ��� ������-ᠭ����� ������: "
    s += ub + ret_mo( m1MO_PR )[ _MO_ADRES ] + ue + "."
    frd->( Eval( blk, s ) )
    madresschool := ""
    If Type( "m1school" ) == "N" .and. m1school > 0
      r_use( dir_server() + "mo_schoo",, "SCH" )
      Goto ( m1school )
      If !Empty( sch->fname )
        mschool := AllTrim( sch->fname )
        madresschool := AllTrim( sch->adres )
      Endif
    Endif
    s := st + "8. ������ ������������ ��ࠧ���⥫쭮�� ��०�����, � ���஬ " + ;
      "���砥��� ��ᮢ��襭����⭨�: " + ub + mschool + ue + "."
    frd->( Eval( blk, s ) )
    s := st + "9. �ਤ��᪨� ���� ��ࠧ���⥫쭮�� ��०�����, � ���஬ " + ;
      "���砥��� ��ᮢ��襭����⭨�: "
    If Empty( madresschool )
      frd->( Eval( blk, s ) )
      s := Replicate( "_", sh ) + "."
    Else
      s += ub + madresschool + ue + "."
    Endif
    frd->( Eval( blk, s ) )
    s := st + "10. ��� ��砫� ����樭᪮�� �ᬮ��: " + ub + full_date( mn_data ) + ue + "."
    frd->( Eval( blk, s ) )
  Else // ��ᯠ��ਧ��� ��⥩-���
    frt->prikaz := "�� 15.02.2013�. � 72�"
    frt->forma  := "030-�/�/�-13"
    frt->titul  := "���� ��ᯠ��ਧ�樨 ��ᮢ��襭����⭥��"
    s := st + "1. ������ ������������ ��樮��୮�� ��०�����: "
    If p_tip_lu == TIP_LU_DDS
      s += ub + AllTrim( mstacionar ) + ue + "."
      frd->( Eval( blk, s ) )
    Else
      frd->( Eval( blk, s ) )
      s := Replicate( "_", sh ) + "."
      frd->( Eval( blk, s ) )
    Endif
    s := st + "1.1. �०��� ������������ (� ��砥 ��� ���������):"
    frd->( Eval( blk, s ) )
    s := Replicate( "_", sh ) + "."
    frd->( Eval( blk, s ) )
    s := st + "1.2. ������⢥���� �ਭ����������: "
    If p_tip_lu == TIP_LU_DDS
      i := mo_stdds->vedom
      If !Between( i, 0, 3 )
        i := 3
      Endif
    Else
      i := -1
    Endif
    mm_vedom := { { "�࣠�� ��ࠢ���࠭����", 0 }, ;
      { "��ࠧ������", 1 }, ;
      { "�樠�쭮� �����", 2 }, ;
      { "��㣮�", 3 } }
    s += f3_inf_dds_karta( mm_vedom, i,, ub, ue )
    frd->( Eval( blk, s ) )
    s := st + "1.3. �ਤ��᪨� ���� ��樮��୮�� ��०�����: "
    If p_tip_lu == TIP_LU_DDS .and. !Empty( mo_stdds->adres )
      s += ub + AllTrim( mo_stdds->adres ) + ue + "."
    Endif
    frd->( Eval( blk, s ) )
    If p_tip_lu == TIP_LU_DDSOP .or. Empty( mo_stdds->adres )
      s := Replicate( "_", sh ) + "."
      frd->( Eval( blk, s ) )
    Endif
    s := st + "2. �������, ���, ����⢮ ��ᮢ��襭����⭥��: " + ub + AllTrim( mfio ) + ue + "."
    frd->( Eval( blk, s ) )
    s := st + "2.1. ���: "
    s += f3_inf_dds_karta( { { "��.", "�" }, { "���.", "�" } }, mpol, "/", ub, ue )
    frd->( Eval( blk, s ) )
    s := st + "2.2. ��� ஦�����: " + ub + date_month( mdate_r, .t. ) + ue + "."
    frd->( Eval( blk, s ) )
    s := st + "2.3. ��⥣��� ��� ॡ����, ��室�饣��� � �殮��� ��������� ���樨: "
    s += f3_inf_dds_karta( mm_kateg_uch(), m1kateg_uch, "; ", ub, ue )
    frd->( Eval( blk, s ) )
    s := st + "2.4. �� ������ �஢������ ��ᯠ��ਧ�樨 ��室���� "
    mm_gde_nahod1[ 3, 1 ] := "�����⥫��⢮�"
    s += f3_inf_dds_karta( mm_gde_nahod1, m1gde_nahod,, ub, ue )
    frd->( Eval( blk, s ) )
    s := st + "3. ����� ��易⥫쭮�� ����樭᪮�� ���客����:"
    frd->( Eval( blk, s ) )
    s := st + "��� " + iif( Empty( mspolis ), Replicate( "_", 15 ), ub + AllTrim( mspolis ) + ue )
    s += " � " + ub + AllTrim( mnpolis ) + ue + "."
    frd->( Eval( blk, s ) )
    s := st + "���客�� ����樭᪠� �࣠������: " + ub + AllTrim( mcompany ) + ue + "."
    frd->( Eval( blk, s ) )
    s := st + "���客�� ����� �������㠫쭮�� ��楢��� ���: "
//    s += iif( Empty( kart->snils ), Replicate( "_", 25 ), ub + Transform( kart->SNILS, picture_pf ) + ue ) + "."
    s += iif( Empty( kart->snils ), Replicate( "_", 25 ), ub + Transform_SNILS( kart->SNILS ) + ue ) + "."
    frd->( Eval( blk, s ) )
    s := st + "4. ��� ����㯫���� � ��樮��୮� ��०�����: "
    s += iif( p_tip_lu == TIP_LU_DDSOP .or. Empty( mdate_post ), Replicate( "_", 15 ), ub + full_date( mdate_post ) + ue ) + "."
    frd->( Eval( blk, s ) )
    s := st + "5. ��稭� ����� �� ��樮��୮�� ��०�����: "
// �� ���� �����    del_array( mm_prich_vyb(), 1 ) // 㤠���� 1-� ����� "{"�� ���", 0}"
    s += f3_inf_dds_karta( mm_prich_vyb(), m1prich_vyb,, ub, ue )
    frd->( Eval( blk, s ) )
    s := st + "5.1. ��� �����: " + iif( Empty( mDATE_VYB ), Replicate( "_", 15 ), ub + full_date( mDATE_VYB ) + ue ) + "."
    frd->( Eval( blk, s ) )
    s := st + "6. ��������� �� ������ �஢������ ��ᯠ��ਧ�樨:"
    frd->( Eval( blk, s ) )
    s := Replicate( "_", 73 ) + " (㪠���� ��稭�)."
    frd->( Eval( blk, s ) )
    s := st + "7. ���� ���� ��⥫��⢠: "
    If emptyall( kart_->okatog, kart->adres )
      s += Replicate( "_", 50 ) + " " + Replicate( "_", sh ) + "."
    Else
      s += ub + ret_okato_ulica( kart->adres, kart_->okatog, 1, 2 ) + ue + "."
    Endif
    frd->( Eval( blk, s ) )
    s := st + "8. ������ ������������ ����樭᪮� �࣠����樨, ��࠭��� " + ;
      "��ᮢ��襭����⭨� (��� த�⥫�� ��� ��� ������� �।�⠢�⥫��) " + ;
      "��� ����祭�� ��ࢨ筮� ������-ᠭ��୮� �����: "
    s += ub + ret_mo( m1MO_PR )[ _MO_FULL_NAME ] + ue + "."
    frd->( Eval( blk, s ) )
    s := st + "9. �ਤ��᪨� ���� ����樭᪮� �࣠����樨, ��࠭��� " + ;
      "��ᮢ��襭����⭨� (��� த�⥫�� ��� ��� ������� �।�⠢�⥫��) " + ;
      "��� ����祭�� ��ࢨ筮� ������-ᠭ��୮� �����: "
    s += ub + ret_mo( m1MO_PR )[ _MO_ADRES ] + ue + "."
    frd->( Eval( blk, s ) )
    s := st + "10. ��� ��砫� ��ᯠ��ਧ�樨: " + ub + full_date( mn_data ) + ue + "."
    frd->( Eval( blk, s ) )
  Endif
  s := st + "11. ������ ������������ � �ਤ��᪨� ���� ����樭᪮� �࣠����樨, " + ;
    "�஢����襩 " + iif( p_tip_lu == TIP_LU_PN, "��䨫����᪨� ����樭᪨� �ᬮ��: ", "��ᯠ��ਧ���: " ) + ;
    ub + glob_mo[ _MO_FULL_NAME ] + ", " + glob_mo[ _MO_ADRES ] + ue + "."
  frd->( Eval( blk, s ) )
  s := st + "12. �業�� 䨧��᪮�� ࠧ���� � ��⮬ ������ �� ������ " + ;
    iif( p_tip_lu == TIP_LU_PN, "����樭᪮�� �ᬮ��:", "��ᯠ��ਧ�樨:" )
  frd->( Eval( blk, s ) )
  count_ymd( mdate_r, mn_data, @y, @m, @d )
  s := ub + st + lstr( d ) + st + ue + " (�᫮ ����) " + ;
    ub + st + lstr( m ) + st + ue + " (����楢) " + ;
    ub + st + lstr( y ) + st + ue + " ���."
  frd->( Eval( blk, s ) )
  mm_fiz_razv1 := { { "����� ����� ⥫�", 1 }, { "����⮪ ����� ⥫�", 2 } }
  mm_fiz_razv2 := { { "������ ���", 1 }, { "��᮪�� ���", 2 } }
  For i := 1 To 2
    s := st + "12." + lstr( i ) + ". ��� ��⥩ � ������ " + ;
      { "0 - 4 ���: ", "5 - 17 ��� �����⥫쭮: " }[ i ]
    If i == 1
      fl := ( lvozrast < 5 )
    Else
      fl := ( lvozrast > 4 )
    Endif
    s += "���� (��) " + iif( !fl, "________", ub + st + lstr( mWEIGHT ) + st + ue ) + "; "
    s += "��� (�) " + iif( !fl, "________", ub + st + lstr( mHEIGHT ) + st + ue ) + "; "
    s += "���㦭���� ������ (�) " + iif( !fl .or. mPER_HEAD == 0, "________", ub + st + lstr( mPER_HEAD ) + st + ue ) + "; "
    s += "䨧��᪮� ࠧ��⨥ " + f3_inf_dds_karta( mm_fiz_razv(), iif( fl, m1FIZ_RAZV, -1 ),, ub, ue, .f. )
    s += " (" + f3_inf_dds_karta( mm_fiz_razv1, iif( fl, m1FIZ_RAZV1, -1 ),, ub, ue, .f. )
    s += ", " + f3_inf_dds_karta( mm_fiz_razv2, iif( fl, m1FIZ_RAZV2, -1 ),, ub, ue, .f. )
    s += " - �㦭�� ����ભ���)."
    frd->( Eval( blk, s ) )
  Next
  fl := ( lvozrast < 5 )
  s := st + "13. �業�� ����᪮�� ࠧ���� (���ﭨ�):"
  frd->( Eval( blk, s ) )
  s := st + "13.1. ��� ��⥩ � ������ 0 - 4 ���:"
  frd->( Eval( blk, s ) )
  s := st + "�������⥫쭠� �㭪�� (������ ࠧ����) " + iif( !fl, "________", ub + st + lstr( m1psih11 ) + st + ue ) + ";"
  frd->( Eval( blk, s ) )
  s := st + "���ୠ� �㭪�� (������ ࠧ����) " + iif( !fl, "________", ub + st + lstr( m1psih12 ) + st + ue ) + ";"
  frd->( Eval( blk, s ) )
  s := st + "�樮���쭠� � �樠�쭠� (���⠪� � ���㦠�騬 ��஬) �㭪樨 (������ ࠧ����) " + iif( !fl, "________", ub + st + lstr( m1psih13 ) + st + ue ) + ";"
  frd->( Eval( blk, s ) )
  s := st + "�।�祢�� � �祢�� ࠧ��⨥ (������ ࠧ����) " + iif( !fl, "________", ub + st + lstr( m1psih14 ) + st + ue ) + "."
  frd->( Eval( blk, s ) )
  fl := ( lvozrast > 4 )
  s := st + "13.2. ��� ��⥩ � ������ 5 - 17 ���:"
  frd->( Eval( blk, s ) )
  s := st + "13.2.1. ��宬��ୠ� ���: " + f3_inf_dds_karta( mm_psih2(), iif( fl, m1psih21, -1 ),, ub, ue )
  frd->( Eval( blk, s ) )
  s := st + "13.2.2. ��⥫����: " + f3_inf_dds_karta( mm_psih2(), iif( fl, m1psih22, -1 ),, ub, ue )
  frd->( Eval( blk, s ) )
  s := st + "13.2.3. ���樮���쭮-�����⨢��� ���: " + f3_inf_dds_karta( mm_psih2(), iif( fl, m1psih23, -1 ),, ub, ue )
  frd->( Eval( blk, s ) )
  fl := ( mpol == "�" .and. lvozrast > 9 )
  s := st + "14. �業�� �������� ࠧ���� (� 10 ���):"
  frd->( Eval( blk, s ) )
  s := st + "14.1. ������� ��㫠 ����稪�: � " + iif( !fl .or. m141p == 0, "________", ub + st + lstr( m141p ) + st + ue )
  s += " �� " + iif( !fl .or. m141ax == 0, "________", ub + st + lstr( m141ax ) + st + ue )
  s += " Fa " + iif( !fl .or. m141fa == 0, "________", ub + st + lstr( m141fa ) + st + ue ) + "."
  frd->( Eval( blk, s ) )
  fl := ( mpol == "�" .and. lvozrast > 9 )
  s := st + "14.2. ������� ��㫠 ����窨: � " + iif( !fl .or. m142p == 0, "________", ub + st + lstr( m142p ) + st + ue )
  s += " �� " + iif( !fl .or. m142ax == 0, "________", ub + st + lstr( m142ax ) + st + ue )
  s += " Ma " + iif( !fl .or. m142ma == 0, "________", ub + st + lstr( m142ma ) + st + ue )
  s += " Me " + iif( !fl .or. m142me == 0, "________", ub + st + lstr( m142me ) + st + ue ) + ";"
  frd->( Eval( blk, s ) )
  s := st + "�ࠪ���⨪� ������㠫쭮� �㭪樨: menarhe ("
  s += iif( !fl .or. m142me1 == 0, "________", ub + st + lstr( m142me1 ) + st + ue ) + " ���, "
  s += iif( !fl .or. m142me2 == 0, "________", ub + st + lstr( m142me2 ) + st + ue ) + " ����楢); "
  If fl .and. emptyall( m142p, m142ax, m142ma, m142me, m142me1, m142me2 )
    m1142me3 := m1142me4 := m1142me5 := -1
  Endif
  s += "menses (�ࠪ���⨪�): " + f3_inf_dds_karta( mm_142me3(), iif( fl, m1142me3, -1 ),, ub, ue, .f. )
  s += ", " + f3_inf_dds_karta( mm_142me4(), iif( fl, m1142me4, -1 ),, ub, ue, .f. )
  s += ", " + f3_inf_dds_karta( mm_142me5(), iif( fl, m1142me5, -1 ), " � ", ub, ue )
  frd->( Eval( blk, s ) )
  s := st + "15. ����ﭨ� ���஢�� �� �஢������ " + ;
    iif( p_tip_lu == TIP_LU_PN, "�����饣� ��䨫����᪮�� ����樭᪮�� �ᬮ��:", "��ᯠ��ਧ�樨:" )
  frd->( Eval( blk, s ) )
  If lvozrast < 14
    mdef_diagnoz := "Z00.1"
  Else
    mdef_diagnoz := "Z00.3"
  Endif
  s := st + "15.1. �ࠪ��᪨ ���஢ " + iif( m1diag_15_1 == 0, Replicate( "_", 30 ), ub + st + RTrim( mdef_diagnoz ) + st + ue ) + " (��� �� ���)."
  frd->( Eval( blk, s ) )
  //
  mm_dispans := { { "��⠭������ ࠭��", 1 }, { "��⠭������ �����", 2 }, { "�� ��⠭������", 0 } }
  mm_danet := { { "��", 1 }, { "���", 0 } }
  mm_usl := { { "� ���㫠���� �᫮����", 0 }, ;
    { "� �᫮���� �������� ��樮���", 1 }, ;
    { "� ��樮����� �᫮����", 2 } }
  mm_uch := { { "� �㭨樯����� ����樭᪨� �࣠�������", 1 }, ;
    { "� ���㤠��⢥���� ����樭᪨� �࣠������� ��ꥪ� ���ᨩ᪮� �����樨 ", 0 }, ;
    { "� 䥤�ࠫ��� ����樭᪨� �࣠�������", 2 }, ;
    { "����� ����樭᪨� �࣠�������", 3 } }
  mm_uch1 := AClone( mm_uch )
  AAdd( mm_uch1, { "ᠭ��୮-������� �࣠�������", 4 } )
  mm_danet1 := { { "�������", 1 }, { "�� �������", 0 } }
  For i := 1 To 5
    fl := .f.
    For k := 1 To 14
      mvar := "mdiag_15_" + lstr( i ) + "_" + lstr( k )
      If k == 1
        fl := !Empty( &mvar ) .and. m1diag_15_1 == 0
      Else
        m1var := "m1diag_15_" + lstr( i ) + "_" + lstr( k )
        If fl
          Do Case
          Case eq_any( k, 4, 5, 6, 7 )
            mvar := "m1diag_15_" + lstr( i ) + "_3"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            Endif
          Case eq_any( k, 9, 10, 11, 12 )
            mvar := "m1diag_15_" + lstr( i ) + "_8"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            Endif
          Case k == 14
            mvar := "m1diag_15_" + lstr( i ) + "_13"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            Endif
          Endcase
        Else
          &m1var := -1
        Endif
      Endif
    Next
  Next
  For i := 1 To 5
    fl := .f.
    s := s1 := s2 := s3 := s4 := s5 := s6 := ""
    For k := 1 To 14
      mvar := "mdiag_15_" + lstr( i ) + "_" + lstr( k )
      If k == 1
        fl := !Empty( &mvar ) .and. m1diag_15_1 == 0
      Else
        m1var := "m1diag_15_" + lstr( i ) + "_" + lstr( k )
      Endif
      Do Case
      Case k == 1
        s := st + "15." + lstr( i + 1 ) + ". ������� " + iif( !fl, Replicate( "_", 30 ), ub + st + RTrim( &mvar ) + st + ue ) + " (��� �� ���)."
      Case k == 2
        s1 := st + "15." + lstr( i + 1 ) + ".1. ��ᯠ��୮� �������: " + f3_inf_dds_karta( mm_dispans, &m1var,, ub, ue )
      Case k == 3
        s2 := st + "15." + lstr( i + 1 ) + ".2. ��祭�� �뫮 �����祭�: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 4
        s2 := Left( s2, Len( s2 ) -1 ) + '; �᫨ "��": ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 5
        s2 := Left( s2, Len( s2 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch, &m1var,, ub, ue )
      Case k == 6
        s3 := st + "15." + lstr( i + 1 ) + ".3. ��祭�� �뫮 �믮�����: " + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 7
        s3 := Left( s3, Len( s3 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch, &m1var,, ub, ue )
      Case k == 8
        s4 := st + "15." + lstr( i + 1 ) + ".4. ����樭᪠� ॠ������� � (���) ᠭ��୮-����⭮� ��祭�� �뫨 �����祭�: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 9
        s4 := Left( s4, Len( s4 ) -1 ) + '; �᫨ "��": ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 10
        s4 := Left( s4, Len( s4 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch1, &m1var,, ub, ue )
      Case k == 11
        s5 := st + "15." + lstr( i + 1 ) + ".5. ����樭᪠� ॠ������� � (���) ᠭ��୮-����⭮� ��祭�� �뫨 �믮�����: " + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 12
        s5 := Left( s5, Len( s5 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch1, &m1var,, ub, ue )
      Case k == 13
        s6 := st + "15." + lstr( i + 1 ) + ".6. ��᮪��孮����筠� ����樭᪠� ������ �뫠 ४����������: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 14
        s6 := Left( s6, Len( s6 ) -1 ) + '; �᫨ "��": ' + f3_inf_dds_karta( mm_danet1, &m1var,, ub, ue )
      Endcase
    Next
    frd->( Eval( blk, s ) )
    frd->( Eval( blk, s1 ) )
    frd->( Eval( blk, s2 ) )
    frd->( Eval( blk, s3 ) )
    frd->( Eval( blk, s4 ) )
    frd->( Eval( blk, s5 ) )
    frd->( Eval( blk, s6 ) )
  Next
  mm_gruppa := { { "I", 1 }, { "II", 2 }, { "III", 3 }, { "IV", 4 }, { "V", 5 } }
  s := st + "15.9. ��㯯� ���ﭨ� ���஢��: " + f3_inf_dds_karta( mm_gruppa, mGRUPPA_DO,, ub, ue )
  frd->( Eval( blk, s ) )
  If p_tip_lu == TIP_LU_PN
    s := st + "15.10. ����樭᪠� ��㯯� ��� ����⨩ 䨧��᪮� �����ன: "
    s += f3_inf_dds_karta( mm_gr_fiz_do, m1GR_FIZ_DO,, ub, ue )
    frd->( Eval( blk, s ) )
  Endif
  s := st + "16. ����ﭨ� ���஢�� �� १���⠬ �஢������ " + ;
    iif( p_tip_lu == TIP_LU_PN, "�����饣� ��䨫����᪮�� ����樭᪮�� �ᬮ��:", "��ᯠ��ਧ�樨:" )
  frd->( Eval( blk, s ) )
  s := st + "16.1. �ࠪ��᪨ ���஢ " + iif( m1diag_16_1 == 0, Replicate( "_", 30 ), ub + st + RTrim( mkod_diag ) + st + ue ) + " (��� �� ���)."
  frd->( Eval( blk, s ) )
  For i := 1 To 5
    fl := .f.
    For k := 1 To 16
      mvar := "mdiag_16_" + lstr( i ) + "_" + lstr( k )
      If k == 1
        fl := !Empty( &mvar ) .and. m1diag_16_1 == 0
      Else
        m1var := "m1diag_16_" + lstr( i ) + "_" + lstr( k )
        If fl
          Do Case
          Case eq_any( k, 5, 6 )
            mvar := "m1diag_16_" + lstr( i ) + "_4"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            Endif
          Case eq_any( k, 8, 9 )
            mvar := "m1diag_16_" + lstr( i ) + "_7"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            Endif
          Case eq_any( k, 11, 12 )
            mvar := "m1diag_16_" + lstr( i ) + "_10"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            Endif
          Case eq_any( k, 14, 15 )
            mvar := "m1diag_16_" + lstr( i ) + "_13"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            Endif
          Endcase
        Else
          &m1var := -1
        Endif
      Endif
    Next
  Next
  For i := 1 To 5
    fl := .f.
    s := s1 := s2 := s3 := s4 := s5 := s6 := s7 := ""
    For k := 1 To 16
      mvar := "mdiag_16_" + lstr( i ) + "_" + lstr( k )
      If k == 1
        fl := !Empty( &mvar ) .and. m1diag_16_1 == 0
      Else
        m1var := "m1diag_16_" + lstr( i ) + "_" + lstr( k )
      Endif
      Do Case
      Case k == 1
        s := st + "16." + lstr( i + 1 ) + ". ������� " + iif( !fl, Replicate( "_", 30 ), ub + st + RTrim( &mvar ) + st + ue ) + " (��� �� ���)."
      Case k == 2
        s1 := st + "16." + lstr( i + 1 ) + ".1. ������� ��⠭����� �����: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 3
        s2 := st + "16." + lstr( i + 1 ) + ".2. ��ᯠ��୮� �������: " + f3_inf_dds_karta( mm_dispans, &m1var,, ub, ue )
      Case k == 4
        s3 := st + "16." + lstr( i + 1 ) + ".3. �������⥫�� �������樨 � ��᫥������� �����祭�: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 5
        s3 := Left( s3, Len( s3 ) -1 ) + '; �᫨ "��": ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 6
        s3 := Left( s3, Len( s3 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch, &m1var,, ub, ue )
      Case k == 7
        s4 := st + "16." + lstr( i + 1 ) + ".4. �������⥫�� �������樨 � ��᫥������� �믮�����: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 8
        s4 := Left( s4, Len( s4 ) -1 ) + '; �᫨ "��": ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 9
        s4 := Left( s4, Len( s4 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch, &m1var,, ub, ue )
      Case k == 10
        s5 := st + "16." + lstr( i + 1 ) + ".5. ��祭�� �����祭�: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 11
        s5 := Left( s5, Len( s5 ) -1 ) + '; �᫨ "��": ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 12
        s5 := Left( s5, Len( s5 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch, &m1var,, ub, ue )
      Case k == 13
        s6 := st + "16." + lstr( i + 1 ) + ".6. ����樭᪠� ॠ������� � (���) ᠭ��୮-����⭮� ��祭�� �����祭�: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 14
        s6 := Left( s6, Len( s6 ) -1 ) + '; �᫨ "��": ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 15
        s6 := Left( s6, Len( s6 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch1, &m1var,, ub, ue )
      Case k == 16
        s7 := st + "16." + lstr( i + 1 ) + ".7. ��᮪��孮����筠� ����樭᪠� ������ �뫠 ४����������: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Endcase
    Next
    frd->( Eval( blk, s ) )
    frd->( Eval( blk, s1 ) )
    frd->( Eval( blk, s2 ) )
    frd->( Eval( blk, s3 ) )
    frd->( Eval( blk, s4 ) )
    frd->( Eval( blk, s5 ) )
    frd->( Eval( blk, s6 ) )
    frd->( Eval( blk, s7 ) )
  Next
  If m1invalid1 == 0
    m1invalid2 := m1invalid5 := m1invalid6 := m1invalid8 := -1
    minvalid3 := minvalid4 := minvalid7 := CToD( "" )
  Endif
  If Empty( minvalid7 )
    m1invalid8 := -1
  Endif
  s := st + '16.7. ������������: ' + f3_inf_dds_karta( mm_danet, m1invalid1,, ub, ue )
  s := Left( s, Len( s ) -1 ) + '; �᫨ "��": ' + f3_inf_dds_karta( mm_invalid2(), m1invalid2,, ub, ue )
  s := Left( s, Len( s ) -1 ) + '; ��⠭������ ����� (���) ' + iif( Empty( minvalid3 ), Replicate( "_", 15 ), ub + full_date( minvalid3 ) + ue )
  s += '; ��� ��᫥����� �ᢨ��⥫��⢮����� ' + iif( Empty( minvalid4 ), Replicate( "_", 15 ), ub + full_date( minvalid4 ) + ue ) + '.'
  frd->( Eval( blk, s ) )
  s := st + '16.7.1. �����������, ���᫮���訥 ������������� �����������:'
  frd->( Eval( blk, s ) )
  mm_invalid5[ 6, 1 ] := "������� �஢�, �஢�⢮��� �࣠��� � �⤥��� ����襭��, ��������騥 ���㭭� ��堭���;"
  mm_invalid5[ 7, 1 ] := "������� ���ਭ��� ��⥬�, ����ன�⢠ ��⠭�� � ����襭�� ������ �����,"
  ATail( mm_invalid5 )[ 1 ] := "��᫥��⢨� �ࠢ�, ��ࠢ����� � ��㣨� �������⢨� ���譨� ��稭)"
  s := st + '(' + f3_inf_dds_karta( mm_invalid5, m1invalid5, ' ', ub, ue )
  frd->( Eval( blk, s ) )
  s := st + '16.7.2.���� ����襭�� � ���ﭨ� ���஢��:'
  frd->( Eval( blk, s ) )
  s := st + f3_inf_dds_karta( mm_invalid6(), m1invalid6, '; ', ub, ue )
  frd->( Eval( blk, s ) )
  s := st + '16.7.3. �������㠫쭠� �ணࠬ�� ॠ�����樨 ॡ����-��������:'
  frd->( Eval( blk, s ) )
  s := st + '��� �����祭��: ' + iif( Empty( minvalid7 ), Replicate( "_", 15 ), ub + full_date( minvalid7 ) + ue ) + ';'
  frd->( Eval( blk, s ) )
  s := st + '�믮������ �� ������ ��ᯠ��ਧ�樨: ' + f3_inf_dds_karta( mm_invalid8(), m1invalid8,, ub, ue )
  frd->( Eval( blk, s ) )
  s := st + "16.8. ��㯯� ���ﭨ� ���஢��: " + f3_inf_dds_karta( mm_gruppa, mGRUPPA,, ub, ue )
  frd->( Eval( blk, s ) )
  If p_tip_lu == TIP_LU_PN
    s := st + "16.9. ����樭᪠� ��㯯� ��� ����⨩ 䨧��᪮� �����ன: "
    s += f3_inf_dds_karta( mm_gr_fiz, m1GR_FIZ,, ub, ue )
    frd->( Eval( blk, s ) )
  Endif
  s := st + iif( p_tip_lu == TIP_LU_PN, '16.10', '16.9' ) + ;
    '. �஢������ ��䨫����᪨� �ਢ����:'
  frd->( Eval( blk, s ) )
  s := st
  For j := 1 To Len( mm_privivki1() )
    If m1privivki1 == mm_privivki1()[ j, 2 ]
      s += ub
    Endif
    s += mm_privivki1()[ j, 1 ]
    If m1privivki1 == mm_privivki1()[ j, 2 ]
      s += ue
    Endif
    If mm_privivki1()[ j, 2 ] == 0
      s += "; "
    Else
      s += ": " + f3_inf_dds_karta( mm_privivki2(), iif( m1privivki1 == mm_privivki1()[ j, 2 ], m1privivki2, -1 ),, ub, ue, .f. ) + "; "
    Endif
  Next
  s += '�㦤����� � �஢������ ���樭�樨 (ॢ��樭�樨) � 㪠������ ������������ �ਢ���� (�㦭�� ����ભ���): '
  If m1privivki1 > 0 .and. !Empty( mprivivki3 )
    s += ub + AllTrim( mprivivki3 ) + ue
  Endif
  frd->( Eval( blk, s ) )
  s := Replicate( "_", sh ) + "."
  frd->( Eval( blk, s ) )
  s := st + iif( p_tip_lu == TIP_LU_PN, '16.11', '16.10' ) + ;
    '. ���������樨 �� �ନ஢���� ���஢��� ��ࠧ� �����, ०��� ���, ��⠭��, 䨧��᪮�� ࠧ����, ���㭮��䨫��⨪�, ������ 䨧��᪮� �����ன: '
  k := 3
  If !Empty( mrek_form )
    k := 1
    s += ub + AllTrim( mrek_form ) + ue
  Endif
  frd->( Eval( blk, s ) )
  For i := 1 To k
    s := Replicate( "_", sh ) + iif( i == k, ".", "" )
    frd->( Eval( blk, s ) )
  Next
  If p_tip_lu == TIP_LU_PN
    s := st + '16.12. ���������樨 � ����室����� ��⠭������� ��� �த������� ' + ;
      '��ᯠ��୮�� �������, ������ ������� ����������� (���ﭨ�) ' + ;
      '� ��� ���, �� ��祭��, ����樭᪮� ॠ�����樨 � ' + ;
      'ᠭ��୮-����⭮�� ��祭�� � 㪠������ ���� ����樭᪮� ' + ;
      '�࣠����樨 (ᠭ��୮-����⭮� �࣠����樨) � ᯥ樠�쭮�� ' + ;
      '(��������) ���: '
  Else
    s := st + '16.11. ���������樨 �� ��ᯠ��୮�� �������, ��祭��, ' + ;
      '����樭᪮� ॠ�����樨 � ᠭ��୮-����⭮�� ��祭�� � 㪠������ ' + ;
      '�������� (��� ���), ���� ����樭᪮� �࣠����樨 � ᯥ樠�쭮�� ' + ;
      '(��������) ���: '
  Endif
  k := 5
  If !Empty( mrek_disp )
    k := 2
    s += ub + AllTrim( mrek_disp ) + ue
  Endif
  frd->( Eval( blk, s ) )
  For i := 1 To k
    s := Replicate( "_", sh ) + iif( i == k, ".", "" )
    frd->( Eval( blk, s ) )
  Next
  //
  adbf := { { "name", "C", 60, 0 }, ;
    { "data", "C", 10, 0 }, ;
    { "rezu", "C", 17, 0 } }
  dbCreate( fr_data + "1", adbf )
  Use ( fr_data + "1" ) New Alias FRD1
  dbCreate( fr_data + "2", adbf )
  Use ( fr_data + "2" ) New Alias FRD2
  arr := iif( p_tip_lu == TIP_LU_PN, f4_inf_dnl_karta( 1 ), f4_inf_dds_karta( 1 ) )
  For i := 1 To Len( arr )
    Select FRD1
    Append Blank
    frd1->name := arr[ i, 1 ]
    frd1->data := full_date( arr[ i, 2 ] )
  Next
  arr := iif( p_tip_lu == TIP_LU_PN, f4_inf_dnl_karta( 2 ), f4_inf_dds_karta( 2 ) )
  For i := 1 To Len( arr )
    Select FRD2
    Append Blank
    frd2->name := arr[ i, 1 ]
    frd2->data := full_date( arr[ i, 2 ] )
    frd2->rezu := arr[ i, 3 ]
  Next
  //
  Close databases
  call_fr( "mo_030dcu13" )

  Return Nil

// 05.07.13
Function f3_inf_dds_karta( _menu, _i, _r, ub, ue, fl )

  Local j, s := ""

  Default _r To ", ", fl To .t.
  For j := 1 To Len( _menu )
    If _i == _menu[ j, 2 ]
      s += ub
    Endif
    s += LTrim( _menu[ j, 1 ] )
    If _i == _menu[ j, 2 ]
      s += ue
    Endif
    If j < Len( _menu )
      s += _r
    Endif
  Next
  If fl
    s += " (�㦭�� ����ભ���)."
  Endif

  Return s

// 04.05.16
Function f4_inf_dds_karta( par, _etap, et2 )

  Local i, k, arr := {}

  If par == 1
    If iif( _etap == nil, .t., _etap == 1 )
      For i := 1 To Len( dds_arr_osm1() )
        k := 0
        Do Case
        Case i ==  1 // {"��⠫쬮���","", 0, 17,{65},{1112},{"2.83.21"}}, ;
          k := 3
        Case i ==  2 // {"��ਭ���ਭ�����","", 0, 17,{64},{1111, 111101},{"2.83.22"}}, ;
          k := 5
        Case i ==  3 // {"���᪨� ����","", 0, 17,{20},{1135},{"2.83.18"}}, ;
          k := 4
        Case i ==  4 // {"�ࠢ��⮫��-��⮯��","", 0, 17,{100},{1123},{"2.83.19"}}, ;
          k := 6
        Case i ==  5 // {"�����-��������� (����窨)","�", 0, 17,{2},{1101},{"2.83.16"}}, ;
          k := 11
        Case i ==  6 // {"���᪨� �஫��-���஫�� (����稪�)","�", 0, 17,{19},{112603, 113502},{"2.83.17"}}, ;
          k := 10
        Case i ==  7 // {"���᪨� �⮬�⮫�� (� 3 ���)","", 3, 17,{86},{140102},{"2.83.23"}}, ;
          k := 8
        Case i ==  8 // {"���᪨� ���ਭ���� (� 5 ���)","", 5, 17,{21},{1127, 112702, 113402},{"2.83.24"}}, ;
          k := 9
        Case i ==  9 // {"���஫��","", 0, 17,{53},{1109},{"2.83.20"}}, ;
          k := 2
        Case i == 10 // {"��娠��","", 0, 17,{72},{1115},{"2.4.1"}}, ;
          k := 7
        Case i == 11 // {"�������","", 0, 17,{68, 57},{1134, 1110},{"2.83.14","2.83.15"}};
          k := 1
        Endcase
        mvart := "MTAB_NOMov" + lstr( i )
        mvard := "MDATEo" + lstr( i )
        If Between( mvozrast, dds_arr_osm1()[ i, 3 ], dds_arr_osm1()[ i, 4 ] ) .and. ;
            iif( Empty( dds_arr_osm1()[ i, 2 ] ), .t., dds_arr_osm1()[ i, 2 ] == mpol )
          If !emptyany( &mvard, &mvart )
            AAdd( arr, { dds_arr_osm1()[ i, 1 ], &mvard, "", i, k } )
          Endif
        Endif
      Next
    Endif
    If metap == 2 .and. iif( _etap == nil, .t., _etap == 2 )
      Default et2 To 0
      If eq_any( et2, 0, 1 )
        For i := 7 To 8 // �⮬�⮫�� � ���ਭ���� �� 2 �⠯�
          k := 0
          mvart := "MTAB_NOMov" + lstr( i )
          mvard := "MDATEo" + lstr( i )
          If !Between( mvozrast, dds_arr_osm1()[ i, 3 ], dds_arr_osm1()[ i, 4 ] )
            If !emptyany( &mvard, &mvart )
              AAdd( arr, { dds_arr_osm1()[ i, 1 ], &mvard, "", i, k } )
            Endif
          Endif
        Next
      Endif
      If eq_any( et2, 0, 2 )
        For i := 1 To Len( dds_arr_osm2() )
          k := 0
          mvart := "MTAB_NOM2ov" + lstr( i )
          mvard := "MDATE2o" + lstr( i )
          If !emptyany( &mvard, &mvart )
            AAdd( arr, { dds_arr_osm2()[ i, 1 ], &mvard, "", i, k } )
          Endif
        Next
      Endif
    Endif
  Else
    For i := 1 To Len( dds_arr_iss() )
      k := 0
      Do Case
      Case i ==  1 // {"������᪨� ������ ���","", 0, 17,{34},{1107, 1301, 1402, 1702},{"4.2.153"}}, ;
        k := 2
      Case i ==  2 // {"������᪨� ������ �஢�","", 0, 17,{34},{1107, 1301, 1402, 1702},{"4.11.136"}}, ;
        k := 1
      Case i ==  3 // {"��᫥������� �஢�� ���� � �஢�","", 0, 17,{34},{1107, 1301, 1402, 1702},{"4.12.169"}}, ;
        k := 4
      Case i ==  4 // {"�����ப�न�����","", 0, 17,{111},{110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202},{"13.1.1"}}, ;
        k := 13
      Case i ==  5 // {"���ண��� ������ (� 15 ���)","", 15, 17,{78},{1118, 1802},{"7.61.3"}}, ;
        k := 12
      Case i ==  6 // {"��� ��������� ����� (����ᮭ�����) (�� 1 ����)","", 0, 0,{106},{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203},{"8.1.1"}}, ;
        k := 11
      Case i ==  7 // {"��� �⮢����� ������ (� 7 ���)","", 7, 17,{106},{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203},{"8.1.2"}}, ;
        k := 8
      Case i ==  8 // {"��� ���","", 0, 17,{106},{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203},{"8.1.3"}}, ;
        k := 7
      Case i ==  9 // {"��� ⠧����७��� ���⠢�� (�� 1 ����)","", 0, 0,{106},{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203},{"8.1.4"}}, ;
        k := 10
      Case i == 10 // {"��� �࣠��� ���譮� ������ �������᭮� ��䨫����᪮�","", 0, 17,{106},{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203},{"8.2.1"}}, ;
        k := 6
      Case i == 11 // {"��� �࣠��� ९த�⨢��� ��⥬�","", 7, 17,{106},{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203},{"8.2.2","8.2.3"}};
        k := 9
      Endcase
      mvart := "MTAB_NOMiv" + lstr( i )
      mvard := "MDATEi" + lstr( i )
      mvarr := "MREZi" + lstr( i )
      If Between( mvozrast, dds_arr_iss()[ i, 3 ], dds_arr_iss()[ i, 4 ] )
        If !emptyany( &mvard, &mvart )
          AAdd( arr, { dds_arr_iss()[ i, 1 ], &mvard, &mvarr, i, k } )
        Endif
      Endif
    Next
  Endif

  Return arr

// 28.01.15
Function inf_dds_svod( par, par2, is_schet )

  Local arr_m, i, buf := save_maxrow(), lkod_h, lkod_k, rec

  If ( arr_m := year_month( T_ROW, T_COL -5 ) ) != NIL
    mywait()
    If f0_inf_dds( arr_m, is_schet > 1, is_schet == 3 )
      adbf := { ;
        { "nomer",   "N",     6,     0 }, ;
        { "KOD",   "N",     7,     0 }, ; // ��� (����� �����)
        { "KOD_K",   "N",     7,     0 }, ; // ��� �� ����⥪�
        { "FIO",   "C",    50,     0 }, ; // �.�.�. ���쭮��
        { "DATE_R",   "D",     8,     0 }, ; // ��� ஦����� ���쭮��
        { "N_DATA",   "D",     8,     0 }, ; // ��� ��砫� ��祭��
        { "K_DATA",   "D",     8,     0 }, ; // ��� ����砭�� ��祭��
        { "sroki",   "C",    11,     0 }, ; // �ப� ��祭��
        { "noplata",   "N",     1,     0 }, ; //
        { "oplata",   "C",    30,     0 }, ; // �����
        { "CENA_1",   "N",    10,     2 }, ; // ����稢����� �㬬� ��祭��
        { "KOD_DIAG",   "C",     5,     0 }, ; // ��� 1-�� ��.�������
        { "etap",   "N",     1,     0 }, ; //
        { "gruppa_do",   "N",     1,     0 }, ; //
        { "gruppa",   "N",     1,     0 }, ; //
        { "gd1",   "C",     1,     0 }, ; //
        { "gd2",   "C",     1,     0 }, ; //
        { "gd3",   "C",     1,     0 }, ; //
        { "gd4",   "C",     1,     0 }, ; //
        { "gd5",   "C",     1,     0 }, ; //
        { "g1",   "C",     1,     0 }, ; //
        { "g2",   "C",     1,     0 }, ; //
        { "g3",   "C",     1,     0 }, ; //
        { "g4",   "C",     1,     0 }, ; //
        { "g5",   "C",     1,     0 }, ; //
        { "vperv",   "C",     1,     0 }, ; //
        { "dispans",   "C",     1,     0 }, ; //
        { "n1",   "C",     1,     0 }, ; //
        { "n2",   "C",     1,     0 }, ; //
        { "n3",   "C",     1,     0 }, ; //
        { "p1",   "C",     1,     0 }, ; //
        { "p2",   "C",     1,     0 }, ; //
        { "p3",   "C",     1,     0 }, ; //
        { "f1",   "C",     1,     0 }, ; //
        { "f2",   "C",     1,     0 }, ; //
        { "f3",   "C",     1,     0 }, ; //
        { "f4",   "C",     1,     0 }, ; //
        { "f5",   "C",     1,     0 }; //
      }
      For i := 1 To Len( dds_arr_iss() )
        AAdd( adbf, { "di_" + lstr( i ), "C", 8, 0 } )
      Next
      For i := 1 To Len( dds_arr_osm1() )
        AAdd( adbf, { "d1_" + lstr( i ), "C", 8, 0 } )
      Next
      AAdd( adbf, { "d1_zs", "C", 8, 0 } )
      For i := 1 To Len( dds_arr_osm2() )
        AAdd( adbf, { "d2_" + lstr( i ), "C", 8, 0 } )
      Next
      dbCreate( cur_dir() + "tmpfio", adbf )
      r_use( dir_server() + "mo_rak",, "RAK" )
      r_use( dir_server() + "mo_raks",, "RAKS" )
      Set Relation To akt into RAK
      r_use( dir_server() + "mo_raksh",, "RAKSH" )
      Set Relation To kod_raks into RAKS
      Index On Str( kod_h, 7 ) + DToS( rak->DAKT ) to ( cur_dir() + "tmp_raksh" )
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + "human_",, "HUMAN_" ), ;
        r_use( dir_server() + "human",, "HUMAN" ), ;
        dbSetRelation( "HUMAN_", {|| RecNo() }, "recno()" ), ;
        r_use( cur_dir() + "tmp" ), ;
        dbSetRelation( "HUMAN", {|| kod }, "kod" );
        }
      Do While .t.
        Eval( blk_open )
        If rec == NIL
          Go Top
        Else
          Goto ( rec )
          Skip
          If Eof()
            Exit
          Endif
        Endif
        rec := tmp->( RecNo() )
        @ MaxRow(), 0 Say Str( rec / tmp->( LastRec() ) * 100, 6, 2 ) + "%" Color cColorWait
        lkod_h := human->kod
        lkod_k := human->kod_k
        Close databases
        oms_sluch_dds( p_tip_lu, lkod_h, lkod_k, "f2_inf_DDS_svod" )
      Enddo
      Close databases
      delfrfiles()
      r_use( dir_server() + "organiz",, "ORG" )
      adbf := { { "name", "C", 130, 0 }, ;
        { "nomer", "N", 6, 0 }, ;
        { "kol_opl", "N", 6, 0 }, ;
        { "CENA_1", "N", 15, 2 }, ;
        { "period", "C", 250, 0 }, ;
        { "period2", "C", 50, 0 }, ;
        { "kol2", "C", 60, 0 }, ;
        { "kol3", "C", 60, 0 }, ;
        { "kol4", "C", 60, 0 }, ;
        { "gd1",   "N",     8,     0 }, ; //
        { "gd2",   "N",     8,     0 }, ; //
        { "gd3",   "N",     8,     0 }, ; //
        { "gd4",   "N",     8,     0 }, ; //
        { "gd5",   "N",     8,     0 }, ; //
        { "g1",   "N",     8,     0 }, ; //
        { "g2",   "N",     8,     0 }, ; //
        { "g3",   "N",     8,     0 }, ; //
        { "g4",   "N",     8,     0 }, ; //
        { "g5",   "N",     8,     0 }, ; //
        { "vperv",   "N",     8,     0 }, ; //
        { "dispans",   "N",     8,     0 }, ; //
        { "n1",   "N",     8,     0 }, ; //
        { "n2",   "N",     8,     0 }, ; //
        { "n3",   "N",     8,     0 }, ; //
        { "p1",   "N",     8,     0 }, ; //
        { "p2",   "N",     8,     0 }, ; //
        { "p3",   "N",     8,     0 }, ; //
        { "f1",   "N",     8,     0 }, ; //
        { "f2",   "N",     8,     0 }, ; //
        { "f3",   "N",     8,     0 }, ; //
        { "f4",   "N",     8,     0 }, ; //
        { "f5",   "N",     8,     0 } }
      For i := 1 To Len( dds_arr_iss() )
        AAdd( adbf, { "di_" + lstr( i ), "N", 8, 0 } )
      Next
      For i := 1 To Len( dds_arr_osm1() )
        AAdd( adbf, { "d1_" + lstr( i ), "N", 8, 0 } )
      Next
      AAdd( adbf, { "d1_zs", "N", 8, 0 } )
      For i := 1 To Len( dds_arr_osm2() )
        AAdd( adbf, { "d2_" + lstr( i ), "N", 8, 0 } )
      Next
      dbCreate( fr_titl, adbf )
      Use ( fr_titl ) New Alias FRT
      Append Blank
      frt->name := glob_mo[ _MO_SHORT_NAME ]
      frt->period := iif( p_tip_lu == TIP_LU_DDS, ;
        "�ॡ뢠��� � ��樮����� �᫮���� ��⥩-��� � ��⥩, ��室����� � ��㤭�� ��������� ���樨", ;
        "��⥩-��� � ��⥩, ��⠢���� ��� ����祭�� த�⥫��, � ⮬ �᫥ ��뭮����� (㤮�����), �ਭ���� ��� ����� (�����⥫��⢮), � ����� ��� ���஭���� ᥬ��" )
      frt->period2 := arr_m[ 4 ]
      If par2 == 1
        frt->kol2 := "�.�.�"
        frt->kol3 := "��� ஦�����"
        frt->kol4 := "��� ��砫� ��ᯠ��ਧ�樨"
      Else
        frt->kol2 := "������������ ����樭᪮� �࣠����樨"
        frt->kol3 := "������� ������⥫�"
        frt->kol4 := "�����᪨� ������⥫� �믮������: �ᬮ�७�/��ࠡ�⠭� ����"
      Endif
      Copy File ( cur_dir() + "tmpfio" + sdbf() ) to ( fr_data + sdbf() )
      Do Case
      Case par == 1
        Use ( fr_data ) New Alias FRD
        Index On DToS( n_data ) + Upper( fio ) to ( fr_data )
        Go Top
        j := 0
        Do While !Eof()
          frd->nomer := ++j
          Select FRT
          frt->nomer := frd->nomer
          frt->kol_opl += frd->noplata
          frt->cena_1 += frd->cena_1
          For i := 1 To Len( dds_arr_iss() )
            poled := "frd->di_" + lstr( i )
            polet := "frt->di_" + lstr( i )
            If !Empty( &poled )
              &polet := &polet + 1
            Endif
          Next
          For i := 1 To Len( dds_arr_osm1() )
            poled := "frd->d1_" + lstr( i )
            polet := "frt->d1_" + lstr( i )
            If !Empty( &poled )
              &polet := &polet + 1
            Endif
          Next
          If !Empty( frd->d1_zs )
            frt->d1_zs++
          Endif
          For i := 1 To Len( dds_arr_osm2() )
            poled := "frd->d2_" + lstr( i )
            polet := "frt->d2_" + lstr( i )
            If !Empty( &poled )
              &polet := &polet + 1
            Endif
          Next
          Select FRD
          Skip
        Enddo
        Close databases
        call_fr( "mo_ddsTF" )
      Case par == 2
        Use ( fr_data ) New Alias FRD
        Index On DToS( n_data ) + Upper( fio ) to ( fr_data )
        Go Top
        j := 0
        Do While !Eof()
          frd->nomer := ++j
          Select FRT
          frt->nomer := frd->nomer
          For i := 1 To 5
            poled := "frd->gd" + lstr( i )
            polet := "frt->gd" + lstr( i )
            If !Empty( &poled )
              &polet := &polet + 1
            Endif
          Next
          For i := 1 To 5
            poled := "frd->g" + lstr( i )
            polet := "frt->g" + lstr( i )
            If !Empty( &poled )
              &polet := &polet + 1
            Endif
          Next
          If !Empty( frd->vperv )
            frt->vperv++
          Endif
          If !Empty( frd->dispans )
            frt->dispans++
          Endif
          If !Empty( frd->n1 )
            frt->n1++
          Endif
          If !Empty( frd->n2 )
            frt->n2++
          Endif
          If !Empty( frd->n3 )
            frt->n3++
          Endif
          If !Empty( frd->f1 )
            frt->f1++
          Endif
          If !Empty( frd->f3 )
            frt->f3++
          Endif
          If !Empty( frd->f4 )
            frt->f4++
          Endif
          If !Empty( frd->f5 )
            frt->f5++
          Endif
          Select FRD
          Skip
        Enddo
        If par2 == 2
          Select FRD
          Zap
        Endif
        Close databases
        call_fr( "mo_ddsMZ", iif( par2 == 2, 3, ) )
      Endcase
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 04.05.16
Function f2_inf_dds_svod( Loc_kod, kod_kartotek ) // ᢮���� ���ଠ��

  Local i := 0, c, s := "��� ���", pole, arr, ddo := {}, dposle := {}

  r_use( dir_server() + "mo_rak",, "RAK" )
  r_use( dir_server() + "mo_raks",, "RAKS" )
  Set Relation To akt into RAK
  r_use( dir_server() + "mo_raksh",, "RAKSH" )
  Set Relation To kod_raks into RAKS
  Set Index to ( cur_dir() + "tmp_raksh" )
  Select RAKSH
  find ( Str( Loc_kod, 7 ) )
  Do While Loc_kod == raksh->kod_h .and. !Eof()
    If Round( raksh->sump, 2 ) == Round( mCENA_1, 2 )
      i := 1
      s := "����祭"
    Else
      i := 0
      s := "�� ���.: ��� " + AllTrim( rak->NAKT ) + " �� " + date_8( rak->DAKT )
    Endif
    Skip
  Enddo
  Use ( cur_dir() + "tmpfio" ) New Alias TF
  Append Blank
  tf->KOD := Loc_kod
  tf->KOD_K := kod_kartotek
  tf->FIO := mfio
  tf->DATE_R := mdate_r
  tf->N_DATA := mN_DATA
  tf->K_DATA := mK_DATA
  tf->sroki := Left( date_8( mN_DATA ), 5 ) + "-" + Left( date_8( mK_DATA ), 5 )
  tf->noplata := i
  tf->oplata := s
  tf->CENA_1 := mCENA_1
  tf->KOD_DIAG := mkod_diag
  tf->etap := metap
  tf->gruppa_do := mgruppa_do
  If Between( mgruppa_do, 1, 5 )
    pole := "tf->gd" + lstr( mgruppa_do )
    &pole := "X"
  Endif
  tf->gruppa := mgruppa
  If Between( mgruppa, 1, 5 )
    pole := "tf->g" + lstr( mgruppa )
    &pole := "X"
  Endif
  For i := 1 To 5
    pole := "mdiag_16_" + lstr( i ) + "_1"
    If !Empty( &pole )
      AAdd( ddo, AllTrim( &pole ) )
    Endif
  Next
  For i := 1 To 5
    pole := "mdiag_16_" + lstr( i ) + "_1"
    If !Empty( &pole )
      AAdd( dposle, AllTrim( &pole ) )
      pole := "m1diag_16_" + lstr( i ) + "_2"
      if &pole == 1
        tf->vperv := "X"
      Endif
      pole := "m1diag_16_" + lstr( i ) + "_3"
      if &pole == 2
        tf->dispans := "X"
      Endif
      pole := "m1diag_16_" + lstr( i ) + "_13"
      if &pole == 1
        tf->n2 := "X"
        pole := "m1diag_16_" + lstr( i ) + "_15"
        if &pole == 4
          tf->n1 := "X"
        Endif
      Endif
      pole := "m1diag_16_" + lstr( i ) + "_16"
      if &pole == 1
        tf->n3 := "X"
      Endif
    Endif
  Next
  For i := 1 To Len( ddo )
    c := Left( ddo[ i ], 3 )
    If Between( c, "F00", "F69" ) .or. Between( c, "F80", "F99" )
      tf->f3 := "X"
    Endif
  Next
  For i := 1 To Len( dposle )
    If AScan( ddo, dposle[ i ] ) == 0
      tf->f1 := "X"
    Endif
    c := Left( dposle[ i ], 3 )
    If Between( c, "F00", "F69" ) .or. Between( c, "F80", "F99" )
      tf->f4 := "X"
    Endif
  Next
  If !Empty( tf->f3 ) .and. Empty( tf->f4 )
    tf->f5 := "X"
  Endif
  arr := f4_inf_dds_karta( 1, 1 )
  For i := 1 To Len( arr )
    pole := "tf->d1_" + lstr( arr[ i, 4 ] )
    &pole := date_8( arr[ i, 2 ] )
  Next
  tf->d1_zs := mshifr_zs
  arr := f4_inf_dds_karta( 1, 2, 1 ) // �⮬�⮫�� � ���ਭ���� �� 2 �⠯�
  For i := 1 To Len( arr )
    pole := "tf->d1_" + lstr( arr[ i, 4 ] )
    &pole := date_8( arr[ i, 2 ] )
  Next
  arr := f4_inf_dds_karta( 1, 2, 2 ) // ��⠫�� ���� �� 2 �⠯�
  For i := 1 To Len( arr )
    pole := "tf->d2_" + lstr( arr[ i, 4 ] )
    &pole := date_8( arr[ i, 2 ] )
  Next
  arr := f4_inf_dds_karta( 2 )
  For i := 1 To Len( arr )
    pole := "tf->di_" + lstr( arr[ i, 4 ] )
    &pole := date_8( arr[ i, 2 ] )
  Next

  Return Nil

// 20.06.21 �ਫ������ � ����� ���� �14-05/50 �� 07.02.2020�.
Function inf_dds_svod2( par2, is_schet )

  Local arr_m, i, buf := save_maxrow(), lkod_h, lkod_k, rec, sh := 91, HH := 60, n_file := cur_dir() + "ddssvod2.txt"

  If ( arr_m := year_month( T_ROW, T_COL -5 ) ) != NIL
    mywait()
    If f0_inf_dds( arr_m, is_schet > 1, is_schet == 3 )
      Private arr_deti := { ;
        { "1", "�ᥣ�", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, ;
        { "1.1", "0-14 ���", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, ;
        { "1.2", "15-17 ���", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
        }
      Private arr_2510 := { ;
        { '001 ��� 0-14 ��� ���.', 0, 0, 0, 0, 0, 0, 0 }, ;
        { '002 �� ��� ��� �� 1 �.', 0, 0, 0, 0, 0, 0, 0 }, ;
        { '003 ��� 15-17 ��� ���.', 0, 0, 0, 0, 0, 0, 0 }, ;
        { '004 15-17 ��� - �', 0, 0, 0, 0, 0, 0, 0 }, ;
        { '005 誮�쭨��', 0, 0, 0, 0, 0, 0, 0 };
        }
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + "human_",, "HUMAN_" ), ;
        r_use( dir_server() + "human",, "HUMAN" ), ;
        dbSetRelation( "HUMAN_", {|| RecNo() }, "recno()" ), ;
        r_use( cur_dir() + "tmp" ), ;
        dbSetRelation( "HUMAN", {|| kod }, "kod" );
        }

      Do While .t.
        // R_Use_base("human_u")
        Eval( blk_open )
        If rec == NIL
          Go Top
        Else
          Goto ( rec )
          Skip
          If Eof()
            Exit
          Endif
        Endif
        rec := tmp->( RecNo() )
        @ MaxRow(), 0 Say Str( rec / tmp->( LastRec() ) * 100, 6, 2 ) + "%" Color cColorWait
        lkod_h := human->kod
        lkod_k := human->kod_k
        Close databases
        oms_sluch_dds( p_tip_lu, lkod_h, lkod_k, "f2_inf_DDS_svod2" )
      Enddo
      Close databases
      fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
      add_string( glob_mo[ _MO_SHORT_NAME ] )
      If par2 == 3
        add_string( PadL( "�ਫ������", sh ) )
        add_string( PadL( "� ����� ����", sh ) )
        add_string( PadL( "�14-05/50 �� 07.02.2020�.", sh ) )
      Endif
      add_string( "" )
      add_string( Center( "�������� � ��ᯠ��ਧ�樨 ��ᮢ��襭����⭨�,", sh ) )
      If p_tip_lu == TIP_LU_DDS
        add_string( Center( "�ॡ뢠��� � ��樮����� �᫮���� ��⥩-��� � ��⥩,", sh ) )
        add_string( Center( "��室����� � ��㤭�� ��������� ���樨", sh ) )
      Else
        add_string( Center( "��⥩-��� � ��⥩, ��⠢���� ��� ����祭�� த�⥫��, � ⮬ �᫥", sh ) )
        add_string( Center( "��뭮����� (㤮�����), �ਭ���� ��� ����� (�����⥫��⢮),", sh ) )
        add_string( Center( "� ����� ��� ���஭���� ᥬ��", sh ) )
      Endif
      add_string( Center( "[ " + CharRem( "~", mas1pmt[ is_schet ] ) + " ]", sh ) )
      add_string( Center( arr_m[ 4 ], sh ) )
      add_string( "" )
      If par2 == 3
        // add_string("�������������������������������������������������������������������������������������������")
        // add_string("�� � ���⨭- � �ᬮ�७� ��� ��� ᥫ�������           �� ���            ����⮳�� 7���� 14")
        // add_string("�� � �����   �����������������������Ĵ����������������������������������Ĵ�� �������ᥫ� ")
        // add_string("   �         ��ᥣ��� �㡳�ᥣ��� �㡳���ࢳ�஢�� ��� �1�2�ⳤ�堭���饢�ᯠ�ᳫ�祭�     ")
        // add_string("�������������������������������������������������������������������������������������������")
        // add_string(" 1 �    2    �  3  �  4  �  5  �  6  �  7  �  8  �  9  �  10 �  11 �  12 �  13 �  14 �  15 ")
        // add_string("�������������������������������������������������������������������������������������������")
        add_string( "��������������������������������������������������������������������������������������������" )
        add_string( "�� �          �     �ᬮ�७�   ������           �� ���                  ����⮳���⮳�� 6�" )
        add_string( "�� �������⥫������������������Ĵ����������������������������������������Ĵ��   ��� �������" )
        add_string( "   �          ��ᥣ�����ள���������ࢳ�஢�� ��� ���_�� �����������饢��᪠�ᯠ�ᳫ�祭" )
        add_string( "��������������������������������������������������������������������������������������������" )
        add_string( " 1 �    2     �  3  �  4  �  5  �  6  �  7  �  8  �  9  �  10 �  11 �  12 �  13 �  14 �  15 " )
        add_string( "��������������������������������������������������������������������������������������������" )
        For i := 1 To 3
          s := PadR( arr_deti[ i, 1 ], 4 ) + PadR( arr_deti[ i, 2 ], 9 )
          s += put_val( arr_deti[ i, 3 ], 6 )
          s += put_val( arr_deti[ i, 16 ], 6 ) // ���஫��
          s += put_val( arr_deti[ i, 17 ], 6 ) // ���������
          s += put_val( arr_deti[ i, 7 ], 6 )
          s += put_val( arr_deti[ i, 8 ], 6 )
          s += put_val( arr_deti[ i, 9 ], 6 )
          s += put_val( arr_deti[ i, 21 ], 6 ) // ����- �離�
          s += put_val( arr_deti[ i, 18 ], 6 ) // �����
          s += put_val( arr_deti[ i, 19 ], 6 ) // ���ਭ��
          // s += put_val(arr_deti[i, 11], 6)
          s += put_val( arr_deti[ i, 12 ], 6 )
          s += put_val( arr_deti[ i, 20 ], 6 ) // 䠪��� �᪠
          s += put_val( arr_deti[ i, 13 ], 6 )
          s += put_val( arr_deti[ i, 14 ], 6 )
          // for j := 3 to 15
          // s += put_val(arr_deti[i,j], 6)
          // next
          add_string( s )
          add_string( Replicate( "�", sh ) )
        Next
      Else
        add_string( "�������������������������������������������������������������������" )
        add_string( "                         ���᫮ ��⥩�     �� ��㯯�� ���஢��     " )
        add_string( "     ��� - ����       ������������������������������������������" )
        add_string( "     ⠡��� 2510        ��ᥣ�� ᥫ��  1  �  2  �  3  �  4  �  5  " )
        add_string( "�������������������������������������������������������������������" )
        add_string( "                         �  5  �  6  �  7  �  8  �  9  �  12 �  13 " )
        add_string( "�������������������������������������������������������������������" )
        For i := 1 To Len( arr_2510 )
          s := PadR( arr_2510[ i, 1 ], 25 )
          For j := 2 To Len( arr_2510[ i ] )
            s += put_val( arr_2510[ i, j ], 6 )
          Next
          add_string( s )
        Next
      Endif
      FClose( fp )
      viewtext( n_file,,,, .t.,,, 2 )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil


// 20.06.21
Function f2_inf_dds_svod2( Loc_kod, kod_kartotek )

  Local i, j, k, is_selo, ad := {}, ar := { 1 }, ar1 := {}, ;
    ar2 := Array( Len( arr_deti[ 1 ] ) )

  If mvozrast < 15
    AAdd( ar, 2 )
  Else
    AAdd( ar, 3 )
  Endif
  //
  For i := 1 To 5
    j := 0
    For k := 1 To 3
      s := "diag_16_" + lstr( i ) + "_" + lstr( k )
      mvar := "m" + s
      If k == 1
        If !Empty( &mvar )
          arr := { AllTrim( &mvar ), 0, 0 }
          If Len( arr[ 1 ] ) > 5
            arr[ 1 ] := Left( arr[ 1 ], 5 )
          Endif
          AAdd( ad, arr ) ; j := Len( ad )
        Endif
      Elseif j > 0
        m1var := "m1" + s
        ad[ j, k ] := &m1var
      Endif
    Next
  Next


  r_use( dir_server() + "kartote2",, "KART2" )
  Goto ( kod_kartotek )
  r_use( dir_server() + "kartote_",, "KART_" )
  Goto ( kod_kartotek )

  r_use( dir_server() + "uslugi",, "USL" )
  r_use_base( "human_u" )
  // R_Use(dir_server() + "human_",,"HUMAN_")
  r_use( dir_server() + "human",, "HUMAN" )
  // set relation to recno() into HUMAN_, to kod_k into KART_
  // use (cur_dir() + "tmp") new
  // set relation to kod into HUMAN
  // go top



  r_use( dir_server() + "kartotek",, "KART" )
  Goto ( kod_kartotek )
  is_selo := f_is_selo( kart_->gorod_selo, kart_->okatog )
  If mvozrast == 0
    AAdd( ar1, 2 )
  Endif
  If mvozrast < 15
    AAdd( ar1, 1 )
  Else
    AAdd( ar1, 3 )
    If kart->pol == "�"
      AAdd( ar1, 4 )
    Endif
  Endif
  If mvozrast > 6 // 誮�쭨�� ?
    AAdd( ar1, 5 )
  Endif
  //
  AFill( ar2, 0 )
  For i := 1 To Len( ad ) // 横� �� ���������
    If !( Left( ad[ i, 1 ], 1 ) == "A" .or. Left( ad[ i, 1 ], 1 ) == "B" ) .and. ad[ i, 2 ] == 1 // ����䥪樮��� ����������� ���.�����
      // arr_deti[k, 7] ++
      ar2[ 7 ] := 1
      If Left( ad[ i, 1 ], 1 ) == "I" // ������� ��⥬� �஢����饭��
        ar2[ 8 ] := 1     // arr_deti[k, 8] ++
      Endif
      If Left( ad[ i, 1 ], 1 ) == "J" // ������� �࣠��� ��堭��
        ar2[ 11 ] := 1      // arr_deti[k, 11] ++
      Endif
      If Left( ad[ i, 1 ], 1 ) == "K" // ������� �࣠��� ��饢�७��
        ar2[ 12 ] := 1     // arr_deti[k, 12] ++
      Endif
      If Left( ad[ i, 1 ], 1 ) == "H" // ������� ����
        ar2[ 18 ] := 1    // arr_deti[k, 18] ++
      Endif
      If Left( ad[ i, 1 ], 1 ) == "E" // ������� ���ਭ������
        ar2[ 19 ] := 1  // arr_deti[k, 19] ++
      Endif
      If Left( ad[ i, 1 ], 1 ) == "M" // ������� ���⭮-���筮� ��⥬�
        ar2[ 21 ] := 1  // arr_deti[k, 21] ++
      Endif
      //
      If Left( ad[ i, 1 ], 3 ) == "E78"
        ar2[ 20 ] := 1
      Elseif Left( ad[ i, 1 ], 5 ) == "R73.9"
        ar2[ 20 ] := 1
      Elseif Left( ad[ i, 1 ], 5 ) == "Z72.0"
        ar2[ 20 ] := 1
      Elseif Left( ad[ i, 1 ], 5 ) == "Z72.4"
        ar2[ 20 ] := 1
      Elseif Left( ad[ i, 1 ], 5 ) == "R63.5"
        ar2[ 20 ] := 1
      Elseif Left( ad[ i, 1 ], 5 ) == "Z72.3"
        ar2[ 20 ] := 1
      Elseif Left( ad[ i, 1 ], 5 ) == "Z72.1"
        ar2[ 20 ] := 1
      Elseif Left( ad[ i, 1 ], 5 ) == "Z72.2"
        ar2[ 20 ] := 1
      Endif
      //
      If Left( ad[ i, 1 ], 1 ) == "C" .or. Between( Left( ad[ i, 1 ], 3 ), "D00", "D09" ) // ���
        ar2[ 9 ] := 1  // arr_deti[k, 9] ++
      Endif
      If ad[ i, 3 ] > 0
        ar2[ 13 ] := 1  // arr_deti[k, 13] ++  // ����� �� ��ᯠ�୮� �������
      Endif
      If m1napr_stac > 0 // ���ࠢ��� �� ��祭��
        ar2[ 14 ] := 1 // arr_deti[k, 14] ++ // ��⠥�, �� �뫮 ���� ��祭��
        If is_selo
          ar2[ 15 ] := 1   // arr_deti[k, 15] ++
        Endif
      Endif
    Endif
  Next i
  // ���� ������ ����� ⥫�
  If m1fiz_razv1 == 1
    ar2[ 20 ] := 1
  Endif

  For j := 1 To 2
    k := ar[ j ]
    arr_deti[ k, 3 ] ++
    If DoW( mk_data ) == 7 // �㡡��
      arr_deti[ k, 4 ] ++
    Endif
    If is_selo
      arr_deti[ k, 5 ] ++
      If DoW( mk_data ) == 7 // �㡡��
        arr_deti[ k, 6 ] ++
      Endif
    Endif
    //
    For i := 7 To Len( ar2 )
      arr_deti[ k, i ] += ar2[ i ]
    Next
  Next
  //
  fl := .f.
  //

  //
  Select HU
  find ( Str( Loc_kod, 7 ) )
  Do While hu->kod == Loc_kod .and. !Eof()
    If eq_any( hu_->PROFIL, 19, 136 )
      fl := .t.
    Endif
    usl->( dbGoto( hu->u_kod ) )
    If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
      lshifr := usl->shifr
    Endif
    If Left( lshifr, 2 ) == "2."  // ��祡�� ���
      If hu_->PROFIL == 19
        // ar2[16] := 1
        arr_deti[ k, 16 ] ++
      Endif
      If hu_->PROFIL == 136
        // ar2[17] := 1
        arr_deti[ k, 17 ] ++
      Endif
    Endif
    Select HU
    Skip
  Enddo
  //
  For j := 1 To Len( ar1 )
    k := ar1[ j ]
    arr_2510[ k, 2 ] ++
    If is_selo
      arr_2510[ k, 3 ] ++
    Endif
    If Between( mgruppa, 1, 5 )
      arr_2510[ k, 3 + mgruppa ] ++
    Endif
  Next

  Return Nil

// 08.11.13
Function inf_dds_030dso( is_schet )

  Local arr_m, i, n, buf := save_maxrow(), lkod_h, lkod_k, rec, sh := 80, HH := 80, n_file := cur_dir() + "f_030dso.txt", d1, d2

  If ( arr_m := year_month( T_ROW, T_COL -5 ) ) != NIL
    mywait()
    If f0_inf_dds( arr_m, is_schet > 1, is_schet == 3 )
      Private arr_deti[ 5 ] ; AFill( arr_deti, 0 )
      Private s12_1 := 0, s12_1m := 0, s12_2 := 0, s12_2m := 0
      Private arr_vozrast := { ;
        { 4, 0, 4 }, ;
        { 5, 5, 9 }, ;
        { 6, 10, 14 }, ;
        { 7, 15, 17 }, ;
        { 8, 0, 14 }, ;
        { 9, 0, 17 };
        }
      Private arr1vozrast := { ;
        { 0, 17 }, ;
        { 0, 14 }, ;
        { 0, 4 }, ;
        { 5, 9 }, ;
        { 10, 14 }, ;
        { 15, 17 };
        }
      Private arr_4 := { ;
        { "1", "������� ��䥪樮��� � ��ࠧ��...", "A00-B99",, }, ;
        { "1.1", "�㡥�㫥�", "A15-A19",, }, ;
        { "1.2", "���-��䥪��, ����", "B20-B24",, }, ;
        { "2", "������ࠧ������", "C00-D48",, }, ;
        { "3", "������� �஢� � �஢�⢮��� �࣠��� ...", "D50-D89",, }, ;
        { "3.1", "������", "D50-D53",, }, ;
        { "4", "������� ���ਭ��� ��⥬�, ����ன�⢠...", "E00-E90",, }, ;
        { "4.1", "���� ������", "E10-E14",, }, ;
        { "4.2", "�������筮��� ��⠭��", "E40-E46",, }, ;
        { "4.3", "���७��", "E66",, }, ;
        { "4.4", "����প� �������� ࠧ����", "E30.0",, }, ;
        { "4.5", "�०���६����� ������� ࠧ��⨥", "E30.1",, }, ;
        { "5", "����᪨� ����ன�⢠ � �����...", "F00-F99",, }, ;
        { "5.1", "��⢥���� ���⠫����", "F70-F79",, }, ;
        { "6", "������� ��ࢭ�� ��⥬�, �� ���:", "G00-G98",, }, ;
        { "6.1", "�ॡࠫ�� ��ࠫ�� � ��㣨� ...", "G80-G83",, }, ;
        { "7", "������� ����� � ��� �ਤ��筮�� ������", "H00-H59",, }, ;
        { "8", "������� �� � ��楢������ ����⪠", "H60-H95",, }, ;
        { "9", "������� ��⥬� �஢����饭��", "I00-I99",, }, ;
        { "10", "������� �࣠��� ��堭��, �� ���:", "J00-J99",, }, ;
        { "10.1", "��⬠, ��⬠��᪨� �����", "J45-J46",, }, ;
        { "11", "������� �࣠��� ��饢�७��", "K00-K93",, }, ;
        { "12", "������� ���� � ��������� �����⪨", "L00-L99",, }, ;
        { "13", "������� ���⭮-���筮� ...", "M00-M99",, }, ;
        { "13.1", "��䮧, ��म�, ᪮����", "M40-M41",, }, ;
        { "14", "������� ��祯������ ��⥬�, �� ���:", "N00-N99",, }, ;
        { "14.1", "������� ��᪨� ������� �࣠���", "N40-N51",, }, ;
        { "14.2", "����襭�� �⬠ � �ࠪ�� �������権", "N91-N94.5",, }, ;
        { "14.3", "��ᯠ��⥫�� ����������� ...", "N70-N77",, }, ;
        { "14.4", "����ᯠ��⥫�� ������� ...", "N83-N83.9",, }, ;
        { "14.5", "������� ����筮� ������", "N60-N64",, }, ;
        { "15", "�⤥��� ���ﭨ�, �������...", "P00-P96",, }, ;
        { "16", "�஦����� �������� (��ப� ...", "Q00-Q99",, }, ;
        { "16.1", "ࠧ���� ��ࢭ�� ��⥬�", "Q00-Q07",, }, ;
        { "16.2", "��⥬� �஢����饭��", "Q20-Q28",, }, ;
        { "16.3", "���⭮-���筮� ��⥬�", "Q65-Q79",, }, ;
        { "16.4", "���᪨� ������� �࣠���", "Q50-Q52",, }, ;
        { "16.5", "��᪨� ������� �࣠���", "Q53-Q55",, }, ;
        { "17", "�ࠢ��, ��ࠢ����� � �������...", "S00-T98",, }, ;
        { "18", "��稥", "",, }, ;
        { "19", "����� �����������", "A00-T98",, };
      }
      For n := 1 To Len( arr_4 )
        If "-" $ arr_4[ n, 3 ]
          d1 := Token( arr_4[ n, 3 ], "-", 1 )
          d2 := Token( arr_4[ n, 3 ], "-", 2 )
        Else
          d1 := d2 := arr_4[ n, 3 ]
        Endif
        arr_4[ n, 4 ] := diag_to_num( d1, 1 )
        arr_4[ n, 5 ] := diag_to_num( d2, 2 )
      Next
      dbCreate( cur_dir() + "tmp4", { { "name", "C", 100, 0 }, ;
        { "diagnoz", "C", 20, 0 }, ;
        { "stroke", "C", 4, 0 }, ;
        { "ns", "N", 2, 0 }, ;
        { "diapazon1", "N", 10, 0 }, ;
        { "diapazon2", "N", 10, 0 }, ;
        { "tbl", "N", 1, 0 }, ;
        { "k04", "N", 8, 0 }, ;
        { "k05", "N", 8, 0 }, ;
        { "k06", "N", 8, 0 }, ;
        { "k07", "N", 8, 0 }, ;
        { "k08", "N", 8, 0 }, ;
        { "k09", "N", 8, 0 }, ;
        { "k10", "N", 8, 0 }, ;
        { "k11", "N", 8, 0 } } )
      Use ( cur_dir() + "tmp4" ) New Alias TMP
      For i := 1 To Len( arr_vozrast )
        For n := 1 To Len( arr_4 )
          Append Blank
          tmp->tbl := arr_vozrast[ i, 1 ]
          tmp->stroke := arr_4[ n, 1 ]
          tmp->name := arr_4[ n, 2 ]
          tmp->ns := n
          tmp->diagnoz := arr_4[ n, 3 ]
          tmp->diapazon1 := arr_4[ n, 4 ]
          tmp->diapazon2 := arr_4[ n, 5 ]
        Next
      Next
      Index On Str( tbl, 1 ) + Str( ns, 2 ) to ( cur_dir() + "tmp4" )
      Use
      dbCreate( cur_dir() + "tmp10", { { "voz", "N", 1, 0 }, ;
        { "tbl", "N", 2, 0 }, ;
        { "tip", "N", 1, 0 }, ;
        { "kol", "N", 6, 0 } } )
      Use ( cur_dir() + "tmp10" ) New Alias TMP10
      Index On Str( voz, 1 ) + Str( tbl, 1 ) + Str( tip, 1 ) to ( cur_dir() + "tmp10" )
      Use
      Copy file tmp10.dbf To tmp11.dbf
      Use ( cur_dir() + "tmp11" ) New Alias TMP11
      Index On Str( voz, 1 ) + Str( tbl, 2 ) + Str( tip, 1 ) to ( cur_dir() + "tmp11" )
      Use
      dbCreate( cur_dir() + "tmp13", { { "voz", "N", 1, 0 }, ;
        { "tip", "N", 2, 0 }, ;
        { "kol", "N", 6, 0 } } )
      Use ( cur_dir() + "tmp13" ) New Alias TMP13
      Index On Str( voz, 1 ) + Str( tip, 2 ) to ( cur_dir() + "tmp13" )
      Use
      dbCreate( cur_dir() + "tmp16", { { "voz", "N", 1, 0 }, ;
        { "man", "N", 1, 0 }, ;
        { "tip", "N", 2, 0 }, ;
        { "kol", "N", 6, 0 } } )
      Use ( cur_dir() + "tmp16" ) New Alias TMP16
      Index On Str( voz, 1 ) + Str( man, 1 ) + Str( tip, 2 ) to ( cur_dir() + "tmp16" )
      Use
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + "human_",, "HUMAN_" ), ;
        r_use( dir_server() + "human",, "HUMAN" ), ;
        dbSetRelation( "HUMAN_", {|| RecNo() }, "recno()" ), ;
        r_use( cur_dir() + "tmp" ), ;
        dbSetRelation( "HUMAN", {|| kod }, "kod" );
        }
      Do While .t.
        Eval( blk_open )
        If rec == NIL
          Go Top
        Else
          Goto ( rec )
          Skip
          If Eof()
            Exit
          Endif
        Endif
        rec := tmp->( RecNo() )
        @ MaxRow(), 0 Say Str( rec / tmp->( LastRec() ) * 100, 6, 2 ) + "%" Color cColorWait
        lkod_h := human->kod
        lkod_k := human->kod_k
        Close databases
        oms_sluch_dds( p_tip_lu, lkod_h, lkod_k, "f2_inf_DDS_030dso" )
      Enddo
      Close databases
      fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
      add_string( glob_mo[ _MO_SHORT_NAME ] )
      add_string( PadL( "�ਫ������ 3", sh ) )
      add_string( PadL( "� �ਪ��� ����", sh ) )
      add_string( PadL( "�72� �� 15.02.2013�.", sh ) )
      add_string( "" )
      add_string( PadL( "���⭠� �ଠ � 030-�/�/�-13", sh ) )
      add_string( "" )
      add_string( Center( "�������� � ��ᯠ��ਧ�樨 ��ᮢ��襭����⭨�,", sh ) )
      If p_tip_lu == TIP_LU_DDS
        add_string( Center( "�ॡ뢠��� � ��樮����� �᫮���� ��⥩-��� � ��⥩,", sh ) )
        add_string( Center( "��室����� � ��㤭�� ��������� ���樨", sh ) )
      Else
        add_string( Center( "��⥩-��� � ��⥩, ��⠢���� ��� ����祭�� த�⥫��, � ⮬ �᫥", sh ) )
        add_string( Center( "��뭮����� (㤮�����), �ਭ���� ��� ����� (�����⥫��⢮),", sh ) )
        add_string( Center( "� ����� ��� ���஭���� ᥬ��", sh ) )
      Endif
      add_string( Center( "[ " + CharRem( "~", mas1pmt[ is_schet ] ) + " ]", sh ) )
      add_string( Center( arr_m[ 4 ], sh ) )
      add_string( "" )
      add_string( "2. ��᫮ ��⥩, ��襤�� ��ᯠ��ਧ��� � ���⭮� ��ਮ��:" )
      add_string( "  2.1. �ᥣ� � ������ �� 0 �� 17 ��� �����⥫쭮:" + Str( arr_deti[ 1 ], 6 ) + " (祫����), �� ���:" )
      add_string( "  2.1.1. � ������ �� 0 �� 4 ��� �����⥫쭮      " + Str( arr_deti[ 2 ], 6 ) + " (祫����)," )
      add_string( "  2.1.2. � ������ �� 5 �� 9 ��� �����⥫쭮      " + Str( arr_deti[ 3 ], 6 ) + " (祫����)," )
      add_string( "  2.1.3. � ������ �� 10 �� 14 ��� �����⥫쭮    " + Str( arr_deti[ 4 ], 6 ) + " (祫����)," )
      add_string( "  2.1.4. � ������ �� 15 �� 17 ��� �����⥫쭮    " + Str( arr_deti[ 5 ], 6 ) + " (祫����)." )
      For i := 1 To Len( arr_vozrast )
        verify_ff( HH -50, .t., sh )
        add_string( "" )
        add_string( Center( lstr( arr_vozrast[ i, 1 ] ) + ;
          ". ������� ������� ������������ (���ﭨ�) � ��⥩ � ������ �� " + ;
          lstr( arr_vozrast[ i, 2 ] ) + " �� " + lstr( arr_vozrast[ i, 3 ] ) + " ��� �����⥫쭮", sh ) )
        add_string( "��������������������������������������������������������������������������������" )
        add_string( " �� �    ������������   � ��� ����ᥣ��� �.糢��-�� �.糑��⮨� ��� ���.�����" )
        add_string( " �� �    �����������    � ���-10���ॣ�����-����� �����-������������������������" )
        add_string( "    �                   �       �������稪� ����ࢳ稪� ��ᥣ������糢��⮳�����" )
        add_string( "��������������������������������������������������������������������������������" )
        add_string( " 1  �          2        �   3   �  4  �  5  �  6  �  7  �  8  �  9  � 10  � 11  " )
        add_string( "��������������������������������������������������������������������������������" )
        Use ( cur_dir() + "tmp4" ) index ( cur_dir() + "tmp4" ) New Alias TMP
        find ( Str( arr_vozrast[ i, 1 ], 1 ) )
        Do While tmp->tbl == arr_vozrast[ i, 1 ] .and. !Eof()
          s := tmp->stroke + " " + PadR( tmp->name, 19 ) + " " + PadC( AllTrim( tmp->diagnoz ), 7 )
          For n := 4 To 11
            s += put_val( tmp->&( "k" + StrZero( n, 2 ) ), 6 )
          Next
          add_string( s )
          Skip
        Enddo
        Use
        add_string( Replicate( "�", sh ) )
      Next
      arr1title := { ;
        "��������������������������������������������������������������������������������", ;
        "                    �   �ᥣ�   �   � ��    �   � ���   �� 䥤�ࠫ�-� � ����� ", ;
        "  ������ ��⥩     �           �           ���ꥪ� ���  ��� ���  �    ��     ", ;
        "                    �           �           �           �           �           ", ;
        "��������������������������������������������������������������������������������", ;
        "          1         �     2     �     3     �     4     �     5     �     6     ", ;
        "��������������������������������������������������������������������������������" }
      arr2title := { ;
        "��������������������������������������������������������������������������������", ;
        "                    �   �ᥣ�   �� �㭨�.�� �   � ���   �� 䥤�ࠫ�-� � ����� ", ;
        "  ������ ��⥩     �����������������������Ĵ��ꥪ� ����ĭ�� ���������Č������", ;
        "                    � ���.�  %  � ���.�  %  � ���.�  %  � ���.�  %  � ���.�  %  ", ;
        "��������������������������������������������������������������������������������", ;
        "          1         �  2  �  3  �  4  �  5  �  6  �  7  �  8  �  9  �  10 �  11 ", ;
        "��������������������������������������������������������������������������������" }
      arr3title := { ;
        "��������������������������������������������������������������������������������", ;
        " ������   �ᥣ�   �   � ��    �   � ���   �� 䥤�ࠫ�-� � ����� �� ᠭ��୮", ;
        " ��⥩  �           �           ���ꥪ� ���  ��� ���  �    ��     �-������� ", ;
        "        �           �           �           �           �           ��࣠���-�� ", ;
        "��������������������������������������������������������������������������������", ;
        "    1   �     2     �     3     �     4     �     5     �     6     �     7     ", ;
        "��������������������������������������������������������������������������������" }
      arr4title := { ;
        "��������������������������������������������������������������������������������", ;
        " ������   �ᥣ�   �� �㭨�.�� �   � ���   �� 䥤�ࠫ�-� � ����� �� ᠭ.-���.", ;
        " ��⥩  �����������������������Ĵ��ꥪ� ����ĭ�� ���������Č��������Į�-�����", ;
        "        � ���.�  %  � ���.�  %  � ���.�  %  � ���.�  %  � ���.�  %  � ���.�  %  ", ;
        "��������������������������������������������������������������������������������", ;
        "    1   �  2  �  3  �  4  �  5  �  6  �  7  �  8  �  9  �  10 �  11 �  12 �  13 ", ;
        "��������������������������������������������������������������������������������" }
      verify_ff( HH -50, .t., sh )
      add_string( "10. �������� �������⥫��� �������権, ��᫥�������, ��祭�� � ����樭᪮�" )
      add_string( "    ॠ�����樨 ��⥩ �� १���⠬ �஢������ �����饩 ��ᯠ��ਧ�樨:" )
      Use ( cur_dir() + "tmp10" ) index ( cur_dir() + "tmp10" ) New Alias TMP10
      For i := 1 To 8
        verify_ff( HH -16, .t., sh )
        add_string( "" )
        s := Space( 5 )
        If i == 1
          add_string( s + "10.1. �㦤����� � �������⥫��� ���������� � ��᫥��������" )
          add_string( s + "      � ���㫠���� �᫮���� � � �᫮���� �������� ��樮���" )
        Elseif i == 2
          add_string( s + "10.2. ��諨 �������⥫�� �������樨 � ��᫥�������" )
          add_string( s + "      � ���㫠���� �᫮���� � � �᫮���� �������� ��樮���" )
        Elseif i == 3
          add_string( s + "10.3. �㦤����� � �������⥫��� ���������� � ��᫥��������" )
          add_string( s + "      � ��樮����� �᫮����" )
        Elseif i == 4
          add_string( s + "10.4. ��諨 �������⥫�� �������樨 � ��᫥�������" )
          add_string( s + "      � ��樮����� �᫮����" )
        Elseif i == 5
          add_string( s + "10.5. ������������� ��祭�� � ���㫠���� �᫮���� � � �᫮����" )
          add_string( s + "      �������� ��樮���" )
        Elseif i == 6
          add_string( s + "10.6. ������������� ��祭�� � ��樮����� �᫮����" )
        Elseif i == 7
          add_string( s + "10.7. ������������� ����樭᪠� ॠ�������" )
          add_string( s + "      � ���㫠���� �᫮���� � � �᫮���� �������� ��樮���" )
        Else
          add_string( s + "10.8. ������������� ����樭᪠� ॠ������� � (���)" )
          add_string( s + "      ᠭ��୮-����⭮� ��祭�� � ��樮����� �᫮����" )
        Endif
        n := 20
        If eq_any( i, 1, 3, 5, 6, 7 )
          AEval( arr1title, {| x| add_string( x ) } )
        Elseif eq_any( i, 2, 4 )
          AEval( arr2title, {| x| add_string( x ) } )
        Else
          AEval( arr3title, {| x| add_string( x ) } )
          n := 8
        Endif
        For j := 1 To Len( arr1vozrast )
          s := PadC( lstr( arr1vozrast[ j, 1 ] ) + " - " + lstr( arr1vozrast[ j, 2 ] ), n )
          skol := oldkol := 0
          s1 := ""
          For k := 1 To iif( i == 8, 5, 4 )
            find ( Str( j, 1 ) + Str( i, 1 ) + Str( k, 1 ) )
            If Found() .and. ( v := tmp10->kol ) > 0
              skol += v
              If eq_any( i, 2, 4 )
                s1 += Str( v, 6 )
                find ( Str( j, 1 ) + Str( i -1, 1 ) + Str( k, 1 ) )
                If Found() .and. tmp10->kol > 0
                  s1 += " " + umest_val( v / tmp10->kol * 100, 5, 2 )
                  oldkol += tmp10->kol
                Else
                  s1 += Space( 6 )
                Endif
              Else
                s1 += " " + PadC( lstr( v ), 11 )
              Endif
            Else
              s1 += Space( 12 )
            Endif
          Next
          If skol > 0
            If eq_any( i, 2, 4 )
              s += Str( skol, 6 ) + " " + umest_val( skol / oldkol * 100, 5, 2 )
            Else
              s += " " + PadC( lstr( skol ), 11 )
            Endif
            add_string( s + s1 )
          Else
            add_string( s )
          Endif
        Next
        add_string( Replicate( "�", sh ) )
      Next
      Use
      //
      verify_ff( HH -50, .t., sh )
      add_string( "11. �������� ��祭��, ����樭᪮� ॠ�����樨 � (���) ᠭ��୮-����⭮��" )
      add_string( "    ��祭�� ��⥩ �� �஢������ �����饩 ��ᯠ��ਧ�樨:" )
      vkol := 0
      Use ( cur_dir() + "tmp11" ) index ( cur_dir() + "tmp11" ) New Alias TMP11
      For i := 1 To 12
        If i % 3 > 0
          verify_ff( HH -16, .t., sh )
          add_string( "" )
        Endif
        s := Space( 5 )
        If i == 1
          add_string( s + "11.1. ������������� ��祭�� � ���㫠���� �᫮���� � � �᫮����" )
          add_string( s + "      �������� ��樮���" )
        Elseif i == 2
          add_string( s + "11.2. �஢����� ��祭�� � ���㫠���� �᫮���� � � �᫮����" )
          add_string( s + "      �������� ��樮���" )
        Elseif i == 3
          add_string( s + "11.3. ��稭� ���믮������ ४������権 �� ��祭�� � ���㫠���� �᫮����" )
          add_string( s + "      � � �᫮���� �������� ��樮���:" )
          add_string( s + "        11.3.1. �� ��諨 �ᥣ� " + lstr( vkol ) + " (祫����)" )
        Elseif i == 4
          add_string( s + "11.4. ������������� ��祭�� � ��樮����� �᫮����" )
        Elseif i == 5
          add_string( s + "11.5. �஢����� ��祭�� � ��樮����� �᫮����" )
        Elseif i == 6
          add_string( s + "11.6. ��稭� ���믮������ ४������権 �� ��祭�� � ��樮����� �᫮����:" )
          add_string( s + "        11.6.1. �� ��諨 �ᥣ� " + lstr( vkol ) + " (祫����)" )
        Elseif i == 7
          add_string( s + "11.7. ������������� ����樭᪠� ॠ�������" )
          add_string( s + "      � ���㫠���� �᫮���� � � �᫮���� �������� ��樮���" )
        Elseif i == 8
          add_string( s + "11.8. �஢����� ����樭᪠� ॠ�������" )
          add_string( s + "      � ���㫠���� �᫮���� � � �᫮���� �������� ��樮���" )
        Elseif i == 9
          add_string( s + "11.9. ��稭� ���믮������ ४������権 �� ����樭᪮� ॠ�����樨" )
          add_string( s + "      � ���㫠���� �᫮���� � � �᫮���� �������� ��樮���:" )
          add_string( s + "        11.9.1. �� ��諨 �ᥣ� " + lstr( vkol ) + " (祫����)" )
        Elseif i == 10
          add_string( s + "11.10. ������������� ����樭᪠� ॠ������� � (���)" )
          add_string( s + "       ᠭ��୮-����⭮� ��祭�� � ��樮����� �᫮����" )
        Elseif i == 11
          add_string( s + "11.11. �஢����� ����樭᪠� ॠ������� � (���)" )
          add_string( s + "       ᠭ��୮-����⭮� ��祭�� � ��樮����� �᫮����" )
        Else
          add_string( s + "11.12. ��稭� ���믮������ ४������権 �� ����樭᪮� ॠ�����樨" )
          add_string( s + "       � (���) ᠭ��୮-����⭮�� ��祭�� � ��樮����� �᫮����:" )
          add_string( s + "         11.12.1. �� ��諨 �ᥣ� " + lstr( vkol ) + " (祫����)" )
        Endif
        If i % 3 > 0
          n := 20
          If eq_any( i, 1, 4, 7 )
            AEval( arr1title, {| x| add_string( x ) } )
          Elseif eq_any( i, 2, 5, 8 )
            AEval( arr2title, {| x| add_string( x ) } )
          Elseif i == 10
            AEval( arr3title, {| x| add_string( x ) } )
            n := 8
          Elseif i == 11
            AEval( arr4title, {| x| add_string( x ) } )
            n := 8
          Endif
          For j := 1 To Len( arr1vozrast )
            s := PadC( lstr( arr1vozrast[ j, 1 ] ) + " - " + lstr( arr1vozrast[ j, 2 ] ), n )
            skol := oldkol := 0
            s1 := ""
            For k := 1 To iif( i > 10, 5, 4 )
              find ( Str( j, 1 ) + Str( i, 2 ) + Str( k, 1 ) )
              If Found() .and. ( v := tmp11->kol ) > 0
                skol += v
                If eq_any( i, 2, 5, 8, 11 )
                  s1 += Str( v, 6 )
                  find ( Str( j, 1 ) + Str( i -1, 2 ) + Str( k, 1 ) )
                  If Found() .and. tmp11->kol > 0
                    s1 += " " + umest_val( v / tmp11->kol * 100, 5, 2 )
                    oldkol += tmp11->kol
                  Else
                    s1 += Space( 6 )
                  Endif
                Else
                  s1 += " " + PadC( lstr( v ), 11 )
                Endif
              Else
                s1 += Space( 12 )
              Endif
            Next
            If eq_any( i, 2, 5, 8, 11 )
              vkol := oldkol - skol
            Endif
            If skol > 0
              If eq_any( i, 2, 5, 8, 11 )
                s += Str( skol, 6 ) + " " + umest_val( skol / oldkol * 100, 5, 2 )
              Else
                s += " " + PadC( lstr( skol ), 11 )
              Endif
              add_string( s + s1 )
            Else
              add_string( s )
            Endif
          Next
          add_string( Replicate( "�", sh ) )
        Endif
      Next
      Use
      verify_ff( HH -3, .t., sh )
      add_string( "" )
      add_string( "12. �������� ��᮪��孮����筮� ����樭᪮� �����:" )
      add_string( "  12.1. ४���������� (�� �⮣�� �����饩 ��ᯠ�c-樨): " + lstr( s12_1 ) + " 祫., � �.�. " + lstr( s12_1m ) + " ����稪��" )
      add_string( "  12.2. ������� (�� �⮣�� ��ᯠ��ਧ�樨 � �।.����): " + lstr( s12_2 ) + " 祫., � �.�. " + lstr( s12_2m ) + " ����稪��" )
      Use ( cur_dir() + "tmp13" ) index ( cur_dir() + "tmp13" ) New Alias TMP13
      verify_ff( HH -16, .t., sh )
      n := 32
      add_string( "" )
      add_string( "13. ��᫮ ��⥩-��������� �� �᫠ ��⥩, ��襤�� ��ᯠ��ਧ���" )
      add_string( "    � ���⭮� ��ਮ��" )
      add_string( "��������������������������������������������������������������������������������" )
      add_string( "                                � � ஦����ﳯਮ���񭭳���.����륳 祫.�  %  " )
      add_string( "         ������ ��⥩          �����������������������������������Ĵ��⥩���⥩" )
      add_string( "                                � 祫.�  %  � 祫.�  %  � 祫.�  %  ������������" )
      add_string( "��������������������������������������������������������������������������������" )
      add_string( "               1                �  2  �  3  �  4  �  5  �  6  �  7  �  8  �  9  " )
      add_string( "��������������������������������������������������������������������������������" )
      For j := 1 To Len( arr1vozrast )
        s := PadC( lstr( arr1vozrast[ j, 1 ] ) + " - " + lstr( arr1vozrast[ j, 2 ] ), n )
        find ( Str( j, 1 ) + Str( 0, 2 ) )
        oldkol := iif( Found(), tmp13->kol, 0 )
        For i := 1 To 4
          find ( Str( j, 1 ) + Str( i, 2 ) )
          If Found()
            s += Str( tmp13->kol, 6 ) + " " + umest_val( tmp13->kol / oldkol * 100, 5, 2 )
          Else
            s += Space( 12 )
          Endif
        Next
        add_string( s )
      Next
      add_string( Replicate( "�", sh ) )
      verify_ff( HH -16, .t., sh )
      n := 26
      add_string( "" )
      add_string( "14. �믮������ �������㠫��� �ணࠬ� ॠ�����樨 (���) ��⥩-���������" )
      add_string( "    � ���⭮� ��ਮ��" )
      add_string( "��������������������������������������������������������������������������������" )
      add_string( "                          ���������.������Ⳣ�.���筳 ��� ���⠳�� �믮����" )
      add_string( "       ������ ��⥩      �祭� ������������������������������������������������" )
      add_string( "                          � 祫.� 祫.�  %  � 祫.�  %  � 祫.�  %  � 祫.�  %  " )
      add_string( "��������������������������������������������������������������������������������" )
      add_string( "             1            �  2  �  3  �  4  �  5  �  6  �  7  �  8  �  9  �  10 " )
      add_string( "��������������������������������������������������������������������������������" )
      For j := 1 To Len( arr1vozrast )
        s := PadC( lstr( arr1vozrast[ j, 1 ] ) + " - " + lstr( arr1vozrast[ j, 2 ] ), n )
        find ( Str( j, 1 ) + Str( 10, 2 ) )
        oldkol := 0
        If Found()
          oldkol := tmp13->kol
        Endif
        s += put_val( oldkol, 6 )
        For i := 11 To 14
          find ( Str( j, 1 ) + Str( i, 2 ) )
          If Found()
            s += Str( tmp13->kol, 6 ) + " " + umest_val( tmp13->kol / oldkol * 100, 5, 2 )
          Else
            s += Space( 12 )
          Endif
        Next
        add_string( s )
      Next
      add_string( Replicate( "�", sh ) )
      verify_ff( HH -15, .t., sh )
      n := 20
      add_string( "" )
      add_string( "15. �墠� ��䨫����᪨�� �ਢ������ � ���⭮� ��ਮ��" )
      add_string( "��������������������������������������������������������������������������������" )
      add_string( "                    �  �ਢ��  ��� �ਢ��� �� ���.�������� �ਢ��� �� ���.���" )
      add_string( "    ������ ��⥩   �    祫.   ������������������������������������������������" )
      add_string( "                    �           � ��������� � ���筮  � ��������� � ���筮  " )
      add_string( "��������������������������������������������������������������������������������" )
      add_string( "          1         �     2     �     3     �     4     �     5     �     6     " )
      add_string( "��������������������������������������������������������������������������������" )
      For j := 1 To Len( arr1vozrast )
        s := PadC( lstr( arr1vozrast[ j, 1 ] ) + " - " + lstr( arr1vozrast[ j, 2 ] ), n )
        find ( Str( j, 1 ) + Str( 20, 2 ) )
        If Found()
          s += " " + PadC( lstr( tmp13->kol ), 11 )
        Else
          s += Space( 12 )
        Endif
        For i := 21 To 24
          find ( Str( j, 1 ) + Str( i, 2 ) )
          If Found()
            s += " " + PadC( lstr( tmp13->kol ), 11 )
          Else
            s += Space( 12 )
          Endif
        Next
        add_string( s )
      Next
      add_string( Replicate( "�", sh ) )
      Use ( cur_dir() + "tmp16" ) index ( cur_dir() + "tmp16" ) New Alias TMP16
      verify_ff( HH -21, .t., sh )
      n := 20
      add_string( "" )
      add_string( "16. ���।������ ��⥩ �� �஢�� 䨧��᪮�� ࠧ����" )
      add_string( "��������������������������������������������������������������������������������" )
      add_string( "                    ���᫮ �ள���.䨧.� �⪫������ 䨧��᪮�� ࠧ���� (祫.)" )
      add_string( "    ������ ��⥩   �襤�� ���ࠧ��⨥ ����������������������������������������" )
      add_string( "                    �ᯠ��ਧ�   祫.  �����.��᳨����.��᳭���.��Ⳣ��.���" )
      add_string( "��������������������������������������������������������������������������������" )
      add_string( "          1         �    2    �    3    �    4    �    5    �    6    �    7    " )
      add_string( "��������������������������������������������������������������������������������" )
      For j := 1 To Len( arr1vozrast )
        For k := 0 To 1
          s := PadR( " " + lstr( arr1vozrast[ j, 1 ] ) + " - " + lstr( arr1vozrast[ j, 2 ] ) + ;
            iif( k == 0, "", " (����稪�)" ), n )
          find ( Str( j, 1 ) + Str( k, 1 ) + Str( 0, 2 ) )
          If Found()
            s += " " + PadC( lstr( tmp16->kol ), 9 )
          Else
            s += Space( 10 )
          Endif
          For i := 1 To 5
            find ( Str( j, 1 ) + Str( k, 1 ) + Str( i, 2 ) )
            If Found()
              s += " " + PadC( lstr( tmp16->kol ), 9 )
            Else
              s += Space( 10 )
            Endif
          Next
          add_string( s )
        Next
      Next
      add_string( Replicate( "�", sh ) )
      verify_ff( HH -21, .t., sh )
      n := 20
      add_string( "" )
      add_string( "17. ���।������ ��⥩ �� ��㯯�� ���ﭨ� ���஢��" )
      add_string( "��������������������������������������������������������������������������������" )
      add_string( "                    ���᫮ �ள �� ��ᯠ��ਧ�樨     � �� १���⠬ ���-�� " )
      add_string( "    ������ ��⥩   �襤�� ����������������������������������������������������" )
      add_string( "                    �ᯠ��ਧ� I  � II � III� IV � V  � I  � II � III� IV � V  " )
      add_string( "��������������������������������������������������������������������������������" )
      add_string( "          1         �    2    � 3  � 4  � 5  � 6  � 7  � 8  � 9  � 10 � 11 � 12 " )
      add_string( "��������������������������������������������������������������������������������" )
      For j := 1 To Len( arr1vozrast )
        For k := 0 To 1
          s := PadR( " " + lstr( arr1vozrast[ j, 1 ] ) + " - " + lstr( arr1vozrast[ j, 2 ] ) + ;
            iif( k == 0, "", " (����稪�)" ), n )
          find ( Str( j, 1 ) + Str( k, 1 ) + Str( 0, 2 ) )
          If Found()
            s += " " + PadC( lstr( tmp16->kol ), 9 )
          Else
            s += Space( 10 )
          Endif
          For i := 11 To 15
            find ( Str( j, 1 ) + Str( k, 1 ) + Str( i, 2 ) )
            s += put_val( tmp16->kol, 5 )
          Next
          For i := 21 To 25
            find ( Str( j, 1 ) + Str( k, 1 ) + Str( i, 2 ) )
            s += put_val( tmp16->kol, 5 )
          Next
          add_string( s )
        Next
      Next
      add_string( Replicate( "�", sh ) )
      FClose( fp )
      viewtext( n_file,,,, .f.,,, 5 )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 08.11.13
Function f2_inf_dds_030dso( Loc_kod, kod_kartotek ) // ᢮���� ���ଠ��

  Local i, j, k, av := {}, av1 := {}, ad := {}, arr, s, fl, ;
    is_man := ( mpol == "�" ), blk_tbl, blk_tip, blk_put_tip, ;
    a10[ 9 ], a11[ 13 ]

  blk_tbl := {| _k| iif( _k < 2, 1, 2 ) }
  blk_tip := {| _k| iif( _k == 0, 2, iif( _k > 1, _k + 1, _k ) ) }
  blk_put_tip := {| _e, _k| iif( _k > _e, _k, _e ) }
  arr_deti[ 1 ] ++
  If mvozrast < 5
    arr_deti[ 2 ] ++
  Elseif mvozrast < 10
    arr_deti[ 3 ] ++
  Elseif mvozrast < 15
    arr_deti[ 4 ] ++
  Else
    arr_deti[ 5 ] ++
  Endif
  For i := 1 To Len( arr_vozrast )
    If Between( mvozrast, arr_vozrast[ i, 2 ], arr_vozrast[ i, 3 ] )
      AAdd( av, arr_vozrast[ i, 1 ] ) // ᯨ᮪ ⠡��� � 4 �� 9
    Endif
  Next
  For i := 1 To Len( arr1vozrast )
    If Between( mvozrast, arr1vozrast[ i, 1 ], arr1vozrast[ i, 2 ] )
      AAdd( av1, i )
    Endif
  Next
  For i := 1 To 5
    j := 0
    For k := 1 To 16
      s := "diag_16_" + lstr( i ) + "_" + lstr( k )
      mvar := "m" + s
      If k == 1
        If !Empty( &mvar )
          arr := Array( 16 ) ; AFill( arr, 0 ) ; arr[ 1 ] := AllTrim( &mvar )
          If Len( arr[ 1 ] ) > 5
            arr[ 1 ] := Left( arr[ 1 ], 5 )
          Endif
          AAdd( ad, arr ) ; j := Len( ad )
        Endif
      Elseif j > 0
        m1var := "m1" + s
        ad[ j, k ] := &m1var
      Endif
    Next
  Next
  Use ( cur_dir() + "tmp4" ) index ( cur_dir() + "tmp4" ) New Alias TMP
  Use ( cur_dir() + "tmp10" ) index ( cur_dir() + "tmp10" ) New Alias TMP10
  AFill( a10, 0 )
  For i := 1 To Len( ad ) // 横� �� ���������
    au := {}
    d := diag_to_num( ad[ i, 1 ], 1 )
    For n := 1 To Len( arr_4 )
      If !Empty( arr_4[ n, 3 ] ) .and. Between( d, arr_4[ n, 4 ], arr_4[ n, 5 ] )
        AAdd( au, n )
      Endif
    Next
    If Len( au ) == 1
      AAdd( au, Len( arr_4 ) -1 )  // {"18","��稥","",,}, ;
    Endif
    Select TMP
    For n := 1 To Len( av ) // 横� �� ᯨ�� ⠡��� � 4 �� 9
      For j := 1 To Len( au )
        find ( Str( av[ n ], 1 ) + Str( au[ j ], 2 ) )
        If Found()
          tmp->k04++
          If is_man
            tmp->k05++
          Endif
          If ad[ i, 2 ] > 0 // ���.�����
            tmp->k06++
            If is_man
              tmp->k07++
            Endif
          Endif
          If ad[ i, 3 ] > 0 // ���.����.��⠭������
            tmp->k08++
            If is_man
              tmp->k09++
            Endif
            If ad[ i, 3 ] == 2 // ���.����.��⠭������ �����
              tmp->k10++
              If is_man
                tmp->k11++
              Endif
            Endif
          Endif
        Endif
      Next
    Next
    If ad[ i, 4 ] == 1 // 1-���.����.�����祭�
      ntbl := Eval( blk_tbl, ad[ i, 5 ] )
      ntip := Eval( blk_tip, ad[ i, 6 ] )
      If ntbl == 1 .and. a10[ 3 ] > 0 // 㦥 ���� ��樮���
        //
      Elseif ntbl == 2
        a10[ 1 ] := 0
        a10[ 3 ] := Eval( blk_put_tip, a10[ 3 ], ntip )
      Else
        a10[ 1 ] := Eval( blk_put_tip, a10[ 1 ], ntip )
        a10[ 3 ] := 0
      Endif
    Endif
    If ad[ i, 7 ] == 1 // 1-���.����.�믮�����
      ntbl := Eval( blk_tbl, ad[ i, 8 ] )
      ntip := Eval( blk_tip, ad[ i, 9 ] )
      If ntbl == 1 .and. a10[ 4 ] > 0 // 㦥 ���� ��樮���
        //
      Elseif ntbl == 2
        a10[ 2 ] := 0
        a10[ 4 ] := Eval( blk_put_tip, a10[ 4 ], ntip )
      Else
        a10[ 2 ] := Eval( blk_put_tip, a10[ 2 ], ntip )
        a10[ 4 ] := 0
      Endif
    Endif
    If ad[ i, 10 ] == 1 // 1-��祭�� �����祭�
      ntbl := Eval( blk_tbl, ad[ i, 11 ] )
      ntip := Eval( blk_tip, ad[ i, 12 ] )
      If ntbl == 1 .and. a10[ 6 ] > 0 // 㦥 ���� ��樮���
        //
      Elseif ntbl == 2
        a10[ 5 ] := 0
        a10[ 6 ] := Eval( blk_put_tip, a10[ 6 ], ntip )
      Else
        a10[ 5 ] := Eval( blk_put_tip, a10[ 5 ], ntip )
        a10[ 6 ] := 0
      Endif
    Endif
    If ad[ i, 13 ] == 1 // 1-ॠ���.�����祭�
      ntbl := Eval( blk_tbl, ad[ i, 14 ] )
      ntip := Eval( blk_tip, ad[ i, 15 ] )
      If ntbl == 1 .and. a10[ 8 ] > 0 // 㦥 ���� ��樮���
        //
      Elseif ntbl == 2 .or. ntip == 5 // ��� ᠭ��਩
        a10[ 7 ] := 0
        a10[ 8 ] := Eval( blk_put_tip, a10[ 8 ], ntip )
      Else
        a10[ 7 ] := Eval( blk_put_tip, a10[ 7 ], ntip )
        a10[ 8 ] := 0
      Endif
    Endif
    If ad[ i, 16 ] == 1 // 1-��� �����祭�
      a10[ 9 ] := 1
    Endif
  Next
  Select TMP10
  For n := 1 To Len( av1 ) // 横� �� �����⠬ ⠡��� 10
    For j := 1 To Len( a10 ) -1
      If a10[ j ] > 0
        find ( Str( av1[ n ], 1 ) + Str( j, 1 ) + Str( a10[ j ], 1 ) )
        If !Found()
          Append Blank
          tmp10->voz := av1[ n ]
          tmp10->tbl := j
          tmp10->tip := a10[ j ]
        Endif
        tmp10->kol++
      Endif
    Next
  Next
  ad := {}
  For i := 1 To 5
    j := 0
    For k := 1 To 14
      s := "diag_15_" + lstr( i ) + "_" + lstr( k )
      mvar := "m" + s
      If k == 1
        If !Empty( &mvar )
          arr := Array( 14 ) ; AFill( arr, 0 ) ; arr[ 1 ] := AllTrim( &mvar )
          If Len( arr[ 1 ] ) > 5
            arr[ 1 ] := Left( arr[ 1 ], 5 )
          Endif
          AAdd( ad, arr ) ; j := Len( ad )
        Endif
      Elseif j > 0
        m1var := "m1" + s
        ad[ j, k ] := &m1var
      Endif
    Next
  Next
  Use ( cur_dir() + "tmp11" ) index ( cur_dir() + "tmp11" ) New Alias TMP11
  AFill( a11, 0 )
  For i := 1 To Len( ad ) // 横� �� ���������
    If ad[ i, 3 ] == 1 // 1-��祭�� �����祭�
      ntbl := Eval( blk_tbl, ad[ i, 4 ] )
      ntip := Eval( blk_tip, ad[ i, 5 ] )
      If ntbl == 1 .and. a11[ 4 ] > 0 // 㦥 ���� ��樮���
        //
      Elseif ntbl == 2
        a11[ 1 ] := 0
        a11[ 4 ] := Eval( blk_put_tip, a11[ 4 ], ntip )
      Else
        a11[ 1 ] := Eval( blk_put_tip, a11[ 1 ], ntip )
        a11[ 4 ] := 0
      Endif
      // ��祭�� �믮�����
      ntbl := Eval( blk_tbl, ad[ i, 6 ] )
      ntip := Eval( blk_tip, ad[ i, 7 ] )
      If ntbl == 1 .and. a11[ 5 ] > 0 // 㦥 ���� ��樮���
        //
      Elseif ntbl == 2
        a11[ 2 ] := 0
        a11[ 5 ] := Eval( blk_put_tip, a11[ 5 ], ntip )
      Else
        a11[ 2 ] := Eval( blk_put_tip, a11[ 2 ], ntip )
        a11[ 5 ] := 0
      Endif
    Endif
    If ad[ i, 8 ] == 1 // 1-ॠ���.�����祭�
      ntbl := Eval( blk_tbl, ad[ i, 9 ] )
      ntip := Eval( blk_tip, ad[ i, 10 ] )
      If ntbl == 1 .and. a11[ 10 ] > 0 // 㦥 ���� ��樮���
        //
      Elseif ntbl == 2
        a11[ 7 ] := 0
        a11[ 10 ] := Eval( blk_put_tip, a11[ 10 ], ntip )
      Else
        a11[ 7 ] := Eval( blk_put_tip, a11[ 7 ], ntip )
        a11[ 10 ] := 0
      Endif
      // 1-ॠ���.�믮�����
      ntbl := Eval( blk_tbl, ad[ i, 11 ] )
      ntip := Eval( blk_tip, ad[ i, 12 ] )
      If ntbl == 1 .and. a11[ 11 ] > 0 // 㦥 ���� ��樮���
        //
      Elseif ntbl == 2 .or. ntip == 5 // ��� ᠭ��਩
        a11[ 8 ] := 0
        a11[ 11 ] := Eval( blk_put_tip, a11[ 11 ], ntip )
      Else
        a11[ 8 ] := Eval( blk_put_tip, a11[ 8 ], ntip )
        a11[ 11 ] := 0
      Endif
    Endif
    If ad[ i, 14 ] == 1 // 1-��� �஢�����
      a11[ 13 ] := 1
    Endif
  Next
  Select TMP11
  For n := 1 To Len( av1 ) // 横� �� �����⠬ ⠡��� 10
    For j := 1 To Len( a11 ) -1
      If a11[ j ] > 0
        find ( Str( av1[ n ], 1 ) + Str( j, 2 ) + Str( a11[ j ], 1 ) )
        If !Found()
          Append Blank
          tmp11->voz := av1[ n ]
          tmp11->tbl := j
          tmp11->tip := a11[ j ]
        Endif
        tmp11->kol++
      Endif
    Next
  Next
  If a10[ 9 ] > 0
    s12_1++
    If is_man
      s12_1m++
    Endif
  Endif
  If a11[ 13 ] > 0
    s12_2++
    If is_man
      s12_2m++
    Endif
  Endif
  ad := { 0 }
  If m1invalid1 == 1 // ������������-��
    AAdd( ad, 4 )
    If m1invalid2 == 0 // � ஦�����
      AAdd( ad, 1 )
    Else               // �ਮ��⥭���
      AAdd( ad, 2 )
      If !Empty( minvalid3 ) .and. minvalid3 >= mn_data
        AAdd( ad, 3 )
      Endif
    Endif
    If !Empty( minvalid7 ) // ��� �����祭�� ���.�ணࠬ�� ॠ�����樨
      AAdd( ad, 10 )
      Do Case // �믮������
      Case m1invalid8 == 1 // ���������, 1
        AAdd( ad, 11 )
      Case m1invalid8 == 2 // ���筮, 2
        AAdd( ad, 12 )
      Case m1invalid8 == 3 // ����, 3
        AAdd( ad, 13 )
      Otherwise            // �� �믮�����, 0
        AAdd( ad, 14 )
      Endcase
    Endif
  Endif
  If m1privivki1 == 1     // �� �ਢ�� �� ����樭᪨� ���������", 1}, ;
    If m1privivki2 == 1
      AAdd( ad, 21 )
    Else
      AAdd( ad, 22 )
    Endif
  Elseif m1privivki1 == 2 // �� �ਢ�� �� ��㣨� ��稭��", 2}}
    If m1privivki2 == 1
      AAdd( ad, 23 )
    Else
      AAdd( ad, 24 )
    Endif
  Else                    // �ਢ�� �� �������", 0}, ;
    AAdd( ad, 20 )
  Endif
  Use ( cur_dir() + "tmp13" ) index ( cur_dir() + "tmp13" ) New Alias TMP13
  For n := 1 To Len( av1 ) // 横� �� �����⠬ ⠡����
    For j := 1 To Len( ad )
      find ( Str( av1[ n ], 1 ) + Str( ad[ j ], 2 ) )
      If !Found()
        Append Blank
        tmp13->voz := av1[ n ]
        tmp13->tip := ad[ j ]
      Endif
      tmp13->kol++
    Next
  Next
  ad := { 0 }
  If m1fiz_razv == 0
    AAdd( ad, 1 )
  Else
    If m1fiz_razv1 == 1
      AAdd( ad, 2 )
    Elseif m1fiz_razv1 == 2
      AAdd( ad, 3 )
    Endif
    If m1fiz_razv2 == 1
      AAdd( ad, 4 )
    Elseif m1fiz_razv2 == 2
      AAdd( ad, 5 )
    Endif
  Endif
  AAdd( ad, mGRUPPA_DO + 10 )
  AAdd( ad, mGRUPPA + 20 )
  // index on str(voz, 1)+str(man, 1)+str(tip, 2) to tmp16
  Use ( cur_dir() + "tmp16" ) index ( cur_dir() + "tmp16" ) New Alias TMP16
  For n := 1 To Len( av1 ) // 横� �� �����⠬ ⠡����
    For j := 1 To Len( ad )
      find ( Str( av1[ n ], 1 ) + "0" + Str( ad[ j ], 2 ) )
      If !Found()
        Append Blank
        tmp16->voz := av1[ n ]
        tmp16->tip := ad[ j ]
      Endif
      tmp16->kol++
      If is_man
        find ( Str( av1[ n ], 1 ) + "1" + Str( ad[ j ], 2 ) )
        If !Found()
          Append Blank
          tmp16->voz := av1[ n ]
          tmp16->man := 1
          tmp16->tip := ad[ j ]
        Endif
        tmp16->kol++
      Endif
    Next
  Next

  Return Nil

// 24.12.19
Function inf_dds_xmlfile( is_schet )

  Static stitle := "XML-���⠫: ��ᯠ��ਧ��� ��⥩-��� "
  Local arr_m, n, buf := save_maxrow(), lkod_h, lkod_k, rec, blk, t_arr[ BR_LEN ]

  If ( arr_m := year_month( T_ROW, T_COL -5 ) ) != NIL
    mywait()
    If f0_inf_dds( arr_m, is_schet > 1, is_schet == 3, .t. )
      r_use( dir_server() + "human",, "HUMAN" )
      Use ( cur_dir() + "tmp" ) new
      Set Relation To kod into HUMAN
      Index On Upper( human->fio ) to ( cur_dir() + "tmp" )
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + "human_",, "HUMAN_" ), ;
        r_use( dir_server() + "human",, "HUMAN" ), ;
        dbSetRelation( "HUMAN_", {|| RecNo() }, "recno()" ), ;
        e_use( cur_dir() + "tmp", cur_dir() + "tmp" ), ;
        dbSetRelation( "HUMAN", {|| kod }, "kod" );
        }
      Eval( blk_open )
      Go Top
      t_arr[ BR_TOP ] := 2
      t_arr[ BR_BOTTOM ] := 23
      t_arr[ BR_LEFT ] := 0
      t_arr[ BR_RIGHT ] := 79
      t_arr[ BR_TITUL ] := stitle + arr_m[ 4 ]
      t_arr[ BR_TITUL_COLOR ] := "B/BG"
      t_arr[ BR_COLOR ] := color0
      t_arr[ BR_ARR_BROWSE ] := { '�', '�', '�', "N/BG,W+/N,B/BG,W+/B", .t. }
      blk := {|| iif( tmp->is == 1, { 1, 2 }, { 3, 4 } ) }
      t_arr[ BR_COLUMN ] := { { " ", {|| iif( tmp->is == 1, "", " " ) }, blk }, ;
        { " �.�.�.", {|| PadR( human->fio, 37 ) }, blk }, ;
        { "��� ஦�.", {|| full_date( human->date_r ) }, blk }, ;
        { "� ��.�����", {|| human->uch_doc }, blk }, ;
        { "�ப� ���-�", {|| Left( date_8( human->n_data ), 5 ) + "-" + Left( date_8( human->k_data ), 5 ) }, blk }, ;
        { "�⠯", {|| iif( human->ishod == 101, " I  ", "I-II" ) }, blk } }
      t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ - ��室 ��� ᮧ����� 䠩��;  ^<+,-,Ins>^ - �⬥���/���� �⬥�� � ��樥��" ) }
      t_arr[ BR_EDIT ] := {| nk, ob| f1_inf_n_xmlfile( nk, ob, "edit" ) }
      edit_browse( t_arr )
      Select TMP
      Delete For is == 0
      Pack
      n := LastRec()
      Close databases
      rest_box( buf )
      If n == 0 .or. !f_esc_enter( "��⠢����� XML-䠩��" )
        Return Nil
      Endif
      mywait()
      r_use( dir_server() + "mo_rpdsh",, "RPDSH" )
      Index On Str( KOD_H, 7 ) to ( cur_dir() + "tmprpdsh" )
      Use
      r_use( dir_server() + "mo_raksh",, "RAKSH" )
      Index On Str( KOD_H, 7 ) to ( cur_dir() + "tmpraksh" )
      Use
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + "human_",, "HUMAN_" ), ;
        r_use( dir_server() + "human",, "HUMAN" ), ;
        dbSetRelation( "HUMAN_", {|| RecNo() }, "recno()" ), ;
        r_use( cur_dir() + "tmp", cur_dir() + "tmp" ), ;
        dbSetRelation( "HUMAN", {|| kod }, "kod" );
        }
      mo_mzxml_n( 1 )
      n := 0
      Do While .t.
        ++n
        Eval( blk_open )
        If rec == NIL
          Go Top
        Else
          Goto ( rec )
          Skip
          If Eof()
            Exit
          Endif
        Endif
        rec := tmp->( RecNo() )
        @ MaxRow(), 0 Say PadR( Str( n / tmp->( LastRec() ) * 100, 6, 2 ) + "%" + " " + ;
          RTrim( human->fio ) + " " + date_8( human->n_data ) + "-" + ;
          date_8( human->k_data ), 80 ) Color cColorWait
        lkod_h := human->kod
        lkod_k := human->kod_k
        Close databases
        oms_sluch_dds( p_tip_lu, lkod_h, lkod_k, "f2_inf_N_XMLfile" )
      Enddo
      Close databases
      rest_box( buf )
      mo_mzxml_n( 3, "tmp", stitle )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 23.01.25 ���ଠ�� �� ��ᯠ��ਧ�樨 � ��䨫��⨪� ���᫮�� ��ᥫ����
Function inf_dvn( k )

  Static si1 := 1, si2 := 1, si3 := 1, si4 := 1, si5 := 2, si6 := 2, si7 := 2, sj := 1, sj1 := 1
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { "���� ���� �131/~�", ;
      "~���᮪ ��樥�⮢", ;
      "�������ਠ��� ~�����", ;
      "����� ��� ~�����ࠢ�", ;
      "����� �� �� ��� ~�����ࠢ�", ;
      "����⭠� �ଠ �~131", ;
      "����� ~䠩���� R0... � ��" }
    mas_msg := { "��ᯥ�⪠ ����� ���� ��ᯠ��ਧ�樨 (��䨫����᪨� ���.�ᬮ�஢) �131/�", ;
      "��ᯥ�⪠ ᯨ᪠ ��樥�⮢, ��襤�� ��ᯠ��ਧ���/��䨫��⨪�", ;
      "�������ਠ��� ����� �� ��ᯠ��ਧ�樨/��䨫��⨪� ���᫮�� ��ᥫ����", ;
      "��ᯥ�⪠ ᢮��� ��� ������ࠤ᪮�� �����⭮�� ������ ��ࠢ���࠭����", ;
      "��ᯥ�⪠ ᢮��� �� 㣫㡫����� ��ᯠ��ਧ�樨 ��� ������ࠤ᪮�� �����ࠢ�", ;
      "�������� � ��ᯠ��ਧ�樨 ��।����� ��㯯 ���᫮�� ��ᥫ����", ;
      "���ଠ樮���� ᮯ஢������� �� ��-樨 ��宦����� ��䨫����᪨� ��ய��⨩" }
    mas_fun := { "inf_DVN(11)", ;
      "inf_DVN(12)", ;
      "inf_DVN(13)", ;
      "inf_DVN(14)", ;
      "inf_DVN(17)", ;
      "inf_DVN(15)", ;
      "inf_DVN(16)" }
    popup_prompt( T_ROW, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    f_131_u()
  Case k == 12
    mas_pmt := AClone( mas1pmt )
    AAdd( mas_pmt, "��砨, ��� ~�� �����訥 � ���" )
    If ( j := popup_prompt( T_ROW, T_COL -5, sj, mas_pmt ) ) > 0
      sj := j
      If ( j := popup_prompt( T_ROW, T_COL -5, sj1, ;
          { "��ᯠ��ਧ��� ~1 �⠯", ;
          "���ࠢ���� �� 2 �⠯ - ��� ~�� ��諨", ;
          "��ᯠ��ਧ��� ~2 �⠯", ;
          "~��䨫��⨪�" } ) ) > 0
        sj1 := j
        f2_inf_dvn( sj, sj1 )
      Endif
    Endif
  Case k == 13
    /*mas_pmt := {"~���, �������騥 ��ᯠ��ਧ�樨"}
    mas_msg := {"����� ���, ��������� ��ᯠ�ਧ�樨, ��⮤�� �������ਠ�⭮�� ���᪠"}
    mas_fun := {"inf_DVN(31)"}
    popup_prompt(T_ROW,T_COL-5,si3,mas_pmt,mas_msg,mas_fun)*/
    inf_dvn( 31 )
  Case k == 14
    mas_pmt := { "~�������� � ��ᯠ��ਧ�樨 �� ���ﭨ� �� ...", ;
      "~��������� �����ਭ�� ��ᯠ��ਧ�樨 ������" }
    mas_msg := { "�ਫ������ � �ਪ��� ���� �2066 �� 01.08.2013�.", ;
      "��������� �����ਭ�� ��ᯠ��ਧ�樨 ������" }
    mas_fun := { "inf_DVN(21)", ;
      "inf_DVN(22)" }
    popup_prompt( T_ROW, T_COL -5, si2, mas_pmt, mas_msg, mas_fun )
  Case k == 15
    If ( j := popup_prompt( T_ROW, T_COL -5, 1, mas1pmt ) ) > 0
      forma_131( j )
    Endif
  Case k == 16
    mas_pmt := { "����-��䨪 (R0~5)", ;
      "����� ������ (R0~1)", ;
      "~����� ������ (R11)" }
    mas_msg := { "�������� � ��ᬮ�� 䠩��� ������ R05...", ;
      "�������� � ��ᬮ�� 䠩��� ������ R01...", ;
      "�������� � ��ᬮ�� 䠩��� ������ R11..." }
    mas_fun := { "inf_DVN(41)", ;
      "inf_DVN(42)", ;
      "inf_DVN(43)" }
    str_sem := "�����"
    If g_slock( str_sem )
      fff_init_r01() // ����
      popup_prompt( T_ROW - Len( mas_pmt ) -3, T_COL -5, si4, mas_pmt, mas_msg, mas_fun )
      g_sunlock( str_sem )
    Else
      func_error( 4, "� ����� ������ � �⨬ ०���� ࠡ�⠥� ��㣮� ���짮��⥫�." )
    Endif
  Case k == 17
    inf_ydvn()
  Case k == 41
    // ne_real()
    // if glob_mo[_MO_KOD_TFOMS] == '711001' // ��-���쭨�
    mas_pmt := { "~�������� �����-��䨪�", ;
      "~��ᬮ�� 䠩��� ������" }
    mas_msg := { "�������� 䠩�� ������ R05... � ������-��䨪�� �� ����栬", ;
      "��ᬮ�� 䠩��� ������ R05... � १���⮢ ࠡ��� � ����" }
    mas_fun := { "inf_DVN(51)", ;
      "inf_DVN(52)" }
    popup_prompt( T_ROW, T_COL -5, si5, mas_pmt, mas_msg, mas_fun )
    // endif
  Case k == 42
    // ne_real()
    // if glob_mo[_MO_KOD_TFOMS] == '711001' // ��-���쭨�
    mas_pmt := { "~�������� 䠩��� ������", ;
      "~��ᬮ�� 䠩��� ������" }
    mas_msg := { "�������� 䠩��� ������ R01... �� �ᥬ ����栬", ;
      "��ᬮ�� 䠩��� ������ R01... � १���⮢ ࠡ��� � ����" }
    mas_fun := { "inf_DVN(61)", ;
      "inf_DVN(62)" }
    If need_delete_reestr_r01()
      AAdd( mas_pmt, "~���㫨஢���� �����" )
      AAdd( mas_msg, "���㫨஢���� ������ᠭ���� ����� 䠩��� R01" )
      AAdd( mas_fun, "delete_reestr_R01()" )
    Endif
    // set key K_CTRL_F10 to delete_month_R01()
    popup_prompt( T_ROW, T_COL -5, si6, mas_pmt, mas_msg, mas_fun )
    // set key K_CTRL_F10 to
    // endif
  Case k == 21
    If ( j := popup_prompt( T_ROW, T_COL -5, 1, mas1pmt ) ) > 0
      f21_inf_dvn( j )
    Endif
  Case k == 22
    f22_inf_dvn( j )
  Case k == 31
    mnog_poisk_dvn1()
  Case k == 51
    f_create_r05()
  Case k == 52
    f_view_r05()
  Case k == 61
    f_create_r01()
  Case k == 62
    f_view_r01()
  Case k == 43
//    If glob_mo[ _MO_KOD_TFOMS ] == '711001' // ��-���쭨�
      mas_pmt := { "~�������� 䠩��� ������", ;
        "~��ᬮ�� 䠩��� ������" }
      mas_msg := { "�������� 䠩��� ������ R11... �� ������� �����", ;
        "��ᬮ�� 䠩��� ������ R11... � १���⮢ ࠡ��� � ����" }
      mas_fun := { "inf_DVN(71)", ;
        "inf_DVN(72)" }
      If need_delete_reestr_r01()
        AAdd( mas_pmt, "~���㫨஢���� �����" )
        AAdd( mas_msg, "���㫨஢���� ������ᠭ���� ����� R11" )
        AAdd( mas_fun, "delete_reestr_R11()" )
      Endif
      AAdd( mas_pmt, "~������ ������ ��樥�⮢" )
      AAdd( mas_msg, "������ ������ ��樥�⮢" )
      AAdd( mas_fun, "find_new_R00()" )
      AAdd( mas_pmt, "�~����� '�� �����' ��樥�⮢" )
      AAdd( mas_msg, "������ ��樥�⮢, �ਪ९������ � ��㣨� �� ��� ��� �ਪ९�����" )
      AAdd( mas_fun, "find_new_R000()" )

      // set key K_CTRL_F10 to delete_month_R11()
      popup_prompt( T_ROW, T_COL - 5, si7, mas_pmt, mas_msg, mas_fun )
      // set key K_CTRL_F10 to
//    Endif
  Case k == 71
    f_create_r11()
  Case k == 72
    f_view_r01( _XML_FILE_R11 )
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Elseif Between( k, 21, 29 )
      si2 := j
    Elseif Between( k, 31, 39 )
      si3 := j
    Elseif Between( k, 41, 49 )
      si4 := j
    Elseif Between( k, 51, 59 )
      si5 := j
    Elseif Between( k, 61, 69 )
      si6 := j
    Elseif Between( k, 71, 79 )
      si7 := j
    Endif
  Endif

  Return Nil

// 15.08.19
Function f0_inf_dvn( arr_m, is_schet, is_reg, is_1_2 )

  Local fl := .t., j := 0, n, buf := save_maxrow()

  Default is_schet To .t., is_reg To .f., is_1_2 To .f.
  If !del_dbf_file( cur_dir() + "tmp" + sdbf() )
    Return .f.
  Endif
  mywait()
  dbCreate( cur_dir() + "tmp", { { "kod_k", "N", 7, 0 }, ;
    { "kod1h", "N", 7, 0 }, ;
    { "date1", "D", 8, 0 }, ;
    { "kod2h", "N", 7, 0 }, ;
    { "date2", "D", 8, 0 }, ;
    { "kod3h", "N", 7, 0 }, ;
    { "date3", "D", 8, 0 }, ;
    { "kod4h", "N", 7, 0 }, ;
    { "date4", "D", 8, 0 } } )
  Use ( cur_dir() + "tmp" ) new
  Index On Str( kod_k, 7 ) to ( cur_dir() + "tmp" )
  r_use( dir_server() + "schet_",, "SCHET_" )
  r_use( dir_server() + "human_",, "HUMAN_" )
  r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
  Set Relation To RecNo() into HUMAN_
  n := iif( is_1_2, 204, 203 )
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Index On kod to ( cur_dir() + "tmp_h" ) ;
    For Between( ishod, 201, n ) .and. human->cena_1 > 0 .and. iif( is_schet, schet > 0, .t. ) ;
    While human->k_data <= arr_m[ 6 ] ;
    PROGRESS
  Go Top
  Do While !Eof()
    fl := f_is_uch( st_a_uch, human->lpu )
    If fl .and. is_reg
      fl := .f.
      Select SCHET_
      Goto ( human->schet )
      If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // ⮫쪮 ��ॣ����஢����
        fl := .t.
      Endif
    Endif
    If fl .and. ret_koef_from_rak( human->kod ) > 0
      Select TMP
      find ( Str( human->kod_k, 7 ) )
      If !Found()
        Append Blank
        tmp->kod_k := human->kod_k
      Endif
      Do Case
      Case human->ishod == 201
        If ( Empty( tmp->date1 ) .or. human->k_data > tmp->date1 )
          tmp->kod1h := human->kod
          tmp->date1 := human->k_data
        Endif
      Case human->ishod == 202
        If ( Empty( tmp->date2 ) .or. human->k_data > tmp->date2 )
          tmp->kod2h := human->kod
          tmp->date2 := human->k_data
        Endif
      Case human->ishod == 203
        If ( Empty( tmp->date3 ) .or. human->k_data > tmp->date3 )
          tmp->kod3h := human->kod
          tmp->date3 := human->k_data
        Endif
      Case human->ishod == 204
        tmp->kod4h := human->kod
        tmp->date4 := human->k_data
      Endcase
      If++j % 1000 == 0
        Commit
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  rest_box( buf )
  fl := .t.
  If tmp->( LastRec() ) == 0
    fl := func_error( 4, "�� ������� �/� �� ��ᯠ��ਧ�樨 ���᫮�� ��ᥫ���� " + arr_m[ 4 ] )
  Endif
  Close databases

  Return fl

// 20.10.16 ���� ���� ��ᯠ��ਧ�樨 �� �ଥ �131/�
Function f_131_u()

  Local arr_m, buf := save_maxrow(), k, blk, t_arr[ BR_LEN ], rec := 0

  If ( st_a_uch := inputn_uch( T_ROW, T_COL -5,,, @lcount_uch ) ) != NIL ;
      .and. ( arr_m := year_month(,,, 5 ) ) != Nil .and. f0_inf_dvn( arr_m, .f. )
    mywait()
    r_use( dir_server() + "kartotek",, "KART" )
    Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" ) new
    If glob_kartotek > 0
      find ( Str( glob_kartotek, 7 ) )
      If Found()
        rec := tmp->( RecNo() )
      Endif
    Endif
    Set Relation To kod_k into KART
    Index On Upper( kart->fio ) to ( cur_dir() + "tmp" )
    Private ;
      blk_open := {|| dbCloseAll(), ;
      r_use( dir_server() + "uslugi",, "USL" ), ;
      r_use( dir_server() + "human_u_",, "HU_" ), ;
      r_use( dir_server() + "human_u", dir_server() + "human_u", "HU" ), ;
      dbSetRelation( "HU_", {|| RecNo() }, "recno()" ), ;
      r_use( dir_server() + "human_",, "HUMAN_" ), ;
      r_use( dir_server() + "human",, "HUMAN" ), ;
      dbSetRelation( "HUMAN_", {|| RecNo() }, "recno()" ), ;
      r_use( dir_server() + "kartote_",, "KART_" ), ;
      r_use( dir_server() + "kartotek",, "KART" ), ;
      dbSetRelation( "KART_", {|| RecNo() }, "recno()" ), ;
      r_use( cur_dir() + "tmp", cur_dir() + "tmp" ), ;
      dbSetRelation( "KART", {|| kod_k }, "kod_k" );
      }
    Eval( blk_open )
    Go Top
    If rec > 0
      Goto ( rec )
    Endif
    t_arr[ BR_TOP ] := T_ROW
    t_arr[ BR_BOTTOM ] := 23
    t_arr[ BR_LEFT ] := 0
    t_arr[ BR_RIGHT ] := 79
    t_arr[ BR_TITUL ] := "���᫮� ��ᥫ���� " + arr_m[ 4 ]
    t_arr[ BR_TITUL_COLOR ] := "B/BG"
    t_arr[ BR_COLOR ] := color0
    t_arr[ BR_ARR_BROWSE ] := { '�', '�', '�', "N/BG,W+/N,B/BG,W+/B,RB/BG,W+/RB", .t. }
    blk := {|| iif( emptyall( tmp->kod1h, tmp->kod2h ), { 5, 6 }, iif( Empty( tmp->kod2h ), { 1, 2 }, { 3, 4 } ) ) }
    t_arr[ BR_COLUMN ] := { { " �.�.�.",     {|| PadR( kart->fio, 39 ) }, blk }, ;
      { "��� ஦�.",  {|| full_date( kart->date_r ) }, blk }, ;
      { "� ��.�����",  {|| PadR( __f_131_u( 1 ), 10 ) }, blk }, ;
      { "�ப� ���-�", {|| PadR( __f_131_u( 2 ), 11 ) }, blk }, ;
      { "�⠯",        {|| PadR( __f_131_u( 3 ), 4 ) }, blk } }
    t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ - ��室;  ^<Enter>^ - �ᯥ���� ����� ���� ���-�� (���.�ᬮ��)" ) }
    t_arr[ BR_EDIT ] := {| nk, ob| f1_131_u( nk, ob, "edit" ) }
    edit_browse( t_arr )
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 20.09.15
Static Function __f_131_u( k )

  Local s := "", ie := 1

  If emptyall( tmp->kod1h, tmp->kod2h ) // ����� ��䨫��⨪�
    human->( dbGoto( tmp->kod3h ) )
    ie := 3
  Else // ��ᯠ��ਧ���
    If Empty( tmp->kod1h ) // ��祬�-� ��� ��ࢮ�� �⠯�
      human->( dbGoto( tmp->kod2h ) )
    Else
      human->( dbGoto( tmp->kod1h ) )
    Endif
    If !Empty( tmp->kod2h ) // ���� ��ன �⠯
      ie := 2
    Endif
  Endif
  If k == 1
    s := human->uch_doc
  Elseif k == 2
    s := Left( date_8( human->n_data ), 5 ) + "-"
    If ie == 2
      human->( dbGoto( tmp->kod2h ) )
    Endif
    s += Left( date_8( human->k_data ), 5 )
  Else
    s := { "I ��", "I-II", "���" }[ ie ]
  Endif

  Return s

// 27.09.24
Function f1_131_u( nKey, oBrow, regim )

  Static lV := "V", sb1 := "<b><u>", sb2 := "</u></b>"
  Static s_smg := "�� 㤠���� ��।����� ��㯯� ���஢��"
  Local ret := -1, rec := tmp->( RecNo() ), buf := save_maxrow(), ;
    i, j, k, fl, lshifr, au := {}, ar, metap, m1gruppa, is_disp := .t., ;
    mpol := kart->pol, fl_dispans := .f., adbf, s, y, m, d, arr, ;
    blk := {| s| __dbAppend(), field->stroke := s }

  If regim == "edit" .and. nKey == K_ENTER
    glob_kartotek := tmp->kod_k
    delfrfiles()
    mywait()
    Private arr_otklon := {}, arr_usl_otkaz := {}, mvozrast, mdvozrast, ;
      M1RAB_NERAB, m1veteran := 0, m1mobilbr := 0, ;
      m1kurenie := 0, mad1 := 120, mad2 := 80, m1tip_mas := 0, mssr := 0, ;
      m1holestdn := 0, m1glukozadn := 0, m1fiz_akt := 0, m1ner_pit := 0, ;
      mholest := 0, mglukoza := 0, ;
      m1riskalk := 0, m1pod_alk := 0, m1psih_na := 0, ;
      m1ot_nasl1 := 0, m1ot_nasl2 := 0, m1ot_nasl3 := 0, m1ot_nasl4 := 0, ;
      m1dispans := 0, m1nazn_l  := 0, m1dopo_na := 0, m1ssh_na  := 0, ;
      m1spec_na := 0, m1sank_na := 0, ;
      pole_diag, pole_1pervich, pole_1stadia, pole_1dispans, ;
      mWEIGHT := 0, mHEIGHT := 0, mn_data, mk_data, mk_data1
    For i := 1 To 5
      pole_diag := "mdiag" + lstr( i )
      pole_d_diag := "mddiag" + lstr( i )
      pole_1pervich := "m1pervich" + lstr( i )
      pole_1stadia := "m1stadia" + lstr( i )
      pole_1dispans := "m1dispans" + lstr( i )
      pole_d_dispans := "mddispans" + lstr( i )
      Private &pole_diag := Space( 6 )
      Private &pole_d_diag := CToD( "" )
      Private &pole_1pervich := 0
      Private &pole_1stadia := 0
      Private &pole_1dispans := 0
      Private &pole_d_dispans := CToD( "" )
    Next
    If emptyall( tmp->kod1h, tmp->kod2h ) // ����� ��䨫��⨪�
      is_disp := .f.
      human->( dbGoto( tmp->kod3h ) )
      If Between( human_->RSLT_NEW, 343, 345 )
        m1GRUPPA := human_->RSLT_NEW - 342
      Elseif Between( human_->RSLT_NEW, 373, 374 )
        m1GRUPPA := human_->RSLT_NEW - 370
      Endif
      If !Between( m1gruppa, 1, 4 )
        m1GRUPPA := 0 ; func_error( 4, s_smg )
      Endif
    Else // I �⠯
      If Empty( tmp->kod1h )
        func_error( 4, "��������� II �⠯, �� ��������� I �⠯" )
        rest_box( buf )
        Return ret
      Endif
      human->( dbGoto( tmp->kod1h ) )
      m1GRUPPA := ret_gruppa_dvn( human_->RSLT_NEW )
      If !Between( m1gruppa, 0, 4 )
        m1GRUPPA := 0 ; func_error( 4, s_smg )
      Endif
    Endif
    M1RAB_NERAB := human->RAB_NERAB
    mn_data := human->n_data
    mk_data := mk_data1 := human->k_data
    Private is_disp_19 := !( mk_data < 0d20190501 )
    Private is_disp_21 := !( mk_data < 0d20210101 )
    Private is_disp_24 := !( mk_data < 0d20240901 )
    mdate_r := full_date( human->date_r )
    read_arr_dvn( human->kod )
    ret_arr_vozrast_dvn( mk_data )

    mvozrast := count_years( human->date_r, human->n_data )
    mdvozrast := Year( human->n_data ) - Year( human->date_r )
    If m1veteran == 1
      mdvozrast := ret_vozr_dvn_veteran( mdvozrast, human->k_data )
    Endif

    // ret_arrays_disp( is_disp_19, is_disp_21, is_disp_24 )
    ret_arrays_disp( mk_data )
    ret_tip_mas( mWEIGHT, mHEIGHT, @m1tip_mas )
    Select HU
    find ( Str( human->kod, 7 ) )
    Do While hu->kod == human->kod .and. !Eof()
      usl->( dbGoto( hu->u_kod ) )
      If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
        lshifr := usl->shifr
      Endif
      If !eq_any( Left( lshifr, 5 ), "70.3.", "70.7.", "72.1.", "72.5.", "72.6.", "72.7." )
        AAdd( au, { AllTrim( lshifr ), ;
          hu_->PROFIL, ;
          iif( Left( hu_->kod_diag, 1 ) == "Z", "", hu_->kod_diag ), ;
          c4tod( hu->date_u );
          } )
      Endif
      Select HU
      Skip
    Enddo
    k_nev_4_1_12 := 0
    For k := 1 To Len( au )
      lshifr := au[ k, 1 ]
      If is_disp_19
        //
      Elseif ( ( lshifr == "2.3.3" .and. au[ k, 2 ] == 3 ) .or.  ; // �����᪮�� ����
        ( lshifr == "2.3.1" .and. au[ k, 2 ] == 136 ) )    // �������� � �����������
        k_nev_4_1_12 := k
      Endif
      If AScan( arr_otklon, au[ k, 1 ] ) > 0
        au[ k, 3 ] := "+" // �⪫������ � ��᫥�������
        If eq_any( lshifr, "4.20.1", "4.20.2" ) // �᫨ �⪫������ � ��᫥������� �⮫����.���ਠ��
          If ( i := AScan( au, {| x| x[ 1 ] == "4.1.12" } ) ) > 0
            au[ i, 3 ] := "+" // ������ �⪫������ � �ᬮ�� 䥫��� "4.1.12"
          Endif
        Endif
      Endif
    Next
    If is_disp_19
      arr_10 := { ;
        { 1, "56.1.16", "���� (�����஢����) �� ������ �஭��᪨� ����䥪樮���� �����������, 䠪�஢ �᪠ �� ࠧ����, ���ॡ����� ��મ��᪨� �।�� � ����ய��� ����� ��� �����祭�� ���" }, ;
        { 2, "3.1.19", "���ய������ (����७�� ��� ���, ����� ⥫�, ���㦭��� ⠫��), ���� ������ ����� ⥫�" }, ;
        { 3, "3.1.5", "����७�� ���ਠ�쭮�� ��������" }, ;
        { 4, "3.4.9", "����७�� ����ਣ������� ��������" }, ;
        { 5, "4.12.174", "��᫥������� �஢� �� ��騩 宫���ਭ" }, ;
        { 6, "4.12.169", "��᫥������� �஢�� ���� � �஢�" }, ;
        { 7, "4.11.137", "������᪨� ������ �஢� (3 ������⥫�)" }, ;
        { 8, "4.8.4", "��᫥������� ���� �� ������ �஢�" }, ;
        { 9, "4.14.66", "��᫥������� �஢� �� �����-ᯥ���᪨� ��⨣��" }, ;
        { 10, { { "2.3.1", 136 }, { "2.3.3", 3 }, { "2.3.3", 42 } }, "�ᬮ�� ����મ� ��� ����஬-�����������" }, ;
        { 11, { "4.1.12", "4.20.1", "4.20.2" }, "���⨥ ����� (�᪮��) � �����孮�� 襩�� ��⪨ (���㦭��� ���筮�� ����) � �ࢨ���쭮�� ������ �� �⮫����᪮� ��᫥�������" }, ;
        { 12, "7.57.3", "��������� ����� ������� �����" }, ;
        { 13, "7.61.3", "���ண��� �񣪨� ��䨫����᪠�" }, ;
        { 14, "13.1.1", "�����ப�न����� (� �����)" }, ;
        { 15, "10.3.13", "�����䠣�����த㮤���᪮���" }, ;
        { 16, "56.1.18", "��।������ �⭮�⥫쭮�� �㬬�୮�� �थ筮-��㤨�⮣� �᪠", "mdvozrast < 40" }, ;
        { 17, "56.1.19", "��।������ ��᮫�⭮�� �㬬�୮�� �थ筮-��㤨�⮣� �᪠", "39 < mdvozrast .and. mdvozrast < 65" }, ;
        { 18, "56.1.14", "��⪮� �������㠫쭮� ��䨫����᪮� �������஢����" }, ;
        { 19, { { "2.3.7", 57 }, { "2.3.7", 97 }, { "2.3.2", 57 }, { "2.3.2", 97 }, { "2.3.4", 42 } }, "�ਥ� (�ᬮ��) ���-�࠯���" };
        }
    Else
      arr_10 := { ;
        { 1, "56.1.16", "���� (�����஢����) �� ������ �஭��᪨� ����䥪樮���� �����������, 䠪�஢ �᪠ �� ࠧ����, ���ॡ����� ��મ��᪨� �।�� � ����ய��� ����� ��� �����祭�� ���" }, ;
        { 2, "3.1.19", "���ய������ (����७�� ��� ���, ����� ⥫�, ���㦭��� ⠫��), ���� ������ ����� ⥫�" }, ;
        { 3, "3.1.5", "����७�� ���ਠ�쭮�� ��������" }, ;
        { 4, "4.12.174", "��।������ �஢�� ��饣� 宫���ਭ� � �஢�" }, ;
        { 5, "4.12.169", "��।������ �஢�� ���� � �஢� �����-��⮤��" }, ;
        { 6, { "56.1.17", "56.1.18" }, "��।������ �⭮�⥫쭮�� �㬬�୮�� �थ筮-��㤨�⮣� �᪠", "mdvozrast < 40" }, ;
        { 7, { "56.1.17", "56.1.19" }, "��।������ ��᮫�⭮�� �㬬�୮�� �थ筮-��㤨�⮣� �᪠", "39 < mdvozrast .and. mdvozrast < 66" }, ;
        { 8, "13.1.1", "�����ப�न����� (� �����)" }, ;
        { 9, { "4.1.12", "4.20.1", "4.20.2" }, "�ᬮ�� 䥫��஬ (����મ�), ������ ���⨥ ����� (�᪮��) � �����孮�� 襩�� ��⪨ (���㦭��� ���筮�� ����) � �ࢨ���쭮�� ������ �� �⮫����᪮� ��᫥�������" }, ;
        { 10, "7.61.3", "���ண��� ������" }, ;
        { 11, "7.57.3", "��������� ����� ������� �����" }, ;
        { 12, "4.11.137", "������᪨� ������ �஢�" }, ;
        { 13, "4.11.136", "������᪨� ������ �஢� ࠧ������" }, ;
        { 14, "4.12.172", "������ �஢� ���娬��᪨� ����࠯����᪨�" }, ;
        { 15, "4.2.153", "��騩 ������ ���" }, ;
        { 16, "4.8.4", "��᫥������� ���� �� ������ �஢� ���㭮娬��᪨� ��⮤��" }, ;
        { 17, { "8.2.1", "8.2.4", "8.2.5" }, "����ࠧ�㪮��� ��᫥������� (���) �� �।��� �᪫�祭�� ������ࠧ������ �࣠��� ���譮� ������, ������ ⠧�" }, ;
        { 18, "8.1.5", "����ࠧ�㪮��� ��᫥������� (���) � 楫�� �᪫�祭�� ����ਧ�� ���譮� �����" }, ;
        { 19, "3.4.9", "����७�� ����ਣ������� ��������" }, ;
        { 20, { { "2.3.1", 97 }, { "2.3.1", 57 }, { "2.3.2", 97 }, { "2.3.2", 57 }, { "2.3.3", 42 }, { "2.3.5", 57 }, { "2.3.5", 97 }, { "2.3.6", 57 }, { "2.3.6", 97 } }, "�ਥ� (�ᬮ��) ���-�࠯���" };
        }
      If is_disp .and. Year( mk_data ) > 2017 // � 18 ����
        arr_10[ 13 ] := { 13, "4.14.66", "��᫥������� �஢� �� �����-ᯥ���᪨� ��⨣��" }
        del_array( arr_10, 18 )
        del_array( arr_10, 17 )
        del_array( arr_10, 15 )
        del_array( arr_10, 14 )
      Endif
    Endif
    dbCreate( fr_data, { { "name", "C", 200, 0 }, ;
      { "ns", "N", 2, 0 }, ;
      { "vv", "C", 10, 0 }, ;
      { "vo", "C", 10, 0 }, ;
      { "vd", "C", 20, 0 } } )
    Use ( fr_data ) New Alias FRD
    For n := 1 To Len( arr_10 )
      Append Blank
      frd->name := arr_10[ n, 3 ]
      frd->ns := arr_10[ n, 1 ]
    Next
    Index On Str( ns, 2 ) To tmp_frd
    For i := 1 To Len( arr_10 )
      fl := fl_nev := .f. ;  date_o := CToD( "" )
      If ValType( arr_usl_otkaz ) == "A"
        For k1 := 1 To Len( arr_usl_otkaz )
          ar := arr_usl_otkaz[ k1 ]
          If ValType( ar ) == "A" .and. Len( ar ) >= 10 .and. ValType( ar[ 5 ] ) == "C" ;
              .and. ValType( ar[ 10 ] ) == "N" .and. Between( ar[ 10 ], 1, 2 )
            lshifr := AllTrim( ar[ 5 ] )
            If ValType( arr_10[ i, 2 ] ) == "C"
              If lshifr == arr_10[ i, 2 ]
                fl := .t.
                If ar[ 10 ] == 1 // �⪠�
                  date_o := ar[ 9 ]
                Else // �������������
                  fl_nev := .t.
                Endif
              Endif
            Elseif ValType( arr_10[ i, 2, 1 ] ) == "C" // ���� � ���ᨢ�
              For j := 1 To Len( arr_10[ i, 2 ] )
                If lshifr == arr_10[ i, 2, j ]
                  fl := .t.
                  If ar[ 10 ] == 1 // �⪠�
                    date_o := ar[ 9 ]
                  Else // �������������
                    fl_nev := .t.
                  Endif
                  Exit
                Endif
              Next
            Else
              For j := 1 To Len( arr_10[ i, 2 ] )
                If lshifr == arr_10[ i, 2, j, 1 ] .and. ar[ 4 ] == arr_10[ i, 2, j, 2 ]
                  fl := .t.
                  If ar[ 10 ] == 1 // �⪠�
                    date_o := ar[ 9 ]
                  Else // �������������
                    fl_nev := .t.
                  Endif
                  Exit
                Endif
              Next
            Endif
          Endif
          If fl ; exit ; Endif
        Next
      Endif
      If !fl
        If ValType( arr_10[ i, 2 ] ) == "C" // ���� ���
          If ( k := AScan( au, {| x| x[ 1 ] == arr_10[ i, 2 ] } ) ) > 0
            fl := .t.
          Endif
        Elseif ValType( arr_10[ i, 2, 1 ] ) == "C" // ���� � ���ᨢ�
          For j := 1 To Len( arr_10[ i, 2 ] )
            If ( k := AScan( au, {| x| x[ 1 ] == arr_10[ i, 2, j ] } ) ) > 0
              fl := .t. ; Exit
            Endif
          Next
        Else // � ���ᨢ� ����: ��� � ��䨫�
          For j := 1 To Len( arr_10[ i, 2 ] )
            If ( k := AScan( au, {| x| x[ 1 ] == arr_10[ i, 2, j, 1 ] .and. x[ 2 ] == arr_10[ i, 2, j, 2 ] } ) ) > 0
              fl := .t. ; Exit
            Endif
          Next
        Endif
      Endif
      If fl .and. Len( arr_10[ i ] ) > 3
        fl := &( arr_10[ i, 4 ] )
      Endif
      If fl
        find ( Str( arr_10[ i, 1 ], 2 ) )
        If ValType( arr_10[ i, 2 ] ) == "A" .and. ValType( arr_10[ i, 2, 1 ] ) == "C" ;
            .and. arr_10[ i, 2, 1 ] == "4.1.12" .and. k_nev_4_1_12 > 0
          frd->vv := full_date( au[ k_nev_4_1_12, 4 ] )
          frd->vd := "����������"
        Elseif fl_nev
          frd->vv := "����������"
        Elseif !Empty( date_o )
          frd->vv := "�⪠�"
          frd->vo := full_date( date_o )
        Else
          frd->vv := full_date( au[ k, 4 ] )
          If au[ k, 4 ] < human->n_data
            frd->vo := full_date( au[ k, 4 ] )
          Endif
          frd->vd := iif( Empty( au[ k, 3 ] ), "-", "<b>" + au[ k, 3 ] + "</b>" )
        Endif
      Endif
    Next
    Select FRD
    Set Index To
    Go Top
    Do While !Eof()
      If emptyall( frd->vv, frd->vd, frd->vo )
        Delete
      Endif
      Skip
    Enddo
    Pack
    n := 0
    Go Top
    Do While !Eof()
      frd->ns := ++n
      Skip
    Enddo
    //
    adbf := { { "titul", "C", 50, 0 }, ;
      { "titul2", "C", 50, 0 }, ;
      { "fio", "C", 100, 0 }, ;
      { "fio2", "C", 60, 0 }, ;
      { "pol", "C", 50, 0 }, ;
      { "date_r", "C", 10, 0 }, ;
      { "d_dr", "C", 2, 0 }, ;
      { "m_dr", "C", 2, 0 }, ;
      { "y_dr", "C", 4, 0 }, ;
      { "vozrast", "N", 4, 0 }, ;
      { "subekt", "C", 50, 0 }, ;
      { "rajon", "C", 50, 0 }, ;
      { "gorod", "C", 50, 0 }, ;
      { "nas_p", "C", 50, 0 }, ;
      { "adres", "C", 200, 0 }, ;
      { "gorod_selo", "C", 50, 0 }, ;
      { "kod_lgot", "C", 2, 0 }, ;
      { "sever", "C", 30, 0 }, ;
      { "zanyat", "C", 200, 0 }, ;
      { "mobil", "C", 30, 0 }, ;
      { "n_data", "C", 10, 0 }, ;
      { "k_data", "C", 10, 0 }, ;
      { "v13_1", "C", 10, 0 }, ;
      { "v13_2", "C", 10, 0 }, ;
      { "v13_3", "C", 10, 0 }, ;
      { "v13_4", "C", 10, 0 }, ;
      { "v13_5", "C", 10, 0 }, ;
      { "v13_6", "C", 10, 0 }, ;
      { "v13_7", "C", 10, 0 }, ;
      { "v13_8", "C", 10, 0 }, ;
      { "v13_9", "C", 10, 0 }, ;
      { "v14", "C", 2, 0 }, ;
      { "v14_1", "C", 1, 0 }, ;
      { "v14_2", "C", 1, 0 }, ;
      { "v15", "C", 2, 0 }, ;
      { "v15_1", "C", 1, 0 }, ;
      { "v15_2", "C", 1, 0 }, ;
      { "v16_1", "C", 1, 0 }, ;
      { "v16_2", "C", 1, 0 }, ;
      { "v16_3", "C", 1, 0 }, ;
      { "v16_4", "C", 1, 0 }, ;
      { "v17", "C", 30, 0 }, ;
      { "v18", "C", 30, 0 }, ;
      { "v18_1", "C", 30, 0 }, ;
      { "v18_2", "C", 30, 0 }, ;
      { "v19", "C", 30, 0 }, ;
      { "v20", "C", 30, 0 }, ;
      { "vrach", "C", 100, 0 } }
    dbCreate( fr_titl, adbf )
    Use ( fr_titl ) New Alias FRT
    Append Blank
    frt->titul := iif( !emptyall( tmp->kod1h, tmp->kod2h ), "��ᯠ��ਧ�樨", "��䨫����᪮�� ����樭᪮�� �ᬮ��" )
    frt->titul2 := iif( !emptyall( tmp->kod1h, tmp->kod2h ), "��ᯠ��ਧ���", "��䨫����᪨� ����樭᪨� �ᬮ��" )
    arr := retfamimot( 1, .f. )
    frt->fio2 := arr[ 1 ] + " " + arr[ 2 ] + " " + arr[ 3 ]
    frt->fio := Expand( Upper( RTrim( frt->fio2 ) ) )
    frt->pol := iif( kart->pol == "�", sb1 + "��. - 1" + sb2 + ", ���. - 2", "��. - 1, " + sb1 + "���. - 2" + sb2 )
    frt->date_r := mdate_r
    frt->d_dr := SubStr( mdate_r, 1, 2 )
    frt->m_dr := SubStr( mdate_r, 4, 2 )
    frt->y_dr := SubStr( mdate_r, 7, 4 )
    frt->vozrast := mvozrast
    If f_is_selo()
      frt->gorod_selo := "��த᪠� - 1, " + sb1 + "ᥫ�᪠� - 2" + sb2
    Else
      frt->gorod_selo := sb1 + "��த᪠� - 1" + sb2 + ", ᥫ�᪠� - 2"
    Endif
    arr := ret_okato_array( kart_->okatog )
    frt->subekt := arr[ 1 ]
    frt->rajon  := arr[ 2 ]
    frt->gorod  := arr[ 3 ]
    frt->nas_p  := arr[ 4 ]
    If Empty( kart->adres )
      frt->adres := "㫨�" + sb1 + Space( 30 ) + sb2 + " ���" + sb1 + Space( 5 ) + sb2 + " ������" + sb1 + Space( 5 ) + sb2
    Else
      frt->adres := sb1 + PadR( kart->adres, 60 ) + sb2
    Endif
    If ( i := AScan( stm_kategor, {| x| x[ 2 ] == kart_->kategor } ) ) > 0 .and. Between( stm_kategor[ i, 3 ], 1, 8 )
      frt->kod_lgot := lstr( stm_kategor[ i, 3 ] )
    Endif
    frt->mobil := f_131_u_da_net( m1mobilbr, sb1, sb2 )
    frt->n_data := full_date( mn_data )
    frt->v13_1 := iif( mad1 > 140 .and. mad2 > 90, frt->n_data, "-" )
    frt->v13_2 := iif( m1glukozadn == 1 .or. mglukoza > 6.1, frt->n_data, "-" )
    frt->v13_3 := iif( m1tip_mas >= 3, frt->n_data, "-" )
    frt->v13_4 := iif( m1kurenie == 1, frt->n_data, "-" )
    frt->v13_5 := iif( m1riskalk == 1, frt->n_data, "-" )
    frt->v13_6 := iif( m1pod_alk == 1, frt->n_data, "-" )
    frt->v13_7 := iif( m1fiz_akt == 1, frt->n_data, "-" )
    frt->v13_8 := iif( m1ner_pit == 1, frt->n_data, "-" )
    frt->v13_9 := iif( m1ot_nasl1 == 1 .or. m1ot_nasl2 == 1 .or. m1ot_nasl3 == 1 .or. m1ot_nasl4 == 1, frt->n_data, "-" )
    If mdvozrast < 66
      If mdvozrast > 39
        frt->v15 := lstr( mssr )
        If 5 <= mssr .and. mssr < 10 // ��᮪�� ���.�㬬��� �थ筮-��㤨��� ��
          frt->v15_1 := lV
        Elseif mssr >= 10 // �祭� ��᮪�� ���.�㬬��� �थ筮-��㤨��� ��
          frt->v16_2 := lV
        Endif
      Else
        frt->v14 := lstr( mssr )
        If mssr < 1 // ������ ��.�㬬��� �थ筮-��㤨��� ��
          frt->v14_1 := lV
        Elseif 5 <= mssr .and. mssr < 10 // ������ ��.�㬬��� �थ筮-��㤨��� ��
          frt->v14_2 := lV
        Endif
      Endif
    Endif
    dbCreate( fr_data + "1", { { "name", "C", 200, 0 }, ;
      { "ns", "N", 2, 0 }, ;
      { "vn", "C", 10, 0 }, ;
      { "vv", "C", 10, 0 }, ;
      { "vd", "C", 20, 0 } } )
    If !Empty( tmp->kod2h ) // II �⠯
      human->( dbGoto( tmp->kod2h ) )
      M1RAB_NERAB := human->RAB_NERAB
      mk_data := human->k_data
      is_disp_19 := !( mk_data < 0d20190501 )
      m1GRUPPA := ret_gruppa_dvn( human_->RSLT_NEW )
      If !Between( m1gruppa, 1, 4 )
        m1GRUPPA := 0 ; func_error( 4, s_smg )
      Endif
      read_arr_dvn( human->kod )
      //
      Select HU
      find ( Str( human->kod, 7 ) )
      Do While hu->kod == human->kod .and. !Eof()
        usl->( dbGoto( hu->u_kod ) )
        If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
          lshifr := usl->shifr
        Endif
        AAdd( au, { AllTrim( lshifr ), ;
          hu_->PROFIL, ;
          iif( Left( hu_->kod_diag, 1 ) == "Z", "", hu_->kod_diag ), ;
          c4tod( hu->date_u );
          } )
        Select HU
        Skip
      Enddo
      For k := 1 To Len( au )
        If AScan( arr_otklon, au[ k, 1 ] ) > 0
          au[ k, 3 ] := "+" // �⪫������ � ��᫥�������
        Endif
      Next
      If is_disp_19
        arr_11 := { ;
          { 1, "�㯫��᭮� ᪠��஢���� ��娮�䠫��� ���਩", "8.23.706" }, ;
          { 2, "���⣥������ �࣠��� ��㤭�� ���⪨", "7.2.702" }, ;
          { 3, "�� �࣠��� ��㤭�� ������", "7.2.701" }, ;
          { 4, "���ࠫ쭠� �� ������", "7.2.703" }, ;
          { 5, "�� �࣠��� ��㤭�� ������ (� ��������-���)", "7.2.704" }, ;
          { 6, "�����⮭��� ��ᨮ���� �� ������", "7.2.705" }, ;
          { 7, "����ᨣ��������᪮��� ���������᪠�", "10.6.710" }, ;
          { 8, "����஬���᪮���", "10.4.701" }, ;
          { 9, "�����䠣�����த㮤���᪮���", "10.3.713" }, ;
          { 10, "���஬����", "16.1.717" }, ;
          { 11, "�ᬮ�� (���������) ��箬-���஫����", "2.84.1" }, ;
          { 12, "�ᬮ�� (���������) ��箬-���࣮� ��� ��箬-�஫����", "2.84.10" }, ;
          { 13, "�ᬮ�� (���������) ��箬-���࣮� ��� ��箬-�����ப⮫����", "2.84.6" }, ;
          { 14, "�ᬮ�� (���������) ��箬-����஬-�����������", "2.84.5" }, ;
          { 15, "�ᬮ�� (���������) ��箬-��ਭ���ਭ�������", "2.84.8" }, ;
          { 16, "�ᬮ�� (���������) ��箬-��⠫쬮�����", "2.84.3" }, ;
          { 17, "���㡫����� ��䨫����᪮� �������஢����", "56.1.723" }, ;
          { 18, "�ਥ� (�ᬮ��) ���-�࠯���", "2.84.11" };
          }
      Else
        arr_11 := { ;
          { 1, "�㯫��᭮� ᪠��஢���� ��娮�䠫��� ���਩", { "8.23.6", "8.23.706" } }, ;
          { 2, "�ᬮ�� (���������) ��箬-���஫����", "2.84.1" }, ;
          { 3, "���䠣�����த㮤���᪮���", "10.3.13" }, ;
          { 4, "�ᬮ�� (���������) ��箬-���࣮� ��� ��箬-�஫����", "2.84.10" }, ;
          { 5, "�ᬮ�� (���������) ��箬-���࣮� ��� ��箬-�����ப⮫����", "2.84.6" }, ;
          { 6, "������᪮��� ��� ४�஬���᪮���", { "10.4.1", "10.6.10" } }, ;
          { 7, "��।������ ��������� ᯥ��� �஢�", "4.12.173" }, ;
          { 8, "���஬����", { "16.1.17", "16.1.717" } }, ;
          { 9, "�ᬮ�� (���������) ��箬-����஬-�����������", "2.84.5" }, ;
          { 10, "��।������ ���業��樨 �����஢������ ����������� � �஢� ��� ��� �� ⮫�࠭⭮��� � ����", { "4.12.170", "4.12.171" } }, ;
          { 11, "�ᬮ�� (���������) ��箬-��ਭ���ਭ�������", "2.84.8" }, ;
          { 12, "������ �஢� �� �஢��� ᮤ�ঠ��� �����ᯥ���᪮�� ��⨣���", "4.14.66" }, ;
          { 13, "�ᬮ�� (���������) ��箬-��⠫쬮�����", "2.84.3" }, ;
          { 14, "�������㠫쭮� 㣫㡫����� ��䨫����᪮� �������஢����", { "56.1.15", "56.1.20" } }, ;
          { 15, "��㯯���� ��䨫����᪮� �������஢���� (誮�� ��樥��)", "0" }, ;
          { 16, "�ਥ� (�ᬮ��) ���-�࠯���", { "2.84.2", "2.84.7", "2.84.9", "2.84.11" } };
          }
        If is_disp .and. Year( mk_data ) > 2017 // � 18 ����
          arr_11[ 6 ] := { 6, "����ᨣ��������᪮��� ���������᪠�", "10.6.710" }
          arr_11[ 14 ] := { 14, "�������㠫쭮� ��� ��㯯���� (誮�� ��� ��樥��) 㣫㡫����� ��䨫����᪮� �������஢����", "56.1.723" }
          del_array( arr_11, 15 )
          del_array( arr_11, 12 )
          del_array( arr_11, 10 )
          del_array( arr_11, 7 )
          del_array( arr_11, 3 )
        Endif
      Endif
      Use ( fr_data + "1" ) New Alias FRD1
      For n := 1 To Len( arr_11 )
        Append Blank
        frd1->name := arr_11[ n, 2 ]
        frd1->ns := arr_11[ n, 1 ]
      Next
      Index On Str( ns, 2 ) To tmp_frd1
      For k := 1 To Len( au )
        fl := .f.
        For i := 1 To Len( arr_11 )
          If ValType( arr_11[ i, 3 ] ) == "A"
            fl := ( AScan( arr_11[ i, 3 ], au[ k, 1 ] ) > 0 )
          Else
            fl := ( au[ k, 1 ] == arr_11[ i, 3 ] )
          Endif
          If fl ; exit ; Endif
        Next
        If fl
          find ( Str( arr_11[ i, 1 ], 2 ) )
          frd1->vn := full_date( mk_data1 )
          frd1->vv := full_date( au[ k, 4 ] )
          frd1->vd := iif( Empty( au[ k, 3 ] ), "-", "<b>" + au[ k, 3 ] + "</b>" )
        Endif
      Next
      Select FRD1
      Set Index To
      Go Top
      Do While !Eof()
        If emptyall( frd1->vv, frd1->vd, frd1->vn )
          Delete
        Endif
        Skip
      Enddo
      Pack
      n := 0
      Go Top
      Do While !Eof()
        frd1->ns := ++n
        Skip
      Enddo
    Endif
    frt->k_data := full_date( mk_data )
    frt->zanyat := iif( M1RAB_NERAB == 0, sb1, "" ) + "1 - ࠡ�⠥�" + iif( M1RAB_NERAB == 0, sb2, "" ) + ";  " + ;
      iif( M1RAB_NERAB == 1, sb1, "" ) + "2 - �� ࠡ�⠥�" + iif( M1RAB_NERAB == 1, sb2, "" ) + ";  " + ;
      iif( M1RAB_NERAB == 2, "<u>", "" ) + "3 - �����騩�� � ��ࠧ���⥫쭮� �࣠����樨 �� �筮� �ଥ" + iif( M1RAB_NERAB == 2, "</u>", "" ) + "."
    frt->sever := f_131_u_da_net( 0, sb1, sb2 )
    Do Case
    Case m1gruppa == 1
      frt->v16_1 := lV
    Case m1gruppa == 2
      frt->v16_2 := lV
    Case m1gruppa == 3
      frt->v16_3 := lV
    Case m1gruppa == 4
      frt->v16_4 := lV
    Endcase
    frt->v17   := f_131_u_da_net( m1nazn_l, sb1, sb2 )
    frt->v18   := f_131_u_da_net( m1dopo_na, sb1, sb2 )
    frt->v18_1 := f_131_u_da_net( m1ssh_na, sb1, sb2 )
    frt->v18_2 := f_131_u_da_net( m1psih_na, sb1, sb2 )
    frt->v19   := f_131_u_da_net( m1spec_na, sb1, sb2 )
    frt->v20   := f_131_u_da_net( m1sank_na, sb1, sb2 )
    r_use( dir_server() + "mo_pers",, "P2" )
    Goto ( human_->vrach )
    frt->vrach := p2->fio
    //
    arr_12 := { ;
      { 7, "1", "������� ��䥪樮��� � ��ࠧ���� �������", "A00-B99" }, ;
      { 8, "1.1", "  � ⮬ �᫥: �㡥�㫥�", "A15-A19" }, ;
      { 9, "2", "������ࠧ������", "C00-D48" }, ;
      { 10, "2.1", "� ⮬ �᫥: �������⢥��� ������ࠧ������ � ������ࠧ������ in situ", "C00-D09" }, ;
      { 11, "2.2", "� ⮬ �᫥: ��饢���", "C15,D00.1" }, ;
      { 12, "2.2.1", " �� ��� � 1-2 �⠤��", "C15,D00.1", "1" }, ;
      { 13, "2.3", "���㤪�", "C16,D00.2" }, ;
      { 14, "2.3.1", " �� ��� � 1-2 �⠤��", "C16,D00.2", "1" }, ;
      { 15, "2.4", "�����筮� ��誨", "C18,D01.0" }, ;
      { 16, "2.4.1", " �� ��� � 1-2 �⠤��", "C18,D01.0", "1" }, ;
      { 17, "2.5", "४�ᨣ�������� ᮥ�������, ��אַ� ��誨, ������� ��室� (����) � ����쭮�� ������", "C19-C21,D01.1-D01.3" }, ;
      { 18, "2.5.1", " �� ��� � 1-2 �⠤��", "C19-C21,D01.1-D01.3", "1" }, ;
      { 19, "2.6", "������㤮筮� ������", "C25" }, ;
      { 20, "2.6.1", " �� ��� � 1-2 �⠤��", "C25", "1" }, ;
      { 21, "2.7", "��奨, �஭客 � �������", "C33,C34,D02.1-D02.2" }, ;
      { 22, "2.7.1", " �� ��� � 1-2 �⠤��", "C33,C34,D02.1-D02.2", "1" }, ;
      { 23, "2.8", "����筮� ������", "C50,D05" }, ;
      { 24, "2.8.1", " �� ��� � 1-2 �⠤��", "C50,D05", "1" }, ;
      { 25, "2.9", "襩�� ��⪨", "C53,D06" }, ;
      { 26, "2.9.1", " �� ��� � 1-2 �⠤��", "C53,D06", "1" }, ;
      { 27, "2.10", "⥫� ��⪨", "C54" }, ;
      { 28, "2.10.1", " �� ��� � 1-2 �⠤��", "C54", "1" }, ;
      { 29, "2.11", "�筨��", "C56" }, ;
      { 30, "2.11.1", " �� ��� � 1-2 �⠤��", "C56", "1" }, ;
      { 31, "2.12", "�।��⥫쭮� ������", "C61,D07.5" }, ;
      { 32, "2.12.1", " �� ��� � 1-2 �⠤��", "C61,D07.5", "1" }, ;
      { 33, "2.13", "��窨, �஬� ���筮� ��堭��", "C64" }, ;
      { 34, "2.13.1", " �� ��� � 1-2 �⠤��", "C64", "1" }, ;
      { 35, "3", "������� �஢�, �஢�⢮��� �࣠��� � �⤥��� ����襭��, ��������騥 ���㭭� ��堭���", "D50-D89" }, ;
      { 36, "3.1", "� ⮬ �᫥: ������, �易��� � ��⠭���, ��������᪨� ������, �������᪨� � ��㣨� ������", "D50-D64" }, ;
      { 37, "4", "������� ���ਭ��� ��⥬�, ����ன�⢠ ��⠭�� � ����襭�� ������ �����", "E00-E90" }, ;
      { 38, "4.1", "� ⮬ �᫥: ���� ������", "E10-E14" }, ;
      { 39, "4.2", "���७��", "E66" }, ;
      { 40, "4.3", "����襭�� ������ ������⥨��� � ��㣨� ���������", "E78" }, ;
      { 41, "5", "������� ��ࢭ�� ��⥬�", "G00-G99" }, ;
      { 42, "5.1", "� ⮬ �᫥: ��室�騥 �ॡࠫ�� �襬��᪨� ������ [�⠪�] � த�⢥��� ᨭ�஬�", "G45" }, ;
      { 43, "6", "������� ����� � ��� �ਤ��筮�� ������", "H00-H59" }, ;
      { 44, "6.1", "� ⮬ �᫥: ����᪠� ���ࠪ� � ��㣨� ���ࠪ��", "H25,H26" }, ;
      { 45, "6.2", "���㪮��", "H40" }, ;
      { 46, "6.3", "᫥��� � ���������� �७��", "H54" }, ;
      { 47, "7", "������� ��⥬� �஢����饭��", "I00-I99" }, ;
      { 48, "7.1", "� ⮬ �᫥: �������, �ࠪ�ਧ��騥�� ����襭�� �஢�� ���������", "I10-I15" }, ;
      { 49, "7.2", "�襬��᪠� ������� ���", "I20-I25" }, ;
      { 50, "7.2.1", "� ⮬ �᫥: �⥭���न� (��㤭�� ����)", "I20" }, ;
      { 51, "7.2.2", "� ⮬ �᫥ ���⠡��쭠� �⥭���न�", "I20.0" }, ;
      { 52, "7.2.3", "�஭��᪠� �襬��᪠� ������� ���", "I25" }, ;
      { 53, "7.2.4", "� ⮬ �᫥: ��७�ᥭ�� � ��諮� ����� �����ठ", "I25.2" }, ;
      { 54, "7.3", "��㣨� ������� ���", "I30-I52" }, ;
      { 55, "7.4", "�ॡ஢������ �������", "I60-I69" }, ;
      { 56, "7.4.1", "� ⮬ �᫥: ���㯮ઠ � �⥭�� ���ॡࠫ��� ���਩, �� �ਢ���騥 � ������ �����, � ���㯮ઠ � �⥭�� �ॡࠫ��� ���਩, �� �ਢ���騥 � ������ �����", "I65,I66" }, ;
      { 57, "7.4.2", "��㣨� �ॡ஢������ �������", "I67" }, ;
      { 58, "7.4.3", "��᫥��⢨� �㡠�孮����쭮�� �஢�����ﭨ�, ��᫥��⢨� ������९���� �஢�����ﭨ�, ��᫥��⢨� ��㣮�� ���ࠢ����᪮�� ������९���� �஢�����ﭨ�, ��᫥��⢨� ����� �����, ��᫥��⢨� ������, �� ��筥��� ��� �஢�����ﭨ� ��� ����� �����", "I69.0-I69.4" }, ;
      { 59, "7.4.4", "����ਧ�� ���譮� �����", "I71.3-I71.4" }, ;
      { 60, "8", "������� �࣠��� ��堭��", "J00-J98" }, ;
      { 61, "8.1", "� ⮬ �᫥: ����᭠� ���������, ���������, �맢����� Streptococcus pneumonia, ���������, �맢����� Haemophilus influenza, ����ਠ�쭠� ���������, ���������, �맢����� ��㣨�� ��䥪樮��묨 ����㤨⥫ﬨ, ��������� �� ��������, �������஢����� � ��㣨� ��ਪ��, ��������� ��� ��筥��� ����㤨⥫�", "J12-J18" }, ;
      { 62, "8.2", "�஭��, �� ��筥��� ��� ����� � �஭��᪨�, ���⮩ � ᫨����-������ �஭��᪨� �஭��, �஭��᪨� �஭�� ����筥���, �䨧���", "J40-J43" }, ;
      { 63, "8.3", "��㣠� �஭��᪠� ������⨢��� ����筠� �������, ��⬠, ��⬠��᪨� �����, �஭�����᪠� �������", "J44-J47" }, ;
      { 64, "9", "������� �࣠��� ��饢�७��", "K00-K93" }, ;
      { 65, "9.1", "� ⮬ �᫥: 梨� ���㤪�, 梨� �������⨯���⭮� ��誨", "K25,K26" }, ;
      { 66, "9.2", "������ � �㮤����", "K29" }, ;
      { 67, "9.3", "����䥪樮��� ���� � �����", "K50-K52" }, ;
      { 68, "9.4", "��㣨� ������� ���筨��", "K55-K63" }, ;
      { 69, "10", "������� ��祯������ ��⥬�", "N00-N99" }, ;
      { 70, "10.1", "� ⮬ �᫥: ����௫���� �।��⥫쭮� ������, ��ᯠ��⥫�� ������� �।��⥫쭮� ������, ��㣨� ������� �।��⥫쭮� ������", "N40-N42" }, ;
      { 71, "10.2", "���ப���⢥���� ��ᯫ���� ����筮� ������", "N60" }, ;
      { 72, "10.3", "��ᯠ��⥫�� ������� ���᪨� ⠧���� �࣠���", "N70-N77" }, ;
      { 73, "11", "��稥 �����������", "" };
      }
    len12 := Len( arr_12 )
    diag12 := Array( len12 )
    dbCreate( fr_data + "2", { { "name", "C", 350, 0 }, ;
      { "diagnoz", "C", 50, 0 }, ;
      { "ns", "N", 2, 0 }, ;
      { "stroke", "C", 8, 0 }, ;
      { "vz", "C", 10, 0 }, ;
      { "v1", "C", 10, 0 }, ;
      { "vd", "C", 10, 0 }, ;
      { "vp", "C", 10, 0 } } )
    Use ( fr_data + "2" ) New Alias FRD2
    For n := 1 To len12
      Append Blank
      frd2->name := iif( "." $ arr_12[ n, 2 ], "", "<b>" ) + arr_12[ n, 3 ] + iif( "." $ arr_12[ n, 2 ], "", "</b>" )
      frd2->ns := n
      frd2->stroke := arr_12[ n, 2 ]
      If Len( arr_12[ n ] ) < 5
        frd2->diagnoz := arr_12[ n, 4 ]
      Endif
      s2 := arr_12[ n, 4 ]
      If Len( arr_12[ n ] ) > 4
        frd2->vp := "-"
      Endif
      diag12[ n ] := {}
      For i := 1 To NumToken( s2, "," )
        s3 := Token( s2, ",", i )
        If "-" $ s3
          d1 := Token( s3, "-", 1 )
          d2 := Token( s3, "-", 2 )
        Else
          d1 := d2 := s3
        Endif
        AAdd( diag12[ n ], { diag_to_num( d1, 1 ), diag_to_num( d2, 2 ) } )
      Next
    Next
    For i := 1 To 5
      pole_diag := "mdiag" + lstr( i )
      pole_d_diag := "mddiag" + lstr( i )
      pole_1pervich := "m1pervich" + lstr( i )
      pole_1stadia := "m1stadia" + lstr( i )
      pole_1dispans := "m1dispans" + lstr( i )
      pole_d_dispans := "mddispans" + lstr( i )
      If !Empty( &pole_diag ) .and. !( Left( &pole_diag, 1 ) == "Z" )
        au := {}
        d := diag_to_num( &pole_diag, 1 )
        For n := 1 To len12
          r := diag12[ n ]
          For j := 1 To Len( r )
            fl := Between( d, r[ j, 1 ], r[ j, 2 ] )
            If fl .and. Len( arr_12[ n ] ) > 4 // ���� �஢���� �⠤��
              If human->k_data < 0d20150401 // �� 1.04.2015
                fl := ( &pole_1stadia == 0 ) // ࠭���
              Else
                fl := ( &pole_1stadia < 3 ) // 1 � 2 �⠤��
              Endif
            Endif
            If fl
              AAdd( au, n )
            Endif
          Next
        Next
        If Empty( au ) // ����ᨬ � ��稥 �����������
          AAdd( au, len12 )
        Endif
        For j := 1 To Len( au )
          Goto ( au[ j ] )
          if &pole_1pervich == 1 // �����
            frd2->vz := frd2->v1 := frt->k_data // ��� ��� �࠯���
            if &pole_1dispans == 1
              frd2->vd := frt->k_data
            Endif
          elseif &pole_1pervich == 0 // ࠭�� ������
            frd2->vz := full_date( &pole_d_diag )
            if &pole_1dispans == 1
              frd2->vd := iif( Empty( &pole_d_dispans ), frd2->vz, full_date( &pole_d_dispans ) )
            Endif
          Else // �।���⥫�� �������
            If Empty( frd2->vp )
              frd2->vp := frt->k_data
            Endif
          Endif
        Next
      Endif
    Next
    Close databases
    call_fr( "mo_131_u" ) // �����
    Close databases
    Eval( blk_open )
    Goto ( rec )
    rest_box( buf )
  Endif

  Return ret

// 01.07.17
Static Function f_131_u_da_net( k, sb1, sb2 )

  If k > 1 ; k := 1 ; Endif // �᫨ ����� "��" ��⮢� �⢥�

  Return f3_inf_dds_karta( { { "�� - 1", 1 }, { "��� - 2", 0 } }, k, ";  ", sb1, sb2, .f. )

// 28.05.24 �ਫ������ � �ਪ��� ���� "������" �� 12.05.2017�. �1615
Function f21_inf_dvn( par ) // ᢮�

  Local arr_m, buf := save_maxrow(), s, as := {}, as1[ 14 ], i, j, k, n, ar, at, ii, g1, sh := 65, fl, mdvozrast, adbf
  Local kol_2_year_dvn := 0, kol_2_year_prof := 0
  Local kol_2_year_dvn_40 := 0, kol_2_year_prof_40 := 0

  If ( st_a_uch := inputn_uch( T_ROW, T_COL -5,,, @lcount_uch ) ) != NIL ;
      .and. ( arr_m := year_month(,,, 5 ) ) != Nil .and. f0_inf_dvn( arr_m, par > 1, par == 3, .t. )
    Private arr_usl_bio := { { ;
      "A11.20.010", ;// ������ ����筮� ������ ��᪮����
      "A11.20.010.001", ;// ������ ������ࠧ������ ����筮� ������ ��楫쭠� �㭪樮���� ��� ����஫�� ७⣥������᪮�� ��᫥�������
      "A11.20.010.002", ;// ������ ������ࠧ������ ����筮� ������ �ᯨ�樮���� ����㬭�� ��� ����஫�� ७⣥������᪮�� ��᫥�������
      "A11.20.010.004" ;// ������ �����쯨�㥬�� ������ࠧ������ ����筮� ������ �ᯨ�樮���� ����㬭�� ��� ����஫�� ���ࠧ�㪮���� ��᫥�������
    }, ;
    { ;
      "A11.18.001", ;// ������ �����筮� ��誨 ��᪮���᪠�
      "A11.18.002", ;// ������ �����筮� ��誨 ����⨢���
      "A11.19.001", ;// ������ ᨣ�������� ��誨 � ������� �������᪮���᪨� �孮�����
      "A11.19.002", ;// ������ ��אַ� ��誨 � ������� �������᪮���᪨� �孮�����
      "A11.19.003", ;// ������ ���� � ��ਠ���쭮� ������
      "A11.19.009" ;// ������ ⮫�⮩ ��誨 �� �����᪮���
    }, ;
    { ;
      "A11.20.011", ;// ������ 襩�� ��⪨
      "A11.20.011.001", ;// ������ 襩�� ��⪨ ࠤ����������
      "A11.20.011.002", ;// ������ 襩�� ��⪨ ࠤ���������� ����ᮢ�����
      "A11.20.011.003" ;// ������ 襩�� ��⪨ �������
    }, ;
    { ;
      "A11.01.001", ;// ������ ����
      "A11.07.001", ;// ������ ᫨���⮩ ������ ��
      "A11.07.002", ;// ������ �몠
      "A11.07.003", ;// ������ ���������, ���� � ���������
      "A11.07.004", ;// ������ ���⪨, ���� � ��窠
      "A11.07.005", ;// ������ ᫨���⮩ �।����� ������ ��
      "A11.07.006", ;// ������ ����
      "A11.07.007", ;// ������ ⪠��� ���
      "A11.07.016", ;// ������ ᫨���⮩ �⮣��⪨
      "A11.07.016.001", ;// ������ ᫨���⮩ �⮣��⪨ ��� ����஫�� ��᪮���᪮�� ��᫥�������
      "A11.07.020", ;// ������ ��� ������
      "A11.07.020.001", ;// ������ ������譮� ��� ������
      "A11.08.001", ;// ������ ᫨���⮩ �����窨 ���⠭�
      "A11.08.001.001", ;// ������ ⪠��� ���⠭� ��� ����஫�� ��ਭ��᪮���᪮�� ��᫥�������
      "A11.08.002", ;// ������ ᫨���⮩ �����窨 ������ ���
      "A11.08.003", ;// ������ ᫨���⮩ �����窨 ��ᮣ��⪨
      "A11.08.003.001", ;// ������ ᫨���⮩ �����窨 ��ᮣ��⪨ ��� ����஫�� ��᪮���᪮�� ��᫥�������
      "A11.08.015", ;// ������ ᫨���⮩ �����窨 �������ᮢ�� �����
      "A11.08.016", ;// ������ ⪠��� ���襢������ ��ଠ��
      "A11.08.016.001", ;// ������ ⪠��� ���襢������ ��ଠ�� ��� ����஫�� ��᪮���᪮�� ��᫥�������
      "A11.26.001" ;// ������ ������ࠧ������ ���, ����⨢� ��� ண�����
    };
      }
    Private arr_21[ 50 ], arr_316 := {}, arr_ne := {}
    AFill( arr_21, 0 )
    mywait( "���� ����⨪�" )
    adbf := { { "name", "C", 80, 0 }, ;
      { "NN", "N", 2, 0 }, ;
      { "g1", "N", 6, 0 }, ;
      { "g2", "N", 6, 0 }, ;
      { "g3", "N", 6, 0 }, ;
      { "g4", "N", 6, 0 }, ;
      { "g5", "N", 6, 0 }, ;
      { "g6", "N", 6, 0 }, ;
      { "g7", "N", 6, 0 }, ;
      { "g8", "N", 6, 0 }, ;
      { "g9", "N", 6, 0 } }
    dbCreate( cur_dir() + "tmp1", adbf )
    Use ( cur_dir() + "tmp1" ) new
    Index On Str( nn, 2 ) to ( cur_dir() + "tmp1" )
    Append Blank
    tmp1->nn := 2 ;  tmp1->name := "�ᬮ�७� �ᥣ� (�����訫� I �⠯)"
    Append Blank
    tmp1->nn := 3 ;  tmp1->name := "�� ��.2 ��᫥ 18:00"
    Append Blank
    tmp1->nn := 4 ;  tmp1->name := "�� ��.2 � �㡡���"
    Append Blank
    tmp1->nn := 5 ;  tmp1->name := "�� ��.2 ��襤訥 �� ��᫥������� � ���� ����"
    Append Blank
    tmp1->nn := 6 ;  tmp1->name := "�� ��.2 �ᥣ� ᥫ�᪨� ��⥫��"
    Append Blank
    tmp1->nn := 7 ;  tmp1->name := "�� ��.6 ᥫ�᪨� ��⥫�� ��᫥ 18:00"
    Append Blank
    tmp1->nn := 8 ;  tmp1->name := "�� ��.6 ᥫ�᪨� ��⥫�� � �㡡���"
    Append Blank
    tmp1->nn := 9 ;  tmp1->name := "������� � ����� ����.�����.����������ﬨ"
    Append Blank
    tmp1->nn := 10 ; tmp1->name := "�ᥣ� ����� ����� �����.�����������"
    Append Blank
    tmp1->nn := 11 ; tmp1->name := "�� ��.9 ������� ������� ���.�஢����饭��"
    Append Blank
    tmp1->nn := 12 ; tmp1->name := "�� ��.9 ������� ���"
    Append Blank
    tmp1->nn := 13 ; tmp1->name := "        �� ��.12 � �.�. � 1 � 2 �⠤���"
    Append Blank
    tmp1->nn := 14 ; tmp1->name := "�� ��.9 ������� ���� ������"
    Append Blank
    tmp1->nn := 15 ; tmp1->name := "        � �.�. ���� ������ I ⨯�"
    Append Blank
    tmp1->nn := 16 ; tmp1->name := "�� ��.9 ������� ���㪮��"
    Append Blank
    tmp1->nn := 17 ; tmp1->name := "�� ��.9 ������� �஭.������� �࣠��� ��堭��"
    Append Blank
    tmp1->nn := 18 ; tmp1->name := "�� ��.9 ������� ������� �࣠��� ��饢�७��"
    Append Blank
    tmp1->nn := 19 ; tmp1->name := "�� ��.9 ������� ����� �� ���.�������"
    Append Blank
    tmp1->nn := 20 ; tmp1->name := "�� ��.9 ������� �뫮 ���� ��祭��"
    Append Blank
    tmp1->nn := 21 ; tmp1->name := "   �� ��.19 �� ��� ᥫ�᪨� ��⥫��"
    dbCreate( cur_dir() + "tmp11", adbf )
    Use ( cur_dir() + "tmp11" ) new
    Index On Str( nn, 2 ) to ( cur_dir() + "tmp11" )
    Append Blank
    tmp11->nn :=  1 ; tmp11->name := "����� ����� �� ��ᯠ���� ����"
    Append Blank
    tmp11->nn :=  2 ; tmp11->name := "������� ᯥ樠����஢����� ���.������"
    Append Blank
    tmp11->nn :=  3 ; tmp11->name := "������� ॠ�����樮��� ��ய����"
    Append Blank
    tmp11->nn :=  4 ; tmp11->name := "�⪠������ �� �஢������ ���-�� � 楫��"
    Append Blank
    tmp11->nn :=  5 ; tmp11->name := "����� ��樥�⮢ � ������⮫�����"
    Append Blank
    tmp11->nn :=  6 ; tmp11->name := "  � �.�. 1 �⠤��"
    Append Blank
    tmp11->nn :=  7 ; tmp11->name := "         2 �⠤��"
    Append Blank
    tmp11->nn :=  8 ; tmp11->name := "         3 �⠤��"
    Append Blank
    tmp11->nn :=  9 ; tmp11->name := "         4 �⠤��"
    Append Blank
    tmp11->nn := 10 ; tmp11->name := "���ࠢ���� �� �������.㣫㡫.��䨫���.����-��"
    Append Blank
    tmp11->nn := 11 ; tmp11->name := "���-�� ��襤�� �������.㣫㡫.��䨫���.����-��"
    Append Blank
    tmp11->nn := 12 ; tmp11->name := "��業� �墠� �������.㣫㡫.��䨫���.����-���"
    Append Blank
    tmp11->nn := 13 ; tmp11->name := "���ࠢ���� �ࠦ��� �� ��㯯���� ��䨫���.����-��"
    Append Blank
    tmp11->nn := 14 ; tmp11->name := "���-�� ��襤�� ��㯯���� ��䨫���.����-��"
    Append Blank
    tmp11->nn := 15 ; tmp11->name := "��業� �墠� ��㯯��� ��䨫���.����-���"
    //
    dbCreate( cur_dir() + "tmp12", adbf )
    Use ( cur_dir() + "tmp12" ) new
    Index On Str( nn, 2 ) to ( cur_dir() + "tmp12" )
    Append Blank
    tmp12->nn :=  1 ; tmp12->name := "���-�� �������䨩 � ࠬ��� ��ᯠ��ਧ�樨"
    Append Blank
    tmp12->nn :=  2 ; tmp12->name := "  ���-�� �����客�����"
    Append Blank
    tmp12->nn :=  3 ; tmp12->name := "    ����� ��⮫���� � ����筮� ������"
    Append Blank
    tmp12->nn :=  4 ; tmp12->name := "      ���ࠢ���� �� 2 �⠯ ��ᯠ��ਧ�樨"
    Append Blank
    tmp12->nn :=  5 ; tmp12->name := "      �믮����� ������ ����筮� ������"
    Append Blank                        // C50,D05
    tmp12->nn :=  6 ; tmp12->name := "    ����� ��� ����筮� ������, �ᥣ�"
    Append Blank
    tmp12->nn :=  7 ; tmp12->name := "      in situ"
    Append Blank
    tmp12->nn :=  8 ; tmp12->name := "      �� ��� 1 �⠤��"
    Append Blank
    tmp12->nn :=  9 ; tmp12->name := "      �� ��� 2 �⠤��"
    Append Blank
    tmp12->nn := 10 ; tmp12->name := "      �� ��� 3 �⠤��"
    Append Blank
    tmp12->nn := 11 ; tmp12->name := "      �� ��� 4 �⠤��"
    Append Blank
    tmp12->nn := 12 ; tmp12->name := "���-�� �������� ���� �� ������ �஢�"
    Append Blank
    tmp12->nn := 13 ; tmp12->name := "  ���-�� �����客�����"
    Append Blank
    tmp12->nn := 14 ; tmp12->name := "    ���� ������⥫�� ��� �� ������ �஢� � ����"
    Append Blank
    tmp12->nn := 15 ; tmp12->name := "      ���ࠢ���� �� 2 �⠯ ��ᯠ��ਧ�樨"
    Append Blank
    tmp12->nn := 16 ; tmp12->name := "        �믮����� ������᪮���"
    Append Blank
    tmp12->nn := 17 ; tmp12->name := "        �믮����� ४�஬���᪮���"
    Append Blank
    tmp12->nn := 18 ; tmp12->name := "        �믮����� ������ �� ������᪮��� ��� ४�஬���᪮���"
    Append Blank                     // C18-C21,D01.0-D01.3
    tmp12->nn := 19 ; tmp12->name := "    ����� ��� ⮫�⮩/��אַ� ��誨, �ᥣ�"
    Append Blank
    tmp12->nn := 20 ; tmp12->name := "      in situ"
    Append Blank
    tmp12->nn := 21 ; tmp12->name := "      �� ��� 1 �⠤��"
    Append Blank
    tmp12->nn := 22 ; tmp12->name := "      �� ��� 2 �⠤��"
    Append Blank
    tmp12->nn := 23 ; tmp12->name := "      �� ��� 3 �⠤��"
    Append Blank
    tmp12->nn := 24 ; tmp12->name := "      �� ��� 4 �⠤��"
    Append Blank
    tmp12->nn := 25 ; tmp12->name := "���-�� ���-��⮢  � ࠬ��� ��ᯠ��ਧ�樨"
    Append Blank
    tmp12->nn := 26 ; tmp12->name := "  ���-�� �����客�����"
    Append Blank
    tmp12->nn := 27 ; tmp12->name := "    ��﫥�� ��⮫���� 襩�� ��⪨"
    Append Blank
    tmp12->nn := 28 ; tmp12->name := "      ���ࠢ���� �� 2 �⠯ ��ᯠ��ਧ�樨"
    Append Blank
    tmp12->nn := 29 ; tmp12->name := "      �믮����� ������ 襩�� ��⪨"
    Append Blank                    // �53,D06
    tmp12->nn := 30 ; tmp12->name := "    ����� ��� 襩�� ��⪨, �ᥣ�"
    Append Blank
    tmp12->nn := 31 ; tmp12->name := "      in situ"
    Append Blank
    tmp12->nn := 32 ; tmp12->name := "      �� ��� 1 �⠤��"
    Append Blank
    tmp12->nn := 33 ; tmp12->name := "      �� ��� 2 �⠤��"
    Append Blank
    tmp12->nn := 34 ; tmp12->name := "      �� ��� 3 �⠤��"
    Append Blank
    tmp12->nn := 35 ; tmp12->name := "      �� ��� 4 �⠤��"
    Append Blank
    tmp12->nn := 36 ; tmp12->name := "���-�� �����-��, � ������ ����� ��⮫���� ���� � ������� ᫨������"
    Append Blank
    tmp12->nn := 37 ; tmp12->name := "  ���ࠢ���� �� ������ ���� � ������� ᫨������"
    Append Blank                      // C00,C14.8,C43,C44,D00.0,D03,D04
    tmp12->nn := 38 ; tmp12->name := "  ����� ��� ���� � ������� ᫨������, �ᥣ�"
    Append Blank
    tmp12->nn := 39 ; tmp12->name := "    in situ"
    Append Blank
    tmp12->nn := 40 ; tmp12->name := "    �� ��� 1 �⠤��"
    Append Blank
    tmp12->nn := 41 ; tmp12->name := "    �� ��� 2 �⠤��"
    Append Blank
    tmp12->nn := 42 ; tmp12->name := "    �� ��� 3 �⠤��"
    Append Blank
    tmp12->nn := 43 ; tmp12->name := "    �� ��� 4 �⠤��"
    //
    dbCreate( cur_dir() + "tmp2", { { "kod_k", "N", 7, 0 }, ;
      { "rslt1", "N", 3, 0 }, ;
      { "rslt2", "N", 3, 0 } } )
    Use ( cur_dir() + "tmp2" ) new
    Index On Str( kod_k, 7 ) to ( cur_dir() + "tmp2" )
    r_use( dir_server() + "mo_rpdsh",, "RPDSH" )
    Index On Str( KOD_H, 7 ) to ( cur_dir() + "tmprpdsh" )
    r_use( dir_server() + "kartote_",, "KART_" )
    r_use( dir_server() + "uslugi",, "USL" )
    r_use( dir_server() + "human_u_",, "HU_" )
    r_use( dir_server() + "human_u", dir_server() + "human_u", "HU" )
    Set Relation To RecNo() into HU_
    r_use( dir_server() + "human_",, "HUMAN_" )
    r_use( dir_server() + "human",, "HUMAN" )
    Set Relation To RecNo() into HUMAN_, To kod_k into KART_
    r_use( dir_server() + "schet_",, "SCHET_" )
    Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" ) new
    f_error_dvn( 1 )
    ii := 0
    Go Top
    Do While !Eof()
      @ MaxRow(), 0 Say Str( ++ii / tmp->( LastRec() ) * 100, 6, 2 ) + "%" Color cColorWait
      If !Empty( tmp->kod4h ) // ��ᯠ��ਧ��� 1 ࠧ � 2 ����
        human->( dbGoto( tmp->kod4h ) )
        mdvozrast := Year( human->n_data ) - Year( human->date_r )
        g1 := ret_gruppa_dvn( human_->RSLT_NEW )
      /*if between(g1, 1, 4)
        arr_21[31] ++
        if human->pol == "�"
          arr_21[32] ++
        else
          arr_21[33] ++
        endif
        if human->pol == "�" .and. human->k_data < 0d20190501 .and. ascan(arr2g_vozrast_DVN,mdvozrast) > 0
          arr_21[34] ++
        else
          arr_21[35] ++
        endif
      endif*/
      Elseif emptyall( tmp->kod1h, tmp->kod2h ) // ��䨫��⨪�
        human->( dbGoto( tmp->kod3h ) )
        mdvozrast := Year( human->n_data ) - Year( human->date_r )
        g1 := 0
        If Between( human_->RSLT_NEW, 343, 345 )
          g1 := human_->RSLT_NEW - 342
        Elseif Between( human_->RSLT_NEW, 373, 374 )
          g1 := human_->RSLT_NEW - 370
        Endif
        If Between( g1, 1, 4 )
          arr_21[ 14 ] ++
          If f_is_selo( kart_->gorod_selo, kart_->okatog )
            arr_21[ 15 ] ++
          Endif
          If g1 == 3
            arr_21[ 41 ] ++
          Elseif g1 == 4
            arr_21[ 42 ] ++
          Endif
          If g1 == 4 ; g1 := 3 ; Endif // �⮣� III ��㯯�
          arr_21[ 15 + g1 ]++   // ���ᬮ��� �� ��㯯�� ���஢��
          If f_starshe_trudosp( human->POL, human->DATE_R, human->n_data )
            arr_21[ 40 ] ++
          Endif
          f2_f21_inf_dvn( 2 )
        Endif
      Else
        f1_f21_inf_dvn()
      Endif
      f_error_dvn( 2 )
      Select TMP
      Skip
    Enddo
    Close databases
    // �஢�ਬ ���饭�� 2 ���� �����
    mywait( "�஢�ઠ �� ���饭�� ��०����� � ������訥 2 ����" )
    r_use( dir_server() + "human",, "HUMAN" )
    Index On Str( KOD_k, 7 ) + DToS( n_data ) to ( cur_dir() + "tmp_2year" ) For n_data > ( Date() -800 )
    Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" ) new
    ii := 0
    Go Top
    Do While !Eof()
      @ MaxRow(), 0 Say Str( ++ii / tmp->( LastRec() ) * 100, 6, 2 ) + "%" Color cColorWait
      If !Empty( tmp->kod4h ) // ��ᯠ��ਧ��� 1 ࠧ � 2 ����
        //
      Elseif emptyall( tmp->kod1h, tmp->kod2h ) // ��䨫��⨪�
        Select human
        human->( dbGoto( tmp->kod3h ) )
        t_kod_k :=  human->kod_k
        t_date  :=  human->n_data
        Skip -1
        If human->kod_k == t_kod_k
          If ( ( t_date - human->n_data ) > 730 )
            kol_2_year_prof++
            If ( mvozrast := count_years( human->date_r, human->n_data ) > 39 ) .and. ( mvozrast := count_years( human->date_r, human->n_data ) < 66 )
              kol_2_year_prof_40++
            Endif
          Endif
        Else
          kol_2_year_prof++
          If ( mvozrast := count_years( human->date_r, human->n_data ) > 39 ) .and. ( mvozrast := count_years( human->date_r, human->n_data ) < 66 )
            kol_2_year_prof_40++
          Endif
        Endif
      Else// ��ᯠ��ਧ���
        If ( tmp->kod1h > 0 )
          Select human
          human->( dbGoto( tmp->kod1h ) )
          t_kod_k :=  human->kod_k
          t_date  :=  human->n_data
          Skip -1
          If human->kod_k == t_kod_k
            If ( ( t_date - human->n_data ) > 730 )
              kol_2_year_dvn++
              If ( mvozrast := count_years( human->date_r, human->n_data ) > 39 ) .and. ( mvozrast := count_years( human->date_r, human->n_data ) < 66 )
                kol_2_year_dvn_40++
              Endif
            Endif
          Else
            kol_2_year_dvn++
            If ( mvozrast := count_years( human->date_r, human->n_data ) > 39 )  .and. ( mvozrast := count_years( human->date_r, human->n_data ) < 66 )
              kol_2_year_dvn_40++
            Endif
          Endif
        Endif
      Endif
      Select TMP
      Skip
    Enddo
    Close databases
    dbCreate( cur_dir() + "tmp3", { { "et2", "N", 1, 0 }, ;
      { "gr1", "N", 1, 0 }, ;
      { "gr2", "N", 1, 0 }, ;
      { "kol1", "N", 6, 0 }, ;
      { "kol2", "N", 6, 0 } } )
    Use ( cur_dir() + "tmp3" ) new
    Index On Str( et2, 1 ) + Str( gr1, 1 ) + Str( gr2, 1 ) to ( cur_dir() + "tmp3" )
    r_use( dir_server() + "kartotek",, "KART" )
    Use ( cur_dir() + "tmp2" ) new
    Go Top
    Do While !Eof()
      fl := .f.
      g1 := ret_gruppa_dvn( tmp2->rslt1, @fl )
      If Between( g1, 0, 4 )
        k := iif( fl, 1, 0 )
        g2 := ret_gruppa_dvn( tmp2->rslt2 )
        If !Between( g2, 1, 4 )
          g2 := 0
        Endif
        Select TMP3
        find ( Str( k, 1 ) + Str( g1, 1 ) + Str( g2, 1 ) )
        If !Found()
          Append Blank
          tmp3->et2 := k
          tmp3->gr1 := g1
          tmp3->gr2 := g2
        Endif
        tmp3->kol1++
        If g2 > 0
          tmp3->kol2++
        Endif
      Endif
      If tmp2->rslt1 == 316 .and. Empty( tmp2->rslt2 )
        kart->( dbGoto( tmp2->kod_k ) )
        AAdd( arr_316, AllTrim( kart->fio ) + " �.�." + full_date( kart->date_r ) )
      Endif
      If tmp2->rslt1 == 0 .and. !Empty( tmp2->rslt2 )
        kart->( dbGoto( tmp2->kod_k ) )
        AAdd( arr_ne, AllTrim( kart->fio ) + " �.�." + full_date( kart->date_r ) )
      Endif
      Select TMP2
      Skip
    Enddo
    Close databases
    //
    at := { glob_mo[ _MO_SHORT_NAME ], "[ " + CharRem( "~", mas1pmt[ par ] ) + " �� ���⮬ �⪠��� � ����� ]", arr_m[ 4 ] }
    print_shablon( "svod_dvn", { arr_21, at, ar }, "tmp1.txt", .f. )
    fp := FCreate( "tmp2.txt" ) ; n_list := 1 ; tek_stroke := 0
    fl := f_error_dvn( 3, 60, 80 )
    StrFile( "��� ��襤訥 ��ᯠ��ਧ���/���ᬮ��, ࠭�� �� ���頢訥 ��०����� ����� 2-� ���" + hb_eol(), "tmp1.txt", .t. )
    StrFile( " ��ᯠ��ਧ��� == " + lstr( kol_2_year_dvn ) + " 祫. �� ��� 40-65 ��� == " +  lstr( kol_2_year_dvn_40 )  + " 祫."  + hb_eol(), "tmp1.txt", .t. )
    StrFile( " ���ᬮ��      == " + lstr( kol_2_year_prof ) + " 祫. �� ��� 40-65 ��� == " +  lstr( kol_2_year_prof_40 )  + " 祫."  +  + hb_eol(), "tmp1.txt", .t. )
    FClose( fp )
    If fl
      StrFile( "FF", "tmp1.txt", .t. )
      feval( "tmp2.txt", {| s| StrFile( s + hb_eol(), "tmp1.txt", .t. ) } )
    Endif
    viewtext( "tmp1.txt",,,,,,, 3 )
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 08.07.24
Function inf_ydvn()

  Local i, ii, s, arr_m, buf := save_maxrow(), ar, arr_excel := {}, is_all
  Local sh, HH := 53,  n_file := cur_dir() + "gor_YDVN.txt", reg_print, arr_itog[ 20 ]
  Local t_rec, t_poisk, t_rezult, is_pesia
/*local arr_title := {;
"��������������������������������������������������������������������������������������������������������������������������������������", ;
"��諨� � ⮬ �   �    �   �   ���諨 ���      �      �      �      �      ����ࠢ-���諨�      �      �      �      �      ������", ;
"1 �⠯� �᫥ ����୥���㡡���  ����   �   I  �  II  �  III � IIIa � IIIb ����� ���2 �⠯�   I  �  II  �  III � IIIa � IIIb �  ����", ;
"      � ᥫ�  � �६�  �       �  ����   ���㯯����㯯����㯯����㯯����㯯�� 2 �⠯�      ���㯯����㯯����㯯����㯯����㯯�� � ���", ;
"��������������������������������������������������������������������������������������������������������������������������������������", ;
"   2  �  2.1  �   3    �   4   �    5    �   6  �   7  �   8  �   9  �  10  �   11  �  12  �  13  �  14  �  15  �  16  �  17  �   18  ", ;
"��������������������������������������������������������������������������������������������������������������������������������������"}*/
/*local arr_title := {;
"����������������������������������������������������������������������������������������������������������������������������������������������", ;
"��諨� ���襳 � ⮬ �   �    �   �   ���諨 ���      �      �      �      �      ����ࠢ-���諨�      �      �      �      �      ������", ;
"1 �⠯���㤮᯳ �᫥ ����୥���㡡���  ����   �   I  �  II  �  III � IIIa � IIIb ����� ���2 �⠯�   I  �  II  �  III � IIIa � IIIb �  ����", ;
"      � ����. � ᥫ�  � �६�  �       �  ����   ���㯯����㯯����㯯����㯯����㯯�� 2 �⠯�      ���㯯����㯯����㯯����㯯����㯯�� � ���", ;
"����������������������������������������������������������������������������������������������������������������������������������������������", ;
"   2  �  2.1  �  2.2  �   3    �   4   �    5    �   6  �   7  �   8  �   9  �  10  �   11  �  12  �  13  �  14  �  15  �  16  �  17  �   18  ", ;
"����������������������������������������������������������������������������������������������������������������������������������������������"}
*/
  Local arr_title := { ;
    "����������������������������������������������������������������������������������������������������������������������������������������������", ;
    "    ��諨 1-� �⠯   �                     �� ���� 2                              �       �      �              �� ���� 2.1        �       ", ;
    "�������������������������������������������������������������������������������������       �      ������������������������������������       ", ;
    "��諨� ���襳 � ⮬ �   �    �   �   ���諨 ���      �      �      �      �      ����ࠢ-���諨�      �      �      �      �      ������", ;
    "1 �⠯���㤮᯳ �᫥ ����୥���㡡���  ����   �   I  �  II  �  III � IIIa � IIIb ����� ���2 �⠯�   I  �  II  �  III � IIIa � IIIb �  ����", ;
    "      � ����. � ᥫ�  � �६�  �       �  ����   ���㯯����㯯����㯯����㯯����㯯�� 2 �⠯�      ���㯯����㯯����㯯����㯯����㯯�� � ���", ;
    "����������������������������������������������������������������������������������������������������������������������������������������������", ;
    "   2  �  2.1  �       �   3    �   4   �    5    �   6  �   7  �   8  �   9  �  10  �   11  �  12  �  13  �  14  �  15  �  16  �  17  �   18  ", ;
    "����������������������������������������������������������������������������������������������������������������������������������������������" }

  Local title_zagol := { ;
    "��� �ࠦ����", ;
    "� ����ࡨ��� 䮭�� (����稥 ���� � ����� �஭��᪨� ����䥪樮���� ����������� - 1 ��㯯�", ;
    "�� ����� 祬 � ����� ᮯ������騬 �஭��᪨� ����䥪樮��� ������������ - 2 ��㯯�", ;
    "�⮣�" }
  Local mas_n_otchet[ 15 ]
  Private  pole_pervich, pole_1pervich, pole_dispans, pole_1dispans

  AFill( mas_n_otchet, 0 )
  r_use( dir_server() + "kartote_",, "KART_" )
  r_use( dir_server() + "kartotek",, "KART" )

  For i := 1 To 5
    sk := lstr( i )
    // pole_pervich := "mpervich"+sk
    pole_1pervich := "m1pervich" + sk
    // pole_dispans := "mdispans"+sk
    pole_1dispans := "m1dispans" + sk
    // Private &pole_pervich := space(7)
    Private &pole_1pervich := 0
    // Private &pole_dispans := space(10)
    Private &pole_1dispans := 0
  Next

  If ( st_a_uch := inputn_uch( T_ROW, T_COL -5,,, @lcount_uch ) ) != NIL ;
      .and. ( arr_m := year_month(,,, 5 ) ) != NIL
    mywait()
    dbCreate( cur_dir() + "tmp", { { "gruppa_1", "N", 1, 0 }, ;// 1-��㯯� 2- ��㯯� 3 - ��� ��㯯�
    { "etap_1", "N", 1, 0 }, ;  // �⠯ 1-� 2-�
    { "sub_day", "N", 1, 0 }, ; // �믮������ � �㡡��� 0-��� 1-��
    { "one_day", "N", 1, 0 }, ; // �믮������ � 1 ���� 0-��� 1-��
    { "gruppa", "N", 3, 0 }, ;  // ��㯯� ���஢�� 1, 2.3a, 3b
    { "napr2", "N", 1, 0 }, ;   // ���ࠢ��� �� 2-� �⠯ 0-��� 1-��
    { "selo", "N", 1, 0 }, ;    // ���� 0-��� 1-��
      { "pensia", "N", 1, 0 }, ;  // ����� 0-��� 1-�� _pol=="�", 62, 57 �� ������ �� 2022 ��� - ⠪ � ⠡���
    { "d_one", "N", 1, 0 }, ;   // ����� ���� �� �-��� 0-��� 1-��
    { "kod_k", "N", 7, 0 } } )
    r_use( dir_server() + "human_",, "HUMAN_" )
    r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
    Set Relation To RecNo() into HUMAN_
    Use ( cur_dir() + "tmp" ) new
    //
    Select HUMAN
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
      // If Between( human->ishod, 401, 402 )
      If is_sluch_dispanser_covid( human->ishod )
        // read_arr_DVN_COVID(human->kod)
        // is_selo := f_is_selo(kart_->gorod_selo,kart_->okatog)  // �ਧ��� ᥫ�
        Select KART_
        Goto ( HUMAN->kod_k )
        Select KART
        Goto ( HUMAN->kod_k )
        Select HUMAN
        is_selo := f_is_selo( kart_->gorod_selo, kart_->okatog )  // �ਧ��� ᥫ�
        is_pensia := f_starshe_trudosp( kart->pol, kart->date_r, human->n_data, 3 ) // �ਧ��� ���ᨮ��஢
        Select TMP
        Append Blank
        tmp->kod_k := HUMAN->kod_k
        If is_selo
          tmp->selo := 1
        Endif
        If is_pensia
          tmp->pensia := 1
        Endif
        If DoW( human->n_data ) == 7
          tmp->sub_day := 1
        Else
          tmp->sub_day := 0
        Endif
        If human->k_data == human->n_data
          tmp->one_day := 1
        Else
          tmp->one_day := 0
        Endif
        If human->ishod == 401
          tmp->etap_1 := 1
        Else
          tmp->etap_1 := 2
        Endif
        // �롨ࠥ� ��㣨
        // larr := array(2, len(uslugiEtap_DVN_COVID(metap)))
        // arr_usl := {} // array(len(uslugiEtap_DVN_COVID(metap)))
        //
        arr := read_arr_dispans( human->kod )
        //
        For i := 1 To Len( arr )
          If ValType( arr[ i ] ) == "A" .and. ValType( arr[ i, 1 ] ) == "C"
            Do Case
            Case arr[ i, 1 ] == "5" .and. ValType( arr[ i, 2 ] ) == "N"
              tmp->gruppa_1 := arr[ i, 2 ]
            Case eq_any( arr[ i, 1 ], "11", "12", "13", "14" )
              sk := Right( arr[ i, 1 ], 1 )
              pole_1pervich := "m1pervich" + sk
              pole_1dispans := "m1dispans" + sk
              If ValType( arr[ i, 2, 4 ] ) == "N"
                &pole_1dispans := arr[ i, 2, 4 ]
              Endif
              If ValType( arr[ i, 2, 2 ] ) == "N"
                &pole_1pervich := arr[ i, 2, 2 ]
              Endif
              if &pole_1dispans == 1 .and. &pole_1pervich == 1
                tmp->d_one := 1
              Endif
            Case arr[ i, 1 ] == "40"
              tmp_mas := arr[ i, 2 ]
              fl_t := .f.
              fl_t1 := .f.
              For jj := 1 To Len( tmp_mas )
                If AllTrim( tmp_mas[ jj ] )     == "70.8.2"     // 70- �஢������ ��� � 6 ����⭮� 室졮�
                  fl_t := .t.
                  mas_n_otchet[ 3 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == "A12.09.001" // 71- "�஢������ ᯨ஬��ਨ ��� ᯨண�䨨"
                  fl_t := .t.
                  mas_n_otchet[ 4 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == "A12.09.005" // "69- ���ᮮ�ᨬ����"
                  fl_t := .t.
                  mas_n_otchet[ 2 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == "A06.09.007" // 72- ���⣥������ ������
                  fl_t := .t.
                  mas_n_otchet[ 5 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == "B03.016.003"// 73- "��騩 (������᪨�) ������ �஢� ࠧ������"
                  fl_t := .t.
                  mas_n_otchet[ 6 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == "B03.016.004"// 74- ������ �஢� ���娬��᪨� ����࠯����᪨�
                  fl_t := .t.
                  mas_n_otchet[ 7 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == "70.8.3"     // 75 "��।������ ���業��樨 �-����� � �஢�"
                  fl_t := .t.
                  mas_n_otchet[ 8 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == "70.8.52"    // 2 - 78 �㯫��᭮� ᪠���-�� ��� ������ ����筮�⥩
                  fl_t1 := .t.
                  mas_n_otchet[ 10 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == "70.8.51"    // 2 - 79 �஢������ �� ������
                  fl_t1 := .t. // mas_n_otchet[9] ++
                  mas_n_otchet[ 11 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == "70.8.50"    // 2 - 80 �஢������ �宪�न���䨨
                  fl_t1 := .t.
                  mas_n_otchet[ 12 ] ++
                Endif
              Next
              If fl_t
                mas_n_otchet[ 1 ] ++
              Endif
              If fl_t1
                mas_n_otchet[ 9 ] ++
              Endif
            Case arr[ i, 1 ] == "56"  // ॠ�������
              If ValType( arr[ i, 2 ] ) == "N"
                // mas_n_otchet[14] ++
              Elseif ValType( arr[ i, 2 ] ) == "A"
                If arr[ i, 2 ][ 2 ] > 0
                  mas_n_otchet[ 14 ] ++
                Endif
              Endif
            Endcase
          Endif
        Next
        //
        If human_->RSLT_NEW == 317
          tmp->gruppa := 1
          tmp->napr2  := 0
        Elseif human_->RSLT_NEW == 318
          tmp->gruppa := 2
          tmp->napr2  := 0
        Elseif human_->RSLT_NEW == 355
          tmp->gruppa := 3
          tmp->napr2  := 0
        Elseif human_->RSLT_NEW == 356
          tmp->gruppa := 4
          tmp->napr2  := 0
        Elseif human_->RSLT_NEW == 352
          tmp->gruppa := 1
          tmp->napr2  := 1
        Elseif human_->RSLT_NEW == 353
          tmp->gruppa := 2
          tmp->napr2  := 1
        Elseif human_->RSLT_NEW == 357
          tmp->gruppa := 3
          tmp->napr2  := 1
        Else // if human_->RSLT_NEW == 358
          tmp->gruppa := 4
          tmp->napr2  := 1
        Endif
      Endif
      Select HUMAN
      Skip
    Enddo
    Select TMP
    Index On Str( kod_k, 7 ) + Str( etap_1, 1 )  To tmp_kk
    //
    Go Top
    Do While !Eof()
      If etap_1 == 2
        t_rec := tmp->( RecNo() )
        t_poisk := Str( tmp->kod_k, 7 ) + Str( 1, 1 )
        t_rezult := 0 // �� 㬮�砭�� ����
        find( t_poisk )
        If Found()
          t_rezult := tmp->gruppa_1
        Endif
        Goto t_rec
        g_rlock( forever )
        tmp->gruppa_1  := t_rezult
        Unlock
      Endif
      Select TMP
      Skip
    Enddo
    // ᮧ���� ����
    reg_print := f_reg_print( arr_title, @sh, 2 )
    fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
    // add_string("")
    //
    For II := 0 To 3
      AFill( arr_itog, 0 )
      Select TMP
      Go Top
      Do While !Eof()
        If iif( II == 3, .t., tmp->Gruppa_1 == II )
          If tmp->etap_1 == 1
            arr_itog[ 2 ] ++
            If tmp->sub_day == 1
              arr_itog[ 4 ] ++
            Endif
            If tmp->one_day == 1
              arr_itog[ 5 ] ++
            Endif
            If tmp->gruppa == 1
              arr_itog[ 6 ] ++
            Endif
            If tmp->gruppa == 2
              arr_itog[ 7 ] ++
            Endif
            If tmp->gruppa == 3
              arr_itog[ 8 ] ++
              arr_itog[ 9 ] ++
            Endif
            If tmp->gruppa == 4
              arr_itog[ 8 ] ++
              arr_itog[ 10 ] ++
            Endif
            If tmp->napr2 == 1
              arr_itog[ 11 ] ++
            Endif
            // ��ࠡ�⪠ 28.09.2023
            If tmp->gruppa == 1 .and. tmp->pensia == 1
              arr_itog[ 13 ] ++
            Endif
            If tmp->gruppa == 2  .and. tmp->pensia == 1
              arr_itog[ 14 ] ++
            Endif
            If tmp->gruppa == 3 .and. tmp->pensia == 1
              arr_itog[ 15 ] ++
              arr_itog[ 16 ] ++
            Endif
            If tmp->gruppa == 4 .and. tmp->pensia == 1
              arr_itog[ 15 ] ++
              arr_itog[ 17 ] ++
            Endif
          Else
            arr_itog[ 12 ] ++
         /* if tmp->gruppa == 1
            arr_itog[13] ++
          endif
          if tmp->gruppa == 2
            arr_itog[14] ++
          endif
          if tmp->gruppa == 3
            arr_itog[15] ++
            arr_itog[16] ++
          endif
          if tmp->gruppa == 4
            arr_itog[15] ++
            arr_itog[17] ++
          endif
          */
          Endif
          If tmp->d_one == 1
            arr_itog[ 18 ] ++
          Endif
          If tmp->selo == 1
            arr_itog[ 19 ]++
          Endif
          If tmp->pensia == 1
            arr_itog[ 20 ]++
          Endif
        Endif
        Skip
      Enddo
      // �뢮���
      add_string( Center( "���, ��७��訥 COVID-19", sh ) )
      If II == 3
        add_string( Center( "�����", sh ) )
      Else
        add_string( Center( title_zagol[ II + 1 ], sh ) )
      Endif
      add_string( Center( arr_m[ 4 ], sh ) )
      // add_string("")
      AEval( arr_title, {| x| add_string( x ) } )
      add_string( PadL( lstr( arr_itog[ 2 ] ), 6 ) + ;
        PadL( lstr( arr_itog[ 20 ] ), 8 ) + ;
        PadL( lstr( arr_itog[ 19 ] ), 8 ) + ;
        PadL( "", 8 ) + ;
        PadL( lstr( arr_itog[ 4 ] ), 9 ) + ;
        PadL( lstr( arr_itog[ 5 ] ), 10 ) + ;
        PadL( lstr( arr_itog[ 6 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 7 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 8 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 9 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 10 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 11 ] ), 8 ) + ;
        PadL( lstr( arr_itog[ 12 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 13 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 14 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 15 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 16 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 17 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 18 ] ), 8 ) )
      // add_string("")
      add_string( "" )
    Next
    If verify_ff( HH, .t., sh )
      // aeval(arr_title, {|x| add_string(x) } )
    Endif
    // endif
    add_string( "���� ��� � �⪫�����ﬨ  �� ����, �����묨 � �ࠦ���, ��७��� ����� ��஭�������� ��䥪��" )
    add_string( "COVID-19 �� १���⠬ I �⠯� 㣫㡫����� ��ᯠ��ਧ�樨 (���� �� ������⢠ �ࠦ���, �����訢��" )
    add_string( " I �⠯ 㣫㡫����� ��ᯠ��ਧ�樨 � ��襤�� �����⭮� ��᫥�������, %)" )
    add_string( "" )
    add_string( "68- �ᥣ� ��� � �⪮����ﬨ I �⠯              = " + PadL( lstr( mas_n_otchet[ 1 ] ), 9 ) + " 祫." )
    add_string( "69- �������                                   = " + PadL( lstr( mas_n_otchet[ 2 ] ), 9 ) + " 祫." )
    add_string( "70- ���� � 6 ����⭮� 室졮�                   = " + PadL( lstr( mas_n_otchet[ 3 ] ), 9 ) + " 祫." )
    add_string( "71- ���஬����                                 = " + PadL( lstr( mas_n_otchet[ 4 ] ), 9 ) + " 祫." )
    add_string( "72- ���⣥������ ������                       = " + PadL( lstr( mas_n_otchet[ 5 ] ), 9 ) + " 祫." )
    add_string( "73- ��騩 ������ �஢�                          = " + PadL( lstr( mas_n_otchet[ 6 ] ), 9 ) + " 祫." )
    add_string( "74- ���娬��᪨� ������ �஢�                  = " + PadL( lstr( mas_n_otchet[ 7 ] ), 9 ) + " 祫." )
    add_string( "75- ��।������ ���業��樨 �-����� � �஢�   = " + PadL( lstr( mas_n_otchet[ 8 ] ), 9 ) + " 祫." )
    add_string( "" )
    add_string( "���� ��� � �⪫�����ﬨ  �� ����, �����묨 � �ࠦ���, ��७��� ����� ��஭�������� ��䥪�� " )
    add_string( "COVID-19 �� १���⠬ II �⠯� 㣫㡫����� ��ᯠ��ਧ�樨 (���� �� ������⢠ �ࠦ���, �����訢�� " )
    add_string( " II �⠯ 㣫㡫����� ��ᯠ��ਧ�樨 � ��襤�� �����⭮� ��᫥�������, %)" )
    add_string( "" )
    add_string( "77- �ᥣ� ��� � �⪮����ﬨ II �⠯             = " + PadL( lstr( mas_n_otchet[ 9 ] ), 9 ) + " 祫." )
    add_string( "78- �㯫��᭮� ᪠���-�� ��� ������ ����筮�⥩ = " + PadL( lstr( mas_n_otchet[ 10 ] ), 9 ) + " 祫." )
    add_string( "79- �஢������ �� ������                        = " + PadL( lstr( mas_n_otchet[ 11 ] ), 9 ) + " 祫." )
    add_string( "80- �஢������ �宪�न���䨨                  = " + PadL( lstr( mas_n_otchet[ 12 ] ), 9 ) + " 祫." )
    add_string( "" )
    add_string( "��᫮ �ࠦ���, ������ �� ��ᯠ��୮� ������� � ���ࠢ������ �� ॠ������� ��" )
    add_string( "१���⠬ 㣫㡫����� ��ᯠ��ਧ�樨  (���.�.)" )
    add_string( "" )
    add_string( "83- �ᥣ� �������� ��ᯠ��୮�� �������     = " + PadL( lstr( arr_itog[ 18 ] ), 9 ) + " 祫." )
    add_string( "85- ���ࠢ��� �� ॠ�������                   = " + PadL( lstr( mas_n_otchet[ 14 ] ), 9 ) + " 祫." )
    Close databases
    FClose( fp )
    Private yes_albom := .t.
    viewtext( n_file,,,, ( sh > 80 ),,, reg_print )
  Endif
  rest_box( buf )
  Close databases

  Return Nil


// 27.04.20
Function f1_f21_inf_dvn()

  Local sumr := 0, m1GRUPPA, fl2 := .f., is_selo

  Select TMP2
  Append Blank
  tmp2->kod_k := tmp->kod_k
  // ��ᯠ��ਧ��� I �⠯
  If Empty( tmp->kod1h )
    // ��� 1 �⠯�, �� ���� ��ன
  Else
    human->( dbGoto( tmp->kod1h ) )
    mdvozrast := Year( human->n_data ) - Year( human->date_r )
    m1GRUPPA := ret_gruppa_dvn( human_->RSLT_NEW, @fl2 )
    If Between( m1gruppa, 0, 4 )
      tmp2->rslt1 := human_->RSLT_NEW
      If m1gruppa == 0
        fl2 := .t. // ���ࠢ��� �� 2 �⠯
      Endif
      Private m1veteran := 0, m1mobilbr := 0
      read_arr_dvn( human->kod, .f. )
      arr_21[ 3 ] ++
      If m1veteran == 1
        arr_21[ 4 ] ++
      Endif
      If m1mobilbr == 1
        arr_21[ 5 ] ++
      Endif
      If mdvozrast == 65
        arr_21[ 32 ] ++
      Elseif mdvozrast > 65
        arr_21[ 33 ] ++
      Endif
      If Between( m1gruppa, 1, 4 )
        arr_21[ 5 + m1gruppa ] ++
      Endif
      If ( is_selo := f_is_selo( kart_->gorod_selo, kart_->okatog ) )
        arr_21[ 47 ] ++
      Endif
      If f_starshe_trudosp( human->POL, human->DATE_R, human->n_data )
        arr_21[ 19 ] ++
        If is_selo
          arr_21[ 20 ] ++
        Endif
        If Between( m1gruppa, 1, 4 )
          arr_21[ 42 + m1gruppa ] ++
        Endif
      Endif
      f2_f21_inf_dvn( 1 )
      If human->schet > 0
        Select SCHET_
        Goto ( human->schet )
        If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // ⮫쪮 ��ॣ����஢����
          arr_21[ 10 ] ++
          Select RPDSH
          find ( Str( human->kod, 7 ) )
          Do While rpdsh->KOD_H == human->kod .and. !Eof()
            sumr += rpdsh->S_SL
            Skip
          Enddo
          If Round( human->cena_1, 2 ) == Round( sumr, 2 ) // ��������� ����祭
            arr_21[ 11 ] ++
          Endif
        Endif
      Endif
    Else
      // ��祬�-� ���ࠢ��쭠� ��㯯�
    Endif
  Endif
  If fl2 // ���ࠢ��� �� 2 �⠯
    arr_21[ 12 ]++    // ���ࠢ��� �� 2 �⠯
  Endif
  If !Empty( tmp->kod2h ) // ��ᯠ��ਧ��� II �⠯
    human->( dbGoto( tmp->kod2h ) )
    m1GRUPPA := ret_gruppa_dvn( human_->RSLT_NEW )
    If Between( m1gruppa, 1, 4 )
      tmp2->rslt2 := human_->RSLT_NEW
      If Empty( tmp2->rslt1 )
      Else
        arr_21[ 13 ] ++
        If !fl2  // �� �� ���ࠢ���, �� ��� ࠢ�� ����
          arr_21[ 12 ]++    // ���ࠢ��� �� 2 �⠯
        Endif
      Endif
    Else
      // ��祬�-� ���ࠢ��쭠� ��㯯�
    Endif
  Endif

  Return Nil

// 07.04.22
Function f2_f21_inf_dvn( par )

  Local is_selo, i, j, k, k1 := 9, fl2 := .f., ar[ 21 ], arr11[ 15 ], arr12[ 43 ], au := {}, fl_pens
  Private arr_otklon := {}, arr_usl_otkaz := {}, ;
    M1RAB_NERAB := human->RAB_NERAB, m1veteran := 0, m1mobilbr := 0, ;
    m1kurenie := 0, mad1 := 120, mad2 := 80, m1tip_mas := 0, mssr := 0, ;
    m1holestdn := 0, m1glukozadn := 0, m1fiz_akt := 0, m1ner_pit := 0, ;
    mholest := 0, mglukoza := 0, ;
    m1riskalk := 0, m1pod_alk := 0, m1psih_na := 0, ;
    m1ot_nasl1 := 0, m1ot_nasl2 := 0, m1ot_nasl3 := 0, m1ot_nasl4 := 0, ;
    m1dispans := 0, m1nazn_l  := 0, m1dopo_na := 0, m1ssh_na  := 0, ;
    m1spec_na := 0, m1sank_na := 0, ;
    pole_diag, pole_1pervich, pole_1stadia, pole_1dispans, ;
    mWEIGHT := 0, mHEIGHT := 0

  AFill( ar, 0 ) ; ar[ 2 ] := 1
  AFill( arr11, 0 )
  AFill( arr12, 0 )
  If kart_->invalid > 0
    arr_21[ 21 ] ++
  Endif
  If par == 1
    If mdvozrast < 35
      k1 := 1
    Elseif mdvozrast < 40
      k1 := 2
    Elseif mdvozrast < 55
      k1 := 3
    Elseif mdvozrast < 60
      k1 := 4
    Elseif mdvozrast < 65
      k1 := 5
    Elseif mdvozrast < 75
      k1 := 6
    Else
      k1 := 7
    Endif
    // g5
  Endif
  If human->n_data == human->k_data // �� ���� ����
    ar[ 5 ] := 1
  Endif
  If ( is_selo := f_is_selo( kart_->gorod_selo, kart_->okatog ) )
    ar[ 6 ] := 1
  Endif
  If DoW( human->k_data ) == 7 // �㡡��
    ar[ 4 ] := 1
    If is_selo
      ar[ 8 ] := 1
    Endif
  Endif
  fl_pens := f_starshe_trudosp( human->POL, human->DATE_R, human->n_data )
  For i := 1 To 5
    pole_diag := "mdiag" + lstr( i )
    pole_1pervich := "m1pervich" + lstr( i )
    pole_1stadia := "m1stadia" + lstr( i )
    pole_1dispans := "m1dispans" + lstr( i )
    Private &pole_diag := Space( 6 )
    Private &pole_1pervich := 0
    Private &pole_1stadia := 0
    Private &pole_1dispans := 0
  Next
  read_arr_dvn( human->kod )
  m1GRUPPA := ret_gruppa_dvn( human_->RSLT_NEW, @fl2 )
  If Between( m1gruppa, 0, 4 )
    If m1gruppa == 0
      fl2 := .t. // ���ࠢ��� �� 2 �⠯
    Endif
  Endif
  If !Empty( tmp->kod2h )
    fl2 := .t. // ��襫 2 �⠯
  Endif
  Select HU
  find ( Str( tmp->kod1h, 7 ) )
  Do While hu->kod == tmp->kod1h .and. !Eof()
    usl->( dbGoto( hu->u_kod ) )
    If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
      lshifr := usl->shifr
    Endif
    AAdd( au, { AllTrim( lshifr ), ;
      hu_->PROFIL, ;
      0, ;
      c4tod( hu->date_u );
      } )
    Select HU
    Skip
  Enddo
  For k := 1 To Len( au )
    If AScan( arr_otklon, au[ k, 1 ] ) > 0
      au[ k, 3 ] := 1 // �⪫������ � ��᫥�������
    Endif
    If au[ k, 1 ] == "7.57.3"
      arr12[ 1 ] := arr12[ 2 ] := 1
      arr12[ 3 ] := au[ k, 3 ]
      If fl2 .and. au[ k, 3 ] == 1
        arr12[ 4 ] := 1
      Endif
    Elseif au[ k, 1 ] == "4.8.4"
      arr12[ 12 ] := arr12[ 13 ] := 1
      arr12[ 14 ] := au[ k, 3 ]
      If fl2 .and. au[ k, 3 ] == 1
        arr12[ 15 ] := 1
      Endif
    Elseif eq_any( au[ k, 1 ], "4.20.1", "4.20.2" )
      arr12[ 25 ] := arr12[ 26 ] := 1
      arr12[ 27 ] := au[ k, 3 ]
      If fl2 .and. au[ k, 3 ] == 1
        arr12[ 28 ] := 1
      Endif
      // elseif eq_any(au[k, 1],"56.1.15","56.1.20","56.1.21","56.1.721")
      // arr11[10] := arr11[11] := 1
      // elseif au[k, 1] == "56.1.723"
      // arr11[13] := arr11[14] := 1
    Endif
  Next
  // ��ᯠ��ਧ��� II �⠯
  If !Empty( tmp->kod2h )
    human->( dbGoto( tmp->kod2h ) )
    m1GRUPPA2 := ret_gruppa_dvn( human_->RSLT_NEW )
    If Between( m1gruppa2, 1, 4 ) // �筮 ���� 2 �⠯
      read_arr_dvn( human->kod ) // ������� �������� � �.�.
    Endif
    au := {}
    Select HU
    find ( Str( tmp->kod1h, 7 ) )
    Do While hu->kod == tmp->kod1h .and. !Eof()
      usl->( dbGoto( hu->u_kod ) )
      If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
        lshifr := usl->shifr
      Endif
      AAdd( au, { AllTrim( lshifr ), ;
        hu_->PROFIL, ;
        0, ;
        c4tod( hu->date_u );
        } )
      Select HU
      Skip
    Enddo
    For k := 1 To Len( au )
      If AScan( arr_otklon, au[ k, 1 ] ) > 0
        au[ k, 3 ] := 1 // �⪫������ � ��᫥�������
      Endif
      If eq_any( au[ k, 1 ], "10.6.10", "10.6.710" )
        arr12[ 16 ] := 1
      Elseif eq_any( au[ k, 1 ], "10.4.1", "10.4.701" )
        arr12[ 17 ] := 1
      Elseif eq_any( au[ k, 1 ], "56.1.15", "56.1.20", "56.1.21", "56.1.721" )
        arr11[ 10 ] := arr11[ 11 ] := 1
      Elseif au[ k, 1 ] == "56.1.723"
        arr11[ 13 ] := arr11[ 14 ] := 1
      Endif
    Next
  Endif
  For i := 1 To 5
    pole_diag := "mdiag" + lstr( i )
    pole_1pervich := "m1pervich" + lstr( i )
    pole_1stadia := "m1stadia" + lstr( i )
    pole_1dispans := "m1dispans" + lstr( i )
    if &pole_1pervich == 1 .and. &pole_1dispans == 1
      arr11[ 1 ] := 1
    Endif
    If !( Left( &pole_diag, 1 ) == "A" .or. Left( &pole_diag, 1 ) == "B" ) .and. &pole_1pervich == 1 // ����䥪樮��� ����������� ���.�����
      ar[ 9 ] := 1
      ar[ 10 ] ++
      If Left( &pole_diag, 1 ) == "I" // ������� ��⥬� �஢����饭��
        ar[ 11 ] := 1
      Elseif Left( &pole_diag, 1 ) == "J" // ������� �࣠��� ��堭��
        ar[ 17 ] := 1
      Elseif Left( &pole_diag, 1 ) == "K" // ������� �࣠��� ��饢�७��
        ar[ 18 ] := 1
      Endif
      If Left( &pole_diag, 1 ) == "C" .or. Between( Left( &pole_diag, 3 ), "D00", "D09" ) // ���
        ar[ 12 ] := 1
        if &pole_1stadia < 3 // 1 � 2 �⠤��
          ar[ 13 ] := 1
        Endif
        arr11[ 5 ] := 1
        If Between( &pole_1stadia, 1, 4 )
          arr11[ 5 + &pole_1stadia ] := 1
        Endif
        If Left( &pole_diag, 3 ) == "C50"
          arr12[ 6 ] := 1
          If Between( &pole_1stadia, 1, 4 )
            arr12[ 7 + &pole_1stadia ] := 1
          Endif
        Elseif Left( &pole_diag, 3 ) == "D05"
          arr12[ 6 ] := 1
          arr12[ 7 ] := 1 // in situ
        Endif
        If eq_any( Left( &pole_diag, 3 ), "C18", "C19", "C20", "C21" )
          arr12[ 19 ] := 1
          If Between( &pole_1stadia, 1, 4 )
            arr12[ 20 + &pole_1stadia ] := 1
          Endif
        Elseif eq_any( Left( &pole_diag, 5 ), "D01.0", "D01.1", "D01.2", "D01.3" )
          arr12[ 19 ] := 1
          arr12[ 20 ] := 1 // in situ
        Endif
        If Left( &pole_diag, 3 ) == "C53"
          arr12[ 30 ] := 1
          If Between( &pole_1stadia, 1, 4 )
            arr12[ 31 + &pole_1stadia ] := 1
          Endif
        Elseif Left( &pole_diag, 3 ) == "D06"
          arr12[ 30 ] := 1
          arr12[ 31 ] := 1 // in situ
        Endif
        If eq_any( Left( &pole_diag, 3 ), "C00", "C43", "C44" ) .or. Left( &pole_diag, 5 ) == "C14.8"
          arr12[ 36 ] := 1
          arr12[ 38 ] := 1
          If Between( &pole_1stadia, 1, 4 )
            arr12[ 39 + &pole_1stadia ] := 1
          Endif
        Elseif eq_any( Left( &pole_diag, 3 ), "D03", "D04" ) .or. Left( &pole_diag, 5 ) == "D00.0"
          arr12[ 36 ] := 1
          arr12[ 38 ] := 1
          arr12[ 39 ] := 1
        Endif
      Endif
      If Between( Left( &pole_diag, 3 ), "E10", "E14" ) // ���� ������
        ar[ 14 ] := 1
        If Left( &pole_diag, 3 ) == "E10" // I �⠤��
          ar[ 15 ] := 1
        Endif
      Endif
      If eq_any( Left( &pole_diag, 3 ), "H40", "H42" ) .or. Left( &pole_diag, 5 ) == "Q15.0" // ���㪮��
        ar[ 16 ] := 1
      Endif
      if &pole_1dispans == 1
        ar[ 19 ] := 1
        If is_selo
          ar[ 21 ] := 1
        Endif
      Endif
      If .f. // 1-��祭�� �����祭�
        ar[ 20 ] := 1 // ?? �뫮 ���� ��祭��
      Endif
    Endif
  Next
  pole := "tmp1->g" + lstr( k1 )
  Select TMP1
  For i := 1 To Len( ar )
    If ar[ i ] > 0
      find ( Str( i, 2 ) )
      &pole := &pole + ar[ i ]
      If k1 < 8 .and. fl_pens
        tmp1->g8 += ar[ i ]
      Endif
    Endif
  Next
  Select TMP11
  For i := 1 To Len( arr11 )
    If arr11[ i ] > 0
      find ( Str( i, 2 ) )
      tmp11->g3 += arr11[ i ]
    Endif
  Next
  Select TMP12
  For i := 1 To Len( arr12 )
    If arr12[ i ] > 0
      find ( Str( i, 2 ) )
      tmp12->g3 += arr12[ i ]
    Endif
  Next

  Return Nil

// 20.10.16 ��������� �����ਭ�� ��ᯠ��ਧ�樨 ������
Function f22_inf_dvn()

  Static group_ini := "f22_inf_DVN"
  Static as := { ;
    { 1, 0, 0, "��饥 �᫮ �ࠦ���, ��������� ��ᯠ��ਧ�樨 � ⥪�饬 ����" }, ;
    { 2, 0, 0, "������⢮ �ࠦ��� �� �᫠ ��������� ��ᯠ��ਧ�樨 � ⥪�饬 ����, ��襤�� 1-� �⠯ ��ᯠ��ਧ�樨 �� ����� ��ਮ�" }, ;
    { 3, 0, 0, "������⢮ �ࠦ��� �� �᫠ ��������� ��ᯠ��ਧ�樨 � ⥪�饬 ����, ��襤�� 2-� �⠯ ��ᯠ��ਧ�樨 �� ����� ��ਮ�" }, ;
    { 4, 0, 0, "������⢮ �ࠦ��� �� �᫠ ��������� ��ᯠ��ਧ�樨 � ⥪�饬 ����, ��������� �����訢�� ��ᯠ��ਧ��� �� ����� ��ਮ�, �� ���:" }, ;
    { 4, 1, 0, "����� I ��㯯� ���஢��" }, ;
    { 4, 2, 0, "����� II ��㯯� ���஢��" }, ;
    { 4, 3, 0, "����� III� ��㯯� ���஢��" }, ;
    { 4, 4, 0, "����� III� ��㯯� ���஢��" }, ;
    { 5, 0, 0, "������⢮ �ࠦ��� � ����� �����묨 �஭��᪨�� ����䥪樮��묨 ����������ﬨ, �� ���:" }, ;
    { 5, 1, 0, "� �⥭���न��" }, ;
    { 5, 2, 0, "� �஭��᪮� �襬��᪮� �������� ���" }, ;
    { 5, 3, 0, "� ���ਠ�쭮� �����⮭���" }, ;
    { 5, 4, 0, "� �⥭���� ᮭ��� ���਩ >50%" }, ;
    { 5, 5, 0, "� ����� ����襭��� ��������� �஢����饭�� � ��������" }, ;
    { 5, 6, 0, "� �����७��� �� �������⢥���� ������ࠧ������ ���㤪� �� १���⠬ 䨡ண����᪮���" }, ;
    { 5, 6, 1, "�� ࠭��� �⠤��" }, ;
    { 5, 7, 0, "� �����७��� �� �������⢥��� ������ࠧ������� ��⪨ � �� �ਤ�⪮�" }, ;
    { 5, 7, 1, "�� ࠭��� �⠤��" }, ;
    { 5, 8, 0, "� �����७��� �� �������⢥���� ������ࠧ������ ������ �� ����� �ᬮ�� ���-���࣠ (�஫���) � ��� �� �����ᯥ���᪨� ��⨣��" }, ;
    { 5, 8, 1, "�� ࠭��� �⠤��" }, ;
    { 5, 9, 0, "� �����७��� �� �������⢥���� ������ࠧ������ ��㤭�� ������ �� ����� �������䨨" }, ;
    { 5, 9, 1, "�� ࠭��� �⠤��" }, ;
    { 5, 10, 0, "� �����७��� �� ����४⠫�� ࠪ �� ����� ४�஬���- � ������᪮���" }, ;
    { 5, 10, 1, "�� ࠭��� �⠤��" }, ;
    { 5, 11, 0, "� �����७��� �� �������⢥��� ����������� ��㣨� ��������権" }, ;
    { 5, 11, 1, "�� ࠭��� �⠤��" }, ;
    { 5, 12, 0, "� ���� �����⮬" }, ;
    { 6, 0, 0, "������⢮ �ࠦ��� � ����� ������ �㡥�㫥��� ������" }, ;
    { 7, 0, 0, "������⢮ �ࠦ��� � ����� ������� ���㪮���, �� ���:" }, ;
    { 7, 0, 1, "�� ࠭��� �⠤��" }, ;
    { 8, 0, 0, "������⢮ �ࠦ��� � ����� �����묨 ����������ﬨ ��㣨� �࣠��� � ��⥬ �� ����� ��ਮ�" }, ;
    { 9, 0, 0, "������⢮ �ࠦ���, ������ 䠪��� �᪠ �஭��᪨� ����䥪樮���� ����������� �� ����� ��ਮ�, �� ���:" }, ;
    { 9, 1, 0, "���ॡ���� ⠡�� (��७��)" }, ;
    { 9, 2, 0, "����襭��� ��" }, ;
    { 9, 3, 0, "�����筠� ���� ⥫�" }, ;
    { 9, 4, 0, "���७��" }, ;
    { 9, 5, 0, "�����宫���ਭ����, ��᫨�������" }, ;
    { 9, 6, 0, "����࣫������" }, ;
    { 9, 7, 0, "�������筠� 䨧��᪠� ��⨢�����" }, ;
    { 9, 8, 0, "���樮���쭮� ��⠭��" }, ;
    { 9, 9, 0, "�����७��� �� ���㡭�� ���ॡ����� ��������" }, ;
    { 9, 10, 0, "����騥 2 䠪�� �᪠ � �����" }, ;
    { 10, 0, 0, "������⢮ �ࠦ��� � �����७��� �� ����ᨬ���� �� ��������, ��મ⨪�� � ����ய��� �।��, �� ���:" }, ;
    { 11, 0, 1, "�᫮ �ࠦ���, ���ࠢ������ � ��娠���-��મ����" }, ;
    { 12, 0, 0, "������⢮ �ࠦ��� 2-� ��㯯� ���஢��, ��襤�� 㣫㡫����� ��䨫����᪮� �������஢����" }, ;
    { 13, 0, 0, "������⢮ �ࠦ��� 2-� ��㯯� ���஢��, ��襤�� ��㯯���� ��䨫����᪮� �������஢����" }, ;
    { 14, 0, 0, "������⢮ �ࠦ��� 3-� ��㯯� ���஢��, ��襤�� 㣫㡫����� ��䨫����᪮� �������஢����" }, ;
    { 15, 0, 0, "������⢮ �ࠦ��� 3-� ��㯯� ���஢��, ��襤�� ��㯯���� ��䨫����᪮� �������஢����" };
    }
  Local i, ii, s, arr_m, buf := save_maxrow(), ar, arr_excel := {}

  If ( st_a_uch := inputn_uch( T_ROW, T_COL -5,,, @lcount_uch ) ) != NIL ;
      .and. ( arr_m := year_month(,,, 5 ) ) != NIL
    Private mk1, mispoln, mtel_isp
    ar := getinisect( tmp_ini(), group_ini )
    mk1 := Int( Val( a2default( ar, "mk1", "0" ) ) )
    mispoln := PadR( a2default( ar, "mispoln", "" ), 20 )
    mtel_isp := PadR( a2default( ar, "mtel_isp", "" ), 20 )
    s := " \" + ;
      "      ��饥 �᫮ �ࠦ���, ��������� ��ᯠ��ਧ�樨 @          \" + ;
      "      ������� � ���樠�� �ᯮ���⥫� @                           \" + ;
      "      ����䮭 �ᯮ���⥫�            @                           \" + ;
      " \"
    displbox( s, ;
      , ;                   // 梥� ���� (㬮��. - cDataCGet)
      { "mk1", "mispoln", "mtel_isp" }, ; // ���ᨢ Private-��६����� ��� ।���஢����
    { "999999",, }, ; // ���ᨢ Picture ��� ।���஢����
    17 )
    If LastKey() != K_ESC
      setinisect( tmp_ini(), group_ini, { { "mk1", mk1 }, ;
        { "mispoln", mispoln }, ;
        { "mtel_isp", mtel_isp };
        } )
      mywait()
      If f0_inf_dvn( arr_m, .f. )
        mywait( "���� ����⨪�" )
        delfrfiles()
        dbCreate( fr_data, { ;
          { "nomer", "C", 5, 0 }, ;
          { "nn1", "N", 2, 0 }, ;
          { "nn2", "N", 2, 0 }, ;
          { "nn3", "N", 2, 0 }, ;
          { "name", "C", 250, 0 }, ;
          { "v1", "N", 6, 0 }, ;
          { "v2", "N", 6, 0 } } )
        Use ( fr_data ) New Alias FRD
        For i := 1 To Len( as )
          Append Blank
          If !Empty( as[ i, 1 ] ) .and. Empty( as[ i, 2 ] )
            frd->nomer := lstr( as[ i, 1 ] ) + "."
          Endif
          frd->nn1 := as[ i, 1 ]
          frd->nn2 := as[ i, 2 ]
          frd->nn3 := as[ i, 3 ]
          frd->name := iif( !Empty( as[ i, 1 ] ), "", Space( 10 ) ) + ;
            iif( Empty( as[ i, 2 ] ), "", Space( 10 ) ) + ;
            iif( Empty( as[ i, 3 ] ), "", Space( 10 ) ) + ;
            as[ i, 4 ]
          If i == 1
            frd->v1 := frd->v2 := mk1
          Endif
        Next
        Index On Str( nn1, 2 ) + Str( nn2, 2 ) + Str( nn3, 2 ) to ( cur_dir() + "tmp_frd" )
        //
        r_use( dir_server() + "human_",, "HUMAN_" )
        r_use( dir_server() + "human",, "HUMAN" )
        Set Relation To RecNo() into HUMAN_
        r_use( dir_server() + "schet_",, "SCHET_" )
        ii := 0
        Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" ) new
        Go Top
        Do While !Eof()
          @ MaxRow(), 0 Say Str( ++ii / tmp->( LastRec() ) * 100, 6, 2 ) + "%" Color cColorWait
          If !emptyall( tmp->kod1h, tmp->kod2h ) // ⮫쪮 ��ᯠ��ਧ���
            f1_f22_inf_dvn()
          Endif
          Select TMP
          Skip
        Enddo
        Close databases
        r_use( dir_server() + "organiz",, "ORG" )
        dbCreate( fr_titl, { { "name", "C", 130, 0 }, ;
          { "period", "C", 100, 0 }, ;
          { "ispoln", "C", 100, 0 }, ;
          { "glavn", "C", 100, 0 } } )
        Use ( fr_titl ) New Alias FRT
        Append Blank
        frt->name := glob_mo[ _MO_SHORT_NAME ]
        frt->period := arr_m[ 4 ]
        frt->glavn :=  "������ ��� __________________ " + fam_i_o( org->ruk )
        frt->ispoln := "�ᯮ���⥫�: " + AllTrim( mispoln ) + " __________________ ⥫." + AllTrim( mtel_isp )
        //
        ar := {}
        AAdd( ar, { 2, 3, Month( arr_m[ 6 ] + 1 ) } )
        AAdd( ar, { 2, 4, "." + lstr( Year( arr_m[ 6 ] + 1 ) ) } )
        Use ( fr_data ) New Alias FRD
        For i := 1 To Len( as )
          Goto ( i )
          If i != 4
            AAdd( ar, { 8 + i, 3, frd->v1 } )
          Endif
          If !eq_any( i, 1, 4 )
            AAdd( ar, { 8 + i, 5, frd->v2 } )
          Endif
        Next
        AAdd( ar, { 59, 1, frt->glavn } )
        AAdd( ar, { 61, 1, frt->ispoln } )
        AAdd( arr_excel, { "�ଠ ����", AClone( ar ) } )
        Close databases
        call_fr( "mo_dvnMZ" )
      Endif
    Endif
  Endif

  Return Nil

// 23.09.15
Function f1_f22_inf_dvn() // ᢮���� ���ଠ��

  Local i, ar := {}, fl_reg1 := .f., fl_reg2 := .f., is_d := .f., is_pr := .f., ;
    k5 := 0, k9 := 0, m1gruppa, fl

  // ��ᯠ��ਧ��� I �⠯
  If Empty( tmp->kod1h )
    // ��� 1 �⠯�, �� ���� ��ன
  Else
    human->( dbGoto( tmp->kod1h ) )
    m1GRUPPA := ret_gruppa_dvn( human_->RSLT_NEW )
    If !Between( m1gruppa, 0, 4 )
      Return Nil
    Endif
    Private m1kurenie := 0, mad1 := 120, mad2 := 80, m1tip_mas := 0, ;
      mholest := 0, mglukoza := 0, ;
      m1holestdn := 0, m1glukozadn := 0, m1fiz_akt := 0, m1ner_pit := 0, ;
      m1riskalk := 0, m1pod_alk := 0, m1psih_na := 0, m1prof_ko := 0, ;
      pole_diag, pole_1stadia, pole_1pervich, mWEIGHT := 0, mHEIGHT := 0
    For i := 1 To 5
      pole_diag := "mdiag" + lstr( i )
      pole_1stadia := "m1stadia" + lstr( i )
      pole_1pervich := "m1pervich" + lstr( i )
      Private &pole_diag := Space( 6 )
      Private &pole_1stadia := 0
      Private &pole_1pervich := 0
    Next
    read_arr_dvn( human->kod )
    ret_tip_mas( mWEIGHT, mHEIGHT, @m1tip_mas )
    If human->schet > 0
      Select SCHET_
      Goto ( human->schet )
      If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // ⮫쪮 ��ॣ����஢����
        fl_reg1 := .t.
      Endif
    Endif
    //
    AAdd( ar, { 2, 0, 0, fl_reg1 } )
    If m1kurenie == 1
      AAdd( ar, { 9, 1, 0, fl_reg1 } ) ; ++k9
    Endif
    If mad1 > 140 .and. mad2 > 90
      AAdd( ar, { 9, 2, 0, fl_reg1 } ) ; ++k9
    Endif
    If m1tip_mas == 3
      AAdd( ar, { 9, 3, 0, fl_reg1 } ) ; ++k9
    Elseif m1tip_mas > 3
      AAdd( ar, { 9, 4, 0, fl_reg1 } ) ; ++k9
    Endif
    If m1holestdn == 1 .or. mholest > 5
      AAdd( ar, { 9, 5, 0, fl_reg1 } ) ; ++k9
    Endif
    If m1glukozadn == 1 .or. mglukoza > 6.1
      AAdd( ar, { 9, 6, 0, fl_reg1 } ) ; ++k9
    Endif
    If m1fiz_akt == 1
      AAdd( ar, { 9, 7, 0, fl_reg1 } ) ; ++k9
    Endif
    If m1ner_pit == 1
      AAdd( ar, { 9, 8, 0, fl_reg1 } ) ; ++k9
    Endif
    If m1riskalk == 1
      AAdd( ar, { 9, 9, 0, fl_reg1 } ) ; ++k9
    Endif
    If k9 > 1
      AAdd( ar, { 9, 10, 0, fl_reg1 } )
    Endif
    If k9 > 0
      AAdd( ar, { 9, 0, 0, fl_reg1 } )
    Endif
    If m1pod_alk == 1
      AAdd( ar, { 10, 0, 0, fl_reg1 } )
      If m1psih_na == 1
        AAdd( ar, { 11, 0, 1, fl_reg1 } )
      Endif
    Endif
    If !Empty( tmp->kod2h ) // ��ᯠ��ਧ��� II �⠯
      human->( dbGoto( tmp->kod2h ) )
      i := ret_gruppa_dvn( human_->RSLT_NEW )
      If Between( i, 1, 4 )
        m1gruppa := i
        If human->schet > 0
          Select SCHET_
          Goto ( human->schet )
          If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // ⮫쪮 ��ॣ����஢����
            fl_reg2 := .t.
          Endif
        Endif
        AAdd( ar, { 3, 0, 0, fl_reg2 } )
        If i == 2
          If m1prof_ko == 0
            AAdd( ar, { 12, 0, 0, fl_reg2 } )
          Elseif m1prof_ko == 1
            AAdd( ar, { 13, 0, 0, fl_reg2 } )
          Endif
        Elseif eq_any( i, 3, 4 )
          If m1prof_ko == 0
            AAdd( ar, { 14, 0, 0, fl_reg2 } )
          Elseif m1prof_ko == 1
            AAdd( ar, { 15, 0, 0, fl_reg2 } )
          Endif
        Endif
      Else // �᫨ ��-� �� ⠪ � ���� �⠯��
        human->( dbGoto( tmp->kod1h ) ) // �������� �� 1 �⠯
      Endif
    Endif
    If Between( m1gruppa, 1, 4 )
      fl := fl_reg1 .or. fl_reg2
      AAdd( ar, { 4, 0, 0, fl } )
      AAdd( ar, { 4, m1gruppa, 0, fl } )
      For i := 1 To 5
        pole_diag := "mdiag" + lstr( i )
        pole_1stadia := "m1stadia" + lstr( i )
        pole_1pervich := "m1pervich" + lstr( i )
        If !Empty( &pole_diag ) .and. &pole_1pervich == 1
          is_d := .t.
          If Left( &pole_diag, 3 ) == "I20"
            AAdd( ar, { 5, 1, 0, fl } ) ; ++k5
          Elseif Left( &pole_diag, 3 ) == "I25"
            AAdd( ar, { 5, 2, 0, fl } ) ; ++k5
          Elseif eq_any( Left( &pole_diag, 3 ), "I10", "I11", "I12", "I13", "I15" )
            AAdd( ar, { 5, 3, 0, fl } ) ; ++k5
          Elseif Left( &pole_diag, 5 ) == "I65.2"
            AAdd( ar, { 5, 4, 0, fl } ) ; ++k5
          Elseif Left( &pole_diag, 3 ) == "I66"
            AAdd( ar, { 5, 5, 0, fl } ) ; ++k5
          Elseif Left( &pole_diag, 1 ) == "C"
            If Left( &pole_diag, 3 ) == "C16"
              AAdd( ar, { 5, 6, 0, fl } ) ; ++k5
              if &pole_1stadia == 1
                AAdd( ar, { 5, 6, 1, fl } )
              Endif
            Elseif eq_any( Left( &pole_diag, 3 ), "C53", "C54", "C55" )
              AAdd( ar, { 5, 7, 0, fl } ) ; ++k5
              if &pole_1stadia == 1
                AAdd( ar, { 5, 7, 1, fl } )
              Endif
            Elseif Left( &pole_diag, 3 ) == "C61"
              AAdd( ar, { 5, 8, 0, fl } ) ; ++k5
              if &pole_1stadia == 1
                AAdd( ar, { 5, 8, 1, fl } )
              Endif
            Elseif Left( &pole_diag, 3 ) == "C50"
              AAdd( ar, { 5, 9, 0, fl } ) ; ++k5
              if &pole_1stadia == 1
                AAdd( ar, { 5, 9, 1, fl } )
              Endif
            Elseif eq_any( Left( &pole_diag, 3 ), "C17", "C18", "C19", "C20", "C21" )
              AAdd( ar, { 5, 10, 0, fl } ) ; ++k5
              if &pole_1stadia == 1
                AAdd( ar, { 5, 10, 1, fl } )
              Endif
            Else
              AAdd( ar, { 5, 11, 0, fl } ) ; ++k5
              if &pole_1stadia == 1
                AAdd( ar, { 5, 11, 1, fl } )
              Endif
            Endif
          Elseif eq_any( Left( &pole_diag, 3 ), "E10", "E11", "E12", "E13", "E14" )
            AAdd( ar, { 5, 12, 0, fl } ) ; ++k5
          Elseif eq_any( Left( &pole_diag, 3 ), "A15", "A16" )
            AAdd( ar, { 6, 0, 0, fl } ) ; is_pr := .t.
          Elseif Left( &pole_diag, 3 ) == "H40"
            AAdd( ar, { 7, 0, 0, fl } ) ; is_pr := .t.
            if &pole_1stadia == 1
              AAdd( ar, { 7, 1, 1, fl } )
            Endif
          Endif
        Endif
      Next
      If k5 > 0
        AAdd( ar, { 5, 0, 0, fl } )
      Endif
      If is_d .and. Empty( k5 ) .and. !is_pr
        AAdd( ar, { 8, 0, 0, fl } )
      Endif
    Endif
  Endif
  If !Empty( ar )
    Select FRD
    For i := 1 To Len( ar )
      find ( Str( ar[ i, 1 ], 2 ) + Str( ar[ i, 2 ], 2 ) + Str( ar[ i, 3 ], 2 ) )
      If Found()
        frd->v1++
        If ar[ i, 4 ]
          frd->v2++
        Endif
      Endif
    Next
  Endif

  Return Nil

// 27.09.24 ᯨ᮪ ��樥�⮢
Function f2_inf_dvn( is_schet, par )

  Local arr_m, buf := save_maxrow(), lkod_h, lkod_k, rec, s, as := {}, ;
    a, sh, HH := 53, n, n_file := cur_dir() + "spis_dvn.txt", reg_print
  Private ppar := par, p_is_schet := is_schet

  If par > 1
    ppar--
  Endif
  If ( st_a_uch := inputn_uch( T_ROW, T_COL -5,,, @lcount_uch ) ) != Nil .and. ( arr_m := year_month(,,, 5 ) ) != NIL
    mywait()
    If f0_inf_dvn( arr_m, eq_any( is_schet, 2, 3 ), is_schet == 3 )
      adbf := { ;
        { "nomer",   "N",     6,     0 }, ;
        { "KOD",   "N",     7,     0 }, ; // ��� (����� �����)
        { "KOD_K",   "N",     7,     0 }, ; // ��� �� ����⥪�
        { "FIO",   "C",    50,     0 }, ; // �.�.�. ���쭮��
        { "DATE_R",   "D",     8,     0 }, ; // ��� ஦����� ���쭮��
        { "N_DATA",   "D",     8,     0 }, ; // ��� ��砫� ��祭��
        { "K_DATA",   "D",     8,     0 }, ; // ��� ����砭�� ��祭��
        { "sroki",   "C",    35,     0 }, ; // �ப� ��祭��
        { "CENA_1",   "N",    10,     2 }, ; // ����稢����� �㬬� ��祭��
        { "KOD_DIAG",   "C",     5,     0 }, ; // ��� 1-�� ��.�������
        { "etap",   "N",     1,     0 }, ; //
        { "gruppa",   "N",     1,     0 }, ; //
        { "vrach",   "C",    15,     0 }, ; // ���
        { "DATA_O",   "C",    35,     0 } ; // �ப� ��㣮�� �⠯�
      }
      // ret_arrays_disp( .f. )
      ret_arrays_disp()
      Private count_dvn_arr_usl18 := Len( dvn_arr_usl18 )
      Private count_dvn_arr_umolch18 := Len( dvn_arr_umolch18 )
      // ret_arrays_disp( .t., .t. )
      ret_arrays_disp()
      For i := 1 To Max( count_dvn_arr_usl18, count_dvn_arr_usl )
        AAdd( adbf, { "d_" + lstr( i ), "C", 24, 0 } )
      Next
      For i := 1 To Max( count_dvn_arr_umolch18, count_dvn_arr_umolch )
        AAdd( adbf, { "du_" + lstr( i ), "C", 8, 0 } )
      Next
      AAdd( adbf, { "fl_2018", "L", 1, 0 } )
      AAdd( adbf, { "d_zs", "C", 8, 0 } )
      dbCreate( cur_dir() + "tmpfio", adbf )
      Use ( cur_dir() + "tmpfio" ) New Alias TF
      r_use( dir_server() + "uslugi",, "USL" )
      use_base( "human_u" )
      r_use( dir_server() + "human_",, "HUMAN_" )
      r_use( dir_server() + "human",, "HUMAN" )
      Set Relation To RecNo() into HUMAN_
      r_use( dir_server() + "mo_pers",, "PERS" )
      r_use( dir_server() + "schet_",, "SCHET_" )
      Use ( cur_dir() + "tmp" ) new
      Go Top
      Do While !Eof()
        @ MaxRow(), 0 Say Str( tmp->( RecNo() ) / tmp->( LastRec() ) * 100, 6, 2 ) + "%" Color cColorWait
        Do Case
        Case par == 1
          If tmp->kod1h > 0
            f2_inf_dvn_svod( 1, tmp->kod1h )
          Endif
        Case par == 2
          If tmp->kod1h > 0 .and. tmp->kod2h == 0
            f2_inf_dvn_svod( 0, tmp->kod1h )
          Endif
        Case par == 3
          If tmp->kod1h > 0 .and. tmp->kod2h > 0
            f2_inf_dvn_svod( 2, tmp->kod2h )
          Endif
        Case par == 4
          If tmp->kod3h > 0
            f2_inf_dvn_svod( 3, tmp->kod3h )
          Endif
        Endcase
        Select TMP
        Skip
      Enddo
      Close databases
      mywait()
      at := { ;
        { "����ਣ������ ��������", { { 1, .t., 1 }, { 1, .f., 1 } }, 0 }, ;
        { "�஢� �� ��騩 宫���ਭ", { { 1, .t., 2 }, { 1, .f., 2 }, { 3, .t., 2 }, { 3, .f., 2 } }, 0 }, ;
        { "�஢��� ���� � �஢�", { { 1, .t., 3 }, { 1, .f., 3 }, { 3, .t., 3 }, { 3, .f., 3 } }, 0 }, ;
        { "������᪨� ������ ���", { { 1, .t., 4 }, { 1, .f., 4 } }, 0 }, ;
        { "������ �஢� (3 ������⥫�)", { { 1, .t., 5 }, { 1, .f., 5 }, { 3, .t., 5 }, { 3, .f., 5 } }, 0 }, ;
        { "������ �஢� (ࠧ������)", { { 1, .t., 6 }, { 1, .f., 6 } }, 0 }, ;
        { "���娬��᪨� ������ �஢�", { { 1, .t., 7 }, { 1, .f., 7 } }, 0 }, ;
        { "�஢� �� �����-ᯥ���᪨� ��⨣��", { { 1, .t., 8 }, { 2, .f., 21 } }, 0 }, ;
        { "��᫥������� ���� �� ������ �஢�", { { 1, .t., 9 }, { 1, .f., 8 }, { 3, .t., 9 }, { 3, .f., 8 } }, 0 }, ;
        { "�ᬮ�� ����મ�, ���⨥ ����� (�᪮��)", { { 1, .t., 10 }, { 1, .f., 9 } }, 0 }, ;
        { "��������� ������� �����", { { 1, .t., 11 }, { 1, .f., 11 }, { 3, .t., 11 }, { 3, .f., 11 } }, 0 }, ;
        { "���ண��� �񣪨�", { { 1, .t., 12 }, { 1, .f., 12 }, { 3, .t., 12 }, { 3, .f., 12 } }, 0 }, ;
        { "��� ���譮� ������", { { 1, .t., 13 }, { 1, .f., 13 }, { 1, .f., 15 } }, 0 }, ;
        { "�����ப�न����� (� �����)", { { 1, .t., 14 }, { 1, .f., 16 } }, 0 }, ;
        { "���஬����", { { 2, .f., 17 } }, 0 }, ;
        { "�����஢���� ���������� �஢�", { { 2, .t., 15 }, { 2, .f., 18 } }, 0 }, ;
        { "����࠭⭮��� � ����", { { 2, .t., 16 }, { 2, .f., 19 } }, 0 }, ;
        { "������� ᯥ��� �஢�", { { 2, .t., 17 }, { 2, .f., 20 } }, 0 }, ;
        { "������-�� ��娮�䠫��� ���਩", { { 2, .t., 18 }, { 2, .f., 22 } }, 0 }, ;
        { "�����䠣�����த㮤���᪮���", { { 2, .t., 19 }, { 2, .f., 23 } }, 0 }, ;
        { "����᪮��� ���������᪠�", { { 2, .t., 20 }, { 2, .f., 24 } }, 0 }, ;
        { "����ᨣ��������᪮��� ���������᪠�", { { 2, .t., 21 }, { 2, .f., 25 } }, 0 }, ;
        { "��� ��� ���஫���", { { 1, .t., 22 }, { 2, .t., 22 }, { 2, .f., 26 } }, 0 }, ;
        { "��� ��� ��⠫쬮����", { { 2, .t., 23 }, { 2, .f., 27 } }, 0 }, ;
        { "��� ��� ��ਭ���ਭ������", { { 2, .f., 28 } }, 0 }, ;
        { "��� ��� �஫��� (���࣠)", { { 2, .t., 24 }, { 2, .f., 29 } }, 0 }, ;
        { "��� ��� �����-����������", { { 2, .t., 25 }, { 2, .f., 30 } }, 0 }, ;
        { "��� ��� �����ப⮫��� (���࣠)", { { 2, .t., 26 }, { 2, .f., 31 } }, 0 }, ;
        { "��� ��� �࠯���", { { 1, .t., 27 }, { 1, .f., 32 }, { 2, .t., 27 }, { 2, .f., 32 }, { 3, .t., 27 }, { 3, .f., 32 } }, 0 };
      }
      lat := Len( at )
      aitog := Array( lat ) ; AFill( aitog, 0 ) ; is_zs := 0
      Use ( cur_dir() + "tmpfio" ) New Alias TF
      Index On Upper( fio ) to ( cur_dir() + "tmpfio" )
      Go Top
      Do While !Eof()
        For i := 1 To iif( tf->fl_2018, count_dvn_arr_usl18, count_dvn_arr_usl )
          pole := "tf->d_" + lstr( i )
          If !Empty( &pole )
            For j := 1 To lat
              If at[ j, 3 ] == 0 .and. AScan( at[ j, 2 ], {| x| x[ 1 ] == ppar .and. x[ 2 ] == tf->fl_2018 .and. x[ 3 ] == i } ) > 0
                at[ j, 3 ] := 1 ; Exit
              Endif
            Next
          Endif
        Next
        If Empty( is_zs ) .and. !Empty( tf->d_zs )
          is_zs := 1
        Endif
        Skip
      Enddo
      arr_title := { ;
        "����������������������������������", ;
        "            ���⠳  �ப�   � ��.", ;
        "    �.�.�   �஦�� ��祭��  �����-", ;
        "            �����          � ��� ", ;
        "����������������������������������" }
      If ppar == 2
        arr_title[ 1 ] += "�����������"
        arr_title[ 2 ] += "����ଠ��"
        arr_title[ 3 ] += "�� I �⠯� "
        arr_title[ 4 ] += "���ᯠ�-樨"
        arr_title[ 5 ] += "�����������"
      Endif
      For i := 1 To lat
        If at[ i, 3 ] > 0
          arr_title[ 1 ] += "���������"
          arr_title[ 2 ] += "�" + PadR( SubStr( at[ i, 1 ], 1, 8 ), 8 )
          arr_title[ 3 ] += "�" + PadR( SubStr( at[ i, 1 ], 9, 8 ), 8 )
          arr_title[ 4 ] += "�" + PadR( SubStr( at[ i, 1 ], 17, 8 ), 8 )
          arr_title[ 5 ] += "���������"
        Endif
      Next
      If is_zs > 0
        arr_title[ 1 ] += "���������"
        arr_title[ 2 ] += "�  ���  "
        arr_title[ 3 ] += "������祭"
        arr_title[ 4 ] += "� ���� "
        arr_title[ 5 ] += "���������"
      Endif
      If ppar == 1
        arr_title[ 1 ] += "�����������"
        arr_title[ 2 ] += "����ଠ��"
        arr_title[ 3 ] += "�� II �⠯�"
        arr_title[ 4 ] += "���ᯠ�-樨"
        arr_title[ 5 ] += "�����������"
      Endif
      arr_title[ 1 ] += "����������"
      arr_title[ 2 ] += "��� �㬬� "
      arr_title[ 3 ] += "�� ����"
      arr_title[ 4 ] += "�� ���"
      arr_title[ 5 ] += "����������"
      reg_print := f_reg_print( arr_title, @sh, 2 )
      fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
      add_string( "" )
      If ppar == 1
        add_string( Center( "��ᯠ��ਧ��� ���᫮�� ��ᥫ���� 1 �⠯", sh ) )
        If par == 2
          add_string( Center( "���ࠢ���� �� 2 �⠯, �� ��� �� ��諨", sh ) )
        Endif
      Elseif ppar == 2
        add_string( Center( "��ᯠ��ਧ��� ���᫮�� ��ᥫ���� 2 �⠯", sh ) )
      Else
        add_string( Center( "��䨫��⨪� ���᫮�� ��ᥫ����", sh ) )
      Endif
      If is_schet == 4
        add_string( Center( "[ ��砨, ��� �� �����訥 � ��� ]", sh ) )
      Else
        add_string( Center( "[ " + CharRem( "~", mas1pmt[ is_schet ] ) + " ]", sh ) )
      Endif
      add_string( Center( arr_m[ 4 ], sh ) )
      add_string( "" )
      AEval( arr_title, {| x| add_string( x ) } )
      j1 := ss := 0
      Go Top
      Do While !Eof()
        s := lstr( ++j1 ) + ". " + tf->fio
        s1 := SubStr( s, 1, 12 ) + " "
        s2 := SubStr( s, 13, 12 ) + " "
        s3 := SubStr( s, 25, 12 ) + " "
        s := full_date( tf->date_r )
        s1 += PadR( SubStr( s, 1, 3 ), 5 )
        s2 += PadR( SubStr( s, 4, 3 ), 5 )
        s3 += PadR( SubStr( s, 7 ), 5 )
        //
        s1 += PadR( SubStr( tf->sroki, 1, 9 ), 11 )
        s2 += PadR( SubStr( tf->sroki, 10, 9 ), 11 )
        s3 += PadR( SubStr( tf->sroki, 19 ), 11 )
        //
        s1 += PadR( tf->KOD_DIAG, 6 )
        s2 += Space( 6 )
        s3 += Space( 6 )
        If ppar == 2
          s1 += PadR( SubStr( tf->data_o, 1, 9 ), 11 )
          s2 += PadR( SubStr( tf->data_o, 10, 9 ), 11 )
          s3 += PadR( SubStr( tf->data_o, 19 ), 11 )
        Endif
        For i := 1 To lat
          If at[ i, 3 ] > 0
            fl := .t.
            For j := 1 To Len( at[ i, 2 ] )
              If at[ i, 2, j, 1 ] == ppar .and. at[ i, 2, j, 2 ] == tf->fl_2018
                pole := "tf->d_" + lstr( at[ i, 2, j, 3 ] ) // ����� ����� �� ���ᨢ� �-�� mo_init
                If !Empty( &pole )
                  s1 += PadR( SubStr( &pole, 1, 8 ), 9 )
                  s2 += PadR( SubStr( &pole, 9, 8 ), 9 )
                  s3 += PadR( SubStr( &pole, 17 ), 9 )
                  If Between( Left( &pole, 1 ), '0', '9' )
                    aitog[ i ] ++
                  Endif
                  fl := .f.
                  Exit
                Endif
              Endif
            Next
            If fl
              s1 += Space( 9 )
              s2 += Space( 9 )
              s3 += Space( 9 )
            Endif
          Endif
        Next
        If is_zs > 0
          s1 += PadR( tf->d_zs, 9 )
          s2 += Space( 9 )
          s3 += Space( 9 )
        Endif
        If ppar == 1
          s1 += PadR( SubStr( tf->data_o, 1, 9 ), 11 )
          s2 += PadR( SubStr( tf->data_o, 10, 9 ), 11 )
          s3 += PadR( SubStr( tf->data_o, 19 ), 11 )
        Endif
        s1 += iif( tf->gruppa == 4, "3", put_val( tf->gruppa, 1 ) ) + Str( tf->CENA_1, 8, 2 )
        If tf->gruppa > 2
          s2 += iif( tf->gruppa == 3, "�", "�" )
        Endif
        s3 += AllTrim( tf->vrach )
        ss += tf->CENA_1
        If verify_ff( HH -3, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( s1 )
        add_string( s2 )
        add_string( s3 )
        add_string( Replicate( "�", sh ) )
        Skip
      Enddo
      s1 := PadR( "�⮣�:", 13 + 5 + 11 + 6 )
      If ppar == 2
        s1 += Space( 11 )
      Endif
      For i := 1 To lat
        If at[ i, 3 ] > 0
          If Empty( aitog[ i ] )
            Space( 9 )
          Else
            s1 += PadC( lstr( aitog[ i ] ), 8 ) + " "
          Endif
        Endif
      Next
      i := 0
      If is_zs > 0
        i += 9
      Endif
      If ppar == 1
        i += 11
      Endif
      i += 2
      s1 += Str( ss, 7 + i, 2 )
      add_string( s1 )
      Close databases
      FClose( fp )
      Private yes_albom := .t.
      viewtext( n_file,,,, ( sh > 80 ),,, reg_print )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 27.09.24
Function f2_inf_dvn_svod( par, kod_h ) // ᢮���� ���ଠ��

  Static P_BEGIN_RSLT := 342
  Local i, j, c, s, pole, ar, arr := {}, fl, lshifr, arr_usl := {}
  Private metap := ppar, m1gruppa, mvozrast, mdvozrast, mpol, mn_data, mk_data, ;
    arr_usl_dop := {}, arr_usl_otkaz := {}, arr_otklon := {}, m1veteran := 0, mvar, ;
    fl2 := .f., mshifr_zs := "", is_2019

  Select HUMAN
  Goto ( kod_h )
  mpol    := human->pol
  mn_data := human->n_data
  mk_data := human->k_data
  is_2018 := p := ( mk_data < 0d20190501 )
  is_2021 := p := ( mk_data < 0d20210101 )
  is_2019 := !is_2018
  ret_arr_vozrast_dvn( mk_data )
  // ret_arrays_disp( is_2019, is_2021 )
  ret_arrays_disp( mk_data )
  If ppar == 1 // ��ᯠ��ਧ��� 1 �⠯
    m1GRUPPA := ret_gruppa_dvn( human_->RSLT_NEW, @fl2 )
    If Between( m1gruppa, 0, 4 )
      If m1gruppa == 0
        fl2 := .t. // ���ࠢ��� �� 2 �⠯
      Endif
    Else
      Return Nil
    Endif
    If par == 0 .and. !fl2
      Return Nil
    Endif
  Elseif ppar == 2 // ��ᯠ��ਧ��� 2 �⠯
    m1GRUPPA := ret_gruppa_dvn( human_->RSLT_NEW )
    If Between( m1gruppa, 1, 4 )
      //
    Else
      Return Nil
    Endif
  Elseif ppar == 3 // ��䨫��⨪�
    m1GRUPPA := 0
    If Between( human_->RSLT_NEW, 343, 345 )
      m1GRUPPA := human_->RSLT_NEW - 342
    Elseif Between( human_->RSLT_NEW, 373, 374 )
      m1GRUPPA := human_->RSLT_NEW - 370
    Endif
    If !Between( m1gruppa, 1, 4 )
      Return Nil
    Endif
  Else
    Return Nil
  Endif
  read_arr_dvn( kod_h )
  mvozrast := count_years( human->date_r, human->n_data )
  mdvozrast := Year( human->n_data ) - Year( human->date_r )
  If m1veteran == 1
    mdvozrast := ret_vozr_dvn_veteran( mdvozrast, human->k_data )
  Endif
  For i := 1 To iif( is_2018, count_dvn_arr_usl18, count_dvn_arr_usl )
    mvar := "MTAB_NOMv" + lstr( i )
    Private &mvar := 0
    mvar := "MDATE" + lstr( i )
    Private &mvar := CToD( "" )
    mvar := "M1OTKAZ" + lstr( i )
    Private &mvar := 0
  Next
  fl := .f.
  If ppar == 1 .and. tmp->kod2h > 0
    Select HUMAN
    Goto ( tmp->kod2h )
    fl := ( human_->oplata != 9 )
  Elseif ppar == 2 .and. tmp->kod1h > 0
    Select HUMAN
    Goto ( tmp->kod1h )
    fl := ( human_->oplata != 9 )
  Endif
  If fl
    s := "�� � ����"
    If human->schet > 0
      s := "����ॣ.��"
      Select SCHET_
      Goto ( human->schet )
      If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // ��ॣ����஢����
        s := "���� ��ॣ"
      Endif
    Endif
    AAdd( arr, { human->n_data, human->k_data, s } )
  Endif
  Select HUMAN
  Goto ( kod_h )
  If p_is_schet == 4 .and. human->schet > 0
    Return Nil
  Endif
  s := "�� � ����"
  If human->schet > 0
    s := "����ॣ.��"
    Select SCHET_
    Goto ( human->schet )
    If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // ��ॣ����஢����
      s := "���� ��ॣ"
    Endif
  Endif
  Select TF
  Append Blank
  tf->KOD    := human->kod
  tf->KOD_K  := tmp->kod_k
  tf->FIO    := human->fio
  tf->DATE_R := human->date_r
  tf->N_DATA := mN_DATA
  tf->K_DATA := mK_DATA
  tf->sroki  := date_8( mN_DATA ) + "-" + date_8( mK_DATA ) + " " + s
  tf->CENA_1 := human->CENA_1
  tf->etap   := metap
  tf->gruppa := m1gruppa
  tf->KOD_DIAG := human->kod_diag
  If Len( arr ) > 0
    tf->data_o := date_8( arr[ 1, 1 ] ) + "-" + date_8( arr[ 1, 2 ] ) + " " + arr[ 1, 3 ]
  Endif
  pers->( dbGoto( human_->vrach ) )
  tf->vrach := fam_i_o( pers->fio )
  lcount := iif( is_2018, count_dvn_arr_usl18, count_dvn_arr_usl )
  larr_dvn := iif( is_2018, dvn_arr_usl18, dvn_arr_usl )
  lcount_u := iif( is_2018, count_dvn_arr_umolch18, count_dvn_arr_umolch )
  larr_dvn_u := iif( is_2018, dvn_arr_umolch18, dvn_arr_umolch )
  larr := Array( 2, lcount ) ; afillall( larr, 0 )
  Select HU
  find ( Str( kod_h, 7 ) )
  Do While hu->kod == kod_h .and. !Eof()
    usl->( dbGoto( hu->u_kod ) )
    If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, mk_data ) )
      lshifr := usl->shifr
    Endif
    lshifr := AllTrim( lshifr )
    If !eq_any( Left( lshifr, 5 ), "70.3.", "70.7.", "72.1.", "72.5.", "72.6.", "72.7.", "2.90." )
      mshifr_zs := lshifr
    Else
      fl := .t.
      If metap != 2
        If is_2018
          If lshifr == "2.3.3" .and. hu_->PROFIL == 3 ; // �����᪮�� ����
            .and. ( i := AScan( dvn_arr_usl18, {| x| ValType( x[ 2 ] ) == "C" .and. x[ 2 ] == "4.20.1" } ) ) > 0
            fl := .f. ; larr[ 1, i ] := hu->( RecNo() )
          Endif
        Else
        /*if ((lshifr == "2.3.3" .and. hu_->PROFIL == 3) .or.  ; // �����᪮�� ����
              (lshifr == "2.3.1" .and. hu_->PROFIL == 136))  ; // �������� � �����������
            .and. (i := ascan(dvn_arr_usl, {|x| valtype(x[2])=="C" .and. x[2]=="4.1.12"})) > 0
          fl := .f. ; larr[1,i] := hu->(recno())
        endif*/
        Endif
      Endif
      If fl
        For i := 1 To lcount_u
          If Empty( larr[ 2, i ] ) .and. larr_dvn_u[ i, 2 ] == lshifr
            fl := .f. ; larr[ 2, i ] := hu->( RecNo() ) ; Exit
          Endif
        Next
      Endif
      If fl
        For i := 1 To lcount
          If Empty( larr[ 1, i ] )
            If ValType( larr_dvn[ i, 2 ] ) == "C"
              If larr_dvn[ i, 2 ] == lshifr
                fl := .f.
              Elseif larr_dvn[ i, 2 ] == "4.20.1" .and. lshifr == "4.20.2"
                fl := .f.
              Endif
            Elseif Len( larr_dvn[ i ] ) > 11
              If AScan( larr_dvn[ i, 12 ], {| x| x[ 1 ] == lshifr .and. x[ 2 ] == hu_->PROFIL } ) > 0
                fl := .f.
              Endif
            Endif
            If !fl
              larr[ 1, i ] := hu->( RecNo() ) ; Exit
            Endif
          Endif
        Next
      Endif
    Endif
    AAdd( arr_usl, hu->( RecNo() ) )
    Select HU
    Skip
  Enddo
  For i := 1 To lcount
    If !Empty( larr[ 1, i ] )
      hu->( dbGoto( larr[ 1, i ] ) )
      If hu->kod_vr > 0
        mvar := "MTAB_NOMv" + lstr( i )
        &mvar := hu->kod_vr
      Endif
      mvar := "MDATE" + lstr( i )
      &mvar := c4tod( hu->date_u )
      mvar := "M1OTKAZ" + lstr( i )
      If metap != 2
        If is_2018
          If hu_->PROFIL == 3 .and. ;
              AScan( dvn_arr_usl18, {| x| ValType( x[ 2 ] ) == "C" .and. x[ 2 ] == "4.20.1" } ) > 0
            &mvar := 2 // ������������� �믮������
          Endif
        Else
        /*if (hu_->PROFIL == 3 .or. hu_->PROFIL == 136)  ;
            .and. ascan(dvn_arr_usl, {|x| valtype(x[2])=="C" .and. x[2]=="4.1.12"}) > 0
          &mvar := 2 // ������������� �믮������
        endif*/
        Endif
      Endif
    Endif
  Next
  If metap != 2 .and. ValType( arr_usl_otkaz ) == "A"
    For j := 1 To Len( arr_usl_otkaz )
      ar := arr_usl_otkaz[ j ]
      If ValType( ar ) == "A" .and. Len( ar ) >= 5 .and. ValType( ar[ 5 ] ) == "C"
        lshifr := AllTrim( ar[ 5 ] )
        If ( i := AScan( larr_dvn, {| x| ValType( x[ 2 ] ) == "C" .and. x[ 2 ] == lshifr } ) ) > 0
          If ValType( ar[ 1 ] ) == "N" .and. ar[ 1 ] > 0
            mvar := "MTAB_NOMv" + lstr( i )
            &mvar := ar[ 1 ]
          Endif
          mvar := "MDATE" + lstr( i )
          &mvar := mn_data
          If Len( ar ) >= 9 .and. ValType( ar[ 9 ] ) == "D"
            &mvar := ar[ 9 ]
          Endif
          mvar := "M1OTKAZ" + lstr( i )
          &mvar := 1
          If Len( ar ) >= 10 .and. ValType( ar[ 10 ] ) == "N" .and. Between( ar[ 10 ], 1, 2 )
            &mvar := ar[ 10 ]
          Endif
        Endif
      Endif
    Next
  Endif
  //
  If is_2018
    arr := f21_inf_dvn_svod18( 1 )
  Else
    arr := f21_inf_dvn_svod( 1 )
  Endif
  For i := 1 To Len( arr )
    pole := "tf->d_" + lstr( arr[ i, 4 ] )
    If arr[ i, 5 ] == 1
      &pole := "�⪠�   ��樥��"
    Elseif arr[ i, 5 ] == 2
      &pole := "������������� �믮������"
    Else
      &pole := date_8( arr[ i, 2 ] )
    Endif
  Next
  tf->d_zs := mshifr_zs
  tf->fl_2018 := is_2018
  If is_2018
    arr := f21_inf_dvn_svod18( 2 )
  Else
    arr := f21_inf_dvn_svod( 2 )
  Endif
  For i := 1 To Len( arr )
    pole := "tf->du_" + lstr( arr[ i, 4 ] )
    &pole := date_8( arr[ i, 2 ] )
  Next

  Return Nil

// 10.11.19
Function f21_inf_dvn_svod18( par )

  Local i, arr := {}

  If par == 1
    For i := 1 To count_dvn_arr_usl18
      mvart := "MTAB_NOMv" + lstr( i )
      mvard := "MDATE" + lstr( i )
      mvaro := "M1OTKAZ" + lstr( i )
      If f_is_usl_oms_sluch_dvn( i, metap, iif( metap == 3, mvozrast, mdvozrast ), mpol )
        If !emptyany( &mvard, &mvart )
          AAdd( arr, { dvn_arr_usl18[ i, 1 ], &mvard, "", i, &mvaro } )
        Endif
      Endif
    Next
  Else
    For i := 1 To count_dvn_arr_umolch18
      If f_is_umolch_sluch_dvn( i, metap, iif( metap == 3, mvozrast, mdvozrast ), mpol )
        AAdd( arr, { dvn_arr_umolch18[ i, 1 ], iif( dvn_arr_umolch18[ i, 8 ] == 0, mn_data, mk_data ), "", i, 0 } )
      Endif
    Next
  Endif

  Return arr

// 08.12.15
Function f21_inf_dvn_svod( par )

  Local i, arr := {}

  If par == 1
    For i := 1 To count_dvn_arr_usl
      mvart := "MTAB_NOMv" + lstr( i )
      mvard := "MDATE" + lstr( i )
      mvaro := "M1OTKAZ" + lstr( i )
      If f_is_usl_oms_sluch_dvn( i, metap, iif( metap == 3, mvozrast, mdvozrast ), mpol )
        If !emptyany( &mvard, &mvart )
          AAdd( arr, { dvn_arr_usl[ i, 1 ], &mvard, "", i, &mvaro } )
        Endif
      Endif
    Next
  Else
    For i := 1 To count_dvn_arr_umolch
      If f_is_umolch_sluch_dvn( i, metap, iif( metap == 3, mvozrast, mdvozrast ), mpol )
        AAdd( arr, { dvn_arr_umolch[ i, 1 ], iif( dvn_arr_umolch[ i, 8 ] == 0, mn_data, mk_data ), "", i, 0 } )
      Endif
    Next
  Endif

  Return arr

// 19.02.18 ���ଠ�� �� ��䨫��⨪� � ����ᬮ�ࠬ ��ᮢ��襭����⭨�
Function inf_dnl( k )

  Static si1 := 1, si2 := 1, sj1 := 1, sj2 := 1
  Local mas_pmt, mas_msg, mas_fun, j, j1, j2
  Local mas2pmt := { "��~䨫����᪨� �ᬮ���", ;
    "��~����⥫�� �ᬮ���", ;
    "��~ਮ���᪨� �ᬮ���" }

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { "~���� ���.����ᬮ��", ;
      "~���᮪ ��樥�⮢", ;
      "~�������ਠ��� �����", ;
      "����� ��� ���~��ࠢ�", ;
      "��ଠ � 030-��/~�-17", ;
      "XML-䠩� ��� ~���⠫� ����" }
    mas_msg := { "���� ��䨫����᪮�� ����ᬮ�� ��ᮢ��襭����⭥�� (�ଠ � 030-��/�-17)", ;
      "��ᬮ�� ᯨ�� ��樥�⮢, ��襤�� ����ᬮ���", ;
      "�������ਠ��� ����� �� ��ᯠ��ਧ�樨/����ᬮ�ࠬ ��ᮢ��襭����⭨�", ;
      "��ᯥ�⪠ ᢮��� ��� ������ࠤ᪮�� �����⭮�� ������ ��ࠢ���࠭����", ;
      "�������� � ��䨫����᪨� �ᬮ��� ��ᮢ��襭����⭨� (�ଠ � 030-��/�-17)", ;
      "�������� XML-䠩�� ��� ����㧪� �� ���⠫ �����ࠢ� ��" }
    mas_fun := { "inf_DNL(11)", ;
      "inf_DNL(12)", ;
      "inf_DNL(13)", ;
      "inf_DNL(14)", ;
      "inf_DNL(15)", ;
      "inf_DNL(16)" }
    Private p_tip_lu := TIP_LU_PN
    popup_prompt( T_ROW, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    inf_dnl_karta()
  Case k == 12
    ne_real()
  Case k == 13
    mnog_poisk_dnl()
  Case k == 14
    mas_pmt := { "~�������� � ���ᬮ��� ��⥩ �� ���ﭨ� �� ..." }
    mas_msg := { "�ਫ������ � �ਪ��� ������ �1025 �� 08.07.2019�." }
    mas_fun := { "inf_DNL(21)" }
    popup_prompt( T_ROW, T_COL -5, si2, mas_pmt, mas_msg, mas_fun )
  Case k == 15
    If ( j1 := popup_prompt( T_ROW, T_COL -5, 1, mas1pmt ) ) > 0
      inf_dnl_030poo( j1 )
    Endif
  Case k == 16
    // if (j2 := popup_prompt(T_ROW,T_COL-5,sj2,mas2pmt,,,"N/W,GR+/R,B/W,W+/R")) > 0
    // sj2 := j2
    // p_tip_lu := {TIP_LU_PN,TIP_LU_PREDN,TIP_LU_PERN}[j2]
    p_tip_lu := TIP_LU_PN
    If ( j1 := popup_prompt( T_ROW, T_COL -5, 1, mas1pmt ) ) > 0
      // inf_DNL_XMLfile(j1,charrem("~",mas2pmt[j2]))
      inf_dnl_xmlfile( j1, "��䨫����᪨� �ᬮ���" )
    Endif
    // endif
  Case k == 21
    If ( j1 := popup_prompt( T_ROW, T_COL -5, 1, mas1pmt ) ) > 0
      f21_inf_dnl( j1 )
    Endif
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Elseif Between( k, 21, 29 )
      si2 := j
    Endif
  Endif

  Return Nil

// 25.03.18 ��ᯥ�⪠ ����� ���.���.�ᬮ�� (���⭠� �ଠ � 030-��/�...)
Function inf_dnl_karta()

  Local arr_m, buf := save_maxrow(), blk, t_arr[ BR_LEN ]

  If ( arr_m := year_month( T_ROW, T_COL -5 ) ) != NIL
    mywait()
    If f0_inf_dnl( arr_m, .f. )
      Copy File ( cur_dir() + "tmp" + sdbf() ) to ( cur_dir() + "tmpDNL" + sdbf() ) // �.�. ����� ⮦� ���� TMP-䠩�
      r_use( dir_server() + "human",, "HUMAN" )
      Use ( cur_dir() + "tmpDNL" ) new
      Set Relation To kod into HUMAN
      Index On Upper( human->fio ) to ( cur_dir() + "tmpDNL" )
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + "human_",, "HUMAN_" ), ;
        r_use( dir_server() + "human",, "HUMAN" ), ;
        dbSetRelation( "HUMAN_", {|| RecNo() }, "recno()" ), ;
        r_use( cur_dir() + "tmpDNL", cur_dir() + "tmpDNL", "TMP" ), ;
        dbSetRelation( "HUMAN", {|| kod }, "kod" );
        }
      Eval( blk_open )
      Go Top
      t_arr[ BR_TOP ] := T_ROW
      t_arr[ BR_BOTTOM ] := 23
      t_arr[ BR_LEFT ] := 0
      t_arr[ BR_RIGHT ] := 79
      t_arr[ BR_TITUL ] := "���ᬮ��� ��ᮢ��襭����⭨� " + arr_m[ 4 ]
      t_arr[ BR_TITUL_COLOR ] := "B/BG"
      t_arr[ BR_COLOR ] := color0
      t_arr[ BR_ARR_BROWSE ] := { '�', '�', '�', "N/BG,W+/N,B/BG,W+/B", .t. }
      blk := {|| iif( human->schet > 0, { 1, 2 }, { 3, 4 } ) }
      t_arr[ BR_COLUMN ] := { { " �.�.�.", {|| PadR( human->fio, 39 ) }, blk }, ;
        { "��� ஦�.", {|| full_date( human->date_r ) }, blk }, ;
        { "� ��.�����", {|| human->uch_doc }, blk }, ;
        { "�ப� ���-�", {|| Left( date_8( human->n_data ), 5 ) + "-" + Left( date_8( human->k_data ), 5 ) }, blk }, ;
        { "�⠯", {|| iif( human->ishod == 301, " I  ", "I-II" ) }, blk } }
      t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ - ��室;  ^<Enter>^ - �ᯥ���� ����� ��䨫����᪮�� ���.�ᬮ��" ) }
      t_arr[ BR_EDIT ] := {| nk, ob| f1_inf_dnl_karta( nk, ob, "edit" ) }
      edit_browse( t_arr )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 11.03.19
Function f0_inf_dnl( arr_m, is_schet, is_reg, arr_ishod, is_snils )

  Local fl := .t.

  Default is_schet To .t., is_reg To .f., is_snils To .f., arr_ishod TO { 301, 302 } // ��䨫��⨪� 1 � 2 �⠯
  If !del_dbf_file( cur_dir() + "tmp" + sdbf() )
    Return .f.
  Endif
  dbCreate( cur_dir() + "tmp", { { "kod", "N", 7, 0 }, ;
    { "kod_k", "N", 7, 0 }, ;
    { "is", "N", 1, 0 }, ;
    { "ishod", "N", 6, 0 } } )
  Use ( cur_dir() + "tmp" ) new
  r_use( dir_server() + "schet_",, "SCHET_" )
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "human_",, "HUMAN_" )
  r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
  Set Relation To RecNo() into HUMAN_, To kod_k into KART
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Index On kod to ( cur_dir() + "tmp_h" ) ;
    For AScan( arr_ishod, ishod ) > 0 .and. iif( is_schet, schet > 0, .t. ) ;
    While human->k_data <= arr_m[ 6 ] ;
    PROGRESS
  Go Top
  Do While !Eof()
    fl := .t.
    If is_reg
      fl := .f.
      Select SCHET_
      Goto ( human->schet )
      If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // ⮫쪮 ��ॣ����஢����
        fl := .t.
      Endif
    Endif
    If fl .and. ret_koef_from_rak( human->kod ) > 0
      Select TMP
      Append Blank
      tmp->kod := human->kod
      tmp->kod_k := human->kod_k
      tmp->ishod := human->ishod
      tmp->is := iif( is_snils .and. Empty( kart->snils ), 0, 1 )
    Endif
    Select HUMAN
    Skip
  Enddo
  fl := .t.
  If tmp->( LastRec() ) == 0
    fl := func_error( 4, "�� ������� �/� �� ����ᬮ�ࠬ ��ᮢ��襭����⭨� " + arr_m[ 4 ] )
  Endif
  Close databases

  Return fl

// 07.08.13
Function f1_inf_dnl_karta( nKey, oBrow, regim )

  Local ret := -1, lkod_h, lkod_k, rec := tmp->( RecNo() ), buf := save_maxrow()

  If regim == "edit" .and. nKey == K_ENTER
    mywait()
    lkod_h := human->kod
    lkod_k := human->kod_k
    Close databases
    oms_sluch_pn( lkod_h, lkod_k, "f2_inf_DNL_karta" )
    Eval( blk_open )
    Goto ( rec )
    rest_box( buf )
  Endif

  Return ret

// 13.09.25
Function f2_inf_dnl_karta( Loc_kod, kod_kartotek, lvozrast )

  Static st := "     ", ub := "<u><b>", ue := "</b></u>", sh := 88
  Local adbf, s, i, j, k, y, m, d, fl, mm_danet, blk := {| s| __dbAppend(), field->stroke := s }
  local mm_invalid5 := mm_invalid5()

  delfrfiles()
  r_use( dir_server() + "mo_stdds" )
  If Type( "m1stacionar" ) == "N" .and. m1stacionar > 0
    Goto ( m1stacionar )
  Endif
  r_use( dir_server() + "kartote_",, "KART_" )
  Goto ( kod_kartotek )
  r_use( dir_server() + "kartotek",, "KART" )
  Goto ( kod_kartotek )
  r_use( dir_server() + "mo_pers",, "P2" )
  Goto ( m1vrach )
  r_use( dir_server() + "organiz",, "ORG" )
  adbf := { { "name", "C", 130, 0 }, ;
    { "prikaz", "C", 50, 0 }, ;
    { "forma", "C", 50, 0 }, ;
    { "titul", "C", 100, 0 }, ;
    { "fio", "C", 50, 0 }, ;
    { "k_data", "C", 40, 0 }, ;
    { "vrach", "C", 40, 0 }, ;
    { "glavn", "C", 40, 0 } }
  dbCreate( fr_titl, adbf )
  Use ( fr_titl ) New Alias FRT
  Append Blank
  frt->name := glob_mo[ _MO_SHORT_NAME ]
  frt->fio := mfio
  frt->k_data := date_month( mk_data )
  frt->vrach := fam_i_o( p2->fio )
  frt->glavn := fam_i_o( org->ruk )
  adbf := { { "stroke", "C", 2000, 0 } }
  dbCreate( fr_data, adbf )
  Use ( fr_data ) New Alias FRD
  frt->prikaz := "�� 10 ������ 2017 �. � 514�"
  frt->forma  := "030-��/�-17"
  frt->titul  := "���� ��䨫����᪮�� �ᬮ�� ��ᮢ��襭����⭥��"
  s := st + "1. �������, ���, ����⢮ (�� ����稨) ��ᮢ��襭����⭥��: " + ub + AllTrim( mfio ) + ue + "."
  frd->( Eval( blk, s ) )
  s := st + "���: " + f3_inf_dds_karta( { { "��.", "�" }, { "���.", "�" } }, mpol, "/", ub, ue )
  frd->( Eval( blk, s ) )
  s := st + "��� ஦�����: " + ub + date_month( mdate_r, .t. ) + ue + "."
  frd->( Eval( blk, s ) )
  s := st + "2. ����� ��易⥫쭮�� ����樭᪮�� ���客����: "
  s += "��� " + iif( Empty( mspolis ), Replicate( "_", 15 ), ub + AllTrim( mspolis ) + ue )
  s += " � " + ub + AllTrim( mnpolis ) + ue + "."
  frd->( Eval( blk, s ) )
  s := st + "���客�� ����樭᪠� �࣠������: " + ub + AllTrim( mcompany ) + ue + "."
  frd->( Eval( blk, s ) )
  s := st + "3. ���客�� ����� �������㠫쭮�� ��楢��� ���: "
//  s += iif( Empty( kart->snils ), Replicate( "_", 25 ), ub + Transform( kart->SNILS, picture_pf ) + ue ) + "."
  s += iif( Empty( kart->snils ), Replicate( "_", 25 ), ub + Transform_SNILS( kart->SNILS ) + ue ) + "."
  frd->( Eval( blk, s ) )
  s := st + "4. ���� ���� ��⥫��⢠ (�ॡ뢠���): "
  If emptyall( kart_->okatog, kart->adres )
    s += Replicate( "_", 37 ) + " " + Replicate( "_", sh ) + "."
  Else
    s += ub + ret_okato_ulica( kart->adres, kart_->okatog, 1, 2 ) + ue + "."
  Endif
  frd->( Eval( blk, s ) )
  s := st + "5. ��⥣���: " + f3_inf_dds_karta( mm_kateg_uch(), m1kateg_uch, "; ", ub, ue )
  frd->( Eval( blk, s ) )
  s := st + "6. ������ ������������ ����樭᪮� �࣠����樨, � ���ன " + ;
    "��ᮢ��襭����⭨� ����砥� ��ࢨ��� ������-ᠭ����� ������: "
  s += ub + ret_mo( m1MO_PR )[ _MO_FULL_NAME ] + ue + "."
  frd->( Eval( blk, s ) )
  s := st + "7. ���� ���� ��宦����� ����樭᪮� �࣠����樨, � ���ன " + ;
    "��ᮢ��襭����⭨� ����砥� ��ࢨ��� ������-ᠭ����� ������: "
  s += ub + ret_mo( m1MO_PR )[ _MO_ADRES ] + ue + "."
  frd->( Eval( blk, s ) )
  madresschool := ""
  If Type( "m1school" ) == "N" .and. m1school > 0
    r_use( dir_server() + "mo_schoo",, "SCH" )
    Goto ( m1school )
    If !Empty( sch->fname )
      mschool := AllTrim( sch->fname )
      madresschool := AllTrim( sch->adres )
    Endif
  Endif
  s := st + "8. ������ ������������ ��ࠧ���⥫쭮� �࣠����樨, � ���ன " + ;
    "���砥��� ��ᮢ��襭����⭨�: " + ub + mschool + ue + "."
  frd->( Eval( blk, s ) )
  s := st + "9. ���� ���� ��宦����� ��ࠧ���⥫쭮� �࣠����樨, � ���ன " + ;
    "���砥��� ��ᮢ��襭����⭨�: "
  If Empty( madresschool )
    frd->( Eval( blk, s ) )
    s := Replicate( "_", sh ) + "."
  Else
    s += ub + madresschool + ue + "."
  Endif
  frd->( Eval( blk, s ) )
  s := st + "10. ��� ��砫� ��䨫����᪮�� ����樭᪮�� �ᬮ�� ��ᮢ��襭����⭥�� (����� - ��䨫����᪨� �ᬮ��): " + ub + full_date( mn_data ) + ue + "."
  frd->( Eval( blk, s ) )
  s := st + "11. ������ ������������ � ���� ���� ��宦����� ����樭᪮� �࣠����樨, " + ;
    "�஢����襩 ��䨫����᪨� �ᬮ��: " + ;
    ub + glob_mo[ _MO_FULL_NAME ] + ", " + glob_mo[ _MO_ADRES ] + ue + "."
  frd->( Eval( blk, s ) )
  s := st + "12. �業�� 䨧��᪮�� ࠧ���� � ��⮬ ������ �� ������ ��䨫����᪮�� �ᬮ��:"
  frd->( Eval( blk, s ) )
  count_ymd( mdate_r, mn_data, @y, @m, @d )
  s := ub + st + lstr( d ) + st + ue + " (�᫮ ����) " + ;
    ub + st + lstr( m ) + st + ue + " (����楢) " + ;
    ub + st + lstr( y ) + st + ue + " ���."
  frd->( Eval( blk, s ) )
  mm_fiz_razv1 := { { "����� ����� ⥫�", 1 }, { "����⮪ ����� ⥫�", 2 } }
  mm_fiz_razv2 := { { "������ ���", 1 }, { "��᮪�� ���", 2 } }
  For i := 1 To 2
    s := st + "12." + lstr( i ) + ". ��� ��⥩ � ������ " + ;
      { "0 - 4 ���: ", "5 - 17 ��� �����⥫쭮: " }[ i ]
    If i == 1
      fl := ( lvozrast < 5 )
    Else
      fl := ( lvozrast > 4 )
    Endif
    s += "���� (��) " + iif( !fl, "________", ub + st + lstr( mWEIGHT ) + st + ue ) + "; "
    s += "��� (�) " + iif( !fl, "________", ub + st + lstr( mHEIGHT ) + st + ue ) + "; "
    If i == 1
      s += "���㦭���� ������ (�) " + iif( !fl .or. mPER_HEAD == 0, "________", ub + st + lstr( mPER_HEAD ) + st + ue ) + "; "
    Endif
    s += "䨧��᪮� ࠧ��⨥ " + f3_inf_dds_karta( mm_fiz_razv(), iif( fl, m1FIZ_RAZV, -1 ),, ub, ue, .f. )
    s += " (" + f3_inf_dds_karta( mm_fiz_razv1, iif( fl, m1FIZ_RAZV1, -1 ),, ub, ue, .f. )
    s += ", " + f3_inf_dds_karta( mm_fiz_razv2, iif( fl, m1FIZ_RAZV2, -1 ),, ub, ue, .f. )
    s += " - �㦭�� ����ભ���)."
    frd->( Eval( blk, s ) )
  Next
  fl := ( lvozrast < 5 )
  s := st + "13. �業�� ����᪮�� ࠧ���� (���ﭨ�):"
  frd->( Eval( blk, s ) )
  s := st + "13.1. ��� ��⥩ � ������ 0 - 4 ���:"
  frd->( Eval( blk, s ) )
  s := st + "�������⥫쭠� �㭪�� (������ ࠧ����) " + iif( !fl, "________", ub + st + lstr( m1psih11 ) + st + ue ) + ";"
  frd->( Eval( blk, s ) )
  s := st + "���ୠ� �㭪�� (������ ࠧ����) " + iif( !fl, "________", ub + st + lstr( m1psih12 ) + st + ue ) + ";"
  frd->( Eval( blk, s ) )
  s := st + "�樮���쭠� � �樠�쭠� (���⠪� � ���㦠�騬 ��஬) �㭪樨 (������ ࠧ����) " + iif( !fl, "________", ub + st + lstr( m1psih13 ) + st + ue ) + ";"
  frd->( Eval( blk, s ) )
  s := st + "�।�祢�� � �祢�� ࠧ��⨥ (������ ࠧ����) " + iif( !fl, "________", ub + st + lstr( m1psih14 ) + st + ue ) + "."
  frd->( Eval( blk, s ) )
  fl := ( lvozrast > 4 )
  s := st + "13.2. ��� ��⥩ � ������ 5 - 17 ���:"
  frd->( Eval( blk, s ) )
  s := st + "13.2.1. ��宬��ୠ� ���: " + f3_inf_dds_karta( mm_psih2(), iif( fl, m1psih21, -1 ),, ub, ue )
  frd->( Eval( blk, s ) )
  s := st + "13.2.2. ��⥫����: " + f3_inf_dds_karta( mm_psih2(), iif( fl, m1psih22, -1 ),, ub, ue )
  frd->( Eval( blk, s ) )
  s := st + "13.2.3. ���樮���쭮-�����⨢��� ���: " + f3_inf_dds_karta( mm_psih2(), iif( fl, m1psih23, -1 ),, ub, ue )
  frd->( Eval( blk, s ) )
  fl := ( mpol == "�" .and. lvozrast > 9 )
  s := st + "14. �業�� �������� ࠧ���� (� 10 ���):"
  frd->( Eval( blk, s ) )
  s := st + "14.1. ������� ��㫠 ����稪�: � " + iif( !fl .or. m141p == 0, "________", ub + st + lstr( m141p ) + st + ue )
  s += " �� " + iif( !fl .or. m141ax == 0, "________", ub + st + lstr( m141ax ) + st + ue )
  s += " Fa " + iif( !fl .or. m141fa == 0, "________", ub + st + lstr( m141fa ) + st + ue ) + "."
  frd->( Eval( blk, s ) )
  fl := ( mpol == "�" .and. lvozrast > 9 )
  s := st + "14.2. ������� ��㫠 ����窨: � " + iif( !fl .or. m142p == 0, "________", ub + st + lstr( m142p ) + st + ue )
  s += " �� " + iif( !fl .or. m142ax == 0, "________", ub + st + lstr( m142ax ) + st + ue )
  s += " Ma " + iif( !fl .or. m142ma == 0, "________", ub + st + lstr( m142ma ) + st + ue )
  s += " Me " + iif( !fl .or. m142me == 0, "________", ub + st + lstr( m142me ) + st + ue ) + ";"
  frd->( Eval( blk, s ) )
  s := st + "�ࠪ���⨪� ������㠫쭮� �㭪樨: menarhe ("
  s += iif( !fl .or. m142me1 == 0, "________", ub + st + lstr( m142me1 ) + st + ue ) + " ���, "
  s += iif( !fl .or. m142me2 == 0, "________", ub + st + lstr( m142me2 ) + st + ue ) + " ����楢); "
  If fl .and. emptyall( m142p, m142ax, m142ma, m142me, m142me1, m142me2 )
    m1142me3 := m1142me4 := m1142me5 := -1
  Endif
  s += "menses (�ࠪ���⨪�): " + f3_inf_dds_karta( mm_142me3(), iif( fl, m1142me3, -1 ),, ub, ue, .f. )
  s += ", " + f3_inf_dds_karta( mm_142me4(), iif( fl, m1142me4, -1 ),, ub, ue, .f. )
  s += ", " + f3_inf_dds_karta( mm_142me5(), iif( fl, m1142me5, -1 ), " � ", ub, ue )
  frd->( Eval( blk, s ) )
  s := st + "15. ����ﭨ� ���஢�� �� �஢������ �����饣� ��䨫����᪮�� �ᬮ��:"
  frd->( Eval( blk, s ) )
  If lvozrast < 14
    mdef_diagnoz := "Z00.1"
  Else
    mdef_diagnoz := "Z00.3"
  Endif
  s := st + "15.1. �ࠪ��᪨ ���஢ " + iif( m1diag_15_1 == 0, Replicate( "_", 30 ), ub + st + RTrim( mdef_diagnoz ) + st + ue ) + " (��� �� ���)."
  frd->( Eval( blk, s ) )
  //
  mm_dispans := { { "��⠭������ ࠭��", 1 }, { "��⠭������ �����", 2 }, { "�� ��⠭������", 0 } }
  mm_danet := { { "��", 1 }, { "���", 0 } }
  mm_usl := { { "� ���㫠���� �᫮����", 0 }, ;
    { "� �᫮���� �������� ��樮���", 1 }, ;
    { "� ��樮����� �᫮����", 2 } }
  mm_uch := { { "� �㭨樯����� ����樭᪨� �࣠�������", 1 }, ;
    { "� ���㤠��⢥���� ����樭᪨� �࣠������� ��ꥪ� ���ᨩ᪮� �����樨 ", 0 }, ;
    { "� 䥤�ࠫ��� ����樭᪨� �࣠�������", 2 }, ;
    { "����� ����樭᪨� �࣠�������", 3 } }
  mm_uch1 := AClone( mm_uch )
  AAdd( mm_uch1, { "ᠭ��୮-������� �࣠�������", 4 } )
  mm_danet1 := { { "�������", 1 }, { "�� �������", 0 } }
  For i := 1 To 5
    fl := .f.
    For k := 1 To 14
      mvar := "mdiag_15_" + lstr( i ) + "_" + lstr( k )
      If k == 1
        fl := !Empty( &mvar ) .and. m1diag_15_1 == 0
      Else
        m1var := "m1diag_15_" + lstr( i ) + "_" + lstr( k )
        If fl
          Do Case
          Case eq_any( k, 4, 5, 6, 7 )
            mvar := "m1diag_15_" + lstr( i ) + "_3"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            Endif
          Case eq_any( k, 9, 10, 11, 12 )
            mvar := "m1diag_15_" + lstr( i ) + "_8"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            Endif
          Case k == 14
            mvar := "m1diag_15_" + lstr( i ) + "_13"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            Endif
          Endcase
        Else
          &m1var := -1
        Endif
      Endif
    Next
  Next
  For i := 1 To 5
    fl := .f.
    s := s1 := s2 := s3 := s4 := s5 := s6 := ""
    For k := 1 To 2
      mvar := "mdiag_15_" + lstr( i ) + "_" + lstr( k )
      If k == 1
        fl := !Empty( &mvar ) .and. m1diag_15_1 == 0
      Else
        m1var := "m1diag_15_" + lstr( i ) + "_" + lstr( k )
        If ( j := &m1var ) > 0
          j := 1
        Endif
      Endif
      Do Case
      Case k == 1
        s := st + "15." + lstr( i + 1 ) + ". ������� " + iif( !fl, Replicate( "_", 30 ), ub + st + RTrim( &mvar ) + st + ue ) + " (��� �� ���)."
      Case k == 2
        s1 := st + "15." + lstr( i + 1 ) + ".1. ��ᯠ��୮� ������� ��⠭������: " + f3_inf_dds_karta( mm_danet, j,, ub, ue )
      Endcase
    Next
    frd->( Eval( blk, s ) )
    frd->( Eval( blk, s1 ) )
  Next
  mm_gruppa := { { "I", 1 }, { "II", 2 }, { "III", 3 }, { "IV", 4 }, { "V", 5 } }
  s := st + "15.7. ��㯯� ���ﭨ� ���஢��: " + f3_inf_dds_karta( mm_gruppa, mGRUPPA_DO,, ub, ue )
  frd->( Eval( blk, s ) )
  s := st + "15.8. ����樭᪠� ��㯯� ��� ����⨩ 䨧��᪮� �����ன: " + f3_inf_dds_karta( mm_gr_fiz_do, m1GR_FIZ_DO,, ub, ue )
  frd->( Eval( blk, s ) )
  s := st + "16. ����ﭨ� ���஢�� �� १���⠬ �஢������ �����饣� ��䨫����᪮�� �ᬮ��:"
  frd->( Eval( blk, s ) )
  s := st + "16.1. �ࠪ��᪨ ���஢ " + iif( m1diag_16_1 == 0, Replicate( "_", 30 ), ub + st + RTrim( mkod_diag ) + st + ue ) + " (��� �� ���)."
  frd->( Eval( blk, s ) )
  For i := 1 To 5
    fl := .f.
    For k := 1 To 16
      mvar := "mdiag_16_" + lstr( i ) + "_" + lstr( k )
      If k == 1
        fl := !Empty( &mvar ) .and. m1diag_16_1 == 0
      Else
        m1var := "m1diag_16_" + lstr( i ) + "_" + lstr( k )
        If fl
          Do Case
          Case eq_any( k, 5, 6 )
            mvar := "m1diag_16_" + lstr( i ) + "_4"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            Endif
          Case eq_any( k, 8, 9 )
            mvar := "m1diag_16_" + lstr( i ) + "_7"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            Endif
          Case eq_any( k, 11, 12 )
            mvar := "m1diag_16_" + lstr( i ) + "_10"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            Endif
          Case eq_any( k, 14, 15 )
            mvar := "m1diag_16_" + lstr( i ) + "_13"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            Endif
          Endcase
        Else
          &m1var := -1
        Endif
      Endif
    Next
  Next
  For i := 1 To 5
    fl := .f.
    s := s1 := s2 := s3 := s4 := s5 := s6 := s7 := ""
    For k := 1 To 15
      mvar := "mdiag_16_" + lstr( i ) + "_" + lstr( k )
      If k == 1
        fl := !Empty( &mvar ) .and. m1diag_16_1 == 0
      Else
        m1var := "m1diag_16_" + lstr( i ) + "_" + lstr( k )
      Endif
      Do Case
      Case k == 1
        s := st + "16." + lstr( i + 1 ) + ". ������� " + iif( !fl, Replicate( "_", 30 ), ub + st + RTrim( &mvar ) + st + ue ) + " (��� �� ���)."
      Case k == 2
        s1 := st + "16." + lstr( i + 1 ) + ".1. ������� ��⠭����� �����: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 3
        s2 := st + "16." + lstr( i + 1 ) + ".2. ��ᯠ��୮� �������: " + f3_inf_dds_karta( mm_dispans, &m1var,, ub, ue )
      Case k == 4
        s3 := st + "16." + lstr( i + 1 ) + ".3. �������⥫�� �������樨 � ��᫥������� �����祭�: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 5
        s3 := Left( s3, Len( s3 ) -1 ) + '; �᫨ "��": ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 6
        s3 := Left( s3, Len( s3 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch, &m1var,, ub, ue )
      Case k == 7
        s4 := st + "16." + lstr( i + 1 ) + ".4. �������⥫�� �������樨 � ��᫥������� �믮�����: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 8
        s4 := Left( s4, Len( s4 ) -1 ) + '; �᫨ "��": ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 9
        s4 := Left( s4, Len( s4 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch, &m1var,, ub, ue )
      Case k == 10
        s5 := st + "16." + lstr( i + 1 ) + ".5. ��祭�� �����祭�: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 11
        s5 := Left( s5, Len( s5 ) -1 ) + '; �᫨ "��": ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 12
        s5 := Left( s5, Len( s5 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch, &m1var,, ub, ue )
      Case k == 13
        s6 := st + "16." + lstr( i + 1 ) + ".6. ����樭᪠� ॠ������� � (���) ᠭ��୮-����⭮� ��祭�� �����祭�: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 14
        s6 := Left( s6, Len( s6 ) -1 ) + '; �᫨ "��": ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 15
        s6 := Left( s6, Len( s6 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch1, &m1var,, ub, ue )
      Endcase
    Next
    frd->( Eval( blk, s ) )
    frd->( Eval( blk, s1 ) )
    frd->( Eval( blk, s2 ) )
    frd->( Eval( blk, s3 ) )
    frd->( Eval( blk, s4 ) )
    frd->( Eval( blk, s5 ) )
    frd->( Eval( blk, s6 ) )
  Next
  If m1invalid1 == 0
    m1invalid2 := m1invalid5 := m1invalid6 := m1invalid8 := -1
    minvalid3 := minvalid4 := minvalid7 := CToD( "" )
  Endif
  If Empty( minvalid7 )
    m1invalid8 := -1
  Endif
  s := st + '16.7. ������������: ' + f3_inf_dds_karta( mm_danet, m1invalid1,, ub, ue )
  s := Left( s, Len( s ) -1 ) + '; �᫨ "��": ' + f3_inf_dds_karta( mm_invalid2(), m1invalid2,, ub, ue )
  s := Left( s, Len( s ) -1 ) + '; ��⠭������ ����� (���) ' + iif( Empty( minvalid3 ), Replicate( "_", 15 ), ub + full_date( minvalid3 ) + ue )
  s += '; ��� ��᫥����� �ᢨ��⥫��⢮����� ' + iif( Empty( minvalid4 ), Replicate( "_", 15 ), ub + full_date( minvalid4 ) + ue ) + '.'
  frd->( Eval( blk, s ) )
/*s := st+'16.7.1. �����������, ���᫮���訥 ������������� �����������:'
frd->(eval(blk,s))
mm_invalid5[6, 1] := "������� �஢�, �஢�⢮��� �࣠��� � �⤥��� ����襭��, ��������騥 ���㭭� ��堭���;"
mm_invalid5[7, 1] := "������� ���ਭ��� ��⥬�, ����ன�⢠ ��⠭�� � ����襭�� ������ �����,"
atail(mm_invalid5)[1] := "��᫥��⢨� �ࠢ�, ��ࠢ����� � ��㣨� �������⢨� ���譨� ��稭)"
s := st+'(' + f3_inf_DDS_karta(mm_invalid5,m1invalid5,' ',ub,ue)
frd->(eval(blk,s))
s := st+'16.7.2.���� ����襭�� � ���ﭨ� ���஢��:'
frd->(eval(blk,s))
s := st + f3_inf_DDS_karta(mm_invalid6(),m1invalid6,'; ',ub,ue)
frd->(eval(blk,s))
s := st+'16.7.3. �������㠫쭠� �ணࠬ�� ॠ�����樨 ॡ����-��������:'
frd->(eval(blk,s))
s := st+'��� �����祭��: '+iif(empty(minvalid7), replicate("_", 15), ub + full_date(minvalid7)+ue)+';'
frd->(eval(blk,s))
s := st+'�믮������ �� ������ ��ᯠ��ਧ�樨: ' + f3_inf_DDS_karta(mm_invalid8(),m1invalid8,,ub,ue)
frd->(eval(blk,s))*/
  s := st + "16.8. ��㯯� ���ﭨ� ���஢��: " + f3_inf_dds_karta( mm_gruppa, mGRUPPA,, ub, ue )
  frd->( Eval( blk, s ) )
  s := st + "16.9. ����樭᪠� ��㯯� ��� ����⨩ 䨧��᪮� �����ன: "
  s += f3_inf_dds_karta( mm_gr_fiz, m1GR_FIZ,, ub, ue )
  frd->( Eval( blk, s ) )
/*s := st+'16.10'+'. �஢������ ��䨫����᪨� �ਢ����:'
frd->(eval(blk,s))
s := st
for j := 1 to len(mm_privivki1())
  if m1privivki1 == mm_privivki1()[j, 2]
    s += ub
  endif
  s += mm_privivki1()[j, 1]
  if m1privivki1 == mm_privivki1()[j, 2]
    s += ue
  endif
  if mm_privivki1()[j, 2] == 0
    s += "; "
  else
    s += ": " + f3_inf_DDS_karta(mm_privivki2(),iif(m1privivki1==mm_privivki1()[j, 2],m1privivki2,-1),,ub,ue,.f.)+"; "
  endif
next
s += '�㦤����� � �஢������ ���樭�樨 (ॢ��樭�樨) � 㪠������ ������������ �ਢ���� (�㦭�� ����ભ���): '
if m1privivki1 > 0 .and. !empty(mprivivki3)
  s += ub+alltrim(mprivivki3)+ue
endif
frd->(eval(blk,s))
s := replicate("_",sh)+"."
frd->(eval(blk,s))*/
  s := st + '17. ���������樨 �� �ନ஢���� ���஢��� ��ࠧ� �����, ०��� ���, ��⠭��, 䨧��᪮�� ࠧ����, ���㭮��䨫��⨪�, ������ 䨧��᪮� �����ன: '
  k := 3
  If !Empty( mrek_form )
    k := 1
    s += ub + AllTrim( mrek_form ) + ue
  Endif
  frd->( Eval( blk, s ) )
  For i := 1 To k
    s := Replicate( "_", sh ) + iif( i == k, ".", "" )
    frd->( Eval( blk, s ) )
  Next
  s := st + '18. ���������樨 �� �஢������ ��ᯠ��୮�� �������, ' + ;
    '��祭��, ����樭᪮� ॠ�����樨 � ᠭ��୮-����⭮�� ��祭��: '
  k := 5
  If !Empty( mrek_disp )
    k := 2
    s += ub + AllTrim( mrek_disp ) + ue
  Endif
  frd->( Eval( blk, s ) )
  For i := 1 To k
    s := Replicate( "_", sh ) + iif( i == k, ".", "" )
    frd->( Eval( blk, s ) )
  Next
  //
  adbf := { { "name", "C", 60, 0 }, ;
    { "data", "C", 10, 0 }, ;
    { "rezu", "C", 17, 0 } }
  dbCreate( fr_data + "1", adbf )
  Use ( fr_data + "1" ) New Alias FRD1
  dbCreate( fr_data + "2", adbf )
  Use ( fr_data + "2" ) New Alias FRD2
/*arr := f4_inf_DNL_karta(1)
for i := 1 to len(arr)
  select FRD1
  append blank
  frd1->name := arr[i, 1]
  frd1->data := full_date(arr[i, 2])
next
arr := f4_inf_DNL_karta(2)
for i := 1 to len(arr)
  select FRD2
  append blank
  frd2->name := arr[i, 1]
  frd2->data := full_date(arr[i, 2])
  frd2->rezu := arr[i, 3]
next*/
  //
  Close databases
  call_fr( "mo_030pou17" )

  Return Nil

// 02.06.20
Function f4_inf_dnl_karta( par, _etap )

  Local i, k := 0, fl, arr := {}, ar

  If Type( "mperiod" ) == "N" .and. Between( mperiod, 1, 31 )
    //
  Else
    mperiod := ret_period_pn( mdate_r, mn_data, mk_data,, @k )
  Endif
  If !Between( mperiod, 1, 31 )
    mperiod := k
  Endif
  If !Between( mperiod, 1, 31 )
    mperiod := 31
  Endif
  np_oftal_2_85_21( mperiod, mk_data )
  ar := np_arr_1_etap[ mperiod ]
  If par == 1
    If iif( _etap == nil, .t., _etap == 1 )
      For i := 1 To count_pn_arr_osm -1
        mvart := "MTAB_NOMov" + lstr( i )
        mvard := "MDATEo" + lstr( i )
        fl := .t.
        If fl .and. !Empty( np_arr_osmotr[ i, 2 ] )
          fl := ( mpol == np_arr_osmotr[ i, 2 ] )
        Endif
        If fl
          fl := ( !Empty( ar[ 4 ] ) .and. AScan( ar[ 4 ], np_arr_osmotr[ i, 1 ] ) > 0 )
        Endif
        If fl .and. !emptyany( &mvard, &mvart )
          AAdd( arr, { np_arr_osmotr[ i, 3 ], &mvard, "", i, f5_inf_dnl_karta( i ) } )
        Endif
      Next
    Endif
    AAdd( arr, { "������� (��� ��饩 �ࠪ⨪�)", MDATEp1, "", -1, 1 } )
    If metap == 2 .and. iif( _etap == nil, .t., _etap == 2 )
      For i := 1 To count_pn_arr_osm -1
        mvart := "MTAB_NOMov" + lstr( i )
        mvard := "MDATEo" + lstr( i )
        fl := .t.
        If fl .and. !Empty( np_arr_osmotr[ i, 2 ] )
          fl := ( mpol == np_arr_osmotr[ i, 2 ] )
        Endif
        If fl
          fl := ( AScan( ar[ 4 ], np_arr_osmotr[ i, 1 ] ) == 0 )
        Endif
        If fl .and. !emptyany( &mvard, &mvart )
          AAdd( arr, { np_arr_osmotr[ i, 3 ], &mvard, "", i, f5_inf_dnl_karta( i ) } )
        Endif
      Next
      AAdd( arr, { "������� (��� ��饩 �ࠪ⨪�)", MDATEp2, "", -2, 1 } )
    Endif
  Else
    For i := 1 To count_pn_arr_iss // ��᫥�������
      mvart := "MTAB_NOMiv" + lstr( i )
      mvard := "MDATEi" + lstr( i )
      mvarr := "MREZi" + lstr( i )
      fl := .t.
      If fl .and. !Empty( np_arr_issled[ i, 2 ] )
        fl := ( mpol == np_arr_issled[ i, 2 ] )
      Endif
      If fl
        fl := ( AScan( ar[ 5 ], np_arr_issled[ i, 1 ] ) > 0 )
      Endif
      If fl .and. !emptyany( &mvard, &mvart )
        k := 0
        Do Case
        Case i == 1 // {"3.5.4"   ,   , "�㤨������᪨� �ਭ���", 0, 64,{1111, 111101} }, ;
          k := 15
        Case i == 2 // {"4.2.153" ,   , "��騩 ������ ���", 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 2
          // case i == 3 // {"4.8.1"   ,   , "��騩 ������ ����", 0, 34,{1107, 1301, 1402, 1702} }, ;
          // k := 3
          // case i == 4 // {"4.11.136",   , "������᪨� ������ �஢�", 0, 34,{1107, 1301, 1402, 1702} }, ;
        Case i == 3 // {"4.11.136",   , "������᪨� ������ �஢�", 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 1
          // case i == 5 // {"4.12.169",   , "��᫥������� �஢�� ���� � �஢�", 0, 34,{1107, 1301, 1402, 1702} }, ;
          // k := 4
          // case between(i, 6, 16) // {"4.14.67" ,   , "�஫��⨭ (��ମ�)", 1, 34,{1107, 1301, 1402, 1702} }, ;
          // k := 5
          // case between(i, 17, 21) // {"4.26.1"  ,   , "�����⠫�� �ਭ��� �� �����८�", 0, 34,{1107, 1301, 1402, 1702} }, ;
        Case Between( i, 4, 8 ) // {"4.26.1"  ,   , "�����⠫�� �ਭ��� �� �����८�", 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 14
          // case i == 22 // {"7.61.3"  ,   , "���ண��� ������ � 1-� �஥�樨", 0, 78,{1118, 1802} }, ;
          // k := 12
          // case i == 23 // {"8.1.1"   ,   , "��� ��������� ����� (����ᮭ�����)", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
        Case i == 9 // {"8.1.1"   ,   , "��� ��������� ����� (����ᮭ�����)", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 11
          // case i == 24 // {"8.1.2"   ,   , "��� �⮢����� ������", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          // k := 8
        Case i == 12 // {"8.1.6"   , 12, "��� ��祪", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 18
          // case i == 25 // {"8.1.3"   ,   , "��� ���", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
        Case i == 10 // {"8.1.3"   ,   , "��� ���", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 7
          // case i == 26 // {"8.1.4"   ,   , "��� ⠧����७��� ���⠢��", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
        Case i == 11 // {"8.1.4"   ,   , "��� ⠧����७��� ���⠢��", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 10
          // case i == 27 // {"8.2.1"   ,   , "��� �࣠��� ���譮� ������", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
        Case i == 13 // {"8.2.1"   ,   , "��� �࣠��� ���譮� ������", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 6
          // case between(i, 28, 29) // {"8.2.2"   ,"�", "��� �࣠��� ९த�⨢��� ��⥬�", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          // k := 9
          // case i == 30 // {"13.1.1"  ,   , "�����ப�न�����", 0, 111,{110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202} }, ;
        Case i == 14 // {"13.1.1"  ,   , "�����ப�न�����", 0, 111,{110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202} }, ;
          k := 13
        Endcase
        AAdd( arr, { np_arr_issled[ i, 3 ], &mvard, &mvarr, i, k } )
      Endif
    Next
    // ������� "2.4.2" "�ਭ��� �� ������ ����.ࠧ����"
    i := count_pn_arr_osm  // ��᫥���� ����� ���ᨢ�
    mvart := "MTAB_NOMov" + lstr( i )
    mvard := "MDATEo" + lstr( i )
    If ( !Empty( ar[ 4 ] ) .and. AScan( ar[ 4 ], np_arr_osmotr[ i, 1 ] ) > 0 ) .and. !emptyany( &mvard, &mvart )
      AAdd( arr, { np_arr_osmotr[ i, 3 ], &mvard, "", i, 21 } )
    Endif
  Endif

  Return arr

// 25.11.13
Function f5_inf_dnl_karta( i )

  Local k := 0

  Do Case
  Case i == 14 // {"2.85.16","�", "�����-���������", 2, {1101} }, ;
    k := 11
  Case i == 15 // {"2.85.17","�", "���᪨� �஫��-���஫��", 19, {112603, 113502} }, ;
    k := 10
  Case i == 16 // {"2.85.18",   , "���᪨� ����", 20, {1135} }, ;
    k := 4
  Case i == 17 // {"2.85.19",   , "�ࠢ��⮫��-��⮯��", 100, {1123} }, ;
    k := 6
  Case i == 18 // {"2.85.20",   , "���஫��", 53, {1109} }, ;
    k := 2
  Case i == 19 // {"2.85.21",   , "��⠫쬮���", 65, {1112} }, ;
    k := 3
  Case i == 20 // {"2.85.22",   , "�⮫�ਭ�����", 64, {1111, 111101} }, ;
    k := 5
  Case i == 21 // {"2.85.23",   , "���᪨� �⮬�⮫��", 86, {140102} }, ;
    k := 8
  Case i == 22 // {"2.85.24",   , "���᪨� ���ਭ����", 21, {1127, 112702, 113402} }, ;
    k := 9
  Case i == 23 // {"2.4.1"  ,   , "��娠��", 72, {1115} };
    k := 7
  Endcase

  Return k

// 09.06.20 �ਫ������ � ����� ���� "������" �1025 �� 08.07.2019�.
Function f21_inf_dnl( par )

  Local arr_m, buf := save_maxrow(), lkod_h, lkod_k, rec, s, adbf, as, i, j, k, sh, HH := 40, n, n_file := cur_dir() + "svod_dnl.txt"

  If ( arr_m := year_month(,,, 5 ) ) != NIL
    If arr_m[ 1 ] < 2020
      Return func_error( 4, "������ �ଠ �⢥ত��� � 2020 ����" )
    Endif
    mywait()
    If f0_inf_dnl( arr_m, par > 1, par == 3, { 301, 302 } )
      r_use( dir_server() + "mo_rpdsh",, "RPDSH" )
      Index On Str( KOD_H, 7 ) to ( cur_dir() + "tmprpdsh" )
      adbf := { { "ti", "N", 1, 0 }, ;
        { "stroke", "C", 8, 0 }, ;
        { "mm", "N", 2, 0 }, ;
        { "mm1", "N", 1, 0 }, ;
        { "vsego", "N", 6, 0 }, ;
        { "vsego1", "N", 6, 0 }, ;
        { "vsegoM", "N", 6, 0 }, ;
        { "g1", "N", 6, 0 }, ;
        { "g2", "N", 6, 0 }, ;
        { "g3", "N", 6, 0 }, ;
        { "g4", "N", 6, 0 }, ;
        { "g4inv", "N", 6, 0 }, ;
        { "g5", "N", 6, 0 }, ;
        { "g5inv", "N", 6, 0 }, ;
        { "mg1", "N", 6, 0 }, ;
        { "mg2", "N", 6, 0 }, ;
        { "mg3", "N", 6, 0 }, ;
        { "mg4", "N", 6, 0 }, ;
        { "sv", "N", 6, 0 }, ;
        { "so", "N", 6, 0 }, ;
        { "v2", "N", 6, 0 }, ;
        { "m15", "N", 6, 0 }, ;
        { "m15s", "N", 6, 0 }, ;
        { "m15pos", "N", 6, 0 }, ;
        { "m15poss", "N", 6, 0 }, ;
        { "m15a", "N", 6, 0 }, ;
        { "m15p", "N", 6, 0 }, ;
        { "m15ps", "N", 6, 0 }, ;
        { "m15p1", "N", 6, 0 }, ;
        { "m15p1s", "N", 6, 0 }, ;
        { "m15e", "N", 6, 0 }, ;
        { "g15", "N", 6, 0 }, ;
        { "g15s", "N", 6, 0 }, ;
        { "g15pos", "N", 6, 0 }, ;
        { "g15poss", "N", 6, 0 }, ;
        { "g15g", "N", 6, 0 }, ;
        { "g15p", "N", 6, 0 }, ;
        { "g15ps", "N", 6, 0 }, ;
        { "g15p1", "N", 6, 0 }, ;
        { "g15p1s", "N", 6, 0 }, ;
        { "g15e", "N", 6, 0 }, ;
        { "g18", "N", 6, 0 }, ;
        { "g18s", "N", 6, 0 }, ;
        { "m18", "N", 6, 0 }, ;
        { "m18s", "N", 6, 0 } }

      dbCreate( cur_dir() + "tmp1", adbf )
      Use ( cur_dir() + "tmp1" ) new
      Index On Str( mm, 2 ) to ( cur_dir() + "tmp1" )
      Append Blank
      tmp1->mm := 0 ; tmp1->stroke := "�ᥣ�"
      Append Blank
      tmp1->mm := 1 ; tmp1->stroke := "0-14 ���"
      Append Blank
      tmp1->mm := 2 ; tmp1->stroke := "�� 1 �."
      Append Blank
      tmp1->mm := 3 ; tmp1->stroke := "15-17 �."
      Append Blank
      tmp1->mm := 4 ; tmp1->stroke := "15-17 �"
      Append Blank
      tmp1->mm := 5 ; tmp1->stroke := "誮�쭨��"
      adbf := { { "ti", "N", 1, 0 }, ;
        { "g1", "N", 6, 0 }, ;
        { "g2", "N", 6, 0 }, ;
        { "g3", "N", 6, 0 }, ;
        { "g31", "N", 6, 0 }, ;
        { "g32", "N", 6, 0 }, ;
        { "g4", "N", 6, 0 }, ;
        { "g5", "N", 6, 0 }, ;
        { "g6", "N", 6, 0 }, ;
        { "g7", "N", 6, 0 }, ;
        { "g8", "N", 6, 0 }, ;
        { "g9", "N", 6, 0 }, ;
        { "g10", "N", 6, 0 }, ;
        { "g11", "N", 6, 0 }, ;
        { "g12", "N", 6, 0 }, ;
        { "g13", "N", 6, 0 }, ;
        { "g14", "N", 6, 0 }, ;
        { "g15", "N", 6, 0 }, ;
        { "g7n", "N", 6, 0 }, ;
        { "g8n", "N", 6, 0 }, ;
        { "g12n", "N", 6, 0 }, ;
        { "g13n", "N", 6, 0 }, ;
        { "g14n", "N", 6, 0 }, ;
        { "g16n", "N", 6, 0 } }
      dbCreate( cur_dir() + "tmp2", adbf )
      Use ( cur_dir() + "tmp2" ) new
      Index On Str( ti, 1 ) to ( cur_dir() + "tmp2" )
      r_use( dir_server() + "mo_schoo",, "SCH" )
      r_use( dir_server() + "schet_",, "SCHET_" )
      r_use( dir_server() + "uslugi",, "USL" )
      r_use_base( "human_u" )
      r_use( dir_server() + "kartote_",, "KART_" )
      r_use( dir_server() + "human_",, "HUMAN_" )
      r_use( dir_server() + "human",, "HUMAN" )
      Set Relation To RecNo() into HUMAN_, To kod_k into KART_
      Use ( cur_dir() + "tmp" ) new
      Set Relation To kod into HUMAN
      Go Top
      Do While !Eof()
        @ MaxRow(), 0 Say Str( RecNo() / LastRec() * 100, 6, 2 ) + "%" Color cColorWait
        f1_f21_inf_dnl( tmp->kod, tmp->kod_k )
        Select TMP
        Skip
      Enddo
      Close databases
      arr_title := { ;
        "��������������������������������������������������������������������������������������������������������������������", ;
        "��⥣�- ���᫮ ��⥩ I�⠯���।������ �� ��㯯�� ���஢�� I �⠯ ����-�� �� ���.��㯯������砥� I�Ⳮ���.������", ;
        "ਨ     �����������������������������������������������������������������������������������������������Ĵ��   �訫� ", ;
        "��⥩   ��ᥣ�� ᥫ�����/��  1  �  2  �  3  �  4  �4���.�  5  �5���.��᭮��������ᯥ怳ᯥ恳��ॣ������2 ��.�2 ��.", ;
        "��������������������������������������������������������������������������������������������������������������������", ;
        "        �  5  � 5.1 �  6  �  7  �  8  �  9  �  10 � 10.1�  11 � 11.1�  12 �  13 �  14 �  15 �  16 �  17 �  18 �  19 ", ;
        "��������������������������������������������������������������������������������������������������������������������" }
      sh := Len( arr_title[ 1 ] )
      fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
      add_string( glob_mo[ _MO_SHORT_NAME ] )
      add_string( PadL( '�ਫ������ � ����� ���� "������"', sh ) )
      add_string( PadL( "�1025 �� 08.07.2019�.", sh ) )
      add_string( "" )
      add_string( Center( "[ " + CharRem( "~", mas1pmt[ par ] ) + " ]", sh ) )
      add_string( Center( "(" + arr_m[ 4 ] + ")", sh ) )
      Use ( cur_dir() + "tmp1" ) index ( cur_dir() + "tmp1" ) new
      add_string( "" )
      add_string( Center( "�������� � ��䨫����᪨� �ᬮ��� ��ᮢ��襭����⭨�", sh ) )
      add_string( "" )
      AEval( arr_title, {| x| add_string( x ) } )
      Go Top
      Do While !Eof()
        s := tmp1->stroke + put_val( tmp1->vsego, 6 ) + ;
          put_val( tmp1->vsego1, 6 ) + ;
          put_val( tmp1->vsegoM, 6 ) + ;
          put_val( tmp1->g1, 6 ) + ;
          put_val( tmp1->g2, 6 ) + ;
          put_val( tmp1->g3, 6 ) + ;
          put_val( tmp1->g4, 6 ) + ;
          put_val( tmp1->g4inv, 6 ) + ;
          put_val( tmp1->g5, 6 ) + ;
          put_val( tmp1->g5inv, 6 ) + ;
          put_val( tmp1->mg1, 6 ) + ;
          put_val( tmp1->mg2, 6 ) + ;
          put_val( tmp1->mg3, 6 ) + ;
          put_val( tmp1->mg4, 6 ) + ;
          put_val( tmp1->sv, 6 ) + ;
          put_val( tmp1->so, 6 ) + ;
          put_val( tmp1->v2, 6 ) + ;
          put_val( tmp1->v2, 6 )
        // put_val(tmp1->g31, 6)+;
        // put_val(tmp1->g32, 6)+;
        If verify_ff( HH -1, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( s )
        add_string( Replicate( "�", sh ) )
        Skip
      Enddo
      //
      verify_ff( HH -12, .t., sh )
/*    arr_title := {;
"��������������������������������������������������������������������������������", ;
"        �      ���� (15-17 ���)            �        ����誨 (15-17 ���)        ", ;
"        ������������������������������������������������������������������������", ;
"        �䠪� �ᬮ�.(祫.)���⮫� ��  �����.�䠪� �ᬮ�.(祫.)���⮫� ��  �����.", ;
"        �����������������Ĵ९�.� ��.6��� II�����������������Ĵ९�.� ��.6��� II", ;
"        ��ᥣ�� ᥫ�����ள���.� ᥫ���⠯ ��ᥣ�� ᥫ�����������.� ᥫ���⠯ ", ;
"��������������������������������������������������������������������������������", ;
"        �  3  �  4  �  5  �  6  �  7  �  8  �  3  �  4  �  5  �  6  �  7  �  8  ", ;
"��������������������������������������������������������������������������������"}*/
      arr_title := { ;
        "�����������������������������������������������������������������������������������������������������������������������������������������������", ;
        "            ���� (15-17 ���)                                          �                         ����誨 (15-17 ���)                           ", ;
        "�����������������������������������������������������������������������������������������������������������������������������������������������", ;
        "     䠪� �ᬮ�.(祫.)       ���⮫� ��  ��� 7 � ��  �����.�����.� ��  �      䠪� �ᬮ�.(祫.)      ���⮫� ��  ��� 14� ��  �����.�����.� ��  ", ;
        "����������������������������Ĵ९�.� ��.7�����-� 7.2 ��� II��� �.�  9  �����������������������������Ĵ९�.���.14�����-�14.2 ��� II��� �.� 18  ", ;
        "�ᥣ�� ᥫ������ ᥫ�����ள���.� ᥫ����  � ᥫ���⠯ ��� 7 � ᥫ���ᥣ�� ᥫ������ ᥫ�����������.� ᥫ����  � ᥫ���⠯ ��� 16� ᥫ�", ;
        "�����������������������������������������������������������������������������������������������������������������������������������������������", ;
        "  3  �  4  �  5  � 5.1 �  6  �  7  � 7.1 � 7.2 � 7.3 �  8  �  9  � 9.1 �  13 � 13.1�  14 � 14.1�  15 �  16 � 16.1� 16.2� 16.3� 17  � 18  � 18.1", ;
        "�����������������������������������������������������������������������������������������������������������������������������������������������" }
      sh := Len( arr_title[ 1 ] )
      i := 1
      add_string( "" )
      add_string( "��ᮢ��襭����⭨� � ������ 15-17 ���" )
      AEval( arr_title, {| x| add_string( x ) } )
      Go Top
      s :=   put_val( tmp1->m15, 5 ) + ;
        put_val( tmp1->m15s, 6 ) + ;
        put_val( tmp1->m15pos, 6 ) + ;
        put_val( tmp1->m15poss, 6 ) + ;
        put_val( tmp1->m15a, 6 ) + ;
        put_val( tmp1->m15p, 6 ) + ;
        put_val( tmp1->m15ps, 6 ) + ;
        put_val( tmp1->m15p1, 6 ) + ;
        put_val( tmp1->m15p1s, 6 ) + ;
        put_val( tmp1->m15e, 6 ) + ;
        put_val( tmp1->m18, 6 ) + ;
        put_val( tmp1->m18s, 6 ) + ;
        put_val( tmp1->g15, 6 ) + ;
        put_val( tmp1->g15s, 6 ) + ;
        put_val( tmp1->g15pos, 6 ) + ;
        put_val( tmp1->g15poss, 6 ) + ;
        put_val( tmp1->g15g, 6 ) + ;
        put_val( tmp1->g15p, 6 ) + ;
        put_val( tmp1->g15ps, 6 ) + ;
        put_val( tmp1->g15p1, 6 ) + ;
        put_val( tmp1->g15p1s, 6 ) + ;
        put_val( tmp1->g15e, 6 ) + ;
        put_val( tmp1->g18, 6 ) + ;
        put_val( tmp1->g18s, 6 )
      If verify_ff( HH -1, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( s )
      add_string( Replicate( "�", sh ) )
      //
      verify_ff( HH -12, .t., sh )
      arr_title := { ;
        "����������������������������������������������������������������������������������������������������������������������������������������", ;
        "         �    �ᬮ�७�    ��� ��� ᥫ�᪨� ���ᬮ-��ᬮ-�����-�                  �� ���                        �䠪�-��� �9��� �9���   ", ;
        "���⨭-  �����������������������������������Ĵ�७���७����  ������������������������������������������������Ĵ ��� �����볭��-���.20", ;
        "����     �     ���᫥�� �㡳     ���᫥�� �㡳�஫-�����-�����䳡�����     �  1�2 ��������������������������������᪠���   ��   �ᥫ�-", ;
        "         ��ᥣ��18:00����� ��ᥣ��18:00����� ����ள����-���樮��஢�� ��� � �⠤.��-��賣��� ������࣠���࣠������-����.����-�᪨� ", ;
        "         �     �     �     �     �     �     ����������  ���� �����     ��� �11�ᮥ�.��ਤ.����.���堭���饢���  �����.����  ���⥫", ;
        "����������������������������������������������������������������������������������������������������������������������������������������", ;
        "         �  1  �  2  �  3  �  4  �  5  �  6  �  7  �  8  �  9  � 10  �  11 �  12  �  13 �  14 �  15 �  16 �  17 �  18 �  19 �  20 �  21 ", ;
        "����������������������������������������������������������������������������������������������������������������������������������������" }
      // 1     2     3     4     5     6     7n    8n    7     8     9     0                        11    12          13    14    15
      sh := Len( arr_title[ 1 ] )
      add_string( "" )
      add_string( '� ࠬ��� ��樮���쭮�� �஥�� "��ࠢ���࠭����"' )
      AEval( arr_title, {| x| add_string( x ) } )
      Use ( cur_dir() + "tmp2" ) index ( cur_dir() + "tmp2" ) new
      Go Top
      Do While !Eof()
        s := PadR( { "0-14 ���", "15-17 ���", "�ᥣ�" }[ tmp2->ti ], 9 ) + ;
          put_val( tmp2->g1, 6 ) + ;
          put_val( tmp2->g2, 6 ) + ;
          put_val( tmp2->g3, 6 ) + ;
          put_val( tmp2->g4, 6 ) + ;
          put_val( tmp2->g5, 6 ) + ;
          put_val( tmp2->g6, 6 ) + ;
          put_val( tmp2->g7n, 6 ) + ;
          put_val( tmp2->g8n, 6 ) + ;
          put_val( tmp2->g7, 6 ) + ;
          put_val( tmp2->g8, 6 ) + ;
          put_val( tmp2->g9, 6 ) + ;
          put_val( 0, 7 ) + ;
          put_val( tmp2->g12n, 6 ) + ;
          put_val( tmp2->g13n, 6 ) + ;
          put_val( tmp2->g14n, 6 ) + ;
          put_val( tmp2->g11, 6 ) + ;
          put_val( tmp2->g12, 6 ) + ;
          put_val( tmp2->g16n, 6 ) + ;
          put_val( tmp2->g13, 6 ) + ;
          put_val( tmp2->g14, 6 ) + ;
          put_val( tmp2->g15, 6 )
        If verify_ff( HH -1, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( s )
        add_string( Replicate( "�", sh ) )
        Skip
      Enddo
      //
      FClose( fp )
      Close databases
      Private yes_albom := .t.
      viewtext( n_file,,,, ( .t. ),,, 3 )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 20.06.20
Function f1_f21_inf_dnl( Loc_kod, kod_kartotek ) // ᢮���� ���ଠ��

  Local ii, im, i, j, k, s, sumr := 0, ar := { 0 }, ltip_school := -1, ar15[ 26 ], ;
    is_2 := .f., ad := {}, arr, a3 := {}, fl_ves := .t.
  Private m1tip_school := -1, m1school := 0, mvozrast, mdvozrast, mgruppa := 0, m1GR_FIZ := 1, m1invalid1 := 0
  Private mvar, m1var, m1FIZ_RAZV1, m1napr_stac := 0

  AFill( ar15, 0 )
  mvozrast := count_years( human->date_r, human->n_data )
  mdvozrast := Year( human->n_data ) - Year( human->date_r )
  For i := 1 To 5
    For k := 1 To 16
      s := "diag_16_" + lstr( i ) + "_" + lstr( k )
      mvar := "m" + s
      If k == 1
        Private &mvar := Space( 6 )
      Else
        m1var := "m1" + s
        Private &m1var := 0
        Private &mvar := Space( 3 )
      Endif
    Next
  Next
  ii := 1
  is_2 := ( human->ishod == 302 ) // �� ��ன �⠯
  read_arr_pn( Loc_kod )
  If human->pol == "�"
    If m1napr_stac > 0
      ar15[ 23 ] ++
      If f_is_selo()
        ar15[ 24 ] ++
      Endif
    Endif
  Else
    If m1napr_stac > 0
      ar15[ 25 ] ++
      If f_is_selo()
        ar15[ 26 ] ++
      Endif
    Endif
  Endif
  //
  mGRUPPA := human_->RSLT_NEW - 331// L_BEGIN_RSLT
  If mvozrast == 0
    AAdd( ar, 2 )
  Endif
  If mdvozrast < 15
    AAdd( ar, 1 )
  Else
    AAdd( ar, 3 )
    If human->pol == "�"
      AAdd( ar, 4 )
    Endif
  Endif
  If mdvozrast > 6 // 誮�쭨�� ?
    AAdd( ar, 5 )
  Endif
  If m1school > 0
    Select SCH
    Goto ( m1school )
    ltip_school := sch->tip
  Endif
  For i := 1 To 5
    j := 0
    For k := 1 To 16
      s := "diag_16_" + lstr( i ) + "_" + lstr( k )
      mvar := "m" + s
      If k == 1
        If !Empty( &mvar )
          arr := Array( 16 ) ; AFill( arr, 0 ) ; arr[ 1 ] := AllTrim( &mvar )
          If Len( arr[ 1 ] ) > 5
            arr[ 1 ] := Left( arr[ 1 ], 5 )
          Endif
          AAdd( ad, arr ) ; j := Len( ad )
        Endif
      Elseif j > 0
        m1var := "m1" + s
        ad[ j, k ] := &m1var
      Endif
    Next
  Next
  //
  arr := Array( 24 ) ; AFill( arr, 0 ) ; arr[ 16 ] := 3
  arr[ 1 ] := 1
  If ( is_selo := f_is_selo() )
    arr[ 4 ] := 1
  Endif
  If DoW( human->k_data ) == 7 // �㡡��
    arr[ 3 ] := 1
    If is_selo
      arr[ 6 ] := 1
    Endif
  Endif

  For i := 1 To Len( ad )
    If !( Left( ad[ i, 1 ], 1 ) == "A" .or. Left( ad[ i, 1 ], 1 ) == "B" ) .and. ad[ i, 2 ] > 0 // ����䥪樮��� ����������� ���.�����
      arr[ 7 ] ++
      If Left( ad[ i, 1 ], 1 ) == "I" // ������� ��⥬� �஢����饭��
        arr[ 8 ] ++
      Elseif Left( ad[ i, 1 ], 1 ) == "J" // ������� �࣠��� ��堭��
        arr[ 11 ] ++
      Elseif Left( ad[ i, 1 ], 1 ) == "K" // ������� �࣠��� ��饢�७��
        arr[ 12 ] ++
      Elseif Left( ad[ i, 1 ], 1 ) == "M" // ������� ���⭮-���筮� ��⥬�
        arr[ 19 ] ++
      Elseif Left( ad[ i, 1 ], 1 ) == "H" // ������� ����
        arr[ 20 ] ++
      Elseif Left( ad[ i, 1 ], 1 ) == "E" // ������� ���ਭ������
        arr[ 21 ] ++
      Endif
      If Left( ad[ i, 1 ], 3 ) == "E78"
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == "R73.9"
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == "Z72.0"
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == "Z72.4"
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == "R63.5"
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == "Z72.3"
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == "Z72.1"
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == "Z72.2"
        arr[ 22 ] ++
        fl_ves := .f.
      Endif
      // ���� ������ ����� ⥫�
      If Left( ad[ i, 1 ], 1 ) == "C" .or. Between( Left( ad[ i, 1 ], 3 ), "D00", "D09" ) // ��� ����� ���� ��������  .or. between(left(ad[i, 1], 3),"D45","D47")
        arr[ 9 ] ++
      Endif
      // ��������
      If ad[ i, 3 ] == 2 // ���.����.��⠭������ �����
        arr[ 13 ] ++
      Endif
      If ad[ i, 10 ] == 1 // 1-��祭�� �����祭�
        arr[ 14 ] ++    // ?? �뫮 ���� ��祭��
        If is_selo
          arr[ 15 ] ++
        Endif
      Endif
    Endif
  Next
  AAdd( a3, AClone( arr ) )
  If Between( mdvozrast, 15, 17 )
    arr[ 16 ] := 2
    j := iif( human->pol == "�", 1, 7 )
    ar15[ j ] ++
    If is_selo
      ar15[ j + 1 ] ++
    Endif
    If ( i := AScan( ad, {| x| Left( x[ 1 ], 1 ) == "N" } ) ) > 0 // ��⮫���� �࣠��� ९த�⨢��� ��⥬�
      ar15[ j + 3 ] ++
      If is_selo
        ar15[ j + 4 ] ++
      Endif
      If ad[ i, 2 ] > 0 // ����������� ���.�����
        If is_2
          ar15[ j + 5 ] ++
        Endif
        If j == 1
          ar15[ 13 ] ++
          If is_selo
            ar15[ 14 ] ++
          Endif
        Else
          ar15[ 15 ] ++
          If is_selo
            ar15[ 16 ] ++
          Endif
        Endif
      Endif
    Endif

    fl := .f.
    Select HU
    find ( Str( Loc_kod, 7 ) )
    Do While hu->kod == Loc_kod .and. !Eof()
      If eq_any( hu_->PROFIL, 19, 136 )
        fl := .t.
      Endif
      usl->( dbGoto( hu->u_kod ) )
      If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
        lshifr := usl->shifr
      Endif
      If Left( lshifr, 2 ) == "2."  // ��祡�� ���
        If Left( lshifr, 4 ) != "2.91"  // �� �����業�� ������㥬
          If j == 1
            ar15[ 17 ] ++
            If is_selo
              ar15[ 18 ] ++
            Endif
          Else
            ar15[ 19 ] ++
            If is_selo
              ar15[ 20 ] ++
            Endif
          Endif
          // mydebug(,human->fio)
          If hu_->PROFIL == 19
            arr[ 17 ] ++
          Endif
          If hu_->PROFIL == 136
            arr[ 18 ] ++
            // mydebug(,"2------------------------------------------")
          Endif
        Endif
      Endif
      Select HU
      Skip
    Enddo
    If fl
      ar15[ j + 2 ] ++
    Endif
  Else
    arr[ 16 ] := 1
  Endif
  AAdd( a3, AClone( arr ) )
  //
  // aadd(arr,{"12.4.1",m1FIZ_RAZV1})  // "N",䨧��᪮� ࠧ��⨥ 0-��ଠ�쭮�, � �⪫�����ﬨ: 1-����� ����� ⥫�, 2-����⮪ ����� ⥫�, 3-������ ���, 4-��᮪�� ���
  If m1fiz_razv1 == 1
    If fl_ves
      arr[ 22 ] ++
    Endif
  Endif
  //
  For j := 1 To Len( a3 )
    Select TMP2
    find ( Str( a3[ j, 16 ], 1 ) )
    If !Found()
      Append Blank
      tmp2->ti := a3[ j, 16 ]
    Endif
    For i := 1 To 15
      pole := "tmp2->g" + lstr( i )
      &pole := &pole + a3[ j, i ]
    Next
    tmp2->g7n  := tmp2->g7n  + arr[ 17 ]
    tmp2->g8n  := tmp2->g8n  + arr[ 18 ]
    tmp2->g12n := tmp2->g12n + arr[ 19 ]
    tmp2->g13n := tmp2->g13n + arr[ 20 ]
    tmp2->g14n := tmp2->g14n + arr[ 21 ]
    tmp2->g16n := tmp2->g16n + arr[ 22 ]
  Next
  //
  For j := 1 To Len( ar )
    im := ar[ j ]
    Select TMP1
    find ( Str( im, 2 ) )
    tmp1->vsego++
    If is_selo
      tmp1->vsego1++
    Endif
    tmp1->m15  += ar15[ 1 ]
    tmp1->m15s += ar15[ 2 ]
    tmp1->m15pos += ar15[ 17 ]
    tmp1->m15poss += ar15[ 18 ]
    tmp1->m15a += ar15[ 3 ]
    tmp1->m15p += ar15[ 4 ]
    tmp1->m15ps += ar15[ 5 ]
    tmp1->m15p1 += ar15[ 13 ]
    tmp1->m15p1s += ar15[ 14 ]
    tmp1->m15e += ar15[ 6 ] // 2-� �⠯
    tmp1->g15  += ar15[ 7 ]
    tmp1->g15s += ar15[ 8 ]
    tmp1->g15pos += ar15[ 19 ]
    tmp1->g15poss += ar15[ 20 ]
    tmp1->g15g += ar15[ 9 ]
    tmp1->g15p += ar15[ 10 ]
    tmp1->g15ps += ar15[ 11 ]
    tmp1->g15p1 += ar15[ 15 ]
    tmp1->g15p1s += ar15[ 16 ]
    tmp1->g15e += ar15[ 12 ] // 2-� �⠯
    tmp1->g18 += ar15[ 23 ]
    tmp1->g18s += ar15[ 24 ]
    tmp1->m18 += ar15[ 25 ]
    tmp1->m18s += ar15[ 26 ]
    If Between( mgruppa, 1, 5 )
      pole := "tmp1->g" + lstr( mgruppa )
      &pole := &pole + 1
      If Between( mgruppa, 4, 5 ) .and. m1invalid1 == 1 // ������������-��
        pole += "inv"
        &pole := &pole + 1
      Endif
      If /*ltip_school == 0 .and.*/ between(m1GR_FIZ, 1, 4)
        pole := "tmp1->mg" + lstr( m1GR_FIZ )
        &pole := &pole + 1
      Endif
      If is_2 // I � II �⠯
        tmp1->v2++
      Endif
    Endif
    If human->schet > 0
      Select SCHET_
      Goto ( human->schet )
      If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // ⮫쪮 ��ॣ����஢����
        tmp1->sv++
        sumr := 0
        Select RPDSH
        find ( Str( Loc_kod, 7 ) )
        Do While rpdsh->KOD_H == Loc_kod .and. !Eof()
          sumr += rpdsh->S_SL
          Skip
        Enddo
        If Round( human->cena_1, 2 ) == Round( sumr, 2 ) // ��������� ����祭
          tmp1->so++
        Endif
      Endif
    Endif
  Next

  Return Nil

// 25.03.18
Function inf_dnl_030poo( is_schet )

  Local arr_m, i, n, buf := save_maxrow(), lkod_h, lkod_k, rec, sh := 80, HH := 80, n_file := cur_dir() + "f_030poo.txt", d1, d2

  If ( arr_m := year_month( T_ROW, T_COL -5 ) ) != NIL
    If arr_m[ 1 ] < 2018
      Return func_error( 4, "������ �ଠ �⢥ত��� � 2018 ����" )
    Endif
    mywait()
    If f0_inf_dnl( arr_m, is_schet > 1, is_schet == 3 )
      Private arr_deti[ 6 ] ; AFill( arr_deti, 0 )
      Private s12_1 := 0, s12_1m := 0, s12_2 := 0, s12_2m := 0
      Private arr_vozrast := { ;
        { 3, 0, 17 };
        }
      Private arr1vozrast := { ;
        { 0, 17 }, ;
        { 0, 4 }, ;
        { 0, 14 }, ;
        { 5, 9 }, ;
        { 10, 14 }, ;
        { 15, 17 };
        }
      Private arr_4 := { ;
        { "1", "������� ��䥪樮��� � ��ࠧ��...", "A00-B99",, }, ;
        { "1.1", "�㡥�㫥�", "A15-A19",, }, ;
        { "1.2", "���-��䥪��, ����", "B20-B24",, }, ;
        { "2", "������ࠧ������", "C00-D48",, }, ;
        { "3", "������� �஢� � �஢�⢮��� �࣠��� ...", "D50-D89",, }, ;
        { "3.1", "������", "D50-D53",, }, ;
        { "4", "������� ���ਭ��� ��⥬�, ����ன�⢠...", "E00-E90",, }, ;
        { "4.1", "���� ������", "E10-E14",, }, ;
        { "4.2", "�������筮��� ��⠭��", "E40-E46",, }, ;
        { "4.3", "���७��", "E66",, }, ;
        { "4.4", "����প� �������� ࠧ����", "E30.0",, }, ;
        { "4.5", "�०���६����� ������� ࠧ��⨥", "E30.1",, }, ;
        { "5", "����᪨� ����ன�⢠ � �����...", "F00-F99",, }, ;
        { "5.1", "��⢥���� ���⠫����", "F70-F79",, }, ;
        { "6", "������� ��ࢭ�� ��⥬�, �� ���:", "G00-G98",, }, ;
        { "6.1", "�ॡࠫ�� ��ࠫ�� � ��㣨� ...", "G80-G83",, }, ;
        { "7", "������� ����� � ��� �ਤ��筮�� ������", "H00-H59",, }, ;
        { "8", "������� �� � ��楢������ ����⪠", "H60-H95",, }, ;
        { "9", "������� ��⥬� �஢����饭��", "I00-I99",, }, ;
        { "10", "������� �࣠��� ��堭��, �� ���:", "J00-J99",, }, ;
        { "10.1", "��⬠, ��⬠��᪨� �����", "J45-J46",, }, ;
        { "11", "������� �࣠��� ��饢�७��", "K00-K93",, }, ;
        { "12", "������� ���� � ��������� �����⪨", "L00-L99",, }, ;
        { "13", "������� ���⭮-���筮� ...", "M00-M99",, }, ;
        { "13.1", "��䮧, ��म�, ᪮����", "M40-M41",, }, ;
        { "14", "������� ��祯������ ��⥬�, �� ���:", "N00-N99",, }, ;
        { "14.1", "������� ��᪨� ������� �࣠���", "N40-N51",, }, ;
        { "14.2", "����襭�� �⬠ � �ࠪ�� �������権", "N91-N94.5",, }, ;
        { "14.3", "��ᯠ��⥫�� ����������� ...", "N70-N77",, }, ;
        { "14.4", "����ᯠ��⥫�� ������� ...", "N83",, }, ;
        { "14.5", "������� ����筮� ������", "N60-N64",, }, ;
        { "15", "�⤥��� ���ﭨ�, �������...", "P00-P96",, }, ;
        { "16", "�஦����� �������� (��ப� ...", "Q00-Q99",, }, ;
        { "16.1", "ࠧ���� ��ࢭ�� ��⥬�", "Q00-Q07",, }, ;
        { "16.2", "��⥬� �஢����饭��", "Q20-Q28",, }, ;
        { "16.3", "���᪨� ������� �࣠���", "Q50-Q52",, }, ;
        { "16.4", "��᪨� ������� �࣠���", "Q53-Q55",, }, ;
        { "16.5", "���⭮-���筮� ��⥬�", "Q65-Q79",, }, ;
        { "17", "�ࠢ��, ��ࠢ����� � �������...", "S00-T98",, }, ;
        { "18", "��稥", "",, }, ;
        { "19", "����� �����������", "A00-T98",, };
        }
      For n := 1 To Len( arr_4 )
        If "-" $ arr_4[ n, 3 ]
          d1 := Token( arr_4[ n, 3 ], "-", 1 )
          d2 := Token( arr_4[ n, 3 ], "-", 2 )
        Else
          d1 := d2 := arr_4[ n, 3 ]
        Endif
        arr_4[ n, 4 ] := diag_to_num( d1, 1 )
        arr_4[ n, 5 ] := diag_to_num( d2, 2 )
      Next
      dbCreate( cur_dir() + "tmp4", { { "name", "C", 100, 0 }, ;
        { "diagnoz", "C", 20, 0 }, ;
        { "stroke", "C", 4, 0 }, ;
        { "ns", "N", 2, 0 }, ;
        { "diapazon1", "N", 10, 0 }, ;
        { "diapazon2", "N", 10, 0 }, ;
        { "tbl", "N", 1, 0 }, ;
        { "k04", "N", 8, 0 }, ;
        { "k05", "N", 8, 0 }, ;
        { "k06", "N", 8, 0 }, ;
        { "k07", "N", 8, 0 }, ;
        { "k08", "N", 8, 0 }, ;
        { "k09", "N", 8, 0 }, ;
        { "k10", "N", 8, 0 }, ;
        { "k11", "N", 8, 0 } } )
      Use ( cur_dir() + "tmp4" ) New Alias TMP
      For i := 1 To Len( arr_vozrast )
        For n := 1 To Len( arr_4 )
          Append Blank
          tmp->tbl := arr_vozrast[ i, 1 ]
          tmp->stroke := arr_4[ n, 1 ]
          tmp->name := arr_4[ n, 2 ]
          tmp->ns := n
          tmp->diagnoz := arr_4[ n, 3 ]
          tmp->diapazon1 := arr_4[ n, 4 ]
          tmp->diapazon2 := arr_4[ n, 5 ]
        Next
      Next
      Index On Str( tbl, 1 ) + Str( ns, 2 ) to ( cur_dir() + "tmp4" )
      Use
      dbCreate( cur_dir() + "tmp10", { { "voz", "N", 1, 0 }, ;
        { "tbl", "N", 2, 0 }, ;
        { "tip", "N", 2, 0 }, ;
        { "kol", "N", 6, 0 } } )
      Use ( cur_dir() + "tmp10" ) New Alias TMP10
      Index On Str( voz, 1 ) + Str( tbl, 1 ) + Str( tip, 2 ) to ( cur_dir() + "tmp10" )
      Use
      Copy File ( cur_dir() + "tmp10" + sdbf() ) to ( cur_dir() + "tmp11" + sdbf() )
      Use ( cur_dir() + "tmp11" ) New Alias TMP11
      Index On Str( voz, 1 ) + Str( tbl, 2 ) + Str( tip, 2 ) to ( cur_dir() + "tmp11" )
      Use
      dbCreate( cur_dir() + "tmp13", { { "voz", "N", 1, 0 }, ;
        { "tip", "N", 2, 0 }, ;
        { "kol", "N", 6, 0 } } )
      Use ( cur_dir() + "tmp13" ) New Alias TMP13
      Index On Str( voz, 1 ) + Str( tip, 2 ) to ( cur_dir() + "tmp13" )
      Use
      dbCreate( cur_dir() + "tmp16", { { "voz", "N", 1, 0 }, ;
        { "man", "N", 1, 0 }, ;
        { "tip", "N", 2, 0 }, ;
        { "kol", "N", 6, 0 } } )
      Use ( cur_dir() + "tmp16" ) New Alias TMP16
      Index On Str( voz, 1 ) + Str( man, 1 ) + Str( tip, 2 ) to ( cur_dir() + "tmp16" )
      Use
      dbCloseAll()
      Use ( cur_dir() + "tmp4" )  index ( cur_dir() + "tmp4" )  new
      Use ( cur_dir() + "tmp10" ) index ( cur_dir() + "tmp10" ) new
      Use ( cur_dir() + "tmp11" ) index ( cur_dir() + "tmp11" ) new
      Use ( cur_dir() + "tmp13" ) index ( cur_dir() + "tmp13" ) new
      Use ( cur_dir() + "tmp16" ) index ( cur_dir() + "tmp16" ) new
      r_use( dir_server() + "human_",, "HUMAN_" )
      r_use( dir_server() + "human",, "HUMAN" )
      Set Relation To RecNo() into HUMAN_
      r_use( cur_dir() + "tmp" )
      Set Relation To kod into HUMAN
      ii := 0
      mywait( " " )
      Go Top
      Do While !Eof()
        @ MaxRow(), 0 Say PadR( Str( ++ii / tmp->( LastRec() ) * 100, 6, 2 ) + "%  " + AllTrim( human->fio ) + "  " + full_date( human->date_r ), 80 ) Color cColorWait
        f2_inf_dnl_030poo( human->kod, human->kod_k )
        Select TMP
        Skip
      Enddo
      Close databases
      //
      fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
      add_string( glob_mo[ _MO_SHORT_NAME ] )
      add_string( PadL( "�ਫ������ 3", sh ) )
      add_string( PadL( "� �ਪ��� ����", sh ) )
      add_string( PadL( "�514� �� 10.08.2017�.", sh ) )
      add_string( "" )
      add_string( PadL( "��ଠ ������᪮� ���⭮�� � 030-��/�-17", sh ) )
      add_string( "" )
      add_string( Center( "�������� � ��䨫����᪨� ����樭᪨� �ᬮ��� ��ᮢ��襭����⭨�", sh ) )
      add_string( Center( "[ " + CharRem( "~", mas1pmt[ is_schet ] ) + " ]", sh ) )
      add_string( Center( arr_m[ 4 ], sh ) )
      add_string( "" )
      add_string( "2. ��᫮ ��⥩, ��襤�� ���ᬮ��� � ���⭮� ��ਮ��:" )
      add_string( "  2.1. �ᥣ� � ������ �� 0 �� 17 ��� �����⥫쭮:" + Str( arr_deti[ 1 ], 6 ) + " (祫����), �� ���:" )
      add_string( "  2.1.1. � ������ �� 0 �� 4 ��� �����⥫쭮      " + Str( arr_deti[ 2 ], 6 ) + " (祫����)," )
      add_string( "  2.1.2. � ������ �� 0 �� 14 ��� �����⥫쭮     " + Str( arr_deti[ 2 ] + arr_deti[ 3 ] + arr_deti[ 4 ], 6 ) + " (祫����)," )
      add_string( "  2.1.3. � ������ �� 5 �� 9 ��� �����⥫쭮      " + Str( arr_deti[ 3 ], 6 ) + " (祫����)," )
      add_string( "  2.1.4. � ������ �� 10 �� 14 ��� �����⥫쭮    " + Str( arr_deti[ 4 ], 6 ) + " (祫����)," )
      add_string( "  2.1.5. � ������ �� 15 �� 17 ��� �����⥫쭮    " + Str( arr_deti[ 5 ], 6 ) + " (祫����)," )
      add_string( "  2.1.6. ��⥩-��������� �� 0 �� 17 ��� �����⥫쭮" + Str( arr_deti[ 6 ], 6 ) + " (祫����)." )
      For i := 1 To Len( arr_vozrast )
        verify_ff( HH -50, .t., sh )
        add_string( "" )
        add_string( Center( lstr( arr_vozrast[ i, 1 ] ) + ;
          ". ������� ������� ������������ (���ﭨ�) � ��⥩ � ������ �� " + ;
          lstr( arr_vozrast[ i, 2 ] ) + " �� " + lstr( arr_vozrast[ i, 3 ] ) + " ��� �����⥫쭮", sh ) )
        add_string( "��������������������������������������������������������������������������������" )
        add_string( " �� �    ������������   � ��� ����ᥣ��� �.糢��-�� �.糑��⮨� ��� ���.�����" )
        add_string( " �� �    �����������    � ���-10���ॣ�����-����� �����-������������������������" )
        add_string( "    �                   �       �������稪� ����ࢳ稪� ��ᥣ������糢��⮳�����" )
        add_string( "��������������������������������������������������������������������������������" )
        add_string( " 1  �          2        �   3   �  4  �  5  �  6  �  7  �  8  �  9  � 10  � 11  " )
        add_string( "��������������������������������������������������������������������������������" )
        Use ( cur_dir() + "tmp4" ) index ( cur_dir() + "tmp4" ) New Alias TMP
        find ( Str( arr_vozrast[ i, 1 ], 1 ) )
        Do While tmp->tbl == arr_vozrast[ i, 1 ] .and. !Eof()
          s := tmp->stroke + " " + PadR( tmp->name, 19 ) + " " + PadC( AllTrim( tmp->diagnoz ), 7 )
          For n := 4 To 11
            s += put_val( tmp->&( "k" + StrZero( n, 2 ) ), 6 )
          Next
          add_string( s )
          Skip
        Enddo
        Use
        add_string( Replicate( "�", sh ) )
      Next
      arr1title := { ;
        "��������������������������������������������������������������������������������", ;
        "                    �   �ᥣ�   �   � ��    �   � ���   �� 䥤�ࠫ�-� � ����� ", ;
        "  ������ ��⥩     �           �           ���ꥪ� ���  ��� ���  �    ��     ", ;
        "                    �           �           �           �           �           ", ;
        "��������������������������������������������������������������������������������", ;
        "          1         �     2     �     3     �     4     �     5     �     6     ", ;
        "��������������������������������������������������������������������������������" }
      arr2title := { ;
        "��������������������������������������������������������������������������������", ;
        "                    �   �ᥣ�   �� �㭨�.�� �   � ���   �� 䥤�ࠫ�-� � ����� ", ;
        "  ������ ��⥩     �����������������������Ĵ��ꥪ� ����ĭ�� ���������Č������", ;
        "                    � ���.�  %  � ���.�  %  � ���.�  %  � ���.�  %  � ���.�  %  ", ;
        "��������������������������������������������������������������������������������", ;
        "          1         �  2  �  3  �  4  �  5  �  6  �  7  �  8  �  9  �  10 �  11 ", ;
        "��������������������������������������������������������������������������������" }
      arr3title := { ;
        "��������������������������������������������������������������������������������", ;
        " ������   �ᥣ�   �   � ��    �   � ���   �� 䥤�ࠫ�-� � ����� �� ᠭ��୮", ;
        " ��⥩  �           �           ���ꥪ� ���  ��� ���  �    ��     �-������� ", ;
        "        �           �           �           �           �           ��࣠���-�� ", ;
        "��������������������������������������������������������������������������������", ;
        "    1   �     2     �     3     �     4     �     5     �     6     �     7     ", ;
        "��������������������������������������������������������������������������������" }
      arr4title := { ;
        "��������������������������������������������������������������������������������", ;
        " ������   �ᥣ�   �� �㭨�.�� �   � ���   �� 䥤�ࠫ�-� � ����� �� ᠭ.-���.", ;
        " ��⥩  �����������������������Ĵ��ꥪ� ����ĭ�� ���������Č��������Į�-�����", ;
        "        � ���.�  %  � ���.�  %  � ���.�  %  � ���.�  %  � ���.�  %  � ���.�  %  ", ;
        "��������������������������������������������������������������������������������", ;
        "    1   �  2  �  3  �  4  �  5  �  6  �  7  �  8  �  9  �  10 �  11 �  12 �  13 ", ;
        "��������������������������������������������������������������������������������" }
      verify_ff( HH -50, .t., sh )
      add_string( "4. �������� �������⥫��� �������権, ��᫥�������, ��祭��, ����樭᪮�" )
      add_string( "   ॠ�����樨 ��⥩ �� १���⠬ �஢������ ��䨫����᪨� �ᬮ�஢:" )
      Use ( cur_dir() + "tmp10" ) index ( cur_dir() + "tmp10" ) New Alias TMP10
      For i := 1 To 2
        verify_ff( HH -16, .t., sh )
        add_string( "" )
        s := Space( 5 )
        If i == 1
          add_string( s + "4.1. �������⥫�� �������樨 � (���) ��᫥�������" )
        Else
          add_string( s + "4.2. ��祭��, ����樭᪠� ॠ������� � ᠭ��୮-����⭮� ��祭��" )
        Endif
        n := 20
        If eq_any( i, 1, 3, 5, 6, 7 )
          AEval( arr1title, {| x| add_string( x ) } )
        Elseif eq_any( i, 2, 4 )
          AEval( arr2title, {| x| add_string( x ) } )
        Else
          AEval( arr3title, {| x| add_string( x ) } )
          n := 8
        Endif
        For j := 1 To Len( arr1vozrast )
          s := PadC( lstr( arr1vozrast[ j, 1 ] ) + " - " + lstr( arr1vozrast[ j, 2 ] ), n )
          skol := oldkol := 0
          s1 := ""
          For k := 1 To iif( i == 8, 5, 4 )
            find ( Str( j, 1 ) + Str( i, 1 ) + Str( k, 1 ) )
            If Found() .and. ( v := tmp10->kol ) > 0
              skol += v
              If eq_any( i, 2, 4 )
                s1 += Str( v, 6 )
                find ( Str( j, 1 ) + Str( i -1, 1 ) + Str( k, 1 ) )
                If Found() .and. tmp10->kol > 0
                  s1 += " " + umest_val( v / tmp10->kol * 100, 5, 2 )
                  oldkol += tmp10->kol
                Else
                  s1 += Space( 6 )
                Endif
              Else
                s1 += " " + PadC( lstr( v ), 11 )
              Endif
            Else
              s1 += Space( 12 )
            Endif
          Next
          If skol > 0
            If eq_any( i, 2, 4 )
              s += Str( skol, 6 ) + " " + umest_val( skol / oldkol * 100, 5, 2 )
            Else
              s += " " + PadC( lstr( skol ), 11 )
            Endif
            add_string( s + s1 )
          Else
            add_string( s )
          Endif
        Next
        add_string( Replicate( "�", sh ) )
      Next
      Use
      //
      // verify_FF(HH-50, .t., sh)
      // add_string("11. �������� ��祭��, ����樭᪮� ॠ�����樨 � (���) ᠭ��୮-����⭮��")
      // add_string("    ��祭�� ��⥩ �� �஢������ �����饣� ��䨫����᪮�� �ᬮ��:")
      vkol := 0
      Use ( cur_dir() + "tmp11" ) index ( cur_dir() + "tmp11" ) New Alias TMP11
      For i := 1 To 0// 12
        If i % 3 > 0
          verify_ff( HH -16, .t., sh )
          add_string( "" )
        Endif
        s := Space( 5 )
        If i == 1
          add_string( s + "11.1. ������������� ��祭�� � ���㫠���� �᫮���� � � �᫮����" )
          add_string( s + "      �������� ��樮���" )
        Elseif i == 2
          add_string( s + "11.2. �஢����� ��祭�� � ���㫠���� �᫮���� � � �᫮����" )
          add_string( s + "      �������� ��樮���" )
        Elseif i == 3
          add_string( s + "11.3. ��稭� ���믮������ ४������権 �� ��祭�� � ���㫠���� �᫮����" )
          add_string( s + "      � � �᫮���� �������� ��樮���:" )
          add_string( s + "        11.3.1. �� ��諨 �ᥣ� " + lstr( vkol ) + " (祫����)" )
        Elseif i == 4
          add_string( s + "11.4. ������������� ��祭�� � ��樮����� �᫮����" )
        Elseif i == 5
          add_string( s + "11.5. �஢����� ��祭�� � ��樮����� �᫮����" )
        Elseif i == 6
          add_string( s + "11.6. ��稭� ���믮������ ४������権 �� ��祭�� � ��樮����� �᫮����:" )
          add_string( s + "        11.6.1. �� ��諨 �ᥣ� " + lstr( vkol ) + " (祫����)" )
        Elseif i == 7
          add_string( s + "11.7. ������������� ����樭᪠� ॠ�������" )
          add_string( s + "      � ���㫠���� �᫮���� � � �᫮���� �������� ��樮���" )
        Elseif i == 8
          add_string( s + "11.8. �஢����� ����樭᪠� ॠ�������" )
          add_string( s + "      � ���㫠���� �᫮���� � � �᫮���� �������� ��樮���" )
        Elseif i == 9
          add_string( s + "11.9. ��稭� ���믮������ ४������権 �� ����樭᪮� ॠ�����樨" )
          add_string( s + "      � ���㫠���� �᫮���� � � �᫮���� �������� ��樮���:" )
          add_string( s + "        11.9.1. �� ��諨 �ᥣ� " + lstr( vkol ) + " (祫����)" )
        Elseif i == 10
          add_string( s + "11.10. ������������� ����樭᪠� ॠ������� � (���)" )
          add_string( s + "       ᠭ��୮-����⭮� ��祭�� � ��樮����� �᫮����" )
        Elseif i == 11
          add_string( s + "11.11. �஢����� ����樭᪠� ॠ������� � (���)" )
          add_string( s + "       ᠭ��୮-����⭮� ��祭�� � ��樮����� �᫮����" )
        Else
          add_string( s + "11.12. ��稭� ���믮������ ४������権 �� ����樭᪮� ॠ�����樨" )
          add_string( s + "       � (���) ᠭ��୮-����⭮�� ��祭�� � ��樮����� �᫮����:" )
          add_string( s + "         11.12.1. �� ��諨 �ᥣ� " + lstr( vkol ) + " (祫����)" )
        Endif
        If i % 3 > 0
          n := 20
          If eq_any( i, 1, 4, 7 )
            AEval( arr1title, {| x| add_string( x ) } )
          Elseif eq_any( i, 2, 5, 8 )
            AEval( arr2title, {| x| add_string( x ) } )
          Elseif i == 10
            AEval( arr3title, {| x| add_string( x ) } )
            n := 8
          Elseif i == 11
            AEval( arr4title, {| x| add_string( x ) } )
            n := 8
          Endif
          For j := 1 To Len( arr1vozrast )
            s := PadC( lstr( arr1vozrast[ j, 1 ] ) + " - " + lstr( arr1vozrast[ j, 2 ] ), n )
            skol := oldkol := 0
            s1 := ""
            For k := 1 To iif( i > 10, 5, 4 )
              find ( Str( j, 1 ) + Str( i, 2 ) + Str( k, 1 ) )
              If Found() .and. ( v := tmp11->kol ) > 0
                skol += v
                If eq_any( i, 2, 5, 8, 11 )
                  s1 += Str( v, 6 )
                  find ( Str( j, 1 ) + Str( i -1, 2 ) + Str( k, 1 ) )
                  If Found() .and. tmp11->kol > 0
                    s1 += " " + umest_val( v / tmp11->kol * 100, 5, 2 )
                    oldkol += tmp11->kol
                  Else
                    s1 += Space( 6 )
                  Endif
                Else
                  s1 += " " + PadC( lstr( v ), 11 )
                Endif
              Else
                s1 += Space( 12 )
              Endif
            Next
            If eq_any( i, 2, 5, 8, 11 )
              vkol := oldkol - skol
            Endif
            If skol > 0
              If eq_any( i, 2, 5, 8, 11 )
                s += Str( skol, 6 ) + " " + umest_val( skol / oldkol * 100, 5, 2 )
              Else
                s += " " + PadC( lstr( skol ), 11 )
              Endif
              add_string( s + s1 )
            Else
              add_string( s )
            Endif
          Next
          add_string( Replicate( "�", sh ) )
        Endif
      Next
      Use
      Use ( cur_dir() + "tmp16" ) index ( cur_dir() + "tmp16" ) New Alias TMP16
      verify_ff( HH -21, .t., sh )
      n := 20
      add_string( "" )
      add_string( "5. ��᫮ ��⥩ �� �஢�� 䨧��᪮�� ࠧ����" )
      add_string( "��������������������������������������������������������������������������������" )
      add_string( "                    ���᫮ �ள���.䨧.� ����襭�� 䨧��᪮�� ࠧ���� (祫.) " )
      add_string( "    ������ ��⥩   �襤��   �ࠧ��⨥ ����������������������������������������" )
      add_string( "                    ����.��.�   祫.  �����.��᳨����.��᳭���.��Ⳣ��.���" )
      add_string( "��������������������������������������������������������������������������������" )
      add_string( "          1         �    2    �    3    �    4    �    5    �    6    �    7    " )
      add_string( "��������������������������������������������������������������������������������" )
      For j := 1 To Len( arr1vozrast )
        For k := 0 To 1
          s := PadR( " " + lstr( arr1vozrast[ j, 1 ] ) + " - " + lstr( arr1vozrast[ j, 2 ] ) + ;
            iif( k == 0, "", " (����稪�)" ), n )
          find ( Str( j, 1 ) + Str( k, 1 ) + Str( 0, 2 ) )
          If Found()
            s += " " + PadC( lstr( tmp16->kol ), 9 )
          Else
            s += Space( 10 )
          Endif
          For i := 1 To 5
            find ( Str( j, 1 ) + Str( k, 1 ) + Str( i, 2 ) )
            If Found()
              s += " " + PadC( lstr( tmp16->kol ), 9 )
            Else
              s += Space( 10 )
            Endif
          Next
          add_string( s )
        Next
      Next
      add_string( Replicate( "�", sh ) )
      verify_ff( HH -21, .t., sh )
      n := 20
      add_string( "" )
      add_string( "6. ��᫮ ��⥩ �� ����樭᪨� ��㯯�� ��� ����⨩ 䨧��᪮� �����ன" )
      add_string( "��������������������������������������������������������������������������������" )
      add_string( "                    ���᫮ �ள    �� ���.�ᬮ��     � �� १���⠬ ���.��" )
      add_string( "    ������ ��⥩   �襤��   ��������������������������������������������������" )
      add_string( "                    ����.��.� I  � II � III� IV ��� �� I  � II � III� IV ��� �" )
      add_string( "��������������������������������������������������������������������������������" )
      add_string( "          1         �    2    � 3  � 4  � 5  � 6  � 7  � 8  � 9  � 10 � 11 � 12 " )
      add_string( "��������������������������������������������������������������������������������" )
      For j := 1 To Len( arr1vozrast )
        For k := 0 To 1
          s := PadR( " " + lstr( arr1vozrast[ j, 1 ] ) + " - " + lstr( arr1vozrast[ j, 2 ] ) + ;
            iif( k == 0, "", " (����稪�)" ), n )
          find ( Str( j, 1 ) + Str( k, 1 ) + Str( 0, 2 ) )
          If Found()
            s += " " + PadC( lstr( tmp16->kol ), 9 )
          Else
            s += Space( 10 )
          Endif
          For i := 31 To 35
            find ( Str( j, 1 ) + Str( k, 1 ) + Str( i, 2 ) )
            s += put_val( tmp16->kol, 5 )
          Next
          For i := 41 To 45
            find ( Str( j, 1 ) + Str( k, 1 ) + Str( i, 2 ) )
            s += put_val( tmp16->kol, 5 )
          Next
          add_string( s )
        Next
      Next
      verify_ff( HH -21, .t., sh )
      n := 20
      add_string( "" )
      add_string( "7. ��᫮ ��⥩ �� ��㯯�� ���஢��" )
      add_string( "��������������������������������������������������������������������������������" )
      add_string( "                    ���᫮ �ள    �� ���.�ᬮ��     � �� १���⠬ ���.��" )
      add_string( "    ������ ��⥩   �襤��   ��������������������������������������������������" )
      add_string( "                    ����.��.� I  � II � III� IV � V  � I  � II � III� IV � V  " )
      add_string( "��������������������������������������������������������������������������������" )
      add_string( "          1         �    2    � 3  � 4  � 5  � 6  � 7  � 8  � 9  � 10 � 11 � 12 " )
      add_string( "��������������������������������������������������������������������������������" )
      For j := 1 To Len( arr1vozrast )
        For k := 0 To 1
          s := PadR( " " + lstr( arr1vozrast[ j, 1 ] ) + " - " + lstr( arr1vozrast[ j, 2 ] ) + ;
            iif( k == 0, "", " (����稪�)" ), n )
          find ( Str( j, 1 ) + Str( k, 1 ) + Str( 0, 2 ) )
          If Found()
            s += " " + PadC( lstr( tmp16->kol ), 9 )
          Else
            s += Space( 10 )
          Endif
          For i := 11 To 15
            find ( Str( j, 1 ) + Str( k, 1 ) + Str( i, 2 ) )
            s += put_val( tmp16->kol, 5 )
          Next
          For i := 21 To 25
            find ( Str( j, 1 ) + Str( k, 1 ) + Str( i, 2 ) )
            s += put_val( tmp16->kol, 5 )
          Next
          add_string( s )
        Next
      Next
      add_string( Replicate( "�", sh ) )
      FClose( fp )
      viewtext( n_file,,,, .t.,,, 5 )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 14.07.19
Function f2_inf_dnl_030poo( Loc_kod, kod_kartotek ) // ᢮���� ���ଠ��

  Local i, j, k, av := {}, av1 := {}, ad := {}, arr, s, fl, ;
    is_man := ( human->pol == "�" ), blk_tbl, blk_tip, blk_put_tip, a10[ 9 ], a11[ 13 ]

  blk_tbl := {| _k| iif( _k < 2, 1, 2 ) }
  blk_tip := {| _k| iif( _k == 0, 2, iif( _k > 1, _k + 1, _k ) ) }
  blk_put_tip := {| _e, _k| iif( _k > _e, _k, _e ) }
  Private metap := 1, mperiod := 0, mshifr_zs := "", m1lis := 0, ;
    mkateg_uch, m1kateg_uch := 3, ; // ��⥣��� ��� ॡ����:
    mMO_PR := Space( 10 ), m1MO_PR := Space( 6 ), ; // ��� �� �ਪ९�����
    mschool := Space( 10 ), m1school := 0, ; // ��� ���.��०�����
    mWEIGHT := 0, ;   // ��� � ��
    mHEIGHT := 0, ;   // ��� � �
    mPER_HEAD := 0, ; // ���㦭���� ������ � �
    mfiz_razv, m1FIZ_RAZV := 0, ; // 䨧��᪮� ࠧ��⨥
    mfiz_razv1, m1FIZ_RAZV1 := 0, ; // �⪫������ ����� ⥫�
    mfiz_razv2, m1FIZ_RAZV2 := 0, ; // �⪫������ ���
    m1psih11 := 0, ;  // �������⥫쭠� �㭪�� (������ ࠧ����)
    m1psih12 := 0, ;  // ���ୠ� �㭪�� (������ ࠧ����)
    m1psih13 := 0, ;  // �樮���쭠� � �樠�쭠� (���⠪� � ���㦠�騬 ��஬) �㭪樨 (������ ࠧ����)
    m1psih14 := 0, ;  // �।�祢�� � �祢�� ࠧ��⨥ (������ ࠧ����)
    mpsih21, m1psih21 := 0, ;  // ��宬��ୠ� ���: (��ଠ, �⪫������)
    mpsih22, m1psih22 := 0, ;  // ��⥫����: (��ଠ, �⪫������)
    mpsih23, m1psih23 := 0, ;  // ���樮���쭮-�����⨢��� ���: (��ଠ, �⪫������)
    m141p   := 0, ; // ������� ��㫠 ����稪� P
    m141ax  := 0, ; // ������� ��㫠 ����稪� Ax
    m141fa  := 0, ; // ������� ��㫠 ����稪� Fa
    m142p   := 0, ; // ������� ��㫠 ����窨 P
    m142ax  := 0, ; // ������� ��㫠 ����窨 Ax
    m142ma  := 0, ; // ������� ��㫠 ����窨 Ma
    m142me  := 0, ; // ������� ��㫠 ����窨 Me
    m142me1 := 0, ; // ������� ��㫠 ����窨 - menarhe (���)
    m142me2 := 0, ; // ������� ��㫠 ����窨 - menarhe (����楢)
    m142me3, m1142me3 := 0, ; // ������� ��㫠 ����窨 - menses (�ࠪ���⨪�):
    m142me4, m1142me4 := 1, ; // ������� ��㫠 ����窨 - menses (�ࠪ���⨪�):
    m142me5, m1142me5 := 1, ; // ������� ��㫠 ����窨 - menses (�ࠪ���⨪�):
    mdiag_15_1, m1diag_15_1 := 1, ; // ����ﭨ� ���஢�� �� �஢������ ���ᬮ��-�ࠪ��᪨ ���஢
    mdiag_15[ 5, 14 ], ; //
    mGRUPPA_DO := 0, ; // ��㯯� ���஢�� �� ���-��
    mGR_FIZ_DO, m1GR_FIZ_DO := 1, ;
    mdiag_16_1, m1diag_16_1 := 1, ; // ����ﭨ� ���஢�� �� १���⠬ �஢������ ���ᬮ�� (�ࠪ��᪨ ���஢)
    mdiag_16[ 5, 16 ], ; //
    minvalid[ 8 ], ;  // ࠧ��� 16.7
    mGRUPPA := 0, ;    // ��㯯� ���஢�� ��᫥ ���-��
    mGR_FIZ, m1GR_FIZ := 1, ;
    mPRIVIVKI[ 3 ], ; // �஢������ ��䨫����᪨� �ਢ����
    mrek_form := Space( 255 ), ; // "C100",���������樨 �� �ନ஢���� ���஢��� ��ࠧ� �����, ०��� ���, ��⠭��, 䨧��᪮�� ࠧ����, ���㭮��䨫��⨪�, ������ 䨧��᪮� �����ன
    mrek_disp := Space( 255 ), ; // "C100",���������樨 �� ��ᯠ��୮�� �������, ��祭��, ����樭᪮� ॠ�����樨 � ᠭ��୮-����⭮�� ��祭�� � 㪠������ �������� (��� ���), ���� ����樭᪮� �࣠����樨 � ᯥ樠�쭮�� (��������) ���
    mhormon := "0 ��.", m1hormon := 1, not_hormon, ;
    mstep2, m1step2 := 0
  Private minvalid1, m1invalid1 := 0, ;
    minvalid2, m1invalid2 := 0, ;
    minvalid3 := CToD( "" ), minvalid4 := CToD( "" ), ;
    minvalid5, m1invalid5 := 0, ;
    minvalid6, m1invalid6 := 0, ;
    minvalid7 := CToD( "" ), ;
    minvalid8, m1invalid8 := 0
  Private mprivivki1, m1privivki1 := 0, ;
    mprivivki2, m1privivki2 := 0, ;
    mprivivki3 := Space( 100 )
  Private mvar, m1var, m1lis := 0
  //
  For i := 1 To 5
    For k := 1 To 14
      s := "diag_15_" + lstr( i ) + "_" + lstr( k )
      mvar := "m" + s
      If k == 1
        Private &mvar := Space( 6 )
      Else
        m1var := "m1" + s
        Private &m1var := 0
        Private &mvar := Space( 4 )
      Endif
    Next
  Next
  //
  For i := 1 To 5
    For k := 1 To 16
      s := "diag_16_" + lstr( i ) + "_" + lstr( k )
      mvar := "m" + s
      If k == 1
        Private &mvar := Space( 6 )
      Else
        m1var := "m1" + s
        Private &m1var := 0
        Private &mvar := Space( 3 )
      Endif
    Next
  Next
  mvozrast := count_years( human->date_r, human->n_data )
  If !Between( mvozrast, 0, 17 )
    mvozrast := 17
  Endif
  mdvozrast := Year( human->n_data ) - Year( human->date_r )
  If !Between( mdvozrast, 0, 17 )
    mdvozrast := 17
  Endif
  read_arr_pn( Loc_kod )
  arr_deti[ 1 ] ++
  If mdvozrast < 5
    arr_deti[ 2 ] ++
  Elseif mdvozrast < 10
    arr_deti[ 3 ] ++
  Elseif mdvozrast < 15
    arr_deti[ 4 ] ++
  Else
    arr_deti[ 5 ] ++
  Endif
  For i := 1 To Len( arr_vozrast )
    If Between( mdvozrast, arr_vozrast[ i, 2 ], arr_vozrast[ i, 3 ] )
      AAdd( av, arr_vozrast[ i, 1 ] ) // ᯨ᮪ ⠡��� � 4 �� 9
    Endif
  Next
  For i := 1 To Len( arr1vozrast )
    If Between( mdvozrast, arr1vozrast[ i, 1 ], arr1vozrast[ i, 2 ] )
      AAdd( av1, i )
    Endif
  Next
  For i := 1 To 5
    j := 0
    For k := 1 To 16
      s := "diag_16_" + lstr( i ) + "_" + lstr( k )
      mvar := "m" + s
      If k == 1
        If !Empty( &mvar )
          arr := Array( 16 ) ; AFill( arr, 0 ) ; arr[ 1 ] := AllTrim( &mvar )
          If Len( arr[ 1 ] ) > 5
            arr[ 1 ] := Left( arr[ 1 ], 5 )
          Endif
          AAdd( ad, arr ) ; j := Len( ad )
        Endif
      Elseif j > 0
        m1var := "m1" + s
        ad[ j, k ] := &m1var
      Endif
    Next
  Next
  AFill( a10, 0 )
  For i := 1 To Len( ad ) // 横� �� ���������
    au := {}
    d := diag_to_num( ad[ i, 1 ], 1 )
    For n := 1 To Len( arr_4 )
      If !Empty( arr_4[ n, 3 ] ) .and. Between( d, arr_4[ n, 4 ], arr_4[ n, 5 ] )
        AAdd( au, n )
      Endif
    Next
    If Len( au ) == 1
      AAdd( au, Len( arr_4 ) -1 )  // {"18","��稥","",,}, ;
    Endif
    Select TMP4
    For n := 1 To Len( av ) // 横� �� ᯨ�� ⠡��� � 4 �� 9
      For j := 1 To Len( au )
        find ( Str( av[ n ], 1 ) + Str( au[ j ], 2 ) )
        If Found()
          tmp4->k04++
          If is_man
            tmp4->k05++
          Endif
          If ad[ i, 2 ] > 0 // ���.�����
            tmp4->k06++
            If is_man
              tmp4->k07++
            Endif
          Endif
          If ad[ i, 3 ] > 0 // ���.����.��⠭������
            tmp4->k08++
            If is_man
              tmp4->k09++
            Endif
            If ad[ i, 3 ] == 2 // ���.����.��⠭������ �����
              tmp4->k10++
              If is_man
                tmp4->k11++
              Endif
            Endif
          Endif
        Endif
      Next
    Next
    If ad[ i, 4 ] == 1 // 1-���.����.�����祭�
      ntbl := Eval( blk_tbl, ad[ i, 5 ] )
      ntip := Eval( blk_tip, ad[ i, 6 ] )
      If ntbl == 1 .and. a10[ 3 ] > 0 // 㦥 ���� ��樮���
        //
      Elseif ntbl == 2
        a10[ 1 ] := 0
        a10[ 3 ] := Eval( blk_put_tip, a10[ 3 ], ntip )
      Else
        a10[ 1 ] := Eval( blk_put_tip, a10[ 1 ], ntip )
        a10[ 3 ] := 0
      Endif
    Endif
    If ad[ i, 7 ] == 1 // 1-���.����.�믮�����
      ntbl := Eval( blk_tbl, ad[ i, 8 ] )
      ntip := Eval( blk_tip, ad[ i, 9 ] )
      If ntbl == 1 .and. a10[ 4 ] > 0 // 㦥 ���� ��樮���
        //
      Elseif ntbl == 2
        a10[ 2 ] := 0
        a10[ 4 ] := Eval( blk_put_tip, a10[ 4 ], ntip )
      Else
        a10[ 2 ] := Eval( blk_put_tip, a10[ 2 ], ntip )
        a10[ 4 ] := 0
      Endif
    Endif
    If ad[ i, 10 ] == 1 // 1-��祭�� �����祭�
      ntbl := Eval( blk_tbl, ad[ i, 11 ] )
      ntip := Eval( blk_tip, ad[ i, 12 ] )
      If ntbl == 1 .and. a10[ 6 ] > 0 // 㦥 ���� ��樮���
        //
      Elseif ntbl == 2
        a10[ 5 ] := 0
        a10[ 6 ] := Eval( blk_put_tip, a10[ 6 ], ntip )
      Else
        a10[ 5 ] := Eval( blk_put_tip, a10[ 5 ], ntip )
        a10[ 6 ] := 0
      Endif
    Endif
    If ad[ i, 13 ] == 1 // 1-ॠ���.�����祭�
      ntbl := Eval( blk_tbl, ad[ i, 14 ] )
      ntip := Eval( blk_tip, ad[ i, 15 ] )
      If ntbl == 1 .and. a10[ 8 ] > 0 // 㦥 ���� ��樮���
        //
      Elseif ntbl == 2 .or. ntip == 5 // ��� ᠭ��਩
        a10[ 7 ] := 0
        a10[ 8 ] := Eval( blk_put_tip, a10[ 8 ], ntip )
      Else
        a10[ 7 ] := Eval( blk_put_tip, a10[ 7 ], ntip )
        a10[ 8 ] := 0
      Endif
    Endif
    If ad[ i, 16 ] == 1 // 1-��� �����祭�
      a10[ 9 ] := 1
    Endif
  Next
  Select TMP10
  For n := 1 To Len( av1 ) // 横� �� �����⠬ ⠡��� 10
    For j := 1 To Len( a10 ) -1
      If a10[ j ] > 0
        find ( Str( av1[ n ], 1 ) + Str( j, 1 ) + Str( a10[ j ], 2 ) )
        If !Found()
          Append Blank
          tmp10->voz := av1[ n ]
          tmp10->tbl := j
          tmp10->tip := a10[ j ]
        Endif
        tmp10->kol++
      Endif
    Next
  Next
  ad := {}
  For i := 1 To 5
    j := 0
    For k := 1 To 14
      s := "diag_15_" + lstr( i ) + "_" + lstr( k )
      mvar := "m" + s
      If k == 1
        If !Empty( &mvar )
          arr := Array( 14 ) ; AFill( arr, 0 ) ; arr[ 1 ] := AllTrim( &mvar )
          If Len( arr[ 1 ] ) > 5
            arr[ 1 ] := Left( arr[ 1 ], 5 )
          Endif
          AAdd( ad, arr ) ; j := Len( ad )
        Endif
      Elseif j > 0
        m1var := "m1" + s
        ad[ j, k ] := &m1var
      Endif
    Next
  Next
  AFill( a11, 0 )
  For i := 1 To Len( ad ) // 横� �� ���������
    If ad[ i, 3 ] == 1 // 1-��祭�� �����祭�
      ntbl := Eval( blk_tbl, ad[ i, 4 ] )
      ntip := Eval( blk_tip, ad[ i, 5 ] )
      If ntbl == 1 .and. a11[ 4 ] > 0 // 㦥 ���� ��樮���
        //
      Elseif ntbl == 2
        a11[ 1 ] := 0
        a11[ 4 ] := Eval( blk_put_tip, a11[ 4 ], ntip )
      Else
        a11[ 1 ] := Eval( blk_put_tip, a11[ 1 ], ntip )
        a11[ 4 ] := 0
      Endif
      // ��祭�� �믮�����
      ntbl := Eval( blk_tbl, ad[ i, 6 ] )
      ntip := Eval( blk_tip, ad[ i, 7 ] )
      If ntbl == 1 .and. a11[ 5 ] > 0 // 㦥 ���� ��樮���
        //
      Elseif ntbl == 2
        a11[ 2 ] := 0
        a11[ 5 ] := Eval( blk_put_tip, a11[ 5 ], ntip )
      Else
        a11[ 2 ] := Eval( blk_put_tip, a11[ 2 ], ntip )
        a11[ 5 ] := 0
      Endif
    Endif
    If ad[ i, 8 ] == 1 // 1-ॠ���.�����祭�
      ntbl := Eval( blk_tbl, ad[ i, 9 ] )
      ntip := Eval( blk_tip, ad[ i, 10 ] )
      If ntbl == 1 .and. a11[ 10 ] > 0 // 㦥 ���� ��樮���
        //
      Elseif ntbl == 2
        a11[ 7 ] := 0
        a11[ 10 ] := Eval( blk_put_tip, a11[ 10 ], ntip )
      Else
        a11[ 7 ] := Eval( blk_put_tip, a11[ 7 ], ntip )
        a11[ 10 ] := 0
      Endif
      // 1-ॠ���.�믮�����
      ntbl := Eval( blk_tbl, ad[ i, 11 ] )
      ntip := Eval( blk_tip, ad[ i, 12 ] )
      If ntbl == 1 .and. a11[ 11 ] > 0 // 㦥 ���� ��樮���
        //
      Elseif ntbl == 2 .or. ntip == 5 // ��� ᠭ��਩
        a11[ 8 ] := 0
        a11[ 11 ] := Eval( blk_put_tip, a11[ 11 ], ntip )
      Else
        a11[ 8 ] := Eval( blk_put_tip, a11[ 8 ], ntip )
        a11[ 11 ] := 0
      Endif
    Endif
    If ad[ i, 14 ] == 1 // 1-��� �஢�����
      a11[ 13 ] := 1
    Endif
  Next
  Select TMP11
  For n := 1 To Len( av1 ) // 横� �� �����⠬ ⠡��� 10
    For j := 1 To Len( a11 ) -1
      If a11[ j ] > 0
        find ( Str( av1[ n ], 1 ) + Str( j, 2 ) + Str( a11[ j ], 2 ) )
        If !Found()
          Append Blank
          tmp11->voz := av1[ n ]
          tmp11->tbl := j
          tmp11->tip := a11[ j ]
        Endif
        tmp11->kol++
      Endif
    Next
  Next
  If a10[ 9 ] > 0
    s12_1++
    If is_man
      s12_1m++
    Endif
  Endif
  If a11[ 13 ] > 0
    s12_2++
    If is_man
      s12_2m++
    Endif
  Endif
  ad := { 0 }
  If m1invalid1 == 1 // ������������-��
    arr_deti[ 6 ] ++
    AAdd( ad, 4 )
    If m1invalid2 == 0 // � ஦�����
      AAdd( ad, 1 )
    Else               // �ਮ��⥭���
      AAdd( ad, 2 )
      If !Empty( minvalid3 ) .and. minvalid3 >= human->n_data
        AAdd( ad, 3 )
      Endif
    Endif
    If !Empty( minvalid7 ) // ��� �����祭�� ���.�ணࠬ�� ॠ�����樨
      AAdd( ad, 10 )
      Do Case // �믮������
      Case m1invalid8 == 1 // ���������, 1
        AAdd( ad, 11 )
      Case m1invalid8 == 2 // ���筮, 2
        AAdd( ad, 12 )
      Case m1invalid8 == 3 // ����, 3
        AAdd( ad, 13 )
      Otherwise            // �� �믮�����, 0
        AAdd( ad, 14 )
      Endcase
    Endif
  Endif
  If m1privivki1 == 1     // �� �ਢ�� �� ����樭᪨� ���������", 1}, ;
    If m1privivki2 == 1
      AAdd( ad, 21 )
    Else
      AAdd( ad, 22 )
    Endif
  Elseif m1privivki1 == 2 // �� �ਢ�� �� ��㣨� ��稭��", 2}}
    If m1privivki2 == 1
      AAdd( ad, 23 )
    Else
      AAdd( ad, 24 )
    Endif
  Else                    // �ਢ�� �� �������", 0}, ;
    AAdd( ad, 20 )
  Endif
  Select TMP13
  For n := 1 To Len( av1 ) // 横� �� �����⠬ ⠡����
    For j := 1 To Len( ad )
      find ( Str( av1[ n ], 1 ) + Str( ad[ j ], 2 ) )
      If !Found()
        Append Blank
        tmp13->voz := av1[ n ]
        tmp13->tip := ad[ j ]
      Endif
      tmp13->kol++
    Next
  Next
  ad := { 0 }
  If m1fiz_razv == 0
    AAdd( ad, 1 )
  Else
    If m1fiz_razv1 == 1
      AAdd( ad, 2 )
    Elseif m1fiz_razv1 == 2
      AAdd( ad, 3 )
    Endif
    If m1fiz_razv2 == 1
      AAdd( ad, 4 )
    Elseif m1fiz_razv2 == 2
      AAdd( ad, 5 )
    Endif
  Endif
  mGRUPPA := human_->RSLT_NEW - 331 // L_BEGIN_RSLT
  If !Between( mgruppa, 1, 5 )
    mgruppa := 1
  Endif
  If !Between( mgruppa_do, 1, 5 )
    mgruppa_do := 1
  Endif
  If !Between( m1GR_FIZ, 0, 4 )
    m1GR_FIZ := 1
  Endif
  If !Between( m1GR_FIZ_DO, 0, 4 )
    m1GR_FIZ_DO := 1
  Endif
  AAdd( ad, mGRUPPA_DO + 10 )
  AAdd( ad, mGRUPPA + 20 )
  AAdd( ad, iif( m1GR_FIZ_DO == 0, 35, m1GR_FIZ_DO + 30 ) )
  AAdd( ad, iif( m1GR_FIZ == 0, 45, m1GR_FIZ + 40 ) )
  Select TMP16
  For n := 1 To Len( av1 ) // 横� �� �����⠬ ⠡����
    For j := 1 To Len( ad )
      find ( Str( av1[ n ], 1 ) + "0" + Str( ad[ j ], 2 ) )
      If !Found()
        Append Blank
        tmp16->voz := av1[ n ]
        tmp16->tip := ad[ j ]
      Endif
      tmp16->kol++
      If is_man
        find ( Str( av1[ n ], 1 ) + "1" + Str( ad[ j ], 2 ) )
        If !Found()
          Append Blank
          tmp16->voz := av1[ n ]
          tmp16->man := 1
          tmp16->tip := ad[ j ]
        Endif
        tmp16->kol++
      Endif
    Next
  Next

  Return Nil

// 11.03.19
Function inf_dnl_xmlfile( is_schet, stitle )

  Local arr_m, n, buf := save_maxrow(), lkod_h, lkod_k, rec, blk, t_arr[ BR_LEN ], arr, n_func

  If ( arr_m := year_month( T_ROW, T_COL -5 ) ) != NIL
    mywait()
    Do Case
    Case p_tip_lu == TIP_LU_PN
      arr := { 301, 302 } // ��䨫��⨪� 1 � 2 �⠯
    Case p_tip_lu == TIP_LU_PREDN
      arr := { 303, 304 } // �।.�ᬮ��� 1 � 2 �⠯
    Case p_tip_lu == TIP_LU_PERN
      arr := { 305 } // ��ਮ�.�ᬮ���
    Endcase
    If f0_inf_dnl( arr_m, is_schet > 1, is_schet == 3, arr, .t. )
      Copy File ( cur_dir() + "tmp" + sdbf() ) to ( cur_dir() + "tmpDNL" + sdbf() ) // �.�. ����� ⮦� ���� TMP-䠩�
      r_use( dir_server() + "human",, "HUMAN" )
      Use ( cur_dir() + "tmpDNL" ) new
      Set Relation To kod into HUMAN
      Index On Upper( human->fio ) to ( cur_dir() + "tmpDNL" )
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + "human_",, "HUMAN_" ), ;
        r_use( dir_server() + "human",, "HUMAN" ), ;
        dbSetRelation( "HUMAN_", {|| RecNo() }, "recno()" ), ;
        e_use( cur_dir() + "tmpDNL", cur_dir() + "tmpDNL", "TMP" ), ;
        dbSetRelation( "HUMAN", {|| kod }, "kod" );
        }
      Eval( blk_open )
      Go Top
      t_arr[ BR_TOP ] := 2
      t_arr[ BR_BOTTOM ] := 23
      t_arr[ BR_LEFT ] := 0
      t_arr[ BR_RIGHT ] := 79
      stitle := "XML-���⠫: " + stitle + " ��ᮢ��襭����⭨� "
      t_arr[ BR_TITUL ] := stitle + arr_m[ 4 ]
      t_arr[ BR_TITUL_COLOR ] := "B/BG"
      t_arr[ BR_COLOR ] := color0
      t_arr[ BR_ARR_BROWSE ] := { '�', '�', '�', "N/BG,W+/N,B/BG,W+/B", .t. }
      blk := {|| iif( tmp->is == 1, { 1, 2 }, { 3, 4 } ) }
      t_arr[ BR_COLUMN ] := { { " ", {|| iif( tmp->is == 1, "", " " ) }, blk }, ;
        { " �.�.�.", {|| PadR( human->fio, 37 ) }, blk }, ;
        { "��� ஦�.", {|| full_date( human->date_r ) }, blk }, ;
        { "� ��.�����", {|| human->uch_doc }, blk }, ;
        { "�ப� ���-�", {|| Left( date_8( human->n_data ), 5 ) + "-" + Left( date_8( human->k_data ), 5 ) }, blk }, ;
        { "�⠯", {|| iif( eq_any( human->ishod, 301, 303, 305 ), " I  ", "I-II" ) }, blk } }
      t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ - ��室 ��� ᮧ����� 䠩��;  ^<+,-,Ins>^ - �⬥���/���� �⬥�� � ��樥��" ) }
      t_arr[ BR_EDIT ] := {| nk, ob| f1_inf_n_xmlfile( nk, ob, "edit" ) }
      edit_browse( t_arr )
      Select TMP
      Delete For is == 0
      Pack
      n := LastRec()
      Close databases
      rest_box( buf )
      If n == 0 .or. !f_esc_enter( "��⠢����� XML-䠩��" )
        Return Nil
      Endif
      mywait()
      r_use( dir_server() + "mo_rpdsh",, "RPDSH" )
      Index On Str( KOD_H, 7 ) to ( cur_dir() + "tmprpdsh" )
      Use
      r_use( dir_server() + "mo_raksh",, "RAKSH" )
      Index On Str( KOD_H, 7 ) to ( cur_dir() + "tmpraksh" )
      Use
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + "human_",, "HUMAN_" ), ;
        r_use( dir_server() + "human",, "HUMAN" ), ;
        dbSetRelation( "HUMAN_", {|| RecNo() }, "recno()" ), ;
        e_use( cur_dir() + "tmpDNL", cur_dir() + "tmpDNL", "TMP" ), ;
        dbSetRelation( "HUMAN", {|| kod }, "kod" );
        }
      mo_mzxml_n( 1 )
      n := 0
      Do While .t.
        ++n
        Eval( blk_open )
        If rec == NIL
          Go Top
        Else
          Goto ( rec )
          Skip
          If Eof()
            Exit
          Endif
        Endif
        rec := tmp->( RecNo() )
        @ MaxRow(), 0 Say PadR( Str( n / tmp->( LastRec() ) * 100, 6, 2 ) + "%" + " " + ;
          RTrim( human->fio ) + " " + date_8( human->n_data ) + "-" + ;
          date_8( human->k_data ), 80 ) Color cColorWait
        lkod_h := human->kod
        lkod_k := human->kod_k
        Close databases
        n_func := "f2_inf_N_XMLfile"
        Do Case
        Case p_tip_lu == TIP_LU_PN
          oms_sluch_pn( lkod_h, lkod_k, n_func ) // ��䨫��⨪� 1 � 2 �⠯
        Case p_tip_lu == TIP_LU_PREDN
          oms_sluch_predn( lkod_h, lkod_k, n_func ) // �।.�ᬮ��� 1 � 2 �⠯
        Case p_tip_lu == TIP_LU_PERN
          oms_sluch_pern( lkod_h, lkod_k, n_func ) // ��ਮ�.�ᬮ���
        Endcase
      Enddo
      Close databases
      rest_box( buf )
      mo_mzxml_n( 3, "tmp", stitle )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 22.11.13
Function f1_inf_n_xmlfile( nKey, oBrow, regim )

  Local ret := -1, rec := tmp->( RecNo() )

  If regim == "edit"
    Do Case
    Case nkey == K_INS
      tmp->is := iif( tmp->is == 1, 0, 1 )
      ret := 0
      Keyboard Chr( K_TAB )
    Case nkey == 43  // +
      tmp->( dbEval( {|| tmp->is := 1 } ) )
      Goto ( rec )
      ret := 0
    Case nkey == 45  // -
      tmp->( dbEval( {|| tmp->is := 0 } ) )
      Goto ( rec )
      ret := 0
    Endcase
  Endif

  Return ret

// 22.11.13 �� ����� ���� ��ᮢ��襭����⭥�� ᮧ���� ���� XML-䠩��
Function f2_inf_n_xmlfile( Loc_kod, kod_kartotek, lvozrast )

  Local adbf, s, i, j, k, y, m, d, fl

  r_use( dir_server() + "kartote_",, "KART_" )
  Goto ( kod_kartotek )
  r_use( dir_server() + "kartotek",, "KART" )
  Goto ( kod_kartotek )
  r_use( dir_server() + "human_",, "HUMAN_" )
  Goto ( Loc_kod )
  r_use( dir_server() + "human",, "HUMAN" )
  Goto ( Loc_kod )
  r_use( dir_server() + "mo_pers",, "P2" )
  Goto ( m1vrach )
  r_use( dir_server() + "organiz",, "ORG" )
  r_use( dir_server() + "mo_rpdsh", cur_dir() + "tmprpdsh", "RPDSH" )
  r_use( dir_server() + "mo_raksh", cur_dir() + "tmpraksh", "RAKSH" )
  mo_mzxml_n( 2,,, lvozrast )

  Return Nil

// 25.11.13
Function f4_inf_predn_karta( par, _etap )

  Local i, k, fl, arr := {}, ar := npred_arr_1_etap[ mperiod ]

  If par == 1
    If iif( _etap == nil, .t., _etap == 1 )
      For i := 1 To count_predn_arr_osm
        mvart := "MTAB_NOMov" + lstr( i )
        mvard := "MDATEo" + lstr( i )
        fl := .t.
        If fl .and. !Empty( npred_arr_osmotr[ i, 2 ] )
          fl := ( mpol == npred_arr_osmotr[ i, 2 ] )
        Endif
        If fl
          fl := ( !Empty( ar[ 4 ] ) .and. AScan( ar[ 4 ], npred_arr_osmotr[ i, 1 ] ) > 0 )
        Endif
        If fl .and. !emptyany( &mvard, &mvart )
          AAdd( arr, { npred_arr_osmotr[ i, 3 ], &mvard, "", i, f5_inf_dnl_karta( i ) } )
        Endif
      Next
    Endif
    AAdd( arr, { "������� (��� ��饩 �ࠪ⨪�)", MDATEp1, "", -1, 1 } )
    If metap == 2 .and. iif( _etap == nil, .t., _etap == 2 )
      For i := 1 To count_predn_arr_osm
        mvart := "MTAB_NOMov" + lstr( i )
        mvard := "MDATEo" + lstr( i )
        fl := .t.
        If fl .and. !Empty( npred_arr_osmotr[ i, 2 ] )
          fl := ( mpol == npred_arr_osmotr[ i, 2 ] )
        Endif
        If fl
          fl := ( AScan( ar[ 4 ], npred_arr_osmotr[ i, 1 ] ) == 0 )
        Endif
        If fl .and. !emptyany( &mvard, &mvart )
          AAdd( arr, { npred_arr_osmotr[ i, 3 ], &mvard, "", i, f5_inf_dnl_karta( i ) } )
        Endif
      Next
      AAdd( arr, { "������� (��� ��饩 �ࠪ⨪�)", MDATEp2, "", -2, 1 } )
    Endif
  Else
    For i := 1 To count_predn_arr_iss // ��᫥�������
      mvart := "MTAB_NOMiv" + lstr( i )
      mvard := "MDATEi" + lstr( i )
      mvarr := "MREZi" + lstr( i )
      fl := .t.
      If fl .and. !Empty( npred_arr_issled[ i, 2 ] )
        fl := ( mpol == npred_arr_issled[ i, 2 ] )
      Endif
      If fl
        fl := ( AScan( ar[ 5 ], npred_arr_issled[ i, 1 ] ) > 0 )
      Endif
      If fl .and. !emptyany( &mvard, &mvart )
        k := 0
        Do Case
        Case i ==  1 // {"4.2.153" ,   , "��騩 ������ ���", 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 2
        Case i ==  2 // {"4.11.136",   , "������᪨� ������ �஢�", 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 1
        Case i ==  3 // {"4.12.169",   , "��᫥������� �஢�� ���� � �஢�", 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 4
        Case i ==  4 // {"4.8.12"  ,   , "������ ���� �� �� ����⮢", 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 16
        Case i ==  5 // {"7.61.3"  ,   , "���ண��� ������ � 1-� �஥�樨", 0, 78,{1118, 1802} }, ;
          k := 12
        Case i ==  6 // {"8.1.2"   ,   , "��� �⮢����� ������", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 8
        Case i ==  7 // {"8.1.3"   ,   , "��� ���", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 7
        Case i ==  8 // {"8.2.1"   ,   , "��� �࣠��� ���譮� ������", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 6
        Case i ==  9 // {"8.2.2"   ,"�", "��� �࣠��� ९த�⨢��� ��⥬�", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 9
        Case i == 10 // {"8.2.3"   ,"�", "��� �࣠��� ९த�⨢��� ��⥬�", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 9
        Case i == 11 // {"13.1.1"  ,   , "�����ப�न�����", 0, 111,{110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202} }, ;
          k := 13
        Endcase
        AAdd( arr, { npred_arr_issled[ i, 3 ], &mvard, &mvarr, i, k } )
      Endif
    Next
  Endif

  Return arr

// 25.11.13
Function f4_inf_pern_karta( par )

  Local i, k, fl, arr := {}, ar := nper_arr_1_etap[ mperiod ]

  If par == 1
    AAdd( arr, { "������� (��� ��饩 �ࠪ⨪�)", MDATEp1, "", -1, 1 } )
  Else
    For i := 1 To count_Pern_arr_iss // ��᫥�������
      mvart := "MTAB_NOMiv" + lstr( i )
      mvard := "MDATEi" + lstr( i )
      mvarr := "MREZi" + lstr( i )
      fl := ( AScan( ar[ 5 ], nPer_arr_issled[ i, 1 ] ) > 0 )
      If fl .and. !emptyany( &mvard, &mvart )
        k := 0
        Do Case
        Case i ==  1 // {"4.2.153" ,   , "��騩 ������ ���", 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 2
        Case i ==  1 // {"4.11.136",   , "������᪨� ������ �஢�", 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 1
        Case i ==  1 // {"16.1.16" ,   , "������ ���� 㣫�த� ���堥�.������", 0, 34,{1107, 1301, 1402, 1702} };
          k := 17
        Endcase
        AAdd( arr, { nPer_arr_issled[ i, 3 ], &mvard, &mvarr, i, k } )
      Endif
    Next
  Endif

  Return arr

// 12.09.25 ����� ��ᮢ��襭����⭨�, ��������� ����ᬮ�ࠬ, ��⮤�� �������ਠ�⭮�� ���᪠
Function mnog_poisk_dnl()

  Local mm_tmp := {}, mm_sort
  Local buf := SaveScreen(), tmp_color := SetColor( cDataCGet ), ;
    tmp_help := help_code, hGauge, name_file := cur_dir() + "_kartDNL.txt", ;
    sh := 80, HH := 77, i, a_diagnoz[ 10 ], ta, name_dbf := cur_dir() + "_kartDNL" + sdbf(), ;
    mm_da_net := { { "���", 1 }, { "�� ", 2 } }, ;
    mm_mest := { { "������ࠤ ��� �������", 1 }, { "�����த���", 2 } }, ;
    mm_disp := { { "�������", 0 }, { "�� ��室���", 1 }, { "��諨", 2 } }, ;
    mm_death := { { "�뢮���� ���", 0 }, { "�� �뢮���� 㬥���", 1 }, { "�뢮���� ⮫쪮 㬥���", 2 } }, ;
    mm_prik := { { "�������", 0 }, ;
    { "�ਪ९�� � ��襩 ��", 1 }, ;
    { "�ਪ९�� � ��㣨� ��", 2 }, ;
    { "�ਪ९����� �������⭮", 3 } }, ;
    tmp_file := cur_dir() + "tmp_mn_p" + sdbf(), ;
    k_fio, k_adr, tt_fio[ 10 ], tt_adr[ 10 ], fl_exit := .f.
  Local adbf := { ;
    { "UCHAST",   "N",  2, 0 }, ; // ����� ���⪠
    { "KOD_VU",   "N",  6, 0 }, ; // ��� � ���⪥
    { "FIO",   "C", 50, 0 }, ; // �.�.�. ���쭮��
    { "PHONE",   "C", 40, 0 }, ; // ⥫�䮭 ���쭮��
    { "POL",   "C",  1, 0 }, ; // ���
    { "DATE_R", "C", 10, 0 }, ; // ��� ஦����� ���쭮��
    { "LET",   "N",  2, 0 }, ; // ᪮�쪮 ��� � �⮬ ����
    { "ADRESR",  "C", 50, 0 }, ; // ���� ���쭮��
    { "ADRESP",  "C", 50, 0 }, ; // ���� ���쭮��
    { "POLIS",     "C", 17, 0 }, ; // �����
    { "KOD_SMO",   "C",  5, 0 }, ; //
    { "SMO",       "C", 80, 0 }, ; // ॥��஢� ����� ���;;�८�ࠧ����� �� ����� ����� � ����, ����த��� = 34
    { "SNILS",   "C", 14, 0 }, ;
    { "MO_PR",     "C",  6, 0 }, ; // ��� �� �ਯ�᪨
    { "MONAME_PR", "C", 60, 0 }, ; // ������������ �� �ਯ�᪨
    { "DATE_PR", "C", 10, 0 }, ; // ��� �ਯ�᪨
    { "LAST_L_U", "C", 10, 0 };  // ��� ��᫥����� ���� ����
  }
  If !myfiledeleted( name_dbf )
    Return Nil
  Endif
  Private mm_smo := {}, pyear, mstr_crb := 0, is_kategor2 := .f., is_talon := ret_is_talon()
  If is_talon
    is_kategor2 := !Empty( stm_kategor2 )
  Endif
  For i := 1 To Len( glob_arr_smo )
    If glob_arr_smo[ i, 3 ] == 1
      AAdd( mm_smo, { glob_arr_smo[ i, 1 ], PadR( lstr( glob_arr_smo[ i, 2 ] ), 5 ) } )
    Endif
  Next
  ta := f2_mnog_poisk_dnl(,,, 1 )
  AAdd( mm_tmp, { "god", "N", 4, 0, "9999", ;
    nil, ;
    Year( sys_date ), nil, ;
    "� ����� ���� �� �뫮 ��������/��ᯠ��ਧ�樨" } )
  AAdd( mm_tmp, { "v_period", "C", 100, 0, NIL, ;
    {| x| menu_reader( x, { {| k, r, c| f2_mnog_poisk_dnl( k, r, c ) } }, A__FUNCTION ) }, ;
    ta[ 1 ], {| x| ta[ 2 ] }, ;
    '������� ��ਮ�� ��������/��ᯠ��ਧ�樨' } )
  AAdd( mm_tmp, { "o_prik", "N", 1, 0, NIL, ;
    {| x| menu_reader( x, mm_prik, A__MENUVERT ) }, ;
    1, {| x| inieditspr( A__MENUVERT, mm_prik, x ) }, ;
    "�⭮襭�� � �ਪ९�����" } )
  AAdd( mm_tmp, { "o_death", "N", 1, 0, NIL, ;
    {| x| menu_reader( x, mm_death, A__MENUVERT ) }, ;
    1, {| x| inieditspr( A__MENUVERT, mm_death, x ) }, ;
    "�������� � ᬥ�� �� ᢥ����� �����" } )
  Private arr_uchast := {}
  If is_uchastok > 0
    AAdd( mm_tmp, { "bukva", "C", 1, 0, "@!", ;
      nil, ;
      " ", nil, ;
      "�㪢� (��। ���⪮�)" } )
    AAdd( mm_tmp, { "uchast", "N", 1, 0,, ;
      {| x| menu_reader( x, { {| k, r, c| get_uchast( r + 1, c ) } }, A__FUNCTION ) }, ;
      0, {|| init_uchast( arr_uchast ) }, ;
      "���⮪ (���⪨)" } )
    mm_sort := { ;
      { "� ���⪠ + ��� + ���", 1 }, ;
      { "� ���⪠ + ��� + ����", 2 }, ;
      { "� ���⪠ + ���� + ���", 4 };
      }
    If is_uchastok == 1
      AAdd( mm_sort, { '� ���⪠ + � � ���⪥', 3 } )
    Elseif is_uchastok == 2
      AAdd( mm_sort, { '� ���⪠ + ��� �� ����⥪�', 3 } )
    Elseif is_uchastok == 3
      AAdd( mm_sort, { '� ���⪠ + ����� �� ���', 3 } )
    Endif
  Else
    mm_sort := { ;
      { "��� + ���", 1 }, ;
      { "��� + ����", 2 }, ;
      { "��� �� ����⥪�", 3 };
      }
    del_array( adbf, 1 ) // 㡨ࠥ� ���⮪
    del_array( adbf, 1 ) // 㡨ࠥ� ���⮪
  Endif
  AAdd( mm_tmp, { "fio", "C", 20, 0, "@!", ;
    nil, ;
    Space( 20 ), nil, ;
    "��� (��砫�� �㪢� ��� 蠡���)" } )
  AAdd( mm_tmp, { "mi_git", "N", 2, 0, NIL, ;
    {| x| menu_reader( x, mm_mest, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    "���� ��⥫��⢠:" } )
  AAdd( mm_tmp, { "_okato", "C", 11, 0, NIL, ;
    {| x| menu_reader( x, ;
    { {| k, r, c| get_okato_ulica( k, r, c, { k, m_okato, } ) } }, A__FUNCTION ) }, ;
    Space( 11 ), {| x| Space( 11 ) }, ;
    '���� ॣ����樨 (�����)' } )
  AAdd( mm_tmp, { "adres", "C", 20, 0, "@!", ;
    nil, ;
    Space( 20 ), nil, ;
    "���� (�����ப� ��� 蠡���)" } )
  If is_talon
    AAdd( mm_tmp, { "kategor", "N", 2, 0, NIL, ;
      {| x| menu_reader( x, mo_cut_menu( stm_kategor ), A__MENUVERT ) }, ;
      0, {|| Space( 10 ) }, ;
      "��� ��⥣�ਨ �죮��" } )
    If is_kategor2
      AAdd( mm_tmp, { "kategor2", "N", 4, 0, NIL, ;
        {| x| menu_reader( x, stm_kategor2, A__MENUVERT ) }, ;
        0, {|| Space( 10 ) }, ;
        "��⥣��� ��" } )
    Endif
  Endif
  AAdd( mm_tmp, { "pol", "C", 1, 0, "!", ;
    nil, ;
    " ", nil, ;
    "���", {|| mpol $ " ��" } } )
  AAdd( mm_tmp, { "god_r_min", "D", 8, 0,, ;
    nil, ;
    CToD( "" ), nil, ;
    "��� ஦����� (�������쭠�)" } )
  AAdd( mm_tmp, { "god_r_max", "D", 8, 0,, ;
    nil, ;
    CToD( "" ), nil, ;
    "��� ஦����� (���ᨬ��쭠�)" } )
  AAdd( mm_tmp, { "smo", "C", 5, 0, NIL, ;
    {| x| menu_reader( x, mm_smo, A__MENUVERT ) }, ;
    Space( 5 ), {|| Space( 10 ) }, ;
    "���客�� ��������" } )
  AAdd( mm_tmp, { "i_sort", "N", 1, 0, NIL, ;
    {| x| menu_reader( x, mm_sort, A__MENUVERT ) }, ;
    1, {| x| inieditspr( A__MENUVERT, mm_sort, x ) }, ;
    "����஢�� ��室���� ���㬥��" } )
  Delete File ( tmp_file )
  init_base( tmp_file,, mm_tmp, 0 )
  //
  k := f_edit_spr( A__APPEND, mm_tmp, "������⢥����� ������", ;
    "e_use(cur_dir()+'tmp_mn_p')", 0, 1,,,,, "write_mn_p_DNL" )
  If k > 0
    mywait()
    Use ( tmp_file ) New Alias MN
    If is_talon .and. mn->kategor == 0
      is_talon := ( is_kategor2 .and. mn->kategor2 > 0 )
    Endif
    Private mfio := "", madres := "", arr_vozr := list2arr( mn->v_period )
    If !Empty( mn->fio )
      mfio := AllTrim( mn->fio )
      If !( Right( mfio, 1 ) == "*" )
        mfio += "*"
      Endif
    Endif
    If !Empty( mn->adres )
      madres := AllTrim( mn->adres )
      If !( Left( madres, 1 ) == "*" )
        madres := "*" + madres
      Endif
      If !( Right( madres, 1 ) == "*" )
        madres += "*"
      Endif
    Endif
    Private c_view := 0, c_found := 0
    status_key( "^<Esc>^ - ��ࢠ�� ����" )
    hGauge := gaugenew(,,, "���� � ����⥪�", .t. )
    gaugedisplay( hGauge )
    //
    dbCreate( cur_dir() + "tmp", { { "kod", "N", 7, 0 } },, .t., "TMP" )
    r_use( dir_server() + "human_",, "HUMAN_" )
    r_use( dir_server() + "human", dir_server() + "humankk", "HUMAN" )
    Set Relation To RecNo() into HUMAN_
    r_use( dir_server() + "kartote2",, "KART2" )
    r_use( dir_server() + "kartote_",, "KART_" )
    r_use( dir_server() + "kartotek",, "KART" )
    Set Relation To RecNo() into KART_, RecNo() into KART2
    Go Top
    Do While !Eof()
      gaugeupdate( hGauge, RecNo() / LastRec() )
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      f1_mnog_poisk_dnl( @c_view, @c_found )
      Select KART
      Skip
    Enddo
    closegauge( hGauge )
    j := tmp->( LastRec() )
    Close databases
    If j == 0
      If !fl_exit
        func_error( 4, "��� ᢥ�����!" )
      Endif
    Else
      stat_msg( "���⠢����� ⥪�⮢��� � DBF-䠩���" )
      Use ( tmp_file ) New Alias MN
      arr_title := { ;
        "������", ;
        " ��  �", ;
        " ��  �", ;
        "������" }
      If is_uchastok > 0 .or. mn->i_sort == 3 // ��� �� ����⥪�
        arr_title[ 1 ] += "����������"
        arr_title[ 2 ] += " ���⮪ �"
        arr_title[ 3 ] += "   ���   �"
        arr_title[ 4 ] += "����������"
      Endif
      arr_title[ 1 ] += "��������������������������������������������������������������������������������������������������������������"
      arr_title[ 2 ] += "             �.�.�. ��樥��               ����   ���   �              ����                ���- ���᫥���� "
      arr_title[ 3 ] += "                (⥫�䮭)                  �� � ஦����� �                                   ��९.��/� �� ���"
      arr_title[ 4 ] += "��������������������������������������������������������������������������������������������������������������"
      reg_print := f_reg_print( arr_title, @sh, 2 )
      dbCreate( name_dbf, adbf,, .t., "DVN" )
      r_use( dir_server() + "human", dir_server() + "humankk", "HUMAN" )
      r_use( dir_server() + "kartote2",, "KART2" )
      r_use( dir_server() + "kartote_",, "KART_" )
      r_use( dir_server() + "kartotek",, "KART" )
      Set Relation To RecNo() into KART_, To RecNo() into KART2
      Use ( cur_dir() + "tmp" ) new
      Set Relation To kod into KART
      If is_uchastok > 0
        If mn->i_sort == 1 // � ���⪠ + ��� ஦����� + ���
          Index On Str( kart->uchast, 2 ) + Str( mn->god - Year( kart->date_r ), 4 ) + Upper( kart->fio ) to ( cur_dir() + "tmp" )
        Elseif mn->i_sort == 2 // � ���⪠ + ��� ஦����� + ����
          Index On Str( kart->uchast, 2 ) + Str( mn->god - Year( kart->date_r ), 4 ) + Upper( kart->adres ) to ( cur_dir() + "tmp" )
        Elseif mn->i_sort == 4 // � ���⪠ + ���� + ��� ஦�����
          Index On Str( kart->uchast, 2 ) + Upper( kart->adres ) + Str( mn->god - Year( kart->date_r ), 4 ) to ( cur_dir() + "tmp" )
        Elseif mn->i_sort == 3 // � ���⪠ + ���
          If is_uchastok == 1 // � ���⪠ + � � ���⪥
            Index On Str( kart->uchast, 2 ) + Str( kart->kod_vu, 5 ) + Upper( kart->fio ) to ( cur_dir() + "tmp" )
          Elseif is_uchastok == 2 // � ���⪠ + ��� �� ����⥪�
            Index On Str( kart->uchast, 2 ) + Str( kart->kod, 7 ) to ( cur_dir() + "tmp" )
          Elseif is_uchastok == 3 // � ���⪠ + ����� �� ���
            Index On Str( kart->uchast, 2 ) + kart2->kod_AK + Upper( kart->fio ) to ( cur_dir() + "tmp" )
          Endif
        Endif
      Else
        If mn->i_sort == 1 // ��� ஦����� + ���
          Index On Str( mn->god - Year( kart->date_r ), 4 ) + Upper( kart->fio ) to ( cur_dir() + "tmp" )
        Elseif mn->i_sort == 2 // ��� ஦����� + ����
          Index On Str( mn->god - Year( kart->date_r ), 4 ) + Upper( kart->adres ) to ( cur_dir() + "tmp" )
        Elseif mn->i_sort == 3 // ��� �� ����⥪�
          Index On Str( kod, 7 ) to ( cur_dir() + "tmp" )
        Endif
      Endif
      fp := FCreate( name_file ) ; n_list := 1 ; tek_stroke := 0
      add_string( "" )
      add_string( Center( Expand( "��������� ���������������� ������" ), sh ) )
      add_string( "" )
      add_string( " == ��������� ������ ==" )
      add_string( "� ����� ���� �� �뫮 ����ᬮ��/��ᯠ��ਧ�樨 ��ᮢ��襭����⭨�: " + lstr( mn->god ) )
      If !Empty( mn->v_period )
        add_string( "������� ��ਮ�� ����ᬮ��/��ᯠ��ਧ�樨: " + AllTrim( mn->v_period ) )
      Endif
      If mn->o_death == 1
        add_string( "�� �᪫�祭��� 㬥��� (�� ᢥ����� �����)" )
      Elseif mn->o_death == 2
        add_string( "���᮪ 㬥��� (�� ᢥ����� �����)" )
      Endif
      If !Empty( mn->o_prik )
        add_string( "�⭮襭�� � �ਪ९�����: " + inieditspr( A__MENUVERT, mm_prik, mn->o_prik ) )
      Endif
      If is_uchastok > 0
        If !Empty( mn->bukva )
          add_string( "�㪢�: " + mn->bukva )
        Endif
        If !Empty( mn->uchast )
          add_string( "���⮪: " + init_uchast( arr_uchast ) )
        Endif
      Endif
      If !Empty( mfio )
        add_string( "���: " + mfio )
      Endif
      If mn->mi_git > 0
        add_string( "���� ��⥫��⢠: " + inieditspr( A__MENUVERT, mm_mest, mn->mi_git ) )
      Endif
      If !Empty( mn->_okato )
        add_string( "���� ॣ����樨 (�����): " + ret_okato_ulica( '', mn->_okato ) )
      Endif
      If !Empty( madres )
        add_string( "����: " + madres )
      Endif
      If is_talon .and. mn->kategor > 0
        add_string( "��� ��⥣�ਨ �죮��: " + inieditspr( A__MENUVERT, stm_kategor, mn->kategor ) )
      Endif
      If is_talon .and. is_kategor2 .and. mn->kategor2 > 0
        add_string( "��⥣��� ��: " + inieditspr( A__MENUVERT, stm_kategor2, mn->kategor2 ) )
      Endif
      If !Empty( mn->pol )
        add_string( "���: " + mn->pol )
      Endif
      If !Empty( mn->god_r_min ) .or. !Empty( mn->god_r_max )
        If Empty( mn->god_r_min )
          add_string( "���, த��訥�� �� " + full_date( mn->god_r_max ) )
        Elseif Empty( mn->god_r_max )
          add_string( "���, த��訥�� ��᫥ " + full_date( mn->god_r_min ) )
        Else
          add_string( "���, த��訥�� � " + full_date( mn->god_r_min ) + " �� " + full_date( mn->god_r_max ) )
        Endif
      Endif
      If !Empty( mn->smo )
        add_string( "���: " + inieditspr( A__MENUVERT, mm_smo, mn->smo ) )
      Endif
      add_string( "" )
      add_string( "������� ��樥�⮢: " + lstr( tmp->( LastRec() ) ) + " 祫." )
      AEval( arr_title, {| x| add_string( x ) } )
      ii := 0
      Select TMP
      Go Top
      Do While !Eof()
        ++ii
        @ 24, 1 Say Str( ii / tmp->( LastRec() ) * 100, 6, 2 ) + "%" Color cColorSt2Msg
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        mdate := CToD( "" )
        Select HUMAN
        find ( Str( tmp->kod, 7 ) )
        Do While human->kod_k == tmp->kod .and. !Eof()
          If Empty( mdate )
            mdate := human->k_data
          Else
            mdate := Max( mdate, human->k_data )
          Endif
          Skip
        Enddo
        Select DVN
        Append Blank
        s1 := PadR( lstr( ii ), 6 )
        If is_uchastok > 0 .or. mn->i_sort == 3
          If is_uchastok > 0
            s := ""
            If !Empty( kart->uchast )
              dvn->UCHAST := kart->uchast
              s += lstr( kart->uchast )
            Endif
            If is_uchastok == 1 .and. !Empty( kart->kod_vu ) // � ���⪠ + � � ���⪥
              s += "/" + lstr( kart->kod_vu )
              dvn->KOD_VU := kart->kod_vu
            Elseif is_uchastok == 2 // � ���⪠ + ��� �� ����⥪�
              s += "/" + lstr( kart->kod )
              dvn->KOD_VU := kart->kod
            Elseif is_uchastok == 3 .and. !Empty( kart2->kod_AK ) // � ���⪠ + ����� �� ���
              s += "/" + LTrim( kart2->kod_AK )
              dvn->KOD_VU := Val( kart2->kod_AK )
            Endif
          Else
            s := PadL( lstr( tmp->kod ), 9 )
          Endif
          s1 += PadR( s, 10 )
        Endif
        s := ""
        If !Empty( kart_->PHONE_H )
          s += "�." + AllTrim( kart_->PHONE_H ) + " "
        Endif
        If !Empty( kart_->PHONE_M )
          s += "�." + AllTrim( kart_->PHONE_M ) + " "
        Endif
        If !Empty( kart_->PHONE_W )
          s += "�." + AllTrim( kart_->PHONE_W )
        Endif
        dvn->FIO := kart->fio
        dvn->PHONE := s
        s := AllTrim( kart->fio ) + " " + s
        k_fio := perenos( tt_fio, s, 43 )
        s1 += PadR( tt_fio[ 1 ], 44 )
        s1 += Str( mn->god - Year( kart->date_r ), 2 ) + " "
        s1 += full_date( kart->date_r ) + " "
        dvn->POL := kart->pol
        dvn->DATE_R := full_date( kart->date_r )
        dvn->LET := mn->god - Year( kart->date_r )
        k_adr := perenos( tt_adr, kart->adres, 35 )
        s1 += PadR( tt_adr[ 1 ], 36 )
        dvn->ADRESR := kart->adres
        dvn->ADRESP := kart_->adresp
        dvn->POLIS := LTrim( kart_->NPOLIS )
        dvn->KOD_SMO := kart_->smo
        dvn->SMO := smo_to_screen( 1 )
//        dvn->SNILS := iif( Empty( kart->SNILS ), "", Transform( kart->SNILS, picture_pf ) )
        dvn->SNILS := iif( Empty( kart->SNILS ), "", Transform_SNILS( kart->SNILS ) )
        If !Empty( dvn->mo_pr := kart2->mo_pr )
          dvn->MONAME_PR := ret_mo( kart2->mo_pr )[ _MO_SHORT_NAME ]
          If !Empty( kart2->pc4 )
            dvn->DATE_PR := Left( kart2->pc4, 6 ) + "20" + SubStr( kart2->pc4, 7 )
          Else
            dvn->DATE_PR := full_date( kart2->DATE_PR )
          Endif
        Endif
        If Empty( kart2->MO_PR )
          s := ""
        Elseif kart2->MO_PR == glob_mo[ _MO_KOD_TFOMS ]
          s := "���"
        Else
          s := "�㦮�"
        Endif
        s1 += PadR( s, 6 )
        s1 += full_date( mdate )
        dvn->last_l_u := full_date( mdate )
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( s1 )
        For i := 2 To Max( k_fio, k_adr )
          s1 := Space( 6 )
          If is_uchastok > 0 .or. mn->i_sort == 3
            s1 += Space( 10 )
          Endif
          s1 += PadR( tt_fio[ i ], 44 )
          s1 += Space( 14 )
          s1 += tt_adr[ i ]
          add_string( s1 )
        Next
        add_string( Replicate( "-", sh ) )
        Select TMP
        Skip
      Enddo
      If fl_exit
        add_string( "//* " + Expand( "�������� ��������" ) )
      Else
        add_string( "�⮣� ������⢮ ��樥�⮢: " + lstr( tmp->( LastRec() ) ) + " 祫." )
      Endif
      FClose( fp )
      Close databases
      RestScreen( buf )
      viewtext( name_file,,,, .t.,,, reg_print )
      n_message( { "������ 䠩� ��� ����㧪� � Excel: " + name_dbf },, cColorStMsg, cColorStMsg,,, cColorSt2Msg )
    Endif
  Endif
  Close databases
  RestScreen( buf ) ; SetColor( tmp_color )

  Return Nil

// 31.10.16
Function write_mn_p_dnl( k )

  Local fl := .t.

  If k == 1
    If Empty( mgod )
      fl := func_error( 4, '������ ���� ��������� ���� "��� �஢������ ����ᬮ��/��ᯠ��ਧ�樨"' )
    Elseif Empty( mv_period )
      fl := func_error( 4, '������ ���� ����� ��� �� ���� �����⭮� ��ਮ� ����ᬮ��/��ᯠ��ਧ�樨' )
    Endif
  Endif

  Return fl

// 21.11.19
Static Function f1_mnog_poisk_dnl( cv, cf )

  Local i, j, k, n, s, arr, fl, god_r, arr1, vozr

  ++cv
  vozr := mn->god - Year( kart->date_r )
  If ( fl := ( vozr < 18 ) )
    fl := ( AScan( arr_vozr, vozr ) > 0 )
  Endif
  If fl
    Select HUMAN
    find ( Str( kart->kod, 7 ) )
    Do While human->kod_k == kart->kod .and. !Eof()
      If Year( human->k_data ) == mn->god .and. eq_any( human->ishod, 101, 102, 301, 302, 303, 304, 305 )
        fl := .f. ; Exit
      Endif
      Skip
    Enddo
  Endif
  If fl .and. !Empty( mn->o_prik )
    If mn->o_prik == 1 // � ��襩 ��
      fl := ( kart2->MO_PR == glob_mo[ _MO_KOD_TFOMS ] )
    Elseif mn->o_prik == 2 // � ��㣨� ��
      fl := !( kart2->MO_PR == glob_mo[ _MO_KOD_TFOMS ] )
    Else // �ਪ९����� �������⭮
      fl := Empty( kart2->MO_PR )
    Endif
  Endif
  If fl .and. mn->o_death > 0
    If mn->o_death == 1 // �� �᪫�祭��� 㬥��� (�� ᢥ����� �����)
      fl := !( Left( kart2->PC2, 1 ) == "1" )
    Elseif mn->o_death == 2 // ���᮪ 㬥��� (�� ᢥ����� �����)
      fl := ( Left( kart2->PC2, 1 ) == "1" )
    Endif
  Endif
  If fl .and. is_uchastok > 0 .and. !Empty( mn->bukva )
    fl := ( mn->bukva == kart->bukva )
  Endif
  If fl .and. is_uchastok > 0 .and. !Empty( mn->uchast )
    fl := f_is_uchast( arr_uchast, kart->uchast )
  Endif
  If fl .and. !Empty( mfio )
    fl := Like( mfio, Upper( kart->fio ) )
  Endif
  If fl .and. !Empty( madres )
    fl := Like( madres, Upper( kart->adres ) )
  Endif
  If fl .and. is_talon .and. mn->kategor > 0
    fl := ( mn->kategor == kart_->kategor )
  Endif
  If fl .and. is_kategor2 .and. mn->kategor2 > 0
    fl := ( mn->kategor2 == kart_->kategor2 )
  Endif
  If fl .and. !Empty( mn->pol )
    fl := ( kart->pol == mn->pol )
  Endif
  If fl .and. !Empty( mn->god_r_min )
    fl := ( mn->god_r_min <= kart->date_r )
  Endif
  If fl .and. !Empty( mn->god_r_max )
    fl := ( human->date_r <= mn->god_r_max )
  Endif
  If fl .and. mn->mi_git > 0
    If mn->mi_git == 1
      fl := ( Left( kart_->okatog, 2 ) == '18' )
    Else
      fl := !( Left( kart_->okatog, 2 ) == '18' )
    Endif
  Endif
  If fl .and. !Empty( mn->_okato )
    s := mn->_okato
    For i := 1 To 3
      If Right( s, 3 ) == '000'
        s := Left( s, Len( s ) -3 )
      Else
        Exit
      Endif
    Next
    fl := ( Left( kart_->okatog, Len( s ) ) == s )
  Endif
  If fl .and. !Empty( mn->smo )
    fl := ( kart_->smo == mn->smo )
  Endif
  If fl
    Select TMP
    Append Blank
    tmp->kod := kart->kod
    If++cf % 5000 == 0
      tmp->( dbCommit() )
    Endif
  Endif
  @ 24, 1 Say lstr( cv ) Color cColorSt2Msg
  @ Row(), Col() Say "/" Color "W/R"
  @ Row(), Col() Say lstr( cf ) Color cColorStMsg

  Return Nil

// 31.10.16 ����� � GET-� �������� ��ਮ��� �������஢ ��ᮢ��襭����⭨�
Function f2_mnog_poisk_dnl( k, r, c, par )

  Static sast, sarr
  Local buf := save_maxrow(), a, i, j, s, s1

  Default par To 2
  If sast == NIL
    sast := {} ; sarr := {}
    For j := 0 To 17
      AAdd( sast, .t. )
      s := lstr( j )
      If j == 1
        s += " ���"
      Elseif Between( j, 2, 4 )
        s += " ����"
      Else
        s += " ���"
      Endif
      AAdd( sarr, { s, j } )
    Next
  Endif
  s := s1 := ""
  If par == 1
    sast := {}
    For i := 1 To Len( sarr )
      AAdd( sast, .t. )
      s += lstr( sarr[ i, 2 ] ) + iif( i < Len( sarr ), ",", "" )
    Next
    s1 := "��"
  Elseif ( a := bit_popup( r, c, sarr, sast ) ) != NIL
    AFill( sast, .f. )
    For i := 1 To Len( a )
      If ( j := AScan( sarr, {| x| x[ 2 ] == a[ i, 2 ] } ) ) > 0
        sast[ j ] := .t.
        s += lstr( a[ i, 2 ] ) + iif( i < Len( a ), ",", "" )
      Endif
    Next
    If Len( a ) == Len( sast )
      s1 := "��"
    Endif
  Endif
  If Empty( s )
    s := Space( 10 )
  Endif
  If Empty( s1 )
    s1 := s
  Endif

  Return { s, s1 }

// 18.12.13 ������ ���㬥��� �� �ᥬ ����� ��ᯠ��ਧ�樨 � ��䨫��⨪�
Function inf_disp( k )

  Static si1 := 1, si2 := 1
  Local mas_pmt, mas_msg, mas_fun

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { "~�⮣� ��� �����" }
    mas_msg := { "�⮣� �� ��ਮ� �६��� ��� �����" }
    mas_fun := { "inf_DISP(11)" }
    popup_prompt( T_ROW, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    itog_svod_disp_tf()
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Elseif Between( k, 21, 29 )
      si2 := j
    Endif
  Endif

  Return Nil

// 18.12.13 �⮣� �� ��ਮ� �६��� ��� �����
Function itog_svod_disp_tf()

  Local i, k, arr_m, buf := save_maxrow(), ;
    sh := 80, hh := 60, n_file := cur_dir() + "svod_dis.txt"

  If ( arr_m := year_month(,,, 5 ) ) != NIL
    mywait()
    dbCreate( cur_dir() + "tmpk", { { "kod", "N", 7, 0 }, ;
      { "tip", "N", 1, 0 } } )
    Use ( cur_dir() + "tmpk" ) new
    Index On Str( tip, 1 ) + Str( kod, 7 ) to ( cur_dir() + "tmpk" )
    dbCreate( cur_dir() + "tmp", { { "tip",  "N", 1, 0 }, ;
      { "kol_s", "N", 6, 0 }, ;
      { "kol_o", "N", 6, 0 }, ;
      { "kol_p", "N", 6, 0 } } )
    Use ( cur_dir() + "tmp" ) new
    Index On Str( tip, 1 ) to ( cur_dir() + "tmp" )
    r_use( dir_server() + "mo_rak",, "RAK" )
    r_use( dir_server() + "mo_raks",, "RAKS" )
    Set Relation To akt into RAK
    r_use( dir_server() + "mo_raksh",, "RAKSH" )
    Set Relation To kod_raks into RAKS
    Index On Str( kod_h, 7 ) + DToS( rak->dakt ) to ( cur_dir() + "tmpraksh" )
    r_use( dir_server() + "mo_rpd",, "RPD" )
    r_use( dir_server() + "mo_rpds",, "RPDS" )
    Set Relation To pd into RPD
    r_use( dir_server() + "mo_rpdsh",, "RPDSH" )
    Set Relation To kod_rpds into RPDS
    Index On Str( kod_h, 7 ) + DToS( rpd->d_pd ) to ( cur_dir() + "tmprpdsh" )
    r_use( dir_server() + "schet_",, "SCHET_" )
    r_use( dir_server() + "human_",, "HUMAN_" )
    r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
    Set Relation To RecNo() into HUMAN_
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    Index On kod to ( cur_dir() + "tmp_h" ) ;
      For ishod > 100 .and. human_->oplata != 9 .and. schet > 0 ;
      While human->k_data <= arr_m[ 6 ] ;
      PROGRESS
    i := 0
    Go Top
    Do While !Eof()
      ++i
      @ MaxRow(), 1 Say lstr( i ) Color cColorWait
      ltip := 0
      Select SCHET_
      Goto ( human->schet )
      If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // ⮫쪮 ��ॣ����஢����
        If eq_any( human->ishod, 101, 102 )
          ltip := iif( Empty( human->za_smo ), 2, 1 )
        Elseif eq_any( human->ishod, 301, 302 )
          ltip := 3
        Elseif eq_any( human->ishod, 303, 304 )
          m1gruppa := human_->RSLT_NEW - 316
          If Between( m1gruppa, 1, 3 )
            ltip := 4
          Endif
        Elseif human->ishod == 305
          ltip := 5
        Elseif eq_any( human->ishod, 201, 202 )
          ltip := 6
        Elseif human->ishod == 203
          ltip := 7
        Endif
      Endif
      If ltip > 0
        Select TMPK
        find ( Str( ltip, 1 ) + Str( human->kod_k, 7 ) )
        If !Found()
          Append Blank
          tmpk->tip := ltip
          tmpk->kod := human->kod_k
          If LastRec() % 2000 == 0
            Commit
          Endif
        Endif
        Select TMP
        find ( Str( ltip, 1 ) )
        If !Found()
          Append Blank
          tmp->tip := ltip
        Endif
        tmp->kol_s++
        //
        k := 0
        Select RAKSH
        find ( Str( human->kod, 7 ) )
        Do While raksh->kod_h == human->kod .and. !Eof()
          If raksh->IS_REPEAT < 1
            k := iif( raksh->SUMP > 0, 1, 0 )
          Endif
          Skip
        Enddo
        If k == 1
          tmp->kol_o++
        Endif
        //
        k := 0
        Select RPDSH
        find ( Str( human->kod, 7 ) )
        Do While rpdsh->kod_h == human->kod .and. !Eof()
          k += rpdsh->S_SL
          Skip
        Enddo
        If k > 0
          tmp->kol_p++
        Endif
      Endif
      Select HUMAN
      Skip
    Enddo
    //
    fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
    add_string( glob_mo[ _MO_SHORT_NAME ] )
    add_string( "" )
    add_string( Center( "�⮣� �� ��ᯠ��ਧ�樨, ��䨫��⨪� � ����ᬮ�ࠬ", sh ) )
    add_string( Center( "[ " + CharRem( "~", mas1pmt[ 3 ] ) + " ]", sh ) )
    add_string( Center( arr_m[ 4 ], sh ) )
    add_string( "" )
    add_string( "��������������������������������������������������������������������������������" )
    add_string( "                                        � ���-��  � ���-��  � ���-��  � ���-��  " )
    add_string( "                                        � ��砥� � 祫���� � ��砥�,� ��砥�," )
    add_string( "                                        �         �         � �ਭ���峮���祭�." )
    add_string( "                                        �         �         � � ����⥳���������" )
    add_string( "                                        �         �         �         ���� ���." )
    add_string( "��������������������������������������������������������������������������������" )
    For i := 1 To 7
      s :=    { "��ᯠ��ਧ��� ��⥩-��� � ��樮���", ;
        "��ᯠ��ਧ��� ��⥩-��� ��� ������", ;
        "��䨫����.�ᬮ��� ��ᮢ��襭����⭨�", ;
        "�।���⥫�.�ᬮ��� ��ᮢ��襭����⭨�", ;
        "��ਮ���᪨� �ᬮ��� ��ᮢ��襭����⭨�", ;
        "��ᯠ��ਧ��� ���᫮�� ��ᥫ����", ;
        "��䨫��⨪� ���᫮�� ��ᥫ����" }[ i ]
      Select TMP
      find ( Str( i, 1 ) )
      If Found()
        k := 0
        Select TMPK
        find ( Str( i, 1 ) )
        Do While tmpk->tip == i .and. !Eof()
          ++k
          Skip
        Enddo
        s := PadR( s, 40 ) + put_val( tmp->kol_s, 9 ) + ;
          put_val( k, 10 ) + ;
          put_val( tmp->kol_o, 10 ) + ;
          put_val( tmp->kol_p, 10 )
      Endif
      add_string( s )
      add_string( Replicate( "�", sh ) )
    Next
    Close databases
    FClose( fp )
    rest_box( buf )
    viewtext( n_file,,,, .f.,,, 2 )
  Endif

  Return Nil

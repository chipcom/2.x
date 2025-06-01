#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// 06.11.22
Function forma_30()

  Local buf := save_maxrow(), fl_exit := .f., ;
    reg_print, name_file := cur_dir() + "_form_30.txt", ;
    jh := 0, jh1 := 0, arr_m

  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  Private sh, HH := 78, arr_title
  adbf := { { "tip",   "N", 1, 0 }, ;  // 1-4
  { "kod",   "N", 9, 0 }, ;  // ���,��䨫�,ᯥ樠�쭮���,��㣠
  { "p3",    "N", 7, 0 }, ;
    { "p4",    "N", 7, 0 }, ;
    { "p5",    "N", 7, 0 }, ;
    { "p6",    "N", 7, 0 }, ;
    { "p7",    "N", 7, 0 }, ;
    { "p8",    "N", 7, 0 }, ;
    { "p9",    "N", 7, 0 }, ;
    { "p10",   "N", 7, 0 }, ;
    { "p11",   "N", 7, 0 }, ;
    { "p12",   "N", 7, 0 }, ;
    { "p13",   "N", 7, 0 } }
  dbCreate( cur_dir() + "tmp", adbf )
  Use ( cur_dir() + "tmp" ) new
  Index On Str( tip, 1 ) + Str( kod, 9 ) to ( cur_dir() + "tmp" )
  //
  adbf := { { "tip",   "N", 1, 0 }, ;  // 1-4
  { "kod",   "N", 9, 0 }, ;  // ���,��䨫�,ᯥ樠�쭮���,��㣠
  { "p5",    "N", 7, 0 }, ;
    { "p6",    "N", 7, 0 }, ;
    { "p7",    "N", 7, 0 }, ;
    { "p8",    "N", 7, 0 }, ;
    { "p9",    "N", 7, 0 }, ;
    { "p10",   "N", 7, 0 }, ;
    { "p11",   "N", 7, 0 }, ;
    { "p12",   "N", 7, 0 }, ;
    { "p13",   "N", 7, 0 }, ;
    { "p14",   "N", 7, 0 }, ;
    { "p15",   "N", 7, 0 } }
  dbCreate( cur_dir() + "tmp1", adbf )
  Use ( cur_dir() + "tmp1" ) new
  Index On Str( tip, 1 ) + Str( kod, 9 ) to ( cur_dir() + "tmp1" )
  //
  adbf := { { "tip",   "N", 1, 0 }, ;  // 1-4
  { "kod",   "N", 9, 0 }, ;  // ���,��䨫�,ᯥ樠�쭮���,��㣠
  { "p2",    "N", 7, 0 }, ;
    { "p3",    "N", 7, 0 }, ;
    { "p4",    "N", 7, 0 }, ;
    { "p5",    "N", 7, 0 }, ;
    { "p6",    "N", 7, 0 }, ;
    { "p7",    "N", 7, 0 }, ;
    { "p8",    "N", 7, 0 }, ;
    { "p9",    "N", 7, 0 }, ;
    { "p10",   "N", 7, 0 }, ;
    { "p11",   "N", 7, 0 }, ;
    { "p12",   "N", 7, 0 }, ;
    { "p13",   "N", 7, 0 }, ;
    { "p14",   "N", 7, 0 }, ;
    { "p15",   "N", 7, 0 } }
  dbCreate( cur_dir() + "tmp2", adbf )
  Use ( cur_dir() + "tmp2" ) new
  Index On Str( tip, 1 ) + Str( kod, 9 ) to ( cur_dir() + "tmp2" )
  //
  r_use( dir_server + "mo_su",, "MOSU" )
  r_use( dir_server + "mo_hu", dir_server + "mo_hu", "MOHU" )
  Set Relation To u_kod into MOSU
  r_use( dir_server + "uslugi",, "USL" )
  r_use( dir_server + "human_u_",, "HU_" )
  r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
  Set Relation To RecNo() into HU_, To u_kod into USL
  r_use( dir_server + "kartote_",, "KART_" )
  r_use( dir_server + "kartotek",, "KART" )
  Set Relation To RecNo() into KART_
  waitstatus( "<Esc> - ��ࢠ�� ����" ) ; mark_keys( { "<Esc>" } )
  If pi1 == 1 // �� ��� ����砭�� ��祭��
    begin_date := arr_m[ 5 ]
    end_date := arr_m[ 6 ]
    r_use( dir_server + "human_2",, "HUMAN_2" )
    r_use( dir_server + "human_",, "HUMAN_" )
    r_use( dir_server + "human", dir_server + "humand", "HUMAN" )
    Set Relation To kod_k into KART, To RecNo() into HUMAN_, RecNo() into HUMAN_2
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      If human_->oplata < 9 .and. func_pi_schet()
        jh := f1_f30_dop( jh, jh1 )
        jh := f1_f30( jh - 1, @jh1 )
        @ MaxRow(), 1 Say lstr( jh ) Color cColorSt2Msg
        @ Row(), Col() Say "/" Color "W/R"
        @ Row(), Col() Say lstr( jh1 ) Color cColorStMsg
      Endif
      date_24( human->k_data )
      Select HUMAN
      Skip
    Enddo
  Else
    r_use( dir_server + "human_2",, "HUMAN_2" )
    r_use( dir_server + "human_",, "HUMAN_" )
    r_use( dir_server + "human", dir_server + "humans", "HUMAN" )
    Set Relation To kod_k into KART, To RecNo() into HUMAN_, RecNo() into HUMAN_2
    r_use( dir_server + "schet_",, "SCHET_" )
    r_use( dir_server + "schet", dir_server + "schetd", "SCHET" )
    Set Relation To RecNo() into SCHET_
    Set Filter To Empty( schet_->IS_DOPLATA )
    dbSeek( arr_m[ 7 ], .t. )
    Do While schet->pdate <= arr_m[ 8 ] .and. !Eof()
      date_24( c4tod( schet->pdate ) )
      Select HUMAN
      find ( Str( schet->kod, 6 ) )
      Do While human->schet == schet->kod .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        If human_->oplata < 9
          jh := f1_f30_dop( jh, jh1 )
          jh := f1_f30( jh - 1, @jh1 )
        Endif
        @ MaxRow(), 1 Say lstr( jh ) Color cColorSt2Msg
        @ Row(), Col() Say "/" Color "W/R"
        @ Row(), Col() Say lstr( jh1 ) Color cColorStMsg
        Select HUMAN
        Skip
      Enddo
      If fl_exit
        Exit
      Endif
      Select SCHET
      Skip
    Enddo
  Endif
  Close databases
  rest_box( buf )
  If fl_exit ; Return NIL ; Endif
  //
  mywait()
  arr_title := { ;
    "�������������������������������������������������������������������������������������������������������", ;
    "                       �� �   ��᫮ ���饭��  ��� ��饣� �᫠ ��  � �᫮ ���饭�� ��砬� �� ����  ", ;
    "                       �����������������������Ĵ ������ ����������� �����������������������������������", ;
    "������������ �������⥩�ள      �� �.�.����쬨��������������������Ĵ�ᥣ� ��� ��峨� ��9��� ��9��� �12", ;
    "                       �����ᥣ� �ᥫ�᪳ 0-17 �ᥫ��.�18 ��� ��� �      �ᥫ�᪳�� ���� ��� ��� ���", ;
    "                       �  �      ���⥫� ���  ���⥫.�� ���0-17�.�      ���⥫���������0-17�.�������", ;
    "�������������������������������������������������������������������������������������������������������", ;
    "           1           �2 �  3   �  4   �  5   �  6   �  7   �  8   �  9   �  10  �  11  �  12  �  13  ", ;
    "�������������������������������������������������������������������������������������������������������";
    }
  sh := Len( arr_title[ 1 ] )
  reg_print := 6
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  r_use( dir_server + "organiz",, "ORG" )
  add_string( PadR( org->name, 108 ) )
  add_string( PadL( "��ଠ � 30", sh ) )
  add_string( PadL( "�⢥ত��� �ਪ����", sh ) )
  add_string( PadL( "������ ���ᨨ", sh ) )
  add_string( PadL( "�� 27.12.2016�. � 866", sh ) )
  add_string( Center( "�������� �� ���������� ���������������", sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  If pi1 == 1
    add_string( Center( str_pi_schet(), sh ) )
  Else
    add_string( Center( "[ �� ��� �믨᪨ ��� ]", sh ) )
  Endif
  add_string( "" )
  add_string( Center( "������ III. ������������ �� �� �������� ���.������ � ������������ ��������", sh ) )
  add_string( "" )
  add_string( Center( "1. ����� ��祩 ����樭᪮� �࣠����樨 � ���㫠���� �᫮����", sh ) )
  add_string( "(2100)" + PadL( "��� �� ����: ���饭�� � ᬥ�� - 545", sh - 6 ) )
  AEval( arr_title, {| x| add_string( x ) } )
  Use ( cur_dir() + "tmp" ) New index ( cur_dir() + "tmp" )
  find ( Str( 0, 1 ) )
  If Found()
    f2_f30( "��� �ᥣ�", "01" )
    add_string( Replicate( "-", sh ) )
    add_string( "� �.�. �� ��砬" )
    r_use( dir_server + "mo_pers",, "PERS" )
    Select TMP
    Set Relation To kod into PERS
    Index On Upper( pers->fio ) to ( cur_dir() + "tmp" ) For tip == 1
    Go Top
    Do While !Eof()
      f2_f30( lstr( pers->tab_nom ) + " " + fam_i_o( pers->fio ) )
      Skip
    Enddo
    add_string( Replicate( "-", sh ) )
    add_string( "� �.�. �� ��䨫�" )
    Select TMP
    Set Relation To
    Index On Str( kod, 9 ) to ( cur_dir() + "tmp" ) For tip == 2
    Go Top
    Do While !Eof()
      f2_f30( inieditspr( A__MENUVERT, getv002(), tmp->kod ) )
      Skip
    Enddo
    add_string( Replicate( "-", sh ) )
    add_string( "� �.�. �� ᯥ樠�쭮���" )
    Select TMP
    Set Relation To
    Index On PadR( lstr( kod ), 9 ) to ( cur_dir() + "tmp" ) For tip == 3
    Go Top
    Do While !Eof()
      f2_f30( inieditspr( A__MENUVERT, getv015(), tmp->kod ) )
      Skip
    Enddo
    r_use( dir_server + "uslugi",, "USL" )
    add_string( Replicate( "-", sh ) )
    add_string( "� �.�. �� ��㣠�" )
    Select TMP
    Set Relation To kod into USL
    Index On fsort_usl( usl->shifr ) to ( cur_dir() + "tmp" ) For tip == 4
    Go Top
    Do While !Eof()
      f2_f30( AllTrim( usl->shifr ) + " " + usl->name )
      Skip
    Enddo
    r_use( dir_server + "mo_su",, "MOSU" )
    Select TMP
    Set Relation To kod into MOSU
    Index On fsort_usl( mosu->shifr ) to ( cur_dir() + "tmp" ) For tip == 5
    Go Top
    Do While !Eof()
      lshifr := AllTrim( mosu->shifr1 )
      If !Empty( mosu->shifr )
        lshifr += "(" + AllTrim( mosu->shifr ) + ")"
      Endif
      f2_f30( lshifr + " " + mosu->name )
      Skip
    Enddo
  Endif
  arr_title := { ;
    "�������������������������������������������������������������������������������������������������������", ;
    "                          �   ����㯨�� ������       �  �믨ᠭ� ������  �   㬥૮    � �����-����  ", ;
    "                          �����������������������������������������������������������������������������", ;
    "      ��䨫� ����        �      �� �.�.���⥩ ����襳      ����襳�     ��ᥣ� ����襳�ᥣ� �����", ;
    "                          ��ᥣ� �ᥫ�᪳ 0-17 ���㤮� �ᥣ����㤮᳤�����      ���㤮�      ���㤮�", ;
    "                          �      ���⥫�� ���  �����࠳      �����࠳��樮�      �����࠳      ������", ;
    "�������������������������������������������������������������������������������������������������������", ;
    "           2              �  6   �  7   �  8   �  9   �  10  �  11  �  12  �  13  �  14  �  15  �  16  ", ;
    "�������������������������������������������������������������������������������������������������������";
    }
  sh := Len( arr_title[ 1 ] )
  tek_stroke := HH + 10
  verify_ff( HH, .t., sh )
  add_string( "" )
  add_string( Center( "������ IV. ������������ �� �� �������� ���.������ � ������������ ��������", sh ) )
  add_string( "" )
  add_string( Center( "1. ����� 䮭� � ��� �ᯮ�짮�����", sh ) )
  add_string( "(3100)" + PadL( "���� �� ����: ����� - 911, 祫���� - 792", sh - 6 ) )
  AEval( arr_title, {| x| add_string( x ) } )
  Use ( cur_dir() + "tmp1" ) New index ( cur_dir() + "tmp1" )
  find ( Str( 0, 1 ) )
  If Found()
    f2_f30( "���� �ᥣ�",, 2 ) // !!!!!!!
    add_string( Replicate( "-", sh ) )
    add_string( "� �.�. �� ��䨫�" )
    Index On Str( kod, 9 ) to ( cur_dir() + "tmp1" ) For tip == 1
    Go Top
    Do While !Eof()
      f2_f30( inieditspr( A__MENUVERT, getv002(), tmp1->kod ),, 2 )
      Skip
    Enddo
  Endif
  If fl_exit ; Return NIL ; Endif
  //
  mywait()
  arr_title := { ;
    "�����������������������������������������������������������������������������������������������������������", ;
    "                       �                 ��᫮ ���饭��         ��� ��饣� �᫠ ���饭�� �� ������ �����", ;
    "                       ������������������������������������������������������������������������������������", ;
    "������������ �������⥩�     �� �.糨� 2 ��� 4 ���� ��� 6 ��� 6 �     �� �.�18������賤�� ��� 13��� 13", ;
    "                       ��ᥣ��ᥫ������ᥫ�� 0-17�� �.�ᥫ�᳢ᥣ��ᥫ��  �  ���� �0-17��� �.�ᥫ��", ;
    "                       �     � ��� ����.� ��� � ��� ���� � ��� �     � ��� ���� ��ᯮ�     � 0-14� ��� ", ;
    "                       �     ���⥫�����.���⥫�     �0-14 ���⥫�     ���⥫� �  ����� �     �     ���⥫", ;
    "�����������������������������������������������������������������������������������������������������������", ;
    "           1           �  2  �  3  �  4  �  5  �  6  �  7  �  8  �  9  �  10 �  11 �  12 �  13 �  14 �  15 ", ;
    "�����������������������������������������������������������������������������������������������������������";
    }
  sh := Len( arr_title[ 1 ] )
  tek_stroke := HH + 10
  verify_ff( HH, .t., sh )
  add_string( "" )
  add_string( Center( "������ III. ������������ �� �� �������� ���.������ � ������������ ��������", sh ) )
  add_string( Center( "����������", sh ) )
  add_string( Center( "1. ����� ��祩 ����樭᪮� �࣠����樨 � ���㫠���� �᫮����", sh ) )
  add_string( "(2100)" + PadL( "��� �� ����: ���饭�� � ᬥ�� - 545", sh - 6 ) )
  AEval( arr_title, {| x| add_string( x ) } )
  Use ( cur_dir() + "tmp2" ) New index ( cur_dir() + "tmp2" )
  find ( Str( 0, 1 ) )
  If Found()  // � tmp 㦥 ������ �室���
    f2_f30_dop( "��� �ᥣ�", "01" )
    add_string( Replicate( "-", sh ) )
    add_string( "� �.�. �� ��砬" )
    // R_Use(dir_server+"mo_pers",,"PERS")
    Select TMP2
    Set Relation To kod into PERS
    Index On Upper( pers->fio ) to ( cur_dir() + "tmp2" ) For tip == 1
    Go Top
    Do While !Eof()
      f2_f30_dop( lstr( pers->tab_nom ) + " " + fam_i_o( pers->fio ) )
      Skip
    Enddo
    add_string( Replicate( "-", sh ) )
    add_string( "� �.�. �� ��䨫�" )
    Select TMP2
    Set Relation To
    Index On Str( kod, 9 ) to ( cur_dir() + "tmp2" ) For tip == 2
    Go Top
    Do While !Eof()
      f2_f30_dop( inieditspr( A__MENUVERT, getv002(), tmp2->kod ) )
      Skip
    Enddo
    add_string( Replicate( "-", sh ) )
    add_string( "� �.�. �� ᯥ樠�쭮���" )
    Select TMP2
    Set Relation To
    Index On PadR( lstr( kod ), 9 ) to ( cur_dir() + "tmp2" ) For tip == 3
    Go Top
    Do While !Eof()
      f2_f30_dop( inieditspr( A__MENUVERT, getv015(), tmp2->kod ) )
      Skip
    Enddo
    // R_Use(dir_server+"uslugi",,"USL")
    add_string( Replicate( "-", sh ) )
    add_string( "� �.�. �� ��㣠�" )
    Select TMP2
    Set Relation To kod into USL
    Index On fsort_usl( usl->shifr ) to ( cur_dir() + "tmp2" ) For tip == 4
    Go Top
    Do While !Eof()
      f2_f30_dop( AllTrim( usl->shifr ) + " " + usl->name )
      Skip
    Enddo
    // R_Use(dir_server+"mo_su",,"MOSU")
    Select TMP2
    Set Relation To kod into MOSU
    Index On fsort_usl( mosu->shifr ) to ( cur_dir() + "tmp2" ) For tip == 5
    Go Top
    Do While !Eof()
      lshifr := AllTrim( mosu->shifr1 )
      If !Empty( mosu->shifr )
        lshifr += "(" + AllTrim( mosu->shifr ) + ")"
      Endif
      f2_f30_dop( lshifr + " " + mosu->name )
      Skip
    Enddo
  Endif
  //
  FClose( fp )
  Close databases
  rest_box( buf )
  viewtext( name_file,,,, .t.,,, reg_print )

  Return Nil

// 19.10.16
Function f1_f30( jh, jh1 )

  Local i, j, k, n, mvozrast, is_selo, is_dom, is_zabol, fl_stom_new := .f., au_lu := {}, au_flu := {}, ;
    lshifr, lshifr1, yes_30 := .f., fl_pensioner := .f., fl_death := .f., ;
    d2_year := Year( human->k_data ), au_su1 := {}, vid_vp := 0 // �� 㬮�砭�� ��䨫��⨪�

  If human_->NOVOR > 0
    mvozrast := count_years( human_->DATE_R2, human->n_data )
  Else
    mvozrast := count_years( human->date_r, human->n_data )
  Endif
  is_selo := f_is_selo( kart_->gorod_selo, kart_->okatog )  // �ਧ��� ᥫ�
  If ( human->pol == "�" .and. mvozrast >= 55 ) .or. ;
      ( human->pol == "�" .and. mvozrast >= 60 )
    fl_pensioner := .t.
  Endif
  If is_death( human_->RSLT_NEW ) // ᬥ���
    fl_death := .t.
  Endif
  Select HU
  find ( Str( human->kod, 7 ) )
  Do While hu->kod == human->kod .and. !Eof()
    lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
    If f_paraklinika( usl->shifr, lshifr1, human->k_data )
      lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
      If is_2_stomat( lshifr,, .t. ) > 0
        fl_stom_new := .t.
        AAdd( au_lu, { lshifr, ;              // 1
          c4tod( hu->date_u ), ;   // 2
        hu_->profil, ;         // 3
          hu_->PRVS, ;           // 4
          AllTrim( usl->shifr ), ; // 5
        hu->kol_1, ;           // 6
          c4tod( hu->date_u ), ;   // 7
        hu_->kod_diag, ;       // 8
        hu->( RecNo() ), ;       // 9 - ����� �����
        0 } )                   // 10 - ��� ������
      Endif
      If eq_any( Left( lshifr, 5 ), "2.80.", "2.82." )
        vid_vp := 1 // � ���⫮���� �ଥ ��� ���饭�� � ��񬭮� �����
        Exit
      Elseif eq_any( Left( lshifr, 5 ), "2.78.", "2.89." )
        vid_vp := 2 // �� ������ �����������
        Exit
      Elseif Left( lshifr, 5 ) == "2.88."
        vid_vp := 2 // ࠧ���� �� ������ �����������
        Exit
      Elseif d2_year < 2016 .and. Left( lshifr, 3 ) == "57." // �⮬�⮫����
        For i := 1 To 3
          ar := {}
          f_vid_p_stom( {}, {}, ar, { i } )
          If AScan( ar, lshifr ) > 0
            If i == 1 // � ��祡��� 楫��
              vid_vp := 3 // �� ������ �����������
            Elseif i == 2 // // � ��䨫����᪮� 楫��
              vid_vp := 1 // ��䨫��⨪�
            Else // // �� �������� ���⫮���� �����
              vid_vp := 2 // � ���⫮���� �ଥ
            Endif
            Exit
          Endif
        Next
        If vid_vp > 0
          --vid_vp
          Exit
        Endif
      Endif
    Endif
    Select HU
    Skip
  Enddo
  is_zabol := ( vid_vp > 0 )
  If fl_stom_new
    Select MOHU
    find ( Str( human->kod, 7 ) )
    Do While mohu->kod == human->kod .and. !Eof()
      AAdd( au_flu, { mosu->shifr1, ;         // 1
        c4tod( mohu->date_u ), ;  // 2
      mohu->profil, ;         // 3
        mohu->PRVS, ;           // 4
        mosu->shifr, ;          // 5
        mohu->kol_1, ;          // 6
        c4tod( mohu->date_u2 ), ; // 7
      mohu->kod_diag, ;       // 8
        mohu->( RecNo() ), ;      // 9 - ����� �����
      0 } )                    // 10 - ��� ������
      Select MOHU
      Skip
    Enddo
    f_vid_p_stom( au_lu, {},,, human->k_data,,,, au_flu )
    For j := 1 To Len( au_flu )
      If au_flu[ j, 10 ] == 1 // ���� ��祡�� ��񬮬
        mohu->( dbGoto( au_flu[ j, 9 ] ) )
        is_dom := .f. // �� ����
        yes_30 := .t.
        mkol := au_flu[ j, 6 ]
        Select TMP
        For i := 0 To 4
          lkod := { 0, mohu->kod_vr, mohu->PROFIL, ret_new_prvs( mohu->PRVS ), mohu->u_kod }[ i + 1 ]
          If i == 4 ; i := 5 ; Endif
          find ( Str( i, 1 ) + Str( lkod, 9 ) )
          If !Found()
            Append Blank
            tmp->tip := i
            tmp->kod := lkod
          Endif
          If is_dom
            tmp->p9 += mkol
            If is_selo
              tmp->p10 += mkol
            Endif
            If is_zabol
              tmp->p11 += mkol
            Endif
            If mvozrast < 18
              tmp->p12 += mkol
              If is_zabol
                tmp->p13 += mkol
              Endif
            Endif
          Else
            tmp->p3 += mkol
            If is_selo
              tmp->p4 += mkol
            Endif
            If mvozrast < 18
              tmp->p5 += mkol
            Endif
            If is_zabol
              If is_selo
                tmp->p6 += mkol
              Endif
              If mvozrast >= 18
                tmp->p7 += mkol
              Else
                tmp->p8 += mkol
              Endif
            Endif
          Endif
        Next
      Endif
    Next
  Else
    Select HU
    find ( Str( human->kod, 7 ) )
    Do While hu->kod == human->kod .and. !Eof()
      lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
      If f_paraklinika( usl->shifr, lshifr1, human->k_data )
        lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
        ta := f14tf_nastr( @lshifr,, d2_year )
        lshifr := AllTrim( lshifr )
        For j := 1 To Len( ta )
          k := ta[ j, 1 ]
          If Between( k, 1, 6 ) .and. ta[ j, 2 ] >= 0
            If ta[ j, 2 ] == 1 // �����祭�� ��砩
              mkol := human->k_data - human->n_data  // �����-����
              If Between( ta[ j, 1 ], 3, 5 ) // ������� ��樮��� �� 1 ��५�
                ++mkol
              Endif
            Elseif ta[ j, 2 ] == 0
              mkol := hu->kol_1
            Else
              mkol := 0
            Endif
            ii := 0 ; is_dom := .f.
            If k == 2 // ��樮���
              ii := 1
            Elseif eq_any( k, 1, 6 ) // �����������
              ii := 2
              If Year( human->k_data ) > 2012
                is_dom := ( hu->kol_rcp < 0 .and. domuslugatfoms( lshifr ) ) // �� ���� - �� ������
              Else
                is_dom := priem_na_domu( lshifr ) // �� ���� - �� ��஬�
                is_zabol := !priem_profilak( lshifr ) // �� ������ �����������
                If is_zabol .and. Left( human->KOD_DIAG, 1 ) == "Z" // ��䨫����᪨� ���
                  is_zabol := .f.
                Endif
              Endif
            Elseif eq_any( k, 3, 4, 5 ) // ������� ��樮���
              ii := k
            Endif
            If ii == 1 // ��樮���
              yes_30 := .t.
              AAdd( au_su1, { hu_->PROFIL, mkol } )
              // aadd(au_su1,{human_2->PROFIL_K,mkol})
            Elseif ii == 2  // �����������
              yes_30 := .t.
              Select TMP
              For i := 0 To 4
                lkod := { 0, hu->kod_vr, hu_->PROFIL, ret_new_prvs( hu_->PRVS ), hu->u_kod }[ i + 1 ]
                find ( Str( i, 1 ) + Str( lkod, 9 ) )
                If !Found()
                  Append Blank
                  tmp->tip := i
                  tmp->kod := lkod
                Endif
                If is_dom
                  tmp->p9 += mkol
                  If is_selo
                    tmp->p10 += mkol
                  Endif
                  If is_zabol
                    tmp->p11 += mkol
                  Endif
                  If mvozrast < 18
                    tmp->p12 += mkol
                    If is_zabol
                      tmp->p13 += mkol
                    Endif
                  Endif
                Else
                  tmp->p3 += mkol
                  If is_selo
                    tmp->p4 += mkol
                  Endif
                  If mvozrast < 18
                    tmp->p5 += mkol
                  Endif
                  If is_zabol
                    If is_selo
                      tmp->p6 += mkol
                    Endif
                    If mvozrast >= 18
                      tmp->p7 += mkol
                    Else
                      tmp->p8 += mkol
                    Endif
                  Endif
                Endif
              Next
            Endif
          Endif
        Next
      Endif
      Select HU
      Skip
    Enddo
  Endif
  If yes_30
    ++jh1
    For j := 1 To Len( au_su1 ) // ��樮���
      Select TMP1
      For i := 0 To 1
        lkod := iif( i == 0, 0, au_su1[ j, 1 ] )
        find ( Str( i, 1 ) + Str( lkod, 9 ) )
        If !Found()
          Append Blank
          tmp1->tip := i
          tmp1->kod := lkod
        Endif
        tmp1->p14 += au_su1[ j, 2 ]
        If fl_pensioner
          tmp1->p15 += au_su1[ j, 2 ]
        Endif
        If j == Len( au_su1 )
          tmp1->p5++
          If is_selo
            tmp1->p6++
          Endif
          If mvozrast < 18
            tmp1->p7++
          Endif
          If fl_pensioner
            tmp1->p8++
          Endif
          If fl_death
            tmp1->p12++
            If fl_pensioner
              tmp1->p13++
            Endif
          Else
            tmp1->p9++
            If fl_pensioner
              tmp1->p10++
            Endif
            If human_->RSLT_NEW == 103 // ��ॢ��� � ������� ��樮���
              tmp1->p11++
            Endif
          Endif
        Endif
      Next
    Next
  Endif

  Return jh + 1

// 03.12.15
Function f2_f30( s1, s2, par )

  Local i, s, lal := "tmp->p", n1 := 3, n2 := 13

  If s2 == NIL
    s := PadR( s1, 26 )
  Else
    s := PadR( s1, 23 ) + " " + s2
  Endif
  If par != Nil .and. par == 2
    n1 := 5 ; n2 := 15 ; lal := "tmp1->p"
  Endif
  For i := n1 To n2
    s += put_val( &( lal + lstr( i ) ), 7 )
  Next
  If verify_ff( HH, .t., sh )
    AEval( arr_title, {| x| add_string( x ) } )
  Endif
  add_string( s )

  Return Nil

// 08.01.19
Function f1_f30_dop( jh, jh1 )

  Local i, j, k, n, mvozrast, is_selo, is_dom, is_zabol, fl_stom_new := .f., au_lu := {}, au_flu := {}, ;
    lshifr, lshifr1, yes_30 := .f., fl_pensioner := .f., fl_death := .f., ;
    d2_year := Year( human->k_data ), au_su1 := {}, vid_vp := 0 // �� 㬮�砭�� ��䨫��⨪�

  If human_->NOVOR > 0
    mvozrast := count_years( human_->DATE_R2, human->n_data )
  Else
    mvozrast := count_years( human->date_r, human->n_data )
  Endif
  is_selo := f_is_selo( kart_->gorod_selo, kart_->okatog )  // �ਧ��� ᥫ�
  If ( human->pol == "�" .and. mvozrast >= 55 ) .or. ;
      ( human->pol == "�" .and. mvozrast >= 60 )
    fl_pensioner := .t.
  Endif
  If is_death( human_->RSLT_NEW ) // ᬥ���
    fl_death := .t.
  Endif
  Select HU
  find ( Str( human->kod, 7 ) )
  Do While hu->kod == human->kod .and. !Eof()
    lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
    If f_paraklinika( usl->shifr, lshifr1, human->k_data )
      lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
      If is_2_stomat( lshifr,, .t. ) > 0
        fl_stom_new := .t.
        AAdd( au_lu, { lshifr, ;              // 1
          c4tod( hu->date_u ), ;   // 2
        hu_->profil, ;         // 3
          hu_->PRVS, ;           // 4
          AllTrim( usl->shifr ), ; // 5
        hu->kol_1, ;           // 6
          c4tod( hu->date_u ), ;   // 7
        hu_->kod_diag, ;       // 8
        hu->( RecNo() ), ;       // 9 - ����� �����
        0 } )                   // 10 - ��� ������
      Endif
      If eq_any( Left( lshifr, 5 ), "2.80.", "2.82." )
        vid_vp := 1 // � ���⫮���� �ଥ ��� ���饭�� � ��񬭮� �����
        Exit
      Elseif eq_any( Left( lshifr, 5 ), "2.78.", "2.89." )
        vid_vp := 2 // �� ������ �����������
        Exit
      Elseif Left( lshifr, 5 ) == "2.88."
        vid_vp := 2 // ࠧ���� �� ������ �����������
        Exit
      Elseif d2_year < 2016 .and. Left( lshifr, 3 ) == "57." // �⮬�⮫����
        For i := 1 To 3
          ar := {}
          f_vid_p_stom( {}, {}, ar, { i } )
          If AScan( ar, lshifr ) > 0
            If i == 1 // � ��祡��� 楫��
              vid_vp := 3 // �� ������ �����������
            Elseif i == 2 // // � ��䨫����᪮� 楫��
              vid_vp := 1 // ��䨫��⨪�
            Else // // �� �������� ���⫮���� �����
              vid_vp := 2 // � ���⫮���� �ଥ
            Endif
            Exit
          Endif
        Next
        If vid_vp > 0
          --vid_vp
          Exit
        Endif
      Endif
    Endif
    Select HU
    Skip
  Enddo
  is_zabol := ( vid_vp > 0 )
  If fl_stom_new
    Select MOHU
    find ( Str( human->kod, 7 ) )
    Do While mohu->kod == human->kod .and. !Eof()
      AAdd( au_flu, { mosu->shifr1, ;         // 1
        c4tod( mohu->date_u ), ;  // 2
      mohu->profil, ;         // 3
        mohu->PRVS, ;           // 4
        mosu->shifr, ;          // 5
        mohu->kol_1, ;          // 6
        c4tod( mohu->date_u2 ), ; // 7
      mohu->kod_diag, ;       // 8
        mohu->( RecNo() ), ;      // 9 - ����� �����
      0 } )                    // 10 - ��� ������
      Select MOHU
      Skip
    Enddo
    f_vid_p_stom( au_lu, {},,, human->k_data,,,, au_flu )
    For j := 1 To Len( au_flu )
      If au_flu[ j, 10 ] == 1 // ���� ��祡�� ��񬮬
        mohu->( dbGoto( au_flu[ j, 9 ] ) )
        is_dom := .f. // �� ����
        yes_30 := .t.
        mkol := au_flu[ j, 6 ]
        Select TMP2
        For i := 0 To 4
          lkod := { 0, mohu->kod_vr, mohu->PROFIL, ret_new_prvs( mohu->PRVS ), mohu->u_kod }[ i + 1 ]
          If i == 4 ; i := 5 ; Endif
          find ( Str( i, 1 ) + Str( lkod, 9 ) )
          If !Found()
            Append Blank
            tmp2->tip := i
            tmp2->kod := lkod
          Endif
          tmp2->p2 += mkol
          If is_selo             // ᥫ�
            tmp2->p3 += mkol
          Endif
          If fl_pensioner        // ���� ��㤮ᯮᮡ����
            tmp2->p4 += mkol
            If is_selo
              tmp2->p5 += mkol    // ���� ��㤮�+ᥫ�
            Endif
          Endif
          If mvozrast < 18       // ��� �� 18 ���
            tmp2->p6 += mkol
            If mvozrast < 15
              tmp2->p7 += mkol    // ��� �� 15 ���
            Endif
            If is_selo
              tmp2->p8 += mkol    // ��� �� 18 ��� +ᥫ�
            Endif
          Endif
          If is_zabol
            tmp2->p9 += mkol      // �ᥣ� �� �����������
            If is_selo
              tmp2->p10 += mkol   // ᥫ�
            Endif
            If mvozrast >= 18
              tmp2->p11 += mkol   // ���� 18 ���
              If fl_pensioner
                tmp2->p12 += mkol // ���� ��㤮ᯮᮡ����
              Endif
            Else
              tmp2->p13 += mkol   // ��� �� 18 ���
              If mvozrast < 15
                tmp2->p14 += mkol // ��� �� 15 ���
              Endif
              If is_selo
                tmp2->p15 += mkol // ��� �� 18 ��� + ᥫ�
              Endif
            Endif
          Endif
        Next
      Endif
    Next
  Else
    Select HU
    find ( Str( human->kod, 7 ) )
    Do While hu->kod == human->kod .and. !Eof()
      lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
      If f_paraklinika( usl->shifr, lshifr1, human->k_data )
        lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
        ta := f14tf_nastr( @lshifr,, d2_year )
        lshifr := AllTrim( lshifr )
        For j := 1 To Len( ta )
          k := ta[ j, 1 ]
          If Between( k, 1, 6 ) .and. ta[ j, 2 ] >= 0
            If ta[ j, 2 ] == 1 // �����祭�� ��砩
              mkol := human->k_data - human->n_data  // �����-����
              If Between( ta[ j, 1 ], 3, 5 ) // ������� ��樮��� �� 1 ��५�
                ++mkol
              Endif
            Elseif ta[ j, 2 ] == 0
              mkol := hu->kol_1
            Else
              mkol := 0
            Endif
            ii := 0 ; is_dom := .f.
            If k == 2 // ��樮���
              ii := 1
            Elseif eq_any( k, 1, 6 ) // �����������
              ii := 2
              If Year( human->k_data ) > 2012
                is_dom := ( hu->kol_rcp < 0 .and. domuslugatfoms( lshifr ) ) // �� ���� - �� ������
              Else
                is_dom := priem_na_domu( lshifr ) // �� ���� - �� ��஬�
                is_zabol := !priem_profilak( lshifr ) // �� ������ �����������
                If is_zabol .and. Left( human->KOD_DIAG, 1 ) == "Z" // ��䨫����᪨� ���
                  is_zabol := .f.
                Endif
              Endif
            Elseif eq_any( k, 3, 4, 5 ) // ������� ��樮���
              ii := k
            Endif
            If ii == 1 // ��樮���
              // yes_30 := .t.
              // aadd(au_su1,{hu_->PROFIL,mkol})
            Elseif ii == 2  // �����������
              yes_30 := .t.
              Select TMP2
              For i := 0 To 4
                lkod := { 0, hu->kod_vr, hu_->PROFIL, ret_new_prvs( hu_->PRVS ), hu->u_kod }[ i + 1 ]
                find ( Str( i, 1 ) + Str( lkod, 9 ) )
                If !Found()
                  Append Blank
                  tmp2->tip := i
                  tmp2->kod := lkod
                Endif
                tmp2->p2 += mkol
                If is_selo             // ᥫ�
                  tmp2->p3 += mkol
                Endif
                If fl_pensioner        // ���� ��㤮ᯮᮡ����
                  tmp2->p4 += mkol
                  If is_selo
                    tmp2->p5 += mkol    // ���� ��㤮�+ᥫ�
                  Endif
                Endif
                If mvozrast < 18       // ��� �� 18 ���
                  tmp2->p6 += mkol
                  If mvozrast < 15
                    tmp2->p7 += mkol    // ��� �� 15 ���
                  Endif
                  If is_selo
                    tmp2->p8 += mkol    // ��� �� 18 ��� +ᥫ�
                  Endif
                Endif
                If is_zabol
                  tmp2->p9 += mkol      // �ᥣ� �� �����������
                  If is_selo
                    tmp2->p10 += mkol   // ᥫ�
                  Endif
                  If mvozrast >= 18
                    tmp2->p11 += mkol   // ���� 18 ���
                    If fl_pensioner
                      tmp2->p12 += mkol // ���� ��㤮ᯮᮡ����
                    Endif
                  Else
                    tmp2->p13 += mkol   // ��� �� 18 ���
                    If mvozrast < 15
                      tmp2->p14 += mkol // ��� �� 15 ���
                    Endif
                    If is_selo
                      tmp2->p15 += mkol // ��� �� 18 ��� + ᥫ�
                    Endif
                  Endif
                Endif
              Next
            Endif
          Endif
        Next
      Endif
      Select HU
      Skip
    Enddo
  Endif

  Return jh + 1

// 08.01.19
Function f2_f30_dop( s1, s2, par )

  Local i, s, lal := "tmp2->p", n1 := 2, n2 := 15

  s := PadR( s1, 23 ) // +s2
  For i := n1 To n2
    s += put_val( &( lal + lstr( i ) ), 6 )
  Next
  If verify_ff( HH, .t., sh )
    AEval( arr_title, {| x| add_string( x ) } )
  Endif
  add_string( s )

  Return Nil

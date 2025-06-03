#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

Static lcount_uch  := 1
Static f39_nastr := "f39_nast.ini"
Static f39_sect := "��ଠ 39 - "

// 18.03.13
Function forma_39( k )

  Static si1 := 1, si2 := 1
  Local mas_pmt, mas_msg, mas_fun, j, uch_otd

  Default k To 1
  Do Case
  Case k == 1
    Private au1, au2, au3, au4, au5 := 2, au6, fl_povod, lp := Array( 23 ), ;
      _arr_if, _what_if := _init_if(), _arr_komit := {}
    get_nastr( .f. )
    mas_pmt := { "��ଠ 39 �� ~����", ;
      "��ଠ 39 �� ~�⤥�����", ;
      "��ଠ 39 �� ~��०�����", ;
      "��ଠ 39 �� ��~�����樨", ;
      "~����ன�� ��� 39 " + iif( au5 == 2, "[���]", "[�몫]" ) }
    mas_msg := { "��ᯥ�⪠ ��� 39 �� ����", ;
      "��ᯥ�⪠ ��� 39 �� �⤥�����", ;
      "��ᯥ�⪠ ��� 39 �� ��祡���� ��०�����", ;
      "��ᯥ�⪠ ��� 39 �� �࣠����樨, � ���ன ����� ������ ��०�����", ;
      "����ன�� ��� ��⠢����� ��� 39" }
    mas_fun := { "forma_39(11)", ;
      "forma_39(12)", ;
      "forma_39(13)", ;
      "forma_39(14)", ;
      "forma_39(15)" }
    popup_prompt( T_ROW, T_COL - 5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    forma_39_()
  Case k == 12
    forma_39otd()
  Case k == 13
    forma_39all()
  Case k == 14
    forma_39org()
  Case k == 15
    mas_pmt := { '"���饭�� � �-�� �� ������ �����������"', ;
      '"��䨫����᪨� �ਥ��� � �-��"', ;
      '"���饭�� �� ���� �� ������ �����������"', ;
      '"��䨫����᪨� �ਥ��� �� ����"', ;
      iif( au5 == 1, "���", "����" ) + '�祭�� ०��� ��ࠢ�����', ;
      '����祭�� � ����ன�� ࠡ��� � ������� ���饭��', ;
      '���� ����� ࠡ��� �⤥�����' }
    mas_msg := { '����ன�� ������� "���饭�� � �-�� �� ������ �����������" (������� N 6)', ;
      '����ன�� ������� "��䨫����᪨� �ਥ��� � �-��" (������� N 9)', ;
      '����ன�� ������� "���饭�� �� ���� �� ������ �����������" (������� N 11)', ;
      '����ன�� ������� "��䨫����᪨� �ਥ��� �� ����" (������� N 15-16)', ;
      '����祭��/�몫�祭�� ०��� ��ࠢ����� ��� 39', ;
      '����祭�� � ����ன�� ࠡ��� � ������� ���饭��', ;
      '���� ����� ࠡ��� �⤥�����' }
    mas_fun := { "forma_39(21)", ;
      "forma_39(22)", ;
      "forma_39(23)", ;
      "forma_39(24)", ;
      "forma_39(25)", ;
      "forma_39(26)", ;
      "forma_39(27)" }
    popup_prompt( T_ROW - 3 -Len( mas_pmt ), T_COL - 5, si2, mas_pmt, mas_msg, mas_fun )
  Case Between( k, 21, 24 )
    forma_39_na( k - 20 )
  Case k == 25
    nfile := dir_server() + f39_nastr
    name_sect := f39_sect + "5"
    name_var := "�����������"
    ar := getinivar( nFile, { { name_sect, name_var, "2" } } )
    If ( j := f_alert( { '�믮����� ��ࠢ����� ��� 39 ?', ;
        "" }, ;
        { " ~��� ", ;
        " ~�� " }, ;
        Int( Val( ar[ 1 ] ) ), "N+/BG*", "R/BG*", 18,, col1menu ) ) > 0
      setinivar( nFile, { { name_sect, name_var, j } } )
      If au5 != j
        Keyboard Chr( K_ESC ) + Chr( K_ESC ) + Chr( K_ENTER )
      Endif
    Endif
  Case k == 26
    forma_39_povod()
  Case k == 27
    plan_39()
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

// 14.10.24
Function forma_39_()

  Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
    fl_exit := .f., HH := 58, reg_print := 3, speriod, ;
    arr_title, name_file := cur_dir() + "_form_39.txt", s_lu := 0, s_human := 0, ;
    kh := 0, jh := 0, arr_m, arr_pl

  If !get_nastr()
    Return Nil
  Endif
  If ( st_a_uch := inputn_uch( T_ROW, T_COL - 5,,, @lcount_uch ) ) == NIL
    Return Nil
  Endif
  If ( arr_pl := ret_oms_pl( T_ROW, T_COL - 5 ) ) == NIL
    Return Nil
  Endif
  If AScan( arr_pl, F_YES_OMS ) > 0 .and. !fbp_ist_fin( T_ROW, T_COL - 5 )
    Return Nil
  Endif
  If !input_perso( T_ROW, T_COL - 5, .f. )
    Return Nil
  Endif
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  speriod := arr_m[ 4 ]
  begin_date := arr_m[ 7 ]
  end_date := arr_m[ 8 ]
  //
  waitstatus( iif( au5 == 2, "�", "��" ) + "���祭 ०�� ��ࠢ�����" )
  mark_keys( { "<Esc>" } )
  //
  cre_tmp( { { "data", "C", 4, 0 } } )
  Use ( cur_dir() + "tmp" ) New Alias TMP
  Index On Data to ( cur_dir() + "tmp" )
  r_use( dir_server() + "mo_otd",, "OTD" )
  If AScan( arr_pl, F_YES_OMS ) > 0
    If pi1 == 1  // �� ��� ����砭�� ��祭��
      r_use( dir_server() + "human_u", dir_server() + "human_u", "HU" )
      r_use( dir_server() + "human_",, "HUMAN_" )
      r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
      Set Relation To RecNo() into HUMAN_
      dbSeek( DToS( arr_m[ 5 ] ), .t. )
      Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        If human_->oplata < 9 .and. func_pi_schet() .and. ( arr := yes_f_39( 1, glob_human[ 1 ] ) ) != NIL
          ++jh
          For i := 1 To Len( arr )
            Select TMP
            find ( arr[ i, 1 ] )  // ���� �� ��� ��㣨
            If !Found()
              Append Blank
              tmp->data := arr[ i, 1 ]
            Endif
            write_f39( arr[ i ] )
          Next
        Endif
        @ MaxRow(), 1 Say lstr( ++kh ) Color cColorSt2Msg
        If jh > 0
          @ Row(), Col() Say "/" Color "W/R"
          @ Row(), Col() Say lstr( jh ) Color cColorStMsg
        Endif
        Select HUMAN
        Skip
      Enddo
    Else
      r_use( dir_server() + "human_u", dir_server() + "human_u", "HU" )
      r_use( dir_server() + "human_",, "HUMAN_" )
      r_use( dir_server() + "human", dir_server() + "humans", "HUMAN" )
      Set Relation To RecNo() into HUMAN_
      r_use( dir_server() + "schet_",, "SCHET_" )
      r_use( dir_server() + "schet", dir_server() + "schetd", "SCHET" )
      Set Relation To RecNo() into SCHET_
      Set Filter To Empty( schet_->IS_DOPLATA )
      dbSeek( begin_date, .t. )
      Do While schet->pdate <= end_date .and. !Eof()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        Select HUMAN
        find ( Str( schet->kod, 6 ) )
        Do While human->schet == schet->kod .and. !Eof()
          updatestatus()
          If Inkey() == K_ESC
            fl_exit := .t. ; Exit
          Endif
          If human_->oplata < 9 .and. ( arr := yes_f_39( 1, glob_human[ 1 ] ) ) != NIL
            ++jh
            For i := 1 To Len( arr )
              Select TMP
              find ( arr[ i, 1 ] )  // ���� �� ��� ��㣨
              If !Found()
                Append Blank
                tmp->data := arr[ i, 1 ]
              Endif
              write_f39( arr[ i ] )
            Next
          Endif
          @ MaxRow(), 1 Say lstr( ++kh ) Color cColorSt2Msg
          If jh > 0
            @ Row(), Col() Say "/" Color "W/R"
            @ Row(), Col() Say lstr( jh ) Color cColorStMsg
          Endif
          Select HUMAN
          Skip
        Enddo
        If fl_exit ; exit ; Endif
        Select SCHET
        Skip
      Enddo
    Endif
  Endif
  If AScan( arr_pl, F_YES_PL ) > 0
    r_use( dir_server() + "kartotek",, "KART" )
    r_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HU_P" )
    r_use( dir_server() + "hum_p", dir_server() + "hum_pd", "HUM_P" )
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    Do While hum_p->k_data <= arr_m[ 6 ] .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      If ( arr := yes_f_39_pl( 1, glob_human[ 1 ] ) ) != NIL
        ++jh
        For i := 1 To Len( arr )
          Select TMP
          find ( arr[ i, 1 ] )  // ���� �� ��� ��㣨
          If !Found()
            Append Blank
            tmp->data := arr[ i, 1 ]
          Endif
          write_f39( arr[ i ] )
        Next
      Endif
      @ MaxRow(), 1 Say lstr( ++kh ) Color cColorSt2Msg
      If jh > 0
        @ Row(), Col() Say "/" Color "BG/R"
        @ Row(), Col() Say lstr( jh ) Color cColorStMsg
      Endif
      Select HUM_P
      Skip
    Enddo
  Endif
  j := tmp->( LastRec() )
  Private regim := 1
  arr_title := f39_title()
  Private sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  f39_shapka()
  titlen_uch( st_a_uch, sh, lcount_uch )
  _tit_ist_fin( sh )
  s := " �.�.�. � ��������� ���: " + AllTrim( glob_human[ 2 ] )
  s += " [" + lstr( glob_human[ 5 ] ) + "]"   // ⠡.�����
  If Len( glob_human ) > 5 .and. !Empty( glob_human[ 6 ] )
    s += " (" + glob_human[ 6 ] + ")"       // ���������
  Endif
  frt->name1 := s
  add_string( s )
  If pi1 == 1
    s := " " + str_pi_schet()
  Else
    s := " [ �� ��� �믨᪨ ��� ]"
  Endif
  frt->name2 := speriod + s
  add_string( "                           " + speriod + s )
  s := " ���⮪: ����ਠ��� � ________ �客�� � ________"
  add_string( s )
  frt->name3 := s
  //
  Private sp[ 20 ]
  AFill( sp, 0 )
  Select TMP
  Go Top
  AEval( arr_title, {| x| add_string( x ) } )
  arr_title := f39_title2()
  Do While !Eof()
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    f_str_39( Left( DToC( c4tod( tmp->data ) ), 5 ), 1 )
    Select TMP
    Skip
  Enddo
  add_string( Replicate( "-", sh ) )
  f_str_39( "�ᥣ�", 2 )
  add_string( "" )
  frt->name5 := "������� ��� ________________"
  FClose( fp )
  Close databases
  rest_box( buf )
  If j == 0
    func_error( 4, "��� ���ଠ樨!" )
  Else
    name_fr := "mo_f39" + sfr3()
    If _upr_epson() .or. !File( dir_exe() + name_fr )
      viewtext( name_file,,,, .t.,,, reg_print )
    Else
      call_fr( name_fr )
    Endif
  Endif

  Return Nil

// 23.12.12
Function f39_shapka()

  Local arr_org := Array( 3 )

  r_use( dir_server() + "organiz",, "ORG" )
  perenos( arr_org, org->name, 30 )
  frt->name_org := org->name
  org->( dbCloseArea() )
  add_string( PadC( "��������⢮ ��ࠢ���࠭����", 30 ) +      PadL( "��ଠ � 039/�-02", sh - 30 ) )
  add_string( PadC( "���ᨩ᪮� �����樨",        30 ) +   PadL( "�⢥ত��� �ਪ����", sh - 30 ) )
  add_string( PadC( AllTrim( arr_org[ 1 ] ),           30 ) +      PadL( "�����ࠢ� ���ᨨ", sh - 30 ) )
  add_string( PadC( AllTrim( arr_org[ 2 ] ),           30 ) + PadL( "�� 30.12.2002�. N 413", sh - 30 ) )
  add_string( PadC( AllTrim( arr_org[ 3 ] ),           30 ) )
  add_string( Center( "���������", sh ) )
  add_string( Center( "����� ��������� ���������", sh ) )
  add_string( Center( "� ����������� - ��������������� �����������, �� ����", sh ) )
  add_string( "" )

  Return Nil

// 23.12.12
Function f39_title()

  Local arr := Array( 15 )

  If regim == 1
    arr[ 1 ] := "�����"
    arr[ 2 ] := "��� "
    arr[ 3 ] := "     "
    arr[ 4 ] := "     "
    arr[ 5 ] := "     "
    arr[ 6 ] := "     "
    arr[ 7 ] := "     "
    arr[ 8 ] := "     "
    arr[ 9 ] := "     "
    arr[ 10 ] := "     "
    arr[ 11 ] := "     "
    arr[ 12 ] := "     "
    arr[ 13 ] := "�����"
    arr[ 14 ] := "1    "
    arr[ 15 ] := "�����"
    frt->name4 := "���"
  Else
    arr[ 1 ] := "����������������"
    arr[ 2 ] := "                "
    arr[ 3 ] := "                "
    arr[ 4 ] := "                "
    arr[ 5 ] := "                "
    arr[ 6 ] := "                "
    arr[ 7 ] := "                "
    arr[ 8 ] := "                "
    arr[ 9 ] := "                "
    arr[ 10 ] := "                "
    arr[ 11 ] := "                "
    arr[ 12 ] := "                "
    arr[ 13 ] := "����������������"
    arr[ 14 ] := "1               "
    arr[ 15 ] := "����������������"
  Endif
  arr[ 1 ] := arr[ 1 ] + "������������������������������������������������������������������������������������������������������������������"
  arr[ 2 ] := arr[ 2 ] + "���᫮ ��-  �� ⮬ �᫥��� ��饣� �᫠  ���䨳��᫮� �� ��饣� �᫠ ���饭�� �� ���� �    ��᫮ ���饭��    "
  arr[ 3 ] := arr[ 3 ] + "��饭�� �  �� ������ ����饭�� � ����-����⨳���-�                                   �    �� ����� ������    "
  arr[ 4 ] := arr[ 4 ] + "�������������(�� ����  �������� �� ��������- �饭��������������������������������������������������������������"
  arr[ 5 ] := arr[ 5 ] + "�           �2)         ������������      ����  ���   � �� ������ ����������� ��� �᫠   � ��� ���- �����-� ��� "
  arr[ 6 ] := arr[ 6 ] + "�����������Ĵ           �����������������Ĵ     ����� �����������������������Ĵ��䨫���-�     ����  ���  �     "
  arr[ 7 ] := arr[ 7 ] + "��ᥣ����   �           ��ᥣ��� �.�.     �     �(��-��ᥣ��� �.�. � �����⥳�᪨�     �     �     �     �     "
  arr[ 8 ] := arr[ 8 ] + "�     ����  �           �     �� ������ �     ���)  �     �����������������������������Ĵ     �     �     �     "
  arr[ 9 ] := arr[ 9 ] + "�     �ᥫ�-�����������Ĵ     �����������Ĵ     �     �     �0-17 ��    �60���0-17 ��    �     �     �     �     "
  arr[ 10 ] := arr[ 10 ] + "�     �c��� �0-17 �60���     �0-17 �60���     �     �     ����  ��.�. �� �⠳���  ��.�. �     �     �     �     "
  arr[ 11 ] := arr[ 11 ] + "�     ����-����  �� �⠳     ����  �� �⠳     �     �     �     �0-1  ���  �     �0-1  �     �     �     �     "
  arr[ 12 ] := arr[ 12 ] + "�     ����  �     ���  �     �     ���  �     �     �     �     ����  �     �     ����  �     �     �     �     "
  arr[ 13 ] := arr[ 13 ] + "������������������������������������������������������������������������������������������������������������������"
  arr[ 14 ] := arr[ 14 ] + "�2    �3    �4    �5    �6    �7    �8    �9    �10   �11   �12   �13   �14   �15   �16   �17   �18   �19   �20   "
  arr[ 15 ] := arr[ 15 ] + "������������������������������������������������������������������������������������������������������������������"

  Return arr

//
Function f39_title2()

  Local arr := Array( 3 )

  If regim == 1
    arr[ 1 ] := "�����"
    arr[ 2 ] := "1    "
    arr[ 3 ] := "�����"
  Else
    arr[ 1 ] := "����������������"
    arr[ 2 ] := "1               "
    arr[ 3 ] := "����������������"
  Endif
  arr[ 1 ] := arr[ 1 ] + "������������������������������������������������������������������������������������������������������������������"
  arr[ 2 ] := arr[ 2 ] + "�2    �3    �4    �5    �6    �7    �8    �9    �10   �11   �12   �13   �14   �15   �16   �17   �18   �19   �20   "
  arr[ 3 ] := arr[ 3 ] + "������������������������������������������������������������������������������������������������������������������"

  Return arr

// 14.10.24
Function forma_39otd()

  Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
    fl_exit := .f., HH := 58, reg_print := 3, speriod, ;
    arr_title, name_file := cur_dir() + "_form_39.txt", s_lu := 0, s_human := 0, ;
    kh := 0, jh := 0, arr_m, arr_pl

  If !get_nastr()
    Return Nil
  Endif
  If input_uch( T_ROW, T_COL - 5, sys_date ) == Nil .or. input_otd( T_ROW, T_COL - 5, sys_date ) == NIL
    Return Nil
  Endif
  If ( arr_pl := ret_oms_pl( T_ROW, T_COL - 5 ) ) == NIL
    Return Nil
  Endif
  If AScan( arr_pl, F_YES_OMS ) > 0 .and. !fbp_ist_fin( T_ROW, T_COL - 5 )
    Return Nil
  Endif
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  speriod := arr_m[ 4 ]
  begin_date := arr_m[ 7 ]
  end_date := arr_m[ 8 ]
  //
  waitstatus( iif( au5 == 2, "�", "��" ) + "���祭 ०�� ��ࠢ�����" )
  //
  cre_tmp( { { "p_kod", "N", 4, 0 }, ;
    { "tab_nom", "N", 5, 0 }, ;
    { "name", "C", 30, 0 } } )
  Use ( cur_dir() + "tmp" ) New Alias TMP
  Index On Str( p_kod, 4 ) to ( cur_dir() + "tmp" )
  r_use( dir_server() + "mo_otd",, "OTD" )
  If AScan( arr_pl, F_YES_OMS ) > 0
    If pi1 == 1  // �� ��� ����砭�� ��祭��
      r_use( dir_server() + "human_u", dir_server() + "human_u", "HU" )
      r_use( dir_server() + "human_",, "HUMAN_" )
      r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
      Set Relation To RecNo() into HUMAN_
      dbSeek( DToS( arr_m[ 5 ] ), .t. )
      Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        If human_->oplata < 9 .and. func_pi_schet() .and. ( arr := yes_f_39( 2, glob_otd[ 1 ] ) ) != NIL
          ++jh
          For i := 1 To Len( arr )
            Select TMP
            find ( Str( arr[ i, 21 ], 4 ) )  // ���� �� ���� ���
            If !Found()
              Append Blank
              tmp->p_kod := arr[ i, 21 ]
            Endif
            write_f39( arr[ i ] )
          Next
        Endif
        @ MaxRow(), 1 Say lstr( ++kh ) Color cColorSt2Msg
        If jh > 0
          @ Row(), Col() Say "/" Color "W/R"
          @ Row(), Col() Say lstr( jh ) Color cColorStMsg
        Endif
        Select HUMAN
        Skip
      Enddo
    Else
      r_use( dir_server() + "human_u", dir_server() + "human_u", "HU" )
      r_use( dir_server() + "human_",, "HUMAN_" )
      r_use( dir_server() + "human", dir_server() + "humans", "HUMAN" )
      Set Relation To RecNo() into HUMAN_
      r_use( dir_server() + "schet_",, "SCHET_" )
      r_use( dir_server() + "schet", dir_server() + "schetd", "SCHET" )
      Set Relation To RecNo() into SCHET_
      Set Filter To Empty( schet_->IS_DOPLATA )
      dbSeek( begin_date, .t. )
      Do While schet->pdate <= end_date .and. !Eof()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        Select HUMAN
        find ( Str( schet->kod, 6 ) )
        Do While human->schet == schet->kod .and. !Eof()
          updatestatus()
          If Inkey() == K_ESC
            fl_exit := .t. ; Exit
          Endif
          If human_->oplata < 9 .and. ( arr := yes_f_39( 2, glob_otd[ 1 ] ) ) != NIL
            ++jh
            For i := 1 To Len( arr )
              Select TMP
              find ( Str( arr[ i, 21 ], 4 ) )  // ���� �� ���� ���
              If !Found()
                Append Blank
                tmp->p_kod := arr[ i, 21 ]
              Endif
              write_f39( arr[ i ] )
            Next
          Endif
          @ MaxRow(), 1 Say lstr( ++kh ) Color cColorSt2Msg
          If jh > 0
            @ Row(), Col() Say "/" Color "W/R"
            @ Row(), Col() Say lstr( jh ) Color cColorStMsg
          Endif
          Select HUMAN
          Skip
        Enddo
        If fl_exit ; exit ; Endif
        Select SCHET
        Skip
      Enddo
    Endif
  Endif
  If AScan( arr_pl, F_YES_PL ) > 0
    r_use( dir_server() + "kartotek",, "KART" )
    r_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HU_P" )
    r_use( dir_server() + "hum_p", dir_server() + "hum_pd", "HUM_P" )
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    Do While hum_p->k_data <= arr_m[ 6 ] .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      If ( arr := yes_f_39_pl( 2, glob_otd[ 1 ] ) ) != NIL
        ++jh
        For i := 1 To Len( arr )
          Select TMP
          find ( Str( arr[ i, 21 ], 4 ) )  // ���� �� ���� ���
          If !Found()
            Append Blank
            tmp->p_kod := arr[ i, 21 ]
          Endif
          write_f39( arr[ i ] )
        Next
      Endif
      @ MaxRow(), 1 Say lstr( ++kh ) Color cColorSt2Msg
      If jh > 0
        @ Row(), Col() Say "/" Color "BG/R"
        @ Row(), Col() Say lstr( jh ) Color cColorStMsg
      Endif
      Select HUM_P
      Skip
    Enddo
  Endif
  If ( j := tmp->( LastRec() ) ) > 0
    r_use( dir_server() + "mo_pers",, "P2" )
    tmp->( dbEval( {|| p2->( dbGoto( tmp->p_kod ) ), ;
      tmp->tab_nom := p2->tab_nom, ;
      tmp->name := fam_i_o( p2->fio ) } ) )
    Select TMP
    Index On Upper( name ) to ( cur_dir() + "tmp" )
  Endif
  Private regim := 2
  arr_title := f39_title()
  Private sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  f39_shapka()
  _tit_ist_fin( sh )
  s := AllTrim( glob_otd[ 2 ] ) + " (" + AllTrim( glob_uch[ 2 ] ) + ")"
  add_string( Center( s, sh ) )
  frt->name1 := s
  s := "����� ��ਮ�: " + speriod
  add_string( Center( s, sh ) )
  frt->name2 := s
  If pi1 == 1
    s := str_pi_schet()
  Else
    s := "[ �� ��� �믨᪨ ��� ]"
  Endif
  add_string( Center( s, sh ) )
  frt->name3 := s
  add_string( "" )
  //
  Private sp[ 20 ]
  AFill( sp, 0 )
  Select TMP
  Go Top
  AEval( arr_title, {| x| add_string( x ) } )
  arr_title := f39_title2()
  Do While !Eof()
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    ls1 := lstr( tmp->tab_nom, 6 ) + "/" + tmp->name
    f_str_39( Left( ls1, 16 ), 1, ls1 )
    Select TMP
    Skip
  Enddo
  add_string( Replicate( "-", sh ) )
  f_str_39( PadC( "�ᥣ�:", 16 ), 2 )
  FClose( fp )
  Close databases
  rest_box( buf )
  If j == 0
    func_error( 4, "��� ���ଠ樨!" )
  Else
    name_fr := "mo_f39" + sfr3()
    If _upr_epson() .or. !File( dir_exe() + name_fr )
      viewtext( name_file,,,, .t.,,, reg_print )
    Else
      call_fr( name_fr )
    Endif
  Endif

  Return Nil

// 07.02.13
Function forma_39all()

  Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
    fl_exit := .f., tm, ;
    s_lu := 0, s_human := 0, ;
    kh := 0, jh := 0, arr_m, arr_pl

  If !get_nastr()
    Return Nil
  Endif
  If input_uch( T_ROW, T_COL - 5, sys_date ) == NIL
    Return Nil
  Endif
  If ( arr_pl := ret_oms_pl( T_ROW, T_COL - 5 ) ) == NIL
    Return Nil
  Endif
  If AScan( arr_pl, F_YES_OMS ) > 0 .and. !fbp_ist_fin( T_ROW, T_COL - 5 )
    Return Nil
  Endif
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  Private speriod := arr_m[ 4 ]
  begin_date := arr_m[ 7 ]
  end_date := arr_m[ 8 ]
  //
  waitstatus( iif( au5 == 2, "�", "��" ) + "���祭 ०�� ��ࠢ�����" )
  //
  cre_tmp( { { "p_kod", "N", 4, 0 }, ;
    { "tip", "N", 1, 0 }, ;   // 1-���� ���ᮭ��, 2-����.� �⤥�����, 3-�⤥�����
  { "otd", "N", 3, 0 }, ;
    { "tab_nom", "N", 5, 0 }, ;
    { "name", "C", 30, 0 } } )
  Use ( cur_dir() + "tmp" ) New Alias TMP
  Index On Str( tip, 1 ) + Str( p_kod, 4 ) + Str( otd, 3 ) to ( cur_dir() + "tmp" )
  r_use( dir_server() + "mo_otd",, "OTD" )
  If AScan( arr_pl, F_YES_OMS ) > 0
    If pi1 == 1  // �� ��� ����砭�� ��祭��
      r_use( dir_server() + "human_u", dir_server() + "human_u", "HU" )
      r_use( dir_server() + "human_",, "HUMAN_" )
      r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
      Set Relation To RecNo() into HUMAN_
      dbSeek( DToS( arr_m[ 5 ] ), .t. )
      Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        If human_->oplata < 9 .and. func_pi_schet() .and. ( arr := yes_f_39( 0 ) ) != NIL
          ++jh
          For i := 1 To Len( arr )
            Select TMP
            find ( "1" + Str( arr[ i, 21 ], 4 ) )  // ���� �� ���� ���
            If !Found()
              Append Blank
              tmp->p_kod := arr[ i, 21 ]
              tmp->tip := 1
            Endif
            write_f39( arr[ i ] )
            Select TMP
            find ( "2" + Str( arr[ i, 21 ], 4 ) + Str( arr[ i, 22 ], 3 ) ) // ���+�⤥�����
            If !Found()
              Append Blank
              tmp->p_kod := arr[ i, 21 ]
              tmp->otd := arr[ i, 22 ]
              tmp->tip := 2
            Endif
            write_f39( arr[ i ] )
            Select TMP
            find ( "3" + Str( 0, 4 ) + Str( arr[ i, 22 ], 3 ) )  // ��०�����+�⤥�����
            If !Found()
              Append Blank
              tmp->otd := arr[ i, 22 ]
              tmp->tip := 3
            Endif
            write_f39( arr[ i ] )
          Next
        Endif
        @ MaxRow(), 1 Say lstr( ++kh ) Color cColorSt2Msg
        If jh > 0
          @ Row(), Col() Say "/" Color "W/R"
          @ Row(), Col() Say lstr( jh ) Color cColorStMsg
        Endif
        Select HUMAN
        Skip
      Enddo
    Else
      r_use( dir_server() + "human_u", dir_server() + "human_u", "HU" )
      r_use( dir_server() + "human_",, "HUMAN_" )
      r_use( dir_server() + "human", dir_server() + "humans", "HUMAN" )
      Set Relation To RecNo() into HUMAN_
      r_use( dir_server() + "schet_",, "SCHET_" )
      r_use( dir_server() + "schet", dir_server() + "schetd", "SCHET" )
      Set Relation To RecNo() into SCHET_
      Set Filter To Empty( schet_->IS_DOPLATA )
      dbSeek( begin_date, .t. )
      Do While schet->pdate <= end_date .and. !Eof()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        Select HUMAN
        find ( Str( schet->kod, 6 ) )
        Do While human->schet == schet->kod
          updatestatus()
          If Inkey() == K_ESC
            fl_exit := .t. ; Exit
          Endif
          If human_->oplata < 9 .and. ( arr := yes_f_39( 0 ) ) != NIL
            ++jh
            For i := 1 To Len( arr )
              Select TMP
              find ( "1" + Str( arr[ i, 21 ], 4 ) )  // ���� �� ���� ���
              If !Found()
                Append Blank
                tmp->p_kod := arr[ i, 21 ]
                tmp->tip := 1
              Endif
              write_f39( arr[ i ] )
              Select TMP
              find ( "2" + Str( arr[ i, 21 ], 4 ) + Str( arr[ i, 22 ], 3 ) ) // ���+�⤥�����
              If !Found()
                Append Blank
                tmp->p_kod := arr[ i, 21 ]
                tmp->otd := arr[ i, 22 ]
                tmp->tip := 2
              Endif
              write_f39( arr[ i ] )
              Select TMP
              find ( "3" + Str( 0, 4 ) + Str( arr[ i, 22 ], 3 ) )  // ��०�����+�⤥�����
              If !Found()
                Append Blank
                tmp->otd := arr[ i, 22 ]
                tmp->tip := 3
              Endif
              write_f39( arr[ i ] )
            Next
          Endif
          @ MaxRow(), 1 Say lstr( ++kh ) Color cColorSt2Msg
          If jh > 0
            @ Row(), Col() Say "/" Color "W/R"
            @ Row(), Col() Say lstr( jh ) Color cColorStMsg
          Endif
          Select HUMAN
          Skip
        Enddo
        If fl_exit ; exit ; Endif
        Select SCHET
        Skip
      Enddo
    Endif
  Endif
  If AScan( arr_pl, F_YES_PL ) > 0
    r_use( dir_server() + "kartotek",, "KART" )
    r_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HU_P" )
    r_use( dir_server() + "hum_p", dir_server() + "hum_pd", "HUM_P" )
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    Do While hum_p->k_data <= arr_m[ 6 ] .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      If ( arr := yes_f_39_pl( 0 ) ) != NIL
        ++jh
        For i := 1 To Len( arr )
          Select TMP
          find ( "1" + Str( arr[ i, 21 ], 4 ) )  // ���� �� ���� ���
          If !Found()
            Append Blank
            tmp->p_kod := arr[ i, 21 ]
            tmp->tip := 1
          Endif
          write_f39( arr[ i ] )
          Select TMP
          find ( "2" + Str( arr[ i, 21 ], 4 ) + Str( arr[ i, 22 ], 3 ) ) // ���+�⤥�����
          If !Found()
            Append Blank
            tmp->p_kod := arr[ i, 21 ]
            tmp->otd := arr[ i, 22 ]
            tmp->tip := 2
          Endif
          write_f39( arr[ i ] )
          Select TMP
          find ( "3" + Str( 0, 4 ) + Str( arr[ i, 22 ], 3 ) )  // ��०�����+�⤥�����
          If !Found()
            Append Blank
            tmp->otd := arr[ i, 22 ]
            tmp->tip := 3
          Endif
          write_f39( arr[ i ] )
        Next
      Endif
      @ MaxRow(), 1 Say lstr( ++kh ) Color cColorSt2Msg
      If jh > 0
        @ Row(), Col() Say "/" Color "BG/R"
        @ Row(), Col() Say lstr( jh ) Color cColorStMsg
      Endif
      Select HUM_P
      Skip
    Enddo
  Endif
  If ( j := tmp->( LastRec() ) ) > 0
    If Select( "OTD" ) == 0
      r_use( dir_server() + "mo_otd",, "OTD" )
    Endif
    r_use( dir_server() + "mo_pers",, "P2" )
    tmp->( dbEval( {|| p2->( dbGoto( tmp->p_kod ) ), otd->( dbGoto( tmp->otd ) ), ;
      tmp->tab_nom := p2->tab_nom, ;
      tmp->name := iif( tmp->tip == 3, otd->name, fam_i_o( p2->fio ) ) } ) )
  Endif
  Close databases
  rest_box( buf )
  If j == 0
    Return func_error( 4, "��� ���ଠ樨!" )
  Endif
  If Type( "MenuTo_Minut" ) == "N"
    tm := MenuTo_Minut
  Else
    Private MenuTo_Minut
  Endif
  mybell()
  MenuTo_Minut := 0  // �� ��室��� ��⮬���᪨ �� MENU TO
  Keyboard ""
  popup_prompt( T_ROW - 7, T_COL - 5, 1, ;
    { "���᮪ ~�⤥�����", ;
    "���᮪ ~���ᮭ���", ;
    "���ᮭ�� � �~⤥�����", ;
    "�⤥����� ����/~䠪�" },, ;
    { "f_39all_1(3)", ;
    "f_39all_1(1)", ;
    "f_39all_1(2)", ;
    "f_39all_2(3)" } )
  MenuTo_Minut := tm

  Return Nil

// 05.02.13
Function f_39all_1( par )

  Static sotd := 1
  Local buf, HH := 58, reg_print := 3, ;
    arr_title, name_file := cur_dir() + "_form_39.txt", s, ls1, ;
    arr := {}, arr_otd := {}, r := T_ROW, r2, c := T_COL - 5, i

  If par == 2
    buf := SaveScreen( r, 0, MaxRow(), MaxCol() )
    Use ( cur_dir() + "tmp" ) new
    Index On Upper( name ) to ( cur_dir() + "tmp" ) For tip == 3
    dbEval( {|| AAdd( arr, tmp->otd ), AAdd( arr_otd, tmp->name ) } )
    Use
    i := AScan( arr, sotd )
    If ( r2 := r + Len( arr ) + 1 ) > MaxRow() -2
      r2 := MaxRow() -2
    Endif
    status_key( "^<Esc>^ - ��室 ��� �롮�;  ^<Enter>^ - �롮� �⤥�����" )
    If ( i := Popup( r, c, r2, c + 33, arr_otd, i, color0, .t. ) ) > 0
      glob_otd := { arr[ i ], AllTrim( arr_otd[ i ] ) }
      sotd := arr[ i ]
    Endif
    RestScreen( r, 0, MaxRow(), MaxCol(), buf )
    If i == 0 ; Return NIL ; Endif
  Endif
  buf := save_maxrow()
  mywait()
  Use ( fr_data ) New Alias FRD
  Zap
  Use ( fr_titl ) New Alias FRT
  Use ( cur_dir() + "tmp" ) new
  Do Case
  Case par == 1
    Index On Upper( name ) to ( cur_dir() + "tmp" ) For tip == 1
  Case par == 2
    Index On Upper( name ) to ( cur_dir() + "tmp" ) For tip == 2 .and. otd == glob_otd[ 1 ]
  Case par == 3
    Index On Upper( name ) to ( cur_dir() + "tmp" ) For tip == 3
  Endcase
  Private regim := 2
  arr_title := f39_title()
  Private sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  f39_shapka()
  _tit_ist_fin( sh )
  s := AllTrim( glob_uch[ 2 ] )
  If par == 2
    s := glob_otd[ 2 ] + " [ " + s + " ]"
  Endif
  frt->name1 := s
  add_string( Center( s, sh ) )
  s := "����� ��ਮ�: " + speriod
  frt->name2 := s
  add_string( Center( s, sh ) )
  If pi1 == 1
    s := str_pi_schet()
  Else
    s := "[ �� ��� �믨᪨ ��� ]"
  Endif
  frt->name3 := s
  add_string( Center( s, sh ) )
  add_string( "" )
  //
  Private sp[ 20 ]
  AFill( sp, 0 )
  Select TMP
  Go Top
  AEval( arr_title, {| x| add_string( x ) } )
  arr_title := f39_title2()
  Do While !Eof()
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    If par == 3
      ls1 := tmp->name
    Else
      ls1 := lstr( tmp->tab_nom, 6 ) + "/" + tmp->name
    Endif
    f_str_39( Left( ls1, 16 ), 1, ls1 )
    Select TMP
    Skip
  Enddo
  add_string( Replicate( "-", sh ) )
  f_str_39( PadC( "�ᥣ�:", 16 ), 2 )
  FClose( fp )
  Close databases
  rest_box( buf )
  name_fr := "mo_f39" + sfr3()
  If _upr_epson() .or. !File( dir_exe() + name_fr )
    viewtext( name_file,,,, .t.,,, reg_print )
  Else
    call_fr( name_fr )
  Endif

  Return Nil

//
Function f_39all_2( par )

  Static sotd := 1
  Local buf, sh, HH := 58, reg_print := 3, ;
    arr_title, name_file := cur_dir() + "_form_39.txt", s, ls1, ;
    arr := {}, arr_otd := {}, r := T_ROW, r2, c := T_COL - 5, i

  If par == 2
    buf := SaveScreen( r, 0, MaxRow(), MaxCol() )
    Use ( cur_dir() + "tmp" ) new
    Index On Upper( name ) to ( cur_dir() + "tmp" ) For tip == 3
    dbEval( {|| AAdd( arr, tmp->otd ), AAdd( arr_otd, tmp->name ) } )
    Use
    i := AScan( arr, sotd )
    If ( r2 := r + Len( arr ) + 1 ) > MaxRow() -2
      r2 := MaxRow() -2
    Endif
    status_key( "^<Esc>^ - ��室 ��� �롮�;  ^<Enter>^ - �롮� �⤥�����" )
    If ( i := Popup( r, c, r2, c + 28, arr_otd, i, color0, .t. ) ) > 0
      glob_otd := { arr[ i ], AllTrim( arr_otd[ i ] ) }
      sotd := arr[ i ]
    Endif
    RestScreen( r, 0, MaxRow(), MaxCol(), buf )
    If i == 0 ; Return NIL ; Endif
  Endif
  buf := save_maxrow()
  mywait()
  Use ( cur_dir() + "tmp" ) new
  Do Case
  Case par == 1
    Index On Upper( name ) to ( cur_dir() + "tmp" ) For tip == 1
  Case par == 2
    Index On Upper( name ) to ( cur_dir() + "tmp" ) For tip == 2 .and. otd == glob_otd[ 1 ]
  Case par == 3
    Index On Upper( name ) to ( cur_dir() + "tmp" ) For tip == 3
  Endcase
  arr_title := { ;
    "����������������������������������������������������������������������������������������������", ;
    "                               �  ��祡��� �ਥ��� �    ��䨫��⨪     � ���饭�� �� ����  ", ;
    "                               ���������������������������������������������������������������", ;
    "                               � ���� � 䠪� �  %%  � ���� � 䠪� �  %%  � ���� � 䠪� �  %%  ", ;
    "����������������������������������������������������������������������������������������������" }
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  add_string( Center( "���������", sh ) )
  add_string( Center( "��� ��祡��� ���饭��", sh ) )
  add_string( Center( "� ���㫠�୮-����������᪨� ��०������, �� ����", sh ) )
  s := AllTrim( glob_uch[ 2 ] )
  If par == 2
    s := glob_otd[ 2 ] + " [ " + s + " ]"
  Endif
  add_string( Center( s, sh ) )
  add_string( Center( "����� ��ਮ�: " + speriod, sh ) )
  add_string( "" )
  //
  sp1 := sp2 := sp3 := sp4 := sp5 := sp6 := 0
  r_use( dir_server() + "mo_otd",, "OTD" )
  Select TMP
  Set Relation To otd into OTD
  Go Top
  AEval( arr_title, {| x| add_string( x ) } )
  Do While !Eof()
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    If par == 3
      ls1 := tmp->name
    Else
      ls1 := AllTrim( tmp->name ) + " [" + lstr( tmp->tab_nom ) + "]"
    Endif
    ls1 := PadR( ls1, 31 )
    pr1 := pr2 := pr3 := 0
    If otd->plan_vp > 0
      pr1 := tmp->p2 / otd->plan_vp * 100
    Endif
    If otd->plan_pf > 0
      pr2 := tmp->p9 / otd->plan_pf * 100
    Endif
    If otd->plan_pd > 0
      pr3 := tmp->p10 / otd->plan_pd * 100
    Endif
    ls1 += " " + put_val( otd->plan_vp, 6 ) + ;
      " " + put_val( tmp->p2, 6 ) + ;
      " " + umest_val( pr1, 6, 2 ) + ;
      " " + put_val( otd->plan_pf, 6 ) + ;
      " " + put_val( tmp->p9, 6 ) + ;
      " " + umest_val( pr2, 6, 2 ) + ;
      " " + put_val( otd->plan_pd, 6 ) + ;
      " " + put_val( tmp->p10, 6 ) + ;
      " " + umest_val( pr3, 6, 2 )
    add_string( ls1 )
    sp1 += otd->plan_vp
    sp2 += tmp->p2
    sp3 += otd->plan_pf
    sp4 += tmp->p9
    sp5 += otd->plan_pd
    sp6 += tmp->p10
    Skip
  Enddo
  add_string( Replicate( "-", sh ) )
  ls1 := PadC( "�ᥣ�:", 31 )
  pr1 := pr2 := pr3 := 0
  If sp1 > 0
    pr1 := sp2 / sp1 * 100
  Endif
  If sp3 > 0
    pr2 := sp4 / sp3 * 100
  Endif
  If sp5 > 0
    pr3 := sp6 / sp5 * 100
  Endif
  ls1 += " " + put_val( sp1, 6 ) + ;
    " " + put_val( sp2, 6 ) + ;
    " " + umest_val( pr1, 6, 2 ) + ;
    " " + put_val( sp3, 6 ) + ;
    " " + put_val( sp4, 6 ) + ;
    " " + umest_val( pr2, 6, 2 ) + ;
    " " + put_val( sp5, 6 ) + ;
    " " + put_val( sp6, 6 ) + ;
    " " + umest_val( pr3, 6, 2 )
  add_string( ls1 )
  FClose( fp )
  Close databases
  rest_box( buf )
  viewtext( name_file,,,, .t.,,, reg_print )

  Return Nil

// 26.02.17
Function forma_39org()

  Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
    fl_exit := .f., tm, ;
    s_lu := 0, s_human := 0, ;
    kh := 0, jh := 0, arr_m, arr_pl

  If !get_nastr()
    Return Nil
  Endif
  If ( arr_pl := ret_oms_pl( T_ROW, T_COL - 5 ) ) == NIL
    Return Nil
  Endif
  If AScan( arr_pl, F_YES_OMS ) > 0 .and. !fbp_ist_fin( T_ROW, T_COL - 5 )
    Return Nil
  Endif
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  Private speriod := arr_m[ 4 ]
  begin_date := arr_m[ 7 ]
  end_date := arr_m[ 8 ]
  //
  waitstatus( iif( au5 == 2, "�", "��" ) + "���祭 ०�� ��ࠢ�����" )
  //
  cre_tmp( { { "p_kod", "N", 4, 0 }, ;
    { "tip", "N", 1, 0 }, ;   // 1-���� ���ᮭ��, 2-����.� �⤥�����, 3-�⤥�����
  { "uch", "N", 3, 0 }, ;
    { "otd", "N", 3, 0 }, ;
    { "tab_nom", "N", 5, 0 }, ;
    { "name", "C", 30, 0 } } )
  Use ( cur_dir() + "tmp" ) New Alias TMP
  Index On Str( tip, 1 ) + Str( p_kod, 4 ) + Str( uch, 3 ) + Str( otd, 3 ) to ( cur_dir() + "tmp" )
  r_use( dir_server() + "mo_otd",, "OTD" )
  r_use( dir_server() + "mo_uch",, "UCH" )
  If AScan( arr_pl, F_YES_OMS ) > 0
    If pi1 == 1  // �� ��� ����砭�� ��祭��
      r_use( dir_server() + "human_u", dir_server() + "human_u", "HU" )
      r_use( dir_server() + "human_",, "HUMAN_" )
      r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
      Set Relation To RecNo() into HUMAN_
      dbSeek( DToS( arr_m[ 5 ] ), .t. )
      Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        If human_->oplata < 9 .and. func_pi_schet() .and. ( arr := yes_f_39( -1 ) ) != NIL
          ++jh
          For i := 1 To Len( arr )
            Select TMP
            find ( "1" + Str( arr[ i, 21 ], 4 ) )  // ���� �� ���� ���
            If !Found()
              Append Blank
              tmp->p_kod := arr[ i, 21 ]
              tmp->tip := 1
            Endif
            write_f39( arr[ i ] )
            Select TMP
            find ( "2" + Str( arr[ i, 21 ], 4 ) + Str( arr[ i, 23 ], 3 ) ) // ���+��०�����
            If !Found()
              Append Blank
              tmp->p_kod := arr[ i, 21 ]
              tmp->uch := arr[ i, 23 ]
              tmp->tip := 2
            Endif
            write_f39( arr[ i ] )
            Select TMP
            find ( "3" + Str( 0, 4 ) + Str( arr[ i, 23 ], 3 ) )  // ��+��०�����
            If !Found()
              Append Blank
              tmp->uch := arr[ i, 23 ]
              tmp->tip := 3
            Endif
            write_f39( arr[ i ] )
            Select TMP
            find ( "4" + Str( 0, 4 ) + Str( 0, 3 ) + Str( arr[ i, 22 ], 3 ) )  // ��+�⤥�����
            If !Found()
              Append Blank
              tmp->otd := arr[ i, 22 ]
              tmp->tip := 4
            Endif
            write_f39( arr[ i ] )
          Next
        Endif
        @ MaxRow(), 1 Say lstr( ++kh ) Color cColorSt2Msg
        If jh > 0
          @ Row(), Col() Say "/" Color "W/R"
          @ Row(), Col() Say lstr( jh ) Color cColorStMsg
        Endif
        Select HUMAN
        Skip
      Enddo
    Else
      r_use( dir_server() + "human_u", dir_server() + "human_u", "HU" )
      r_use( dir_server() + "human_",, "HUMAN_" )
      r_use( dir_server() + "human", dir_server() + "humans", "HUMAN" )
      Set Relation To RecNo() into HUMAN_
      r_use( dir_server() + "schet_",, "SCHET_" )
      r_use( dir_server() + "schet", dir_server() + "schetd", "SCHET" )
      Set Relation To RecNo() into SCHET_
      Set Filter To Empty( schet_->IS_DOPLATA )
      dbSeek( begin_date, .t. )
      Do While schet->pdate <= end_date .and. !Eof()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        Select HUMAN
        find ( Str( schet->kod, 6 ) )
        Do While human->schet == schet->kod .and. !Eof()
          updatestatus()
          If Inkey() == K_ESC
            fl_exit := .t. ; Exit
          Endif
          If human_->oplata < 9 .and. ( arr := yes_f_39( -1 ) ) != NIL
            ++jh
            For i := 1 To Len( arr )
              Select TMP
              find ( "1" + Str( arr[ i, 21 ], 4 ) )  // ���� �� ���� ���
              If !Found()
                Append Blank
                tmp->p_kod := arr[ i, 21 ]
                tmp->tip := 1
              Endif
              write_f39( arr[ i ] )
              Select TMP
              find ( "2" + Str( arr[ i, 21 ], 4 ) + Str( arr[ i, 23 ], 3 ) ) // ���+��०�����
              If !Found()
                Append Blank
                tmp->p_kod := arr[ i, 21 ]
                tmp->uch := arr[ i, 23 ]
                tmp->tip := 2
              Endif
              write_f39( arr[ i ] )
              Select TMP
              find ( "3" + Str( 0, 4 ) + Str( arr[ i, 23 ], 3 ) )  // ��+��०�����
              If !Found()
                Append Blank
                tmp->uch := arr[ i, 23 ]
                tmp->tip := 3
              Endif
              write_f39( arr[ i ] )
              Select TMP
              find ( "4" + Str( 0, 4 ) + Str( 0, 3 ) + Str( arr[ i, 22 ], 3 ) )  // ��+�⤥�����
              If !Found()
                Append Blank
                tmp->otd := arr[ i, 22 ]
                tmp->tip := 4
              Endif
              write_f39( arr[ i ] )
            Next
          Endif
          @ MaxRow(), 1 Say lstr( ++kh ) Color cColorSt2Msg
          If jh > 0
            @ Row(), Col() Say "/" Color "W/R"
            @ Row(), Col() Say lstr( jh ) Color cColorStMsg
          Endif
          Select HUMAN
          Skip
        Enddo
        If fl_exit ; exit ; Endif
        Select SCHET
        Skip
      Enddo
    Endif
  Endif
  If AScan( arr_pl, F_YES_PL ) > 0
    r_use( dir_server() + "kartotek",, "KART" )
    r_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HU_P" )
    r_use( dir_server() + "hum_p", dir_server() + "hum_pd", "HUM_P" )
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    Do While hum_p->k_data <= arr_m[ 6 ] .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      If ( arr := yes_f_39_pl( -1 ) ) != NIL
        ++jh
        For i := 1 To Len( arr )
          Select TMP
          find ( "1" + Str( arr[ i, 21 ], 4 ) )  // ���� �� ���� ���
          If !Found()
            Append Blank
            tmp->p_kod := arr[ i, 21 ]
            tmp->tip := 1
          Endif
          write_f39( arr[ i ] )
          Select TMP
          find ( "2" + Str( arr[ i, 21 ], 4 ) + Str( arr[ i, 23 ], 3 ) ) // ���+��०�����
          If !Found()
            Append Blank
            tmp->p_kod := arr[ i, 21 ]
            tmp->uch := arr[ i, 23 ]
            tmp->tip := 2
          Endif
          write_f39( arr[ i ] )
          Select TMP
          find ( "3" + Str( 0, 4 ) + Str( arr[ i, 23 ], 3 ) )  // ��+��०�����
          If !Found()
            Append Blank
            tmp->uch := arr[ i, 23 ]
            tmp->tip := 3
          Endif
          write_f39( arr[ i ] )
          Select TMP
          find ( "4" + Str( 0, 4 ) + Str( 0, 3 ) + Str( arr[ i, 22 ], 3 ) )  // ��+�⤥�����
          If !Found()
            Append Blank
            tmp->otd := arr[ i, 22 ]
            tmp->tip := 4
          Endif
          write_f39( arr[ i ] )
        Next
      Endif
      @ MaxRow(), 1 Say lstr( ++kh ) Color cColorSt2Msg
      If jh > 0
        @ Row(), Col() Say "/" Color "BG/R"
        @ Row(), Col() Say lstr( jh ) Color cColorStMsg
      Endif
      Select HUM_P
      Skip
    Enddo
  Endif
  If ( j := tmp->( LastRec() ) ) > 0
    If Select( "UCH" ) == 0
      r_use( dir_server() + "mo_uch",, "UCH" )
    Endif
    If Select( "OTD" ) == 0
      r_use( dir_server() + "mo_otd",, "OTD" )
    Endif
    r_use( dir_server() + "mo_pers",, "P2" )
    tmp->( dbEval( {|| p2->( dbGoto( tmp->p_kod ) ), uch->( dbGoto( tmp->uch ) ), otd->( dbGoto( tmp->otd ) ), ;
      tmp->tab_nom := p2->tab_nom, ;
      tmp->name := iif( tmp->tip == 4, otd->name, iif( tmp->tip == 3, uch->name, fam_i_o( p2->fio ) ) ) } ) )
  Endif
  Close databases
  rest_box( buf )
  If j == 0
    Return func_error( 4, "��� ���ଠ樨!" )
  Endif
  If Type( "MenuTo_Minut" ) == "N"
    tm := MenuTo_Minut
  Else
    Private MenuTo_Minut
  Endif
  mybell()
  MenuTo_Minut := 0  // �� ��室��� ��⮬���᪨ �� MENU TO
  Keyboard ""
  popup_prompt( T_ROW - 6, T_COL - 5, 1, ;
    { "���᮪ ~��०�����", ;
    "���᮪ ~�⤥�����", ;
    "���᮪ ~���ᮭ���", ;
    "���ᮭ�� � �~�०�����" },, ;
    { "f_39org_1(3)", ;
    "f_39org_1(4)", ;
    "f_39org_1(1)", ;
    "f_39org_1(2)" } )
  MenuTo_Minut := tm

  Return Nil

// 14.10.24
Function f_39org_1( par )

  Static such := 1
  Local buf, HH := 58, reg_print := 3, ;
    arr_title, name_file := cur_dir() + "_form_39.txt", s, ls1, ;
    arr := {}, arr_uch := {}, r := T_ROW, r2, c := T_COL - 5, i

  If par == 2
    buf := SaveScreen( r, 0, MaxRow(), MaxCol() )
    Use ( cur_dir() + "tmp" ) new
    Index On Upper( name ) to ( cur_dir() + "tmp" ) For tip == 3
    dbEval( {|| AAdd( arr, tmp->uch ), AAdd( arr_uch, tmp->name ) } )
    Use
    i := AScan( arr, such )
    If ( r2 := r + Len( arr ) + 1 ) > MaxRow() -2
      r2 := MaxRow() -2
    Endif
    status_key( "^<Esc>^ - ��室 ��� �롮�;  ^<Enter>^ - �롮� ��०�����" )
    If ( i := Popup( r, c, r2, c + 33, arr_uch, i, color0, .t. ) ) > 0
      glob_uch := { arr[ i ], AllTrim( arr_uch[ i ] ) }
      such := arr[ i ]
    Endif
    RestScreen( r, 0, MaxRow(), MaxCol(), buf )
    If i == 0 ; Return NIL ; Endif
  Endif
  buf := save_maxrow()
  mywait()
  Use ( fr_data ) New Alias FRD
  Zap
  Use ( fr_titl ) New Alias FRT
  Use ( cur_dir() + "tmp" ) new
  Do Case
  Case par == 1
    Index On Upper( name ) to ( cur_dir() + "tmp" ) For tip == 1
  Case par == 2
    Index On Upper( name ) to ( cur_dir() + "tmp" ) For tip == 2 .and. uch == glob_uch[ 1 ]
  Case par == 3
    Index On Upper( name ) to ( cur_dir() + "tmp" ) For tip == 3
  Case par == 4
    Index On Upper( name ) to ( cur_dir() + "tmp" ) For tip == 4
  Endcase
  Private regim := 2
  arr_title := f39_title()
  Private sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  f39_shapka()
  _tit_ist_fin( sh )
  s := ""
  If par == 2
    s := AllTrim( glob_uch[ 2 ] )
  Endif
  frt->name1 := s
  add_string( Center( s, sh ) )
  s := "����� ��ਮ�: " + speriod
  frt->name2 := s
  add_string( Center( s, sh ) )
  If pi1 == 1
    s := str_pi_schet()
  Else
    s := "[ �� ��� �믨᪨ ��� ]"
  Endif
  frt->name3 := s
  add_string( Center( s, sh ) )
  add_string( "" )
  //
  Private sp[ 20 ]
  AFill( sp, 0 )
  Select TMP
  Go Top
  AEval( arr_title, {| x| add_string( x ) } )
  arr_title := f39_title2()
  Do While !Eof()
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    If eq_any( par, 3, 4 )
      ls1 := tmp->name
    Else
      ls1 := lstr( tmp->tab_nom, 6 ) + "/" + tmp->name
    Endif
    f_str_39( Left( ls1, 16 ), 1, ls1 )
    Select TMP
    Skip
  Enddo
  add_string( Replicate( "-", sh ) )
  f_str_39( PadC( "�ᥣ�:", 16 ), 2 )
  FClose( fp )
  Close databases
  rest_box( buf )
  name_fr := "mo_f39" + sfr3()
  If _upr_epson() .or. !File( dir_exe() + name_fr )
    viewtext( name_file,,,, .t.,,, reg_print )
  Else
    call_fr( name_fr )
  Endif

  Return Nil

//
Function forma_39_na( par )

  Local nfile := dir_server() + f39_nastr, name_sect := f39_sect + lstr( par )
  Local arr, adbf, arr_usl, i

  arr := { '"���饭�� � �-�� �� ������ �����������"', ;
    '"��䨫����᪨� �ਥ��� � �-��"', ;
    '"���饭�� �� ���� �� ������ �����������"', ;
    '"��䨫����᪨� �ਥ��� �� ����"' }
  arr_usl := getinisect( nFile, name_sect )
  adbf := { ;
    { "U_KOD",    "N",      4,      0 }, ;  // ��� ��㣨
  { "U_SHIFR",    "C",     10,      0 }, ;  // ��� ��㣨
  { "U_NAME",     "C",     65,      0 };   // ������������ ��㣨
  }
  dbCreate( cur_dir() + "tmp", adbf )
  r_use( dir_server() + "uslugi",, "USL" )
  Use ( cur_dir() + "tmp" ) new
  For i := 1 To Len( arr_usl )
    Select USL
    Goto ( Val( arr_usl[ i, 2 ] ) )
    If !Eof() .and. usl->kod > 0
      Select TMP
      Append Blank
      tmp->u_kod := usl->kod
      tmp->u_shifr := usl->shifr
      tmp->u_name := usl->name
    Endif
  Next
  Select TMP
  Index On Str( u_kod, 4 ) to ( cur_dir() + "tmpk" )
  Index On fsort_usl( u_shifr ) to ( cur_dir() + "tmpn" )
  Close databases
  ob2_v_usl(, 2, "����ன�� ��� 39: ������� " + arr[ par ] )
  If f_esc_enter( 1 )
    arr_usl := {}
    Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmpn" ) New Alias TMP
    Go Top
    Do While !Eof()
      AAdd( arr_usl, { tmp->u_shifr, lstr( tmp->u_kod ) } )
      Skip
    Enddo
    Close databases
    setinisect( nFile, name_sect, arr_usl )
  Endif

  Return Nil

// 18.03.13
Function forma_39_povod()

  Static default_povod_nastr := { ;
    { 1, 1 }, ;
    { 2, 1 }, ;
    { 3, 1 }, ;
    { 4, 2 }, ;
    { 5, 2 }, ;
    { 6, 2 }, ;
    { 7, 1 }, ;
    { 8, 1 }, ;
    { 9, 2 } }
  Static mm_z_p := { { "�� ������ �����������  ", 1 }, ;
    { "��䨫����᪨� �ਥ��", 2 } }
  Static mm_p_u := { { "��������� ��� ", 0 }, ;
    { "������ ���饭��", 1 } }
  Local nfile := dir_server() + f39_nastr, ;
    name_sect := f39_sect + "6", ;
    r, ar, i, j, k, n := Len( stm_povod ), ;
    buf := SaveScreen()

  ar := getinisect( nFile, name_sect )
  Private mvar, m1var, mpovod, m1povod := Int( Val( a2default( ar, "povod", "0" ) ) )
  mpovod := inieditspr( A__MENUVERT, mm_p_u, m1povod )
  //
  r := 5
  Private gl_area := { 1, 0, 23, 79, 0 }
  SetColor( cDataCGet )
  myclear( r )
  @ r, 0 To r, MaxCol()
  r += 2
  @ r, 2 Say "���������� ��� 39 (����� ���) �� �᭮�����" ;
    Get mpovod reader {| x| menu_reader( x, mm_p_u, A__MENUVERT,,, .f. ) }
  @ r + 1, 2 Say "����������������������������������������������������������������������������"
  @ r + 2, 2 Say "  ����� ���饭��                  � � ����� ������� ��� 39 ��������      "
  @ r + 3, 2 Say "����������������������������������������������������������������������������"
  r += 3
  For i := 1 To n
    k := 1
    If ( j := AScan( default_povod_nastr, {| x| x[ 1 ] == stm_povod[ i, 2 ] } ) ) > 0
      k := default_povod_nastr[ j, 2 ]
    Endif
    j := Int( Val( a2default( ar, "povod_" + lstr( stm_povod[ i, 2 ] ), "0" ) ) )
    If Between( j, 1, 2 )
      k := j
    Endif
    //
    mvar  := "mda" + lstr( stm_povod[ i, 2 ] )
    m1var := "m1da" + lstr( stm_povod[ i, 2 ] )
    Private &m1var := k
    Private &mvar  := inieditspr( A__MENUVERT, mm_z_p, k )
    @ r + i, 2 Say stm_povod[ i, 1 ]
    @ Row(), 40 get &mvar reader {| x| menu_reader( x, mm_z_p, A__MENUVERT,,, .f. ) }
  Next
  status_key( "^<Esc>^ - ��室;  ^<PgDn>^ - ���⢥ত���� ����� ����஥�" )
  myread()
  If LastKey() != K_ESC .and. f_esc_enter( "����� ����஥�" )
    ar := { { "povod", m1povod } }
    For i := 1 To n
      mvar  := "mda" + lstr( stm_povod[ i, 2 ] )
      m1var := "m1da" + lstr( stm_povod[ i, 2 ] )
      AAdd( ar, { "povod_" + lstr( stm_povod[ i, 2 ] ), &m1var } )
    Next
    setinisect( nFile, name_sect, ar )
  Endif
  RestScreen( buf )

  Return Nil

//
Function plan_39()

  Local arr := {}, buf := SaveScreen(), ;
    arr_title := { { 1, "  �⤥�����" }, ;
    { 2, "����;���.;�ਥ���" }, ;
    { 3, "����;���-;���⨪" }, ;
    { 4, "����;����.;�� ����" } }, ;
    mpic := {, { 6, 0 }, { 6, 0 } }, tmp_color := SetColor(), i
  Local blk := {| b, ar, nDim, nElem, nKey| f1plan_39( b, ar, nDim, nElem, nKey ) }

  If input_uch( T_ROW, T_COL - 5, sys_date ) == NIL
    Return Nil
  Endif
  r_use( dir_server() + "mo_otd",, "OTD" )
  dbEval( {|| if( between_date( otd->DBEGIN, otd->DEND, sys_date ) ;
    .or. between_date( otd->DBEGINP, otd->DENDP, sys_date ), ;
    AAdd( arr, { PadR( otd->name, 43 ), ;
    otd->plan_vp, ;
    otd->plan_pf, ;
    otd->plan_pd, ;
    otd->( RecNo() ) } ), nil ) }, ;
    {|| otd->kod_lpu == glob_uch[ 1 ] } )
  Close databases
  ASort( arr,,, {| x, y| x[ 1 ] < y[ 1 ] } )
  Private updt_koef := .f.
  Keyboard Chr( K_RIGHT )
  arrn_browse( 2, 2, MaxRow() -2, 77, arr, arr_title, 1,, color0, ;
    "������ ���� �ਥ��� � ��०����� <" + AllTrim( glob_uch[ 2 ] ) + ">", 'b/bg',,, mpic, blk, { .f., .f., .f. } )
  If updt_koef .and. f_esc_enter( 1 )
    g_use( dir_server() + "mo_otd",, "OTD" )
    For i := 1 To Len( arr )
      Goto ( arr[ i, 5 ] )
      g_rlock( forever )
      otd->plan_vp := arr[ i, 2 ]
      otd->plan_pf := arr[ i, 3 ]
      otd->plan_pd := arr[ i, 4 ]
      Unlock
    Next
    Close databases
  Endif
  RestScreen( buf )
  SetColor( tmp_color )

  Return Nil

//
Function f1plan_39( b, ar, nDim, nElem, nKey )

  Local nRow := Row(), nCol := Col(), flag := .f., ;
    buf := save_maxrow(), buf1, r1, mkod

  If nKey == K_RIGHT
    b:Right()
  Elseif nKey == K_LEFT .and. nDim > 2
    b:Left()
  Elseif nKey == K_ENTER .or. Between( nKey, 46, 57 )
    @ nRow, nCol Get parr[ nElem, nDim ] Picture "999999"
    myread()
    b:refreshall() ; flag := .t.
    updt_koef := .t.
  Else
    Keyboard ""
  Endif
  @ nRow, nCol Say ""

  Return flag

// 23.12.12
Function f_str_39( ls1, par, par2 )

  Local arr[ 20 ], i, pole

  AFill( arr, 0 )
  If par == 1
    For i := 2 To 20
      pole := "tmp->p" + lstr( i )
      arr[ i ] := &pole
      sp[ i ] += &pole
    Next
  Else
    For i := 2 To 20
      arr[ i ] := sp[ i ]
    Next
  Endif
  Select FRD
  Append Blank
  frd->p1 := LTrim( iif( par2 == NIL, ls1, par2 ) )
  For i := 2 To 20
    ls1 += put_val( arr[ i ], 6 )
    pole := "frd->p" + lstr( i )
    &pole := arr[ i ]
  Next
  add_string( ls1 )

  Return Nil

// 18.03.13
Static Function get_nastr( yes_err )

  Static spovod := "povod"
  Local nf := dir_server() + f39_nastr, fl, i, ar := {}, ret := .t.

  Default yes_err To .t.
  au6 := {}
  If ( fl := File( nf ) )
    au1 := getinisect( nf, f39_sect + "1" )
    au2 := getinisect( nf, f39_sect + "2" )
    au3 := getinisect( nf, f39_sect + "3" )
    au4 := getinisect( nf, f39_sect + "4" )
    au5 := Int( Val( getinivar( nf, { { f39_sect + "5", "�����������", "2" } } )[ 1 ] ) )
    ar  := getinisect( nf, f39_sect + "6" )
    fl := .f.
    For i := 1 To Len( au1 )
      fl := .t.
      au1[ i, 2 ] := Int( Val( au1[ i, 2 ] ) )
    Next
    For i := 1 To Len( au2 )
      fl := .t.
      au2[ i, 2 ] := Int( Val( au2[ i, 2 ] ) )
    Next
    For i := 1 To Len( au3 )
      fl := .t.
      au3[ i, 2 ] := Int( Val( au3[ i, 2 ] ) )
    Next
    For i := 1 To Len( au4 )
      fl := .t.
      au4[ i, 2 ] := Int( Val( au4[ i, 2 ] ) )
    Next
    For i := 1 To Len( ar )
      If Left( Lower( ar[ i, 1 ] ), 6 ) == spovod + "_"
        AAdd( au6, { Int( Val( SubStr( ar[ i, 1 ], 7 ) ) ), Int( Val( ar[ i, 2 ] ) ) } )
      Endif
    Next
  Endif
  fl_povod := Int( Val( a2default( ar, spovod, "0" ) ) )
  If !fl .and. au5 != 2 .and. yes_err
    ret := func_error( 4, "�� �ந������� ����ன�� ��� 39" )
  Endif

  Return ret

// 23.12.12
Static Function cre_tmp( adbf )

  AAdd( adbf, { "p1", "C", 50, 0 } )
  AAdd( adbf, { "p2", "N", 7, 0 } )
  AAdd( adbf, { "p3", "N", 7, 0 } )
  AAdd( adbf, { "p4", "N", 7, 0 } )
  AAdd( adbf, { "p5", "N", 7, 0 } )
  AAdd( adbf, { "p6", "N", 7, 0 } )
  AAdd( adbf, { "p7", "N", 7, 0 } )
  AAdd( adbf, { "p8", "N", 7, 0 } )
  AAdd( adbf, { "p9", "N", 7, 0 } )
  AAdd( adbf, { "p10", "N", 7, 0 } )
  AAdd( adbf, { "p11", "N", 7, 0 } )
  AAdd( adbf, { "p12", "N", 7, 0 } )
  AAdd( adbf, { "p13", "N", 7, 0 } )
  AAdd( adbf, { "p14", "N", 7, 0 } )
  AAdd( adbf, { "p15", "N", 7, 0 } )
  AAdd( adbf, { "p16", "N", 7, 0 } )
  AAdd( adbf, { "p17", "N", 7, 0 } )
  AAdd( adbf, { "p18", "N", 7, 0 } )
  AAdd( adbf, { "p19", "N", 7, 0 } )
  AAdd( adbf, { "p20", "N", 7, 0 } )
  dbCreate( cur_dir() + "tmp", adbf )
  delfrfiles()
  dbCreate( fr_titl, { { "name_org", "C", 130, 0 }, ;
    { "name1", "C", 130, 0 }, ;
    { "name2", "C", 130, 0 }, ;
    { "name3", "C", 130, 0 }, ;
    { "name4", "C", 30, 0 }, ;
    { "name5", "C", 50, 0 } } )
  dbCreate( fr_data, adbf )
  Use ( fr_data ) New Alias FRD
  Use ( fr_titl ) New Alias FRT
  Append Blank

  Return Nil

// ������� ���� ��ப� �� ���ᨢ� � TMP-䠩�
Static Function write_f39( ar )

  Local i, pole

  For i := 2 To 20
    pole := "tmp->p" + lstr( i )
    &pole := &pole + ar[ i ]
  Next

  Return Nil

// 22.12.16 �஢���� ���쭮�� �� �� human � ������ १���� � ���� ���ᨢ�
Static Function yes_f_39( par1, par2 )

  Static arr_f := { "str_komp",, "komitet" }
  Local i, j, k, s, mvozrast, is_selo, ret, arr := {}

  If !( _f_ist_fin() .and. human_->usl_ok == 3 )
    Return ret
  Endif
  If human_->NOVOR > 0
    mvozrast := count_years( human_->DATE_R2, human->n_data )
  Else
    mvozrast := count_years( human->date_r, human->n_data )
  Endif
  If Select( "KART_" ) == 0
    r_use( dir_server() + "kartote_",, "KART_" )
  Endif
  kart_->( dbGoto( human->kod_k ) )
  is_selo := f_is_selo( kart_->gorod_selo, kart_->okatog )  // �ਧ��� ᥫ�
  i := human->komu ; j := 0
  If i == 0
    j := 17   // ���
  Elseif eq_any( i, 1, 3 )  // ��稥 �������� ��� ������� (��)
    If hb_FileExists( dir_server() + arr_f[ i ] + sdbf() )
      r_use( dir_server() + arr_f[ i ],, "_B" )
      Goto ( human->str_crb )
      If eq_any( _b->ist_fin, I_FIN_PLAT, I_FIN_LPU ) // �����, ������������ � ���
        j := 19   // �����
      Elseif _b->ist_fin == I_FIN_DMS // ���
        j := 20   // ���
      Else // �� ��⠫�� (���, �� ᢮� ����, �� ����稢�����)
        j := 18   // ���
      Endif
      Use
    Endif
  Elseif i == 5  // ���� ���
    j := 19   // �����
  Endif
  If Between( j, 17, 20 )
    If Select( "USL" ) == 0
      r_use( dir_server() + "uslugi",, "USL" )
    Endif
    If Year( human->k_data ) < 2016
      Select HU
      find ( Str( human->kod, 7 ) )
      Do While hu->kod == human->kod .and. !Eof()
        otd->( dbGoto( hu->otd ) )
        If iif( par1 == -1, .t., f_is_uch( st_a_uch, otd->kod_lpu ) ) .and. hu->kod_vr > 0  // �᫨ ���⠢��� ��� ���
          k := hu->kol
          AFill( lp, 0 )
          lp[ 1 ]  := hu->date_u
          lp[ 21 ] := hu->kod_vr
          lp[ 22 ] := hu->otd
          lp[ 23 ] := otd->kod_lpu
          ___f_39( 1, k, mvozrast, is_selo )
          If !emptyall( lp[ 2 ], lp[ 10 ] )
            lp[ j ] := k
            AAdd( arr, AClone( lp ) )
          Endif
        Endif
        Select HU
        Skip
      Enddo
    Else // ��稭�� � 2016 ����
      If Select( "MOHU" ) == 0
        r_use( dir_server() + "mo_su",, "MOSU" )
        r_use( dir_server() + "mo_hu", dir_server() + "mo_hu", "MOHU" )
        Set Relation To u_kod into MOSU
      Endif
      arr := ___f_39_2016( par1, j, mvozrast, is_selo )
    Endif
    If Len( arr ) > 0
      Do Case
      Case par1 == -1  // �� �࣠����樨
        ret := arr
      Case par1 == 0  // �� ��०�����
        ret := arr
      Case par1 == 1  // �� ����
        If AScan( arr, {| x| x[ 21 ] == par2 } ) > 0
          ret := {}
          For i := 1 To Len( arr )
            If arr[ i, 21 ] == par2
              AAdd( ret, arr[ i ] )
            Endif
          Next
        Endif
      Case par1 == 2 // �� �⤥�����
        If AScan( arr, {| x| x[ 22 ] == par2 } ) > 0
          ret := {}
          For i := 1 To Len( arr )
            If arr[ i, 22 ] == par2
              AAdd( ret, arr[ i ] )
            Endif
          Next
        Endif
      Endcase
    Endif
  Endif

  Return ret

// 19.02.13 �஢���� ���쭮�� �� �� hum_p � ������ १���� � ���� ���ᨢ�
Static Function yes_f_39_pl( par1, par2 )

  Local i, j, k, s, mvozrast, arr, is_selo, ret

  kart->( dbGoto( hum_p->kod_k ) )
  mvozrast := count_years( kart->date_r, hum_p->n_data )
  If Select( "KART_" ) == 0
    r_use( dir_server() + "kartote_",, "KART_" )
  Endif
  Select KART_
  Goto ( kart->( RecNo() ) )
  is_selo := f_is_selo( kart_->gorod_selo, kart_->okatog )  // �ਧ��� ᥫ�
  arr := {}
  Select HU_P
  find ( Str( hum_p->( RecNo() ), 7 ) )
  Do While hu_p->kod == hum_p->( RecNo() ) .and. !Eof()
    otd->( dbGoto( hu_p->otd ) )
    If iif( par1 == -1, .t., f_is_uch( st_a_uch, otd->kod_lpu ) ) .and. hu_p->kod_vr > 0  // �᫨ ���⠢��� ��� ���
      k := hu_p->kol
      AFill( lp, 0 )
      lp[ 1 ]  := hu_p->date_u
      lp[ 21 ] := hu_p->kod_vr
      lp[ 22 ] := hu_p->otd
      lp[ 23 ] := otd->kod_lpu
      ___f_39( 2, k, mvozrast, is_selo )
      If !emptyall( lp[ 2 ], lp[ 10 ] )
        If hum_p->TIP_USL == 1  // ���
          lp[ 20 ] := k
        Else
          lp[ 19 ] := k   // �����
        Endif
        AAdd( arr, AClone( lp ) )
      Endif
    Endif
    Select HU_P
    Skip
  Enddo
  If Len( arr ) > 0
    Do Case
    Case par1 == -1  // �� �࣠����樨
      ret := arr
    Case par1 == 0  // �� ��०�����
      ret := arr
    Case par1 == 1  // �� ����
      If AScan( arr, {| x| x[ 21 ] == par2 } ) > 0
        ret := {}
        For i := 1 To Len( arr )
          If arr[ i, 21 ] == par2
            AAdd( ret, arr[ i ] )
          Endif
        Next
      Endif
    Case par1 == 2 // �� �⤥�����
      If AScan( arr, {| x| x[ 22 ] == par2 } ) > 0
        ret := {}
        For i := 1 To Len( arr )
          If arr[ i, 22 ] == par2
            AAdd( ret, arr[ i ] )
          Endif
        Next
      Endif
    Endcase
  Endif

  Return ret

// 03.04.14 �� 2016 ����
Function ___f_39( par, k, mvozrast, is_selo )

  Local _1, _2, _3, _4, lshifr, lshifr1 := "", ldiag, ta, i, j, is_dom := .f., d2_year := Year( sys_date )

  If Select( "USL" ) == 0
    r_use( dir_server() + "uslugi",, "USL" )
  Endif
  _1 := _2 := _3 := _4 := .f.
  If par == 1
    d2_year := Year( human->k_data )
    ldiag := human->kod_diag
    usl->( dbGoto( hu->u_kod ) )
    If !( _1 := ( AScan( au1, {| x| x[ 2 ] == hu->u_kod } ) > 0 ) )  // ��祡��� �ਥ���
      If !( _2 := ( AScan( au2, {| x| x[ 2 ] == hu->u_kod } ) > 0 ) )  // ��䨫����᪨� �ਥ���
        If !( _3 := ( AScan( au3, {| x| x[ 2 ] == hu->u_kod } ) > 0 ) )  // ���饭�� �� ����
          _4 := ( AScan( au4, {| x| x[ 2 ] == hu->u_kod } ) > 0 )  // ��䨫����᪨� �ਥ��� �� ����
        Endif
      Endif
    Endif
    lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
    lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
    If d2_year > 2012 .and. hu->kol_rcp < 0 .and. domuslugatfoms( lshifr )
      _3 := is_dom := .t. ; _4 := .f.
      If _2
        _4 := .t. ; _3 := .f.
      Endif
      _1 := _2 := .f.
    Endif
  Else
    ldiag := hum_p->kod_diag
    usl->( dbGoto( hu_p->u_kod ) )
    If !( _1 := ( AScan( au1, {| x| x[ 2 ] == hu_p->u_kod } ) > 0 ) )  // ��祡��� �ਥ���
      If !( _2 := ( AScan( au2, {| x| x[ 2 ] == hu_p->u_kod } ) > 0 ) )  // ��䨫����᪨� �ਥ���
        If !( _3 := ( AScan( au3, {| x| x[ 2 ] == hu_p->u_kod } ) > 0 ) )  // ���饭�� �� ����
          _4 := ( AScan( au4, {| x| x[ 2 ] == hu_p->u_kod } ) > 0 )  // ��䨫����᪨� �ਥ��� �� ����
        Endif
      Endif
    Endif
    lshifr := usl->shifr
  Endif
  If au5 == 2 .or. ( par == 1 .and. fl_povod == 1 ) // ��ࠢ����
    If priem_na_domu( lshifr ) // �� ���� - �� ��஬�
      is_dom := .t.
      If !( _3 .or. _4 )
        _1 := _2 := _4 := .f.
        _3 := .t.
      Endif
    Elseif priem_profilak( lshifr ) // ��䨫����᪨� ���
      If !( _2 .or. _4 )
        _1 := _3 := _4 := .f.
        _2 := .t.
      Endif
      If is_dom
        _1 := _2 := _3 := .f.
        _4 := .t.
      Endif
    Elseif is_dom // �� ���� - �� ������
      If !( _3 .or. _4 )
        _1 := _2 := _4 := .f.
        _3 := .t.
      Endif
    Endif
    If !( _1 .or. _2 .or. _3 .or. _4 ) .and. par == 1
      ta := f14tf_nastr( lshifr,, d2_year )
      For j := 1 To Len( ta )
        If eq_any( ta[ j, 1 ], 1, 6 ) .and. ta[ j, 2 ] >= 0
          If is_dom
            _3 := .t.  // ���饭�� �� ����
          Else
            _1 := .t.  // ��祡�� ���
          Endif
          Exit
        Endif
      Next
    Endif
    If ( _1 .or. _2 .or. _3 .or. _4 ) .and. Left( ldiag, 1 ) == "Z" // �ᥣ�� ��䨫����᪨� ���
      If _3 .or. _4
        _1 := _2 := _3 := .f.
        _4 := .t.
      Else
        _1 := _3 := _4 := .f.
        _2 := .t.
      Endif
    Endif
  Endif
  // �᫨ ࠡ�⠥� �� ������ ���饭��
  If ( _1 .or. _2 .or. _3 .or. _4 ) .and. par == 1 .and. fl_povod == 1
    If ( i := AScan( au6, {| x| x[ 1 ] == human_->POVOD } ) ) > 0
      j := au6[ i, 2 ]
    Else
      j := 1 // �� ������ �����������
    Endif
    _1 := _2 := _3 := _4 := .f.
    If j == 1
      If is_dom
        _3 := .t.  // ���饭�� �� ����
      Else
        _1 := .t.  // ��祡�� ���
      Endif
    Else
      If is_dom
        _4 := .t.  // ��䨫����᪨� �ਥ� �� ����
      Else
        _2 := .t.  // ��䨫����᪨� ���
      Endif
    Endif
  Endif
  If _1 .or. _2
    lp[ 2 ] := k
    If is_selo
      lp[ 3 ] := k
    Endif
    If mvozrast < 18
      lp[ 4 ] := k
    Elseif mvozrast >= 60
      lp[ 5 ] := k
    Endif
  Endif
  If _1
    lp[ 6 ] := k
    If mvozrast < 18
      lp[ 7 ] := k
    Elseif mvozrast >= 60
      lp[ 8 ] := k
    Endif
  Endif
  If _2
    lp[ 9 ] := k
  Endif
  If _3 .or. _4
    lp[ 10 ] := k
  Endif
  If _3
    lp[ 11 ] := k
    If mvozrast < 18
      lp[ 12 ] := k
      If mvozrast < 1
        lp[ 13 ] := k
      Endif
    Elseif mvozrast >= 60
      lp[ 14 ] := k
    Endif
  Endif
  If _4
    If mvozrast < 18
      lp[ 15 ] := k
      If mvozrast < 1
        lp[ 16 ] := k
      Endif
    Endif
  Endif

  Return Nil

// 19.08.19 ��稭�� � 2016 ����
Function ___f_39_2016( par1, jcol, mvozrast, is_selo )

  Local _1, _2, _3, _4, lshifr, lshifr1 := "", ldiag, ta, i, j, is_dom := .f., arr := {}, ;
    is_zabol, fl_stom_new := .f., au_lu := {}, au_flu := {}, vid_vp := 0, ; // �� 㬮�砭�� ��䨫��⨪�
    d2_year := Year( human->k_data )

  Select HU
  find ( Str( human->kod, 7 ) )
  Do While hu->kod == human->kod .and. !Eof()
    usl->( dbGoto( hu->u_kod ) )
    lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
    If f_paraklinika( usl->shifr, lshifr1, human->k_data )
      lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
      If is_2_stomat( lshifr,, .t. ) > 0 // ��� ��砥� � 1 ������ 2016 ����
        fl_stom_new := .t.
        AAdd( au_lu, { lshifr, ;              // 1
          c4tod( hu->date_u ), ;   // 2
        0, ;         // 3
          0, ;           // 4
          AllTrim( usl->shifr ), ; // 5
        hu->kol_1, ;           // 6
          c4tod( hu->date_u ), ;   // 7
        "", ;       // 8
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
        If is_usluga_disp_nabl( lshifr )
          vid_vp := 0 // ��⠥� ��䨫��⨪��
        Else
          vid_vp := 2 // ࠧ���� �� ������ �����������
        Endif
        Exit
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
        otd->( dbGoto( mohu->otd ) )
        If iif( par1 == -1, .t., f_is_uch( st_a_uch, otd->kod_lpu ) ) .and. mohu->kod_vr > 0  // �᫨ ���⠢��� ��� ���
          is_dom := .f. // �� ����
          k := au_flu[ j, 6 ] // ���-�� ���
          AFill( lp, 0 )
          lp[ 1 ]  := mohu->date_u
          lp[ 21 ] := mohu->kod_vr
          lp[ 22 ] := mohu->otd
          lp[ 23 ] := otd->kod_lpu
          _1 := _2 := _3 := _4 := .f.
          // 1 ��祡�� ���
          // 2 ��䨫����᪨� ���
          If is_zabol
            _1 := .t.
          Else
            _2 := .t.
          Endif
          lp[ 2 ] := k
          If is_selo
            lp[ 3 ] := k
          Endif
          If mvozrast < 18
            lp[ 4 ] := k
          Elseif mvozrast >= 60
            lp[ 5 ] := k
          Endif
          If _1
            lp[ 6 ] := k
            If mvozrast < 18
              lp[ 7 ] := k
            Elseif mvozrast >= 60
              lp[ 8 ] := k
            Endif
          Endif
          If _2
            lp[ 9 ] := k
          Endif
          lp[ jcol ] := k
          AAdd( arr, AClone( lp ) )
        Endif
      Endif
    Next
  Else
    Select HU
    find ( Str( human->kod, 7 ) )
    Do While hu->kod == human->kod .and. !Eof()
      usl->( dbGoto( hu->u_kod ) )
      lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
      If f_paraklinika( usl->shifr, lshifr1, human->k_data )
        lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
        If !eq_any( Left( lshifr, 5 ), "2.90.", "2.91." )
          ta := f14tf_nastr( @lshifr,, d2_year )
          lshifr := AllTrim( lshifr )
          For j := 1 To Len( ta )
            If eq_any( ta[ j, 1 ], 1, 6 ) .and. ta[ j, 2 ] == 0
              k := hu->kol_1
              otd->( dbGoto( hu->otd ) )
              If iif( par1 == -1, .t., f_is_uch( st_a_uch, otd->kod_lpu ) ) .and. hu->kod_vr > 0  // �᫨ ���⠢��� ��� ���
                is_dom := ( hu->kol_rcp < 0 .and. domuslugatfoms( lshifr ) ) // �� ���� - �� ������
                _1 := _2 := _3 := _4 := .f.
                AFill( lp, 0 )
                lp[ 1 ]  := hu->date_u
                lp[ 21 ] := hu->kod_vr
                lp[ 22 ] := hu->otd
                lp[ 23 ] := otd->kod_lpu
                // 1 ��祡�� ���
                // 2 ��䨫����᪨� ���
                // 3 ���饭�� �� ����
                // 4 ��䨫����᪨� �ਥ� �� ����
                If is_zabol
                  If is_dom
                    _3 := .t.  // ���饭�� �� ����
                  Else
                    _1 := .t.  // ��祡�� ���
                  Endif
                Else
                  If is_dom
                    _4 := .t.  // ��䨫����᪨� �ਥ� �� ����
                  Else
                    _2 := .t.  // ��䨫����᪨� ���
                  Endif
                Endif
                If _1 .or. _2
                  lp[ 2 ] := k
                  If is_selo
                    lp[ 3 ] := k
                  Endif
                  If mvozrast < 18
                    lp[ 4 ] := k
                  Elseif mvozrast >= 60
                    lp[ 5 ] := k
                  Endif
                Endif
                If _1
                  lp[ 6 ] := k
                  If mvozrast < 18
                    lp[ 7 ] := k
                  Elseif mvozrast >= 60
                    lp[ 8 ] := k
                  Endif
                Endif
                If _2
                  lp[ 9 ] := k
                Endif
                If _3 .or. _4
                  lp[ 10 ] := k
                Endif
                If _3
                  lp[ 11 ] := k
                  If mvozrast < 18
                    lp[ 12 ] := k
                    If mvozrast < 1
                      lp[ 13 ] := k
                    Endif
                  Elseif mvozrast >= 60
                    lp[ 14 ] := k
                  Endif
                Endif
                If _4
                  If mvozrast < 18
                    lp[ 15 ] := k
                    If mvozrast < 1
                      lp[ 16 ] := k
                    Endif
                  Endif
                Endif
                lp[ jcol ] := k
                AAdd( arr, AClone( lp ) )
              Endif
            Endif
          Next j
        Endif
      Endif
      Select HU
      Skip
    Enddo
  Endif

  Return arr

//
Function ret_oms_pl( r, c )

  Static sast := { .t., .t. }, ;
    sarr := { { '�� ����� ���',F_YES_OMS }, ;
    { '�� ����� "����� ��㣨"', F_YES_PL } }
  Local ret := { 1 }, i, j, a

  If is_task( X_PLATN ) // ��� ������ ���
    ret := NIL
    If ( a := bit_popup( T_ROW, T_COL - 5, sarr, sast ) ) != NIL
      ret := {} ; AFill( sast, .f. )
      For i := 1 To Len( a )
        AAdd( ret, a[ i, 2 ] )
        If ( j := AScan( sarr, {| x| x[ 2 ] == a[ i, 2 ] } ) ) > 0
          sast[ j ] := .t.
        Endif
      Next
    Endif
  Endif

  Return ret

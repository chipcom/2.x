// ࠡ�� � 室�⠩�⢠�� � ����� - TFOMS_hodotajstvo.prg
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

Static Shodata_sem := "����� � 室�⠩�⢠��"
Static Shodata_err := "� ����� ������ � 室�⠩�⢠�� ࠡ�⠥� ��㣮� ���짮��⥫�."

// 12.09.25 ��ଫ���� 室�⠩�⢠
Function tfoms_hodatajstvo( arr_m, iRefr, par )

  // �㭪�� ��ࠡ��뢠�� ⮫쪮 par = 1 ��� 2 � �訡�� iReft = 57 ��� 599
  // arr_m - �६����� ���ᨢ
  // iRefr - ��� �訡�� 57 ��� 599
  // par - ��ࠬ��� 㪠�뢠�騩 ����⢨�,
  // 1 - �������� 䠩�� ����������� ��� ���뫪� � �����
  // 2 - ��ଫ���� (�����) ����������� (�� ��஬�)
  Local buf24 := save_maxrow(), t_arr[ BR_LEN ], blk

  If !myfiledeleted( cur_dir() + "tmp_k" + sdbf() )
    Return Nil
  Endif

  mywait()
  dbCreate( cur_dir() + "tmp_k", { { "kod", "N", 7, 0 }, ;
    { "kod_lu", "N", 7, 0 }, ;
    { "k_data", "D", 8, 0 }, ;
    { "is", "N", 1, 0 } } )
  Use ( cur_dir() + "tmp_k" ) new
  r_use( dir_server() + "human",, "HUMAN" )
  Use ( cur_dir() + "tmp_h" ) new
  Go Top
  Do While !Eof()
    If tmp_h->REFREASON == iRefr
      human->( dbGoto( tmp_h->kod ) )
      Select TMP_K
      Append Blank
      Replace kod With human->kod_k, ;
        kod_lu With human->( RecNo() ), ;
        k_data With human->k_data, ;
        is With 1
    Endif
    Select TMP_H
    Skip
  Enddo
  Close databases
  If par == 1     // �������� 䠩�� ����������� ��� ���뫪� � �����
    Return create_file_hodatajstvo( arr_m )
  Endif
  //
  r_use( dir_server() + "kartote_",, "KART_" )
  r_use( dir_server() + "kartotek",, "KART" )
  Use ( cur_dir() + "tmp_k" ) New Alias TMP
  Set Relation To kod into KART, To kod into KART_
  Index On Upper( kart->fio ) to ( cur_dir() + "tmp_k" )
  rest_box( buf24 )
  //
  t_arr[ BR_TOP ] := 2
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := 2
  t_arr[ BR_RIGHT ] := 77
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := "�롮� ��樥�⮢ ��� ��ଫ���� 室�⠩�⢠"
  t_arr[ BR_TITUL_COLOR ] := "B/BG"
  t_arr[ BR_ARR_BROWSE ] := { '�', '�', '�', "N/BG,W+/N,B/BG,W+/B", .t. }
  blk := {|| iif( tmp->is == 1, { 1, 2 }, { 3, 4 } ) }
  t_arr[ BR_COLUMN ] := { { ' ', {|| iif( tmp->is == 1, '', ' ' ) }, blk }, ;
    { Center( "���", 30 ), {|| PadR( kart->fio, 30 ) }, blk }, ;
    { " ", {|| kart->pol }, blk }, ;
    { "��� ஦�.", {|| full_date( kart->date_r ) }, blk }, ;
    { " ����", {|| PadR( ret_okato_ulica( kart->adres, kart_->okatog,, 2 ), 26 ) }, blk } }
  t_arr[ BR_EDIT ] := {| nk, ob| f1tfoms_hodatajstvo( nk, ob, "edit" ) }
  t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ ��室 ��� ।���஢���� � ����;  ^<+,-,Ins>^ �⬥��� ��樥�� ��� ����" ) }
  Go Top
  Private ob_kol := tmp->( LastRec() )
  edit_browse( t_arr )
  If ob_kol > 0
    delfrfiles()
    adbf := { { "name", "C", 80, 0 }, ;
      { "predst", "C", 40, 0 }, ;
      { "data", "C", 10, 0 } }
    dbCreate( fr_titl, adbf )
    Use ( fr_titl ) New Alias FRT
    Append Blank
    frt->name   := glob_mo[ _MO_SHORT_NAME ]
    frt->predst := ""
    frt->data   := full_date( sys_date )
    //
    adbf := { { "fio", "C", 30, 0 }, ;
      { "fam", "C", 40, 0 }, ;
      { "ima", "C", 40, 0 }, ;
      { "ots", "C", 40, 0 }, ;
      { "pol_m", "C", 1, 0 }, ;
      { "pol_g", "C", 1, 0 }, ;
      { "date_r", "C", 10, 0 }, ;
      { "mesto_r", "C", 100, 0 }, ;
      { "vpasport", "C", 50, 0 }, ;
      { "spasport", "C", 10, 0 }, ;
      { "npasport", "C", 20, 0 }, ;
      { "dpasport", "C", 10, 0 }, ;
      { "gragd", "C", 40, 0 }, ;
      { "snils", "C", 14, 0 }, ;
      { "iadres", "C", 6, 0 }, ;
      { "sadres", "C", 40, 0 }, ;
      { "radres", "C", 40, 0 }, ;
      { "gadres", "C", 40, 0 }, ;
      { "nadres", "C", 40, 0 }, ;
      { "ulica", "C", 50, 0 }, ;
      { "dom", "C", 10, 0 }, ;
      { "korp", "C", 10, 0 }, ;
      { "kvar", "C", 10, 0 }, ;
      { "phone", "C", 20, 0 }, ;
      { "email", "C", 40, 0 }, ;
      { "is", "N", 1, 0 } }
    dbCreate( fr_data, adbf )
    Use ( fr_data ) New Alias FRD
    Select TMP
    Go Top
    Do While !Eof()
      If tmp->is == 1
        arr := retfamimot( 1, .f. )
        Select FRD
        Append Blank
        frd->fio := fam_i_o( kart->fio, arr )
        frd->fam := arr[ 1 ]
        frd->ima := arr[ 2 ]
        frd->ots := arr[ 3 ]
        frd->pol_m := iif( kart->pol == "�", '�', ' ' )
        frd->pol_g := iif( kart->pol == "�", ' ', '�' )
        frd->date_r := full_date( kart->date_r )
        frd->mesto_r := kart_->mesto_r
        frd->vpasport := inieditspr( A__MENUVERT, getf011(), kart_->vid_ud )
        frd->spasport := kart_->ser_ud
        frd->npasport := kart_->nom_ud
        frd->dpasport := full_date( kart_->kogdavyd )
        If !( Empty( kart_->strana ) .or. kart_->strana == '643' )
          frd->gragd := inieditspr( A__MENUVERT, geto001(), kart_->strana )
        Endif
        If !Empty( kart->SNILS )
//          frd->snils := Transform( kart->SNILS, picture_pf )
          frd->snils := Transform_SNILS( kart->SNILS )
        Endif
        frd->iadres := ""
        arr := ret_okato_array( kart_->okatog )
        frd->sadres := arr[ 1 ]
        frd->radres := arr[ 2 ]
        frd->gadres := arr[ 3 ]
        frd->nadres := arr[ 4 ]
        frd->ulica := kart->adres
        frd->dom := ""
        frd->korp := ""
        frd->kvar := ""
        frd->phone := kart_->PHONE_W
        frd->email := ""
      Endif
      Select TMP
      Skip
    Enddo
    //
    t_arr[ BR_TOP ] := 2
    t_arr[ BR_BOTTOM ] := MaxRow() -2
    t_arr[ BR_LEFT ] := 2
    t_arr[ BR_RIGHT ] := 77
    t_arr[ BR_COLOR ] := color0
    t_arr[ BR_TITUL ] := "������஢���� ��樥�⮢ ��� ��ଫ���� 室�⠩�⢠"
    t_arr[ BR_TITUL_COLOR ] := "B/BG"
    t_arr[ BR_ARR_BROWSE ] := { '�', '�', '�', "N/BG,W+/N,B/BG,W+/B", .t. }
    blk := {|| iif( frd->is == 1, { 1, 2 }, { 3, 4 } ) }
    t_arr[ BR_COLUMN ] := { { Center( "���", 20 ), {|| PadR( fio, 20 ) }, blk }, ;
      { "��� ஦�.", {|| full_date( date_r ) }, blk }, ;
      { " ����", {|| PadR( ulica, 40 ) }, blk } }
    t_arr[ BR_EDIT ] := {| nk, ob| f2tfoms_hodatajstvo( nk, ob, "edit" ) }
    t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ - ��室;  ^<Enter>^ - ।���஢���� ����;  ^<F9>^ - ����� 室�⠩��" ) }
    Select FRD
    Go Top
    edit_browse( t_arr )
    Close databases
  Endif
  Close databases

  Return Nil

//
Function f1tfoms_hodatajstvo( nKey, oBrow, regim )

  Local k := -1, rec, fl

  If regim == "edit"
    Do Case
    Case nkey == K_INS
      Replace tmp->is With if( tmp->is == 1, 0, 1 )
      If tmp->is == 1
        ob_kol++
      Else
        ob_kol--
      Endif
      k := 0
      Keyboard Chr( K_TAB )
    Case nkey == 43 .or. nkey == 45  // + ��� -
      fl := ( nkey == 43 )
      rec := RecNo()
      tmp->( dbEval( {|| tmp->is := iif( fl, 1, 0 ) } ) )
      Goto ( rec )
      If fl
        ob_kol := tmp->( LastRec() )
      Else
        ob_kol := 0
      Endif
      k := 0
    Endcase
  Endif

  Return k

//
Function f2tfoms_hodatajstvo( nKey, oBrow, regim )

  Local k := -1, rec, fl, buf := SaveScreen()

  If regim == "edit"
    Do Case
    Case nkey == K_ENTER
      Private miadres := frd->iadres, ;
        msadres := frd->sadres, ;
        mradres := frd->radres, ;
        mgadres := frd->gadres, ;
        mnadres := frd->nadres, ;
        mulica  := frd->ulica,;
        mdom    := frd->dom,;
        mkorp   := frd->korp,;
        mkvar   := frd->kvar,;
        mphone  := frd->phone,;
        memail  := frd->email,;
        mpredst := frt->predst, ;
        mdata   := frt->data
      r := 8
      SetColor( cDataCGet )
      clrlines( r, 23 )
      @ r, 0 To r, 79
      str_center( r, AllTrim( frd->fio ) )
      ++r
      ++r ; @ r, 1 Say "���⮢� ������" Get miadres
      ++r ; @ r, 1 Say "������" Get msadres When .f.
      ++r ; @ r, 1 Say "�����" Get mradres
      ++r ; @ r, 1 Say "��த" Get mgadres
      ++r ; @ r, 1 Say "����" Get mnadres
      ++r ; @ r, 1 Say "����" Get mulica
      ++r ; @ r, 1 Say "���" Get mdom
      ++r ; @ r, 1 Say "�����" Get mkorp
      ++r ; @ r, 1 Say "������" Get mkvar
      ++r ; @ r, 1 Say "��㦥��� ⥫�䮭" Get mphone
      ++r ; @ r, 1 Say "E-mail" Get memail
      ++r ; @ r, 1 Say "�।�⠢�⥫�" Get mpredst
      ++r ; @ r, 1 Say "��� 室�⠩�⢠" Get mdata
      status_key( "^<Esc>^ - ��室;  ^<PgDn>^ - ������" )
      myread()
      If LastKey() != K_ESC
        frd->is := 1
        frd->iadres := miadres
        frd->sadres := msadres
        frd->radres := mradres
        frd->gadres := mgadres
        frd->nadres := mnadres
        frd->ulica  := mulica
        frd->dom    := mdom
        frd->korp   := mkorp
        frd->kvar   := mkvar
        frd->phone  := mphone
        frd->email  := memail
        frt->predst := mpredst
        frt->data   := mdata
        Commit
      Endif
      RestScreen( buf )
      k := 0
    Case nkey == K_F9
      rec := RecNo()
      Close databases
      call_fr( "mo_hodat" )
      Use ( fr_titl ) New Alias FRT
      Use ( fr_data ) New Alias FRD
      Goto ( rec )
      k := 0
    Endcase
  Endif

  Return k

// 12.09.25 ᮧ����� 䠩�� ����������� ��� ���뫪� � �����
Function create_file_hodatajstvo( arr_m )

  // arr_m - �६����� ���ᨢ
  Local i, k := 0, as, fl := .f., mnn, mb, me, mfilial, ;
    buf := save_maxrow()

  r_use( dir_server() + "organiz",, "ORG" )
  If Empty( mfilial := org->filial_h )
    Close databases
    Return func_error( 4, '�� ��࠭ 䨫��� ����� ��� ��ࠢ�� 䠩�� � 室�⠩�⢠�� ("��� �࣠������")' )
  Endif

  mywait()
  dbCreate( cur_dir() + "tmp_k1", { { "kod", "N", 7, 0 }, ;
    { "kod_lu", "N", 7, 0 }, ;
    { "k_data", "D", 8, 0 }, ;
    { "ntable", "N", 1, 0 }, ;
    { "is", "N", 1, 0 } } )
  Use ( cur_dir() + "tmp_k1" ) new
  Index On Str( kod, 7 ) to ( cur_dir() + "tmp_k1" )

  Use ( cur_dir() + "tmp_k" ) new
  Go Top
  Do While !Eof()
    Select TMP_K1
    find ( Str( tmp_k->kod, 7 ) )
    If Found()
      If tmp_k->k_data > tmp_k1->k_data
        Replace kod_lu With tmp_k->kod_lu, ;
          k_data With tmp_k->k_data
      Endif
    Else
      Append Blank
      Replace kod    With tmp_k->kod, ;
        kod_lu With tmp_k->kod_lu, ;
        k_data With tmp_k->k_data, ;
        is With 1
    Endif
    Select TMP_K
    Skip
  Enddo

  f_mb_me_nsh( 2013, @mb, @me )

  r_use( dir_server() + "mo_hod",, "HOD" )
  Index On Str( nn, 3 ) to ( cur_dir() + "tmp_rees" ) For Year( dfile ) == Year( sys_date )

  For mnn := mb To me
    find ( Str( mnn, 3 ) )
    If !Found() // ��諨 ᢮����� �����
      fl := .t.
      Exit
    Endif
  Next

  If !fl
    rest_box( buf )
    Close databases
    Return func_error( 10, "�� 㤠���� ���� ᢮����� ����� ����� � �����. �஢���� ����ன��!" )
  Endif
  Set Index To

  r_use( dir_server() + "mo_hod_k",, "HODK" )
  Set Relation To kod into HOD
  Index On Str( kod_k, 7 ) to ( cur_dir() + "tmp_hodk" ) ;
    For hod->nyear == arr_m[ 1 ] .and. hod->nmonth == arr_m[ 2 ]

  Select TMP_K1
  Go Top
  Do While !Eof()
    Select HODK
    find ( Str( tmp_k1->kod, 7 ) )
    If Found()
      tmp_k1->is := 0
    Endif
    Select TMP_K1
    Skip
  Enddo
  Delete For is == 0
  Pack
  as := { { 0, '34001', '' }, { 0, '34002', '' }, { 0, '34006', '' }, { 0, '34007', '' }, { 0, '��稥', '' } }

  r_use( dir_server() + "human_",, "HUMAN_" )
  Select TMP_K1
  Set Index To
  Go Top
  Do While !Eof()
    human_->( dbGoto( tmp_k1->kod_lu ) )
    i := 3
    If human_->smo == as[ 1, 2 ]
      i := 1
    Elseif human_->smo == as[ 2, 2 ]
      i := 2
    Endif
    tmp_k1->ntable := i
    ++k
    ++as[i,1 ]
    Skip
  Enddo
  Close databases
  rest_box( buf )
  If k == 0
    Return func_error( 4, '�� �ᥬ ��樥�⠬ 㦥 ��ࠢ���� 室�⠩�⢠ ' + arr_m[ 4 ] )
  Endif
  j := 0
  For i := 1 To 3
    If as[ i, 1 ] > 0
      ++j
    Endif
  Next
  If f_alert( { '���⠢����� ��娢 � 室�⠩�⢠��', ;
      '(������⢮ ��樥�⮢ - ' + lstr( k ) + ', ������⢮ ⠡��� Excel - ' + lstr( j ) + ').', ;
      '', ;
      '�롥�� ����⢨�:' }, ;
      { " �⪠� ", " �������� 䠩�� 室�⠩�⢠ " }, ;
      2, "GR+/R", "W+/R", 16,, "GR+/R,N/BG" ) == 2
    n_file := 'HD_' + lstr( mfilial ) + '_M' + glob_mo[ _MO_KOD_TFOMS ] + '_' + lstr( mnn )
    For i := 1 To 3
      If as[ i, 1 ] > 0
        // as[i,3] := n_file+"_"+as[i,2]+".xls"
        as[ i, 3 ] := n_file + "_" + as[ i, 2 ] + ".xlsx"
        Delete File ( as[ i, 3 ] )
        delfrfiles()
        adbf := { { "name_f", "C", 30, 0 }, ;
          { "codemo", "C", 6, 0 }, ;
          { "name", "C", 60, 0 }, ;
          { "data", "C", 10, 0 } }
        dbCreate( fr_titl, adbf )
        Use ( fr_titl ) New Alias FRT
        Append Blank
        frt->name_f := as[ i, 3 ]
        frt->codemo := glob_mo[ _MO_KOD_TFOMS ]
        frt->name   := glob_mo[ _MO_SHORT_NAME ]
        frt->data   := full_date( sys_date )
        adbf := { { "nomer", "N", 4, 0 }, ;
          { "fam", "C", 50, 0 }, ;
          { "im", "C", 50, 0 }, ;
          { "ot", "C", 50, 0 }, ;
          { "pol", "C", 3, 0 }, ;
          { "date_r", "C", 10, 0 }, ;
          { "vid_ud", "N", 2, 0 }, ;
          { "name_ud", "C", 20, 0 }, ;
          { "ser_ud", "C", 10, 0 }, ;
          { "nom_ud", "C", 20, 0 }, ;
          { "mesto_r", "C", 100, 0 }, ;
          { "snils", "C", 14, 0 }, ;
          { "okatog", "C", 11, 0 }, ;
          { "adresg", "C", 250, 0 }, ;
          { "vidpolis", "C", 10, 0 }, ;
          { "polis", "C", 40, 0 }, ;
          { "smo", "C", 5, 0 }, ;
          { "name_smo", "C", 60, 0 }, ;
          { "okato", "C", 5, 0 }, ;
          { "region", "C", 60, 0 }, ;
          { "proch", "C", 60, 0 } }
        dbCreate( fr_data, adbf )
        Use ( fr_data ) New Alias FRD
        r_use( dir_exe() + "_mo_smo", cur_dir() + "_mo_smo2", "SMO" )
        r_use( dir_server() + "kartote_",, "KART_" )
        r_use( dir_server() + "kartotek",, "KART" )
        Set Relation To RecNo() into KART_
        r_use( dir_server() + "human_",, "HUMAN_" )
        r_use( dir_server() + "human",, "HUMAN" )
        Set Relation To RecNo() into HUMAN_, kod_k into KART
        Use ( cur_dir() + "tmp_k1" ) new
        Set Relation To kod_lu into HUMAN
        Index On Upper( human->fio ) to ( cur_dir() + "tmp_k1" )
        k := 0
        Go Top
        Do While !Eof()
          If tmp_k1->ntable == i
            arr_fio := retfamimot( 2 )
            Select FRD
            Append Blank
            frd->nomer := ++k
            frd->FAM := arr_fio[ 1 ]
            frd->IM  := arr_fio[ 2 ]
            frd->OT  := arr_fio[ 3 ]
            frd->pol := iif( human->pol == '�', '��', '���' )
            frd->date_r := full_date( human->date_r )
            frd->vid_ud := kart_->vid_ud
            frd->name_ud := get_name_vid_ud( kart_->vid_ud )
            frd->ser_ud := kart_->ser_ud
            frd->nom_ud := kart_->nom_ud
            If !Empty( smr := del_spec_symbol( kart_->mesto_r ) )
              frd->mesto_r := CharOne( " ", smr )
            Endif
            If !Empty( kart->snils )
//              frd->snils := Transform( kart->SNILS, picture_pf )
              frd->snils := Transform_SNILS( kart->SNILS )
            Endif
            frd->okatog := kart_->okatog
            frd->adresg := ret_okato_ulica( kart->adres, kart_->okatog, 1, 2 )
            frd->vidpolis := lstr( human_->VPOLIS ) + "-" + inieditspr( A__MENUVERT, mm_vid_polis, human_->VPOLIS )
            frd->polis := AllTrim( AllTrim( human_->SPOLIS ) + " " + human_->NPOLIS )
            frd->smo := human_->smo
            frd->name_smo := inieditspr( A__MENUVERT, glob_arr_smo, Int( Val( human_->smo ) ) )
            If Empty( frd->name_smo )
              Select SMO
              find ( PadR( human_->smo, 5 ) )
              frd->name_smo := smo->name
            Endif
            If Empty( frd->okato := human_->okato )
              Select SMO
              find ( PadR( human_->smo, 5 ) )
              frd->okato := smo->okato
            Endif
            frd->region := inieditspr( A__MENUVERT, glob_array_srf, frd->okato )
            frd->proch := AllTrim( AllTrim( kart_->PHONE_H ) + " " + AllTrim( kart_->PHONE_M ) + " " + kart_->PHONE_W )
          Endif
          Select TMP_K1
          Skip
        Enddo
        Close databases

        error := hodotajstvoxls( n_file + '_' + as[ i, 2 ] )
        If ! Empty( error )
          Return func_error( 4, '�訡�� ᮧ����� 䠩�� 室�⠩�⢠.' )
        Endif
        // call_fr("mo_hodex",3,as[i,3],,.f.)
      Endif
    Next

    g_use( dir_server() + "mo_hod",, "HOD" )
    addrecn()
    hod->KOD := RecNo()
    hod->NYEAR := arr_m[ 1 ]
    hod->NMONTH := arr_m[ 2 ]
    hod->NN := mnn
    hod->KOL1 := 0
    hod->KOL2 := 0
    hod->KOL3 := 0
    hod->FNAME := n_file
    hod->DFILE := sys_date
    hod->TFILE := hour_min( Seconds() )
    hod->DATE_OUT := CToD( "" )
    hod->NUMB_OUT := 0
    g_use( dir_server() + "mo_hod_k",, "HODK" )
    Index On Str( kod, 6 ) to ( cur_dir() + "tmp_hodk" )
    Use ( cur_dir() + "tmp_k1" ) new
    arr_zip := {}
    For i := 1 To 3
      If as[ i, 1 ] > 0
        AAdd( arr_zip, as[ i, 3 ] )
        Select TMP_K1
        Go Top
        Do While !Eof()
          If tmp_k1->ntable == i
            Select HODK
            addrec( 6 )
            hodk->KOD := hod->KOD
            hodk->KOD_K := tmp_k1->kod
            pole := "hod->KOL" + lstr( i )
            &pole := &pole + 1
          Endif
          Select TMP_K1
          Skip
        Enddo
      Endif
    Next
    Close databases
    If chip_create_zipxml( n_file + szip(), arr_zip, .t. )
      view_list_hodatajstvo()
    Endif
  Endif

  Return Nil

// 04.02.13
Function view_list_hodatajstvo()

  Local buf := SaveScreen()

  If !g_slock( Shodata_sem )
    Return func_error( 4, Shodata_err )
  Endif
  Private goal_dir := dir_server() + dir_xml_mo() + hb_ps()
  g_use( dir_server() + "mo_hod",, "HOD" )
  Index On Str( Year( dfile ), 4 ) + Str( nn, 4 ) to ( cur_dir() + "tmp_hod" ) DESCENDING
  Go Top
  If Eof()
    func_error( 4, "��� 䠩��� 室�⠩��" )
  Else
    alpha_browse( T_ROW, 2, 22, 77, "f1_view_list_hodatajstvo", color0,,,,,,, ;
      "f2_view_list_hodatajstvo",, { '�', '�', '�', "N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R", .t., 180 } )
  Endif
  Close databases
  g_sunlock( Shodata_sem )
  RestScreen( buf )

  Return Nil

// 22.02.17
Function f1_view_list_hodatajstvo( oBrow )

  Local oColumn, ;
    blk := {|| iif( hb_FileExists( goal_dir + AllTrim( hod->FNAME ) + szip() ), ;
    iif( Empty( hod->date_out ), { 3, 4 }, { 1, 2 } ), ;
    { 5, 6 } ) }

  oColumn := TBColumnNew( "�����", {|| hod->nn } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "  ���", {|| date_8( hod->dfile ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "���-;��", {|| Right( Str( hod->nyear, 4 ), 2 ) + "/" + StrZero( hod->nmonth, 2 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " ���.;����⠫", {|| put_val( hod->kol1, 6 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " ���.;�����", {|| put_val( hod->kol2, 6 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " ���.;��稥", {|| put_val( hod->kol3, 6 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " ������������ 䠩��", {|| PadR( hod->FNAME, 20 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "�ਬ�砭��", {|| f11_view_list_hodatajstvo() } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  status_key( "^<Esc>^ ��室 ^<Enter>^ ��ᬮ�� ^<F5>^ ������ ^<Del>^ 㤠���� ��� �� ����ᠭ�� 䠩�" )

  Return Nil

//
Static Function f11_view_list_hodatajstvo()

  Local s := ""

  If !hb_FileExists( goal_dir + AllTrim( hod->FNAME ) + szip() )
    s := "��� 䠩��"
  Elseif Empty( hod->date_out )
    s := "�� ����ᠭ"
  Else
    s := "���. " + lstr( hod->NUMB_OUT ) + " ࠧ"
  Endif

  Return PadR( s, 10 )

// 15.10.24
Function f2_view_list_hodatajstvo( nKey, oBrow )

  Local ret := -1, tmp_color := SetColor(), r, r1, r2, arr_f, ;
    s, buf := SaveScreen(), arr, i, k, mdate, t_arr[ 2 ], arr_pmt := {}
  Local error

  Do Case
  Case nKey == K_ENTER
    If ( arr_f := extract_zip_xml( goal_dir, AllTrim( hod->FNAME ) + szip() ) ) != NIL
      If ( k := Len( arr_f ) ) > 1
        stat_msg( "����. ����� ���� ������ " + lstr( k ) + " ⠡���� Excel � ࠧ��� �����." )
      Else
        stat_msg( "����. ����� �㤥� ����� ⠡��� Excel " + arr_f[ 1 ] )
      Endif
      mybell( 2, OK )
      For i := 1 To k
        // openExcel(_tmp_dir1()+arr_f[i])
        view_file_in_viewer( _tmp_dir1() + arr_f[ i ] )
      Next
    Endif
  Case nKey == K_F5
    If f_esc_enter( "����� 䠩�� �� " + date_8( hod->dfile ) )
      Private p_var_manager := "copy_schet"
      s := manager( T_ROW, T_COL + 5, MaxRow() -2,, .t., 2, .f.,,, ) // "norton" ��� �롮� ��⠫���
      If !Empty( s )
        If Upper( s ) == Upper( goal_dir )
          func_error( 4, "�� ��ࠫ� ��⠫��, � ���஬ 㦥 ����ᠭ 楫���� 䠩�! �� �������⨬�." )
        Else
          zip_file := AllTrim( hod->FNAME ) + szip()
          If hb_FileExists( goal_dir + zip_file )
            mywait( '����஢���� "' + zip_file + '" � ��⠫�� "' + s + '"' )
            // copy file (goal_dir+zip_file) to (hb_OemToAnsi(s)+zip_file)
            Copy File ( goal_dir + zip_file ) to ( s + zip_file )
            // if hb_fileExists(hb_OemToAnsi(s)+zip_file)
            If hb_FileExists( s + zip_file )
              hod->( g_rlock( forever ) )
              hod->DATE_OUT := sys_date
              If hod->NUMB_OUT < 99
                hod->NUMB_OUT++
              Endif
              Unlock
              Commit
            Else
              smsg := "�訡�� ����� 䠩�� " + s + zip_file
              func_error( 4, "�訡�� ����� 䠩�� " + s + zip_file )
            Endif
          Else
            func_error( 4, "�� �����㦥� 䠩� " + goal_dir + zip_file )
          Endif
        Endif
      Endif
    Endif
    ret := 0
  Case nKey == K_DEL .and. Empty( hod->DATE_OUT )
    If f_esc_enter( "㤠����� 䠩�� �� " + date_8( hod->dfile ), .t. )
      stat_msg( "���⢥न� 㤠����� ��� ࠧ." ) ; mybell( 2 )
      If f_esc_enter( "㤠����� 䠩�� �� " + date_8( hod->dfile ), .t. )
        mywait( "����. �ந�������� 㤠����� 䠩�� 室�⠩�⢠." )
        g_use( dir_server() + "mo_hod_k",, "HODK" )
        Index On Str( kod, 6 ) to ( cur_dir() + "tmp_hodk" )
        Do While .t.
          find ( Str( hod->kod, 6 ) )
          If !Found() ; exit ; Endif
          deleterec( .t. )
        Enddo
        zip_file := AllTrim( hod->fname ) + szip()
        If hb_FileExists( goal_dir + zip_file )
          Delete File ( goal_dir + zip_file )
        Endif
        Select HOD
        deleterec( .t. )
        stat_msg( "���� 室�⠩�⢠ 㤠��!" ) ; mybell( 2, OK )
        ret := 1
      Endif
    Endif
  Endcase
  SetColor( tmp_color )
  RestScreen( buf )

  Return ret

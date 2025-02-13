// mo_omsid.prg - информация по диспансеризации в ОМС
#include "inkey.ch"
#include "fastreph.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

#define MONTH_UPLOAD 03 // МЕСЯЦ для выгрузки R11

// 22.01.25 Создание файла обмена R11...
Function f_create_r11()

  Local buf := save_maxrow(), i, j, ir, s := "", arr := {}, fl := .t., fl1 := .f., a_reestr := {}, ar
  Private SMONTH := 1, mdate := sys_date, mrec := 1
  Private c_view := 0, c_found := 0, fl_exit := .f., pj, arr_rees := {}, ;
    pkol := 0, CODE_LPU := glob_mo[ _MO_KOD_TFOMS ], CODE_MO := glob_mo[ _MO_KOD_FFOMS ], ;
    mkol := { 0, 0, 0, 0, 0 }, skol[ 5 ], ames[ 12, 5 ], ame[ 12 ], bm := SMONTH, ; // начальный месяц минус один
    _arr_vozrast_DVN := ret_arr_vozrast_dvn( 0d20241201 )

  Private sgod := 2025
  //
  mywait()
  fl := .t.
  fl_1 := .f.
  SMONTH := lm := MONTH_UPLOAD // МЕСЯЦ
  dbCreate( cur_dir + "tmp_00", { ;
    { "reestr",     "N", 6, 0 }, ;
    { "kod",        "N", 7, 0 }, ; // код по картотеке
    { "tip",        "N", 1, 0 }, ; // 1-диспансеризация, 2-профосмотр
    { "tip1",       "N", 1, 0 }, ; // 1-пенсионер,2-65 лет,3-66 лет и старше
    { "voz",        "N", 1, 0 };  // 1-65 лет, 2-66 лет и старше, 3-пенсионер, 4-остальные
  } )
  r_use( dir_server + "mo_xml",, "MO_XML" )
  Index On Str( reestr, 6 ) to ( cur_dir + "tmp_xml" ) For tip_in == _XML_FILE_R12 .and. Empty( TIP_OUT )
  r_use( dir_server + "mo_dr01",, "REES" )
  Index On Str( nn, 3 ) to ( cur_dir + "tmp_dr01" ) For NYEAR == sgod .and. eq_any( NMONTH, SMONTH - 1, SMONTH ) .and. tip == 1
  Go Top
  Do While !Eof()

    If rees->kol_err < 0
      fl := func_error( 4, "В файле PR11 за " + lstr( rees->NMONTH ) + "-й месяц " + ;
        lstr( sgod ) + "г. ошибки на уровне файла! Операция запрещена" )
    Elseif Empty( rees->answer )
      fl := func_error( 4, "Файл PR11 за " + lstr( rees->NMONTH ) + "-й месяц " + ;
        lstr( sgod ) + " года не был прочитан! Операция запрещена" )
    Else
      Select MO_XML
      find ( Str( rees->kod, 6 ) )
      If Found()
        If Empty( mo_xml->TWORK2 )
          fl := func_error( 4, "Прервано чтение файла " + AllTrim( mo_xml->FNAME ) + ;
            "! Аннулируйте (Ctrl+F12) и прочитайте снова" )
        Elseif rees->NMONTH == SMONTH
          AAdd( arr_rees, rees->kod )
        Endif
      Endif
    Endif
    Select REES
    Skip
  Enddo
  If fl
    fl_1 := !Empty( arr_rees )
  Else
    Close databases
    Return Nil
  Endif

  If fl_1 // .or. code_lpu == "321001"// не первый раз
    r_use( dir_server + "mo_dr05p",, "R05p" )
    Goto ( mrec )
    skol[ 1 ] := r05p->KOL1
    skol[ 2 ] := r05p->KOL2
    skol[ 3 ] := r05p->KOL11
    skol[ 4 ] := r05p->KOL12
    skol[ 5 ] := r05p->KOL13
    skol[ 1 ] -= skol[ 3 ]
    skol[ 3 ] -= skol[ 4 ]
    skol[ 3 ] -= skol[ 5 ]
    For i := 1 To 12
      For j := 1 To 2
        ames[ i, j ] := { &( "r05p->kol" + lstr( j ) + "_" + StrZero( i, 2 ) ), 0 }
      Next
      For j := 1 To 3
        ames[ i, j + 2 ] := { &( "r05p->kol1" + lstr( j ) + "_" + StrZero( i, 2 ) ), 0 }
      Next
      ames[ i, 1, 1 ] -= ames[ i, 3, 1 ]
      ames[ i, 3, 1 ] -= ames[ i, 4, 1 ]
      ames[ i, 3, 1 ] -= ames[ i, 5, 1 ]
    Next
    // только для нужного месяца
    For j := 1 To 5
      skol[ j ] := ames[ SMONTH, j, 1 ]
    Next

    AFill( ame, 0 )
    //
    If fl
      r_use( dir_server + "mo_dr01k",, "R01k" )
      Index On Str( reestr, 6 ) + Str( kod_k, 7 ) to ( cur_dir + "tmp_dr01k" )
      r_use( dir_server + "kartotek",, "KART" )
      Use ( dir_server + "mo_dr00" ) New Alias TMP
      Index On kod to ( cur_dir + "tmp_dr00" ) For reestr == 0 .and. kod > 0
      Go Top
      Do While !Eof()
        kart->( dbGoto( tmp->kod ) )
        ar := f0_create_r11( sgod )
        If !( tmp->tip == ar[ 1 ] .and. tmp->tip1 == ar[ 2 ] .and. tmp->voz == ar[ 3 ] )
          tmp->tip := 0
        Endif
        j := tmp->tip
        j1 := tmp->tip1
        tmp->n_m := tmp->n_q := 0 // если уже заходили в режим и не подтвердили создание XML
        If Between( j, 1, 2 )
          If Between( j1, 1, 3 )
            mkol[ j1 + 2 ] ++
          Else
            mkol[ j ] ++  // подсчёт оставшегося кол -ва в пуле пациентов
          Endif
        Endif
        Skip
      Enddo
      Commit

      Index On Str( reestr, 6 ) to ( cur_dir + "tmp_dr00" )
      For ir := 1 To Len( arr_rees )
        Select R01k
        find ( Str( arr_rees[ ir ], 6 ) )
        Do While r01k->reestr == arr_rees[ ir ] .and. !Eof()
          If r01k->oplata == 1  // учтён в ТФОМС
            j := r01k->tip
            j1 := r01k->tip1
            If !Between( j, 1, 2 )
              fl := func_error( 4, "Некорректный вид осмотра в файле MO_DR01k.DBF! Операция запрещена" )
              Exit
            Endif
            If Between( j1, 1, 3 )
              ames[ SMONTH, j1 + 2, 2 ] ++
              skol[ j1 + 2 ] --
            Else
              ames[ SMONTH, j, 2 ] ++
              skol[ j ] --
            Endif
          Endif
          Select R01k
          Skip
        Enddo
        If !fl ; exit ; Endif
      Next ir
      If emptyall( skol[ 1 ], skol[ 2 ], skol[ 3 ], skol[ 4 ], skol[ 5 ] )
        fl := func_error( 4, "Более не требуется создания файлов обмена!" )
      Else
        For j := 1 To 5
          If mkol[ j ] < skol[ j ]
            s := { "диспансеризаций", "профосмотров", "дисп.пенсионеров", "дисп.65 лет", "дисп.66 лет и старше" }[ j ]
            fl := func_error( 4, "Не хватает " + lstr( skol[ j ] -mkol[ j ] ) + " чел. в картотеке для профосмотров" )
          Endif
        Next
      Endif
    Endif

    If fl
      mywait()
      For v := 1 To 5
        j := { 2, 4, 5, 3, 1 }[ v ]
        // порядок: 2-профосмотр, 4-65 лет, 5-66 и старше, 3-пенсионеры, 1-остальная дисп-ия
        If Empty( skol[ j ] )
          Loop
        Endif
        pj := j
        d := koef := Int( mkol[ j ] / skol[ j ] ) + 1 // через сколько записей прыгаем
        If d > 40
          d := koef := 31
        Endif
        i := 0
        Do While skol[ j ] > 0
          Select TMP
          If j == 2
            Index On kod to ( cur_dir + "tmp_dr00" ) For tmp->tip == 2 .and. tmp->n_q == 0 // DESCENDING
          Elseif j == 1
            Index On kod to ( cur_dir + "tmp_dr00" ) For tmp->tip == 1 .and. tmp->tip1 == 0 .and. tmp->n_q == 0 // DESCENDING
          Else
            Index On kod to ( cur_dir + "tmp_dr00" ) For eq_any( tmp->tip, 1, 2 ) .and. tmp->tip1 == pj - 2 .and. tmp->n_q == 0 // DESCENDING
          Endif
          Go Top
          Do While !Eof()
            If d == koef
              i := SMONTH
              If ames[ i, j, 1 ] > ames[ i, j, 2 ] // если ещё не набрали месяц
                tmp->n_m := i
                ames[ i, j, 2 ] ++
                skol[ j ] --
              Endif
              d := 0
            Endif
            ++d
            If Empty( skol[ j ] )
              Exit
            Endif
            Skip
          Enddo
          Select TMP
          If j == 2
            Index On kod to ( cur_dir + "tmp_dr00" ) For tmp->tip == 2 .and. tmp->n_m > 0
          Elseif j == 1
            Index On kod to ( cur_dir + "tmp_dr00" ) For tmp->tip == 1 .and. tmp->tip1 == 0 .and. tmp->n_m > 0
          Else
            Index On kod to ( cur_dir + "tmp_dr00" ) For eq_any( tmp->tip, 1, 2 ) .and. tmp->tip1 == pj - 2 .and. tmp->n_m > 0
          Endif
          Go Top
          Do While !Eof()
            If tmp->n_q == 0 .and. tmp->n_m == SMONTH
              tmp->n_q := Int( ( tmp->n_m + 2 ) / 3 ) // определяем номер квартала по месяцу
              ame[ tmp->n_m ] ++
            Endif
            Skip
          Enddo
        Enddo
      Next v
      Use ( cur_dir + "tmp_00" ) New Alias TMP1
      Select TMP
      Index On kod to ( cur_dir + "tmp_dr00" ) For reestr == 0 .and. n_m > 0
      Go Top
      Do While !Eof()
        Select TMP1
        Append Blank
        tmp1->kod  := tmp->KOD
        tmp1->tip  := tmp->tip
        tmp1->tip1 := tmp->tip1
        tmp1->voz  := tmp->voz
        Select TMP
        Skip
      Enddo
    Endif
    // quit
  Else // первый раз
  /*  select REES
    index on str(NMONTH,2)+str(nn,3) to (cur_dir+"tmp_dr01") for NYEAR == sgod .and. tip == 0
    find (str(lm,2))
    do while lm == rees->NMONTH .and. !eof()
      aadd(arr_rees,rees->kod) // список R01 за февраль
      skip
    enddo
    Use (cur_dir+"tmp_00") new alias TMP
    R_Use(dir_server+"kartotek",,"KART")
    G_Use(dir_server+"mo_dr01k",,"RHUM",.T.,.T.)
    index on str(REESTR,6) to (cur_dir+"tmp_rhum")
    for i := 1 to len(arr_rees)
      select RHUM
      find (str(arr_rees[i],6))
      do while rhum->REESTR == arr_rees[i] .and. !eof()
        kart->(dbGoto(rhum->kod_k))
        if rhum->oplata == 1
          if rhum->tip == 2 // профосмотр
            ar := f0_create_R11(sgod)
            if rhum->tip == ar[1] .and. rhum->tip1 == ar[2] .and. rhum->voz == ar[3]
              select TMP
              append blank
              tmp->kod  := rhum->KOD_K
              tmp->tip  := rhum->tip
              tmp->tip1 := rhum->tip1
              tmp->voz  := rhum->voz
            endif
          else
            rhum->oplata := 2 // все в ошибки
          endif
        endif
        select RHUM
        skip
      enddo
    next */

    //
    Select REES
    Index On Str( NMONTH, 2 ) + Str( nn, 3 ) to ( cur_dir + "tmp_dr01" ) For NYEAR == sgod .and. tip == 0
    find ( Str( lm, 2 ) )
    Do While lm == rees->NMONTH .and. !Eof()
      AAdd( arr_rees, rees->kod ) // список R01 за февраль
      Skip
    Enddo
    Use ( cur_dir + "tmp_00" ) New Alias TMP
    r_use( dir_server + "kartotek",, "KART" )
    g_use( dir_server + "mo_dr01k",, "RHUM" )
    Index On Str( REESTR, 6 ) to ( cur_dir + "tmp_rhum" )
    For i := 1 To Len( arr_rees )
      Select RHUM
      find ( Str( arr_rees[ i ], 6 ) )
      Do While rhum->REESTR == arr_rees[ i ] .and. !Eof()
        kart->( dbGoto( rhum->kod_k ) )
        If rhum->oplata == 1
          ar := f0_create_r11( sgod )
          If rhum->tip == ar[ 1 ] .and. rhum->tip1 == ar[ 2 ] .and. rhum->voz == ar[ 3 ]
            Select TMP
            Append Blank
            tmp->kod  := rhum->KOD_K
            tmp->tip  := rhum->tip
            tmp->tip1 := rhum->tip1
            tmp->voz  := rhum->voz
          Endif
        Endif
        Select RHUM
        Skip
      Enddo
    Next
  Endif

  Close databases
  If fl
    f1_create_r11( lm, fl_1 )
  Endif

  Return Nil

// 09.02.20 переопределить все три первичных ключа в картотеке
Static Function f0_create_r11( sgod )

  Local fl, v, ltip := 0, ltip1 := 0, lvoz := 0, ag, lgod_r

  If !emptyany( kart->kod, kart->fio, kart->date_r ) // данную запись в картотеке недавно удалили
    lgod_r := Year( kart->date_r )
    v := sgod - lgod_r
    If ( fl := ( v > 17 ) ) // только взрослое население
      lvoz := 4
      ltip1 := 0
      If AScan( _arr_vozrast_DVN, v ) > 0
        ltip := 1 // диспансеризация
        // 1-65 лет, 2-66 лет и старше, 3-пенсионер, 4-прочие
        If v >= iif( kart->POL == "М", 60, 55 )
          lvoz := 3
          ltip1 := 1
          If v == 65
            lvoz := 1
            ltip1 := 2
          Elseif v > 65
            lvoz := 2
            ltip1 := 3
          Endif
        Endif
      Else
        ltip := 2 // профосмотры
      Endif
    Endif
  Endif

  Return { ltip, ltip1, lvoz }

// 22.10.21
Function f1_create_r11( lm, fl_dr00 )

  Local nsh := 3, smsg, lnn := 0,buf := save_maxrow()

  If !f_esc_enter( "создания файла R11", .t. )
    Return Nil
  Endif
  g_use( dir_server + "mo_dr01m",, "RM" )
  addrecn()
  rm->DWORK := sys_date
  rm->TWORK1 := hour_min( Seconds() )
  Unlock
  //
  g_use( dir_server + "mo_dr01k",, "RHUM" )
  Index On Str( REESTR, 6 ) to ( cur_dir + "tmp_rhum" )
  g_use( dir_server + "mo_dr01",, "REES" )
  Index On Str( NMONTH, 2 ) + Str( nn, 3 ) to ( cur_dir + "tmp_dr01" ) For NYEAR == sgod .and. tip == 1
  find ( Str( lm, 2 ) )
  Do While lm == rees->NMONTH .and. !Eof()
    If lnn < rees->nn
      lnn := rees->nn
    Endif
    Skip
  Enddo
  Set Index To
  g_use( dir_server + "mo_xml",, "MO_XML" )
  r_use( dir_server + "kartote2",, "KART2" )
  r_use( dir_server + "kartote_",, "KART_" )
  r_use( dir_server + "kartotek",, "KART" )
  Set Relation To RecNo() into KART_, RecNo() into KART2
  If fl_dr00
    g_use( dir_server + "mo_dr00",, "DR00" )
    Index On Str( kod, 7 ) to ( cur_dir + "tmp_dr00" )
  Endif
  Use ( cur_dir + "tmp_00" ) New Alias TMP
  Set Relation To kod into KART
  Index On Upper( kart->fio ) + DToS( kart->date_r ) to ( cur_dir + "tmp_00" )
  //
  SMONTH := lm
  smsg := "Составление файла R11 за " + lstr( SMONTH ) + "-й месяц"
  stat_msg( smsg )
  Select REES
  addrecn()
  rees->KOD    := RecNo()
  rees->tip    := 1
  rees->DSCHET := sys_date
  rees->NYEAR  := sgod
  rees->NMONTH := SMONTH
  rees->NN     := lnn + 1
  s := "R11" + "T34M" + CODE_LPU + "_" + Right( StrZero( rees->NYEAR, 4 ), 2 ) + StrZero( rees->NMONTH, 2 ) + StrZero( rees->NN, nsh )
  rees->NAME_XML := s
  mkod_reestr := rees->KOD
  //
  rm->( g_rlock( forever ) )
  &( "rm->reestr" + StrZero( SMONTH, 2 ) ) := mkod_reestr
  //
  Select MO_XML
  addrecn()
  mo_xml->KOD    := RecNo()
  mo_xml->FNAME  := s
  mo_xml->FNAME2 := ""
  mo_xml->DFILE  := rees->DSCHET
  mo_xml->TFILE  := hour_min( Seconds() )
  mo_xml->TIP_IN := 0
  mo_xml->TIP_OUT := _XML_FILE_R11  // тип высылаемого файла - R11
  mo_xml->REESTR := mkod_reestr
  //
  rees->KOD_XML := mo_xml->KOD
  Unlock
  Commit
  pkol := 0
  Select TMP
  Go Top
  Do While !Eof()
    If tmp->reestr == 0
      ++pkol
      @ MaxRow(), 1 Say lstr( pkol ) Color cColorSt2Msg
      If fl_dr00 // для второго и т.д. реестров в месяце
        Select DR00
        find ( Str( tmp->kod, 7 ) )
        If Found()
          g_rlock( forever )
          dr00->reestr := mkod_reestr
        Endif
      Endif
      //
      Select RHUM
      addrec( 6 )
      rhum->REESTR := mkod_reestr
      rhum->KOD_K := tmp->kod
      rhum->n_m := SMONTH
      rhum->tip := tmp->tip
      rhum->tip1 := tmp->tip1
      rhum->voz := tmp->voz
      rhum->R01_ZAP := pkol
      rhum->ID_PAC := mo_guid( 1, tmp->kod )
      rhum->OPLATA := 0
    Endif
    If pkol % 2000 == 0
      dbUnlockAll()
      dbCommitAll()
    Endif
    Select TMP
    Skip
  Enddo
  Select REES
  g_rlock( forever )
  rees->KOL := pkol
  rees->KOL_ERR := 0
  dbUnlockAll()
  dbCommitAll()
  //
  stat_msg( smsg )
  //
  oXmlDoc := hxmldoc():new()
  oXmlDoc:add( hxmlnode():new( "ZL_LIST" ) )
  oXmlNode := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( "ZGLV" ) )
  mo_add_xml_stroke( oXmlNode, "VERSION", '3.0' )
  mo_add_xml_stroke( oXmlNode, "CODEM", CODE_LPU )
  mo_add_xml_stroke( oXmlNode, "DATE_F", date2xml( mo_xml->DFILE ) )
  mo_add_xml_stroke( oXmlNode, "NAME_F", mo_xml->FNAME )
  mo_add_xml_stroke( oXmlNode, "SMO", '34' )
  mo_add_xml_stroke( oXmlNode, "YEAR", lstr( rees->NYEAR ) )
  mo_add_xml_stroke( oXmlNode, "MONTH", lstr( rees->NMONTH ) )
  mo_add_xml_stroke( oXmlNode, "N_PACK", lstr( rees->NN ) )
  //
  Select RHUM
  Set Relation To kod_k into KART
  Index On Str( R01_ZAP, 6 ) to ( cur_dir + "tmp_rhum" ) For REESTR == mkod_reestr
  Go Top
  Do While !Eof()
    @ MaxRow(), 0 Say Str( rhum->R01_ZAP / pkol * 100, 6, 2 ) + "%" Color cColorSt2Msg
    arr_fio := retfamimot( 1, .f. )
    oXmlNode := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( "PERSONS" ) )
    mo_add_xml_stroke( oXmlNode, "ZAP", lstr( rhum->R01_ZAP ) )
    mo_add_xml_stroke( oXmlNode, "IDPAC", rhum->ID_PAC )
    mo_add_xml_stroke( oXmlNode, "SURNAME", arr_fio[ 1 ] )
    mo_add_xml_stroke( oXmlNode, "NAME", arr_fio[ 2 ] )
    If !Empty( arr_fio[ 3 ] )
      mo_add_xml_stroke( oXmlNode, "PATRONYMIC", arr_fio[ 3 ] )
    Endif
    mo_add_xml_stroke( oXmlNode, "BIRTHDAY", date2xml( kart->date_r ) )
    mo_add_xml_stroke( oXmlNode, "SEX", iif( kart->pol == "М", '1', '2' ) )
    If !Empty( kart->snils )
      mo_add_xml_stroke( oXmlNode, "SS", Transform( kart->SNILS, picture_pf ) )
    Endif
    // проверим наличие ЕНП - иначе старый вариант
    If Len( AllTrim( kart2->KOD_MIS ) ) > 14
      mo_add_xml_stroke( oXmlNode, "TYPE_P", lstr( 3 ) ) // только НОВЫЙ
      s := AllTrim( kart2->KOD_MIS )
      s := PadR( s, 16, "0" )
      //
      mo_add_xml_stroke( oXmlNode, "NUM_P", s )
      mo_add_xml_stroke( oXmlNode, "ENP", s )
    Else
      mo_add_xml_stroke( oXmlNode, "TYPE_P", lstr( iif( Between( kart_->VPOLIS, 1, 3 ), kart_->VPOLIS, 1 ) ) )
      If !Empty( kart_->SPOLIS )
        mo_add_xml_stroke( oXmlNode, "SER_P", kart_->SPOLIS )
      Endif
      s := AllTrim( kart_->NPOLIS )
      If kart_->VPOLIS == 3 .and. Len( s ) != 16
        s := PadR( s, 16, "0" )
      Endif
      mo_add_xml_stroke( oXmlNode, "NUM_P", s )
      If kart_->VPOLIS == 3
        mo_add_xml_stroke( oXmlNode, "ENP", s )
      Endif
    Endif
  /*
      mo_add_xml_stroke(oXmlNode,"TYPE_P",lstr(iif(between(kart_->VPOLIS,1,3),kart_->VPOLIS,1)))
      if !empty(kart_->SPOLIS)
        mo_add_xml_stroke(oXmlNode,"SER_P",kart_->SPOLIS)
      endif
      s := alltrim(kart_->NPOLIS)
      if kart_->VPOLIS == 3 .and. len(s) != 16
        s := padr(s,16,"0")
      endif
      mo_add_xml_stroke(oXmlNode,"NUM_P",s)
      if kart_->VPOLIS == 3
        mo_add_xml_stroke(oXmlNode,"ENP",s)
      endif*/
    mo_add_xml_stroke( oXmlNode, "DOCTYPE", lstr( kart_->vid_ud ) )
    If !Empty( kart_->ser_ud )
      mo_add_xml_stroke( oXmlNode, "DOCSER", kart_->ser_ud )
    Endif
    mo_add_xml_stroke( oXmlNode, "DOCNUM", kart_->nom_ud )
    If !Empty( smr := del_spec_symbol( kart_->mesto_r ) )
      mo_add_xml_stroke( oXmlNode, "MR", smr )
    Endif
    mo_add_xml_stroke( oXmlNode, "CATEGORY", '0' )
    mo_add_xml_stroke( oXmlNode, "T_PR", { "O", "R" }[ rhum->tip ] )
    oCONTACTS := oXmlNode:add( hxmlnode():new( "CONTACTS" ) )
    If !Empty( kart_->PHONE_H )
      mo_add_xml_stroke( oCONTACTS, "TEL_F", Left( kart_->PHONE_H, 1 ) + "-" + SubStr( kart_->PHONE_H, 2, 4 ) + "-" + SubStr( kart_->PHONE_H, 6 ) )
    Endif
    If !Empty( kart_->PHONE_M )
      mo_add_xml_stroke( oCONTACTS, "TEL_M", Left( kart_->PHONE_M, 1 ) + "-" + SubStr( kart_->PHONE_M, 2, 3 ) + "-" + SubStr( kart_->PHONE_M, 5 ) )
    Endif
    oADDRESS := oCONTACTS:add( hxmlnode():new( "ADDRESS" ) )
    s := "18000"
    If Len( AllTrim( kart_->okatop ) ) == 11
      s := Left( kart_->okatop, 5 )
    Elseif Len( AllTrim( kart_->okatog ) ) == 11
      s := Left( kart_->okatog, 5 )
    Endif
    mo_add_xml_stroke( oADDRESS, "SUBJ", s )
    If !Empty( kart->adres )
      mo_add_xml_stroke( oADDRESS, "UL", kart->adres )
    Endif
    Select RHUM
    Skip
  Enddo
  stat_msg( "Запись XML-файла" )
  oXmlDoc:save( AllTrim( mo_xml->FNAME ) + sxml )
  chip_create_zipxml( AllTrim( mo_xml->FNAME ) + szip, { AllTrim( mo_xml->FNAME ) + sxml }, .t. )
  rm->( g_rlock( forever ) )
  rm->TWORK2 := hour_min( Seconds() )
  Close databases
  Keyboard Chr( K_TAB ) + Chr( K_ENTER )
  rest_box( buf )

  Return Nil

// 28.12.21
Function delete_reestr_r11()

  Local t_arr[ BR_LEN ], blk

  If ! hb_user_curUser:isadmin()
    Return func_error( 4, err_admin )
  Endif
  g_use( dir_server + "mo_dr01m",, "R01m" )
  Index On Descend( DToS( DWORK ) + TWORK1 ) to ( cur_dir + "tmp_dr01m" )
  Go Top
  If Eof()
    func_error( 4, "Не было создано файлов R11..." )
  Else
    t_arr[ BR_TOP ] := T_ROW
    t_arr[ BR_BOTTOM ] := MaxRow() -2
    t_arr[ BR_LEFT ] := 2
    t_arr[ BR_RIGHT ] := 77
    t_arr[ BR_COLOR ] := color0
    t_arr[ BR_TITUL ] := "Список созданных пакетов реестров R11"
    t_arr[ BR_TITUL_COLOR ] := "B/BG"
    t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', "N/BG,W+/N,B/BG,W+/B", .t. }
    blk := {|| iif( Empty( r01m->twork2 ), { 3, 4 }, { 1, 2 } ) }
    t_arr[ BR_COLUMN ] := { ;
      { "  Дата;создания", {|| date_8( r01m->dwork ) }, blk }, ;
      { "янв;арь", {|| iif( r01m->reestr01 > 0, "да ", "нет" ) }, blk }, ;
      { "фев;рал", {|| iif( r01m->reestr02 > 0, "да ", "нет" ) }, blk }, ;
      { "мар;т  ", {|| iif( r01m->reestr03 > 0, "да ", "нет" ) }, blk }, ;
      { "апр;ель", {|| iif( r01m->reestr04 > 0, "да ", "нет" ) }, blk }, ;
      { "май;   ", {|| iif( r01m->reestr05 > 0, "да ", "нет" ) }, blk }, ;
      { "июн;ь  ", {|| iif( r01m->reestr06 > 0, "да ", "нет" ) }, blk }, ;
      { "июл;ь  ", {|| iif( r01m->reestr07 > 0, "да ", "нет" ) }, blk }, ;
      { "авг;уст", {|| iif( r01m->reestr08 > 0, "да ", "нет" ) }, blk }, ;
      { "сен;тяб", {|| iif( r01m->reestr09 > 0, "да ", "нет" ) }, blk }, ;
      { "окт;ябр", {|| iif( r01m->reestr10 > 0, "да ", "нет" ) }, blk }, ;
      { "ноя;брь", {|| iif( r01m->reestr11 > 0, "да ", "нет" ) }, blk }, ;
      { "дек;абр", {|| iif( r01m->reestr12 > 0, "да ", "нет" ) }, blk }, ;
      { "Время;начала",    {|| r01m->twork1 }, blk }, ;
      { "Время;окончания", {|| PadR( iif( Empty( r01m->twork2 ), "НЕ ЗАВЕРШЕНО", r01m->twork2 ), 10 ) }, blk };
      }
    t_arr[ BR_EDIT ] := {| nk, ob| f1_delete_reestr_r11( nk, ob, "edit" ) }
    t_arr[ BR_FL_INDEX ] := .f.
    t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ - выход;  ^<Enter>^ - аннулирование создания пакета реестров R01" ) }
    edit_browse( t_arr )
  Endif
  Close databases

  Return Nil

// 09.02.20
Function f1_delete_reestr_r11( nKey, oBrow, regim )

  Local ret := -1, rec_m := r01m->( RecNo() ), ir, fl := .t.

  If regim == "edit" .and. nKey == K_ENTER
    If Empty( r01m->twork2 )
      g_use( dir_server + "mo_dr01",, "REES" )
      For ir := 1 To 12
        mkod_reestr := &( "r01m->reestr" + StrZero( ir, 2 ) )
        If mkod_reestr > 0
          Select REES
          Goto ( mkod_reestr )
          If rees->tip == 0
            fl := func_error( 4, "Это файл R01. Операция запрещена!" )
            Exit
          Elseif rees->ANSWER == 1
            fl := func_error( 4, "Уже получен ответ PR11 за " + lstr( ir ) + "-й месяц. Операция запрещена!" )
            Exit
          Endif
        Endif
      Next
      REES->( dbCloseArea() )
      Select R01m
      If fl .and. f_esc_enter( "аннулирования R11" )
        mywait()
        f2_delete_reestr_r11( rec_m )
        stat_msg( "Аннулирование завершено!" ) ; mybell( 2, OK )
        ret := 1
      Endif
    Else
      func_error( 4, "Процесс создания реестра R11 завершён корректно. Операция запрещена!" )
    Endif
  Endif

  Return ret


// 09.02.20 аннулировать чтение реестра R11
Function f2_delete_reestr_r11( rec_m )

  Local ir, mkod_reestr

  g_use( dir_server + "mo_xml",, "MO_XML" )
  g_use( dir_server + "mo_dr00",, "TMP" )
  Index On Str( REESTR, 6 ) to ( cur_dir + "tmp_dr00" )
  g_use( dir_server + "mo_dr01k",, "RHUM" )
  Index On Str( REESTR, 6 ) to ( cur_dir + "tmp_rhum" )
  g_use( dir_server + "mo_dr01",, "REES" )
  Select R01m
  Goto ( rec_m )
  For ir := 12 To 1 Step -1
    mkod_reestr := &( "r01m->reestr" + StrZero( ir, 2 ) )
    If mkod_reestr > 0
      Select REES
      Goto ( mkod_reestr )
      Select TMP
      Do While .t.
        find ( Str( mkod_reestr, 6 ) )
        If !Found() ; exit ; Endif
        g_rlock( forever )
        tmp->n_m := 0
        tmp->n_q := 0
        tmp->reestr := 0
        dbUnlock()
      Enddo
      Select RHUM
      Do While .t.
        find ( Str( mkod_reestr, 6 ) )
        If !Found() ; exit ; Endif
        deleterec( .t. )
      Enddo
      Select MO_XML
      Goto ( rees->KOD_XML )
      deleterec( .t. )
      Select REES
      deleterec( .t. )
      Select R01m
      g_rlock( forever )
      &( "r01m->reestr" + StrZero( ir, 2 ) ) := 0
      dbUnlockAll()
      dbCommitAll()
    Endif
  Next
  mo_xml->( dbCloseArea() )
  tmp->( dbCloseArea() )
  RHUM->( dbCloseArea() )
  REES->( dbCloseArea() )
  Select R01m
  deleterec()

  Return Nil

// 13.02.20 удаление всех пакетов R11(PR11) за конкретный месяц
Function delete_month_r11()

  Local pss := Space( 10 ), tmp_pss := my_parol()
  Local i, lm, mkod_reestr, ar_m := {}, buf

  If Select( "MO_XML" ) > 0
    Return Nil
  Endif
  If ( lm := input_value( 18, 6, 20, 73, color1, Space( 9 ) + "Введите удаляемый месяц (все файлы R11,PR11)", 2, "99" ) ) == NIL
    Return Nil
  Elseif !Between( lm, 2, 12 )
    Return Nil
  Else
    pss := get_parol(,,,,, "N/W", "W/N*" )
    If LastKey() == K_ENTER .and. AScan( tmp_pss, Crypt( pss, gpasskod ) ) > 0 .and. f_esc_enter( "удаления файлов R11", .t. )
      //
    Else
      Return Nil
    Endif
  Endif
  g_use( dir_server + "mo_xml",, "MO_XML" )
  Index On Str( reestr, 6 ) to ( cur_dir + "tmp_xml" ) For tip_in == _XML_FILE_R12 .and. TIP_OUT == 0
  g_use( dir_server + "mo_dr01",, "REES" )
  g_use( dir_server + "mo_dr01m",, "R01m" )
  Go Top
  Do While !Eof()
    mkod_reestr := &( "r01m->reestr" + StrZero( lm, 2 ) )
    If mkod_reestr > 0
      Select MO_XML
      find ( Str( mkod_reestr, 6 ) )
      Select REES
      Goto ( mkod_reestr )
      If rees->tip == 1
        AAdd( ar_m, { r01m->( RecNo() ), mkod_reestr, iif( rees->answer == 1, mo_xml->kod, 0 ) } )
      Endif
    Endif
    Select R01m
    Skip
  Enddo
  REES->( dbCloseArea() )
  mo_xml->( dbCloseArea() )
  buf := save_maxrow()
  If Empty( ar_m )
    func_error( 10, "Не обнаружено реестров R11 за " + lstr( lm ) + " месяц!" )
  Else
    For i := Len( ar_m ) To 1 Step -1
      stat_msg( "Удаляется " + lstr( i ) + "-й реестр R11" )
      If ar_m[ i, 3 ] > 0
        f2_delete_reestr_r02( ar_m[ i, 2 ], ar_m[ i, 3 ] )
      Endif
      Close databases
      g_use( dir_server + "mo_dr01m",, "R01m" )
      f2_delete_reestr_r11( ar_m[ i, 1 ] )
    Next
    stat_msg( "Успешно удалено реестров R11 - " + lstr( Len( ar_m ) ) + " (и, соответственно, ответов на них PR11)" )
    Inkey( 10 )
  Endif
  rest_box( buf )
  Close databases

  Return Nil

// 28.02.21 удаление всех пакетов R01(PR01) за конкретный месяц
/*
Function delete_month_R01()
Local pss := space(10), tmp_pss := my_parol()
Local i, lm, mkod_reestr, ar_m := {}, buf
if select("MO_XML") > 0
  return NIL
endif
if (lm := input_value(18,6,20,73,color1,space(9)+"Введите удаляемый месяц (все файлы R01,PR01)",2,"99")) == NIL
  return NIL
elseif !between(lm,2,12)
  return NIL
else
  pss := get_parol(,,,,,"N/W","W/N*")
  if lastkey() == K_ENTER .and. ascan(tmp_pss,crypt(pss,gpasskod)) > 0 .and. f_Esc_Enter("удаления файлов R01",.t.)
    //
  else
    return NIL
  endif
endif
G_Use(dir_server+"mo_xml",,"MO_XML")
index on str(reestr,6) to (cur_dir+"tmp_xml") for tip_in == _XML_FILE_R02 .and. TIP_OUT == 0
G_Use(dir_server+"mo_dr01",,"REES")
G_Use(dir_server+"mo_dr01m",,"R01m")
go top
do while !eof()
  mkod_reestr := &("r01m->reestr"+strzero(lm,2))
  if mkod_reestr > 0
    select MO_XML
    find (str(mkod_reestr,6))
    select REES
    goto (mkod_reestr)
    if rees->tip == 0
      aadd(ar_m,{r01m->(recno()),mkod_reestr,iif(rees->answer==1,mo_xml->kod,0)})
    endif
  endif
  select R01m
  skip
enddo
REES->(dbCloseArea())
mo_xml->(dbCloseArea())
buf := save_maxrow()
if empty(ar_m)
  func_error(10,"Не обнаружено реестров R01 за "+lstr(lm)+" месяц!")
else
  for i := len(ar_m) to 1 step -1
    stat_msg("Удаляется "+lstr(i)+"-й реестр R01")
    if ar_m[i,3] > 0
      f2_delete_reestr_R02(ar_m[i,2],ar_m[i,3])
    endif
    close databases
    G_Use(dir_server+"mo_dr01m",,"R01m")
    f2_delete_reestr_R01(ar_m[i,1])
  next
  stat_msg("Успешно удалено реестров R01 - "+lstr(len(ar_m))+" (и, соответственно, ответов на них PR01)")
  inkey(10)
endif
rest_box(buf)
close databases
return NIL
*/

// 25.02.21
Function f32_view_r11( lm )

  Local fl := .t., buf := save_maxrow(), k := 0, skol[ 5, 3 ], ames[ 12, 5, 3 ], mrec := 2, n_file := "r11_itog" + stxt, ;
    arr_rees := {}, mkod_reestr := 0
  Private par := .f.

  afillall( skol, 0 )
  afillall( ames, 0 )
  mywait()
  r_use( dir_server + "mo_dr05p",, "R05p" )
  Goto ( mrec )
  skol[ 1, 1 ] := r05p->KOL1
  skol[ 2, 1 ] := r05p->KOL2
  skol[ 3, 1 ] := r05p->KOL11
  skol[ 4, 1 ] := r05p->KOL12
  skol[ 5, 1 ] := r05p->KOL13
  If par
    skol[ 1, 1 ] -= skol[ 3, 1 ]
    skol[ 3, 1 ] -= skol[ 4, 1 ]
    skol[ 3, 1 ] -= skol[ 5, 1 ]
  Endif
  For i := 1 To 12
    For j := 1 To 2
      ames[ i, j, 1 ] := &( "r05p->kol" + lstr( j ) + "_" + StrZero( i, 2 ) )
    Next
    For j := 1 To 3
      ames[ i, j + 2, 1 ] := &( "r05p->kol1" + lstr( j ) + "_" + StrZero( i, 2 ) )
    Next
    If par
      ames[ i, 1, 1 ] -= ames[ i, 3, 1 ]
      ames[ i, 3, 1 ] -= ames[ i, 4, 1 ]
      ames[ i, 3, 1 ] -= ames[ i, 5, 1 ]
    Endif
  Next
  r05p->( dbCloseArea() )
  // только для нужного месяца
  For j := 1 To 5
    skol[ j ] := ames[ lm, j, 1 ]
  Next
  r_use( dir_server + "mo_dr01k",, "RHUM" )
  Index On Str( reestr, 6 ) + Str( rhum->R01_ZAP, 6 ) to ( cur_dir + "tmp_rhum" )
  Select REES
  Go Top
  Do While !Eof()
    AAdd( arr_rees, rees->kod )
    Skip
  Enddo

  For k := Len( arr_rees ) To 1 Step -1

    mkod_reestr := arr_rees[ k ]
    Select RHUM
    find ( Str( mkod_reestr, 6 ) )
    Do While rhum->reestr == mkod_reestr .and. !Eof()
      If rhum->OPLATA < 2
        i := lm
        j := rhum->tip
        j1 := rhum->tip1
        If Between( j1, 1, 3 )
          ames[ i, j1 + 2, 2 ] ++
        Elseif Between( j, 1, 2 )
          ames[ i, j, 2 ] ++
        Endif
        If rhum->OPLATA == 1
          If Between( j1, 1, 3 )
            ames[ i, j1 + 2, 3 ] ++
          Elseif Between( j, 1, 2 )
            ames[ i, j, 3 ] ++
          Endif
        Endif
      Endif
      Select RHUM
      Skip
    Enddo
  Next k
  rhum->( dbCloseArea() )
  If !par
    For i := 1 To 12
      For k := 2 To 3
        ames[ i, 3, k ] += ames[ i, 4, k ]
        ames[ i, 3, k ] += ames[ i, 5, k ]
        ames[ i, 1, k ] += ames[ i, 3, k ]
      Next
    Next
  Endif
  //
  fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  add_string( Center( "Общая информация (R11)", 80 ) )
  add_string( "" )
  mmt := { "диспансеризация", "профосмотр", "дисп.пенсионеры", "дисп.65 лет", "дисп.66 и старше" }
  For i := lm To lm
    add_string( "──────────────────────────┬─────────────┬─────────────┬────────────┬────────────" )
    add_string( "     месяц                │  по плану   │  отправлено │  в ТФОМСе  │ расхождение" )
    add_string( "──────────────────────────┴─────────────┴─────────────┴────────────┴────────────" )
    n := 26
    add_string( PadR( mm_month[ i ], n ) )
    For j := 1 To 5
      add_string( PadL( mmt[ j ], n ) + put_val( ames[ i, j, 1 ], 11 ) + ;
        put_val( ames[ i, j, 2 ], 14 ) + ;
        put_val( ames[ i, j, 3 ], 13 ) + ;
        put_val( ames[ i, j, 1 ] -ames[ i, j, 3 ], 12 ) )
      // skol[j,2] += ames[i,j,2]
      // skol[j,3] += ames[i,j,3]
    Next
  Next
  add_string( PadR( "Итого:", n ) )
/*  for j := 1 to 5
    add_string(padl(mmt[j],n)+put_val(skol[j,1],11)+;
                              put_val(skol[j,2],14)+;
                              put_val(skol[j,3],13)+;
                              put_val(skol[j,1]-skol[j,3],12))
  next
*/
  FClose( fp )
  rest_box( buf )
  viewtext( n_file,,,, .t.,,, 2 )

  Return Nil

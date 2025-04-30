// mo_omso.prg - работа с оплатой счетов в задаче ОМС (акты контроля)
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

Static lcount_uch := 1
Static lcount_otd := 1

// 30.04.25 прочитать и "разнести" по базам данных РАК 
Function read_xml_file_rak( arr_XML_info, aerr )

  Local fl_akt, fl_schet, blk_akt, blk_schet, i, k, s, s1, arr_s := {}, t_arr[ 2 ], ;
    ia, is, ih, arr, aakt := {}, no_write := .t., fl_2019
  Local tmp_alias, fl_IDC := .f.   // для двойного случая
  Local arrF006 := getf006()

  blk_akt := {|| AAdd( aerr, "АКТ № " + AllTrim( tmp2->_nakt ) + " от " + date_8( tmp2->_dakt ) ) }
  blk_schet := {|| AAdd( aerr, " СЧЁТ № " + AllTrim( tmp3->_nschet ) + " от " + date_8( tmp3->_dschet ) ) }
  Use ( cur_dir + "tmp1file" ) New Alias TMP1
  fl_2019 := ( Val( tmp1->_VERSION ) > 3.1 )
  tmp1->_SMO     := arr_XML_info[ 2 ]
  tmp1->_CODE_MO := arr_XML_info[ 3 ]
  tmp1->_YEAR    := arr_XML_info[ 4 ]
  tmp1->_MONTH   := arr_XML_info[ 5 ]
  Use ( cur_dir + "tmp2file" ) New Alias TMP2
  Use ( cur_dir + "tmp3file" ) New Alias TMP3
  Index On Str( kod_a, 6 ) to ( cur_dir + "tmp3" )
  Use ( cur_dir + "tmp4file" ) New Alias TMP4
  Index On Str( kod_a, 6 ) + Str( kod_s, 6 ) to ( cur_dir + "tmp4" )
  Use ( cur_dir + "tmp5file" ) New Alias TMP5
  Index On Str( kod_a, 6 ) to ( cur_dir + "tmp5" )
  Use ( cur_dir + "tmp6file" ) New Alias TMP6
  Index On Str( kod_a, 6 ) + Str( kod_s, 6 ) + Str( _idcase, 8 ) to ( cur_dir + "tmp6" )
  // сначала найдём коды счетов и коды листов учёта
  g_use( dir_server + "schet_", , "SCHET_" )
  Index On DToS( dschet ) + Upper( nschet ) to ( cur_dir + "tmp_sch_" )
  r_use( dir_server + "mo_otd", , "OTD" )
  g_use( dir_server + "human_", , "HUMAN_" )
  r_use( dir_server + "human", , "HUMAN" )
  Set Relation To RecNo() into HUMAN_, To otd into OTD
  // R_Use(dir_server + "mo_os", , "MO_OS")
  // index on str(kod, 7) to (cur_dir + "tmp_moos") for NEXT_KOD > 0
  ia := is := ih := 0
  @ MaxRow(), 0 Say Space( MaxCol() + 1 ) Color "G+/R*"
  Select TMP2
  Go Top
  Do While !Eof()
    ++ia
    fl_akt := .t.
    arr := {}
    Select TMP3
    find ( Str( tmp2->kod_a, 6 ) )
    Do While tmp2->kod_a == tmp3->kod_a .and. !Eof()
      ++is
      fl_schet := .t.
      Select SCHET_
      find ( DToS( tmp3->_dschet ) + Upper( tmp3->_nschet ) )
      If Found()
        no_write := .f.
        AAdd( arr, schet_->( RecNo() ) )
        tmp3->kod_schet := schet_->( RecNo() )
        If !( tmp3->_PLAT == schet_->smo )
          If fl_akt
            Eval( blk_akt )
            fl_akt := .f.
          Endif
          If fl_schet
            Eval( blk_schet )
            fl_schet := .f.
          Endif
          AAdd( aerr, "  не равен код плательщика: в файле - " + AllTrim( tmp3->_PLAT ) + ", у нас - " + AllTrim( schet_->smo ) )
        Endif
        //
        Select HUMAN
        Set Index to ( dir_server + "humans" )
        find ( Str( tmp3->kod_schet, 6 ) )
        Index On Str( human_->schet_zap, 6 ) to ( cur_dir + "tmp_hum" ) For ishod != 89 While schet == tmp3->kod_schet
        Select TMP4
        find ( Str( tmp3->kod_a, 6 ) + Str( tmp3->kod_s, 6 ) )
        Do While tmp3->kod_a == tmp4->kod_a .and. tmp3->kod_s == tmp4->kod_s .and. !Eof()
          ++ih
          @ MaxRow(), 1  Say "подготовка: " + lstr( ia ) Color "G+/R*"
          @ Row(), Col() Say "/"      Color "R/R*"
          @ Row(), Col() Say lstr( is ) Color "GR+/R*"
          @ Row(), Col() Say "/"      Color "R/R*"
          @ Row(), Col() Say lstr( ih ) Color "W+/R*"
          Select HUMAN
          find ( Str( tmp4->_IDCASE, 6 ) )
          If Found()
            tmp4->KOD_H := human->kod
            fl_IDC := ( Upper( tmp4->_ID_C ) == Upper( human_->ID_C ) )
            If !fl_IDC
              tmp_alias := Select()
              r_use( dir_server + "human_3", dir_server + "human_3", "HUMAN_3" )
              If human_3->( dbSeek( Str( human_->( RecNo() ), 7 ) ) )
                fl_IDC := ( Upper( tmp4->_ID_C ) == Upper( human_3->ID_C ) )
              Endif
              human_3->( dbCloseArea() )
              Select( tmp_alias )
            Endif

            If !fl_IDC
              If fl_akt
                Eval( blk_akt )
                fl_akt := .f.
              Endif
              If fl_schet
                Eval( blk_schet )
                fl_schet := .f.
              Endif
              AAdd( aerr, "  случай № " + lstr( tmp4->_IDCASE ) + ", " + AllTrim( human->fio ) + ", л/у " + lstr( human->kod ) )
              AAdd( aerr, "   ID_C в СМО = " + tmp4->_ID_C + ", ID_C у нас = " + human_->ID_C )
            Endif
          Else
            If fl_akt
              Eval( blk_akt )
              fl_akt := .f.
            Endif
            If fl_schet
              Eval( blk_schet )
              fl_schet := .f.
            Endif
            AAdd( aerr, "   не найден пациент с IDCASE = " + lstr( tmp4->_IDCASE ) )
          Endif
          Select TMP4
          Skip
        Enddo
      Else
        If fl_akt
          // eval(blk_akt)
          // fl_akt := .f.
        Endif
        AAdd( arr_s, { tmp3->kod_a, tmp3->kod_s, ;
          " Не найден СЧЁТ № " + AllTrim( tmp3->_nschet ) + " от " + date_8( tmp3->_dschet ) } )
      Endif
      Select TMP3
      Skip
    Enddo
    AAdd( aakt, { tmp2->kod_a, arr } )
    Select TMP2
    Skip
  Enddo
  Commit
  If no_write
    AAdd( aerr, " Из этого РАК нечего записывать в текущую базу данных" )
  Endif
  If !Empty( aerr )
    For i := 1 To Len( arr_s )
      AAdd( aerr, arr_s[ i, 3 ] )
    Next
    Return Nil
  Endif
  // запишем принимаемый файл (РАК)
  // chip_copy_zipXML(hb_OemToAnsi(full_zip), dir_server+dir_XML_TF)
  chip_copy_zipxml( full_zip, dir_server + dir_XML_TF )
  g_use( dir_server + "mo_xml", , "MO_XML" )
  addrecn()
  mo_xml->KOD := RecNo()
  mo_xml->FNAME := cReadFile
  mo_xml->DFILE := tmp1->_DATA
  mo_xml->TFILE := ""
  mo_xml->DREAD := sys_date
  mo_xml->TREAD := hour_min( Seconds() )
  mo_xml->TIP_IN := _XML_FILE_RAK
  mo_xml->DWORK  := sys_date
  mo_xml->TWORK1 := hour_min( Seconds() )
  mo_xml->TWORK2 := ""
  mo_xml->KOL1 := tmp1->KOL_AKT
  mo_xml->KOL2 := tmp1->KOL_SCH
  rec_xml := mo_xml->KOD
  Unlock
  Commit
  StrFile( hb_eol() + ;
    "Количество актов - " + lstr( tmp1->KOL_AKT ) + hb_eol() + ;
    "Количество счетов - " + lstr( tmp1->KOL_SCH ) + hb_eol() + ;
    "Количество пациентов всего - " + lstr( tmp1->KOL_PAC ) + hb_eol() + ;
    "  в т.ч. количество снятий  - " + lstr( tmp1->KOL_ERR ) + hb_eol() + ;
    "         количество штрафов - " + lstr( tmp1->KOL_PEN ) + hb_eol(), cFileProtokol, .t. )
  //
  Select HUMAN
  Set Index To
  r_use( dir_server + "human_3", { dir_server + "human_3", dir_server + "human_32" }, "HUMAN_3" )
  g_use( dir_server + "mo_rak", , "RAK" )
  Set Relation To KOD_XML into MO_XML
  Index On Str( akt, 6 ) to ( cur_dir + "tmprak" )
  Index On ret_owner_rak( mo_xml->FNAME ) + Str( Year( dakt ), 4 ) + Upper( PadR( nakt, 30 ) ) to ( cur_dir + "tmprak1" )
  Set Index to ( cur_dir + "tmprak" ), ( cur_dir + "tmprak1" )
  g_use( dir_server + "mo_rakexp", , "RAKEXP" )
  Index On Str( akt, 6 ) to ( cur_dir + "tmprakexp" )
  g_use( dir_server + "mo_raks", , "RAKS" )
  Index On Str( akt, 6 ) to ( cur_dir + "tmpraks" )
  g_use( dir_server + "mo_raksh", , "RAKSH" )
  Index On Str( kod_raks, 6 ) to ( cur_dir + "tmpraksh" )
  g_use( dir_server + "mo_raksherr", , "RAKSHERR" )
  Index On Str( kod_raksh, 8 ) to ( cur_dir + "tmpraksherr" )
  ia := is := ih := 0
  @ MaxRow(), 0 Say Space( MaxCol() + 1 ) Color "G+/R*"
  Select TMP2
  Go Top
  Do While !Eof()
    ++ia
    s := hb_eol() + "АКТ № " + AllTrim( tmp2->_nakt ) + " от " + date_8( tmp2->_dakt )
    Select RAK
    Set Order To 2
    find ( ret_owner_rak( cReadFile ) + Str( Year( tmp2->_dakt ), 4 ) + Upper( PadR( tmp2->_nakt, 30 ) ) )
    If Found()
      StrFile( s + " - дубликат в " + RTrim( mo_xml->FNAME ) + hb_eol() + hb_eol(), cFileProtokol, .t. )
    Elseif ( i := AScan( aakt, {| x| x[ 1 ] == tmp2->kod_a } ) ) > 0 .and. Empty( aakt[ i, 2 ] )
      StrFile( s + " - не найдено счетов в базе данных"  + hb_eol() + hb_eol(), cFileProtokol, .t. )
    Else
      s += ", счетов - " + lstr( tmp2->KOL_SCH ) + ;
        ", пациентов всего - " + lstr( tmp2->KOL_PAC )
      If tmp2->KOL_ERR > 0
        s += ", в т.ч. снятий - " + lstr( tmp2->KOL_ERR )
      Endif
      If tmp2->KOL_PEN > 0
        s += ", в т.ч. штрафов - " + lstr( tmp2->KOL_PEN )
      Endif
      put_long_str( s, cFileProtokol )
      If AScan( arrF006, {| x| x[ 2 ] == tmp2->_KONT } ) > 0
        s := 'Вид контроля: ' + inieditspr( A__MENUVERT, arrF006, tmp2->_KONT )
        put_long_str( s, cFileProtokol )
      Endif
      If tmp2->_TYPEK > 0
        s := "Проведенный Контроль: " + iif( tmp2->_TYPEK == 1, "первичный", "повторный" )
        If Between( tmp2->_SKONT, 1, 2 )
          s += ", вид экспертизы: " + iif( tmp2->_skont == 1, "плановая", "целевая" )
        Endif
        StrFile( s + hb_eol(), cFileProtokol, .t. )
        put_long_str( s, cFileProtokol )
      Endif
      Select RAK
      Set Order To 1
      addrec( 6 )
      rak->AKT     := RecNo() // код акта
      rak->KOD_XML := rec_xml
      rak->CODEA   := tmp2->_CODEA
      rak->NAKT    := tmp2->_NAKT
      rak->DAKT    := tmp2->_DAKT
      rak->NSCHET  := ""
      rak->KOL_SCH := tmp2->KOL_SCH
      rak->KOL_PAC := tmp2->KOL_PAC
      rak->KOL_ERR := tmp2->KOL_ERR
      rak->KONT    := tmp2->_KONT
      rak->TYPEK   := tmp2->_TYPEK
      rak->SKONT   := tmp2->_SKONT
      Select TMP5
      find ( Str( tmp2->kod_a, 6 ) )
      Do While tmp2->kod_a == tmp5->kod_a .and. !Eof()
        Select RAKEXP
        addrec( 6 )
        rakexp->AKT      := rak->AKT
        rakexp->CODE_EXP := tmp5->CODE_EXP
        Select TMP5
        Skip
      Enddo
      Select TMP3
      find ( Str( tmp2->kod_a, 6 ) )
      Do While tmp2->kod_a == tmp3->kod_a .and. !Eof()
        ++is
        If tmp3->kod_schet == 0
          If ( i := AScan( arr_s, {| x| x[ 1 ] == tmp3->kod_a .and. x[ 2 ] == tmp3->kod_s } ) ) > 0
            StrFile( hb_eol() + " " + arr_s[ i, 3 ] + hb_eol() + hb_eol(), cFileProtokol, .t. )
          Endif
        Else
          schet_->( dbGoto( tmp3->kod_schet ) )
          schet_->( g_rlock( forever ) )
          schet_->SUMMAP    := tmp3->_SUMMAP
          schet_->SANK_MEK  := tmp3->_SANK_MEK + tmp3->PENALTY
          schet_->SANK_MEE  := tmp3->_SANK_MEE
          schet_->SANK_EKMP := tmp3->_SANK_EKMP
          If tmp2->KOL_SCH == 1
            rak->NSCHET := schet_->NSCHET
          Endif
          //
          StrFile( hb_eol(), cFileProtokol, .t. )
          s := "СЧЁТ № " + AllTrim( tmp3->_nschet ) + " от " + date_8( tmp3->_dschet ) + ;
            ", отч.период - " + StrZero( schet_->nyear, 4 ) + "/" + StrZero( schet_->nmonth, 2 ) + ;
            ", пациентов всего - " + lstr( tmp3->KOL_PAC )
          If tmp3->KOL_ERR > 0
            s += ", в т.ч. снятий - " + lstr( tmp3->KOL_ERR )
          Endif
          If tmp3->KOL_PEN > 0
            s += ", в т.ч. штрафов - " + lstr( tmp3->KOL_PEN )
          Endif
          put_long_str( s, cFileProtokol, 2 )
          s := "Выставлено: " + lstr( tmp3->_SUMMAV, 15, 2 ) + "р., " + ;
            "принято к оплате: " + lstr( tmp3->_SUMMAP, 15, 2 ) + "р."
          If !Empty( tmp3->_SANK_MEK )
            If fl_2019
              s += ", санкции: " + lstr( tmp3->_SANK_MEK, 15, 2 ) + "р."
            Else
              s += ", санкции МЭК: " + lstr( tmp3->_SANK_MEK, 15, 2 ) + "р."
            Endif
          Endif
          If !Empty( tmp3->_SANK_MEE )
            s += ", санкции МЭЭ: " + lstr( tmp3->_SANK_MEE, 15, 2 ) + "р."
          Endif
          If !Empty( tmp3->_SANK_EKMP )
            s += ", санкции ЭКМП: " + lstr( tmp3->_SANK_EKMP, 15, 2 ) + "р."
          Endif
          If !Empty( tmp3->PENALTY )
            s += ", сумма штрафов: " + lstr( tmp3->PENALTY, 15, 2 ) + "р."
          Endif
          put_long_str( s, cFileProtokol, 2 )
          If tmp3->KOL_ERR > 0
            StrFile( hb_eol() + Space( 4 ) + "Список снятий:" + hb_eol(), cFileProtokol, .t. )
          Endif
          Select RAKS
          addrec( 6 )
          raks->KOD_RAKS  := RecNo()
          raks->AKT       := rak->AKT
          raks->SCHET     := tmp3->kod_schet
          raks->KOL_PAC   := tmp3->KOL_PAC
          raks->KOL_ERR   := tmp3->KOL_ERR
          raks->PLAT      := tmp3->_PLAT
          raks->SUMMAV    := tmp3->_SUMMAV
          raks->SUMMAP    := tmp3->_SUMMAP
          raks->SANK_MEK  := tmp3->_SANK_MEK
          raks->SANK_MEE  := tmp3->_SANK_MEE
          raks->SANK_EKMP := tmp3->_SANK_EKMP
          raks->PENALTY   := tmp3->PENALTY
          Commit
          Select TMP4
          find ( Str( tmp3->kod_a, 6 ) + Str( tmp3->kod_s, 6 ) )
          Do While tmp3->kod_a == tmp4->kod_a .and. tmp3->kod_s == tmp4->kod_s .and. !Eof()
            ++ih
            @ MaxRow(), 1  Say "запись: " + lstr( ia ) Color "G+/R*"
            @ Row(), Col() Say "/"      Color "R/R*"
            @ Row(), Col() Say lstr( is ) Color "GR+/R*"
            @ Row(), Col() Say "/"      Color "R/R*"
            @ Row(), Col() Say lstr( ih ) Color "W+/R*"
            human->( dbGoto( tmp4->KOD_H ) )
            human_->( g_rlock( forever ) )
            If human_->OPLATA < 9
              human_->OPLATA := tmp4->_OPLATA
            Endif
            If tmp4->_OPLATA > 1 .or. !Empty( tmp4->PENALTY )
              v := human->cena_1
              If human->ishod == 88
                Select HUMAN_3
                find ( Str( human->kod, 7 ) )
                v := human_3->cena_1
              Endif
              s := "Сумма лечения: " + lstr( v, 15, 2 ) + "р., " + ;
                "принято к оплате: " + lstr( tmp4->_SUMP, 15, 2 ) + "р."
              If !Empty( tmp4->_SANK_MEK )
                If fl_2019
                  s += ", санкции: " + lstr( tmp4->_SANK_MEK, 15, 2 ) + "р."
                Else
                  s += ", санкции МЭК: " + lstr( tmp4->_SANK_MEK, 15, 2 ) + "р."
                Endif
              Endif
              If !Empty( tmp4->_SANK_MEE )
                s += ", санкции МЭЭ: " + lstr( tmp4->_SANK_MEE, 15, 2 ) + "р."
              Endif
              If !Empty( tmp4->_SANK_EKMP )
                s += ", санкции ЭКМП: " + lstr( tmp4->_SANK_EKMP, 15, 2 ) + "р."
              Endif
              If !Empty( tmp4->PENALTY )
                s += ", сумма штрафов: " + lstr( tmp4->PENALTY, 15, 2 ) + "р."
              Endif
              s1 := ""
              If tmp4->_OPLATA == 2
                s1 := " (полный отказ)"
              Elseif tmp4->_OPLATA == 3
                s1 := " (частичный отказ)"
              Elseif tmp4->_OPLATA == 4
                s1 := " (восстановление ранее удержанной суммы)"
              Endif
              StrFile( hb_eol(), cFileProtokol, .t. )
              put_long_str( "Случай № " + lstr( tmp4->_IDCASE ) + ". " + AllTrim( human->fio ) + iif( human->ishod == 88, " (двойной случай), ", ", " ) + ;
                full_date( human->date_r ) + ;
                iif( Empty( otd->SHORT_NAME ), "", " [" + AllTrim( otd->SHORT_NAME ) + "]" ) + ;
                " " + date_8( human->n_data ) + "-" + date_8( human->k_data ), cFileProtokol, 4 )
              put_long_str( s, cFileProtokol, 5 )
              put_long_str( "OPLATA = " + lstr( tmp4->_OPLATA ) + s1, cFileProtokol, 5 )
              If emptyall( tmp4->_SANK_MEK, tmp4->_SANK_MEE, tmp4->_SANK_EKMP, tmp4->PENALTY )
                If AScan( arrF006, {| x| x[ 2 ] == tmp2->_KONT } ) > 0
                  s := 'Вид контроля: ' + inieditspr( A__MENUVERT, arrF006, tmp2->_KONT )
                  put_long_str( s, cFileProtokol, 5 )
                Endif
                s := ""
                If tmp2->_TYPEK > 0
                  s := "Проведенный Контроль: " + iif( tmp2->_TYPEK == 1, "первичный", "повторный" )
                  If Between( tmp2->_SKONT, 1, 2 )
                    s += ", вид экспертизы: " + iif( tmp2->_skont == 1, "плановая", "целевая" )
                  Endif
                Endif
                If fl_2019
                  s := "Контроль подтвердил предыдущее снятие"
                Else
                  s += " (подтвердил предыдущее снятие)"
                Endif
                put_long_str( s, cFileProtokol, 5 )
              Elseif tmp4->_REFREASON > 0
                If Empty( s := ret_f014( tmp4->_REFREASON ) )
                //If Empty( s := ret_t005( tmp4->_REFREASON ) )
                  StrFile( Space( 5 ) + lstr( tmp4->_REFREASON ) + " неизвестная причина отказа" + ;
                    hb_eol(), cFileProtokol, .t. )
                Else
                  put_long_str( "код дефекта: " + s, cFileProtokol, 5 )
                Endif
              Endif
            Endif
            human_->SUMP := tmp4->_SUMP
            If Len( lstr( tmp4->_SANK_MEK + tmp4->PENALTY, 15, 2 ) ) > 10
              human_->SANK_MEK := tmp4->_SANK_MEK
            Else
              human_->SANK_MEK := tmp4->_SANK_MEK + tmp4->PENALTY
            Endif
            human_->SANK_MEE  := tmp4->_SANK_MEE
            human_->SANK_EKMP := tmp4->_SANK_EKMP
            //
            Select RAKSH
            addrec( 6 )
            raksh->KOD_RAKS  := raks->KOD_RAKS
            raksh->KOD_H     := tmp4->KOD_H
            raksh->OPLATA    := tmp4->_OPLATA
            raksh->REFREASON := tmp4->_REFREASON
            raksh->SUMP      := tmp4->_SUMP
            raksh->SANK_MEK  := tmp4->_SANK_MEK
            raksh->SANK_MEE  := tmp4->_SANK_MEE
            raksh->SANK_EKMP := tmp4->_SANK_EKMP
            raksh->PENALTY   := tmp4->PENALTY
            raksh->IS_REPEAT := 0
            raksh->DATE_REP  := CToD( "" )
            raksh->NEXT_KOD  := 0
            /*if raksh->REFREASON > 0
              select MO_OS
              find (str(raksh->kod_h, 7))
              if found()
                raksh->IS_REPEAT := 1
                raksh->DATE_REP  := iif(empty(mo_os->DATE_OPL), sys_date, mo_os->DATE_OPL)
                raksh->NEXT_KOD  := mo_os->NEXT_KOD
                strfile(space(5) + "СЛУЧАЙ УЖЕ БЫЛ ПОВТОРНО ВЫСТАВЛЕН"  + hb_eol(), cFileProtokol, .t.)
              endif
            endif*/
            Select TMP6
            find ( Str( tmp4->kod_a, 6 ) + Str( tmp4->kod_s, 6 ) + Str( tmp4->_idcase, 8 ) )
            Do While tmp4->kod_a == tmp6->kod_a .and. tmp4->kod_s == tmp6->kod_s .and. tmp4->_idcase == tmp6->_idcase .and. !Eof()
              Select RAKSHERR
              addrec( 8 )
              raksherr->KOD_RAKSH := raksh->( RecNo() )
              raksherr->S_CODE    := tmp6->S_CODE
              raksherr->S_SUM     := tmp6->S_SUM
              raksherr->REFREASON := tmp6->REFREASON
              raksherr->PENALTY   := tmp6->PENALTY
              raksherr->SL_ID     := tmp6->SL_ID
              raksherr->SL_ID2    := tmp6->SL_ID2
              raksherr->S_COM     := alltrim(substr(alltrim(tmp6->S_COM),12,5))
            //If Empty( s := ret_t005( tmp6->REFREASON ) )
              If Empty( s := ret_f014( tmp6->REFREASON ) )
                StrFile( Space( 5 ) + lstr( tmp6->REFREASON ) + " неизвестная причина отказа" + ;
                  hb_eol(), cFileProtokol, .t. )
              Else
                put_long_str( "код дефекта: " + s, cFileProtokol, 5 )
              Endif
              if len(alltrim(tmp6->S_COM)) > 0
                if !Empty( s := ret_t005(val(alltrim(substr(alltrim(tmp6->S_COM),12,5)))))
                // -- ??????????  
                  put_long_str( "Уточнение кода дефекта: " + s, cFileProtokol, 5 )
                endif
              endif  
              If !emptyall( tmp6->S_SUM, tmp6->PENALTY )
                raksh->REFREASON := tmp6->REFREASON
                StrFile( Space( 5 ) + "... снятие по данному дефекту ..."  + hb_eol(), cFileProtokol, .t. )
              Endif
              Select TMP6
              Skip
            Enddo
            Select TMP4
            Skip
          Enddo
          Commit
        Endif
        Select TMP3
        Skip
      Enddo
    Endif
    Select TMP2
    Skip
  Enddo
  // запишем время окончания обработки
  Select MO_XML
  Goto ( rec_xml )
  g_rlock( forever )
  mo_xml->TWORK2 := hour_min( Seconds() )
  Close databases
  Return Nil

// 22.04.19
Function put_long_str( s, cFile, n, sh )

  Local i, k, t_arr[ 2 ]

  Default cFile To 'ttt.ttt', n To 0, sh To 80
  k := perenos( t_arr, s, sh - n )
  StrFile( Space( n ) + t_arr[ 1 ] + hb_eol(), cFile, .t. )
  For i := 2 To k
    StrFile( Space( n ) + PadL( AllTrim( t_arr[ i ] ), sh - n ) + hb_eol(), cFile, .t. )
  Next

  Return Nil

// 16.01.16
Function akt_kontrol( k )

  Static si1 := 1
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 1
  Do Case
  Case k == 1
      /*mas_pmt := {"Реестры ~актов контроля", ;
                  "Акты контроля (~2012 год)"}
      mas_msg := {"Просмотр реестров актов контроля (РАК)", ;
                  "Поиск счёта для ввода или просмотра актов контроля за 2012 год"}
      mas_fun := {"akt_kontrol(11)", ;
                  "akt_kontrol(12)"}
      popup_prompt(T_ROW, T_COL+5,si1,mas_pmt,mas_msg,mas_fun)*/
    akt_kontrol( 11 )
  Case k == 11
    view_rak()
  Case k == 12
    akt_kontrol_2012()
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Endif
  Endif

  Return Nil

// 11.02.13
Function view_rak()

  Local str_sem := "Просмотр РАК"

  If !g_slock( str_sem )
    Return func_error( 4, "В данный момент с реестрами актов контроля работает другой пользователь." )
  Endif
  g_use( dir_server + "mo_xml", , "MO_XML" )
  Index On DToS( DFILE ) to ( cur_dir + "tmp_xml" ) For tip_in == _XML_FILE_RAK DESCENDING
  Go Top
  If Eof()
    func_error( 4, "Нет реестров актов контроля" )
  Else
    alpha_browse( T_ROW, 2, MaxRow() -2, MaxCol() -2, "f1_view_rak", color0, , , , , , , ;
      "f2_view_rak", , { '═', '░', '═', "N/BG, W+/N, B/BG, BG+/B, R/BG, W+/R", .t., 180 } )
  Endif
  Close databases
  g_sunlock( str_sem )

  Return Nil

// 11.02.13
Function f1_view_rak( oBrow )

  Local oColumn, blk := {|| iif( Empty( mo_xml->TWORK2 ), { 5, 6 }, { 1, 2 } ) }

  oColumn := TBColumnNew( "Наименование файла;реестра актов контроля", {|| PadR( mo_xml->FNAME, 23 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Дата файла; реестра", {|| full_date( mo_xml->dfile ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " Кол.;актов", {|| Str( mo_xml->kol1, 5 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " Кол.;счетов", {|| Str( mo_xml->kol2, 6 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "  Дата; чтения", {|| date_8( mo_xml->dread ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Время;чтения", {|| mo_xml->tread } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Примечание", {|| PadR( iif( Empty( mo_xml->TWORK2 ), "не дочитан", "" ), 10 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  status_key( "^<Esc>^ выход; ^<Enter>^ просмотр актов; ^<F3>^ протокол чтения файла реестра" )

  Return Nil

// 31.03.13
Function f2_view_rak( nKey, oBrow )

  Local ret := -1, rec := mo_xml->( RecNo() ), buf := SaveScreen()

  Do Case
  Case nKey == K_F3
    viewtext( devide_into_pages( dir_server + dir_XML_TF + cslash + AllTrim( mo_xml->FNAME ) + stxt, 60, 80 ), , , , .t., , , 2 )
    ret := 0
  Case nKey == K_ENTER
    view_rak_akt( rec )
    Close databases
    //
    g_use( dir_server + "mo_xml", cur_dir + "tmp_xml", "MO_XML" )
    Goto ( rec )
    ret := 0
  Case nKey == K_CTRL_F12
    ret := delete_rak( rec, AllTrim( Upper( mo_xml->FNAME ) ), Empty( mo_xml->TWORK2 ) )
    Close databases
    g_use( dir_server + "mo_xml", cur_dir + "tmp_xml", "MO_XML" )
    Goto ( rec )
  Endcase
  RestScreen( buf )

  Return ret

// 11.01.19
Function delete_rak( lrec, lname, not_end )

  Local ret := 0, arr_next := {}, fl, ia, is, ih, buf := save_maxrow()

  mywait()
  r_use( dir_server + "human", , "HUMAN" )
  r_use( dir_server + "mo_raksh", , "RAKSH" )
  r_use( dir_server + "mo_raks", , "RAKS" )
  r_use( dir_server + "mo_rak", , "RAK" )
  Index On nakt to ( cur_dir + "tmp_rak" ) For kod_xml == mo_xml->( RecNo() ) .and. KOL_ERR > 0
  Go Top
  Do While !Eof()
    Select RAKS
    Index On Str( kod_raks, 6 ) to ( cur_dir + "tmp_raks" ) For akt == rak->akt .and. KOL_ERR > 0
    Go Top
    Do While !Eof()
      Select RAKSH
      Index On Str( kod_h, 7 ) to ( cur_dir + "tmp_raksh" ) For KOD_RAKS == raks->KOD_RAKS .and. oplata > 1
      Go Top
      Do While !Eof()
        If raksh->next_kod > 0
          human->( dbGoto( raksh->kod_h ) )
          If Year( human->k_data ) > 2012 // начиная с 2013 года
            AAdd( arr_next, { raksh->kod_h, ;
              raksh->REFREASON, ;
              raksh->SANK_MEK, ;
              raksh->SANK_MEE, ;
              raksh->SANK_EKMP, ;
              raksh->next_kod, ;
              raksh->DATE_REP;
              } )
          Endif
        Endif
        Skip
      Enddo
      Select RAKS
      Skip
    Enddo
    Select RAK
    Skip
  Enddo
  raksh->( dbCloseArea() )
  raks->( dbCloseArea() )
  rak->( dbCloseArea() )
  rest_box( buf )
  If ( ih := Len( arr_next ) ) > 0
    buf := SaveScreen()
    f_message( { "", ;
      "По некоторым пациентам данного РАК", ;
      "уже были повторно выставлены случаи - " + lstr( ih ) + " чел.", ;
      "" }, , "GR+/R", "W+/R" )
    fl := f_esc_enter( "удаления РАК", .t. )
    RestScreen( buf )
    If !fl
      Return ret
    Endif
  Endif
  If not_end
    fl := .t.
  Else
    fl := involved_password( 2, lname, "подтверждения возврата (удаления) РАК" )
  Endif
  If fl .and. f_esc_enter( "удаления РАК", .t. )
    stat_msg( "Подтвердите удаление ещё раз." )
    mybell( 2 )
    If f_esc_enter( "удаления РАК", .t. )
      mywait( "Ждите. Производится удаление РАК." )
      If ih > 0
        g_use( dir_server + "mo_os", , "MO_OS" )
        Index On Str( kod, 7 ) to ( cur_dir + "tmp_moos" )
        For i := 1 To ih
          find ( Str( arr_next[ i, 1 ], 7 ) )
          If Found()
            g_rlock( forever )
          Else
            addrec( 7 )
            mo_os->KOD := arr_next[ i, 1 ]
          Endif
          mo_os->REFREASON := arr_next[ i, 2 ]
          mo_os->SANK_MEK  := arr_next[ i, 3 ]
          mo_os->SANK_MEE  := arr_next[ i, 4 ]
          mo_os->SANK_EKMP := arr_next[ i, 5 ]
          mo_os->NEXT_KOD  := arr_next[ i, 6 ]
          mo_os->DATE_OPL  := arr_next[ i, 7 ]
          mo_os->OPLATA    := 2
          mo_os->IS_REPEAT := 1
          Unlock
        Next
      Endif
      g_use( dir_server + "mo_raksherr", , "RAKSHERR" )
      Index On Str( kod_raksh, 8 ) to ( cur_dir + "tmpraksherr" )
      g_use( dir_server + "mo_raksh", , "RAKSH" )
      Index On Str( kod_raks, 6 ) to ( cur_dir + "tmpraksh" )
      g_use( dir_server + "mo_raks", , "RAKS" )
      Index On Str( akt, 6 ) to ( cur_dir + "tmpraks" )
      g_use( dir_server + "mo_rakexp", , "RAKEXP" )
      Index On Str( akt, 6 ) to ( cur_dir + "tmprakexp" )
      g_use( dir_server + "mo_rak", , "RAK" )
      Index On Str( kod_xml, 6 ) to ( cur_dir + "tmprak" )
      ia := is := ih := 0
      Do While .t.
        Select RAKEXP
        find ( Str( lrec, 6 ) )
        If !Found()
          Exit
        Endif
        deleterec( .t. )
      Enddo
      Do While .t.
        ++ia
        Select RAK
        find ( Str( lrec, 6 ) )
        If !Found()
          Exit
        Endif
        Do While .t.
          ++is
          Select RAKS
          find ( Str( rak->akt, 6 ) )
          If !Found()
            Exit
          Endif
          Do While .t.
            ++ih
            Select RAKSH
            find ( Str( raks->KOD_RAKS, 6 ) )
            If !Found()
              Exit
            Endif
            @ MaxRow(), 1  Say lstr( ia ) Color "G+/R*"
            @ Row(), Col() Say "/"      Color "R/R*"
            @ Row(), Col() Say lstr( is ) Color "GR+/R*"
            @ Row(), Col() Say "/"      Color "R/R*"
            @ Row(), Col() Say lstr( ih ) Color "W+/R*"
            Select RAKSHERR
            Do While .t.
              find ( Str( raksh->( RecNo() ), 8 ) )
              If !Found()
                Exit
              Endif
              deleterec( .t. )
            Enddo
            Select RAKSH
            deleterec( .t. )
          Enddo
          Select RAKS
          deleterec( .t. )
        Enddo
        Select RAK
        deleterec( .t. )
      Enddo
      Select MO_XML
      deleterec( .t. )
      stat_msg( "Реестр актов контроля " + lname + " удалён!" )
      mybell( 2, OK )
      ret := 1
    Endif
  Endif

  Return ret

// 26.10.22
Function view_rak_akt( lrec )

  Local blk, blk_akt, blk_typek, blk_skont, t_arr[ BR_LEN ]

  r_use( dir_server + 'mo_rak', , 'RAK' )
  Index On nakt to ( cur_dir + 'tmp_rak' ) For kod_xml == lrec
  Go Top
  If Eof()
    Return func_error( 4, 'Не обнаружено актов в данном РАКе' )
  Endif
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := 2
  t_arr[ BR_RIGHT ] := MaxCol() -2
  t_arr[ BR_TITUL ] := 'РАК ' + AllTrim( mo_xml->FNAME ) + sxml + ' от ' + date_8( mo_xml->dfile )
  t_arr[ BR_TITUL_COLOR ] := 'B/G*'
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG,W+/N,B/BG,W+/B', .t. }
  blk := {|| iif( Empty( rak->kol_err ), { 1, 2 }, { 3, 4 } ) }
  blk_akt := {| _n, _s, _l| _s := iif( Empty( rak->nschet ), '', '(' + AllTrim( rak->nschet ) + ')' ), ;
    _l := Len( _s ), PadR( rak->nakt, _n - _l ) + _s }
  t_arr[ BR_COLUMN ] := { { 'Номер акта контроля     (счёт)', {|| Eval( blk_akt, 30 ) }, blk }, ;
    { '  Дата;  акта', {|| date_8( rak->dakt ) }, blk }, ;
    { 'Кол-во;счетов', {|| Str( rak->kol_sch, 6 ) }, blk }, ;
    { 'Кол-во;снятий', {|| put_val( rak->kol_err, 6 ) }, blk }, ;
    { ' Контроль', {|| PadR( f0_view_rak_akt( 1 ), 10 ) }, blk }, ;
    { ' Вид экс-; пертизы', {|| PadR( f0_view_rak_akt( 2 ), 9 ) }, blk } }
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход;  ^<Enter>^ - выбор акта для просмотра счетов' ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f1_view_rak_akt( nk, ob, 'edit' ) }
  edit_browse( t_arr )

  Return Nil

// 19.12.22
Function f0_view_rak_akt( k )

  Local s, s1, s2
  Local arrF006 := getf006()

  If emptyall( rak->typek, rak->skont )
    s := PadR( inieditspr( A__MENUVERT, arrF006, rak->KONT ), 19 )
    s1 := Left( s, 10 )
    s2 := Right( s, 9 )
  Else
    s1 := iif( rak->typek == 1, 'первичный', iif( rak->typek == 2, 'повторный', '' ) )
    s2 := iif( rak->skont == 1, 'плановая', iif( rak->skont == 2, 'целевая', 'МЭК' ) )
  Endif

  Return iif( k == 1, s1, s2 )

// 26.10.22
Function f1_view_rak_akt( nk, ob, regim )

  Local ret := -1, rec

  If regim == 'edit' .and. nk == K_ENTER
    rec := rak->( RecNo() )
    view_rak_akt_schet( rak->akt )
    Close databases
    //
    r_use( dir_server + 'mo_rak', cur_dir + 'tmp_rak', 'RAK' )
    Goto ( rec )
    ret := 0
  Endif

  Return ret

// 19.12.22
Function view_rak_akt_schet( lakt, lkont )

  Local blk, blk_eks, t_arr[ BR_LEN ]
  Local arrF006 := getf006()

  r_use( dir_server + "schet_", , "SCHET_" )
  r_use( dir_server + "mo_raks", , "RAKS" )
  Set Relation To schet into SCHET_
  Index On DToS( schet_->dschet ) + schet_->nschet to ( cur_dir + "tmp_raks" ) For akt == lakt
  Go Top
  If Eof()
    Return func_error( 4, "Не обнаружено счетов в данном акте" )
  Endif
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := 2
  t_arr[ BR_RIGHT ] := MaxCol() -2
  // t_arr[BR_TITUL] := "Акт № " + alltrim(rak->nakt) + " от " + date_8(rak->dakt) + ;
  // iif(ascan(glob_F006, {|x| x[2] == rak->kont }) > 0, " [" +inieditspr(A__MENUVERT,glob_F006,rak->KONT) + "]", "")
  t_arr[ BR_TITUL ] := 'Акт № ' + AllTrim( rak->nakt ) + ' от ' + date_8( rak->dakt ) + ;
    iif( AScan( arrF006, {| x| x[ 2 ] == rak->kont } ) > 0, ' [' + inieditspr( A__MENUVERT, arrF006, rak->KONT ) + ']', '' )
  t_arr[ BR_TITUL_COLOR ] := 'B/GR*'
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', "N/BG, W+/N, B/BG, W+/B", .t. }
  blk := {|| iif( Empty( raks->kol_err ), { 1, 2 }, { 3, 4 } ) }
  t_arr[ BR_COLUMN ] := { { " Номер счёта", {|| schet_->nschet }, blk }, ;
    { "Период", {|| Str( schet_->nyear, 4 ) + "/" + StrZero( schet_->nmonth, 2 ) }, blk }, ;
    { "  Дата; счёта", {|| date_8( schet_->dschet ) }, blk }, ;
    { "Паци-;ентов", {|| Str( raks->kol_pac, 6 ) }, blk }, ;
    { "Сня-;тий", {|| put_val( raks->kol_err, 4 ) }, blk }, ;
    { " Сумма счёта", {|| put_kop( raks->SUMMAV, 14 ) }, blk }, ;
    { " СМО приняла;  к оплате", {|| put_kop( raks->SUMMAP, 14 ) }, blk } }
  t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ - выход;  ^<Enter>^ - выбор счёта для просмотра пациентов" ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f1_view_rak_akt_schet( nk, ob, "edit" ) }
  edit_browse( t_arr )

  Return Nil

// 11.02.13
Function f1_view_rak_akt_schet( nk, ob, regim )

  Local ret := -1, rec

  If regim == "edit" .and. nk == K_ENTER
    rec := raks->( RecNo() )
    view_rak_akt_schet_human( raks->KOD_RAKS )
    Close databases
    //
    r_use( dir_server + "schet_", , "SCHET_" )
    r_use( dir_server + "mo_raks", cur_dir + "tmp_raks", "RAKS" )
    Set Relation To schet into SCHET_
    Goto ( rec )
    ret := 0
  Endif

  Return ret

// 14.05.20
Function view_rak_akt_schet_human( lkod_raks )

  Local blk, t_arr[ BR_LEN ], buf := SaveScreen()

  r_use( dir_server + "schet", , "SCHET" )
  Goto ( raks->schet )
  r_use( dir_server + "human_3", { dir_server + "human_3", dir_server + "human_32" }, "HUMAN_3" )
  r_use( dir_server + "human_", , "HUMAN_" )
  r_use( dir_server + "human", , "HUMAN" )
  Set Relation To RecNo() into HUMAN_
  g_use( dir_server + "mo_raksh", , "RAKSH" )
  Set Relation To KOD_H into HUMAN
  Index On Str( human_->SCHET_ZAP, 6 ) to ( cur_dir + "tmp_raksh" ) For KOD_RAKS == lkod_raks
  Go Top
  If Eof()
    Return func_error( 4, "Не обнаружено пациентов в данном счете" )
  Endif
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -1
  t_arr[ BR_LEFT ] := 0
  t_arr[ BR_RIGHT ] := MaxCol()
  t_arr[ BR_TITUL ] := "Счёт № " + AllTrim( schet_->nschet ) + " от " + ;
    date_8( schet_->dschet ) + " " + f4_view_list_schet()
  t_arr[ BR_TITUL_COLOR ] := "B/W*"
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', "N/BG, W+/N, B/BG, W+/B", .t. }
  blk := {|| iif( raksh->oplata == 1, { 1, 2 }, { 3, 4 } ) }
  t_arr[ BR_COLUMN ] := { { " №№;случ", {|| Str( human_->SCHET_ZAP, 4 ) }, blk }, ;
    { " Ф.И.О.", {|| PadR( f_view_rak_akt_schet_human( 1 ), 27 ) }, blk }, ;
    { "Дата рожд.", {|| full_date( human->date_r ) }, blk }, ;
    { " Стоимость", {|| put_kop( f_view_rak_akt_schet_human( 2 ), 10 ) }, blk }, ;
    { " Принято; к оплате", {|| put_kop( raksh->sump, 10 ) }, blk }, ;
    { "Код;деф", {|| put_val( raksh->REFREASON, 3 ) }, blk }, ;
    { "Повторн.;выставл.", {|| iif( Empty( raksh->NEXT_KOD ), Space( 8 ), date_8( raksh->DATE_REP ) ) }, blk } }
  t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ выход; ^<F2>^ поиск; ^<Enter>^ повторное выставление пациента (или отмена)" ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f1_view_rak_akt_schet_human( nk, ob, "edit" ) }
  t_arr[ BR_STEP_FUNC ] := {|| f2_view_rak_akt_schet_human() }
  Private rhuman := 1, chuman := MaxCol() -39
  box_shadow( rhuman, chuman, rhuman + 3, MaxCol() -2, "N+/GR*", , , 0 )
  edit_browse( t_arr )
  RestScreen( buf )

  Return Nil

// 14.05.20
Function f_view_rak_akt_schet_human( k )

  Local s := human->fio, v := human->cena_1, ret

  If human->ishod == 88
    human_3->( dbSeek( Str( human->kod, 7 ) ) )
    If human_3->( Found() )
      v := human_3->cena_1
      s := PadR( s, 23 ) + "_2сл"
    Endif
  Endif

  Return iif( k == 1, s, v )

// 19.12.22
Function f1_view_rak_akt_schet_human( nk, ob, regim )

  Local ret := -1, rec, s, s1
  Local arrF006 := getf006()

  If !( regim == 'edit' )
    Return ret
  Elseif nk == K_F2
    If ( s := input_value( 18, 10, 20, 69, color1, ;
        Space( 5 ) + "Введите номер случая в счёте (для поиска)", 0, "9999" ) ) != NIL ;
        .and. s > 0
      rec := raksh->( RecNo() )
      ob:gotop()
      Go Top
      find ( Str( s, 6 ) )
      If Found()
        ret := 0
      Else
        func_error( 4, "Не найден случай с номером " + lstr( s ) )
        Goto ( rec )
      Endif
    Endif
  Elseif nk == K_ENTER .and. Year( human->k_data ) > 2012
    s := 0
    If !Empty( raksh->SANK_MEK )
      s := raksh->SANK_MEK
    Elseif !Empty( raksh->SANK_MEE )
      s := raksh->SANK_MEE
    Elseif !Empty( raksh->SANK_EKMP )
      s := raksh->SANK_EKMP
    Endif
    If human->cena_1 > 0 .and. Empty( s )
      func_error( 4, "Повторное выставление случая невозможно при нулевой сумме отказа" )
      Return ret
    Elseif !( Round( f_view_rak_akt_schet_human( 2 ), 2 ) == Round( s + raksh->sump, 2 ) .and. raksh->OPLATA == 2 )
      func_error( 4, "Повторное выставление случая возможно только для OPLATA = 2 и полного отказа" )
      Return ret
    Endif
    If ! hb_user_curUser:isadmin()
      func_error( 4, err_admin )
      Return ret
    Endif
    rec := raksh->( RecNo() )
    s := AllTrim( human->fio ) + " " + date_8( human->n_data ) + "-" + date_8( human->k_data ) + " (" + lstr( f_view_rak_akt_schet_human( 2 ) ) + "р.)"
    s1 := "код дефекта: " + lstr( raksh->REFREASON )
    If emptyall( human->cena_1, raksh->SANK_MEK, raksh->SANK_MEE, raksh->SANK_EKMP, raksh->PENALTY ) // скорая помощь
      s1 += ', санкции ' + inieditspr( A__MENUVERT, arrF006, rak->KONT ) + ': 0р. (СМП)'
    Endif
    If !Empty( raksh->SANK_MEK )
      s1 += ", санкции МЭК: " + lstr( raksh->SANK_MEK, 15, 2 ) + "р."
    Elseif !Empty( raksh->SANK_MEE )
      s1 += ", санкции МЭЭ: " + lstr( raksh->SANK_MEE, 15, 2 ) + "р."
    Elseif !Empty( raksh->SANK_EKMP )
      s1 += ", санкции ЭКМП: " + lstr( raksh->SANK_EKMP, 15, 2 ) + "р."
    Endif
    If !Empty( raksh->PENALTY )
      s1 += ", сумма штрафов: " + lstr( raksh->PENALTY, 15, 2 ) + "р."
    Endif
    If Empty( raksh->NEXT_KOD )
      If human_->OPLATA == 9
        func_error( "Ошибка! Данный случай уже был перевыставлен!" )
      Else
        rak_akt_schet_human_add_next( s, s1, rec )
      Endif
    Else
      rak_akt_schet_human_del_next( s, s1, rec )
    Endif
    //
    Close databases
    r_use( dir_server + "human_3", { dir_server + "human_3", dir_server + "human_32" }, "HUMAN_3" )
    r_use( dir_server + "human_", , "HUMAN_" )
    r_use( dir_server + "human", , "HUMAN" )
    Set Relation To RecNo() into HUMAN_
    r_use( dir_server + "mo_raksh", cur_dir + "tmp_raksh", "RAKSH" )
    Set Relation To KOD_H into HUMAN
    Goto ( rec )
    ret := 0
  Endif

  Return ret

// 19.12.22
Function f2_view_rak_akt_schet_human()

  Local arr := {}, i, n, s, lcolor := "N", tmp_select := Select()
  Local arrF006 := getf006()

  n := 76 -chuman
  If Select( "RAKS" ) == 0
    r_use( dir_server + "mo_raks", , "RAKS" )
  Endif
  If Select( "RAK" ) == 0
    r_use( dir_server + "mo_rak", , "RAK" )
  Endif
  raks->( dbGoto( raksh->kod_raks ) )
  rak->( dbGoto( raks->akt ) )
  i := 0
  If AScan( arrF006, {| x| x[ 2 ] == rak->kont } ) > 0
    AAdd( arr, 'Вид контроля: ' + inieditspr( A__MENUVERT, arrF006, rak->KONT ) )
  Endif
  If !emptyall( rak->TYPEK, rak->skont )
    AAdd( arr, "Контроль: " + iif( rak->TYPEK == 1, "первичный", "повторный" ) + ;
      ", вид: " + iif( rak->skont == 1, "плановая", iif( rak->skont == 2, "целевая", "МЭК" ) ) )
  Endif
  AAdd( arr, "" )
  i := Len( arr )
  If raksh->OPLATA == 1
    arr[ i ] := "полностью оплачен"
  Elseif raksh->OPLATA == 2
    arr[ i ] := "полный отказ"
  Elseif raksh->OPLATA == 3
    arr[ i ] := "частичный отказ"
  Elseif raksh->OPLATA == 4
    arr[ i ] := "восст-ние ранее удержанной суммы"
  Endif
  s := 0
  If !Empty( raksh->SANK_MEK )
    s := raksh->SANK_MEK
  Elseif !Empty( raksh->SANK_MEE )
    s := raksh->SANK_MEE
  Elseif !Empty( raksh->SANK_EKMP )
    s := raksh->SANK_EKMP
  Endif
  If raksh->OPLATA == 2
    If Empty( s ) .and. human->cena_1 > 0
      If rak->kont == 1 .or. rak->skont == 0
        lcolor := "R"
        AAdd( arr, "ошибка СМО - нет суммы санкций!" )
      Endif
      If rak->kont > 1 .or. rak->skont > 0
        lcolor := "RB"
        AAdd( arr, "снято предыдущей санкцией" )
      Endif
    Elseif Round( f_view_rak_akt_schet_human( 2 ), 2 ) == Round( s + raksh->sump, 2 )
      AAdd( arr, "снято " + lstr( s, 11, 2 ) + "р." )
      lcolor := "B"
    Endif
  Elseif raksh->OPLATA == 3
    If Round( f_view_rak_akt_schet_human( 2 ), 2 ) == Round( s + raksh->sump, 2 )
      AAdd( arr, "снято " + lstr( s, 11, 2 ) + "р." )
      lcolor := "B"
    Endif
  Endif
  If !Empty( raksh->PENALTY )
    AAdd( arr, "штраф " + lstr( raksh->PENALTY, 15, 2 ) + "р." )
    lcolor := "B"
  Endif
  Do While Len( arr ) < 4
    AAdd( arr, "" )
  Enddo
  For i := 1 To 4
    @ rhuman -1 + i, chuman + 1 Say PadC( arr[ i ], n ) Color lcolor + "/GR*"
  Next
  Select ( tmp_select )

  Return Nil

// 15.02.19
Function rak_akt_schet_human_add_next( s, s1, lrec )

  Local i, arr1, arr2, mkod, buf := save_maxrow()

  glob_perso := raksh->kod_h
  arr1 := { s, ;
    s1, ;
    "После подтверждения данный лист учёта будет выставлен", ;
    "повторно (для последующего исправления и отправки в ТФОМС).", ;
    'Редактировать новый л/у в режиме "Выбор по акту снятия из СМО"', ;
    "" }
  arr2 := { " Отказ ", " Повторное выставление " }
  If f_alert( arr1, arr2, 1, "N+/G*", "N/G*", 13, , "N/G*" ) == 2
    If f_alert( arr1, arr2, 1, "N+/G*", "R/G*", 14, , "N/G*" ) == 2
      mywait()
      Close databases
      // сначала запоминаем копию листа учёта в массивах
      use_base( "human" )
      Set Relation To // "отвязываем"
      Goto ( glob_perso )
      ahuman := get_field()
      Select HUMAN_
      Goto ( glob_perso )
      ahuman_ := get_field()
      Select HUMAN_2
      Goto ( glob_perso )
      ahuman_2 := get_field()
      If ( fl_iname := ( human_->smo == '34   ' ) )
        g_use( dir_server + "mo_hismo", , "SN" )
        Index On Str( kod, 7 ) to ( cur_dir + "tmp_ismo" )
        find ( Str( glob_perso, 7 ) )
        mnameismo := sn->smo_name
      Endif
      arr_hu := {}
      use_base( "human_u" )
      Set Relation To // "отвязываем"
      find ( Str( glob_perso, 7 ) )
      Do While hu->kod == glob_perso .and. !Eof()
        ahu := get_field()
        Select HU_
        Goto ( hu->( RecNo() ) )
        ahu_ := get_field()
        AAdd( arr_hu, { ahu, ahu_ } )
        Select HU
        Skip
      Enddo
      arr_mohu := {}
      use_base( "mo_hu" )
      find ( Str( glob_perso, 7 ) )
      Do While mohu->kod == glob_perso .and. !Eof()
        AAdd( arr_mohu, get_field() )
        Skip
      Enddo
      aonkna := {}
      g_use( dir_server + "mo_onkna", dir_server + "mo_onkna" )
      find ( Str( glob_perso, 7 ) )
      Do While mo_onkna->kod == glob_perso .and. !Eof()
        AAdd( aonkna, get_field() )
        Skip
      Enddo
      aonksl := {}
      g_use( dir_server + "mo_onksl", dir_server + "mo_onksl" )
      find ( Str( glob_perso, 7 ) )
      Do While mo_onksl->kod == glob_perso .and. !Eof()
        AAdd( aonksl, get_field() )
        Skip
      Enddo
      aonkco := {}
      g_use( dir_server + "mo_onkco", dir_server + "mo_onkco" )
      find ( Str( glob_perso, 7 ) )
      Do While mo_onkco->kod == glob_perso .and. !Eof()
        AAdd( aonkco, get_field() )
        Skip
      Enddo
      aonkdi := {}
      g_use( dir_server + "mo_onkdi", dir_server + "mo_onkdi" )
      find ( Str( glob_perso, 7 ) )
      Do While mo_onkdi->kod == glob_perso .and. !Eof()
        AAdd( aonkdi, get_field() )
        Skip
      Enddo
      aonkpr := {}
      g_use( dir_server + "mo_onkpr", dir_server + "mo_onkpr" )
      find ( Str( glob_perso, 7 ) )
      Do While mo_onkpr->kod == glob_perso .and. !Eof()
        AAdd( aonkpr, get_field() )
        Skip
      Enddo
      aonkus := {}
      g_use( dir_server + "mo_onkus", dir_server + "mo_onkus" )
      find ( Str( glob_perso, 7 ) )
      Do While mo_onkus->kod == glob_perso .and. !Eof()
        AAdd( aonkus, get_field() )
        Skip
      Enddo
      aonkle := {}
      g_use( dir_server + "mo_onkle", dir_server + "mo_onkle" )
      find ( Str( glob_perso, 7 ) )
      Do While mo_onkle->kod == glob_perso .and. !Eof()
        AAdd( aonkle, get_field() )
        Skip
      Enddo
      arr_disp := read_arr_dispans( glob_perso )
      glob_persoh3 := 0
      If human->ishod == 88 // двойной случай
        g_use( dir_server + "human_3", { dir_server + "human_3", dir_server + "human_32" }, "HUMAN_3" )
        find ( Str( human->kod, 7 ) )
        If Found()
          rec_h3 := RecNo()
          ahuman_3 := get_field()
          glob_persoh3 := human_3->kod2
          //
          Select HUMAN
          Goto ( glob_persoh3 )
          ahumanh3 := get_field()
          Select HUMAN_
          Goto ( glob_persoh3 )
          ahuman_h3 := get_field()
          Select HUMAN_2
          Goto ( glob_persoh3 )
          ahuman_2h3 := get_field()
          If ( fl_inameh3 := ( human_->smo == '34   ' ) )
            g_use( dir_server + "mo_hismo", , "SNh3" )
            Index On Str( kod, 7 ) to ( cur_dir + "tmp_ismoh3" )
            find ( Str( glob_persoh3, 7 ) )
            mnameismoh3 := sn->smo_name
          Endif
          arr_huh3 := {}
          Select HU
          find ( Str( glob_persoh3, 7 ) )
          Do While hu->kod == glob_persoh3 .and. !Eof()
            ahu := get_field()
            Select HU_
            Goto ( hu->( RecNo() ) )
            ahu_ := get_field()
            AAdd( arr_huh3, { ahu, ahu_ } )
            Select HU
            Skip
          Enddo
          arr_mohuh3 := {}
          Select MOHU
          find ( Str( glob_persoh3, 7 ) )
          Do While mohu->kod == glob_persoh3 .and. !Eof()
            AAdd( arr_mohuh3, get_field() )
            Skip
          Enddo
          aonknah3 := {}
          Select mo_onkna
          find ( Str( glob_persoh3, 7 ) )
          Do While mo_onkna->kod == glob_persoh3 .and. !Eof()
            AAdd( aonknah3, get_field() )
            Skip
          Enddo
          aonkslh3 := {}
          Select mo_onksl
          find ( Str( glob_persoh3, 7 ) )
          Do While mo_onksl->kod == glob_persoh3 .and. !Eof()
            AAdd( aonkslh3, get_field() )
            Skip
          Enddo
          aonkcoh3 := {}
          Select mo_onkco
          find ( Str( glob_persoh3, 7 ) )
          Do While mo_onkco->kod == glob_persoh3 .and. !Eof()
            AAdd( aonkcoh3, get_field() )
            Skip
          Enddo
          aonkdih3 := {}
          Select mo_onkdi
          find ( Str( glob_persoh3, 7 ) )
          Do While mo_onkdi->kod == glob_persoh3 .and. !Eof()
            AAdd( aonkdih3, get_field() )
            Skip
          Enddo
          aonkprh3 := {}
          Select mo_onkpr
          find ( Str( glob_persoh3, 7 ) )
          Do While mo_onkpr->kod == glob_persoh3 .and. !Eof()
            AAdd( aonkprh3, get_field() )
            Skip
          Enddo
          aonkush3 := {}
          Select mo_onkus
          find ( Str( glob_persoh3, 7 ) )
          Do While mo_onkus->kod == glob_persoh3 .and. !Eof()
            AAdd( aonkush3, get_field() )
            Skip
          Enddo
          aonkleh3 := {}
          Select mo_onkle
          find ( Str( glob_persoh3, 7 ) )
          Do While mo_onkle->kod == glob_persoh3 .and. !Eof()
            AAdd( aonkleh3, get_field() )
            Skip
          Enddo
        Endif
      Endif
      //
      Select HUMAN_
      Goto ( glob_perso )
      g_rlock( forever )
      human_->OPLATA := 9
      If glob_persoh3 > 0
        Goto ( glob_persoh3 )
        g_rlock( forever )
        human_->OPLATA := 9
      Endif
      // теперь записываем в БД копию листа учёта
      Select HUMAN
      add1rec( 7 )
      mkod := RecNo()
      AEval( ahuman, {| x, i| FieldPut( i, x ) } )
      human->kod      := mkod
      human->TIP_H    := B_STANDART // лечение завершено
      // human->DATE_OPL := ""
      human->schet    := 0
      //
      Select HUMAN_
      Do While human_->( LastRec() ) < mkod
        Append Blank
      Enddo
      Goto ( mkod )
      g_rlock( forever )
      AEval( ahuman_, {| x, i| FieldPut( i, x ) } )
      human_->KOD_UP    := glob_perso // код оригинального листа учёта
      human_->SUMP      := 0
      human_->OPLATA    := 0
      human_->SANK_MEK  := 0
      human_->SANK_MEE  := 0
      human_->SANK_EKMP := 0
      human_->REESTR    := 0
      human_->REES_ZAP  := 0
      human_->SCHET_ZAP := 0
      human_->ST_VERIFY := 0 // снова ещё не проверен
      //
      Select HUMAN_2
      Do While human_2->( LastRec() ) < mkod
        Append Blank
      Enddo
      Goto ( mkod )
      g_rlock( forever )
      AEval( ahuman_2, {| x, i| FieldPut( i, x ) } )
      If fl_iname
        Select SN
        find ( Str( mkod, 7 ) )
        If Found()
          If !Empty( mnameismo )
            g_rlock( forever )
            sn->smo_name := mnameismo
          Else
            deleterec( .t. )
          Endif
        Else
          If !Empty( mnameismo )
            addrec( 7 )
            sn->kod := mkod
            sn->smo_name := mnameismo
          Endif
        Endif
      Endif
      For i := 1 To Len( arr_hu )
        Select HU
        add1rec( 7 )
        AEval( arr_hu[ i, 1 ], {| x, i| FieldPut( i, x ) } )
        hu->kod := mkod
        Select HU_
        Do While hu_->( LastRec() ) < hu->( RecNo() )
          Append Blank
        Enddo
        Goto ( hu->( RecNo() ) )
        g_rlock( forever )
        AEval( arr_hu[ i, 2 ], {| x, i| FieldPut( i, x ) } )
        hu_->OPLATA    := 0
        hu_->REES_ZAP  := 0
        hu_->SCHET_ZAP := 0
      Next
      //
      For i := 1 To Len( arr_mohu )
        Select MOHU
        add1rec( 7 )
        AEval( arr_mohu[ i ], {| x, i| FieldPut( i, x ) } )
        mohu->kod       := mkod
        mohu->OPLATA    := 0
        mohu->REES_ZAP  := 0
        mohu->SCHET_ZAP := 0
      Next
      dbSelectArea( "mo_onkna" )
      For i := 1 To Len( aonkna )
        addrec( 7 )
        AEval( aonkna[ i ], {| x, i| FieldPut( i, x ) } )
        mo_onkna->kod := mkod
      Next
      dbSelectArea( "mo_onksl" )
      For i := 1 To Len( aonksl )
        addrec( 7 )
        AEval( aonksl[ i ], {| x, i| FieldPut( i, x ) } )
        mo_onksl->kod := mkod
      Next
      dbSelectArea( "mo_onkco" )
      For i := 1 To Len( aonkco )
        addrec( 7 )
        AEval( aonkco[ i ], {| x, i| FieldPut( i, x ) } )
        mo_onkco->kod := mkod
      Next
      dbSelectArea( "mo_onkdi" )
      For i := 1 To Len( aonkdi )
        addrec( 7 )
        AEval( aonkdi[ i ], {| x, i| FieldPut( i, x ) } )
        mo_onkdi->kod := mkod
      Next
      dbSelectArea( "mo_onkpr" )
      For i := 1 To Len( aonkpr )
        addrec( 7 )
        AEval( aonkpr[ i ], {| x, i| FieldPut( i, x ) } )
        mo_onkpr->kod := mkod
      Next
      dbSelectArea( "mo_onkus" )
      For i := 1 To Len( aonkus )
        addrec( 7 )
        AEval( aonkus[ i ], {| x, i| FieldPut( i, x ) } )
        mo_onkus->kod := mkod
      Next
      dbSelectArea( "mo_onkle" )
      For i := 1 To Len( aonkle )
        addrec( 7 )
        AEval( aonkle[ i ], {| x, i| FieldPut( i, x ) } )
        mo_onkle->kod := mkod
      Next
      save_arr_dispans( mkod, arr_disp )
      If glob_persoh3 > 0
        // теперь записываем в БД копию второго листа учёта
        Select HUMAN
        add1rec( 7 )
        mkodh3 := RecNo()
        AEval( ahumanh3, {| x, i| FieldPut( i, x ) } )
        human->kod      := mkodh3
        human->TIP_H    := B_STANDART // лечение завершено
        // human->DATE_OPL := ""
        human->schet    := 0
        //
        Select HUMAN_
        Do While human_->( LastRec() ) < mkodh3
          Append Blank
        Enddo
        Goto ( mkodh3 )
        g_rlock( forever )
        AEval( ahuman_h3, {| x, i| FieldPut( i, x ) } )
        human_->KOD_UP    := glob_persoh3 // код оригинального листа учёта
        human_->SUMP      := 0
        human_->OPLATA    := 0
        human_->SANK_MEK  := 0
        human_->SANK_MEE  := 0
        human_->SANK_EKMP := 0
        human_->REESTR    := 0
        human_->REES_ZAP  := 0
        human_->SCHET_ZAP := 0
        human_->ST_VERIFY := 0 // снова ещё не проверен
        //
        Select HUMAN_2
        Do While human_2->( LastRec() ) < mkodh3
          Append Blank
        Enddo
        Goto ( mkodh3 )
        g_rlock( forever )
        AEval( ahuman_2h3, {| x, i| FieldPut( i, x ) } )
        If fl_inameh3
          Select SNh3
          find ( Str( mkodh3, 7 ) )
          If Found()
            If !Empty( mnameismoh3 )
              g_rlock( forever )
              sn->smo_name := mnameismoh3
            Else
              deleterec( .t. )
            Endif
          Else
            If !Empty( mnameismoh3 )
              addrec( 7 )
              sn->kod := mkodh3
              sn->smo_name := mnameismoh3
            Endif
          Endif
        Endif
        For i := 1 To Len( arr_huh3 )
          Select HU
          add1rec( 7 )
          AEval( arr_huh3[ i, 1 ], {| x, i| FieldPut( i, x ) } )
          hu->kod := mkodh3
          Select HU_
          Do While hu_->( LastRec() ) < hu->( RecNo() )
            Append Blank
          Enddo
          Goto ( hu->( RecNo() ) )
          g_rlock( forever )
          AEval( arr_huh3[ i, 2 ], {| x, i| FieldPut( i, x ) } )
          hu_->OPLATA    := 0
          hu_->REES_ZAP  := 0
          hu_->SCHET_ZAP := 0
        Next
        //
        For i := 1 To Len( arr_mohuh3 )
          Select MOHU
          add1rec( 7 )
          AEval( arr_mohuh3[ i ], {| x, i| FieldPut( i, x ) } )
          mohu->kod       := mkodh3
          mohu->OPLATA    := 0
          mohu->REES_ZAP  := 0
          mohu->SCHET_ZAP := 0
        Next
        dbSelectArea( "mo_onkna" )
        For i := 1 To Len( aonknah3 )
          addrec( 7 )
          AEval( aonknah3[ i ], {| x, i| FieldPut( i, x ) } )
          mo_onkna->kod := mkodh3
        Next
        dbSelectArea( "mo_onksl" )
        For i := 1 To Len( aonkslh3 )
          addrec( 7 )
          AEval( aonkslh3[ i ], {| x, i| FieldPut( i, x ) } )
          mo_onksl->kod := mkodh3
        Next
        dbSelectArea( "mo_onkco" )
        For i := 1 To Len( aonkcoh3 )
          addrec( 7 )
          AEval( aonkcoh3[ i ], {| x, i| FieldPut( i, x ) } )
          mo_onkco->kod := mkodh3
        Next
        dbSelectArea( "mo_onkdi" )
        For i := 1 To Len( aonkdih3 )
          addrec( 7 )
          AEval( aonkdih3[ i ], {| x, i| FieldPut( i, x ) } )
          mo_onkdi->kod := mkodh3
        Next
        dbSelectArea( "mo_onkpr" )
        For i := 1 To Len( aonkprh3 )
          addrec( 7 )
          AEval( aonkprh3[ i ], {| x, i| FieldPut( i, x ) } )
          mo_onkpr->kod := mkodh3
        Next
        dbSelectArea( "mo_onkus" )
        For i := 1 To Len( aonkush3 )
          addrec( 7 )
          AEval( aonkush3[ i ], {| x, i| FieldPut( i, x ) } )
          mo_onkus->kod := mkodh3
        Next
        dbSelectArea( "mo_onkle" )
        For i := 1 To Len( aonkleh3 )
          addrec( 7 )
          AEval( aonkleh3[ i ], {| x, i| FieldPut( i, x ) } )
          mo_onkle->kod := mkodh3
        Next
        Select HUMAN_3
        addrec( 7 )
        AEval( ahuman_3, {| x, i| FieldPut( i, x ) } )
        human_3->KOD       := mkod
        human_3->KOD2      := mkodh3
        human_3->PZTIP     := 0
        human_3->PZKOL     := 0
        human_3->ST_VERIFY := 0
        human_3->KOD_UP    := rec_h3
        human_3->OPLATA    := 0
        human_3->SUMP      := 0
        human_3->SANK_MEK  := 0
        human_3->SANK_MEE  := 0
        human_3->SANK_EKMP := 0
        human_3->REESTR    := 0
        human_3->REES_NUM  := 0
        human_3->REES_ZAP  := 0
        human_3->SCHET     := 0
        human_3->SCHET_NUM := 0
        human_3->SCHET_ZAP := 0
      Endif
      //
      g_use( dir_server + "mo_raksh", , "RAKSH" )
      Goto ( lrec )
      g_rlock( forever )
      raksh->IS_REPEAT := 1
      raksh->DATE_REP  := sys_date
      raksh->NEXT_KOD  := mkod
      Close databases
      stat_msg( "Данный лист учёта выставлен повторно" )
      mybell( 2, OK )
    Endif
  Endif
  rest_box( buf )

  Return Nil

// 14.05.20
Function rak_akt_schet_human_del_next( s, s1, lrec )

  Local i, arr1, arr2, mkod, mkodh3 := 0, buf := save_maxrow()

  glob_perso := raksh->kod_h
  If ( mkod := raksh->next_kod ) > 0
    Select RAKSH
    Set Relation To
    Select HUMAN
    Goto ( mkod )
    If human->schet > 0 .or. human_->REESTR > 0
      Return func_error( 10, "Повторно выставленный лист учёта уже попал в реестр (счёт). Удаление запрещено!" )
    Endif
  Endif
  arr1 := { s, ;
    s1, ;
    "После подтверждения повторно выставленный лист учёта будет удалён", ;
    "" }
  arr2 := { " Отказ ", " Удалить повторно выставленный л/у " }
  If f_alert( arr1, arr2, 1, "N+/GR*", "N/GR*", 15, , "N/GR*" ) == 2
    If f_alert( arr1, arr2, 1, "N+/GR*", "R/GR*", 16, , "N/GR*" ) == 2
      mywait()
      Close databases
      use_base( "mo_hdisp" )
      use_base( "mo_hu" )
      use_base( "human_u" )
      g_use( dir_server + "human_3", { dir_server + "human_3", dir_server + "human_32" }, "HUMAN_3" )
      use_base( "human" )
      Goto ( glob_perso )
      glob_persoh3 := 0
      If human->ishod == 88
        Select HUMAN_3
        find ( Str( glob_perso, 7 ) )
        If Found()
          glob_persoh3 := human_3->kod2
        Endif
      Endif
      Select HUMAN
      Goto ( mkod )
      If human->ishod == 88
        Select HUMAN_3
        find ( Str( mkod, 7 ) )
        If Found()
          mkodh3 := human_3->kod2
          rech3 := RecNo()
        Endif
      Endif
      g_use( dir_server + "mo_raksh", , "RAKSH" )
      g_use( dir_server + "mo_os", , "MO_OS" )
      Index On Str( kod, 7 ) to ( cur_dir + "tmp_moos" ) For NEXT_KOD > 0
      find ( Str( glob_perso, 7 ) )
      If Found()
        deleterec( .t. )
      Endif
      Do While .t.
        Select HDISP
        find ( Str( mkod, 7 ) )
        If !Found()
          Exit
        Endif
        deleterec( .t. )
      Enddo
      g_use( dir_server + "mo_onkna", dir_server + "mo_onkna" )
      Do While .t.
        find ( Str( mkod, 7 ) )
        If !Found()
          Exit
        Endif
        deleterec( .t. )
      Enddo
      If mkodh3 > 0
        Do While .t.
          find ( Str( mkodh3, 7 ) )
          If !Found()
            Exit
          Endif
          deleterec( .t. )
        Enddo
      Endif
      g_use( dir_server + "mo_onksl", dir_server + "mo_onksl" )
      Do While .t.
        find ( Str( mkod, 7 ) )
        If !Found()
          Exit
        Endif
        deleterec( .t. )
      Enddo
      If mkodh3 > 0
        Do While .t.
          find ( Str( mkodh3, 7 ) )
          If !Found()
            Exit
          Endif
          deleterec( .t. )
        Enddo
      Endif
      g_use( dir_server + "mo_onkco", dir_server + "mo_onkco" )
      Do While .t.
        find ( Str( mkod, 7 ) )
        If !Found()
          Exit
        Endif
        deleterec( .t. )
      Enddo
      If mkodh3 > 0
        Do While .t.
          find ( Str( mkodh3, 7 ) )
          If !Found()
            Exit
          Endif
          deleterec( .t. )
        Enddo
      Endif
      g_use( dir_server + "mo_onkdi", dir_server + "mo_onkdi" )
      Do While .t.
        find ( Str( mkod, 7 ) )
        If !Found()
          Exit
        Endif
        deleterec( .t. )
      Enddo
      If mkodh3 > 0
        Do While .t.
          find ( Str( mkodh3, 7 ) )
          If !Found()
            Exit
          Endif
          deleterec( .t. )
        Enddo
      Endif
      g_use( dir_server + "mo_onkpr", dir_server + "mo_onkpr" )
      Do While .t.
        find ( Str( mkod, 7 ) )
        If !Found()
          Exit
        Endif
        deleterec( .t. )
      Enddo
      If mkodh3 > 0
        Do While .t.
          find ( Str( mkodh3, 7 ) )
          If !Found()
            Exit
          Endif
          deleterec( .t. )
        Enddo
      Endif
      g_use( dir_server + "mo_onkus", dir_server + "mo_onkus" )
      Do While .t.
        find ( Str( mkod, 7 ) )
        If !Found()
          Exit
        Endif
        deleterec( .t. )
      Enddo
      If mkodh3 > 0
        Do While .t.
          find ( Str( mkodh3, 7 ) )
          If !Found()
            Exit
          Endif
          deleterec( .t. )
        Enddo
      Endif
      g_use( dir_server + "mo_onkle", dir_server + "mo_onkle" )
      Do While .t.
        find ( Str( mkod, 7 ) )
        If !Found()
          Exit
        Endif
        deleterec( .t. )
      Enddo
      If mkodh3 > 0
        Do While .t.
          find ( Str( mkodh3, 7 ) )
          If !Found()
            Exit
          Endif
          deleterec( .t. )
        Enddo
      Endif
      Do While .t.
        Select MOHU
        find ( Str( mkod, 7 ) )
        If !Found()
          Exit
        Endif
        deleterec( .t., .f. )  // без пометки на удаление
        If mkodh3 > 0
          Do While .t.
            find ( Str( mkodh3, 7 ) )
            If !Found()
              Exit
            Endif
            deleterec( .t., .f. )  // без пометки на удаление
          Enddo
        Endif
      Enddo
      Do While .t.
        Select HU
        find ( Str( mkod, 7 ) )
        If !Found()
          Exit
        Endif
        //
        Select HU_
        deleterec( .t., .f. )
        Select HU
        deleterec( .t., .f. )  // без пометки на удаление
      Enddo
      If mkodh3 > 0
        Do While .t.
          Select HU
          find ( Str( mkodh3, 7 ) )
          If !Found()
            Exit
          Endif
          //
          Select HU_
          deleterec( .t., .f. )
          Select HU
          deleterec( .t., .f. )  // без пометки на удаление
        Enddo
      Endif
      If mkodh3 > 0
        Select HUMAN
        find ( Str( mkodh3, 7 ) )
        Select HUMAN_
        deleterec( .t., .f. )
        Select HUMAN
        deleterec( .t., .f. )  // без пометки на удаление
        g_rlock( forever )
        Replace human->schet With -1  // (вместо нуля)
      Endif
      Select HUMAN
      find ( Str( mkod, 7 ) )
      Select HUMAN_
      deleterec( .t., .f. )
      Select HUMAN
      deleterec( .t., .f. )  // без пометки на удаление
      g_rlock( forever )
      Replace human->schet With -1  // (вместо нуля)
      //
      Select RAKSH
      Goto ( lrec )
      g_rlock( forever )
      raksh->IS_REPEAT := 0
      raksh->DATE_REP  := CToD( "" )
      raksh->NEXT_KOD  := 0
      //
      If glob_persoh3 > 0
        Select HUMAN
        Goto ( glob_persoh3 )
        Select HUMAN_
        g_rlock( forever )
        human_->OPLATA := raksh->OPLATA
      Endif
      If mkodh3 > 0
        Select HUMAN_3
        Goto ( rech3 )
        deleterec( .t. )
      Endif
      Select HUMAN
      Goto ( glob_perso )
      Select HUMAN_
      g_rlock( forever )
      human_->OPLATA    := raksh->OPLATA
      human_->SANK_MEK  := raksh->SANK_MEK
      human_->SANK_MEE  := raksh->SANK_MEE
      human_->SANK_EKMP := raksh->SANK_EKMP
      Close databases
      stat_msg( "Повторно выставленный лист учёта удалён" )
      mybell( 2, OK )
    Endif
  Endif
  rest_box( buf )

  Return Nil

// 10.12.13
Function ret_menu_rak_schet( r, c )

  Static si := 4, ;
    arr := { { "по дате отчётного периода", 1 }, ;
    { "по дате выписки счёта", 2 }, ;
    { "по дате регистрации счёта", 3 }, ;
    { "по дате акта контроля", 4 }, ;
    { "по дате РеестраАктовКонтроля", 5 } }
  Local i, ret, ret_arr

  Default r To T_ROW, c To T_COL -5
  If popup_2array( arr, r, c, si, 1, @ret_arr ) > 0 .and. ValType( ret_arr ) == "A"
    si := ret_arr[ 2 ]
    ret := { ret_arr[ 2 ], ret_arr[ 1 ] }
  Endif

  Return ret

// 30.04.25 список снятий по актам
Function akt_list_of_refusal_pacient()

  Static si := 3
  Static mas_pmt := { "случаи полного снятия", ;
    "случаи частичного снятия", ;
    "все случаи снятия", ;
    "перевыставленные случаи полного снятия", ;
    "не перевыставленные случаи полного снятия" }
  Local buf := save_maxrow(), lsmo, lmenu, i, j, k, s, t_arr[ 2 ], ;
    ireg, fl, arr_m, n_file := cur_dir + "spis_sn" + stxt, sh := 80, HH := 60

  Private a_otd := {}

  If ( st_a_uch := inputn_uch( T_ROW, T_COL -5, , , @lcount_uch ) ) == NIL
    Return Nil
  Endif
  If Len( st_a_uch ) == 1
    glob_uch := st_a_uch[ 1 ]
    If ( st_a_otd := inputn_otd( T_ROW, T_COL -5, .f., .f., glob_uch, @lcount_otd ) ) == NIL
      Return Nil
    Endif
    AEval( st_a_otd, {| x| AAdd( a_otd, x[ 1 ] ) } )
  Else
    r_use( dir_server + "mo_otd", , "OTD" )
    Go Top
    Do While !Eof()
      If f_is_uch( st_a_uch, otd->kod_lpu )
        AAdd( a_otd, otd->( RecNo() ) )
      Endif
      Skip
    Enddo
    otd->( dbCloseArea() )
  Endif
  If ( lsmo := ret_actual_smo() ) == NIL
    Return Nil
  Endif
  If ( lmenu := ret_menu_rak_schet() ) == NIL
    Return Nil
  Endif
  If ( arr_m := year_month( T_ROW, T_COL -5 ) ) == NIL
    Return Nil
  Endif
  If ( ireg := popup_prompt( T_ROW, T_COL -5, si, mas_pmt ) ) == 0
    Return Nil
  Endif
  si := ireg
  If lmenu[ 1 ] == 1 .and. !is_otch_period( arr_m )
    Return Nil
  Endif
  mywait()
  delfrfiles()
  adbf := { { "name", "C", 130, 0 }, ;
    { "name1", "C", 130, 0 }, ;
    { "name2", "C", 130, 0 }, ;
    { "name3", "C", 130, 0 }, ;
    { "sroki", "C", 100, 0 }, ;
    { "sdata", "C", 100, 0 }, ;
    { "ssmo", "C", 50, 0 }, ;
    { "summa1", "N", 15, 2 }, ;
    { "summa2", "N", 15, 2 }, ;
    { "summa3", "N", 15, 2 }, ;
    { "nitog1", "N", 5, 0 }, ;
    { "nitog2", "N", 5, 0 }, ;
    { "nitog3", "N", 5, 0 } }
  dbCreate( fr_titl, adbf )
  Use ( fr_titl ) New Alias FRT
  Append Blank
  frt->name := glob_mo[ _MO_SHORT_NAME ]
  frt->sroki := arr_m[ 4 ]
  frt->sdata := lmenu[ 2 ] + iif( ireg < 3, "", " / " + mas_pmt[ ireg ] )
  frt->ssmo  := lsmo[ 2 ]
  adbf := { { "nrak", "C", 50, 0 }, ;
    { "drak", "C", 10, 0 }, ;
    { "nakt", "C", 50, 0 }, ;
    { "dakt", "C", 10, 0 }, ;
    { "nschet", "C", 50, 0 }, ;
    { "dschet", "C", 10, 0 }, ;
    { "dregschet", "C", 10, 0 }, ;
    { "fio", "C", 60, 0 }, ;
    { "date_r", "C", 10, 0 }, ;
    { "otd", "C", 42, 0 }, ;
    { "n_data", "C", 10, 0 }, ;
    { "k_data", "C", 10, 0 }, ;
    { "cena_1", "N", 11, 2 }, ;
    { "sum_sn", "C", 30, 0 }, ;
    { "sum_snn", "N", 11, 2 }, ;
    { "REFREASON", "C", 15, 0 }, ;
    { "DATE_REP", "C", 10, 0 }, ;
    { "NUMORDER", "N", 10, 0 }, ;
    { "kod_h", "N", 7, 0 } }  // 10.08.2022 для РДЛ
  dbCreate( fr_data, adbf )
  Use ( fr_data ) New Alias FRD
  adbf := { { "REFREASON", "N", 3, 0 }, ;
    { "kol", "N", 6, 0 }, ;
    { "name", "C", 140, 0 } }
  dbCreate( fr_data + "1", adbf )
  Use ( fr_data + "1" ) New Alias FRD1
  Index On Str( REFREASON, 3 ) to ( fr_data + "1" )
  adbf := { { "num_usl", "C", 10, 0 }, ;    // номер услуги по порядку
    { "REFREASON", "C", 15, 0 }, ;
    { "shifr_usl", "C", 10, 0 }, ;  // шифр услуги
    { "name_usl", "C", 250, 0 }, ; // наименование услуги
    { "NUMORDER", "N", 10, 0 }, ;   // Номер заявки(ORDER Number)
    { "fio", "C", 60, 0 }, ;
    { "date_r", "C", 10, 0 }, ;
    { "kol_usl", "N", 10, 0 }, ;    // кол-во услуг
    { "cena_1", "N", 11, 2 }, ;
    { "sum_sn", "N", 11, 2 }, ;
    { "DATE_REP", "C", 10, 0 }, ;
    { "otd", "C", 42, 0 } }
  dbCreate( fr_data + "2", adbf )
  dbCreate( fr_data + "3", adbf )
  Use ( fr_data + "2" ) New Alias FRD2
  Use ( fr_data + "3" ) New Alias FRD3
  //
  fp := FCreate( n_file )
  n_list := 1
  tek_stroke := 0
  add_string( "" )
  If ireg == 3
    s := "Список снятий по актам контроля"
  Elseif ireg == 2
    s := "Список частичных снятий по актам контроля"
  Else
    s := "Список снятий (полных отказов) по актам контроля"
  Endif
  add_string( Center( s, sh ) )
  frt->name1 := s
  add_string( Center( arr_m[ 4 ], sh ) )
  add_string( Center( "[ " + lmenu[ 2 ] + " ]", sh ) )
  add_string( Center( lsmo[ 2 ], sh ) )
  add_string( "" )
  r_use( dir_server + "schet_", , "SCHET_" )
  r_use( dir_server + "mo_pers", , "PERS" )
  r_use( dir_server + "mo_otd", , "OTD" )
  r_use( dir_server + "human_2", , "HUMAN_2" )
  r_use( dir_server + "human_", , "HUMAN_" )
  r_use( dir_server + "human", , "HUMAN" )
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2, To otd into OTD
  r_use( dir_server + "mo_raksh", , "RAKSH" )
  Index On Str( kod_raks, 6 ) to ( cur_dir + "tmpraksh" )
  r_use( dir_server + "mo_raks", , "RAKS" )
  Index On Str( akt, 6 ) to ( cur_dir + "tmpraks" ) For plat == lsmo[ 1 ]
  r_use( dir_server + "mo_rak", , "RAK" )
  Index On Str( kod_xml, 6 ) + DToS( dakt ) + nakt to ( cur_dir + "tmprak" )
  r_use( dir_server + "mo_xml", , "MO_XML" )
  Index On dfile to ( cur_dir + "tmp_xml" ) For TIP_IN == _XML_FILE_RAK
  j := 0
  Go Top
  Do While !Eof()
    If iif( lmenu[ 1 ] == 5, Between( mo_xml->DFILE, arr_m[ 5 ], arr_m[ 6 ] ), .t. )
      fl_xml := .t.
      Select RAK
      find ( Str( mo_xml->kod, 6 ) )
      Do While mo_xml->kod == rak->kod_xml .and. !Eof()
        If iif( lmenu[ 1 ] == 4, Between( rak->dakt, arr_m[ 5 ], arr_m[ 6 ] ), .t. )
          vid_eks := ret_vid_eks()
          fl_rak := .t.
          Select RAKS
          find ( Str( rak->akt, 6 ) )
          Do While rak->akt == raks->akt .and. !Eof()
            schet_->( dbGoto( raks->schet ) )
            fl := .t.
            If lmenu[ 1 ] == 1
              fl := between_otch_period( schet_->dschet, schet_->NYEAR, schet_->NMONTH, arr_m[ 5 ], arr_m[ 6 ] )
            Elseif lmenu[ 1 ] == 2
              fl := Between( schet_->dschet, arr_m[ 5 ], arr_m[ 6 ] )
            Elseif lmenu[ 1 ] == 3
              fl := ( schet_->NREGISTR == 0 .and. Between( date_reg_schet(), arr_m[ 5 ], arr_m[ 6 ] ) )
            Endif
            If fl
              fl_raks := .t.
              Select RAKSH
              find ( Str( raks->kod_raks, 6 ) )
              Do While raks->kod_raks == raksh->kod_raks .and. !Eof()
                human->( dbGoto( raksh->KOD_H ) )
                s := raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
                ssh := raksh->penalty
                s1 := ""
                If vid_eks == 2 .or. !Empty( raksh->SANK_EKMP )
                  s1 += "/ЭКМП"
                Elseif vid_eks == 1 .or. !Empty( raksh->SANK_MEE )
                  s1 += "/МЭЭ"
                Else
                  s1 += "/МЭК"
                Endif
                If !Empty( raksh->penalty )
                  s1 += "/ штраф"
                Endif
                If ( fl := ( raksh->REFREASON > 0 .and. !emptyall( s, ssh ) ) ) // round(human->cena_1, 2)==round(s+raksh->SUMP, 2)
                  If ireg == 2 // частичное
                    fl := ( raksh->oplata == 3 )
                  Elseif ireg == 3 // все случаи
                    fl := eq_any( raksh->oplata, 2, 3 )
                  Else
                    If ( fl := ( raksh->oplata == 2 ) )
                      If ireg == 4 // перевыставленные
                        fl := ( raksh->NEXT_KOD > 0 )
                      Elseif ireg == 5 // не перевыставленные
                        fl := ( raksh->NEXT_KOD == 0 )
                      Endif
                    Endif
                  Endif
                Endif
                If fl
                  fl := ( AScan( a_otd, human->otd ) > 0 )
                Endif
                If fl
                  procent := Round( s / human->cena_1 * 100, 0 )
                  verify_ff( HH -3, .t., sh )
                  Select FRD
                  Append Blank
                  frd->nrak := AllTrim( mo_xml->FNAME )
                  frd->drak := date_8( mo_xml->DFILE )
                  If fl_xml
                    add_string( "РАК: " + AllTrim( mo_xml->FNAME ) + " от " + date_8( mo_xml->DFILE ) )
                    fl_xml := .f.
                  Endif
                  frd->nakt := AllTrim( rak->nakt )
                  frd->dakt := date_8( rak->dakt )
                  If fl_rak
                    add_string( Space( 2 ) + "акт: " + AllTrim( rak->nakt ) + " от " + date_8( rak->dakt ) )
                    fl_rak := .f.
                  Endif
                  frd->nschet := AllTrim( schet_->nschet )
                  frd->dschet := date_8( schet_->dschet )
                  If schet_->NREGISTR == 0
                    frd->dregschet := date_8( date_reg_schet() )
                  Endif
                  If fl_raks
                    add_string( Space( 4 ) + "счёт: " + AllTrim( schet_->nschet ) + " от " + date_8( schet_->dschet ) )
                    fl_raks := .f.
                  Endif
                  verify_ff( HH -3, .t., sh )
                  add_string( Space( 6 ) + lstr( ++j ) + ". " + AllTrim( human->fio ) + ", " + ;
                    full_date( human->date_r ) + ;
                    iif( Empty( otd->SHORT_NAME ), "", " [" + AllTrim( otd->SHORT_NAME ) + "]" ) + ;
                    " " + date_8( human->n_data ) + "-" + date_8( human->k_data ) )
                  add_string( Space( 8 ) + "! полный отказ - " + lstr( human->cena_1, 11, 2 ) + "р." )
                  If raksh->oplata == 2
                    frt->nitog1++
                    frt->summa1 += s
                  Else
                    frt->nitog2++
                    frt->summa2 += s
                  Endif
                  If !Empty( ssh )
                    frt->nitog3++
                    frt->summa3 += ssh
                  Endif
                  frd->fio    := human->fio
                  frd->date_r := full_date( human->date_r )
                  pers->( dbGoto( human_->vrach ) )
                  frd->otd    := AllTrim( otd->SHORT_NAME ) + " / " + fam_i_o( pers->fio )
                  frd->n_data := Left( date_8( human->n_data ), 5 )
                  frd->k_data := date_8( human->k_data )
                  frd->cena_1 := human->cena_1
                  frd->sum_snn := s
                  If !Empty( s ) .and. Empty( ssh )
                    frd->sum_sn := lstr( s, 15, 2 )
                  Elseif Empty( s ) .and. !Empty( ssh )
                    frd->sum_sn := lstr( ssh, 15, 2 ) + "шт"
                  Else
                    frd->sum_sn := lstr( s, 15, 2 ) + eos + lstr( ssh, 15, 2 ) + "шт"
                  Endif
                 // If Empty( s := ret_t005( raksh->REFREASON ) ) /// !!!!!!!
                  If Empty( s := ret_f014( raksh->REFREASON ) ) 
                     s := lstr( raksh->REFREASON ) + " неизвестная причина отказа"
                  Endif
                  frd->REFREASON := lstr( raksh->REFREASON ) + s1
                  frd->NUMORDER  :=  HUMAN_2->pn3
                  frd->kod_h     := human->kod
                  Select FRD1
                  find ( Str( raksh->REFREASON, 3 ) )
                  If !Found()
                    Append Blank
                    frd1->REFREASON := raksh->REFREASON
                    frd1->name := s
                  Endif
                  frd1->kol++
                  k := perenos( t_arr, s, 72 )
                  For i := 1 To k
                    add_string( Space( 8 ) + t_arr[ i ] )
                  Next
                  If raksh->NEXT_KOD > 0
                    add_string( Space( 8 ) + "! случай уже перевыставлен " + date_8( raksh->DATE_REP ) )
                    frd->DATE_REP := date_8( raksh->DATE_REP )
                  Elseif Between( procent, 1, 99 )
                    frd->DATE_REP := "- " + lstr( procent ) + " %"
                  Endif
                Endif
                Select RAKSH
                Skip
              Enddo
            Endif
            Select RAKS
            Skip
          Enddo
        Endif
        Select RAK
        Skip
      Enddo
    Endif
    Select MO_XML
    Skip
  Enddo
  FClose( fp )
  s := ""
  If frt->nitog1 > 0
    s := "Итого пациентов с полным отказом " + lstr( frt->nitog1 ) + " чел. на сумму " + lstr( frt->summa1, 15, 2 ) + "р. "
  Endif
  If frt->nitog2 > 0
    s += " Итого пациентов с частичным отказом " + lstr( frt->nitog2 ) + " чел. на сумму " + lstr( frt->summa2, 15, 2 ) + "р."
  Endif
  frt->name2 := s
  If frt->nitog3 > 0
    frt->name3 := "Итого штрафов: " + lstr( frt->nitog3 ) + " на сумму " + lstr( frt->summa3, 15, 2 ) + "р."
  Endif
  If glob_mo[ _MO_KOD_TFOMS ] == '805965' // РДЛ
    r_use( dir_server + "uslugi", , "USLUGI" )
    r_use( dir_server + "human_u", dir_server + "human_u", "human_u" )
    use_base( "lusl" )
    Select frd
    Go Top
    Do While !Eof()
      Select HUMAN_U
      find ( Str( frd->kod_h, 7 ) )
      Do While frd->kod_h == human_u->kod .and. !Eof()
        Select frd2
        Append Blank
        // {"num_usl", "N", 10, 0}, ;    // номер услуги по порядку
        Select Uslugi
        Goto human_u->u_kod
        // frd2->num_usl    :=
        frd2->shifr_usl  := uslugi->shifr
        frd2->name_usl   := uslugi->name
        frd2->kol_usl := human_u->kol_1
        frd2->cena_1  := human_u->stoim_1
        musl := transform_shifr( frd2->shifr_usl )
        Select lusl
        find( musl )
        frd2->name_usl := lusl->name
        If frd->cena_1 == frd->sum_snn
          // снято полностью
          frd2->sum_sn := human_u->stoim_1
        Endif
        frd2->REFREASON := frd->REFREASON
        frd2->DATE_REP  := frd->DATE_REP
        frd2->NUMORDER  := frd->NUMORDER
        frd2->fio       := frd->fio
        frd2->date_r    := frd->date_r
        frd2->otd       := frd->otd
        Select human_u
        Skip
      Enddo
      Select frd
      Skip
    Enddo
    // упорядычеваем
    Select frd2
    Index On refreason + shifr_usl + Str( numorder, 10 ) To tmp_frd9
    Go Top
    temp_1 := " "
    temp_2 := 1
    temp_3 := 0 // кол_во
    temp_4 := 0 // сумма
    Do While !Eof()
      Select FRD3
      Append Blank
      If frd2->shifr_usl != temp_1
        If temp_3 != 0
          frd3->fio        := " ВСЕГО :"
          frd3->kol_usl    := temp_3
          frd3->cena_1     := temp_4
          frd3->sum_sn     := temp_4
          Append Blank
        Endif
        frd3->num_usl    := Str( temp_2 )
        frd3->shifr_usl  := frd2->shifr_usl
        frd3->name_usl   := frd2->name_usl
        frd3->REFREASON  := frd2->REFREASON
        temp_1 := frd2->shifr_usl
        temp_2++
        temp_3 := frd2->kol_usl
        temp_4 := frd2->sum_sn
      Else
        frd3->shifr_usl  := " "
        frd3->name_usl   := " "
        temp_3 += frd2->kol_usl
        temp_4 += frd2->sum_sn
      Endif
      frd3->kol_usl    := frd2->kol_usl
      frd3->cena_1     := frd2->cena_1
      frd3->sum_sn     := frd2->sum_sn
      frd3->DATE_REP   := frd2->DATE_REP
      frd3->NUMORDER   := frd2->NUMORDER
      frd3->fio        := frd2->fio
      frd3->date_r     := frd2->date_r
      frd3->otd        := frd2->otd
      Select frd2
      Skip
    Enddo
    Select FRD3
    Append Blank
    frd3->fio        := " ВСЕГО :"
    frd3->kol_usl    := temp_3
    frd3->cena_1     := temp_4
    frd3->sum_sn     := temp_4
  Endif
  Close databases

  rest_box( buf )
  name_fr := "mo_spis_sn" + sfr3
  If _upr_epson() .or. !File( dir_exe() + name_fr )
    viewtext( n_file, , , , .f., , , 2 )
  Else
    call_fr( name_fr )
  Endif

  If glob_mo[ _MO_KOD_TFOMS ] == '805965' // РДЛ
    create_xls_rdl( 'rdl_report', arr_m, st_a_uch, lcount_uch, st_a_otd, lcount_otd )
    saveto( cur_dir + 'rdl_report.xlsx' )
  Endif

  Return Nil

// 13.02.19 Список РАК
Function pr_list_rak()

  Static arr_smo
  Local buf := save_maxrow(), arr_m, n_file := cur_dir + "list_RAK" + stxt, ta[ 2 ], i, s, asmo, ;
    krak := 0, kakt, ksch, kpac, kerr, kpen, sh, HH := 60

  If arr_smo == NIL
    arr_smo := mo_cut_menu( glob_arr_smo )
  Endif
  If ( arr_m := year_month( T_ROW, T_COL -5 ) ) == NIL
    Return Nil
  Endif
  If ( asmo := bit_popup( T_ROW, T_COL -5, arr_smo, , color0 ) ) == NIL
    Return Nil
  Endif
  s := ""
  For i := 1 To Len( asmo )
    s += asmo[ i, 1 ] + ", "
  Next
  arr_title := { ;
    "──────────┬─────┬──────────────────────────┬─────┬──────┬──────┬──────┬──────┬──────", ;
    "   Дата   │Отчёт│                          │     │кол-во│кол-во│кол-во│кол-во│кол-во", ;
    "   РАК    │перио│      Акт контроля─       │ СМО │актов │счетов│пациен│снятий│штрафов", ;
    "──────────┴─────┴──────────────────────────┴─────┴──────┴──────┴──────┴──────┴──────" }
  sh := Len( arr_title[ 1 ] )
  k := perenos( ta, Left( s, Len( s ) -2 ), sh )
  //
  fp := FCreate( n_file )
  n_list := 1
  tek_stroke := 0
  add_string( glob_mo[ _MO_SHORT_NAME ] )
  add_string( "" )
  add_string( Center( "Список реестров актов контроля", sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  For i := 1 To k
    add_string( Center( AllTrim( ta[ i ] ), sh ) )
  Next
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  //
  r_use( dir_server + "mo_raksh", , "RAKSH" )
  Index On Str( kod_raks, 6 ) To tmp_raksh For !Empty( PENALTY ) memory // только пациенты со штрафом
  r_use( dir_server + "schet_", , "SCHET_" )
  r_use( dir_server + "mo_raks", , "RAKS" )
  Index On Str( akt, 6 ) To tmpraks memory
  r_use( dir_server + "mo_rak", , "RAK" )
  Index On Str( kod_xml, 6 ) To tmprak memory
  r_use( dir_server + "mo_xml", , "MO_XML" )
  Index On dfile To tmp_xml For TIP_IN == _XML_FILE_RAK memory
  Go Top
  Do While !Eof()
    If Between( mo_xml->DFILE, arr_m[ 5 ], arr_m[ 6 ] )
      otch_period := Space( 6 )
      lsmo := Space( 5 )
      kakt := ksch := kpac := kerr := kpen := 0
      Select RAK
      find ( Str( mo_xml->kod, 6 ) )
      Do While mo_xml->kod == rak->kod_xml .and. !Eof()
        Select RAKS
        find ( Str( rak->akt, 6 ) )
        Do While rak->akt == raks->akt .and. !Eof()
          If AScan( asmo, {| x| x[ 2 ] == Int( Val( raks->plat ) ) } ) > 0
            lsmo := raks->plat
            schet_->( dbGoto( raks->schet ) )
            s := Right( Str( schet_->NYEAR, 4 ), 2 ) + "/" + StrZero( schet_->NMONTH, 2 ) + " "
            If Empty( otch_period )
              otch_period := s
            Elseif !( otch_period == s ) .and. !( Right( otch_period, 1 ) == " +" )
              otch_period := Left( otch_period, 5 ) + " +"
            Endif
            Select RAKSH
            find ( Str( raks->kod_raks, 6 ) )
            Do While raks->kod_raks == raksh->kod_raks .and. !Eof()
              kpen++
              Skip
            Enddo
          Endif
          Select RAKS
          Skip
        Enddo
        kakt++
        ksch += rak->KOL_SCH
        kpac += rak->KOL_PAC
        kerr += rak->KOL_ERR
        Select RAK
        Skip
      Enddo
      If !Empty( otch_period )
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        krak++
        otch_period := padr(otch_period, 7)
        add_string( full_date( mo_xml->DFILE ) + " " + otch_period + PadR( alltrim(mo_xml->FNAME), 26 ) + lsmo + ;
          put_val( kakt, 7 ) + put_val( ksch, 7 ) + put_val( kpac, 7 ) + put_val( kerr, 7 ) + put_val( kpen, 7 ) )
      Endif
    Endif
    Select MO_XML
    Skip
  Enddo
  add_string( Replicate( "─", sh ) )
  add_string( "  Итого количество РАК (реестров актов контроля) - " + lstr( krak ) )
  FClose( fp )
  Close databases
  rest_box( buf )
  viewtext( n_file, , , , .t., , , 2 )

  Return Nil

// 29.11.15 Список счетов без РАК
Function pr_schet_bez_rak()

  Local buf := save_maxrow(), arr_m, n_file := cur_dir + "s_bezRAK" + stxt, sh, HH := 60

  If ( arr_m := year_month( T_ROW, T_COL -5, , 4 ) ) == NIL
    Return Nil
  Endif
  arr_title := { ;
    "───────────────┬────────┬─────╥─────┬────────────╥────────╥─────────────────", ;
    "               │  Дата  │Отчёт║ Кол.│            ║Дата ре-║                 ", ;
    "  Номер счета  │  счета │перио║больн│ Сумма счёта║гистр-ии║  Акт контроля   ", ;
    "───────────────┴────────┴─────╨─────┴────────────╨────────╨─────────────────" }
  sh := Len( arr_title[ 1 ] )
  //
  fp := FCreate( n_file )
  n_list := 1
  tek_stroke := 0
  add_string( "" )
  add_string( Center( "Список счетов, по которым нет актов контроля", sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  add_string( Center( "[ по дате отчётного периода ]", sh ) )
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  r_use( dir_server + "mo_raks", , "RAKS" )
  Index On Str( schet, 6 ) to ( cur_dir + "tmpraks" )
  r_use( dir_server + "schet_", , "SCHET_" )
  r_use( dir_server + "schet", , "SCHET" )
  Set Relation To RecNo() into SCHET_
  Index On Str( schet_->nyear, 4 ) + Str( schet_->nmonth, 2 ) to ( cur_dir + "tmp_schet" ) ;
    For Empty( schet_->IS_DOPLATA )
  dbSeek( Str( arr_m[ 1 ], 4 ) + Str( arr_m[ 2 ], 2 ), .t. )
  Do While schet_->nyear == arr_m[ 1 ] .and. schet_->nmonth <= arr_m[ 3 ] .and. !Eof()
    Select RAKS
    find ( Str( schet->( RecNo() ), 6 ) )
    If !Found()
      s := schet_->nschet + " " + date_8( schet_->dschet ) + " " + ;
        put_otch_period() + ;
        put_val( schet->kol, 6 ) + put_kop( schet->summa, 13 ) + " "
      If schet_->NREGISTR == 1 // ещё не зарегистрирован
        s += "ещё нет "
      Elseif schet_->NREGISTR == 2 // не будет зарегистрирован
        s += "не будет"
      Elseif schet_->NREGISTR == 3 // удалён
        s += "удалён  "
      Else
        s += date_8( schet_->DREGISTR )
      Endif
      s += "     нет акта"
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( s )
    Endif
    Select SCHET
    Skip
  Enddo
  FClose( fp )
  Close databases
  rest_box( buf )
  viewtext( n_file, , , , .f., , , 2 )

  Return Nil

// 31.01.25 суммы снятий по актам
Function akt_summa_of_refusal( tip )

  // 1 - по дате АКТА в РАК
  // 2  - по дате РАК
  Local buf := save_maxrow(), arr_m, n_file := cur_dir + 'sum_RAK' + stxt, sh, HH := 40, arr_smo := AClone( glob_arr_smo )

  If ( arr_m := year_month( T_ROW, T_COL -5 ) ) == NIL
    Return Nil
  Endif
  mywait()
  adbf := { { 'REFREASON', 'N', 3, 0 }, ;
    { 'srefr', 'C', 13, 0 }, ;
    { 'smo', 'C', 5, 0 }, ;
    { 'kol', 'N', 6, 0 }, ;
    { 'summa', 'N', 15, 2 }, ;
    { 'kol1', 'N', 6, 0 }, ;
    { 'summa1', 'N', 15, 2 }, ;
    { 'kol2', 'N', 6, 0 }, ;
    { 'summa2', 'N', 15, 2 }, ;
    { 'kol4', 'N', 6, 0 }, ;
    { 'summa4', 'N', 15, 2 }, ;
    { 'kol3', 'N', 6, 0 }, ;
    { 'summa3', 'N', 15, 2 } }
  dbCreate( cur_dir + 'tmp', adbf )
  Use ( cur_dir + 'tmp' ) new
  Index On smo + Str( REFREASON, 3 ) to ( cur_dir + 'tmp' )
  r_use( dir_server + 'mo_raksh', , 'RAKSH' )
  Index On Str( kod_raks, 6 ) to ( cur_dir + 'tmpraksh' )
  r_use( dir_server + 'mo_raks', , 'RAKS' )
  Index On Str( akt, 6 ) to ( cur_dir + 'tmpraks' )
  r_use( dir_server + 'mo_rak', , 'RAK' )
  If TIP == 1 // дата АКТА
    Index On DToS( dakt ) to ( cur_dir + 'tmprak' ) For Between( dakt, arr_m[ 5 ], arr_m[ 6 ] )
    Go Top
    Do While !Eof()
      @ MaxRow(), 0 Say PadR( date_8( rak->dakt ), 80 ) Color 'W/R'
      vid_eks := ret_vid_eks()
      Select RAKS
      find ( Str( rak->akt, 6 ) )
      Do While rak->akt == raks->akt .and. !Eof()
        Select RAKSH
        find ( Str( raks->kod_raks, 6 ) )
        Do While raks->kod_raks == raksh->kod_raks .and. !Eof()
          s := raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
          If raksh->REFREASON > 0 .and. !emptyall( s, raksh->penalty )
            Select TMP
            For i := 1 To 2
              lsmo := { Space( 5 ), raks->plat }[ i ]
              For k := 1 To 2
                lrefr := { 0, raksh->REFREASON }[ k ]
                find ( lsmo + Str( lrefr, 3 ) )
                If !Found()
                  Append Blank
                  tmp->REFREASON := lrefr
                  tmp->smo := lsmo
                Endif
                If !Empty( s )
                  tmp->kol++
                  tmp->summa += s
                Endif
                If vid_eks == 2 .or. !Empty( raksh->SANK_EKMP )
                  tmp->kol3++
                  tmp->summa3 += s
                Elseif vid_eks == 1 .or. !Empty( raksh->SANK_MEE )
                  tmp->kol2++
                  tmp->summa2 += s
                Else
                  tmp->kol1++
                  tmp->summa1 += s
                Endif
                If !Empty( raksh->penalty )
                  tmp->kol4++
                  tmp->summa4 += raksh->penalty
                Endif
              Next k
            Next i
          Endif
          Select RAKSH
          Skip
        Enddo
        Select RAKS
        Skip
      Enddo
      Select RAK
      Skip
    Enddo
  Else
    r_use( dir_server + 'mo_XML', , 'MO_XML' )
    Select RAK
    Set Relation To kod_xml into MO_XML
    Index On DToS( dakt ) to ( cur_dir + 'tmprak' ) For Between( mo_xml->dfile, arr_m[ 5 ], arr_m[ 6 ] )
    Go Top
    Do While !Eof()
      @ MaxRow(), 0 Say PadR( date_8( rak->dakt ), 80 ) Color 'W/R'
      vid_eks := ret_vid_eks()
      Select RAKS
      find ( Str( rak->akt, 6 ) )
      Do While rak->akt == raks->akt .and. !Eof()
        Select RAKSH
        find ( Str( raks->kod_raks, 6 ) )
        Do While raks->kod_raks == raksh->kod_raks .and. !Eof()
          s := raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
          If raksh->REFREASON > 0 .and. !emptyall( s, raksh->penalty )
            Select TMP
            For i := 1 To 2
              lsmo := { Space( 5 ), raks->plat }[ i ]
              For k := 1 To 2
                lrefr := { 0, raksh->REFREASON }[ k ]
                find ( lsmo + Str( lrefr, 3 ) )
                If !Found()
                  Append Blank
                  tmp->REFREASON := lrefr
                  tmp->smo := lsmo
                Endif
                If !Empty( s )
                  tmp->kol++
                  tmp->summa += s
                Endif
                If vid_eks == 2 .or. !Empty( raksh->SANK_EKMP )
                  tmp->kol3++
                  tmp->summa3 += s
                Elseif vid_eks == 1 .or. !Empty( raksh->SANK_MEE )
                  tmp->kol2++
                  tmp->summa2 += s
                Else
                  tmp->kol1++
                  tmp->summa1 += s
                Endif
                If !Empty( raksh->penalty )
                  tmp->kol4++
                  tmp->summa4 += raksh->penalty
                Endif
              Next k
            Next i
          Endif
          Select RAKSH
          Skip
        Enddo
        Select RAKS
        Skip
      Enddo
      Select RAK
      Skip
    Enddo
  Endif
  arr_title := { ;
    '________________________________________________________________________________________________', ;
    '  код       |кол-во|сумма отказа |______________________в_том_числе_____________________________', ;
    '  нарушения |нару- |в оплате руб.|________МЭК_________|________МЭЭ_________|________ЭКМП________', ;
    '            |шений |             |кол-во| сумма снятий|кол-во| сумма снятий|кол-во| сумма снятий', ;
    '____________|______|_____________|наруш_|_____________|наруш_|_____________|наруш_|_____________' }
  sh := Len( arr_title[ 1 ] )
  //
  fp := FCreate( n_file )
  n_list := 1
  tek_stroke := 0
  add_string( glob_mo[ _MO_SHORT_NAME ] )
  add_string( '' )
  add_string( Center( 'Структура нарушений по результатам контроля объемов, сроков, качества и условий', sh ) )
  add_string( Center( 'предоставления медицинской помощи по обязательному медицинскому страхованию', sh ) )
  If TIP == 1
    add_string( Center( 'даты актов контроля - ' + arr_m[ 4 ], sh ) )
  Else
    add_string( Center( 'даты РЕЕСТРОВ АКТОВ КОНТРОЛЯ - ' + arr_m[ 4 ], sh ) )
  Endif
  AEval( arr_title, {| x| add_string( x ) } )
  // R_Use(dir_exe() + '_mo_t005', cur_dir + '_mo_t005', 'T5')
  Select TMP
  Go Top
  Do While !Eof()
    If tmp->REFREASON == 0
      tmp->srefr := 'Итого'
    Else
//      retT005 := retarr_t005( tmp->REFREASON, .t. )
      retT005 := retarr_f014( tmp->REFREASON, .t. )
      If ! Empty( retT005 )
        s := AllTrim( retT005[ 2 ] )
        s1 := ''
        For i := 1 To Len( s )
          If isletter( SubStr( s, i, 1 ) )
            Exit
          Endif
          s1 += SubStr( s, i, 1 )
        Next
        tmp->srefr := s1
      Endif
      // select T5
      // find (str(tmp->REFREASON, 3))
      // if found()
      // s := alltrim(t5->name)
      // s1 := ""
      // for i := 1 to len(s)
      // if ISLETTER(substr(s,i, 1))
      // exit
      // endif
      // s1 += substr(s,i, 1)
      // next
      // tmp->srefr := s1
      // endif
    Endif
    Select TMP
    Skip
  Enddo
  Index On smo + Str( iif( Empty( REFREASON ), 999, REFREASON ), 3 ) to ( cur_dir + 'tmp' )
  For i := 1 To Len( arr_smo )
    arr_smo[ i, 2 ] := PadR( lstr( arr_smo[ i, 2 ] ), 5 )
  Next
  AAdd( arr_smo, { 'Всего', Space( 5 ), 1 } )
  For i := 1 To Len( arr_smo )
    Select TMP
    find ( arr_smo[ i, 2 ] )
    If Found()
      If verify_ff( HH -3, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( '' )
      add_string( Center( arr_smo[ i, 1 ], sh ) )
      add_string( Center( Replicate( '~', Len( arr_smo[ i, 1 ] ) + 2 ), sh ) )
      Do While tmp->smo == arr_smo[ i, 2 ] .and. !Eof()
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        If tmp->REFREASON == 0
          add_string( Replicate( '-', sh ) )
        Endif
        add_string( PadR( tmp->srefr, 13 ) + Str( tmp->kol, 6 ) + put_kop( tmp->summa, 14 ) + ;
          put_val( tmp->kol1, 7 ) + put_kope( tmp->summa1, 14 ) + ;
          put_val( tmp->kol2, 7 ) + put_kope( tmp->summa2, 14 ) + ;
          put_val( tmp->kol3, 7 ) + put_kope( tmp->summa3, 14 ) )
        If tmp->kol4 > 0
          add_string( PadR( '  кроме того, штрафы', 11 + 6 + 14 ) + put_val( tmp->kol4, 7 ) + put_kope( tmp->summa4, 14 ) )
        Endif
        Select TMP
        Skip
      Enddo
    Endif
  Next
  FClose( fp )
  Close databases
  rest_box( buf )
  Private yes_albom := .t.
  viewtext( n_file, , , , .t., , , 1 )

  Return Nil

// 28.10.2315 список снятий по актам (дефекты)
Function akt_list_of_refusal_defect()

  Static arr_smo
  Static mm_poisk := { { "По дате РАК (XML-файла)", 0 }, ;
    { "По дате акта контроля ", 1 }, ;
    { "По дате СЧЁТА ", 2 } }
  Static mm_akt := { { "отдельно по каждому акту   ", 0 }, ;
    { "объединять акты (как счета)", 1 } }
  Static mm_schet := { { "отдельно по каждому счёту      ", 0 }, ;
    { "объединять по отчётному периоду", 1 }, ;
    { "объединять все счета           ", 2 } }
  Static mm_eks := { { "все ", 0 }, { "МЭК ", 1 }, { "МЭЭ ", 2 }, { "ЭКМП", 3 } }
  Static s1poisk := 1, s1schet := 0, s1akt := 0, s1eks := 0, s1smo := 0
  Local buf := SaveScreen(), i, ar, s, r := 14

  If arr_smo == NIL
    arr_smo := mo_cut_menu( glob_arr_smo )
    For i := 1 To Len( arr_smo )
      arr_smo[ i, 3 ] := PadR( lstr( arr_smo[ i, 2 ] ), 5 )
      arr_smo[ i, 2 ] := i
    Next
  Endif
  If Empty( s1smo )
    s1smo := 0
    For i := 1 To Len( arr_smo )
      s1smo := SetBit( s1smo, arr_smo[ i, 2 ] )
    Next
  Endif
  Private mdate := Space( 10 ), m1date := 0, ;
    mpoisk, m1poisk := s1poisk, ;
    mschet, m1schet := s1schet, ;
    msmo, m1smo := s1smo, ;
    meks, m1eks := s1eks, ;
    makt, m1akt := s1akt
  Private pdate, gl_arr := { ;  // для битовых полей
    { "smo", "N", 10, 0, , , , {| x| inieditspr( A__MENUBIT, arr_smo, x ) } };
    }
  mpoisk := inieditspr( A__MENUVERT, mm_poisk, m1poisk )
  mschet := inieditspr( A__MENUVERT, mm_schet, m1schet )
  meks   := inieditspr( A__MENUVERT, mm_eks,   m1eks  )
  makt   := inieditspr( A__MENUVERT, mm_akt,   m1akt  )
  msmo   := inieditspr( A__MENUBIT,  arr_smo,  m1smo  )
  SetColor( cDataCGet )
  myclear( r )
  Private gl_area := { r, 1, MaxRow() -1, MaxCol(), 0 }, pdate
  status_key( "^<Esc>^ - выход;  ^<PgDn>^ - составление документа" )
  //
  @ r, 0 To MaxRow() -1, MaxCol() Color color8
  str_center( r, " Список снятий по актам (подготовка информации) ", color14 )
  Do While .t.
    @ r + 2, 2 Say "Страховая(ые) компания(и)" Get msmo ;
      reader {| x| menu_reader( x, arr_smo, A__MENUBIT, , , .f. ) }
    @ r + 3, 2 Say "Как подсчитывать (РАК/акты/СЧЁТ)" Get mpoisk ;
      reader {| x| menu_reader( x, mm_poisk, A__MENUVERT, , , .f. ) }
    @ r + 4, 2 Say "Период времени" Get mdate ;
      reader {| x| menu_reader( x, { {| k, r, c| ;
      k := year_month( r + 1, c ), iif( k == nil, nil, ( pdate := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
      k } }, A__FUNCTION, , , .f. ) }
    @ r + 5, 2 Say "Вид экспертизы" Get meks ;
      reader {| x| menu_reader( x, mm_eks, A__MENUVERT, , , .f. ) }
    @ r + 6, 2 Say "Информация по счетам" Get mschet ;
      reader {| x| menu_reader( x, mm_schet, A__MENUVERT, , , .f. ) }
    @ r + 7, 2 Say "Информация по актам" Get makt ;
      reader {| x| menu_reader( x, mm_akt, A__MENUVERT, , , .f. ) }
    myread()
    If LastKey() == K_ESC
      Exit
    Endif
    s1smo   := m1smo
    s1schet := m1schet
    s1poisk := m1poisk
    s1akt   := m1akt
    s1eks   := m1eks
    If Empty( pdate )
      func_error( 4, "Не введён период времени" )
    Elseif Empty( m1smo )
      func_error( 4, "Не введена страховая компания" )
    Else
      ar := {}
      s := ""
      For i := 1 To Len( arr_smo )
        If IsBit( s1smo, i )
          AAdd( ar, arr_smo[ i, 3 ] )
          s += arr_smo[ i, 1 ] + ", "
        Endif
      Next
      s := SubStr( s, 1, Len( s ) -2 )
      f1akt_list_of_refusal_defect( ar, s )
    Endif
  Enddo
  RestScreen( buf )

  Return Nil

// 31.01.25 функция для списка снятий по актам (дефекты)
Function f1akt_list_of_refusal_defect( asmo, ssmo )

  Local adbf, s, otch_period, n_file := cur_dir + 'sp_sn' + stxt, HH := 60, buf := save_maxrow()

  mywait()
  adbf := { { "nrak", "C", 26, 0 }, ;
    { "drak", "D", 8, 0 }, ;
    { "rak", "N", 6, 0 }, ;
    { "srak", "C", 50, 0 }, ;
    { "nakt", "C", 26, 0 }, ;
    { "dakt", "D", 8, 0 }, ;
    { "akt", "N", 6, 0 }, ;
    { "sakt", "C", 50, 0 }, ;
    { "op", "C", 6, 0 }, ;
    { "sop", "C", 50, 0 }, ;
    { "nschet", "C", 15, 0 }, ;
    { "dschet", "D", 8, 0 }, ;
    { "schet", "N", 6, 0 }, ;
    { "ssch", "C", 50, 0 }, ;
    { "otd", "N", 3, 0 }, ;
    { "kol", "N", 6, 0 }, ;
    { "sum_sn", "N", 15, 2 }, ;
    { "kolp", "N", 6, 0 }, ;
    { "penalty", "N", 15, 2 }, ;
    { "REFREASON", "N", 3, 0 } }
  dbCreate( cur_dir + "tmp", adbf )
  Use ( cur_dir + "tmp" ) new
  r_use( dir_server + "schet_", , "SCHET_" )
  r_use( dir_server + "mo_otd", , "OTD" )
  r_use( dir_server + "human", , "HUMAN" )
  r_use( dir_server + "mo_raksh", , "RAKSH" )
  Index On Str( kod_raks, 6 ) To tmpraksh memory
  r_use( dir_server + "mo_raks", , "RAKS" )
  Index On Str( akt, 6 ) To tmpraks memory
  r_use( dir_server + "mo_rak", , "RAK" )
  Index On Str( kod_xml, 6 ) + DToS( dakt ) + nakt To tmprak memory
  r_use( dir_server + "mo_xml", , "MO_XML" )
  Index On dfile To tmp_xml For TIP_IN == _XML_FILE_RAK memory
  Go Top
  // доработка - если
  Do While !Eof()
    If iif( m1poisk == 0, Between( mo_xml->DFILE, pdate[ 5 ], pdate[ 6 ] ), .t. )
      Select RAK
      find ( Str( mo_xml->kod, 6 ) )
      Do While mo_xml->kod == rak->kod_xml .and. !Eof()
        If iif( m1poisk == 1, Between( rak->dakt, pdate[ 5 ], pdate[ 6 ] ), .t. )
          vid_eks := ret_vid_eks()
          Select RAKS
          find ( Str( rak->akt, 6 ) )
          Do While rak->akt == raks->akt .and. !Eof()
            If AScan( asmo, raks->plat ) > 0
              schet_->( dbGoto( raks->schet ) )
              If iif( m1poisk == 2, Between( schet_->dschet, pdate[ 5 ], pdate[ 6 ] ), .t. )
                otch_period := Str( schet_->NYEAR, 4 ) + StrZero( schet_->NMONTH, 2 )
                Select RAKSH
                find ( Str( raks->kod_raks, 6 ) )
                Do While raks->kod_raks == raksh->kod_raks .and. !Eof()
                  human->( dbGoto( raksh->KOD_H ) )
                  s := raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
                  ssh := raksh->penalty
                  fl := .f.
                  If m1eks == 0
                    fl := .t.
                  Elseif vid_eks == 2 .or. !Empty( raksh->SANK_EKMP )
                    fl := ( m1eks == 3 )
                  Elseif vid_eks == 1 .or. !Empty( raksh->SANK_MEE )
                    fl := ( m1eks == 2 )
                  Else
                    fl := ( m1eks == 1 )
                  Endif
                  If !fl
                    s := ssh := 0
                  Endif
                  If raksh->REFREASON > 0 .and. !emptyall( s, ssh )
                    Select TMP
                    Append Blank
                    tmp->nrak := AllTrim( mo_xml->FNAME )
                    tmp->drak := mo_xml->DFILE
                    tmp->rak := mo_xml->kod
                    tmp->nakt := AllTrim( rak->nakt )
                    tmp->dakt := rak->dakt
                    tmp->akt := rak->akt
                    tmp->nschet := AllTrim( schet_->nschet )
                    tmp->dschet := schet_->dschet
                    tmp->schet := raks->KOD_RAKS
                    tmp->op := otch_period
                    tmp->sum_sn := s
                    tmp->penalty := ssh
                    tmp->REFREASON := raksh->REFREASON
                    tmp->otd := human->otd
                  Endif
                  Select RAKSH
                  Skip
                Enddo
              Endif
            Endif
            Select RAKS
            Skip
          Enddo
        Endif
        Select RAK
        Skip
      Enddo
    Endif
    Select MO_XML
    Skip
  Enddo
  //
  dbCreate( cur_dir + "tmp1", adbf )
  Use ( cur_dir + "tmp1" ) new
  Index On Str( rak, 6 ) + Str( akt, 6 ) + op + Str( schet, 6 ) + Str( otd, 3 ) + Str( REFREASON, 3 ) to ( cur_dir + "tmp1" )
  old_rak := old_akt := old_schet := -1
  old_op := Space( 18 )
  Select TMP
  Go Top
  Do While !Eof()
    lrak := iif( m1poisk == 0, tmp->rak, 0 )
    lakt := tmp->akt
    lschet := tmp->schet
    lop := Space( 6 )
    If m1schet == 0 // отдельно по каждому счёту
      lakt := tmp->akt
    Elseif m1schet == 1 // объединять по отчётному периоду
      lop := tmp->op
      lschet := 0
      If m1akt == 0 // отдельно по каждому акту
      Else          // объединять акты (как счета)
        lakt := 0
      Endif
    Else // объединять все счета
      lschet := 0
      If m1akt == 0 // отдельно по каждому акту
      Else          // объединять акты (как счета)
        lakt := 0
      Endif
    Endif
    Select TMP1
    find ( Str( lrak, 6 ) + Str( lakt, 6 ) + lop + Str( lschet, 6 ) + Str( tmp->otd, 3 ) + Str( tmp->REFREASON, 3 ) )
    If !Found()
      Append Blank
      tmp1->rak := lrak
      tmp1->akt := lakt
      tmp1->op := lop
      tmp1->schet := lschet
      If m1poisk == 0 .and. !( old_rak == lrak )
        tmp1->srak := "РАК: " + RTrim( tmp->nrak ) + " от " + date_8( tmp->drak )
        old_rak := lrak
      Endif
      If m1schet == 0  // отдельно по каждому счёту
        If m1akt == 0 .and. !( old_akt == lakt ) // отдельно по каждому акту
          tmp1->sakt := RTrim( tmp->nakt ) + ", " + date_8( tmp->dakt )
          old_akt := lakt
        Endif
        If !( old_schet == lschet )
          tmp1->ssch := RTrim( tmp->nschet ) + ", " + date_8( tmp->dschet )
          old_schet := lschet
        Endif
      Elseif m1schet == 1 // объединять по отчётному периоду
        If m1akt == 0 .and. !( old_akt == lakt ) // отдельно по каждому акту
          tmp1->sakt := RTrim( tmp->nakt ) + ", " + date_8( tmp->dakt )
          old_akt := lakt
        Endif
        If !( old_op == Str( lrak, 6 ) + Str( lakt, 6 ) + lop )
          tmp1->sop := mm_month[ Int( Val( SubStr( tmp1->op, 5 ) ) ) ] + " " + Left( tmp1->op, 4 ) + " года"
          old_op := Str( lrak, 6 ) + Str( lakt, 6 ) + lop
        Endif
      Else // объединять все счета
        If m1akt == 0 .and. !( old_akt == lakt ) // отдельно по каждому акту
          tmp1->sakt := RTrim( tmp->nakt ) + ", " + date_8( tmp->dakt )
          old_akt := lakt
        Endif
      Endif
      tmp1->REFREASON := tmp->REFREASON
      tmp1->otd := tmp->otd
    Endif
    If !Empty( tmp->sum_sn )
      tmp1->kol++
      tmp1->sum_sn += tmp->sum_sn
    Endif
    If !Empty( tmp->penalty )
      tmp1->kolp++
      tmp1->penalty += tmp->penalty
    Endif
    Select TMP
    Skip
  Enddo
 // 
  arr_title := { ;
    "_______________________________________________________________________________", ;
    " № акта, дата       | Проверяемый счёт   |кол-во|  Сумма      |  Коды    |Отде-", ;
    "                    |                    |снятий|  снятий     |  снятий  |ление", ;
    "____________________|____________________|______|_____________|__________|_____" }
  sh := Len( arr_title[ 1 ] )
  //
  fp := FCreate( n_file )
  n_list := 1
  tek_stroke := 0
  add_string( glob_mo[ _MO_SHORT_NAME ] )
  add_string( "" )
  add_string( Center( "Снятия по экспертизам", sh ) )
  add_string( Center( "Вид экспертизы: " + meks, sh ) )
  add_string( Center( "СМО: " + ssmo, sh ) )
  add_string( Center( "даты " + iif( m1poisk == 0, "РАК - ", "актов контроля - " ) + pdate[ 4 ], sh ) )
  AEval( arr_title, {| x| add_string( x ) } )
  // R_Use(dir_exe() + '_mo_t005', cur_dir + '_mo_t005', 'T5')
  ssum := skol := sum_rak := kol_rak := 0
  n := 20
  ssump := skolp := sump_rak := kolp_rak := 0
  Select TMP1
  Set Order To 0
  Go Top
  Do While !Eof()
    If !Empty( tmp1->srak )
      If !Empty( kol_rak )
        add_string( Space( n ) + Replicate( "-", n * 2 + 3 ) )
        add_string( PadL( "Итого по РАК:", 41 ) + Str( kol_rak, 7 ) + Str( sum_rak, 14, 2 ) )
        If !Empty( kolp_rak )
          add_string( Space( 41 ) + Str( kolp_rak, 7 ) + Str( sump_rak, 14, 2 ) + "(штраф)" )
        Endif
        sum_rak := kol_rak := 0
        sump_rak := kolp_rak := 0
      Endif
      add_string( "" )
      add_string( PadC( AllTrim( tmp1->srak ), sh, "_" ) )
    Endif
    s1 := lstr( tmp1->REFREASON )
//    retT005 := retarr_t005( tmp1->REFREASON, .t. )
    retT005 := retarr_f014( tmp1->REFREASON, .t. )
    If ! Empty( retT005 )
      s1 := ""
      s2 := LTrim( retT005[ 2 ] )
      For i := 1 To Len( s2 )
        If isletter( SubStr( s2, i, 1 ) )
          Exit
        Endif
        s1 += SubStr( s2, i, 1 )
      Next
    Endif
    if  Empty( s1 )
      s1 := lstr( tmp1->REFREASON )
    endif  
    // select T5
    // find (str(tmp1->REFREASON, 3))
    // if found()
    // s1 := "" ; s2 := ltrim(t5->name)
    // for i := 1 to len(s2)
    // if ISLETTER(substr(s2,i, 1))
    // exit
    // endif
    // s1 += substr(s2,i, 1)
    // next
    // endif
    If Empty( tmp1->sakt )
      s := Space( n )
    Else
      s := PadR( tmp1->sakt, n )
    Endif
    s += " "
    If Empty( tmp1->ssch )
      s += PadR( tmp1->sop, n )
    Else
      s += PadR( tmp1->ssch, n )
    Endif
    s += put_val( tmp1->kol, 7 ) + Str( tmp1->sum_sn, 14, 2 ) + " " + PadR( CharRem( " ", s1 ), 11 )
    skol += tmp1->kol
    ssum += tmp1->sum_sn
    If m1poisk == 0
      kol_rak += tmp1->kol
      sum_rak += tmp1->sum_sn
    Endif
    otd->( dbGoto( tmp1->otd ) )
    If Empty( otd->short_name )
      s += otd->name
    Else
      s += otd->short_name
    Endif
    If verify_ff( HH -3, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    add_string( s )
    If !Empty( tmp1->penalty )
      add_string( Space( 41 ) + Str( tmp1->kolp, 7 ) + Str( tmp1->penalty, 14, 2 ) + "(штраф)" )
      skolp += tmp1->kolp
      ssump += tmp1->penalty
      If m1poisk == 0
        kolp_rak += tmp1->kolp
        sump_rak += tmp1->penalty
      Endif
    Endif
    Select TMP1
    Skip
  Enddo
  If !Empty( kol_rak )
    add_string( Space( n ) + Replicate( "-", n * 2 + 3 ) )
    add_string( PadL( "Итого по РАК:", 41 ) + Str( kol_rak, 7 ) + Str( sum_rak, 14, 2 ) )
    If !Empty( kolp_rak )
      add_string( Space( 41 ) + Str( kolp_rak, 7 ) + Str( sump_rak, 14, 2 ) + "(штраф)" )
    Endif
  Endif
  add_string( Replicate( "-", sh ) )
  add_string( PadL( "Всего:", 41 ) + Str( skol, 7 ) + Str( ssum, 14, 2 ) )
  If !Empty( skolp )
    add_string( Space( 41 ) + Str( skolp, 7 ) + Str( ssump, 14, 2 ) + "(штраф)" )
  Endif
  FClose( fp )
  Close databases
  rest_box( buf )
  viewtext( n_file, , , , .t., , , 2 )

  Return Nil

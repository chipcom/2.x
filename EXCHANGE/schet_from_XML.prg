// **** счета с 2019 года
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 29.09.25 создать счета по результатам прочитанного реестра СП
Function create_schet19_from_xml( arr_XML_info, aerr, fl_msg, arr_s, name_sp_tk )

  Local arr_schet := {}, c, i, j, lbukva, ;
    mnn, fl, name_zip, arr_zip := {}, lshifr1, ;
    CODE_LPU := glob_mo[ _MO_KOD_TFOMS ], code_schet, mb, me, nsh, ;
    CODE_MO  := glob_mo[ _MO_KOD_FFOMS ], s1
  Local controlVer
  Local tmpSelect
  Local ushifr
  local dPUMPver40 := 0d20240301
  local sVersion
  local old_lek, old_sh
  local oZAP, oPAC, oDISAB, oSLUCH, oPRESCRIPTION, oPRESCRIPTIONS, oD
  local oSl, oOnk, oProt, oDiag, oNAPR, oKSG, oSLk, oOnk_sl, oCONS, oLek, oINJ
  local dEndZsl // дата окончания случая
  local oXmlDoc, oXmlNode

  Default fl_msg To .t., arr_s TO {}
  Private pole
  //
  Use ( cur_dir() + 'tmp1file' ) New Alias TMP1
  mdate_schet := tmp1->_DSCHET
  nsh := f_mb_me_nsh( tmp1->_year, @mb, @me )
  // составляем массив будущих счетов
  // открыть распакованный реестр
  Use ( cur_dir() + 'tmp_r_t1' ) New index ( cur_dir() + 'tmpt1' ) Alias T1
  Use ( cur_dir() + 'tmp_r_t2' ) New index ( cur_dir() + 'tmpt2' ) Alias T2
  Use ( cur_dir() + 'tmp_r_t3' ) New index ( cur_dir() + 'tmpt3' ) Alias T3
  Use ( cur_dir() + 'tmp_r_t4' ) New index ( cur_dir() + 'tmpt4' ) Alias T4
  Use ( cur_dir() + 'tmp_r_t5' ) New index ( cur_dir() + 'tmpt5' ) Alias T5
  Use ( cur_dir() + 'tmp_r_t6' ) New index ( cur_dir() + 'tmpt6' ) Alias T6
  Use ( cur_dir() + 'tmp_r_t7' ) New index ( cur_dir() + 'tmpt7' ) Alias T7
  Use ( cur_dir() + 'tmp_r_t8' ) New index ( cur_dir() + 'tmpt8' ) Alias T8
  Use ( cur_dir() + 'tmp_r_t9' ) New index ( cur_dir() + 'tmpt9' ) Alias T9
  Use ( cur_dir() + 'tmp_r_t10' ) New index ( cur_dir() + 'tmpt10' ) Alias T10
  Use ( cur_dir() + 'tmp_r_t11' ) New index ( cur_dir() + 'tmpt11' ) Alias T11
  Use ( cur_dir() + 'tmp_r_t12' ) New index ( cur_dir() + 'tmpt12' ) Alias T12
  Use ( cur_dir() + 'tmp_r_t1_1' ) New index ( cur_dir() + 'tmpt1_1' ) Alias T1_1
  r_use( dir_server() + 'mo_pers', , 'PERS' )
  r_use( dir_server() + 'mo_otd', , 'OTD' )
  r_use( dir_server() + 'uslugi', , 'USL' )
  r_use( dir_server() + 'kartote_', , 'KART_' )
  r_use( dir_server() + 'kartotek', , 'KART' )
  Set Relation To RecNo() into KART_
  g_use( dir_server() + 'human_u_', , 'HU_' )
  r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
  Set Relation To RecNo() into HU_, To u_kod into USL
  r_use( dir_server() + 'mo_su', , 'MOSU' )
  g_use( dir_server() + 'mo_hu', dir_server() + 'mo_hu', 'MOHU' )
  Set Relation To u_kod into MOSU
  g_use( dir_server() + 'mo_xml', , 'MO_XML' )
  g_use( dir_server() + 'human_3', { dir_server() + 'human_3', dir_server() + 'human_32' }, 'HUMAN_3' )
  use_base( 'human' )
  Set Order To 0
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2, To kod_k into KART
  Use ( cur_dir() + 'tmp2file' ) New Alias TMP2
  Index On Upper( fio ) to ( cur_dir() + 'tmp2' ) For _OPLATA == 1
  Go Top
  Do While !Eof()
    c := ' '
    lal := 'HUMAN'
    dbSelectArea( lal )
    Goto ( tmp2->kod_human )
    If human->ishod == 88
      lal += '_3'
      dbSelectArea( lal )
      Set Order To 1
      find ( Str( tmp2->kod_human, 7 ) )
    Elseif human->ishod == 89
      lal += '_3'
      dbSelectArea( lal )
      Set Order To 2
      find ( Str( tmp2->kod_human, 7 ) )
    Endif
    Select HU
    find ( Str( human->kod, 7 ) )
    Do While hu->kod == human->kod .and. !Eof()
      lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
      lbukva := ' '
      If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data, , @lbukva )
        lshifr1 := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
        If hu->STOIM_1 > 0 .or. Left( lshifr1, 3 ) == '71.' .or. Left( lshifr1, 5 ) == '2.5.2'  // скорая помощь и постановка онко пациентов на дисп. набл.
          If !Empty( lbukva )
            c := lbukva
            Exit
          Endif
        Endif
      Endif
      Select HU
      Skip
    Enddo
    If Type( 'pr_array_schet' ) == 'A' .and. Empty( c )
      c := 'A'   // искусственно для экспорта из чужих БД случаев с отсутствующими услугами
    Endif
    If Empty( c )
      s := AllTrim( human->fio ) + ' - не найдена буква счёта'
      AAdd( aerr, s )
      Close databases
      Return func_error( 4, s )
    Else
      tmp2->SCHET_CHAR := c
    Endif
    If ( i := AScan( arr_schet, {| x| x[ 1 ] == tmp2->_SMO .and. x[ 2 ] == tmp2->SCHET_CHAR } ) ) == 0
      AAdd( arr_schet, { tmp2->_SMO, tmp2->SCHET_CHAR, 0, 0, 0, 0, 0, 0, 0, 0 } )
      i := Len( arr_schet )
    Endif
    arr_schet[ i, 3 ] ++
    arr_schet[ i, 4 ] += &lal.->cena_1
    arr_schet[ i, 8 ] := 0 // сюда запишем код счёта
    arr_schet[ i, 9 ] := 0 // сюда запишем номер пакета
    arr_schet[ i, 10 ] := 0 // сюда запишем индекс массива pr_array_schet
    tmp2->SCHET_ZAP := arr_schet[ i, 3 ]
    tmp2->SCHET := i
    //
    Select TMP2
    Skip
  Enddo
  If Type( 'pr_array_schet' ) == 'A'
    For ii := 1 To Len( arr_schet )
      fl := .f.
      mn_schet := AllTrim( arr_schet[ ii, 1 ] ) + '-' + AllTrim( tmp1->_NSCHET ) + arr_schet[ ii, 2 ]
      If ( i := AScan( pr_array_schet, {| x| AllTrim( x[ 3 ] ) == mn_schet .and. x[ 6 ] == tmp1->_year } ) ) > 0
        arr_schet[ ii, 9 ] := pr_array_schet[ i, 2 ] // сюда запишем номер пакета
        arr_schet[ ii, 10 ] := i
      Endif
      If arr_schet[ ii, 10 ] == 0
        my_debug(, lstr( tmp1->_year ) + '/' + StrZero( tmp1->_month, 2 ) + ' не найден счёт ' + mn_schet )
      Else
        i := arr_schet[ ii, 10 ]
        s := lstr( tmp1->_year ) + '/' + StrZero( tmp1->_month, 2 ) + ' ' + PadR( mn_schet, 15 )
        s += 'max: ' + lstr( pr_array_schet[ i, 8 ] )
        If pr_array_schet[ i, 8 ] == arr_schet[ ii, 3 ]
          s += ' = '
          s1 := '+'
        Else
          s += ' != '
          s1 := '-'
          fl := .t.
        Endif
        s += lstr( arr_schet[ ii, 3 ] ) + ', кол: ' + lstr( pr_array_schet[ i, 7 ] )
        If pr_array_schet[ i, 7 ] == arr_schet[ ii, 3 ]
          s += ' = '
          s1 += '+'
        Else
          s += ' != '
          s1 += '-'
          fl := .t.
        Endif
        s += lstr( arr_schet[ ii, 3 ] ) + ', сум: ' + lstr( pr_array_schet[ i, 5 ], 13, 2 )
        If Round( pr_array_schet[ i, 5 ], 2 ) == Round( arr_schet[ ii, 4 ], 2 )
          s += ' = '
          s1 += '+'
        Else
          s += ' != '
          s1 += '-'
          fl := .t.
        Endif
        s += lstr( arr_schet[ ii, 4 ], 13, 2 )
        my_debug(, s1 + s )
      Endif
      If arr_schet[ ii, 10 ] > 0 // счёт найден в 'pr_array_schet'
        i := arr_schet[ ii, 10 ]
        arr_schet[ ii, 3 ] := arr_schet[ ii, 4 ] := 0
        Select TMP2
        Index On Upper( _ID_C ) to ( cur_dir() + 'tmp2' ) For schet == ii
        dbEval( {|| tmp2->SCHET_ZAP := 0 } ) // обнуляем номер позиции в счёте
        Use ( cur_dir() + 'tmp_s_id' ) New Alias TS
        Index On NIDCASE to ( cur_dir() + 'tmp_ts' ) For kod == pr_array_schet[ i, 11 ]
        Go Top
        Do While !Eof()
          Select TMP2
          find ( Upper( ts->ID_C ) )
          If Found()
            tmp2->SCHET_ZAP := ts->NIDCASE
            human->( dbGoto( tmp2->kod_human ) )
            arr_schet[ ii, 3 ] ++
            arr_schet[ ii, 4 ] += human->cena_1 // потом исправим при спасении кого-нибудь
          Else
            my_debug(, 'в счёте не найден пациент с GUID ' + ts->ID_C )
            my_debug(, '└─>' + print_array( pr_array_schet[ i ] ) )
          Endif
          Select TS
          Skip
        Enddo
        ts->( dbCloseArea() )
        If fl .or. !( pr_array_schet[ i, 8 ] == arr_schet[ ii, 3 ] .and. ;
            pr_array_schet[ i, 7 ] == arr_schet[ ii, 3 ] .and. ;
            Round( pr_array_schet[ i, 5 ], 2 ) == Round( arr_schet[ ii, 4 ], 2 ) )
          If fl
            my_debug(, 'после исправления:' )
          Else
            my_debug(, 'что-то случилось:' )
          Endif
          s := lstr( tmp1->_year ) + '/' + StrZero( tmp1->_month, 2 ) + ' ' + PadR( mn_schet, 15 )
          s += 'max: ' + lstr( pr_array_schet[ i, 8 ] )
          If pr_array_schet[ i, 8 ] == arr_schet[ ii, 3 ]
            s += ' = '
            s1 := '+'
          Else
            s += ' != '
            s1 := '-'
          Endif
          s += lstr( arr_schet[ ii, 3 ] ) + ', кол: ' + lstr( pr_array_schet[ i, 7 ] )
          If pr_array_schet[ i, 7 ] == arr_schet[ ii, 3 ]
            s += ' = '
            s1 += '+'
          Else
            s += ' != '
            s1 += '-'
          Endif
          s += lstr( arr_schet[ ii, 3 ] ) + ', сум: ' + lstr( pr_array_schet[ i, 5 ], 13, 2 )
          If Round( pr_array_schet[ i, 5 ], 2 ) == Round( arr_schet[ ii, 4 ], 2 )
            s += ' = '
            s1 += '+'
          Else
            s += ' != '
            s1 += '-'
          Endif
          s += lstr( arr_schet[ ii, 4 ], 13, 2 )
          my_debug(, s1 + s )
        Endif
      Endif
    Next
  Endif
  r_use( dir_server() + 'schet_',, 'SCH' )
  Index On smo + Str( nn, nsh ) to ( cur_dir() + 'tmp_sch' ) For nyear == tmp1->_YEAR .and. nmonth == tmp1->_MONTH
  fl := .f.
  For i := 1 To Len( arr_schet )
    fl := .f. ; sKodSMO := arr_schet[ i, 1 ]
    If arr_schet[ i, 9 ] > 0
      find ( sKodSMO + Str( arr_schet[ i, 9 ], nsh ) )
      If Found() // номер уже занят
        arr_schet[ i, 9 ] := 0
      Endif
    Endif
    fl := ( arr_schet[ i, 9 ] > 0 )
    If !fl
      For mnn := mb To me
        If AScan( arr_schet, {| x| x[ 1 ] == sKodSMO .and. x[ 9 ] == mnn } ) == 0
          find ( sKodSMO + Str( mnn, nsh ) )
          If !Found() // нашли свободный номер
            fl := .t.
            arr_schet[ i, 9 ] := mnn
            Exit
          Endif
        Endif
      Next
    Endif
    If !fl
      Exit
    Endif
  Next
  If !fl
    Close databases
    s := 'Не удалось найти свободный номер пакета в ТФОМС. Проверьте настройки!'
    AAdd( aerr, s )
    Return func_error( 4, s )
  Endif
  sch->( dbCloseArea() )
  use_base( 'schet' )
  Set Relation To
  // определим дату счёта, чтобы она не была раньше даты чтения реестра в ТФОМС
  mdate_schet := Max( mdate_schet, sys_date )
  StrFile( Space( 10 ) + 'Список составленных счетов:' + hb_eol(), cFileProtokol, .t. )
  Select TMP2
  Index On Str( schet, 6 ) + Str( schet_zap, 6 ) to ( cur_dir() + 'tmp2' ) For schet_zap > 0
  For ii := 1 To Len( arr_schet )
    mnn := arr_schet[ ii, 9 ]
    sKodSMO := AllTrim( arr_schet[ ii, 1 ] )
    s := 'M' + CODE_LPU + iif( sKodSMO == '34', 'T', 'S' ) + sKodSMO + '_' + ;
      Right( StrZero( tmp1->_YEAR, 4 ), 2 ) + StrZero( tmp1->_MONTH, 2 ) + ;
      StrZero( mnn, nsh )
    mn_schet := sKodSMO + '-' + AllTrim( tmp1->_NSCHET ) + arr_schet[ ii, 2 ]
    stat_msg( 'Составление реестра случаев по счёту № ' + mn_schet )
    //
    c := Upper( Left( name_sp_tk, 1 ) ) // {'H', 'F'}[p_tip_reestr]+s
    p_tip_reestr := iif( c == 'H', 1, 2 )
    Select SCHET
    addrec( 6 )
    arr_schet[ ii, 8 ] := mkod := RecNo()
    schet->KOD := mkod
    schet->NOMER_S := mn_schet
    AAdd( arr_s, mn_schet )
    schet->PDATE := dtoc4( mdate_schet )
    schet->KOL   := arr_schet[ ii, 3 ]
    schet->SUMMA := arr_schet[ ii, 4 ]
    schet->KOL_OST   := arr_schet[ ii, 3 ]
    schet->SUMMA_OST := arr_schet[ ii, 4 ]
    //
    Select SCHET_
    Do While schet_->( LastRec() ) < mkod
      Append Blank
    Enddo
    Goto ( mkod )
    g_rlock( forever )
    schet_->IFIN       := 1 // источник финансирования;1-ТФОМС(СМО)
    schet_->IS_MODERN  := 0 // является модернизацией, 0-нет
    schet_->IS_DOPLATA := 0 // является доплатой;0-нет
    schet_->BUKVA      := arr_schet[ ii, 2 ]
    schet_->NSCHET     := mn_schet
    schet_->DSCHET     := mdate_schet
    schet_->SMO        := sKodSMO
    schet_->NYEAR      := tmp1->_YEAR
    schet_->NMONTH     := tmp1->_MONTH
    schet_->NN         := mnn
    schet_->NAME_XML   := c + s // {'H', 'F'}[p_tip_reestr]+s
    schet_->XML_REESTR := mXML_REESTR
    schet_->NREGISTR   := 1 // ещё не зарегистрирован
    schet_->CODE := ret_unique_code( mkod, 12 )
    code_schet := schet_->code
    //
    Select MO_XML
    addrecn()
    mo_xml->KOD    := RecNo()
    mo_xml->FNAME  := c + s
    mo_xml->FNAME2 := 'L' + s
    mo_xml->DFILE  := schet_->DSCHET
    mo_xml->TFILE  := hour_min( Seconds() )
    mo_xml->TIP_OUT := _XML_FILE_SCHET  // тип высылаемого файла;2-счет
    mo_xml->SCHET   := mkod  // код счета (отсылаемого или обработанного СМО)
    //
    schet_->KOD_XML := mo_xml->KOD
    Unlock
    //
    StrFile( lstr( ii ) + '. ' + mn_schet + ' от ' + date_8( mdate_schet ) + ' (' + ;
      lstr( arr_schet[ ii, 3 ] ) + ' чел.) ' + ;
      inieditspr( A__MENUVERT, glob_arr_smo, Int( Val( sKodSMO ) ) ) + ;
      hb_eol(), cFileProtokol, .t. )
    //
    oXmlDoc := hxmldoc():new()
    oXmlDoc:add( hxmlnode():new( 'ZL_LIST' ) )
    oXmlNode := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'ZGLV' ) )

    sVersion := '3.11'
    controlVer := tmp1->_YEAR * 100 + tmp1->_MONTH
    if p_tip_reestr == 1
      // файла реестра случаев первого типа при формировании счета ОМС
      If ( controlVer >= 202201 ) // с января 2022 года
        sVersion := '3.2'
      Endif
      If ( controlVer >= 202403 ) // с марта 2024 года
        sVersion := '4.0'
      Endif
      If ( controlVer >= 202501 ) // с января 2025 года
        sVersion := '5.0'
      Endif
      If ( controlVer >= 202507 ) // с июля 2025 года
        sVersion := '5.1'
      Endif
    elseif p_tip_reestr == 2
      // файла реестра случаев второго типа при формировании счета ОМС
      If ( controlVer >= 202501 ) // с января 2025 года
        sVersion := '5.0'
      Endif
    endif
  
    mo_add_xml_stroke( oXmlNode, 'VERSION', sVersion )
    mo_add_xml_stroke( oXmlNode, 'DATA', date2xml( schet_->DSCHET ) )
    mo_add_xml_stroke( oXmlNode, 'FILENAME', mo_xml->FNAME )
    mo_add_xml_stroke( oXmlNode, 'SD_Z', lstr( arr_schet[ ii, 3 ] ) ) // новое поле
    oXmlNode := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'SCHET' ) )
    mo_add_xml_stroke( oXmlNode, 'CODE', lstr( code_schet ) )
    mo_add_xml_stroke( oXmlNode, 'CODE_MO', CODE_MO )
    mo_add_xml_stroke( oXmlNode, 'YEAR', lstr( tmp1->_YEAR ) )
    mo_add_xml_stroke( oXmlNode, 'MONTH', lstr( tmp1->_MONTH ) )
    mo_add_xml_stroke( oXmlNode, 'NSCHET', mn_schet )
    mo_add_xml_stroke( oXmlNode, 'DSCHET', date2xml( schet_->DSCHET ) )
    mo_add_xml_stroke( oXmlNode, 'PLAT', schet_->SMO )
    mo_add_xml_stroke( oXmlNode, 'SUMMAV', Str( schet->SUMMA, 15, 2 ) )
    // запись номера счета по больным
    iidserv := 0
    Select TMP2
    find ( Str( ii, 6 ) )
    Do While tmp2->schet == ii .and. !Eof()
      @ MaxRow(), 0 Say Str( tmp2->schet_zap / arr_schet[ ii, 3 ] * 100, 6, 2 ) + '%' Color cColorSt2Msg
      //
      Select T1
      find ( Str( tmp2->_N_ZAP, 6 ) )
      If Found() // нашли в отосланном реестре
        kol_sl := iif( Int( Val( t1->VB_P ) ) == 1, 2, 1 )
        For isl := 1 To kol_sl
          Select HUMAN
          Goto ( tmp2->kod_human )
          If isl == 1 .and. kol_sl == 2
            fl := .f.
            Select HUMAN_3
            If human->ishod == 88
              Set Order To 1
            Else
              Set Order To 2
            Endif
            find ( Str( tmp2->kod_human, 7 ) )
            human_3->( g_rlock( forever ) )
            human_3->schet := mkod
            human_3->schet_zap := tmp2->schet_zap
            If human_3->SCHET_NUM < 99
              human_3->SCHET_NUM := human_3->SCHET_NUM + 1
            Endif
            Unlock
            Select HUMAN
            Goto ( human_3->kod )  // встали на 1-й лист учёта
          Endif
          Select HUMAN
          If isl == 2
            Goto ( human_3->kod2 )  // встали на 2-ой лист учёта
          Endif
          human->( g_rlock( forever ) )
          human->schet := mkod ; human->tip_h := B_SCHET
          human_->( g_rlock( forever ) )
          human_->schet_zap := tmp2->schet_zap
          If human_->SCHET_NUM < 99
            human_->SCHET_NUM := human_->SCHET_NUM + 1
          Endif
          Unlock
          a_usl := {}
          Select HU
          find ( Str( human->kod, 7 ) )
          Do While hu->kod == human->kod .and. !Eof()
            If is_usluga_tfoms( usl->shifr, opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ), human->k_data )
              AAdd( a_usl, { hu->( RecNo() ), hu_->REES_ZAP } )
            Endif
            Select HU
            Skip
          Enddo
          a_fusl := {}
          Select MOHU
          find ( Str( human->kod, 7 ) )
          Do While mohu->kod == human->kod .and. !Eof()
            AAdd( a_fusl, { mohu->( RecNo() ), mohu->REES_ZAP } )
            Skip
          Enddo
          If isl == 1
            oZAP := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'ZAP' ) )
            mo_add_xml_stroke( oZAP, 'N_ZAP', lstr( human_->schet_zap ) )
            mo_add_xml_stroke( oZAP, 'PR_NOV', t1->PR_NOV )
            oPAC := oZAP:add( hxmlnode():new( 'PACIENT' ) )
            mo_add_xml_stroke( oPAC, 'ID_PAC', t1->ID_PAC )
            mo_add_xml_stroke( oPAC, 'VPOLIS', t1->VPOLIS )
            If !Empty( t1->SPOLIS )
              mo_add_xml_stroke( oPAC, 'SPOLIS', t1->SPOLIS )
            Endif
            mo_add_xml_stroke( oPAC, 'NPOLIS', t1->NPOLIS )
            If !Empty( t1->ENP )
              mo_add_xml_stroke( oPAC, 'ENP', t1->ENP )
            Endif
            // mo_add_xml_stroke(oPAC, 'ST_OKATO' ,...) // Регион страхования
            If !Empty( t1->smo )
              mo_add_xml_stroke( oPAC, 'SMO', t1->smo )
            Endif
            mo_add_xml_stroke( oPAC, 'SMO_OK', t1->SMO_OK )
            If !Empty( t1->SMO_NAM )
              mo_add_xml_stroke( oPAC, 'SMO_NAM', t1->SMO_NAM )
            Endif
            mo_add_xml_stroke( oPAC, 'NOVOR', t1->NOVOR )
            
            if ( p_tip_reestr == 2 ) .and. xml2date( t1->DATE_Z_2 ) >= 0d20250101
              mo_add_xml_stroke( oPAC, 'SOC', t1->SOC )
            endif

            mo_add_xml_stroke( oPAC, 'MO_PR', t1->MO_PR )
            If !Empty( t1->VNOV_D )
              mo_add_xml_stroke( oPAC, 'VNOV_D', t1->VNOV_D )
            Endif

            if ( p_tip_reestr == 1 ) .and. xml2date( t1->DATE_Z_2 ) >= 0d20250101
              mo_add_xml_stroke( oPAC, 'SOC', t1->SOC )
            endif

            If !Empty( t1->INV ) // Сведения о первичном признании застрахованного лица инвалидом
              oDISAB := oPAC:add( hxmlnode():new( 'DISABILITY' ) )
              mo_add_xml_stroke( oDISAB, 'INV', t1->INV )
              mo_add_xml_stroke( oDISAB, 'DATA_INV', t1->DATA_INV )
              mo_add_xml_stroke( oDISAB, 'REASON_INV', t1->REASON_INV )
              If !Empty( t1->DS_INV )
                mo_add_xml_stroke( oDISAB, 'DS_INV', t1->DS_INV )
              Endif
            Endif
            oSLUCH := oZAP:add( hxmlnode():new( 'Z_SL' ) )
            mo_add_xml_stroke( oSLUCH, 'IDCASE', lstr( human_->schet_zap ) )
            mo_add_xml_stroke( oSLUCH, 'ID_C', t1->ID_C )
            If !Empty( t1->DISP )
              mo_add_xml_stroke( oSLUCH, 'DISP', t1->DISP ) // Тип диспансеризации
            Endif
            mo_add_xml_stroke( oSLUCH, 'USL_OK', t1->USL_OK )
            mo_add_xml_stroke( oSLUCH, 'VIDPOM', t1->VIDPOM )
            If p_tip_reestr == 1
              mo_add_xml_stroke( oSLUCH, 'ISHOD', t1->ISHOD )
              If !Empty( t1->VB_P )
                mo_add_xml_stroke( oSLUCH, 'VB_P', t1->VB_P ) // Признак внутрибольничного перевода при оплате законченного случая как суммы стоимостей пребывания пациента в разных профильных отделениях, каждое из которых оплачивается по КСГ
              Endif
              mo_add_xml_stroke( oSLUCH, 'IDSP', t1->IDSP )
              mo_add_xml_stroke( oSLUCH, 'SUMV', t1->sumv )
              If !Empty( t1->FOR_POM )
                mo_add_xml_stroke( oSLUCH, 'FOR_POM', t1->FOR_POM )
              Endif
              If !Empty( t1->NPR_MO )
                mo_add_xml_stroke( oSLUCH, 'NPR_MO', t1->NPR_MO )
              Endif
              If !Empty( t1->NPR_DATE )
                mo_add_xml_stroke( oSLUCH, 'NPR_DATE', t1->NPR_DATE )
              Endif
              mo_add_xml_stroke( oSLUCH, 'LPU', t1->LPU )
            Else
              If !Empty( t1->FOR_POM )
                mo_add_xml_stroke( oSLUCH, 'FOR_POM', t1->FOR_POM )
              Endif
              mo_add_xml_stroke( oSLUCH, 'LPU', t1->LPU )
              mo_add_xml_stroke( oSLUCH, 'VBR', t1->VBR )
              mo_add_xml_stroke( oSLUCH, 'P_CEL', t1->p_cel )
              mo_add_xml_stroke( oSLUCH, 'P_OTK', t1->p_otk ) // Признак отказа
            Endif
            mo_add_xml_stroke( oSLUCH, 'DATE_Z_1', t1->DATE_Z_1 )
            mo_add_xml_stroke( oSLUCH, 'DATE_Z_2', t1->DATE_Z_2 )
            If !Empty( t1->kd_z )
              mo_add_xml_stroke( oSLUCH, 'KD_Z', t1->kd_z ) // Указывается количество койко-дней для стационара, количество пациенто-дней для дневного стационара
            Endif
            For j := 1 To 3
              pole := 't1->VNOV_M' + iif( j == 1, '', '_' + lstr( j ) )
              If !Empty( &pole )
                mo_add_xml_stroke( oSLUCH, 'VNOV_M', &pole )
              Endif
            Next
            mo_add_xml_stroke( oSLUCH, 'RSLT', t1->RSLT )
            If p_tip_reestr == 1
              If !Empty( t1->MSE )
                mo_add_xml_stroke( oSLUCH, 'MSE', t1->MSE )
              Endif
            Else
              mo_add_xml_stroke( oSLUCH, 'ISHOD', t1->ISHOD )
              mo_add_xml_stroke( oSLUCH, 'IDSP', t1->IDSP )
              mo_add_xml_stroke( oSLUCH, 'SUMV', t1->sumv )
            Endif
            lal := 't1'
          Else
            lal := 't1_1'
            dbSelectArea( lal )
            find ( t1->IDCASE )
          Endif
          oSL := oSLUCH:add( hxmlnode():new( 'SL' ) )
          mo_add_xml_stroke( oSL, 'SL_ID', &lal.->SL_ID )
          If !Empty( &lal.->VID_HMP )
            mo_add_xml_stroke( oSL, 'VID_HMP', &lal.->VID_HMP )
          Endif
          If !Empty( &lal.->METOD_HMP )
            mo_add_xml_stroke( oSL, 'METOD_HMP', &lal.->METOD_HMP )
          Endif
          If !Empty( &lal.->LPU_1 )
            mo_add_xml_stroke( oSL, 'LPU_1', &lal.->LPU_1 )
          Endif
          If !Empty( &lal.->PODR )
            mo_add_xml_stroke( oSL, 'PODR', &lal.->PODR )
          Endif
          mo_add_xml_stroke( oSL, 'PROFIL', &lal.->PROFIL )
          If p_tip_reestr == 1
            If !Empty( &lal.->PROFIL_K )
              mo_add_xml_stroke( oSL, 'PROFIL_K', &lal.->PROFIL_K )
            Endif
            If !Empty( &lal.->DET )
              mo_add_xml_stroke( oSL, 'DET', &lal.->DET )
            Endif
            If !Empty( &lal.->P_CEL )
              mo_add_xml_stroke( oSL, 'P_CEL', &lal.->P_CEL )
            Endif
          Endif
          If !Empty( &lal.->TAL_D )
            mo_add_xml_stroke( oSL, 'TAL_D', &lal.->TAL_D )
            mo_add_xml_stroke( oSL, 'TAL_P', &lal.->TAL_P )
            If !Empty( &lal.->TAL_NUM )
              mo_add_xml_stroke( oSL, 'TAL_NUM', &lal.->TAL_NUM )
            Endif
          Endif
          mo_add_xml_stroke( oSL, 'NHISTORY', &lal.->NHISTORY )
          If !Empty( &lal.->P_PER )
            mo_add_xml_stroke( oSL, 'P_PER', &lal.->P_PER )
          Endif
          mo_add_xml_stroke( oSL, 'DATE_1', &lal.->DATE_1 )
          mo_add_xml_stroke( oSL, 'DATE_2', &lal.->DATE_2 )
          If !Empty( &lal.->kd )
            mo_add_xml_stroke( oSL, 'KD', &lal.->kd ) // Указывается количество койко-дней для стационара, количество пациенто-дней для дневного стационара
          Endif

          If ! Empty( &lal.->WEI ) .and. p_tip_reestr == 1  // по новым правилам ПУМП от 11.01.22
            mo_add_xml_stroke( oSL, 'WEI', &lal.->WEI )
          Endif

          If !Empty( &lal.->DS0 )
            mo_add_xml_stroke( oSL, 'DS0', &lal.->DS0 )
          Endif
          mo_add_xml_stroke( oSL, 'DS1', &lal.->DS1 )
          If p_tip_reestr == 2
            If !Empty( &lal.->DS1_PR )
              mo_add_xml_stroke( oSL, 'DS1_PR', &lal.->DS1_PR )
            Endif
            If !Empty( &lal.->PR_D_N )
              mo_add_xml_stroke( oSL, 'PR_D_N', &lal.->PR_D_N )
            Endif
          Endif
          If p_tip_reestr == 1
            For j := 1 To 7
              pole := lal + '->DS2' + iif( j == 1, '', '_' + lstr( j ) )
              If !Empty( &pole )
                mo_add_xml_stroke( oSL, 'DS2', &pole )
              Endif
            Next
            For j := 1 To 3
              pole := lal + '->DS3' + iif( j == 1, '', '_' + lstr( j ) )
              If !Empty( &pole )
                mo_add_xml_stroke( oSL, 'DS3', &pole )
              Endif
            Next
            If !Empty( &lal.->C_ZAB )
              mo_add_xml_stroke( oSL, 'C_ZAB', &lal.->C_ZAB )
            Endif
            If !Empty( &lal.->DS_ONK )
              mo_add_xml_stroke( oSL, 'DS_ONK', &lal.->DS_ONK )
            Endif
            If !Empty( &lal.->DN )
              mo_add_xml_stroke( oSL, 'DN', &lal.->DN )
            Endif
          Else // диспансеризация
            For j1 := 1 To 4
              pole := lal + '->DS2N' + iif( j1 == 1, '', '_' + lstr( j1 ) )
              If !Empty( &pole )
                oD := oSL:add( hxmlnode():new( 'DS2_N' ) )
                mo_add_xml_stroke( oD, 'DS2', &pole )
                pole := lal + '->DS2N' + iif( j1 == 1, '', '_' + lstr( j1 ) ) + '_PR'
                If !Empty( &pole )
                  mo_add_xml_stroke( oD, 'DS2_PR', &pole )
                Endif
                pole := lal + '->DS2N' + iif( j1 == 1, '', '_' + lstr( j1 ) ) + '_D'
                If !Empty( &pole )
                  mo_add_xml_stroke( oD, 'PR_D', &pole )
                Endif
              Endif
            Next
            mo_add_xml_stroke( oSL, 'DS_ONK', &lal.->DS_ONK )
            Select T5
            find ( t1->IDCASE + Str( isl, 6 ) )
            If Found()
              oPRESCRIPTION := oSL:add( hxmlnode():new( 'PRESCRIPTION' ) )
              Do While t1->IDCASE == t5->IDCASE .and. isl == t5->sluch .and. !Eof()
                oPRESCRIPTIONS := oPRESCRIPTION:add( hxmlnode():new( 'PRESCRIPTIONS' ) )
                If !Empty( t5->NAZ_N )
                  mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_N', t5->NAZ_N )
                Endif
                If !Empty( t5->NAZ_R )
                  mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_R', t5->NAZ_R )
                Endif

                // добавил по новому ПУМП от 02.08.2021
                If !Empty( t5->NAZ_IDDT )
                  mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_IDDOKT', t5->NAZ_IDDT )
                Endif
                If !Empty( t5->NAZ_SPDT )
                  mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_SPDOCT', t5->NAZ_SPDT )
                Endif

                If !Empty( t5->NAZR )
                  mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZR', t5->nazr )
                Endif
                If !Empty( t5->NAZ_SP )
                  mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_SP', t5->NAZ_SP )
                Endif
              /*for i := 1 to 3
                pole := 't5->NAZ_SP'+lstr(i)
                if !empty(&pole)
                  mo_add_xml_stroke(oPRESCRIPTIONS, 'NAZ_SP', &pole)
                endif
              next*/
                If !Empty( t5->NAZ_V )
                  mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_V', t5->NAZ_V )
                Endif
              /*for i := 1 to 3
                pole := 't5->NAZ_V'+lstr(i)
                if !empty(&pole)
                  mo_add_xml_stroke(oPRESCRIPTIONS, 'NAZ_V', &pole)
                endif
              next*/
                If !Empty( t5->naz_usl )
                  mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_USL', t5->naz_usl )
                Endif
                If !Empty( t5->NAPR_DATE )
                  mo_add_xml_stroke( oPRESCRIPTIONS, 'NAPR_DATE', t5->NAPR_DATE )
                  mo_add_xml_stroke( oPRESCRIPTIONS, 'NAPR_MO', t5->NAPR_MO )
                Endif
                If !Empty( t5->NAZ_PMP )
                  mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_PMP', t5->NAZ_PMP )
                Endif
                If !Empty( t5->NAZ_PK )
                  mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_PK', t5->NAZ_PK )
                Endif
                Select T5
                Skip
              Enddo
            Endif
          Endif
          If !Empty( &lal.->n_ksg )
            oKSG := oSL:add( hxmlnode():new( 'KSG_KPG' ) )
            mo_add_xml_stroke( oKSG, 'N_KSG', &lal.->n_ksg )
            
            if xml2date( t1->DATE_Z_2 ) >= dPUMPver40 // дата окончания случая после 01.03.24
              mo_add_xml_stroke( oKSG, 'K_ZP', '1' )  // пока ставим 1
            endif

            If !Empty( &lal.->crit )
              mo_add_xml_stroke( oKSG, 'CRIT', &lal.->crit )
            Endif
            If !Empty( &lal.->crit2 )
              mo_add_xml_stroke( oKSG, 'CRIT', &lal.->crit2 )
            Endif
            mo_add_xml_stroke( oKSG, 'SL_K', &lal.->sl_k )
            If !Empty( &lal.->IT_SL )
              mo_add_xml_stroke( oKSG, 'IT_SL', &lal.->IT_SL )
              If !Empty( &lal.->kod_kslp )
                oSLk := oKSG:add( hxmlnode():new( 'SL_KOEF' ) )
                mo_add_xml_stroke( oSLk, 'ID_SL', &lal.->kod_kslp )
                mo_add_xml_stroke( oSLk, 'VAL_C', &lal.->koef_kslp )
              Endif
              If !Empty( &lal.->kod_kslp2 )
                oSLk := oKSG:add( hxmlnode():new( 'SL_KOEF' ) )
                mo_add_xml_stroke( oSLk, 'ID_SL', &lal.->kod_kslp2 )
                mo_add_xml_stroke( oSLk, 'VAL_C', &lal.->koef_kslp2 )
              Endif
              If !Empty( &lal.->kod_kslp3 )
                oSLk := oKSG:add( hxmlnode():new( 'SL_KOEF' ) )
                mo_add_xml_stroke( oSLk, 'ID_SL', &lal.->kod_kslp3 )
                mo_add_xml_stroke( oSLk, 'VAL_C', &lal.->koef_kslp3 )
              Endif
            Endif
            If !Empty( &lal.->CODE_KIRO )
              oSLk := oKSG:add( hxmlnode():new( 'S_KIRO' ) )
              mo_add_xml_stroke( oSLk, 'CODE_KIRO', &lal.->CODE_KIRO )
              mo_add_xml_stroke( oSLk, 'VAL_K', &lal.->VAL_K )
            Endif
          Elseif !Empty( &lal.->CODE_MES1 )
            mo_add_xml_stroke( oSL, 'CODE_MES1', &lal.->CODE_MES1 )
          Endif
          //
          Select T6
          find ( t1->IDCASE + Str( isl, 6 ) )
          Do While t1->IDCASE == t6->IDCASE .and. isl == t6->sluch .and. !Eof()
            oNAPR := oSL:add( hxmlnode():new( 'NAPR' ) )

            // добавил по новому ПУМП от 02.08.2021
            If !Empty( t5->NAZ_IDDT )
              mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_IDDOKT', t6->NAZ_IDDT )
            Endif
            If !Empty( t5->NAZ_SPDT )
              mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_SPDOCT', t6->NAZ_SPDT )
            Endif

            mo_add_xml_stroke( oNAPR, 'NAPR_DATE', t6->NAPR_DATE )
            If !Empty( t6->NAPR_MO )
              mo_add_xml_stroke( oNAPR, 'NAPR_MO', t6->NAPR_MO )
            Endif
            mo_add_xml_stroke( oNAPR, 'NAPR_V', t6->NAPR_V )
            If Int( Val( t6->NAPR_V ) ) == 3
              mo_add_xml_stroke( oNAPR, 'MET_ISSL', t6->MET_ISSL )
              mo_add_xml_stroke( oNAPR, 'NAPR_USL', t6->U_KOD )
            Endif
            Skip
          Enddo
          If !Empty( &lal.->PR_CONS )
            oCONS := oSL:add( hxmlnode():new( 'CONS' ) ) // консилиумов м.б.несколько (но у нас один)
            mo_add_xml_stroke( oCONS, 'PR_CONS', &lal.->PR_CONS )
            If !Empty( &lal.->DT_CONS )
              mo_add_xml_stroke( oCONS, 'DT_CONS', &lal.->DT_CONS )
            Endif
          Endif
          If !Empty( &lal.->DS1_T )
            oONK_SL := oSL:add( hxmlnode():new( 'ONK_SL' ) )
            mo_add_xml_stroke( oONK_SL, 'DS1_T', &lal.->DS1_T )
            If !Empty( &lal.->STAD )
              mo_add_xml_stroke( oONK_SL, 'STAD', &lal.->STAD )
            Endif
            If !Empty( &lal.->ONK_T )
              mo_add_xml_stroke( oONK_SL, 'ONK_T', &lal.->ONK_T )
            Endif
            If !Empty( &lal.->ONK_N )
              mo_add_xml_stroke( oONK_SL, 'ONK_N', &lal.->ONK_N )
            Endif
            If !Empty( &lal.->ONK_M )
              mo_add_xml_stroke( oONK_SL, 'ONK_M', &lal.->ONK_M )
            Endif
            If !Empty( &lal.->MTSTZ )
              mo_add_xml_stroke( oONK_SL, 'MTSTZ', &lal.->MTSTZ )
            Endif
            If !Empty( &lal.->SOD )
              mo_add_xml_stroke( oONK_SL, 'SOD', &lal.->SOD )
            Endif
            If !Empty( t1->K_FR )
              mo_add_xml_stroke( oONK_SL, 'K_FR', t1->K_FR )
            Endif
            If !Empty( &lal.->WEI )
              mo_add_xml_stroke( oONK_SL, 'WEI', &lal.->WEI )
            Endif
            If !Empty( &lal.->HEI )
              mo_add_xml_stroke( oONK_SL, 'HEI', &lal.->HEI )
            Endif
            If !Empty( &lal.->BSA )
              mo_add_xml_stroke( oONK_SL, 'BSA', &lal.->BSA )
            Endif
            Select T7
            find ( t1->IDCASE + Str( isl, 6 ) )
            Do While t1->IDCASE == t7->IDCASE .and. isl == t7->sluch .and. !Eof()
              oDIAG := oONK_SL:add( hxmlnode():new( 'B_DIAG' ) )
              mo_add_xml_stroke( oDIAG, 'DIAG_DATE', t7->DIAG_DATE )
              mo_add_xml_stroke( oDIAG, 'DIAG_TIP',  t7->DIAG_TIP )
              mo_add_xml_stroke( oDIAG, 'DIAG_CODE', t7->DIAG_CODE )
              If !Empty( t7->DIAG_RSLT )
                mo_add_xml_stroke( oDIAG, 'DIAG_RSLT', t7->DIAG_RSLT )
              Endif
              If !Empty( t7->REC_RSLT )
                mo_add_xml_stroke( oDIAG, 'REC_RSLT', t7->REC_RSLT )
              Endif
              Skip
            Enddo
            Select T8
            find ( t1->IDCASE + Str( isl, 6 ) )
            Do While t1->IDCASE == t8->IDCASE .and. isl == t8->sluch .and. !Eof()
              oPROT := oONK_SL:add( hxmlnode():new( 'B_PROT' ) )
              mo_add_xml_stroke( oPROT, 'PROT', t8->PROT )
              mo_add_xml_stroke( oPROT, 'D_PROT', t8->D_PROT )
              Skip
            Enddo
            Select T9
            find ( t1->IDCASE + Str( isl, 6 ) )
            Do While t1->IDCASE == t9->IDCASE .and. isl == t9->sluch .and. !Eof()
              oONK := oONK_SL:add( hxmlnode():new( 'ONK_USL' ) )
              mo_add_xml_stroke( oONK, 'USL_TIP', t9->USL_TIP )
              If !Empty( t9->HIR_TIP )
                mo_add_xml_stroke( oONK, 'HIR_TIP', t9->HIR_TIP )
              Endif
              If !Empty( t9->LEK_TIP_L )
                mo_add_xml_stroke( oONK, 'LEK_TIP_L', t9->LEK_TIP_L )
              Endif
              If !Empty( t9->LEK_TIP_V )
                mo_add_xml_stroke( oONK, 'LEK_TIP_V', t9->LEK_TIP_V )
              Endif
              If !Empty( t9->LUCH_TIP )
                mo_add_xml_stroke( oONK, 'LUCH_TIP', t9->LUCH_TIP )
              Endif
              If eq_any( Int( Val( t9->USL_TIP ) ), 2, 4 )
                dEndZsl := xml2date( t1->DATE_Z_2 )
                old_lek := Space( 6 )
                old_sh := Space( 10 )
                // цикл по БД лекарств
                Select T10
                find ( t1->IDCASE + Str( isl, 6 ) )
                Do While t1->IDCASE == t10->IDCASE .and. isl == t10->sluch .and. !Eof()
                  If !( old_lek == t10->REGNUM .and. old_sh == t10->CODE_SH )
                    oLEK := oONK:add( hxmlnode():new( 'LEK_PR' ) )
                    mo_add_xml_stroke( oLEK, 'REGNUM', t10->REGNUM )
                    if dEndZsl >= 0d20250101
                      mo_add_xml_stroke( oLEK, 'REGNUM_DOP', t10->REGNUM_DOP )
                    endif
                    mo_add_xml_stroke( oLEK, 'CODE_SH', t10->CODE_SH )
                  Endif
                  // цикл по датам приёма данного лекарства
                  if dEndZsl >= 0d20250101
                    oINJ := oLEK:add( hxmlnode():new( 'INJ' ) )
                    mo_add_xml_stroke( oINJ, 'DATE_INJ', t10->DATE_INJ )
                    mo_add_xml_stroke( oINJ, 'KV_INJ', t10->KV_INJ )
                    mo_add_xml_stroke( oINJ, 'KIZ_INJ', t10->KIZ_INJ )
                    mo_add_xml_stroke( oINJ, 'S_INJ', t10->S_INJ )
                    mo_add_xml_stroke( oINJ, 'SV_INJ', t10->SV_INJ )
                    mo_add_xml_stroke( oINJ, 'SIZ_INJ', t10->SIZ_INJ )
                    mo_add_xml_stroke( oINJ, 'RED_INJ', t10->RED_INJ )
                  else
                    mo_add_xml_stroke( oLEK, 'DATE_INJ', t10->DATE_INJ )
                  endif
                  old_lek := t10->REGNUM
                  old_sh := t10->CODE_SH
//                    If !( old_lek == t10->REGNUM .and. old_sh == t10->CODE_SH )
//                      oLEK := oONK:add( hxmlnode():new( 'LEK_PR' ) )
//                      mo_add_xml_stroke( oLEK, 'REGNUM', t10->REGNUM )
//                      mo_add_xml_stroke( oLEK, 'CODE_SH', t10->CODE_SH )
//                    Endif
//                    // цикл по датам приёма данного лекарства
//                    mo_add_xml_stroke( oLEK, 'DATE_INJ', t10->DATE_INJ )
//                    old_lek := t10->REGNUM
//                    old_sh := t10->CODE_SH
                  Select T10
                  Skip
                Enddo
                If !Empty( t9->PPTR )
                  mo_add_xml_stroke( oONK, 'PPTR', t9->PPTR )
                Endif
              Endif
              Select T9
              Skip
            Enddo
          Endif
          If p_tip_reestr == 1
            mo_add_xml_stroke( oSL, 'PRVS', &lal.->PRVS )
            If !Empty( &lal.->IDDOKT )
              mo_add_xml_stroke( oSL, 'IDDOKT', &lal.->IDDOKT )
            Endif
            If !Empty( &lal.->ED_COL )
              mo_add_xml_stroke( oSL, 'ED_COL', &lal.->ED_COL )
              mo_add_xml_stroke( oSL, 'TARIF', &lal.->TARIF )
            Endif
            mo_add_xml_stroke( oSL, 'SUM_M', &lal.->SUM_M )
            // ///////////// insert LEK_PR
            // цикл по БД лекарств
            Select T11
            find ( t1->IDCASE + Str( isl, 6 ) )
            Do While t1->IDCASE == t11->IDCASE .and. isl == t11->sluch .and. !Eof()
              oLEK := oSL:add( hxmlnode():new( 'LEK_PR' ) )
              mo_add_xml_stroke( oLEK, 'DATA_INJ', t11->DATA_INJ )
              mo_add_xml_stroke( oLEK, 'CODE_SH', AllTrim( t11->CODE_SH ) )
              If ! Empty( t11->REGNUM )
                mo_add_xml_stroke( oLEK, 'REGNUM', t11->REGNUM )
                // mo_add_xml_stroke(oLEK, 'CODE_MARK', '')  // для дальнейшего использования
                oDOSE := oLEK:add( hxmlnode():new( 'LEK_DOSE' ) )
                mo_add_xml_stroke( oDOSE, 'ED_IZM', t11->ED_IZM )
                mo_add_xml_stroke( oDOSE, 'DOSE_INJ', t11->DOSE_INJ )
                mo_add_xml_stroke( oDOSE, 'METHOD_INJ', t11->METHOD_I )
                mo_add_xml_stroke( oDOSE, 'COL_INJ', t11->COL_INJ )
              Endif
              Select T11
              Skip
            Enddo
            // /////////////

            If !Empty( &lal.->NEXT_VISIT )
              mo_add_xml_stroke( oSL, 'NEXT_VISIT', &lal.->NEXT_VISIT )
            Endif
            If !Empty( &lal.->COMENTSL )
              mo_add_xml_stroke( oSL, 'COMENTSL', &lal.->COMENTSL )
            Endif
          Else
            If !Empty( &lal.->ED_COL )
              mo_add_xml_stroke( oSL, 'ED_COL', &lal.->ED_COL )
            Endif
            mo_add_xml_stroke( oSL, 'PRVS', &lal.->PRVS )
            If !Empty( &lal.->TARIF )
              mo_add_xml_stroke( oSL, 'TARIF', &lal.->TARIF )
            Endif
            mo_add_xml_stroke( oSL, 'SUM_M', &lal.->SUM_M )
          Endif
          Select T2
          find ( t1->IDCASE + Str( isl, 6 ) )
          Do While t1->IDCASE == t2->IDCASE .and. isl == t2->sluch .and. !Eof()
            ++iidserv
            If ( j := AScan( a_fusl, {| x| x[ 2 ] == Int( Val( t2->IDSERV ) ) } ) ) > 0
              Select MOHU
              Goto ( a_fusl[ j, 1 ] )
              mohu->( g_rlock( forever ) )
              mohu->SCHET_ZAP := iidserv
              Unlock
            Else
              j := AScan( a_usl, {| x| x[ 2 ] == Int( Val( t2->IDSERV ) ) } )
              If Between( j, 1, Len( a_usl ) )
                Select HU
                Goto ( a_usl[ j, 1 ] )
                hu_->( g_rlock( forever ) )
                hu_->SCHET_ZAP := iidserv
                Unlock
              Endif
            Endif
            oUSL := oSL:add( hxmlnode():new( 'USL' ) )
            mo_add_xml_stroke( oUSL, 'IDSERV',t2->IDSERV )
            mo_add_xml_stroke( oUSL, 'ID_U',t2->ID_U )
            mo_add_xml_stroke( oUSL, 'LPU',t2->LPU )
            If !Empty( t2->LPU_1 )
              mo_add_xml_stroke( oUSL, 'LPU_1',t2->LPU_1 )
            Endif
            If !Empty( t2->PODR )
              mo_add_xml_stroke( oUSL, 'PODR',t2->PODR )
            Endif
            mo_add_xml_stroke( oUSL, 'PROFIL',t2->PROFIL )
            If !Empty( t2->VID_VME )
              mo_add_xml_stroke( oUSL, 'VID_VME', t2->VID_VME )
            Endif
            If !Empty( t2->DET )
              mo_add_xml_stroke( oUSL, 'DET',t2->DET )
            Endif
            mo_add_xml_stroke( oUSL, 'DATE_IN',t2->DATE_IN )
            mo_add_xml_stroke( oUSL, 'DATE_OUT', t2->DATE_OUT )
            If !Empty( t2->DS )
              mo_add_xml_stroke( oUSL, 'DS',t2->DS )
            Endif
            If !Empty( t2->P_OTK )
              mo_add_xml_stroke( oUSL, 'P_OTK',t2->P_OTK )
            Endif
            ushifr := AllTrim( t2->CODE_USL )
            mo_add_xml_stroke( oUSL, 'CODE_USL', t2->CODE_USL )
            mo_add_xml_stroke( oUSL, 'KOL_USL',t2->KOL_USL )
            mo_add_xml_stroke( oUSL, 'TARIF',t2->TARIF )
            mo_add_xml_stroke( oUSL, 'SUMV_USL', t2->SUMV_USL )

            If p_tip_reestr == 1 .and. ( xml2date( t1->DATE_Z_2 ) >= 0d20220101 ) // добавил по новому ПУМП от 18.01.22
              // имплантант
              tmpSelect := Select()
              Select T12
              find ( t1->IDCASE + Str( isl, 6 ) )
              Do While t1->IDCASE == t12->IDCASE .and. isl == t12->sluch .and. ushifr == AllTrim( t12->CODE_USL ) .and. !Eof()
                oIMPLANT := oUSL:add( hxmlnode():new( 'MED_DEV' ) )
                mo_add_xml_stroke( oIMPLANT, 'DATE_MED', T12->DATE_MED )
                mo_add_xml_stroke( oIMPLANT, 'CODE_MEDDEV', T12->CODE_DEV )
                mo_add_xml_stroke( oIMPLANT, 'NUMBER_SER', T12->NUM_SER )
                Skip
              Enddo
              Select( tmpSelect )
            Endif

            // добавил по новому ПУМП от 02.08.2021
            If p_tip_reestr == 2 .and. ( xml2date( t1->DATE_Z_2 ) >= 0d20210801 )
              If !Empty( t2->PRVS ) .and. !Empty( t2->CODE_MD ) // после разговора с Л.Н.Антоновой 18.08.2021
                oMR_USL_N := oUSL:add( hxmlnode():new( 'MR_USL_N' ) )
                mo_add_xml_stroke( oMR_USL_N, 'MR_N', lstr( 1 ) )
                mo_add_xml_stroke( oMR_USL_N, 'PRVS', t2->PRVS )
                mo_add_xml_stroke( oMR_USL_N, 'CODE_MD', t2->CODE_MD )
              Endif
              // добавил по новому ПУМП от 04-18-02 от 18.01.2022
            Elseif p_tip_reestr == 1 .and. ( xml2date( t1->DATE_Z_2 ) >= 0d20220101 )
              If !Empty( t2->PRVS ) .and. !Empty( t2->CODE_MD ) // после разговора с Л.Н.Антоновой 18.08.2021
                oMR_USL_N := oUSL:add( hxmlnode():new( 'MR_USL_N' ) )
                mo_add_xml_stroke( oMR_USL_N, 'MR_N', lstr( 1 ) )
                mo_add_xml_stroke( oMR_USL_N, 'PRVS', t2->PRVS )
                mo_add_xml_stroke( oMR_USL_N, 'CODE_MD', t2->CODE_MD )
              Endif
            Else
              mo_add_xml_stroke( oUSL, 'PRVS',t2->PRVS )
              mo_add_xml_stroke( oUSL, 'CODE_MD', t2->CODE_MD )
            Endif

            If !Empty( t2->COMENTU )
              mo_add_xml_stroke( oUSL, 'COMENTU', t2->COMENTU )
            Endif
            Select T2
            Skip
          Enddo
          If p_tip_reestr == 2 .and. !Empty( &lal.->COMENTSL )
            mo_add_xml_stroke( oSL, 'COMENTSL', &lal.->COMENTSL )
          Endif
        Next isl
      Else // не нашли в отосланном реестре - почему?
        func_error( 4, 'В реестре не найден пациент "' + AllTrim( human->fio ) + '"' )
      Endif
      //
      Select TMP2
      Skip
    Enddo
    Commit
    @ MaxRow(), 0 Say ' запись' Color cColorSt2Msg
    oXmlDoc:save( AllTrim( mo_xml->FNAME ) + sxml() )
    name_zip := AllTrim( mo_xml->FNAME ) + szip()
    arr_zip := { AllTrim( mo_xml->FNAME ) + sxml() }
    //
    stat_msg( 'Составление реестра пациентов по счёту № ' + mn_schet )
    oXmlDoc := hxmldoc():new()
    oXmlDoc:add( hxmlnode():new( 'PERS_LIST' ) )
    oXmlNode := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'ZGLV' ) )
    sVersion := '3.11'
    If StrZero( tmp1->_YEAR, 4 ) + StrZero( tmp1->_MONTH, 2 ) > '201910' // с ноября 2019 года
      sVersion := '3.2'
    Endif
    mo_add_xml_stroke( oXmlNode, 'VERSION', sVersion )
    mo_add_xml_stroke( oXmlNode, 'DATA', date2xml( schet_->DSCHET ) )
    mo_add_xml_stroke( oXmlNode, 'FILENAME', mo_xml->FNAME2 )
    mo_add_xml_stroke( oXmlNode, 'FILENAME1', mo_xml->FNAME )
    Select TMP2
    find ( Str( ii, 6 ) )
    Do While tmp2->schet == ii .and. !Eof()
      @ MaxRow(), 0 Say Str( tmp2->schet_zap / arr_schet[ ii, 3 ] * 100, 6, 2 ) + '%' Color cColorSt2Msg
      Select T3
      find ( Upper( tmp2->_ID_PAC ) )
      If Found() // нашли в отосланном реестре
        oPAC := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'PERS' ) )
        mo_add_xml_stroke( oPAC, 'ID_PAC', t3->ID_PAC )
        If !Empty( t3->FAM )
          mo_add_xml_stroke( oPAC, 'FAM', t3->FAM )
        endif
        If !Empty( t3->IM )
          mo_add_xml_stroke( oPAC, 'IM', t3->IM )
        endif
        If !Empty( t3->OT )
          mo_add_xml_stroke( oPAC, 'OT', t3->OT )
        Endif
        mo_add_xml_stroke( oPAC, 'W', t3->W )
        mo_add_xml_stroke( oPAC, 'DR', t3->DR )
        If !Empty( t3->dost )
          mo_add_xml_stroke( oPAC, 'DOST', t3->dost ) // отсутствует отчество
        Endif
        If !Empty( t3->tel )
          mo_add_xml_stroke( oPAC, 'TEL', t3->tel )
        Endif
        If !Empty( t3->FAM_P )
          mo_add_xml_stroke( oPAC, 'FAM_P', t3->FAM_P )
          mo_add_xml_stroke( oPAC, 'IM_P', t3->IM_P )
          If !Empty( t3->OT_P )
            mo_add_xml_stroke( oPAC, 'OT_P', t3->OT_P )
          Endif
          mo_add_xml_stroke( oPAC, 'W_P', t3->W_P )
          mo_add_xml_stroke( oPAC, 'DR_P', t3->DR_P )
          If !Empty( t3->dost_p )
            mo_add_xml_stroke( oPAC, 'DOST_P', t3->dost_p ) // отсутствует отчество
          Endif
        Endif
        If !Empty( t3->MR )
          mo_add_xml_stroke( oPAC, 'MR', t3->MR )
        Endif
        If !Empty( t3->DOCNUM )
          mo_add_xml_stroke( oPAC, 'DOCTYPE', t3->DOCTYPE )
          If !Empty( t3->DOCSER )
            mo_add_xml_stroke( oPAC, 'DOCSER', t3->DOCSER )
          Endif
          mo_add_xml_stroke( oPAC, 'DOCNUM', t3->DOCNUM )
        Endif
        If !Empty( t3->DOCDATE )
          mo_add_xml_stroke( oPAC, 'DOCDATE', t3->DOCDATE )
        Endif
        If !Empty( t3->DOCORG )
          mo_add_xml_stroke( oPAC, 'DOCORG', t3->DOCORG )
        Endif
        If !Empty( t3->SNILS )
          mo_add_xml_stroke( oPAC, 'SNILS', t3->SNILS )
        Endif
        If !Empty( t3->OKATOG )
          mo_add_xml_stroke( oPAC, 'OKATOG', t3->OKATOG )
        Endif
        If !Empty( t3->OKATOP )
          mo_add_xml_stroke( oPAC, 'OKATOP', t3->OKATOP )
        Endif
      Else // не нашли в отосланном реестре
        func_error( 4, 'В реестре не найден пациент "' + AllTrim( tmp2->_ID_PAC ) + '"' )
      Endif
      Select TMP2
      Skip
    Enddo
    @ MaxRow(), 0 Say ' запись' Color cColorSt2Msg
    oXmlDoc:save( AllTrim( mo_xml->FNAME2 ) + sxml() )
    AAdd( arr_zip, AllTrim( mo_xml->FNAME2 ) + sxml() )
    If chip_create_zipxml( name_zip, arr_zip, .t. )
      // может быть, сделать ещё что-нибудь после записи счёта?
    Endif
  Next
  // запишем время окончания обработки
  Select MO_XML
  Goto ( mXML_REESTR )
  g_rlock( forever )
  mo_xml->TWORK2 := hour_min( Seconds() )
  Close databases
  If fl_msg
    stat_msg( 'Запись счетов завершена!' ) ; mybell( 2, OK )
  Endif

  Return .t.

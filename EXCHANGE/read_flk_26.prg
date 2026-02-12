#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 12.02.26 зачитать протокол ФЛК во временные файлы новая версия
Function parse_protokol_flk_26( arr_f, aerr )

  Local j, s, oXmlDoc, oXmlNode, cFile
  Local is_err_FLK := .f.
  Local adbf
  local iError := 1   // реестр принят

  adbf := { ;
    { 'FNAME',  'C', 30, 0 }, ; // 27
    { 'FNAME1', 'C', 30, 0 }, ; // 26
    { 'FNAME2', 'C', 30, 0 }, ; // 26
    { 'KOL2',   'N',  6, 0 };   // кол-во ошибок
  }
  dbCreate( cur_dir() + 'tmp1file', adbf, , .t., 'TMP1' )
  tmp1->( dbAppend() )

//    { 'TIP',        'N',   1, 0 }, ;  // тип (номер) обрабатываемого файла
  adbf := { ; // элементы PR
    { 'OSHIB',      'N',   3, 0 }, ;  // код ошибки T005
    { 'SOSHIB',     'C',  12, 0 }, ;  // код ошибки Q015, Q022
    { 'IM_POL',     'C',  20, 0 }, ;  // имя поля, в котором ошибка
    { 'ZN_POL',     'C', 100, 0 }, ;  // Значение поля, вызвавшее ошибку. Не заполняется, если ошибка относится к файлу в целом
    { 'NSCHET',     'C',  15, 0 }, ;  // Номер счета, в котором обнаружена ошибка
    { 'BAS_EL',     'C',  20, 0 }, ;  // имя базового элемента
    { 'N_ZAP',      'N',   6, 0 }, ;  // поле из первичного реестра
    { 'ID_PAC',     'C',  36, 0 }, ;  // Код записи о пациенте, в которой обнаружена ошибка. Не заполняется только в том случае, если ошибка относится к файлу в целом.
    { 'IDCASE',     'N',  11, 0 }, ;  // Номер законченного случая, в котором обнаружена ошибка(указывается, если ошибка обнаружена внутри тега ?Z_SL?, в том числе во входящих в него элементах ?SL? и услугах)
    { 'SL_ID',      'C',  36, 0 }, ;  // Идентификатор случая, в котором обнаружена ошибка (указывается, если ошибка обнаружена внутри тега ?SL?, в том числе во входящих в него услугах)
    { 'IDSERV',     'C',  36, 0 }, ;  // Номер услуги, в которой обнаружена ошибка (указывается, если ошибка обнаруживается внутри тега ?USL?)
    { 'COMMENT',    'C', 250, 0 }, ;  // описание ошибки
    { 'KOD_HUMAN',  'N',   7, 0 } ;   // код по БД листов учёта
  }
//    { 'N_ZAP',      'C',  36, 0 }, ;  // Номер записи, в одном из полей которой обнаружена ошибка
  dbCreate( cur_dir() + 'tmp2file', adbf, , .t., 'TMP2' ) // элементы PR

  dbCreate( cur_dir() + 'tmp22fil', adbf ) // доп.файл, если по одному пациенту > 1 листа учёта

  dbCreate( cur_dir() + 'tmp3file', { ;
    { '_N_ZAP',     'N',  8, 0 }, ;
    { '_REFREASON', 'N',  3, 0 }, ;
    { 'SREFREASON', 'C', 12, 0 };
    }, , .t., 'TMP3' )

  cFile := arr_f[ 1 ]
  If Upper( Right( cFile, 4 ) ) == sxml() .and. ValType( oXmlDoc := hxmldoc():read( _tmp_dir1() + cFile ) ) == 'O'
    For j := 1 To Len( oXmlDoc:aItems[ 1 ]:aItems )
      oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
      Do Case
      Case 'FNAME' == oXmlNode:title  // Имя файла протокола без расширения
        tmp1->FNAME := mo_read_xml_tag( oXmlNode, aerr, .t. )
      Case 'FNAME_I' == oXmlNode:title  // Имя исходного файла без расширения
        tmp1->FNAME1 := mo_read_xml_tag( oXmlNode, aerr, .t. )
      Case 'PR' == oXmlNode:title   // Причина отказа. Если ошибки отсутствуют, то не передается.
        dbSelectArea( 'TMP2' )
        tmp2->( dbAppend() )
        s := AllTrim( mo_read_xml_stroke( oXmlNode, 'OSHIB', aerr ) )
        If Len( s ) > 3 .or. '.' $ s
          tmp2->SOSHIB := s       // описание ошибки в файле Q015, Q016, Q022
        Else
          tmp2->OSHIB := Val( s ) // описание ошибки в файле T005
        Endif
        tmp2->IM_POL  := mo_read_xml_stroke( oXmlNode, 'IM_POL', aerr, .f. )
        tmp2->ZN_POL  := mo_read_xml_stroke( oXmlNode, 'ZN_POL', aerr, .f. )
        tmp2->NSCHET  := mo_read_xml_stroke( oXmlNode, 'NSCHET', aerr, .f. )
        tmp2->BAS_EL  := mo_read_xml_stroke( oXmlNode, 'BAS_EL', aerr, .f. )
        tmp2->N_ZAP   := Val( mo_read_xml_stroke( oXmlNode, 'N_ZAP', aerr, .f. ) )
        tmp2->ID_PAC  := mo_read_xml_stroke( oXmlNode, 'ID_PAC', aerr, .f. )
        tmp2->IDCASE  := Val( mo_read_xml_stroke( oXmlNode, 'IDCASE', aerr, .f. ) )
        tmp2->SL_ID   := mo_read_xml_stroke( oXmlNode, 'SL_ID', aerr, .f. )
        tmp2->IDSERV  := mo_read_xml_stroke( oXmlNode, 'IDSERV', aerr, .f. )
        tmp2->COMMENT := mo_read_xml_stroke( oXmlNode, 'COMMENT', aerr, .f. )
        If ! Empty( tmp2->BAS_EL )
          is_err_FLK := .t.
          iError := 3
          tmp1->KOL2++
        else
          iError := 2
        Endif
      Endcase
    Next j
  Endif
  dbCommitAll()
  Return iError   //  is_err_FLK

// 12.02.26 прочитать реестр ФЛК
Function read_xml_file_flk_26( arr_XML_info, aerr, is_err_FLK_26, cFileProtokol )

  Local i, k, t_arr[ 2 ]  //, pole
  Local mkod_reestr, s

  mkod_reestr := arr_XML_info[ 7 ]
  Use ( cur_dir() + 'tmp1file' ) New Alias TMP1
  r_use( dir_server() + 'mo_rees', , 'REES' )
  rees->( dbGoto( arr_XML_info[ 7 ] ) )
  StrFile( 'Обрабатывается ответ ТФОМС на реестр счета № ' + ;
    lstr( rees->NSCHET ) + ' от ' + full_date( rees->DSCHET ) + 'г. (' + lstr( rees->KOL ) + ' чел.)' + ;
    hb_eol(), cFileProtokol, .t. )
  If ! emptyany( rees->nyear, rees->nmonth )
    StrFile( 'выставленный за ' + mm_month()[ rees->nmonth ] + Str( rees->nyear, 5 ) + ' года' + ;
      hb_eol(), cFileProtokol, .t. )
  Endif
  Use ( cur_dir() + 'tmp2file' ) New Alias TMP2
  Index On Str( FIELD->oshib, 3 ) + FIELD->soshib to ( cur_dir() + 'tmp2' )
  Use ( cur_dir() + 'tmp3file' ) New Alias TMP3
  Index On Str( FIELD->_n_zap, 8 ) to ( cur_dir() + 'tmp3' )

  If is_err_FLK_26 != 1 // есть ошибки ТФОМС
    If !extract_reestr26( rees->( RecNo() ), rees->name_xml )
      AAdd( aerr, Center( 'Не найден ZIP-архив с РЕЕСТРом СЧЕТОВ № ' + lstr( rees->nschet ) + ' от ' + date_8( rees->DSCHET ), 80 ) )
      AAdd( aerr, '' )
      AAdd( aerr, Center( dir_server() + dir_XML_MO() + hb_ps() + AllTrim( rees->name_xml ) + szip(), 80 ) )
      AAdd( aerr, '' )
      AAdd( aerr, Center( 'Без данного архива дальнейшая работа НЕВОЗМОЖНА!', 80 ) )
      dbCloseAll()
      Return .f.
    Endif

//    create_files_tmp_flk_26() // создадим временные файлы для разбора

    Use ( cur_dir() + 'tmp_r_t1' ) New Alias T1
    Index On Upper( FIELD->ID_PAC ) to ( cur_dir() + 'tmp_r_t1' )
    Use ( cur_dir() + 'tmp_r_t2' ) New Alias T2
    Use ( cur_dir() + 'tmp_r_t3' ) New Alias T3   // для пациентов
    Index On Upper( FIELD->ID_PAC ) to ( cur_dir() + 'tmp_r_t3' )
//    Use ( cur_dir() + 'tmp_r_t4' ) New Alias T4
//    Use ( cur_dir() + 'tmp_r_t5' ) New Alias T5
//    Use ( cur_dir() + 'tmp_r_t6' ) New Alias T6
//    Use ( cur_dir() + 'tmp_r_t7' ) New Alias T7
//    Use ( cur_dir() + 'tmp_r_t8' ) New Alias T8

// заполнить поле 'N_ZAP' в файле 'tmp2'
    fill_tmp2_file_flk_26()

    r_use( dir_server() + 'mo_otd', , 'OTD' )

      g_use( dir_server() + 'human_u_',, 'HU_' )
      r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
      Set Relation To RecNo() into HU_

    r_use( dir_server() + 'human_3', { dir_server() + 'human_3', dir_server() + 'human_32' }, 'HUMAN_3' )
    g_use( dir_server() + 'human_', , 'HUMAN_' )
    g_use( dir_server() + 'human', , 'HUMAN' )
    Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_3, To FIELD->otd into OTD
    g_use( dir_server() + 'mo_rhum', , 'RHUM' )
    Index On Str( FIELD->REES_ZAP, 6 ) to ( cur_dir() + 'tmp_rhum' ) For FIELD->reestr == mkod_reestr

    g_use( dir_server() + 'mo_refr', dir_server() + 'mo_refr', 'REFR' )

    dbSelectArea( 'TMP2' ) // сначала проверка

    tmp2->( dbGoTop() )
    Do While ! tmp2->( Eof() )
      dbSelectArea( 'RHUM' )
      rhum->( dbSeek( Str( tmp2->N_ZAP, 6 ) ) )
      If rhum->( Found() )
        human->( dbGoto( rhum->KOD_HUM ) )
        If rhum->OPLATA > 0
          AAdd( aerr, 'Пациент с REES_ZAP=' + lstr( rhum->REES_ZAP ) + ' был прочитан в реестре СП и ТК' )
          If !Empty( human->fio )
            AAdd( aerr, '└─>(ФИО пациента = ' + AllTrim( human->fio ) + ')' )
          Endif
        Endif
        If !( rhum->REES_ZAP == human_->REES_ZAP )
          AAdd( aerr, 'Не равен параметр REES_ZAP: ' + lstr( rhum->REES_ZAP ) + ' != ' + lstr( human_->REES_ZAP ) )
        Endif
      Else
        AAdd( aerr, 'Не найден случай с N_ZAP=' + lstr( tmp2->N_ZAP ) )
      Endif
      dbSelectArea( 'TMP2' )
      tmp2->( dbSkip() )
    Enddo
    If !Empty( aerr )
      dbCloseAll()
      Return .f.
    Endif

  Endif

  StrFile( hb_eol() + 'Обработан файл ' + AllTrim( tmp1->FNAME1 ) + hb_eol(), cFileProtokol, .t. )
  dbSelectArea( 'TMP2' )
  if tmp2->( LastRec() ) > 0
    tmp2->( dbGoTop() )
    StrFile( '  Список ошибок:' + hb_eol(), cFileProtokol, .t. )
    Do While ! tmp2->( Eof() )

      dbSelectArea( 'RHUM' )
      rhum->( dbSeek( Str( tmp2->N_ZAP, 6 ) ) )
      If rhum->( Found() )
        Select REFR
        Do While .t.
          refr->( dbSeek( Str( 2, 1 ) + Str( mkod_reestr, 6 ) + Str( 1, 1 ) + Str( rhum->KOD_HUM, 8 ) ) ) // для счетов
          If ! refr->( Found() )
            Exit
          Endif
          deleterec( .t. )
        Enddo

        Select TMP3
        tmp3->( dbSeek( Str( tmp2->N_ZAP, 8 ) ) )
        Do While tmp2->N_ZAP == tmp3->_N_ZAP .and. ! tmp3->( Eof() )
          Select REFR
          addrec( 1 )
          refr->TIPD := 1 // 2 // счет
          refr->KODD := mkod_reestr
          refr->TIPZ := 1
          refr->KODZ := rhum->KOD_HUM
          refr->REFREASON := tmp3->_REFREASON
          refr->SREFREASON := tmp3->SREFREASON
//          refr->IDENTITY := tmp2->_IDENTITY
          Select tmp3
          tmp3->( dbSkip() )
        Enddo
      endif

      If Empty( tmp2->SOSHIB )
        s := 'код ошибки = ' + lstr( tmp2->OSHIB ) + ' '
        If ( i := AScan( getf012(), {| x| x[ 2 ] == tmp2->OSHIB } ) ) > 0
          s += '"' + getf012()[ i, 5 ] + '"'
        Endif
      Else
        s := 'код ошибки = ' + tmp2->SOSHIB + ' '
        s += '"' + getcategorycheckerrorbyid_q017( Left( tmp2->SOSHIB, 4 ) )[ 2 ] + '" '
//        s += AllTrim( inieditspr( A__MENUVERT, loadq015(), tmp3->SREFREASON ) )
      Endif
      If !Empty( tmp2->IM_POL )
        s += ', имя поля = ' + AllTrim( tmp2->IM_POL )
      Endif
      If !Empty( tmp2->BAS_EL )
        s += ', имя базового элемента = ' + AllTrim( tmp2->BAS_EL )
      Endif
      If !Empty( tmp2->COMMENT )
        s += ', описание ошибки = ' + AllTrim( tmp2->COMMENT )
      Endif
      If !Empty( tmp2->BAS_EL )
        If Empty( tmp2->N_ZAP )
          s += ', СЛУЧАЙ НЕ НАЙДЕН!'
        Else

          dbSelectArea( 'RHUM' )
          rhum->( dbSeek( Str( tmp2->N_ZAP, 6 ) ) )
          If rhum->( Found() )
            g_rlock( 'forever' )
            rhum->OPLATA := 2
            tmp2->kod_human := rhum->KOD_HUM
            dbSelectArea( 'HUMAN' )
            human->( dbGoto( rhum->KOD_HUM ) )
//            If human->ishod == 89 // это 2-ой случай в двойном случае
//              dbSelectArea( 'HUMAN_3' )
////              Set Order To 2
//              human_3->( ordSetFocus( 2 ) )
//              human_3->( dbSeek( Str( rhum->KOD_HUM, 7 ) ) )
//              If human_3->( Found() )
//                human->( dbGoto( human_3->kod ) )    // т.к. GUID'ы в реестре из 1-го случая
//                human_->( dbGoto( human_3->kod ) )   // встать на 1-ый случай
//              Endif
//            Endif
            If human_->REESTR == mkod_reestr
              g_rlock( 'forever' )
              human_->( g_rlock( 'forever' ) )
              human_->OPLATA := 2
              human_->REESTR := 0 // направляется на дальнейшее редактирование
              human_->ST_VERIFY := 0 // снова ещё не проверен
              If human_->REES_NUM > 0
//                human_->REES_NUM := human_->REES_NUM - 1
              Endif
              human->( dbUnlock() )
              s += ', ' + AllTrim( human->fio ) + ', ' + full_date( human->date_r ) + ;
                iif( Empty( otd->SHORT_NAME ), '', ' [' + AllTrim( otd->SHORT_NAME ) + ']' ) + ;
                ' ' + date_8( human->n_data ) + '-' + date_8( human->k_data )
            Endif
          else
            s := 'Не найден случай с N_ZAP=' + lstr( tmp2->_N_ZAP ) + ', _ID_PAC=' + tmp2->_ID_PAC
          endif

        Endif
      Endif
      k := perenos( t_arr, s, 75 )
      StrFile( hb_eol(), cFileProtokol, .t. )
      For i := 1 To k
        StrFile( Space( 5 ) + t_arr[ i ] + hb_eol(), cFileProtokol, .t. )
      Next
      dbSelectArea( 'TMP2' )
      tmp2->( dbSkip() )
    Enddo
/* исправить
    adbf_1 := { ;
      { 'KOD_HUM',  'N',  7, 0 } ; // код HUMAN
    }
    dbCreate( cur_dir() + 'tmp_recno', adbf_1 )
    Use ( cur_dir() + 'tmp_recno' ) New Alias TR
    Select human_ // очищаем признак добавления в реестр счета
    Index On Str( FIELD->REESTR, 7 ) to ( cur_dir() + 'tmp_human_' ) For FIELD->REESTR == mkod_reestr
    human_->( dbSeek( Str( mkod_reestr, 7 ) ) )

    do while human_->REESTR == mkod_reestr .and. ! ( human_->( Eof() ) )
      g_rlock( 'forever' )
      human_->( g_rlock( 'forever' ) )
      human_->OPLATA := 2
      human_->REESTR := 0 // направляется на дальнейшее редактирование
      human_->ST_VERIFY := 5 // проверен 0
      If human_->REES_NUM > 0
        human_->REES_NUM := human_->REES_NUM - 1
      Endif
      human->( dbUnlock() )

      TR->( dbAppend() )
      TR->KOD_HUM := human_->( RecNo() )
      human_->( dbSkip() )
    Enddo
    TR->( dbCloseArea() )
 */
    adbf_1 := { ;
      { 'KOD_HUM',  'N',  7, 0 } ; // код HUMAN
    }
    dbCreate( cur_dir() + 'tmp_recno', adbf_1 )
    Use ( cur_dir() + 'tmp_recno' ) New Alias TR

    Select rhum
    Index On Str( FIELD->reestr, 6 ) to ( cur_dir() + 'tmp_rhum1' )
    Do While .t.
      Select RHUM
      find ( Str( mkod_reestr, 6 ) )
      If !Found()
        exit
      Endif

      //
      Select HUMAN_
      Goto ( rhum->KOD_HUM )
      If human_->REESTR == mkod_reestr // на всякий случай
        Select HUMAN
        Goto ( rhum->KOD_HUM )

    TR->( dbAppend() )
    TR->KOD_HUM := human->( RecNo() )
        If human->ishod == 88 // сначала проверим, не двойной ли это случай (по-старому)
          Select HUMAN_3
          Set Order To 1
          find ( Str( human->kod, 7 ) )
          If Found()
            Select HUMAN_
            Goto ( human_3->kod2 ) // встать на 2-ой лист учёта
            Select HU
            find ( Str( human_3->kod2, 7 ) )
            Do While human_3->kod2 == hu->kod .and. !Eof()
              hu_->( g_rlock( 'forever' ) )
              hu_->REES_ZAP := 0
              hu_->( dbUnlock() )
              Select HU
              Skip
            Enddo
            human_->( g_rlock( 'forever' ) )
            If human_->REES_NUM > 0
//                human_->REES_NUM := human_->REES_NUM - 1
            Endif
            human_->REES_ZAP := 0
            human_->REESTR := 0
            human_->( dbUnlock() )
            // обработка заголовка двойного случая
            human_3->( g_rlock( 'forever' ) )
            If human_3->REES_NUM > 0
              human_3->REES_NUM := human_3->REES_NUM - 1
            Endif
            human_3->REES_ZAP := 0
            human_3->REESTR := 0
            human_3->( dbUnlock() )
          Endif
          // возвращаемся к 1-му листу учёта
          Select HUMAN_
          Goto ( rhum->KOD_HUM )
          Select HU
          find ( Str( rhum->KOD_HUM, 7 ) )
          Do While rhum->KOD_HUM == hu->kod .and. !Eof()
            hu_->( g_rlock( 'forever' ) )
            hu_->REES_ZAP := 0
            hu_->( dbUnlock() )
            Select HU
            Skip
          Enddo
          human_->( g_rlock( 'forever' ) )
          If human_->REES_NUM > 0
//              human_->REES_NUM := human_->REES_NUM - 1
          Endif
          human_->REES_ZAP := 0
          human_->REESTR := 0
          human_->( dbUnlock() )
        Elseif human->ishod == 89 // теперь проверим, не двойной ли это случай (по-новому)
          // сначала обработаем 2-ой случай
          Select HU
          find ( Str( rhum->KOD_HUM, 7 ) )
          Do While rhum->KOD_HUM == hu->kod .and. !Eof()
            hu_->( g_rlock( 'forever' ) )
            hu_->REES_ZAP := 0
            hu_->( dbUnlock() )
            Select HU
            Skip
          Enddo
          human_->( g_rlock( 'forever' ) )
          If human_->REES_NUM > 0
//              human_->REES_NUM := human_->REES_NUM - 1
          Endif
          human_->REES_ZAP := 0
          human_->REESTR := 0
          human_->( dbUnlock() )
          // поищем 1-ый случай
          Select HUMAN_3
          Set Order To 2
          find ( Str( human->kod, 7 ) )
          If Found()
            Select HUMAN_
            Goto ( human_3->kod ) // встать на 1-ый лист учёта
            Select HU
            find ( Str( human_3->kod2, 7 ) )
            Do While human_3->kod2 == hu->kod .and. !Eof()
              hu_->( g_rlock( 'forever' ) )
              hu_->REES_ZAP := 0
              hu_->( dbUnlock() )
              Select HU
              Skip
            Enddo
            human_->( g_rlock( 'forever' ) )
            If human_->REES_NUM > 0
//                human_->REES_NUM := human_->REES_NUM - 1
            Endif
            human_->REES_ZAP := 0
            human_->REESTR := 0
            human_->( dbUnlock() )
            // обработка заголовка двойного случая
            human_3->( g_rlock( 'forever' ) )
            If human_3->REES_NUM > 0
              human_3->REES_NUM := human_3->REES_NUM - 1
            Endif
            human_3->REES_ZAP := 0
            human_3->REESTR := 0
            human_3->( dbUnlock() )
          Endif
        Else
          // обработка одинарного случая
          Select HUMAN_
          Goto ( rhum->KOD_HUM )
          Select HU
          find ( Str( rhum->KOD_HUM, 7 ) )
          Do While rhum->KOD_HUM == hu->kod .and. !Eof()
            hu_->( g_rlock( 'forever' ) )
            hu_->REES_ZAP := 0
            hu_->( dbUnlock() )
            Select HU
            Skip
          Enddo
          human_->( g_rlock( 'forever' ) )
          If human_->REES_NUM > 0
//              human_->REES_NUM := human_->REES_NUM - 1
          Endif
          human_->REES_ZAP := 0
          human_->REESTR := 0
          human_->( dbUnlock() )
        Endif
      Endif
      //
      Select RHUM
      deleterec( .t. )
    Enddo
    TR->( dbCloseArea() )
//altd()
//      create2reestr26( arr_XML_info[ 4 ], arr_XML_info[ 5 ], arr_XML_info[ 9 ], iif( arr_XML_info[ 8 ] == 'VHM', TYPE_REESTR_GENERAL, TYPE_REESTR_DISPASER ), 1 )
  else
    StrFile( '-- Ошибок не обнаружено -- ' + hb_eol(), cFileProtokol, .t. )
  endif
  dbCloseAll()
  Return .t.

// 11.02.26 заполнить поле 'N_ZAP' в файле 'tmp2'
Function fill_tmp2_file_flk_26()

  Local i, s, s1, adbf, ar

  Use ( cur_dir() + 'tmp22fil' ) New Alias TMP22
  dbSelectArea( 'TMP2' )
  adbf := Array( tmp2->( FCount() ) )
  tmp2->( dbGoTop() )
  Do While ! tmp2->( Eof() )
    If ! Empty( tmp2->BAS_EL )
      s := AllTrim( tmp2->BAS_EL )
      Do Case
//      Case s == 'ZAP'
//        dbSelectArea( 'T1' )
//        Locate For t1->N_ZAP == PadR( s1, 6 )
//        If t1->( Found() )
//          tmp2->N_ZAP := Val( t1->N_ZAP )
//        Endif
      Case s == 'PACIENT'
        s1 := tmp2->ID_PAC
        ar := {}

        if tmp2->N_ZAP != 0
          AAdd( ar, tmp2->N_ZAP )
        else
          dbSelectArea( 'T1' )
          t1->( dbSeek( PadR( Upper( s1 ), 36 ) ) )
          Do While Upper( t1->ID_PAC ) == PadR( Upper( s1 ), 36 )
            AAdd( ar, Int( Val( t1->N_ZAP ) ) )
            t1->( dbSkip() )
          Enddo
          If Len( ar ) > 0
            dbSelectArea( 'T2' )
            tmp2->N_ZAP := ar[ 1 ]
            If Len( ar ) > 1
              AEval( adbf, {| x, i| adbf[ i ] := FieldGet( i ) } )
              dbSelectArea( 'TMP22' )
              For i := 2 To Len( ar )
                tmp22->( dbAppend() )
                AEval( adbf, {| x, i| FieldPut( i, x ) } )
                tmp22->N_ZAP := ar[ i ]
              Next
            Endif
          Endif
        endif
        
      Case eq_any( s, 'SLUCH', 'Z_SL' )
        dbSelectArea( 'T1' )
        Locate For Upper( t1->ID_C ) == PadR( Upper( s1 ), 36 )
        If t1->( Found() )
          tmp2->N_ZAP := Val( t1->N_ZAP )
        Endif
      Case s == 'USL'
//        s1 := tmp2->SL_ID
/*
        dbSelectArea( 'T2' )
        Locate For Upper( t2->ID_U ) == PadR( Upper( s1 ), 36 )
        If t2->( Found() )
          dbSelectArea( 'T1' )
          Locate For t1->N_ZAP == t2->IDCASE
          If t1->( Found() )
            tmp2->N_ZAP := Val( t1->N_ZAP )
          Endif
        Endif
*/
      Case s == 'PERS'
        dbSelectArea( 'T3' )
        s1 := AllTrim( tmp2->ID_PAC )
        t3->( dbSeek( PadR( Upper( s1 ), 36 ) ) )
//        Locate For Upper( t3->ID_PAC ) == PadR( Upper( s1 ), 36 )
        If t3->( Found() )
          ar := {}
          dbSelectArea( 'T1' )
          t1->( dbSeek( PadR( Upper( s1 ), 36 ) ) )
          Do While Upper( t1->ID_PAC ) == PadR( Upper( s1 ), 36 )
            AAdd( ar, Int( Val( t1->N_ZAP ) ) )
            t1->( dbSkip() )
          Enddo
          If Len( ar ) > 0
            dbSelectArea( 'TMP2' )
            tmp2->N_ZAP := ar[ 1 ]
            If Len( ar ) > 1
              AEval( adbf, {| x, i| adbf[ i ] := FieldGet( i ) } )
              dbSelectArea( 'TMP22' )
              For i := 2 To Len( ar )
                tmp22->( dbAppend() )
                AEval( adbf, {| x, i| FieldPut( i, x ) } )
                tmp22->N_ZAP := ar[ i ]
              Next
            Endif
          Endif
        Endif
      Endcase
    Endif
    tmp3->( dbAppend() )
    tmp3->_N_ZAP := tmp2->N_ZAP
    tmp3->SREFREASON := tmp2->SOSHIB
    tmp3->_REFREASON := tmp2->OSHIB
    dbSelectArea( 'TMP2' )
    tmp2->( dbSkip() )
  Enddo
  i := tmp22->( LastRec() )
  tmp22->( dbCloseArea() )
  If i > 0
    dbSelectArea( 'TMP2' )
    Append From tmp22fil codepage 'RU866'
//    Index On Str( FIELD->tip, 1 ) + Str( FIELD->oshib, 3 ) to ( cur_dir() + 'tmp2' )
    Index On Str( FIELD->oshib, 3 ) to ( cur_dir() + 'tmp2' )
  Endif
  Return Nil

// 14.01.26 создать файлы для анализа ФЛК нового образца
Function create_files_tmp_flk_26()

  Local _table1 := { ;
    { 'KOD',      'N',  6, 0 }, ; // код
    { 'N_ZAP',    'N',  6, 0 }, ; // номер позиции записи в реестре счетов 26 года
    { 'PR_NOV',   'C',  1, 0 }, ;
    { 'ID_PAC',   'C', 36, 0 }, ; //
    { 'VPOLIS',   'C',  1, 0 }, ; //
    { 'SPOLIS',   'C', 10, 0 }, ; //
    { 'NPOLIS',   'C', 20, 0 }, ; //
    { 'ENP',      'C', 16, 0 }, ; //
    { 'SMO',      'C',  5, 0 }, ; //
    { 'SMO_OK',   'C',  5, 0 }, ; //
    { 'SMO_NAM',  'C',100, 0 }, ; //
    { 'MO_PR',    'C',  6, 0 }, ; //
    { 'NOVOR',    'C',  9, 0 }, ; //
    { 'VNOV_D',   'C',  4, 0 }, ; // вес новорожденного в граммах
    { 'SOC',      'C',  3, 0 }, ; // участники и члены семей участников СВО
    { 'INV',      'C',  1, 0 }, ; //
    { 'DATA_INV', 'C', 10, 0 }, ; //
    { 'REASON_INV','C', 2, 0 }, ; //
    { 'DS_INV',   'C', 10, 0 }, ; //
    { 'MSE',      'C',  1, 0 }, ; //
    { 'KD_Z',     'C',  3, 0 }, ; //
    { 'KD',       'C',  3, 0 }, ; //
    { 'IDCASE',   'C', 12, 0 }, ; //
    { 'ID_C',     'C', 36, 0 }, ; //
    { 'SL_ID',    'C', 36, 0 }, ; //
    { 'DISP',     'C',  3, 0 }, ; //
    { 'USL_OK',   'C',  2, 0 }, ; //
    { 'VIDPOM',   'C',  4, 0 }, ; //
    { 'F_SP',     'C',  1, 0 }, ; // удалено поле
    { 'FOR_POM',  'C',  1, 0 }, ; // N1
    { 'VID_HMP',  'C', 12, 0 }, ; // C9
    { 'ISHOD',    'C',  3, 0 }, ; //
    { 'VB_P',     'C',  1, 0 }, ; //
    { 'IDSP',     'C',  2, 0 }, ; //
    { 'SUMV',     'C', 10, 0 }, ; //
    { 'METOD_HMP','C',  4, 0 }, ; // N4 // 12.02.21
    { 'NPR_MO',   'C',  6, 0 }, ; //
    { 'NPR_DATE', 'C', 10, 0 }, ; //
    { 'EXTR',     'C',  1, 0 }, ; //
    { 'LPU',      'C',  6, 0 }, ; //
    { 'LPU_1',    'C',  8, 0 }, ; //
    { 'PODR',     'C',  8, 0 }, ; //
    { 'PROFIL',   'C',  3, 0 }, ; //
    { 'PROFIL_K', 'C',  3, 0 }, ; //
    { 'DET',      'C',  1, 0 }, ; //
    { 'P_CEL',    'C',  3, 0 }, ; //
    { 'TAL_D',    'C', 10, 0 }, ; //
    { 'TAL_P',    'C', 10, 0 }, ; //
    { 'TAL_NUM',  'C', 20, 0 }, ; //
    { 'VBR',      'C',  1, 0 }, ; //
    { 'NHISTORY', 'C', 10, 0 }, ; //
    { 'P_OTK',    'C',  1, 0 }, ; //
    { 'P_PER',    'C',  1, 0 }, ; //
    { 'DATE_Z_1', 'C', 10, 0 }, ; //
    { 'DATE_Z_2', 'C', 10, 0 }, ; //
    { 'DATE_1',   'C', 10, 0 }, ; //
    { 'DATE_2',   'C', 10, 0 }, ; //
    { 'DS0',      'C',  6, 0 }, ; //
    { 'DS1',      'C',  6, 0 }, ; //
    { 'DS1_PR',   'C',  1, 0 }, ; //
    { 'PR_D_N',   'C',  1, 0 }, ; //
    { 'DS2',      'C',  6, 0 }, ; //
    { 'DS2N',     'C',  6, 0 }, ; //
    { 'DS2N_PR',  'C',  1, 0 }, ; //
    { 'DS2N_D',   'C',  1, 0 }, ; //
    { 'DS2_2',    'C',  6, 0 }, ; //
    { 'DS2N_2',   'C',  6, 0 }, ; //
    { 'DS2N_2_PR','C',  1, 0 }, ; //
    { 'DS2N_2_D', 'C',  1, 0 }, ; //
    { 'DS2_3',    'C',  6, 0 }, ; //
    { 'DS2N_3',   'C',  6, 0 }, ; //
    { 'DS2N_3_PR','C',  1, 0 }, ; //
    { 'DS2N_3_D', 'C',  1, 0 }, ; //
    { 'DS2_4',    'C',  6, 0 }, ; //
    { 'DS2N_4',   'C',  6, 0 }, ; //
    { 'DS2N_4_PR','C',  1, 0 }, ; //
    { 'DS2N_4_D', 'C',  1, 0 }, ; //
    { 'DS2_5',    'C',  6, 0 }, ; //
    { 'DS2_6',    'C',  6, 0 }, ; //
    { 'DS2_7',    'C',  6, 0 }, ; //
    { 'DS3',      'C',  6, 0 }, ; //
    { 'DS3_2',    'C',  6, 0 }, ; //
    { 'DS3_3',    'C',  6, 0 }, ; //
    { 'DS_ONK',   'C',  1, 0 }, ; //
    { 'C_ZAB',    'C',  1, 0 }, ; //
    { 'DN',       'C',  1, 0 }, ; //
    { 'VNOV_M',   'C',  4, 0 }, ; // вес новорожденного в граммах
    { 'VNOV_M_2', 'C',  4, 0 }, ; // вес новорожденного в граммах
    { 'VNOV_M_3', 'C',  4, 0 }, ; // вес новорожденного в граммах
    { 'CODE_MES1','C', 20, 0 }, ; //
    { 'SUM_M',    'C', 10, 0 }, ; //
    { 'DS1_T',    'C',  1, 0 }, ; // Повод обращения:0 - первичное лечение;1 - рецидив;2 - прогрессирование
    { 'PR_CONS',  'C',  1, 0 }, ; // Сведения о проведении консилиума:1 - определена тактика обследования;2 - определена тактика лечения;3 - изменена тактика лечения.
    { 'DT_CONS',  'C', 10, 0 }, ; // Дата проведения консилиума       Обязательно к заполнению при заполненном PR_CONS
    { 'STAD',     'C',  4, 0 }, ; // Стадия заболевания       Заполняется в соответствии со справочником N002
    { 'ONK_T',    'C',  5, 0 }, ; // Значение Tumor   Заполняется в соответствии со справочником N003
    { 'ONK_N',    'C',  5, 0 }, ; // Значение Nodus   Заполняется в соответствии со справочником N004
    { 'ONK_M',    'C',  5, 0 }, ; // Значение Metastasis      Заполняется в соответствии со справочником N005
    { 'MTSTZ',    'C',  1, 0 }, ; // Признак выявления отдалённых метастазов  Подлежит заполнению значением 1 при выявлении отдалённых метастазов только при DS1_T=1 или DS1_T=2
    { 'SOD',      'C',  6, 0 }, ;  // Суммарная очаговая доза Обязательно для заполнения при проведении лучевой или химиолучевой терапии (USL_TIP=3 или USL_TIP=4)
    { 'K_FR',     'C',  2, 0 }, ; //
    { 'WEI',      'C',  5, 0 }, ; //
    { 'HEI',      'C',  5, 0 }, ; //
    { 'BSA',      'C',  5, 0 }, ; //
    { 'RSLT',     'C',  3, 0 }, ; //
    { 'ISHOD',    'C',  3, 0 }, ; //
    { 'IDSP',     'C',  2, 0 }, ; //
    { 'PRVS',     'C',  9, 0 }, ; //
    { 'IDDOKT',   'C', 16, 0 }, ; //
    { 'OS_SLUCH', 'C',  2, 0 }, ; //
    { 'COMENTSL', 'C',250, 0 }, ; //
    { 'ED_COL',   'C',  1, 0 }, ; //
    { 'N_KSG',    'C', 20, 0 }, ; //
    { 'CRIT',     'C', 20, 0 }, ; //
    { 'CRIT2',    'C', 20, 0 }, ; //
    { 'SL_K',     'C',  9, 0 }, ; //
    { 'IT_SL',    'C',  9, 0 }, ; //
    { 'AD_CR',    'C', 10, 0 }, ; //
    { 'DKK2',     'C', 10, 0 }, ; //
    { 'kod_kslp', 'C',  5, 0 }, ; //
    { 'koef_kslp','C',  6, 0 }, ;  //
    { 'kod_kslp2','C',  5, 0 }, ; //
    { 'koef_kslp2','C', 6, 0 }, ;  //
    { 'kod_kslp3','C',  5, 0 }, ; //
    { 'koef_kslp3','C', 6, 0 }, ;  //
    { 'CODE_KIRO','C',  1, 0 }, ; //
    { 'VAL_K',    'C',  5, 0 }, ; //
    { 'NEXT_VISIT','C',10, 0 }, ; //
    { 'TARIF',    'C', 10, 0 } ; //
  }
//    { 'N_ZAP',    'C', 12, 0 }, ; // номер позиции записи в реестре;поле 'IDCASE' (и 'ZAP') в реестре случаев
  Local _table2 := { ;
    { 'SLUCH',    'N',  6, 0 }, ; // номер случая
    { 'KOD',      'N',  6, 0 }, ; // код
    { 'IDCASE',   'C', 12, 0 }, ; // номер позиции записи в реестре;поле 'IDCASE' (и 'ZAP') в реестре случаев
    { 'IDSERV',   'C', 36, 0 }, ; //
    { 'ID_U',     'C', 36, 0 }, ; //
    { 'LPU',      'C',  6, 0 }, ; //
    { 'LPU_1',    'C',  8, 0 }, ; //
    { 'PODR',     'C',  8, 0 }, ; //
    { 'PROFIL',   'C',  3, 0 }, ; //
    { 'VID_VME',  'C', 20, 0 }, ; //
    { 'DET',      'C',  1, 0 }, ; //
    { 'P_OTK',    'C',  1, 0 }, ; //
    { 'DATE_IN',  'C', 10, 0 }, ; //
    { 'DATE_OUT', 'C', 10, 0 }, ; //
    { 'DS',       'C',  6, 0 }, ; //
    { 'CODE_USL', 'C', 20, 0 }, ; //
    { 'KOL_USL',  'C',  6, 0 }, ; //
    { 'TARIF',    'C', 10, 0 }, ; //
    { 'SUMV_USL', 'C', 10, 0 }, ; //
    { 'USL_TIP',  'C',  1, 0 }, ; // Тип онкоуслуги в соответствии со справочником N013
    { 'HIR_TIP',  'C',  1, 0 }, ; // Тип хирургического лечения При USL_TIP=1 в соответствии со справочником N014
    { 'LEK_TIP_L','C',  1, 0 }, ; // Линия лекарственной терапии При USL_TIP=2 в соответствии со справочником N015
    { 'LEK_TIP_V','C',  1, 0 }, ; // Цикл лекарственной терапии       При USL_TIP=2 в соответствии со справочником N016
    { 'LUCH_TIP', 'C',  1, 0 }, ; // Тип лучевой терапии      При USL_TIP=3,4 в соответствии со справочником N017
    { 'PRVS',     'C',  9, 0 }, ; //
    { 'CODE_MD',  'C', 16, 0 }, ; //
    { 'COMENTU',  'C',250, 0 } ;  //
  }
  Local _table3 := { ;
    { 'KOD',      'N',  6, 0 }, ; // код
    { 'ID_PAC',   'C', 36, 0 }, ; // код записи о пациенте ;GUID пациента в листе учета;создается при добавлении записи
    { 'FAM',      'C', 40, 0 }, ; //
    { 'IM',       'C', 40, 0 }, ; //
    { 'OT',       'C', 40, 0 }, ; //
    { 'W',        'C',  1, 0 }, ; //
    { 'DR',       'C', 10, 0 }, ; //
    { 'DOST',     'C',  1, 0 }, ; //
    { 'TEL',      'C', 10, 0 }, ; //
    { 'FAM_P',    'C', 40, 0 }, ; //
    { 'IM_P',     'C', 40, 0 }, ; //
    { 'OT_P',     'C', 40, 0 }, ; //
    { 'W_P',      'C',  1, 0 }, ; //
    { 'DR_P',     'C', 10, 0 }, ; //
    { 'DOST_P',   'C',  1, 0 }, ; //
    { 'MR',       'C', 100, 0 }, ; //
    { 'DOCTYPE',  'C',  2, 0 }, ; //
    { 'DOCSER',   'C', 10, 0 }, ; //
    { 'DOCNUM',   'C', 20, 0 }, ; //
    { 'DOCDATE',  'C', 10, 0 }, ; //
    { 'DOCORG',   'C',255, 0 }, ; //
    { 'SNILS',    'C', 14, 0 }, ; //
    { 'OKATOG',   'C', 11, 0 }, ; //
    { 'OKATOP',   'C', 11, 0 } ; //
  }

  dbCreate( cur_dir() + 'tmp_r_t1', _table1 )
  dbCreate( cur_dir() + 'tmp_r_t2', _table2 )
  dbCreate( cur_dir() + 'tmp_r_t3', _table3 )
  return nil
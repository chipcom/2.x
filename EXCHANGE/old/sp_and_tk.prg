#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 27.04.20 зачитать реестр СП и ТК во временные файлы 
Function reestr_sp_tk_tmpfile( oXmlDoc, aerr, mname_xml )

  Local j, j1, _ar, s, oXmlNode, oNode1, oNode2, buf := save_maxrow()

  Default aerr TO {}, mname_xml To ''
  stat_msg( 'Распаковка/чтение/анализ реестра СП и ТК ' + BeforAtNum( '.', mname_xml ) )
  dbCreate( cur_dir() + 'tmp1file', { ;
    { '_VERSION',   'C',  5, 0 }, ;
    { '_DATA',      'D',  8, 0 }, ;
    { '_FILENAME',  'C', 26, 0 }, ;
    { '_CODE',      'N',  8, 0 }, ;
    { '_CODE_MO',   'C',  6, 0 }, ;
    { '_YEAR',      'N',  4, 0 }, ;
    { '_MONTH',     'N',  2, 0 }, ;
    { '_NSCHET',    'C', 15, 0 }, ;
    { '_DSCHET',    'D',  8, 0 }, ;
    { 'KOL1',       'N',  6, 0 }, ;
    { 'KOL2',       'N',  6, 0 };
    } )
  dbCreate( cur_dir() + 'tmp2file', { ;
    { '_N_ZAP',     'N',  8, 0 }, ;
    { '_ID_PAC',    'C', 36, 0 }, ;
    { '_VPOLIS',    'N',  1, 0 }, ;
    { '_SPOLIS',    'C', 10, 0 }, ;
    { '_NPOLIS',    'C', 20, 0 }, ;
    { '_ENP',       'C', 16, 0 }, ;
    { '_SMO',       'C',  5, 0 }, ;
    { '_SMO_OK',    'C',  5, 0 }, ;
    { '_MO_PR',     'C',  6, 0 }, ;
    { 'KOD_HUMAN',  'N',  7, 0 }, ; // код по БД листов учёта
    { 'FIO',        'C', 50, 0 }, ;
    { 'SCHET_CHAR', 'C',  1, 0 }, ; // пусто, буква 'M', или буква 'D'
    { 'SCHET',      'N',  6, 0 }, ; // код счета
    { 'SCHET_ZAP',  'N',  6, 0 }, ; // номер позиции записи в счете
    { '_IDCASE',    'N',  8, 0 }, ;
    { '_ID_C',      'C', 36, 0 }, ;
    { '_IDENTITY',  'N',  1, 0 }, ;
    { 'CORRECT',    'C',  2, 0 }, ;
    { '_FAM',       'C', 40, 0 }, ; //
    { '_IM',        'C', 40, 0 }, ; //
    { '_OT',        'C', 40, 0 }, ; //
    { '_DR',        'C', 10, 0 }, ; //
    { '_OPLATA',    'N',  1, 0 };
    } )
  dbCreate( cur_dir() + 'tmp3file', { ;
    { '_N_ZAP',     'N',  8, 0 }, ;
    { '_REFREASON', 'N',  3, 0 }, ;
    { 'SREFREASON', 'C', 12, 0 };
    } )
  Use ( cur_dir() + 'tmp1file' ) New Alias TMP1
  Append Blank
  Use ( cur_dir() + 'tmp2file' ) New Alias TMP2
  Use ( cur_dir() + 'tmp3file' ) New Alias TMP3
  For j := 1 To Len( oXmlDoc:aItems[ 1 ]:aItems )
    @ MaxRow(), 1 Say PadR( lstr( j ), 6 ) Color cColorSt2Msg
    oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
    Do Case
    Case 'ZGLV' == oXmlNode:title
      tmp1->_VERSION :=          mo_read_xml_stroke( oXmlNode, 'VERSION', aerr )
      tmp1->_DATA    := xml2date( mo_read_xml_stroke( oXmlNode, 'DATA',    aerr ) )
      tmp1->_FILENAME :=          mo_read_xml_stroke( oXmlNode, 'FILENAME', aerr )
    Case 'SCHET' == oXmlNode:title
      tmp1->_CODE    :=      Val( mo_read_xml_stroke( oXmlNode, 'CODE',   aerr ) )
      tmp1->_CODE_MO :=          mo_read_xml_stroke( oXmlNode, 'CODE_MO', aerr )
      tmp1->_YEAR    :=      Val( mo_read_xml_stroke( oXmlNode, 'YEAR',   aerr ) )
      tmp1->_MONTH   :=      Val( mo_read_xml_stroke( oXmlNode, 'MONTH',  aerr ) )
      tmp1->_NSCHET  :=          mo_read_xml_stroke( oXmlNode, 'NSCHET', aerr )
      tmp1->_DSCHET  := xml2date( mo_read_xml_stroke( oXmlNode, 'DSCHET', aerr ) )
    Case 'ZAP' == oXmlNode:title
      Select TMP2
      Append Blank
      tmp2->_N_ZAP := Val( mo_read_xml_stroke( oXmlNode, 'N_ZAP', aerr ) )
      If ( oNode1 := oXmlNode:find( 'PACIENT' ) ) == NIL
        AAdd( aerr, 'Отсутствует значение обязательного тэга "PACIENT"' )
      Else
        tmp2->_ID_PAC := Upper( mo_read_xml_stroke( oNode1, 'ID_PAC', aerr ) )
        tmp2->_VPOLIS :=   Val( mo_read_xml_stroke( oNode1, 'VPOLIS', aerr ) )
        tmp2->_SPOLIS :=       mo_read_xml_stroke( oNode1, 'SPOLIS', aerr, .f. )
        tmp2->_NPOLIS :=       mo_read_xml_stroke( oNode1, 'NPOLIS', aerr )
        tmp2->_ENP    :=       mo_read_xml_stroke( oNode1, 'ENP', aerr, .f. )
        tmp2->_SMO    :=       mo_read_xml_stroke( oNode1, 'SMO', aerr )
        tmp2->_SMO_OK :=       mo_read_xml_stroke( oNode1, 'SMO_OK', aerr )
        tmp2->_MO_PR  :=       mo_read_xml_stroke( oNode1, 'MO_PR', aerr, .f. )
        tmp2->_IDENTITY := Val( mo_read_xml_stroke( oNode1, 'IDENTITY', aerr, .f. ) )
        If Empty( tmp2->_MO_PR )
          tmp2->_MO_PR := Replicate( '0', 6 )
        Endif
        If ( oNode2 := oNode1:find( 'CORRECTION' ) ) != NIL
          tmp2->_FAM := mo_read_xml_stroke( oNode2, 'FAM', aerr, .f. )
          tmp2->_IM  := mo_read_xml_stroke( oNode2, 'IM', aerr, .f. )
          tmp2->_OT  := mo_read_xml_stroke( oNode2, 'OT', aerr, .f. )
          tmp2->_DR  := mo_read_xml_stroke( oNode2, 'DR', aerr, .f. )
          If oNode2:find( 'OT' ) != Nil .and. Empty( tmp2->_OT )
            tmp2->CORRECT := 'OT' // т.е. пустое отчество
          Endif
        Endif
      Endif
      If AllTrim( tmp1->_VERSION ) == '3.11'
        If ( oNode1 := oXmlNode:find( 'Z_SL' ) ) == NIL
          AAdd( aerr, 'Отсутствует значение обязательного тэга "Z_SL"' )
        Endif
      Else
        If ( oNode1 := oXmlNode:find( 'SLUCH' ) ) == NIL
          AAdd( aerr, 'Отсутствует значение обязательного тэга "SLUCH"' )
        Endif
      Endif
      If oNode1 != NIL
        tmp2->_IDCASE :=   Val( mo_read_xml_stroke( oNode1, 'IDCASE', aerr ) )
        tmp2->_ID_C   := Upper( mo_read_xml_stroke( oNode1, 'ID_C', aerr ) )
        tmp2->_OPLATA :=   Val( mo_read_xml_stroke( oNode1, 'OPLATA', aerr ) )
        If tmp2->_OPLATA > 1
          _ar := mo_read_xml_array( oNode1, 'REFREASON' )
          For j1 := 1 To Len( _ar )
            Select TMP3
            Append Blank
            tmp3->_N_ZAP := tmp2->_N_ZAP
            s := AllTrim( _ar[ j1 ] )
            If Len( s ) > 3 .or. '.' $ s
              tmp3->SREFREASON := s
            Else
              tmp3->_REFREASON := Val( s )
            Endif
          Next
        Endif
      Endif
    Endcase
  Next j
  Commit
  rest_box( buf )
  Return Nil

// 15.10.24 удалить счет(а) по одному реестру СП и ТК и по этим людям создать заново счета (м.б.другое кол-во счетов)
Function recreate_some_schet_from_file_sp( arr )

  Local arr_XML_info[ 8 ], cFile, arr_f, k, n, oXmlDoc, aerr := {}, t_arr[ 2 ], ;
    i, s, go_to_schet := .f., arr_schet := {}

  Private name_schet, _date_schet, mXML_REESTR

  For i := 1 To Len( arr )
    Select SCHET
    Goto ( arr[ i ] )
    If emptyany( schet_->name_xml, schet_->kod_xml ) .or. schet_->IS_MODERN == 1
      Return func_error( 4, "Некорректно заполнены поля счёта " + RTrim( schet_->nschet ) + ". Операция запрещена." )
    Endif
    If i == 1
      mXML_REESTR := schet_->XML_REESTR // ссылка на реестр СП и ТК
    Elseif mXML_REESTR != schet_->XML_REESTR
      Return func_error( 4, "Счёт " + RTrim( schet_->nschet ) + " из другого реестра СП и ТК. Операция запрещена." )
    Endif
    AAdd( arr_schet, { ;
      arr[ i ], ;                  // 1 - schet->(recno())
      schet_->kod_xml, ;         // 2 - ссылка на файл "mo_xml"
      schet_->name_xml, ;        // 3 - имя XML-файла без расширения (и ZIP-архива)
      AllTrim( schet_->nschet ), ; // 4 - номер счета
    schet_->dschet ;          // 5 - дата формирования счета
      } )
  Next
  //
  mo_xml->( dbGoto( mXML_REESTR ) )
  If Empty( mo_xml->REESTR )
    Return func_error( 4, "Отсутствует ссылка на первичный реестр! Операция запрещена." )
  Endif
  Private cReadFile := AllTrim( mo_xml->FNAME ) // имя файла реестра СП и ТК
  Private cFileProtokol := cReadFile + stxt()     // имя файла протокола чтения реестра СП и ТК
  Private mkod_reestr := mo_xml->REESTR       // код первичного реестра
  Private cTimeBegin := hour_min( Seconds() )
  Private name_zip := cReadFile + szip()          // имя архива файла реестра СП и ТК
  cFile := cReadFile + sxml()                     // имя XML-файла реестра СП и ТК
  //
  rees->( dbGoto( mkod_reestr ) )
  Private name_reestr := AllTrim( rees->name_xml ) + szip() // имя архива файла первичного реестра
  // распаковываем первичный реестр
  If ( arr_f := extract_zip_xml( dir_server() + dir_XML_MO() + hb_ps(), name_reestr ) ) == NIL
    Return func_error( 4, "Ошибка в распаковке архива реестра " + name_reestr )
  Endif
  // распаковываем реестр СП и ТК
  If ( arr_f := extract_zip_xml( dir_server() + dir_XML_TF() + hb_ps(), name_zip ) ) == NIL
    Return func_error( 4, "Ошибка в распаковке архива реестра СП и ТК " + name_zip )
  Endif
  If ( n := AScan( arr_f, {| x| Upper( name_without_ext( x ) ) == Upper( cReadFile ) } ) ) == 0
    Return func_error( 4, "В архиве " + name_zip + " нет файла " + cReadFile + sxml() )
  Endif
  Close databases

  If mo_lock_task( X_OMS ) // запрет только ОМС G_SLock1Task(sem_task(),sem_vagno()) // запрет доступа всем
    k := Len( arr_schet )
    s := iif( k == 1, "счёта ", lstr( k ) + " счетов " )
    If iif( arr_schet[ 1, 5 ] > SToD( "20220224" ) .and. arr_schet[ 1, 5 ] < SToD( "20220228" ), .t., involved_password( 3, arr_schet[ 1, 4 ], "пересоздания " + s + arr_schet[ 1, 4 ] ) ) ;
        .and. f_esc_enter( "пересоздания " + s ) // .and. m_copy_DB_from_end(.t.) // резервное копирование
      Private fl_open := .t.
      index_base( "schet" ) // для составления счетов
      index_base( "human" ) // для разноски счетов
      index_base( "human_3" ) // двойные случаи
      Use ( dir_server() + "human_u" ) New READONLY
      Index On Str( FIELD->kod, 7 ) + FIELD->date_u to ( dir_server() + "human_u" ) progress
      Use
      Use ( dir_server() + "mo_hu" ) New READONLY
      Index On Str( FIELD->kod, 7 ) + FIELD->date_u to ( dir_server() + "mo_hu" ) progress
      Use
      index_base( "mo_refr" )  // для записи причин отказов
      //
      mywait()
      StrFile( hb_eol() + ;
        Space( 10 ) + "Повторная обработка файла: " + cFile + ;
        hb_eol(), cFileProtokol )
      StrFile( Space( 10 ) + full_date( sys_date ) + "г. " + cTimeBegin + ;
        hb_eol(), cFileProtokol, .t. )
      mywait( "Производится анализ файла " + cFile )
      // читаем файл в память
      oXmlDoc := hxmldoc():read( _tmp_dir1() + cFile )
      If oXmlDoc == Nil .or. Empty( oXmlDoc:aItems )
        AAdd( aerr, "Ошибка в чтении файла " + cFile )
      Else
        reestr_sp_tk_tmpfile( oXmlDoc, aerr, cReadFile )
      Endif
      If Empty( aerr )
        r_use( dir_server() + "mo_rees",, "REES" )
        Goto ( mkod_reestr )
        If !extract_reestr( rees->( RecNo() ), rees->name_xml )
          AAdd( aerr, Center( "Не найден ZIP-архив с РЕЕСТРом № " + lstr( mnschet ) + " от " + date_8( tmp1->_DSCHET ), 80 ) )
          AAdd( aerr, "" )
          AAdd( aerr, Center( dir_server() + dir_XML_MO() + hb_ps() + AllTrim( rees->name_xml ) + szip(), 80 ) )
          AAdd( aerr, "" )
          AAdd( aerr, Center( "Без данного архива дальнейшая работа НЕВОЗМОЖНА!", 80 ) )
        Endif
      Endif
      Close databases
      If Empty( aerr )
        dbCreate( cur_dir() + "tmpsh", { { "kod_h", "N", 7, 0 } } )
        Use ( cur_dir() + "tmpsh" ) new
        r_use( dir_server() + "human", dir_server() + "humans", "HUMAN" )
        For i := 1 To Len( arr_schet )
          find ( Str( arr_schet[ i, 1 ], 6 ) )
          Do While human->schet == arr_schet[ i, 1 ] .and. !Eof()
            Select tmpsh
            Append Blank
            Replace kod_h With human->kod
            Select HUMAN
            Skip
          Enddo
        Next
        Select tmpsh
        Index On Str( FIELD->kod_h, 7 ) to ( cur_dir() + "tmpsh" )
        r_use( dir_server() + "mo_rhum",, "RHUM" )
        Index On Str( FIELD->REES_ZAP, 6 ) to ( cur_dir() + "tmp_rhum" ) For FIELD->reestr == mkod_reestr
        // открыть распакованный реестр
        Use ( cur_dir() + "tmp_r_t1" ) New Alias T1
        Index On Str( Val( FIELD->n_zap ), 6 ) to ( cur_dir() + "tmpt1" )
        Use ( cur_dir() + "tmp_r_t2" ) New Alias T2
        Index On FIELD->IDCASE + Str( FIELD->sluch, 6 ) to ( cur_dir() + "tmpt2" )
        Use ( cur_dir() + "tmp_r_t3" ) New Alias T3
        Index On Upper( FIELD->ID_PAC ) to ( cur_dir() + "tmpt3" )
        Use ( cur_dir() + "tmp_r_t4" ) New Alias T4
        Index On FIELD->IDCASE + Str( FIELD->sluch, 6 ) to ( cur_dir() + "tmpt4" )
        Use ( cur_dir() + "tmp_r_t5" ) New Alias T5
        Index On FIELD->IDCASE + Str( FIELD->sluch, 6 ) to ( cur_dir() + "tmpt5" )
        Use ( cur_dir() + "tmp_r_t6" ) New Alias T6
        Index On FIELD->IDCASE + Str( FIELD->sluch, 6 ) to ( cur_dir() + "tmpt6" )
        Use ( cur_dir() + "tmp_r_t7" ) New Alias T7
        Index On FIELD->IDCASE + Str( FIELD->sluch, 6 ) to ( cur_dir() + "tmpt7" )
        Use ( cur_dir() + "tmp_r_t8" ) New Alias T8
        Index On FIELD->IDCASE + Str( FIELD->sluch, 6 ) to ( cur_dir() + "tmpt8" )
        Use ( cur_dir() + "tmp_r_t9" ) New Alias T
        Index On FIELD->IDCASE + Str( FIELD->sluch, 6 ) to ( cur_dir() + "tmpt9" )
        Use ( cur_dir() + "tmp_r_t10" ) New Alias T10
        Index On FIELD->IDCASE + Str( FIELD->sluch, 6 ) + FIELD->regnum + FIELD->code_sh + FIELD->date_inj to ( cur_dir() + "tmpt10" )
        Use ( cur_dir() + "tmp_r_t11" ) New Alias T11
        Index On FIELD->IDCASE + Str( FIELD->sluch, 6 ) to ( cur_dir() + "tmpt11" )
        Use ( cur_dir() + "tmp_r_t12" ) New Alias T12
        Index On FIELD->IDCASE + Str( FIELD->sluch, 6 ) to ( cur_dir() + "tmpt12" )
        Use ( cur_dir() + "tmp_r_t1_1" ) New Alias T1_1
        Index On FIELD->IDCASE to ( cur_dir() + "tmpt1_1" )
        Use ( cur_dir() + "tmp2file" ) New Alias TMP2
        is_new_err := .f.  // ушли ли какие-либо случаи в ошибки (т.е. новые ошибки)
        Go Top
        Do While !Eof()
          If tmp2->_OPLATA == 1
            Select T1
            find ( Str( tmp2->_N_ZAP, 6 ) )
            If Found()
              t1->VPOLIS := lstr( tmp2->_VPOLIS )
              t1->SPOLIS := tmp2->_SPOLIS
              t1->NPOLIS := tmp2->_NPOLIS
              t1->ENP    := tmp2->_ENP
              t1->SMO    := tmp2->_SMO
              t1->SMO_OK := tmp2->_SMO_OK
              t1->MO_PR  := tmp2->_MO_PR
            Endif
          Endif
          Select RHUM
          find ( Str( tmp2->_N_ZAP, 6 ) )
          If Found() .and. rhum->KOD_HUM > 0
            Select tmpsh
            find ( Str( rhum->KOD_HUM, 7 ) )
            If Found()
              tmp2->kod_human := rhum->KOD_HUM
              If tmp2->_OPLATA > 1
                is_new_err := .t. // т.е. в новом реестре СП и ТК человек ушёл в ошибки (а раньше попадал в счёт)
              Endif
            Endif
          Else
            AAdd( aerr, "" )
            AAdd( aerr, " - не найден пациент с номером записи " + lstr( tmp2->_N_ZAP ) )
          Endif
          Select TMP2
          Skip
        Enddo
        Select TMP2
        Delete For kod_human == 0 // удалим тех, кто не входит в выбранные счета
        Pack
      Endif
      Close databases
      If Empty( aerr ) .and. is_new_err
        r_use( dir_server() + 'mo_otd',, 'OTD' )
        g_use( dir_server() + "human_",, "HUMAN_" )
        g_use( dir_server() + "human", { dir_server() + "humann", dir_server() + "humans" }, "HUMAN" )
        Set Order To 0 // индексы открыты для реконструкции при перезаписи ФИО
        Set Relation To RecNo() into HUMAN_, To FIELD->otd into OTD
        g_use( dir_server() + "human_3", { dir_server() + "human_3", dir_server() + "human_32" }, "HUMAN_3" )
        g_use( dir_server() + "mo_rhum",, "RHUM" )
        Index On Str( FIELD->REES_ZAP, 6 ) to ( cur_dir() + "tmp_rhum" ) For FIELD->reestr == mkod_reestr
        g_use( dir_server() + "mo_refr", dir_server() + "mo_refr", "REFR" )
        Use ( cur_dir() + "tmp3file" ) New Alias TMP3
        Index On Str( FIELD->_n_zap, 8 ) to ( cur_dir() + "tmp3" )
        Use ( cur_dir() + "tmp2file" ) New Alias TMP2
        Go Top
        Do While !Eof()
          If tmp2->_OPLATA > 1 // удаляем из счёта, удаляем из реестра, оформляем ошибку
            Select RHUM
            find ( Str( tmp2->_N_ZAP, 6 ) )
            g_rlock( forever )
            rhum->OPLATA := tmp2->_OPLATA
            is_2 := 0
            Select HUMAN
            Goto ( rhum->KOD_HUM )
            If eq_any( human->ishod, 88, 89 )
              Select HUMAN_3
              If human->ishod == 88
                Set Order To 1
                is_2 := 1
              Else
                Set Order To 2
                is_2 := 2
              Endif
              find ( Str( rhum->KOD_HUM, 7 ) )
              If Found() // если нашли двойной случай
                Select HUMAN
                If human->ishod == 88  // если реестр составлен по 1-му листу
                  Goto ( human_3->kod2 )  // встать на 2-ой
                Else
                  Goto ( human_3->kod )   // иначе - на 1-ый
                Endif
                human->( g_rlock( forever ) )
                human->schet := 0 ; human->tip_h := B_STANDART
                //
                human_->( g_rlock( forever ) )
                human_->OPLATA := tmp2->_OPLATA
                human_->REESTR := 0 // направляется на дальнейшее редактирование
                human_->ST_VERIFY := 0 // снова ещё не проверен
                If human_->REES_NUM > 0
                  human_->REES_NUM := human_->REES_NUM - 1
                Endif
                human_->REES_ZAP := 0
                If human_->schet_zap > 0
                  If human_->SCHET_NUM > 0
                    human_->SCHET_NUM := human_->SCHET_NUM - 1
                  Endif
                  human_->schet_zap := 0
                Endif
                //
                human_3->( g_rlock( forever ) )
                human_3->OPLATA := tmp2->_OPLATA
                human_3->schet := 0
                human_3->REESTR := 0
                If human_3->REES_NUM > 0
                  human_3->REES_NUM := human_3->REES_NUM - 1
                Endif
                human_3->REES_ZAP := 0
                If human_3->SCHET_NUM > 0
                  human_3->SCHET_NUM := human_3->SCHET_NUM -1
                Endif
                human_3->schet_zap := 0
              Endif
            Endif
            Select HUMAN
            Goto ( rhum->KOD_HUM )
            g_rlock( forever )
            human->schet := 0 ; human->tip_h := B_STANDART
            human_->( g_rlock( forever ) )
            human_->OPLATA := tmp2->_OPLATA
            human_->REESTR := 0 // а направляется на дальнейшее редактирование
            human_->ST_VERIFY := 0 // снова ещё не проверен
            If human_->REES_NUM > 0
              human_->REES_NUM := human_->REES_NUM - 1
            Endif
            human_->REES_ZAP := 0
            If human_->SCHET_NUM > 0
              human_->SCHET_NUM := human_->SCHET_NUM - 1
            Endif
            human_->schet_zap := 0
            //
            lal := "human"
            If is_2 > 0
              lal += "_3"
            Endif
            StrFile( "!!! " + AllTrim( human->fio ) + ", " + full_date( human->date_r ) + ;
              iif( Empty( otd->SHORT_NAME ), "", " [" + AllTrim( otd->SHORT_NAME ) + "]" ) + ;
              " " + AllTrim( human->KOD_DIAG ) + ;
              " " + date_8( &lal.->n_data ) + "-" + date_8( &lal.->k_data ) + ;
              hb_eol(), cFileProtokol, .t. )
            Select REFR
            Do While .t.
              find ( Str( 1, 1 ) + Str( mkod_reestr, 6 ) + Str( 1, 1 ) + Str( rhum->KOD_HUM, 8 ) )
              If !Found() ; exit ; Endif
              deleterec( .t. )
            Enddo
            Select TMP3
            find ( Str( tmp2->_N_ZAP, 8 ) )
            Do While tmp2->_N_ZAP == tmp3->_N_ZAP .and. !Eof()
              Select REFR
              addrec( 1 )
              refr->TIPD := 1
              refr->KODD := mkod_reestr
              refr->TIPZ := 1
              refr->KODZ := rhum->KOD_HUM
              refr->IDENTITY := tmp2->_IDENTITY
              refr->REFREASON := tmp3->_REFREASON
              refr->SREFREASON := tmp3->SREFREASON
              If Empty( refr->SREFREASON )
                If Empty( s := ret_t005( refr->REFREASON ) )
                  s := lstr( refr->REFREASON ) + ' неизвестная причина отказа'
                Endif
              Else
                s := 'код ошибки = ' + tmp3->SREFREASON + ' '
                s += '"' + getcategorycheckerrorbyid_q017( Left( tmp3->SREFREASON, 4 ) )[ 2 ] + '" '
                // s += alltrim(inieditspr(A__POPUPMENU, dir_exe() + "_mo_Q015", tmp3->SREFREASON))
                s += AllTrim( inieditspr( A__MENUVERT, loadq015(), tmp3->SREFREASON ) )
              Endif
              k := perenos( t_arr, s, 75 )
              For i := 1 To k
                StrFile( Space( 5 ) + t_arr[ i ] + hb_eol(), cFileProtokol, .t. )
              Next
              Select TMP3
              Skip
            Enddo
            If is_2 > 0
              StrFile( Space( 5 ) + '- разбейте двойной случай в режиме "ОМС/Двойные случаи/Разделить"' + ;
                hb_eol(), cFileProtokol, .t. )
              StrFile( Space( 5 ) + '- отредактируйте каждый из случаев в режиме "ОМС/Редактирование"' + ;
                hb_eol(), cFileProtokol, .t. )
              StrFile( Space( 5 ) + '- снова соберите случай в режиме "ОМС/Двойные случаи/Создать"' + ;
                hb_eol(), cFileProtokol, .t. )
            Endif
          Endif
          Select TMP2
          Skip
        Enddo
        Close databases
        StrFile( hb_eol(), cFileProtokol, .t. )
      Endif
      If Empty( aerr )
        arr_f := {}
        // создадим новые счета
        go_to_schet := create_schet_from_xml( arr_XML_info, aerr,, arr_f, cReadFile )
        Close databases
        If Empty( aerr ) // если нет ошибок
          use_base( "schet" )
          Set Relation To
          g_use( dir_server() + "mo_xml",, "MO_XML" )
          // удалим старые счета
          For i := 1 To Len( arr_schet )
            StrFile( hb_eol() + ;
              "удалён старый счёт № " + arr_schet[ i, 4 ] + " от " + full_date( arr_schet[ i, 5 ] ) + ;
              hb_eol(), cFileProtokol, .t. )
            Select SCHET_
            Goto ( arr_schet[ i, 1 ] )
            deleterec( .t., .f. )  // без пометки на удаление
            //
            Select SCHET
            Goto ( arr_schet[ i, 1 ] )
            deleterec( .t. )
            //
            Select MO_XML
            Goto ( arr_schet[ i, 2 ] )
            deleterec( .t. )
          Next
          Close databases
        Endif
      Endif
      If Empty( aerr )
        // дозапишем предыдущий файл протокола обработки новым протоколом
        f_append_file( dir_server() + dir_XML_TF() + hb_ps() + cFileProtokol, cFileProtokol )
        viewtext( devide_into_pages( dir_server() + dir_XML_TF() + hb_ps() + cFileProtokol, 60, 80 ),,,, .t.,,, 2 )
      Else
        AEval( aerr, {| x| StrFile( x + hb_eol(), cFileProtokol, .t. ) } )
        viewtext( devide_into_pages( cFileProtokol, 60, 80 ),,,, .t.,,, 2 )
      Endif
      Delete File ( cFileProtokol )
    Endif
    Close databases
    // разрешение доступа всем
    // G_SUnLock(sem_vagno())
    mo_unlock_task( X_OMS )
    Keyboard ""
    If go_to_schet // если выписаны счета
      Keyboard Chr( K_ENTER )
    Endif
  Else
    func_error( 4, "В данный момент работают другие задачи. Операция запрещена!" )
  Endif
  Return Nil

// 08.02.23 дополнить файл ofile строками из файла nfile
Function f_append_file( ofile, nfile )

  Local s

  ft_use( nfile )
  ft_gotop()
  Do While !ft_eof()
    s := ft_readln()
    StrFile( s + hb_eol(), ofile, .t. )
    ft_skip()
  Enddo
  ft_use()
  Return Nil

#define BASE_ISHOD_RZD 500  //

// 20.11.25
Function create1reestr19( _recno, _nyear, _nmonth, p_tip_reestr )

  Local buf := SaveScreen(), i, j, pole
  local lenPZ := 0  // кол-во строк план заказа на год составления реестра
  local reg_sort

  Private mpz, oldpz, atip

  lenPZ := len( p_array_PZ )

  mpz := Array( lenPZ + 1 )
  oldpz := Array( lenPZ + 1 )
  atip := Array( lenPZ + 1 )

  For j := 0 To lenPZ    // для таблицы _moXunit 03.02.23
    pole := 'tmp->PZ' + lstr( j )
    mpz[ j + 1 ] := oldpz[ j + 1 ] := &pole
    atip[ j + 1 ] := '-'
    If ( i := AScan( p_array_PZ, {| x| x[ 1 ] == j } ) ) > 0
      atip[ j + 1 ] := p_array_PZ[ i, 4 ]
    Endif
  Next

  Private pkol := tmp->kol, psumma := tmp->summa, pnyear := _nyear
  Private old_kol := pkol, old_summa := psumma
  private p_blk := {| mkol, msum| f_blk_create1reestr19() }

  dbCloseAll()
  r_use( dir_server() + 'human_3', { dir_server() + 'human_3', dir_server() + 'human_32' }, 'HUMAN_3' )
  Set Order To 2
  r_use( dir_server() + 'human_', , 'HUMAN_' )
  r_use( dir_server() + 'human', , 'HUMAN' )
  Set Relation To RecNo() into HUMAN_
  Use ( cur_dir() + 'tmpb' ) New Alias TMP
  Set Relation To FIELD->kod_human into HUMAN
  Index On Upper( human->fio ) + DToS( tmp->k_data ) to ( cur_dir() + 'tmpb' ) For FIELD->kod_tmp == _recno
  Go Top
  Eval( p_blk )
  If alpha_browse( 3, 0, MaxRow() -4, 79, 'f1create1reestr19', color0, ;
      'Составление реестра случаев за ' + mm_month()[ _nmonth ] + Str( _nyear, 5 ) + ' года', 'BG+/GR', ;
      .t., .t., , , 'f2create1reestr19', , ;
      { '═', '░', '═', 'N/BG, W+/N, B/BG, W+/B', , 300 } )
    If pkol > 0 .and. ( reg_sort := f_alert( { '', ;
        'Каким образом сортировать реестр, отправляемый в ТФОМС', ;
        '' }, ;
        { ' по ~ФИО пациента ', ' по ~убыванию стоимости ' }, ;
        1, 'W/RB', 'G+/RB', MaxRow() -6, , 'BG+/RB, W+/R, W+/RB, GR+/R' ) ) > 0
      f_message( { 'Системная дата: ' + date_month( sys_date, .t. ), ;
        'Обращаем Ваше внимание, что', ;
        'реестр будет создан с этой датой.', ;
        '', ;
        'Изменить её будет НЕВОЗМОЖНО!', ;
        '', ;
        'Сортировка реестра: ' + { 'по ФИО пациента', 'по убыванию стоимости лечения' }[ reg_sort ] }, , ;
        'GR+/R', 'W+/R' )
      If f_esc_enter( 'составления реестра' )
        RestScreen( buf )
        create2reestr19( _recno, _nyear, _nmonth, reg_sort, p_tip_reestr )
      Endif
    Endif
  Endif
  dbCloseAll()
  RestScreen( buf )
  Return Nil

// 03.01.26
Function f_blk_create1reestr19()  // 

  Local i, s, ta[ 2 ], sh := MaxCol() + 1

  s := 'Случаев - ' + expand_value( pkol ) + ' на сумму ' + expand_value( psumma, 2 ) + ' руб.'
  @ 0, 0 Say PadC( s, sh ) Color color1
  s := ''
  For i := 1 To Len( mpz )
    If !Empty( mpz[ i ] )
      s += AllTrim( str_0( mpz[ i ], 9, 2 ) ) + ' ' + atip[ i ] + ', '
    Endif
  Next
  If !Empty( s )
    s := '(п/з: ' + SubStr( s, 1, Len( s ) -2 ) + ')'
  Endif
  perenos( ta, s, sh )
  For i := 1 To 2
    @ i, 0 Say PadC( AllTrim( ta[ i ] ), sh ) Color color1
  Next
  Return Nil

// 11.12.25
Function f1create1reestr19( oBrow )

  Local oColumn, tmp_color, blk_color := {|| if( tmp->plus, { 1, 2 }, { 3, 4 } ) }, n := 32

  oColumn := TBColumnNew( ' ', {|| if( tmp->plus, '', ' ' ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( Center( 'Ф.И.О. больного', n ), {|| iif( tmp->ishod == 89, PadR( Upper( human->fio ), n -4 ) + ' 2сл', PadR( Upper( human->fio ), n ) ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'План-заказ', {|| PadC( f_p_z19( tmp->pzkol, tmp->pz, 1 ), 10 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Кол-во', {|| PadC( f_p_z19( tmp->pzkol, tmp->pz, 2 ), 6 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Нача-; ло', {|| Left( DToC( tmp->n_data ), 5 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Окончан.;лечения', {|| date_8( tmp->k_data ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( ' Стоимость; лечения', {|| put_kope( tmp->cena_1, 10 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  tmp_color := SetColor( 'N/BG' )
  @ MaxRow() -3, 0 Say PadR( ' <Esc> - выход     <Enter> - подтверждение составления реестра', 80 )
  @ MaxRow() -2, 0 Say PadR( ' <Ins> - отметить одного пациента или снять отметку с одного пациента', 80 )
  @ MaxRow() -1, 0 Say PadR( ' <+> - отметить всех пациентов (или по одному виду ПЛАНА-ЗАКАЗА) ', 80 )
  @ MaxRow() -0, 0 Say PadR( ' <-> - снять со всех отметки (никто не попадает в реестр)', 80 )
  mark_keys( { '<Esc>', '<Enter>', '<Ins>', '<+>', '<->', '<F9>' }, 'R/BG' )
  SetColor( tmp_color )
  Return Nil

// 19.01.20
Function f2create1reestr19( nKey, oBrow )

  Local buf, rec, k := -1, i, j, mas_pmt := {}, arr, r1, r2

  Do Case
  Case nkey == K_INS
    Replace tmp->plus With !tmp->plus
    j := tmp->pz + 1
    i := AScan( p_array_PZ, {| x| x[ 1 ] == tmp->PZ } )
    If tmp->plus
      psumma += tmp->cena_1
      pkol++
      If i > 0 .and. !Empty( p_array_PZ[ i, 5 ] )
        mpz[ j ] ++
      Else
        mpz[ j ] += tmp->PZKOL
      Endif
    Else
      psumma -= tmp->cena_1
      pkol--
      If i > 0 .and. !Empty( p_array_PZ[ i, 5 ] )
        mpz[ j ] --
      Else
        mpz[ j ] -= tmp->PZKOL
      Endif
    Endif
    Eval( p_blk )
    k := 0
    Keyboard Chr( K_TAB )
  Case nkey == 43  // +
    arr := {}
    AAdd( mas_pmt, 'Отметить всех пациентов' )
    AAdd( arr, -1 )
    If !Empty( oldpz[ 1 ] )
      AAdd( mas_pmt, 'Отметить неопределённых пациентов' )
      AAdd( arr, 0 )
    Endif
    For j := 2 To Len( oldpz )
      If !Empty( oldpz[ j ] ) .and. ( i := AScan( p_array_PZ, {| x| x[ 1 ] == j -1 } ) ) > 0
        AAdd( mas_pmt, 'Отметить "' + p_array_PZ[ i, 3 ] + '"' )
        AAdd( arr, j -1 )
      Endif
    Next
    r1 := 12
    r2 := r1 + Len( mas_pmt ) + 1
    If r2 > MaxRow() -2
      r2 := MaxRow() -2
      r1 := r2 - Len( mas_pmt ) -1
      If r1 < 2
        r1 := 2
      Endif
    Endif
    If ( j := popup_scr( r1, 12, r2, 67, mas_pmt, 1, color5, .t. ) ) > 0
      j := arr[ j ]
      rec := RecNo()
      buf := save_maxrow()
      mywait()
      If j == -1
        tmp->( dbEval( {|| tmp->plus := .t. } ) )
        psumma := old_summa
        pkol := old_kol
        AEval( mpz, {| x, i| mpz[ i ] := oldpz[ i ] } )
      Else
        psumma := pkol := 0
        AFill( mpz, 0 )
        mpz[ j + 1 ] := oldpz[ j + 1 ]
        Go Top
        Do While !Eof()
          If tmp->pz == j
            tmp->plus := .t.
            psumma += tmp->cena_1
            pkol++
          Else
            tmp->plus := .f.
          Endif
          Skip
        Enddo
      Endif
      Goto ( rec )
      rest_box( buf )
      Eval( p_blk )
      k := 0
    Endif
  Case nkey == 45  // -
    rec := RecNo()
    buf := save_maxrow()
    mywait()
    tmp->( dbEval( {|| tmp->plus := .f. } ) )
    Goto ( rec )
    rest_box( buf )
    psumma := pkol := 0
    AFill( mpz, 0 )
    Eval( p_blk )
    k := 0
  Endcase
  Return k

// 19.01.20
Function f_p_z19( _pzkol, _pz, k )

  Local s, s2, i

  s2 := AllTrim( str_0( _pzkol, 9, 2 ) )
  s := atip[ _pz + 1 ]
  If ( i := AScan( p_array_PZ, {| x| x[ 1 ] == _pz } ) ) > 0 .and. !Empty( p_array_PZ[ i, 5 ] )
    s2 += p_array_PZ[ i, 5 ]
  Endif
  Return iif( k == 1, s, s2 )

#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 26.08.25 читать файлы из ТФОМС (или СМО)
Function read_from_tf_2025()

  Local name_zip, cName
  local _date, _time, s, arr_f := {}, buf, blk_sp_tk, fl := .f., n, ;
    arr_XML_info[ 7 ], tip_csv_file := 0, kod_csv_reestr := 0
  Local full_zip
  
//  private full_zip  // используется в is_our_zip()

  Private p_var_manager := 'Read_From_TFOMS', p_ctrl_enter_sp_tk := .f.
  If ! hb_user_curUser:isadmin()
    Return func_error( 4, err_admin )
  Endif
  If find_unfinished_reestr_sp_tk()
    Return func_error( 4, 'Попытайтесь снова' )
  Endif
  blk_sp_tk := {|| p_ctrl_enter_sp_tk := .t., __Keyboard( Chr( K_ENTER ) ) }

  SetKey( K_CTRL_ENTER, blk_sp_tk )
  full_zip := manager( T_ROW, T_COL + 5, MaxRow() -2, , .t., 1, , , , '*.zip' )
  SetKey( K_CTRL_ENTER, nil )

  If !Empty( full_zip )
    full_zip := Upper( full_zip )
    name_zip := strippath( full_zip )
    cName := name_without_ext( name_zip )
    // если это укрупнённый архив, распаковать и прочитать
    If ! is_our_zip( full_zip, cName, @tip_csv_file, @kod_csv_reestr )
      Return fl
    Endif
    If tip_csv_file > 0 // если это CSV-файлы прикрепления/открепления
      If ( arr_f := extract_zip_xml( keeppath( full_zip ), name_zip ) ) != NIL
        If ( n := AScan( arr_f, {| x| Upper( name_without_ext( x ) ) == Upper( cName ) } ) ) > 0
          fl := read_csv_from_tf( arr_f[ n ], tip_csv_file, kod_csv_reestr )
        Else
          fl := func_error( 4, 'В архиве ' + name_zip + ' нет файла ' + cName + scsv() )
        Endif
      Endif
      Return Nil
    Endif
    // ещё раз, т.к. может быть переопределена переменная full_zip
    name_zip := strippath( full_zip )
    cName := name_without_ext( name_zip )
    // проверим, а нам ли предназначен данный файл
    If !is_our_xml( cName, arr_XML_info )
      Return fl
    Endif
    // проверим, читали ли уже данный файл
    If verify_is_already_xml( cName, @_date, @_time )
      // спросить надо ли ещё раз читать, т.к. уже читали
      func_error( 4, 'Данный файл уже был прочитан и обработан в ' + _time + ' ' + date_8( _date ) + 'г.' )
      viewtext( devide_into_pages( dir_server() + dir_XML_TF() + hb_ps() + cName + stxt(), 60, 80 ), , , , .t., , , 2 )
      Return fl
    Else
      s := 'чтения '
      Do Case
      Case arr_XML_info[ 1 ] == _XML_FILE_FLK
        s += 'протокола ФЛК'
      Case arr_XML_info[ 1 ] == _XML_FILE_SP
        s += 'реестра СП и ТК'
      Case arr_XML_info[ 1 ] == _XML_FILE_RAK
        s += 'р-ра актов контроля'
      Case arr_XML_info[ 1 ] == _XML_FILE_RPD
        s += 'реестра плат.док-тов'
      Case arr_XML_info[ 1 ] == _XML_FILE_R02
        s += 'файла ответа на R01'
      Case arr_XML_info[ 1 ] == _XML_FILE_R12
        s += 'файла ответа на R11'
      Case arr_XML_info[ 1 ] == _XML_FILE_R06
        s += 'файла ответа на R05'
      Case arr_XML_info[ 1 ] == _XML_FILE_D02
        s += 'файла ответа на D01'
      Case arr_XML_info[ 1 ] == _XML_FILE_FLK_25
        s += 'протокола ФЛК 2025'
      Endcase
      buf := SaveScreen()
      f_message( { 'Системная дата: ' + date_month( Date(), .t. ), ;
        'Обращаем Ваше внимание, что после', ;
        s, ;
        'все документы будут созданы с этой датой.', ;
        '', ;
        'Изменить их будет НЕВОЗМОЖНО!' }, , 'R/R*', 'N/R*' )
      fl := .t.
      If arr_XML_info[ 1 ] == _XML_FILE_SP .and. p_ctrl_enter_sp_tk
        fl := involved_password( 2, 'HT34M111111_' + Right( cName, 7 ), 'чтения С ОШИБКАМИ реестра СП и ТК' )
      Endif
      If Year( Date() ) < 2016
        fl := func_error( 4, 'Данная операция возможна начиная с 2016 года!' )
      Elseif fl
        fl := f_esc_enter( s, .t. )
      Endif
      RestScreen( buf )
      If !fl
        Return fl
      Endif
    Endif
    If ( arr_f := extract_zip_xml( keeppath( full_zip ), name_zip ) ) != NIL
      If ( n := AScan( arr_f, {| x| Upper( name_without_ext( x ) ) == Upper( cName ) } ) ) > 0
        fl := read_xml_from_tf_2025( full_zip, arr_f[ n ], arr_XML_info, arr_f )
      Else
        fl := func_error( 4, 'В архиве ' + name_zip + ' нет файла ' + cName + sxml() )
      Endif
    Endif
  Endif
  Return fl

// 28.08.25 чтение в память и анализ XML-файла
Function read_xml_from_tf_2025( full_zip, cFile, arr_XML_info, arr_f )

  Local nTypeFile := 0, aerr := {}, j, oXmlDoc, ;
    nCountWithErr := 0, go_to_schet := .f., go_to_akt := .f., go_to_rpd := .f., ;
    nerror, buf := save_maxrow(), mkod
  Local is_err_FLK_25 := .f.
  Local is_err_FLK := .f.
  Local cReadFile := name_without_ext( cFile )

//  private is_err_FLK := .f.
//  Private cReadFile := name_without_ext( cFile )
  Private cTimeBegin := hour_min( Seconds() ), ;
    mkod_reestr := 0, mXML_REESTR := 0, mdate_schet
  Private cFileProtokol := cReadFile + stxt()

  nTypeFile := arr_XML_info[ 1 ]
  For j := 1 To 4
    If !myfiledeleted( cur_dir() + 'tmp' + lstr( j ) + 'file' + sdbf() )
      Return Nil
    Endif
  Next
  For j := 1 To 8
    If !myfiledeleted( cur_dir() + 'tmp_r_t' + lstr( j ) + sdbf() )
      Return Nil
    Endif
  Next
  If eq_any( nTypeFile, _XML_FILE_FLK, _XML_FILE_FLK_25, _XML_FILE_R02, _XML_FILE_R12, _XML_FILE_R06, _XML_FILE_D02 )
    //
  Elseif !mo_lock_task( X_OMS )
    Return .f.
  Endif
  mywait( 'Производится анализ файла ' + cFile )

  StrFile( Space( 10 ) + 'Протокол обработки файла: ' + cFile + hb_eol(), cFileProtokol )
  StrFile( Space( 10 ) + full_date( Date() ) + 'г. ' + cTimeBegin + hb_eol(), cFileProtokol, .t. )

  // читаем файл в память
  oXmlDoc := hxmldoc():read( _tmp_dir1() + cFile, , @nerror )
  If oXmlDoc == Nil .or. Empty( oXmlDoc:aItems )
    AAdd( aerr, 'Ошибка в чтении файла ' + cFile )
  Elseif oXmlDoc:getattribute( 'encoding' ) == 'UTF-8'
    AAdd( aerr, '' )
    AAdd( aerr, 'В файле ' + cFile + ' кодировка UTF-8, а должна быть Windows-1251' )
  Elseif nTypeFile == _XML_FILE_FLK
    is_err_FLK := protokol_flk_tmpfile( arr_f, aerr )
  Elseif nTypeFile == _XML_FILE_FLK_25

    is_err_FLK_25 := protokol_flk_tmpfile_25( arr_f, aerr )

  Elseif nTypeFile == _XML_FILE_SP
    reestr_sp_tk_tmpfile( oXmlDoc, aerr, cReadFile )
  Elseif nTypeFile == _XML_FILE_RAK
    reestr_rak_tmpfile( oXmlDoc, aerr, cReadFile )
  Elseif nTypeFile == _XML_FILE_RPD
    reestr_rpd_tmpfile( oXmlDoc, aerr, cReadFile )
  Elseif eq_any( nTypeFile, _XML_FILE_R02, _XML_FILE_R12 )
    reestr_r02_tmpfile( oXmlDoc, aerr, cReadFile )
  Elseif nTypeFile == _XML_FILE_R06
    reestr_r06_tmpfile( oXmlDoc, aerr, cReadFile )
  Elseif nTypeFile == _XML_FILE_D02
    reestr_d02_tmpfile( oXmlDoc, aerr, cReadFile )
  Endif

  dbCloseAll()
  If Empty( aerr )
    Do Case
    Case nTypeFile == _XML_FILE_FLK
      StrFile( hb_eol() + 'Тип файла: протокол ФЛК (форматно-логического контроля)' + hb_eol() + hb_eol(), cFileProtokol, .t. )
      If read_xml_file_flk( arr_XML_info, aerr )
        // запишем принимаемый файл (протокол ФЛК)
        chip_copy_zipxml( full_zip, dir_server() + dir_XML_TF() )
        Use ( cur_dir() + 'tmp1file' ) New Alias TMP1
        g_use( dir_server() + 'mo_xml', , 'MO_XML' )
        addrecn()
        mo_xml->KOD := RecNo()
        mo_xml->FNAME := cReadFile
        mo_xml->DREAD := Date()
        mo_xml->TREAD := hour_min( Seconds() )
        mo_xml->TIP_IN := _XML_FILE_FLK // тип принимаемого файла;3-ФЛК
        mo_xml->DWORK  := Date()
        mo_xml->TWORK1 := cTimeBegin
        mo_xml->TWORK2 := hour_min( Seconds() )
        mo_xml->REESTR := mkod_reestr
        mo_xml->KOL2   := tmp1->KOL2
      Endif
    Case nTypeFile == _XML_FILE_FLK_25

      StrFile( hb_eol() + 'Тип файла: протокол ФЛК (форматно-логического контроля) нового образца' + hb_eol() + hb_eol(), cFileProtokol, .t. )
      If read_xml_file_flk_25( arr_XML_info, aerr, is_err_FLK_25, cFileProtokol )
        // запишем принимаемый файл (протокол ФЛК)
        chip_copy_zipxml( full_zip, dir_server() + dir_XML_TF() )
        Use ( cur_dir() + 'tmp1file' ) New Alias TMP1
        g_use( dir_server() + 'mo_xml', , 'MO_XML' )
        addrecn()
        mo_xml->KOD := RecNo()
        mo_xml->FNAME := cReadFile
        mo_xml->DREAD := Date()
        mo_xml->TREAD := hour_min( Seconds() )
        mo_xml->TIP_IN := _XML_FILE_FLK_25 // тип принимаемого файла;3-ФЛК
        mo_xml->DWORK  := Date()
        mo_xml->TWORK1 := cTimeBegin
        mo_xml->TWORK2 := hour_min( Seconds() )
        mo_xml->REESTR := arr_XML_info[ 7 ]   // mkod_reestr
        mo_xml->KOL2   := tmp1->KOL2
      Endif

      if is_err_FLK_25  // ошибки ФЛК 25 есть
      else  // ошибок ФЛК нет
        r_use( dir_server() + 'mo_rees', , 'REES' )
        rees->( dbGoto( arr_XML_info[ 7 ] ) )
        use_base( 'schet' )
        Set Relation To
        addrec( 6 )
        mkod := schet->( RecNo() )
        schet->KOD := mkod
        schet->NOMER_S := rees->NOMER_S
        schet->PDATE := dtoc4( rees->DSCHET )
        schet->KOL   := rees->KOL
        schet->SUMMA := rees->SUMMA
//        schet->KOL_OST   := arr_schet[ ii, 3 ]
//        schet->SUMMA_OST := arr_schet[ ii, 4 ]
        //
        Select SCHET_
        Do While schet_->( LastRec() ) < mkod
          schet_->( dbAppend() )    // Append Blank
        Enddo
        schet_->( dbGoto( mkod ) )
        g_rlock( forever )
        schet_->IFIN       := 1 // источник финансирования;1-ТФОМС(СМО)
        schet_->IS_MODERN  := 0 // является модернизацией, 0-нет
        schet_->IS_DOPLATA := 0 // является доплатой;0-нет
        schet_->BUKVA      := rees->BUKVA
        schet_->NSCHET     := rees->NOMER_S
        schet_->DSCHET     := rees->DSCHET
        schet_->SMO        := hb_ATokens( rees->NOMER_S, '-' )[ 1 ]   // код СМО из имени счета
        schet_->NYEAR      := rees->NYEAR
        schet_->NMONTH     := rees->NMONTH
//        schet_->NN         := mnn
        schet_->NAME_XML   := rees->NAME_XML
        schet_->XML_REESTR := mo_xml->KOD
        schet_->NREGISTR   := 0 // зарегистрирован
        schet_->CODE := ret_unique_code( mkod, 12 )
        schet_->KOD_XML := mo_xml->KOD
      endif
    Case nTypeFile == _XML_FILE_SP
      StrFile( hb_eol() + 'Тип файла: реестр СП и ТК (страховой принадлежности и технологического контроля)' + hb_eol() + hb_eol(), cFileProtokol, .t. )
      nCountWithErr := 0
      If read_xml_file_sp( arr_XML_info, aerr, @nCountWithErr ) > 0
        go_to_schet := create_schet_from_xml( arr_XML_info, aerr, , , cReadFile )
      Elseif nCountWithErr > 0 // все пришли с ошибкой
        g_use( dir_server() + 'mo_xml', , 'MO_XML' )
        Goto ( mXML_REESTR )
        g_rlock( forever )
        mo_xml->TWORK2 := hour_min( Seconds() )
      Endif
    Case nTypeFile == _XML_FILE_RAK
      StrFile( hb_eol() + 'Тип файла: РАК (реестр актов контроля)' + hb_eol() + hb_eol(), cFileProtokol, .t. )
      read_xml_file_rak( arr_XML_info, aerr )
      go_to_akt := Empty( aerr )
    Case nTypeFile == _XML_FILE_RPD
      StrFile( hb_eol() + 'Тип файла: РПД (реестр платёжных документов)' + hb_eol() + hb_eol(), cFileProtokol, .t. )
      read_xml_file_rpd( arr_XML_info, aerr )
      go_to_rpd := Empty( aerr )
    Case nTypeFile == _XML_FILE_R02
      StrFile( hb_eol() + 'Тип файла: PR01 (ответ на файл R01)' + hb_eol() + hb_eol(), cFileProtokol, .t. )
      nCountWithErr := 0
      read_xml_file_r02( arr_XML_info, aerr, @nCountWithErr, _XML_FILE_R02 )
      g_use( dir_server() + 'mo_xml', , 'MO_XML' )
      Goto ( mXML_REESTR )
      g_rlock( forever )
      mo_xml->TWORK2 := hour_min( Seconds() )
    Case nTypeFile == _XML_FILE_R12
      StrFile( hb_eol() + 'Тип файла: PR11 (ответ на файл R11)' + hb_eol() + hb_eol(), cFileProtokol, .t. )
      nCountWithErr := 0
      read_xml_file_r02( arr_XML_info, aerr, @nCountWithErr, _XML_FILE_R12 )
      g_use( dir_server() + 'mo_xml', , 'MO_XML' )
      Goto ( mXML_REESTR )
      g_rlock( forever )
      mo_xml->TWORK2 := hour_min( Seconds() )
    Case nTypeFile == _XML_FILE_R06
      StrFile( hb_eol() + 'Тип файла: PR05 (ответ на файл R05)' + hb_eol() + hb_eol(), cFileProtokol, .t. )
      nCountWithErr := 0
      read_xml_file_r06( arr_XML_info, aerr, @nCountWithErr )
      g_use( dir_server() + 'mo_xml', , 'MO_XML' )
      Goto ( mXML_REESTR )
      g_rlock( forever )
      mo_xml->TWORK2 := hour_min( Seconds() )
    Case nTypeFile == _XML_FILE_D02
      StrFile( hb_eol() + 'Тип файла: D02 (ответ на файл D01)' + hb_eol() + hb_eol(), cFileProtokol, .t. )
      nCountWithErr := 0
      read_xml_file_d02( arr_XML_info, aerr, @nCountWithErr )
      g_use( dir_server() + 'mo_xml', , 'MO_XML' )
      Goto ( mXML_REESTR )
      g_rlock( forever )
      mo_xml->TWORK2 := hour_min( Seconds() )
    Endcase
  Endif
  dbCloseAll()
  rest_box( buf )

  If eq_any( nTypeFile, _XML_FILE_FLK, _XML_FILE_FLK_25, _XML_FILE_R02, _XML_FILE_R06, _XML_FILE_D02 )
    //
  Else
    mo_unlock_task( X_OMS )
  Endif
  If Empty( aerr ) .or. nCountWithErr > 0 // запишем файл протокола обработки
    chip_copy_zipxml( cFileProtokol, dir_server() + dir_XML_TF() )
  Endif
  If !Empty( aerr )
    AEval( aerr, {| x| put_long_str( x, cFileProtokol ) } )
  Endif
  viewtext( devide_into_pages( cFileProtokol, 60, 80 ), , , , .t., , , 2 )

//  Delete File ( cFileProtokol )
  hb_vfErase( cFileProtokol )

  If go_to_schet // если выписаны счета
    Keyboard Chr( K_TAB ) + Chr( K_ENTER )
  Elseif go_to_akt // если приняты акты
    Keyboard Replicate( Chr( K_TAB ), 3 ) + Replicate( Chr( K_ENTER ), 2 )
  Elseif go_to_rpd // если приняты платёжки
    Keyboard Replicate( Chr( K_TAB ), 4 ) + Chr( K_ENTER )
  Endif
  Return Nil

// 28.08.25 зачитать новый Протокол ФЛК.
Function reestr_sp_tk_tmpfile_2025( oXmlDoc, aerr, mname_xml )

  Local j, j1, _ar, oXmlNode, oNode1, oNode2, buf := save_maxrow()
  local s

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
    { 'SCHET',  'N',  6, 0 }, ; // код счета
    { 'SCHET_ZAP',  'N',  6, 0 }, ; // номер позиции записи в счете
    { '_IDCASE',    'N',  8, 0 }, ;
    { '_ID_C',      'C', 36, 0 }, ;
    { '_IDENTITY',  'N',  1, 0 }, ;
    { 'CORRECT',    'C',  2, 0 }, ;
    { '_FAM',     'C', 40, 0 }, ; //
    { '_IM',     'C', 40, 0 }, ; //
    { '_OT',     'C', 40, 0 }, ; //
    { '_DR',     'C', 10, 0 }, ; //
    { '_OPLATA',    'N',  1, 0 };
    } )
  dbCreate( cur_dir() + 'tmp3file', { ;
    { '_N_ZAP',     'N',  8, 0 }, ;
    { '_REFREASON', 'N',  3, 0 }, ;
    { 'SREFREASON', 'C', 12, 0 };
    } )
  Use ( cur_dir() + 'tmp1file' ) New Alias TMP1
  tmp1->( dbAppend() )
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
      dbSelectArea( 'TMP2' )
      tmp2->( dbAppend() )
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
            dbSelectArea( 'TMP3' )
            tmp3->( dbAppend() )
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
  dbCommitAll()
  rest_box( buf )
  Return Nil

// 21.08.25 зачитать протокол ФЛК во временные файлы новая версия
Function protokol_flk_tmpfile_25( arr_f, aerr )

  Local adbf, ii, j, s, oXmlDoc, oXmlNode, is_err_FLK := .f.

  adbf := { ;
    { 'FNAME',  'C', 27, 0 }, ;
    { 'FNAME1', 'C', 26, 0 }, ;
    { 'FNAME2', 'C', 26, 0 }, ;
    { 'KOL2',   'N',  6, 0 };   // кол-во ошибок
  }
//  { 'DATE_F', 'D',  8, 0 }, ;
  dbCreate( cur_dir() + 'tmp1file', adbf, , .t., 'TMP1' )
  tmp1->( dbAppend() )

  adbf := { ; // элементы PR
    { 'TIP',        'N',   1, 0 }, ;  // тип(номер) обрабатываемого файла
    { 'OSHIB',      'N',   3, 0 }, ;  // код ошибки T005
    { 'SOSHIB',     'C',  12, 0 }, ;  // код ошибки Q015, Q022
    { 'IM_POL',     'C',  20, 0 }, ;  // имя поля, в котором ошибка
    { 'ZN_POL',     'C', 100, 0 }, ;  // Значение поля, вызвавшее ошибку. Не заполняется, если ошибка относится к файлу в целом
    { 'NSCHET',     'C',  15, 0 }, ;  // Номер счета, в котором обнаружена ошибка
    { 'BAS_EL',     'C',  20, 0 }, ;  // имя базового элемента
    { 'N_ZAP',      'C',  36, 0 }, ;  // Номер записи, в одном из полей которой обнаружена ошибка
    { 'ID_PAC',     'C',  36, 0 }, ;  // Код записи о пациенте, в которой обнаружена ошибка. Не заполняется только в том случае, если ошибка относится к файлу в целом.
    { 'IDCASE',     'N',  11, 0 }, ;  // Номер законченного случая, в котором обнаружена ошибка(указывается, если ошибка обнаружена внутри тега ?Z_SL?, в том числе во входящих в него элементах ?SL? и услугах)
    { 'SL_ID',      'C',  36, 0 }, ;  // Идентификатор случая, в котором обнаружена ошибка (указывается, если ошибка обнаружена внутри тега ?SL?, в том числе во входящих в него услугах)
    { 'IDSERV',     'C',  36, 0 }, ;  // Номер услуги, в которой обнаружена ошибка (указывается, если ошибка обнаруживается внутри тега ?USL?)
    { 'COMMENT',    'C', 250, 0 }, ;  // описание ошибки
    { 'N_ZAP',      'N',   6, 0 }, ;  // поле из первичного реестра
    { 'KOD_HUMAN',  'N',   7, 0 };   // код по БД листов учёта
  }
  dbCreate( cur_dir() + 'tmp2file', adbf, , .t., 'TMP2' ) // элементы PR

  dbCreate( cur_dir() + 'tmp22fil', adbf ) // доп.файл, если по одному пациенту > 1 листа учёта

  For ii := 1 To Len( arr_f )
    // т.к. в ZIP'е два XML-файла, второй файл также прочитать
    If Upper( Right( arr_f[ ii ], 4 ) ) == sxml() .and. ValType( oXmlDoc := hxmldoc():read( _tmp_dir1() + arr_f[ ii ] ) ) == 'O'
      For j := 1 To Len( oXmlDoc:aItems[ 1 ]:aItems )
        oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
        Do Case
        Case 'FNAME' == oXmlNode:title
          tmp1->FNAME := mo_read_xml_tag( oXmlNode, aerr, .t. )
        Case 'FNAME_I' == oXmlNode:title
          If ii == 1
            tmp1->FNAME1 := mo_read_xml_tag( oXmlNode, aerr, .t. )
          Else
            tmp1->FNAME2 := mo_read_xml_tag( oXmlNode, aerr, .t. )
          Endif
        Case 'PR' == oXmlNode:title
          dbSelectArea( 'TMP2' )
          tmp2->( dbAppend() )
          tmp2->tip := ii
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
          tmp2->N_ZAP   := mo_read_xml_stroke( oXmlNode, 'N_ZAP', aerr, .f. )
          tmp2->ID_PAC  := mo_read_xml_stroke( oXmlNode, 'ID_PAC', aerr, .f. )
          tmp2->IDCASE  := Val( mo_read_xml_stroke( oXmlNode, 'IDCASE', aerr, .f. ) )
          tmp2->SL_ID   := mo_read_xml_stroke( oXmlNode, 'SL_ID', aerr, .f. )
          tmp2->IDSERV  := mo_read_xml_stroke( oXmlNode, 'IDSERV', aerr, .f. )
          tmp2->COMMENT := mo_read_xml_stroke( oXmlNode, 'COMMENT', aerr, .f. )
          If ! Empty( tmp2->BAS_EL )   // .and. !Empty( tmp2->ID_BAS )
            is_err_FLK := .t.
            tmp1->KOL2++
          Endif
        Endcase
      Next j
    Endif
  Next ii
  dbCommitAll()
  Return is_err_FLK

// 26.08.25 прочитать реестр ФЛК
Function read_xml_file_flk_25( arr_XML_info, aerr, is_err_FLK_25, cFileProtokol )

  Local ii, pole, i, k, t_arr[ 2 ]
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
  Index On Str( FIELD->tip, 1 ) + Str( FIELD->oshib, 3 ) + FIELD->soshib to ( cur_dir() + 'tmp2' )
  If is_err_FLK_25
    If !extract_reestr( rees->( RecNo() ), rees->name_xml )
      AAdd( aerr, Center( 'Не найден ZIP-архив с РЕЕСТРом СЧЕТОВ № ' + lstr( rees->nschet ) + ' от ' + date_8( rees->DSCHET ), 80 ) )
      AAdd( aerr, '' )
      AAdd( aerr, Center( dir_server() + dir_XML_MO() + hb_ps() + AllTrim( rees->name_xml ) + szip(), 80 ) )
      AAdd( aerr, '' )
      AAdd( aerr, Center( 'Без данного архива дальнейшая работа НЕВОЗМОЖНА!', 80 ) )
      dbCloseAll()
      Return .f.
    Endif
    Use ( cur_dir() + 'tmp_r_t1' ) New Alias T1
    Index On Upper( FIELD->ID_PAC ) to ( cur_dir() + 'tmp_r_t1' )
    Use ( cur_dir() + 'tmp_r_t2' ) New Alias T2
    Use ( cur_dir() + 'tmp_r_t3' ) New Alias T3
//    Use ( cur_dir() + 'tmp_r_t4' ) New Alias T4
//    Use ( cur_dir() + 'tmp_r_t5' ) New Alias T5
//    Use ( cur_dir() + 'tmp_r_t6' ) New Alias T6
//    Use ( cur_dir() + 'tmp_r_t7' ) New Alias T7
//    Use ( cur_dir() + 'tmp_r_t8' ) New Alias T8
    create_files_tmp_flk_25() // создадим временные файлы для разбора
    // заполнить поле 'N_ZAP' в файле 'tmp2'
    fill_tmp2_file_flk_25()
    r_use( dir_server() + 'mo_otd', , 'OTD' )
    r_use( dir_server() + 'human_3', { dir_server() + 'human_3', dir_server() + 'human_32' }, 'HUMAN_3' )
    g_use( dir_server() + 'human_', , 'HUMAN_' )
    g_use( dir_server() + 'human', , 'HUMAN' )
    Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_3, To FIELD->otd into OTD
    g_use( dir_server() + 'mo_rhum', , 'RHUM' )
    Index On Str( FIELD->REES_ZAP, 6 ) to ( cur_dir() + 'tmp_rhum' ) For FIELD->reestr == mkod_reestr
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

  For ii := 1 To 2
    pole := 'tmp1->fname' + lstr( ii )
    StrFile( hb_eol() + 'Обработан файл ' + &pole + hb_eol(), cFileProtokol, .t. )
    dbSelectArea( 'TMP2' )
    tmp2->( dbSeek( Str( ii, 1 ) ) )
    If tmp2->( Found() )
      StrFile( '  Список ошибок:' + hb_eol(), cFileProtokol, .t. )
      Do While tmp2->tip == ii .and. !Eof()
        If Empty( tmp2->SOSHIB )
          s := 'код ошибки = ' + lstr( tmp2->OSHIB ) + ' '
          If ( i := AScan( getf012(), {| x| x[ 2 ] == tmp2->OSHIB } ) ) > 0
            s += '"' + getf012()[ i, 5 ] + '"'
          Endif
        Else
          s := 'код ошибки = ' + tmp2->SOSHIB + ' '
          s += '"' + getcategorycheckerrorbyid_q017( Left( tmp2->SOSHIB, 4 ) )[ 2 ] + '" '
          s += AllTrim( inieditspr( A__MENUVERT, loadq015(), tmp3->SREFREASON ) )
        Endif
        If !Empty( tmp2->IM_POL )
          s += ', имя поля = ' + AllTrim( tmp2->IM_POL )
        Endif
        If !Empty( tmp2->BAS_EL )
          s += ', имя базового элемента = ' + AllTrim( tmp2->BAS_EL )
        Endif
//        If !Empty( tmp2->ID_BAS )
//          s += ', GUID базового элемента = ' + AllTrim( tmp2->ID_BAS )
//        Endif
        If !Empty( tmp2->COMMENT )
          s += ', описание ошибки = ' + AllTrim( tmp2->COMMENT )
        Endif
        If !Empty( tmp2->BAS_EL )   // .and. !Empty( tmp2->ID_BAS )
          If Empty( tmp2->N_ZAP )
            s += ', СЛУЧАЙ НЕ НАЙДЕН!'
          Else
            dbSelectArea( 'RHUM' )
            rhum->( dbSeek( Str( tmp2->N_ZAP, 6 ) ) )
            If rhum->( Found() )
              g_rlock( forever )
              rhum->OPLATA := 2
              tmp2->kod_human := rhum->KOD_HUM
              dbSelectArea( 'HUMAN' )
              human->( dbGoto( rhum->KOD_HUM ) )
//              If human->ishod == 89 // это 2-ой случай в двойном случае
//                dbSelectArea( 'HUMAN_3' )
////                Set Order To 2
//                  human_3->( ordSetFocus( 2 ) )
//                human_3->( dbSeek( Str( rhum->KOD_HUM, 7 ) ) )
//                If human_3->( Found() )
//                  human->( dbGoto( human_3->kod ) )    // т.к. GUID'ы в реестре из 1-го случая
//                  human_->( dbGoto( human_3->kod ) )   // встать на 1-ый случай
//                Endif
//              Endif

              If human_->REESTR == mkod_reestr
                g_rlock( forever )
                human_->( g_rlock( forever ) )
                human_->OPLATA := 2
                human_->REESTR := 0 // направляется на дальнейшее редактирование
                human_->ST_VERIFY := 0 // снова ещё не проверен
                If human_->REES_NUM > 0
                  human_->REES_NUM := human_->REES_NUM - 1
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
    Else
      StrFile( '-- Ошибок не обнаружено -- ' + hb_eol(), cFileProtokol, .t. )
    Endif
  Next
  dbCloseAll()
  Return .t.

// 25.08.25 заполнить поле 'N_ZAP' в файле 'tmp2'
Function fill_tmp2_file_flk_25()

  Local i, s, s1, adbf, ar

  Use ( cur_dir() + 'tmp22fil' ) New Alias TMP22
  dbSelectArea( 'TMP2' )
  adbf := Array( tmp2->( FCount() ) )
  tmp2->( dbGoTop() )
  Do While ! tmp2->( Eof() )
    If !Empty( tmp2->BAS_EL ) // .and. !Empty( tmp2->ID_BAS )
      s := AllTrim( tmp2->BAS_EL )
//      s1 := AllTrim( tmp2->ID_BAS )
      Do Case
      Case s == 'ZAP'
        dbSelectArea( 'T1' )
        Locate For t1->N_ZAP == PadR( s1, 6 )
        If t1->( Found() )
          tmp2->N_ZAP := Val( t1->N_ZAP )
        Endif
      Case s == 'PACIENT'
        ar := {}
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
      Case eq_any( s, 'SLUCH', 'Z_SL' )
        dbSelectArea( 'T1' )
        Locate For Upper( t1->ID_C ) == PadR( Upper( s1 ), 36 )
        If t1->( Found() )
          tmp2->N_ZAP := Val( t1->N_ZAP )
        Endif
      Case s == 'USL'
        dbSelectArea( 'T2' )
        Locate For Upper( t2->ID_U ) == PadR( Upper( s1 ), 36 )
        If t2->( Found() )
          dbSelectArea( 'T1' )
          Locate For t1->N_ZAP == t2->IDCASE
          If t1->( Found() )
            tmp2->N_ZAP := Val( t1->N_ZAP )
          Endif
        Endif
      Case s == 'PERS'
        dbSelectArea( 'T3' )
        Locate For Upper( t3->ID_PAC ) == PadR( Upper( s1 ), 36 )
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
    dbSelectArea( 'TMP2' )
    tmp2->( dbSkip() )
  Enddo
  i := tmp22->( LastRec() )
  tmp22->( dbCloseArea() )
  If i > 0
    dbSelectArea( 'TMP2' )
    Append From tmp22fil codepage 'RU866'
    Index On Str( FIELD->tip, 1 ) + Str( FIELD->oshib, 3 ) to ( cur_dir() + 'tmp2' )
  Endif
  Return Nil

// 25.08.25 создать файлы для анализа ФЛК нового образца
Function create_files_tmp_flk_25()

  Local _table1 := { ;
    { "KOD",      "N", 6, 0 }, ; // код
    { "N_ZAP",    "C", 12, 0 }, ; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
    { "PR_NOV",   "C", 1, 0 }, ;
    { "ID_PAC",   "C", 36, 0 }, ; //
    { "VPOLIS",   "C", 1, 0 }, ; //
    { "SPOLIS",   "C", 10, 0 }, ; //
    { "NPOLIS",   "C", 20, 0 }, ; //
    { "ENP",      "C", 16, 0 }, ; //
    { "SMO",      "C", 5, 0 }, ; //
    { "SMO_OK",   "C", 5, 0 }, ; //
    { "SMO_NAM",  "C", 100, 0 }, ; //
    { "MO_PR",    "C", 6, 0 }, ; //
    { "NOVOR",    "C", 9, 0 }, ; //
    { "VNOV_D",   "C", 4, 0 }, ; // вес новорожденного в граммах
    { "SOC",      "C", 3, 0 }, ; // участники и члены семей участников СВО
    { "INV",      "C", 1, 0 }, ; //
    { "DATA_INV", "C", 10, 0 }, ; //
    { "REASON_INV","C", 2, 0 }, ; //
    { "DS_INV",   "C", 10, 0 }, ; //
    { "MSE",      "C", 1, 0 }, ; //
    { "KD_Z",     "C", 3, 0 }, ; //
    { "KD",       "C", 3, 0 }, ; //
    { "IDCASE",   "C", 12, 0 }, ; //
    { "ID_C",     "C", 36, 0 }, ; //
    { "SL_ID",    "C", 36, 0 }, ; //
    { "DISP",     "C", 3, 0 }, ; //
    { "USL_OK",   "C", 2, 0 }, ; //
    { "VIDPOM",   "C", 4, 0 }, ; //
    { "F_SP",     "C", 1, 0 }, ; // удалено поле
    { "FOR_POM",  "C", 1, 0 }, ; // N1
    { "VID_HMP",  "C", 12, 0 }, ; // C9
    { "ISHOD",    "C", 3, 0 }, ; //
    { "VB_P",     "C", 1, 0 }, ; //
    { "IDSP",     "C", 2, 0 }, ; //
    { "SUMV",     "C", 10, 0 }, ; //
    { "METOD_HMP","C", 4, 0 }, ; // N4 // 12.02.21
    { "NPR_MO",   "C", 6, 0 }, ; //
    { "NPR_DATE", "C", 10, 0 }, ; //
    { "EXTR",     "C", 1, 0 }, ; //
    { "LPU",      "C", 6, 0 }, ; //
    { "LPU_1",    "C", 8, 0 }, ; //
    { "PODR",     "C", 8, 0 }, ; //
    { "PROFIL",   "C", 3, 0 }, ; //
    { "PROFIL_K", "C", 3, 0 }, ; //
    { "DET",      "C", 1, 0 }, ; //
    { "P_CEL",    "C", 3, 0 }, ; //
    { "TAL_D",    "C", 10, 0 }, ; //
    { "TAL_P",    "C", 10, 0 }, ; //
    { "TAL_NUM",  "C", 20, 0 }, ; //
    { "VBR",      "C", 1, 0 }, ; //
    { "NHISTORY", "C", 10, 0 }, ; //
    { "P_OTK",    "C", 1, 0 }, ; //
    { "P_PER",    "C", 1, 0 }, ; //
    { "DATE_Z_1", "C", 10, 0 }, ; //
    { "DATE_Z_2", "C", 10, 0 }, ; //
    { "DATE_1",   "C", 10, 0 }, ; //
    { "DATE_2",   "C", 10, 0 }, ; //
    { "DS0",      "C", 6, 0 }, ; //
    { "DS1",      "C", 6, 0 }, ; //
    { "DS1_PR",   "C", 1, 0 }, ; //
    { "PR_D_N",   "C", 1, 0 }, ; //
    { "DS2",      "C", 6, 0 }, ; //
    { "DS2N",     "C", 6, 0 }, ; //
    { "DS2N_PR",  "C", 1, 0 }, ; //
    { "DS2N_D",   "C", 1, 0 }, ; //
    { "DS2_2",    "C", 6, 0 }, ; //
    { "DS2N_2",   "C", 6, 0 }, ; //
    { "DS2N_2_PR","C", 1, 0 }, ; //
    { "DS2N_2_D", "C", 1, 0 }, ; //
    { "DS2_3",    "C", 6, 0 }, ; //
    { "DS2N_3",   "C", 6, 0 }, ; //
    { "DS2N_3_PR","C", 1, 0 }, ; //
    { "DS2N_3_D", "C", 1, 0 }, ; //
    { "DS2_4",    "C", 6, 0 }, ; //
    { "DS2N_4",   "C", 6, 0 }, ; //
    { "DS2N_4_PR","C", 1, 0 }, ; //
    { "DS2N_4_D", "C", 1, 0 }, ; //
    { "DS2_5",    "C", 6, 0 }, ; //
    { "DS2_6",    "C", 6, 0 }, ; //
    { "DS2_7",    "C", 6, 0 }, ; //
    { "DS3",      "C", 6, 0 }, ; //
    { "DS3_2",    "C", 6, 0 }, ; //
    { "DS3_3",    "C", 6, 0 }, ; //
    { "DS_ONK",   "C", 1, 0 }, ; //
    { "C_ZAB",    "C", 1, 0 }, ; //
    { "DN",       "C", 1, 0 }, ; //
    { "VNOV_M",   "C", 4, 0 }, ; // вес новорожденного в граммах
    { "VNOV_M_2", "C", 4, 0 }, ; // вес новорожденного в граммах
    { "VNOV_M_3", "C", 4, 0 }, ; // вес новорожденного в граммах
    { "CODE_MES1","C", 20, 0 }, ; //
    { "SUM_M",    "C", 10, 0 }, ; //
    { "DS1_T",    "C", 1, 0 }, ; // Повод обращения:0 - первичное лечение;1 - рецидив;2 - прогрессирование
    { "PR_CONS",  "C", 1, 0 }, ; // Сведения о проведении консилиума:1 - определена тактика обследования;2 - определена тактика лечения;3 - изменена тактика лечения.
    { "DT_CONS",  "C", 10, 0 }, ; // Дата проведения консилиума       Обязательно к заполнению при заполненном PR_CONS
    { "STAD",     "C", 4, 0 }, ; // Стадия заболевания       Заполняется в соответствии со справочником N002
    { "ONK_T",    "C", 5, 0 }, ; // Значение Tumor   Заполняется в соответствии со справочником N003
    { "ONK_N",    "C", 5, 0 }, ; // Значение Nodus   Заполняется в соответствии со справочником N004
    { "ONK_M",    "C", 5, 0 }, ; // Значение Metastasis      Заполняется в соответствии со справочником N005
    { "MTSTZ",    "C", 1, 0 }, ; // Признак выявления отдалённых метастазов  Подлежит заполнению значением 1 при выявлении отдалённых метастазов только при DS1_T=1 или DS1_T=2
    { "SOD",      "C", 6, 0 }, ;  // Суммарная очаговая доза Обязательно для заполнения при проведении лучевой или химиолучевой терапии (USL_TIP=3 или USL_TIP=4)
    { "K_FR",     "C", 2, 0 }, ; //
    { "WEI",      "C", 5, 0 }, ; //
    { "HEI",      "C", 5, 0 }, ; //
    { "BSA",      "C", 5, 0 }, ; //
    { "RSLT",     "C", 3, 0 }, ; //
    { "ISHOD",    "C", 3, 0 }, ; //
    { "IDSP",     "C", 2, 0 }, ; //
    { "PRVS",     "C", 9, 0 }, ; //
    { "IDDOKT",   "C", 16, 0 }, ; //
    { "OS_SLUCH", "C", 2, 0 }, ; //
    { "COMENTSL", "C", 250, 0 }, ; //
    { "ED_COL",   "C", 1, 0 }, ; //
    { "N_KSG",    "C", 20, 0 }, ; //
    { "CRIT",     "C", 20, 0 }, ; //
    { "CRIT2",    "C", 20, 0 }, ; //
    { "SL_K",     "C", 9, 0 }, ; //
    { "IT_SL",    "C", 9, 0 }, ; //
    { "AD_CR",    "C", 10, 0 }, ; //
    { "DKK2",     "C", 10, 0 }, ; //
    { "kod_kslp", "C", 5, 0 }, ; //
    { "koef_kslp","C", 6, 0 }, ;  //
    { "kod_kslp2","C", 5, 0 }, ; //
    { "koef_kslp2","C", 6, 0 }, ;  //
    { "kod_kslp3","C", 5, 0 }, ; //
    { "koef_kslp3","C", 6, 0 }, ;  //
    { "CODE_KIRO","C", 1, 0 }, ; //
    { "VAL_K",    "C", 5, 0 }, ; //
    { "NEXT_VISIT","C", 10, 0 }, ; //
    { "TARIF",    "C", 10, 0 }; //
  }
  Local _table2 := { ;
    { "SLUCH",    "N", 6, 0 }, ; // номер случая
    { "KOD",      "N", 6, 0 }, ; // код
    { "IDCASE",   "C", 12, 0 }, ; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
    { "IDSERV",   "C", 36, 0 }, ; //
    { "ID_U",     "C", 36, 0 }, ; //
    { "LPU",      "C", 6, 0 }, ; //
    { "LPU_1",    "C", 8, 0 }, ; //
    { "PODR",     "C", 8, 0 }, ; //
    { "PROFIL",   "C", 3, 0 }, ; //
    { "VID_VME",  "C", 20, 0 }, ; //
    { "DET",      "C", 1, 0 }, ; //
    { "P_OTK",    "C", 1, 0 }, ; //
    { "DATE_IN",  "C", 10, 0 }, ; //
    { "DATE_OUT", "C", 10, 0 }, ; //
    { "DS",       "C", 6, 0 }, ; //
    { "CODE_USL", "C", 20, 0 }, ; //
    { "KOL_USL",  "C", 6, 0 }, ; //
    { "TARIF",    "C", 10, 0 }, ; //
    { "SUMV_USL", "C", 10, 0 }, ; //
    { "USL_TIP",  "C", 1, 0 }, ; // Тип онкоуслуги в соответствии со справочником N013
    { "HIR_TIP",  "C", 1, 0 }, ; // Тип хирургического лечения При USL_TIP=1 в соответствии со справочником N014
    { "LEK_TIP_L","C", 1, 0 }, ; // Линия лекарственной терапии При USL_TIP=2 в соответствии со справочником N015
    { "LEK_TIP_V","C", 1, 0 }, ; // Цикл лекарственной терапии       При USL_TIP=2 в соответствии со справочником N016
    { "LUCH_TIP", "C", 1, 0 }, ; // Тип лучевой терапии      При USL_TIP=3,4 в соответствии со справочником N017
    { "PRVS",     "C", 9, 0 }, ; //
    { "CODE_MD",  "C", 16, 0 }, ; //
    { "COMENTU",  "C", 250, 0 };  //
  }
  Local _table3 := { ;
    { "KOD",      "N", 6, 0 }, ; // код
    { "ID_PAC",   "C", 36, 0 }, ; // код записи о пациенте ;GUID пациента в листе учета;создается при добавлении записи
    { "FAM",      "C", 40, 0 }, ; //
    { "IM",       "C", 40, 0 }, ; //
    { "OT",       "C", 40, 0 }, ; //
    { "W",        "C", 1, 0 }, ; //
    { "DR",       "C", 10, 0 }, ; //
    { "DOST",     "C", 1, 0 }, ; //
    { "TEL",      "C", 10, 0 }, ; //
    { "FAM_P",    "C", 40, 0 }, ; //
    { "IM_P",     "C", 40, 0 }, ; //
    { "OT_P",     "C", 40, 0 }, ; //
    { "W_P",      "C", 1, 0 }, ; //
    { "DR_P",     "C", 10, 0 }, ; //
    { "DOST_P",   "C", 1, 0 }, ; //
    { "MR",       "C", 100, 0 }, ; //
    { "DOCTYPE",  "C", 2, 0 }, ; //
    { "DOCSER",   "C", 10, 0 }, ; //
    { "DOCNUM",   "C", 20, 0 }, ; //
    { "DOCDATE",  "C", 10, 0 }, ; //
    { "DOCORG",   "C", 255, 0 }, ; //
    { "SNILS",    "C", 14, 0 }, ; //
    { "OKATOG",   "C", 11, 0 }, ; //
    { "OKATOP",   "C", 11, 0 }; //
  }

  dbCreate( cur_dir() + "tmp_r_t1", _table1 )
  dbCreate( cur_dir() + "tmp_r_t2", _table2 )
  dbCreate( cur_dir() + "tmp_r_t3", _table3 )
  return nil
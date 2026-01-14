// oms_files_TFOMS.prg - работа с файлами полученными из ТФОМС в задаче ОМС
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 08.01.26 читать файлы из ТФОМС (или СМО)
Function read_from_tf()

  Local name_zip, _date, _time, s, buf, blk_sp_tk, fl, n, cName
  Local arr_XML_info[ 7 ], arr_f := {}, tip_csv_file := 0, kod_csv_reestr := 0

  fl := .f.
  If ! currentuser():isadmin()
    Return func_error( 4, err_admin() )
  Endif
  If find_unfinished_reestr_sp_tk()
    Return func_error( 4, 'Попытайтесь снова' )
  Endif
  Private p_var_manager := 'Read_From_TFOMS', p_ctrl_enter_sp_tk := .f.
  Private full_zip

  blk_sp_tk := {|| p_ctrl_enter_sp_tk := .t., __Keyboard( Chr( K_ENTER ) ) }
  SetKey( K_CTRL_ENTER, blk_sp_tk )
  full_zip := manager( T_ROW, T_COL + 5, MaxRow() -2, , .t., 1, , , , '*.zip' )
  SetKey( K_CTRL_ENTER, nil )
  If !Empty( full_zip )
    full_zip := Upper( full_zip )
    name_zip := strippath( full_zip )
    cName := name_without_ext( name_zip )
    /*if right(full_zip, 4) == scsv()
      if Is_Our_CSV(cName,@tip_csv_file,@kod_csv_reestr)
        fl := read_CSV_from_TF(full_zip,tip_csv_file,kod_csv_reestr)
      endif
      return fl
    endif*/
    // если это укрупнённый архив, распаковать и прочитать 
    If !is_our_zip( cName, @tip_csv_file, @kod_csv_reestr )
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
      Case arr_XML_info[ 1 ] == _XML_FILE_FLK_26
        s += 'протокола ФЛК 2026'
//      Case arr_XML_info[ 1 ] == _XML_FILE_FLK
//        s += 'протокола ФЛК'
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
      Endcase
      buf := SaveScreen()
      f_message( { 'Системная дата: ' + date_month( sys_date, .t. ), ;
        'Обращаем Ваше внимание, что после', ;
        s, ;
        'все документы будут созданы с этой датой.', ;
        '', ;
        'Изменить их будет НЕВОЗМОЖНО!' }, , 'R/R*', 'N/R*' )
      fl := .t.
      If arr_XML_info[ 1 ] == _XML_FILE_SP .and. p_ctrl_enter_sp_tk
        fl := involved_password( 2, 'HT34M111111_' + Right( cName, 7 ), 'чтения С ОШИБКАМИ реестра СП и ТК' )
      Endif
      fl := f_esc_enter( s, .t. )
      RestScreen( buf )
      If !fl
        Return fl
      Endif
    Endif
    If ( arr_f := extract_zip_xml( keeppath( full_zip ), name_zip ) ) != NIL
      If ( n := AScan( arr_f, {| x| Upper( name_without_ext( x ) ) == Upper( cName ) } ) ) > 0
        fl := read_xml_from_tf( arr_f[ n ], arr_XML_info, arr_f )
      Else
        fl := func_error( 4, 'В архиве ' + name_zip + ' нет файла ' + cName + sxml() )
      Endif
    Endif
  Endif
  Return fl

// 14.01.26 чтение в память и анализ XML-файла
Function read_xml_from_tf( cFile, arr_XML_info, arr_f )

  Local is_err_FLK_26
  Local nTypeFile := 0, mkod_reestr, aerr := {}, j, oXmlDoc, ;
    nCountWithErr := 0, go_to_schet := .f., go_to_akt := .f., ;
    go_to_rpd := .f., nerror, buf := save_maxrow()

  nTypeFile := arr_XML_info[ 1 ]
  mkod_reestr := arr_XML_info[ 7 ]

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
//  If eq_any( nTypeFile, _XML_FILE_FLK, _XML_FILE_FLK_26, _XML_FILE_R02, _XML_FILE_R12, _XML_FILE_R06, _XML_FILE_D02 )
  If eq_any( nTypeFile, _XML_FILE_FLK_26, _XML_FILE_R02, _XML_FILE_R12, _XML_FILE_R06, _XML_FILE_D02 )
    //
  Elseif !mo_lock_task( X_OMS )
    Return .f.
  Endif
  mywait( 'Производится анализ файла ' + cFile )
  Private cReadFile := name_without_ext( cFile ), ;
    cTimeBegin := hour_min( Seconds() ), ;
    mXML_REESTR := 0, mdate_schet, is_err_FLK := .f.
  Private cFileProtokol := cReadFile + stxt()
//  private mkod_reestr := 0,   
  StrFile( Space( 10 ) + 'Протокол обработки файла: ' + cFile + hb_eol(), cFileProtokol )
  StrFile( Space( 10 ) + full_date( sys_date ) + 'г. ' + cTimeBegin + hb_eol(), cFileProtokol, .t. )

  // читаем файл в память
  oXmlDoc := hxmldoc():read( _tmp_dir1() + cFile, , @nerror )
  If oXmlDoc == Nil .or. Empty( oXmlDoc:aItems )
    AAdd( aerr, 'Ошибка в чтении файла ' + cFile )
  Elseif oXmlDoc:getattribute( 'encoding' ) == 'UTF-8'
    AAdd( aerr, '' )
    AAdd( aerr, 'В файле ' + cFile + ' кодировка UTF-8, а должна быть Windows-1251' )
//  Elseif nTypeFile == _XML_FILE_FLK
//    is_err_FLK := protokol_flk_tmpfile( arr_f, aerr )
  Elseif nTypeFile == _XML_FILE_FLK_26

    is_err_FLK_26 := parse_protokol_flk_26( arr_f, aerr )

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

    Case nTypeFile == _XML_FILE_FLK_26

      StrFile( hb_eol() + 'Тип файла: протокол ФЛК (форматно-логического контроля) нового образца' + hb_eol() + hb_eol(), cFileProtokol, .t. )

      If read_xml_file_flk_26( arr_XML_info, aerr, is_err_FLK_26, cFileProtokol )
/*
        // запишем принимаемый файл (протокол ФЛК)
        chip_copy_zipxml( full_zip, dir_server() + dir_XML_TF() )
        Use ( cur_dir() + 'tmp1file' ) New Alias TMP1
        g_use( dir_server() + 'mo_xml', , 'MO_XML' )
        addrecn()
        mo_xml->KOD := RecNo()
        mo_xml->FNAME := cReadFile
        mo_xml->DREAD := Date()
        mo_xml->TREAD := hour_min( Seconds() )
        mo_xml->TIP_IN := _XML_FILE_FLK_26 // тип принимаемого файла;3-ФЛК
        mo_xml->DWORK  := Date()
        mo_xml->TWORK1 := cTimeBegin
        mo_xml->TWORK2 := hour_min( Seconds() )
        mo_xml->REESTR := arr_XML_info[ 7 ]   // mkod_reestr
        mo_xml->KOL2   := tmp1->KOL2
*/
      Endif

      if is_err_FLK_26  // ошибки ФЛК 26 есть
        // открыть распакованный реестр
        Use ( cur_dir() + 'tmp_r_t1' ) New Alias T1
        Index On Str( Val( FIELD->n_zap ), 6 ) to ( cur_dir() + 'tmpt1' )
        Use ( cur_dir() + 'tmp_r_t2' ) New Alias T2
        Index On FIELD->IDCASE + Str( FIELD->sluch, 6 ) to ( cur_dir() + 'tmpt2' )
        Use ( cur_dir() + 'tmp_r_t3' ) New Alias T3
        Index On Upper( FIELD->ID_PAC ) to ( cur_dir() + 'tmpt3' )

//        g_use( dir_server() + 'mo_kfio', , 'KFIO' )
//        Index On Str( FIELD->kod, 7 ) to ( cur_dir() + 'tmp_kfio' )
//        g_use( dir_server() + 'kartote2', , 'KART2' )
//        g_use( dir_server() + 'kartote_', , 'KART_' )
//        g_use( dir_server() + 'kartotek', dir_server() + 'kartoten', 'KART' )
//        Set Order To 0 // индекс открыт для реконструкции при перезаписи ФИО и даты рождения
//        r_use( dir_server() + 'mo_otd', , 'OTD' )
        g_use( dir_server() + 'human_', , 'HUMAN_' )
        g_use( dir_server() + 'human', { dir_server() + 'humann', dir_server() + 'humans' }, 'HUMAN' )
        Set Order To 0 // индексы открыты для реконструкции при перезаписи ФИО
        Set Relation To RecNo() into HUMAN_ //, To FIELD->otd into OTD
        g_use( dir_server() + 'human_3', { dir_server() + 'human_3', dir_server() + 'human_32' }, 'HUMAN_3' )
        g_use( dir_server() + 'mo_rhum', , 'RHUM' )
        Index On Str( FIELD->REES_ZAP, 6 ) to ( cur_dir() + 'tmp_rhum' ) For FIELD->reestr == mkod_reestr

        g_use( dir_server() + 'mo_refr', dir_server() + 'mo_refr', 'REFR' )

        Use ( cur_dir() + 'tmp3file' ) New Alias TMP3
        Index On Str( FIELD->_n_zap, 8 ) to ( cur_dir() + 'tmp3' )
        Use ( cur_dir() + 'tmp2file' ) New Alias TMP2
        tmp2->( dbGoTop() )
        do while ! tmp2->( Eof() )

            Select REFR
            Do While .t.
              refr->( Str( 1, 1 ) + Str( mkod_reestr, 6 ) + Str( 1, 1 ) + Str( rhum->KOD_HUM, 8 ) )
              If !Found()
                Exit
              Endif
              deleterec( .t. )
            Enddo
            Select TMP3
            tmp3->( dbSeek( Str( tmp2->N_ZAP, 8 ) ) )
            Do While tmp2->N_ZAP == tmp3->_N_ZAP .and. ! tmp3->( Eof() )
              Select REFR
              addrec( 1 )
              refr->TIPD := 1
              refr->KODD := mkod_reestr
              refr->TIPZ := 1
              refr->KODZ := rhum->KOD_HUM
              refr->REFREASON := tmp3->_REFREASON
              refr->SREFREASON := tmp3->SREFREASON
//              refr->IDENTITY := tmp2->_IDENTITY

              Select tmp3
              tmp3->( dbSkip() )
            Enddo

          tmp2->( dbSkip() )
        Enddo

altd()
      else  // ошибок ФЛК нет
//        r_use( dir_server() + 'mo_rees', , 'REES' ) 
        e_use( dir_server() + 'mo_rees', , 'REES' ) 
        rees->( dbGoto( arr_XML_info[ 7 ] ) )
        rees->( dbRLock() )
        rees->RES_TFOMS := 1  // реестр счета принят
        rees->( dbUnlock() )
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
        schet_->NN         := rees->NN
        schet_->NAME_XML   := rees->NAME_XML
        schet_->XML_REESTR := mo_xml->KOD
        schet_->NREGISTR   := 0 // зарегистрирован
        schet_->CODE := ret_unique_code( mkod, 12 )
        schet_->KOD_XML := mo_xml->KOD
      endif
/*
    Case nTypeFile == _XML_FILE_FLK
      StrFile( hb_eol() + 'Тип файла: протокол ФЛК (форматно-логического контроля)' + hb_eol() + hb_eol(), cFileProtokol, .t. )
      If read_xml_file_flk( arr_XML_info, aerr )
        // запишем принимаемый файл (протокол ФЛК)
        // chip_copy_zipXML(hb_OemToAnsi(full_zip),dir_server()+dir_XML_TF())
        chip_copy_zipxml( full_zip, dir_server() + dir_XML_TF() )
        Use ( cur_dir() + 'tmp1file' ) New Alias TMP1
        g_use( dir_server() + 'mo_xml', , 'MO_XML' )
        addrecn()
        mo_xml->KOD := RecNo()
        mo_xml->FNAME := cReadFile
        mo_xml->DREAD := sys_date
        mo_xml->TREAD := hour_min( Seconds() )
        mo_xml->TIP_IN := _XML_FILE_FLK // тип принимаемого файла;3-ФЛК
        mo_xml->DWORK  := sys_date
        mo_xml->TWORK1 := cTimeBegin
        mo_xml->TWORK2 := hour_min( Seconds() )
        mo_xml->REESTR := mkod_reestr
        mo_xml->KOL2   := tmp1->KOL2
      Endif
*/
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
  
//  If eq_any( nTypeFile, _XML_FILE_FLK, _XML_FILE_R02, _XML_FILE_R06, _XML_FILE_D02 )
  If eq_any( nTypeFile, _XML_FILE_FLK_26, _XML_FILE_R02, _XML_FILE_R06, _XML_FILE_D02 )
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
  Delete File ( cFileProtokol )
  If go_to_schet // если выписаны счета
    Keyboard Chr( K_TAB ) + Chr( K_ENTER )
  Elseif go_to_akt // если приняты акты
    Keyboard Replicate( Chr( K_TAB ), 3 ) + Replicate( Chr( K_ENTER ), 2 )
  Elseif go_to_rpd // если приняты платёжки
    Keyboard Replicate( Chr( K_TAB ), 4 ) + Chr( K_ENTER )
  Endif
  Return Nil

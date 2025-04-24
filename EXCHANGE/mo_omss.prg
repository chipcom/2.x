// mo_omss.prg - работа со счетами в задаче ОМС
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 28.12.21 читать файлы из ТФОМС (или СМО)
Function read_from_tf()

  Local name_zip, _date, _time, s, arr_f := {}, buf, blk_sp_tk, fl := .f., n, hUnzip, ;
    nErr, cFile, cName, arr_XML_info[ 7 ], tip_csv_file := 0, kod_csv_reestr := 0

  If ! hb_user_curUser:isadmin()
    Return func_error( 4, err_admin )
  Endif
  If find_unfinished_reestr_sp_tk()
    Return func_error( 4, 'Попытайтесь снова' )
  Endif
  Private p_var_manager := 'Read_From_TFOMS', p_ctrl_enter_sp_tk := .f.
  blk_sp_tk := {|| p_ctrl_enter_sp_tk := .t., __Keyboard( Chr( K_ENTER ) ) }
  SetKey( K_CTRL_ENTER, blk_sp_tk )
  Private full_zip := manager( T_ROW, T_COL + 5, MaxRow() -2, , .t., 1, , , , '*.zip' )
  SetKey( K_CTRL_ENTER, nil )
  If !Empty( full_zip )
    full_zip := Upper( full_zip )
    name_zip := strippath( full_zip )
    cName := name_without_ext( name_zip )
    /*if right(full_zip, 4) == scsv
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
          fl := func_error( 4, 'В архиве ' + name_zip + ' нет файла ' + cName + scsv )
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
      viewtext( devide_into_pages( dir_server + dir_XML_TF + cslash + cName + stxt, 60, 80 ), , , , .t., , , 2 )
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
      If Year( sys_date ) < 2016
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
        fl := read_xml_from_tf( arr_f[ n ], arr_XML_info, arr_f )
      Else
        fl := func_error( 4, 'В архиве ' + name_zip + ' нет файла ' + cName + sxml )
      Endif
    Endif
  Endif

  Return fl

// 15.10.24 чтение в память и анализ XML-файла
Function read_xml_from_tf( cFile, arr_XML_info, arr_f )

  Local nTypeFile := 0, aerr := {}, j, oXmlDoc, oXmlNode, oNode1, oNode2, ;
    nCountWithErr := 0, adbf, go_to_schet := .f., go_to_akt := .f., ;
    go_to_rpd := .f., nerror, buf := save_maxrow()

  nTypeFile := arr_XML_info[ 1 ]
  For j := 1 To 4
    If !myfiledeleted( cur_dir + 'tmp' + lstr( j ) + 'file' + sdbf )
      Return Nil
    Endif
  Next
  For j := 1 To 8
    If !myfiledeleted( cur_dir + 'tmp_r_t' + lstr( j ) + sdbf )
      Return Nil
    Endif
  Next
  If eq_any( nTypeFile, _XML_FILE_FLK, _XML_FILE_R02, _XML_FILE_R12, _XML_FILE_R06, _XML_FILE_D02 )
    //
  Elseif !mo_lock_task( X_OMS )
    Return .f.
  Endif
  mywait( 'Производится анализ файла ' + cFile )
  Private cReadFile := name_without_ext( cFile ), ;
    cTimeBegin := hour_min( Seconds() ), ;
    mkod_reestr := 0, mXML_REESTR := 0, mdate_schet, is_err_FLK := .f.
  Private cFileProtokol := cReadFile + stxt
  StrFile( Space( 10 ) + 'Протокол обработки файла: ' + cFile + hb_eol(), cFileProtokol )
  StrFile( Space( 10 ) + full_date( sys_date ) + 'г. ' + cTimeBegin + hb_eol(), cFileProtokol, .t. )
  // читаем файл в память
  oXmlDoc := hxmldoc():read( _tmp_dir1() + cFile, , @nerror )
  If oXmlDoc == Nil .or. Empty( oXmlDoc:aItems )
    AAdd( aerr, 'Ошибка в чтении файла ' + cFile )
  Elseif oXmlDoc:getattribute( 'encoding' ) == 'UTF-8'
    AAdd( aerr, '' )
    AAdd( aerr, 'В файле ' + cFile + ' кодировка UTF-8, а должна быть Windows-1251' )
  Elseif nTypeFile == _XML_FILE_FLK
    is_err_FLK := protokol_flk_tmpfile( arr_f, aerr )
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
  Close databases
  If Empty( aerr )
    Do Case
    Case nTypeFile == _XML_FILE_FLK
      StrFile( hb_eol() + 'Тип файла: протокол ФЛК (форматно-логического контроля)' + hb_eol() + hb_eol(), cFileProtokol, .t. )
      If read_xml_file_flk( arr_XML_info, aerr )
        // запишем принимаемый файл (протокол ФЛК)
        // chip_copy_zipXML(hb_OemToAnsi(full_zip),dir_server+dir_XML_TF)
        chip_copy_zipxml( full_zip, dir_server + dir_XML_TF )
        Use ( cur_dir + 'tmp1file' ) New Alias TMP1
        g_use( dir_server + 'mo_xml', , 'MO_XML' )
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
    Case nTypeFile == _XML_FILE_SP
      StrFile( hb_eol() + 'Тип файла: реестр СП и ТК (страховой принадлежности и технологического контроля)' + hb_eol() + hb_eol(), cFileProtokol, .t. )
      nCountWithErr := 0
      If read_xml_file_sp( arr_XML_info, aerr, @nCountWithErr ) > 0
        go_to_schet := create_schet_from_xml( arr_XML_info, aerr, , , cReadFile )
      Elseif nCountWithErr > 0 // все пришли с ошибкой
        g_use( dir_server + 'mo_xml', , 'MO_XML' )
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
      g_use( dir_server + 'mo_xml', , 'MO_XML' )
      Goto ( mXML_REESTR )
      g_rlock( forever )
      mo_xml->TWORK2 := hour_min( Seconds() )
    Case nTypeFile == _XML_FILE_R12
      StrFile( hb_eol() + 'Тип файла: PR11 (ответ на файл R11)' + hb_eol() + hb_eol(), cFileProtokol, .t. )
      nCountWithErr := 0
      read_xml_file_r02( arr_XML_info, aerr, @nCountWithErr, _XML_FILE_R12 )
      g_use( dir_server + 'mo_xml', , 'MO_XML' )
      Goto ( mXML_REESTR )
      g_rlock( forever )
      mo_xml->TWORK2 := hour_min( Seconds() )
    Case nTypeFile == _XML_FILE_R06
      StrFile( hb_eol() + 'Тип файла: PR05 (ответ на файл R05)' + hb_eol() + hb_eol(), cFileProtokol, .t. )
      nCountWithErr := 0
      read_xml_file_r06( arr_XML_info, aerr, @nCountWithErr )
      g_use( dir_server + 'mo_xml', , 'MO_XML' )
      Goto ( mXML_REESTR )
      g_rlock( forever )
      mo_xml->TWORK2 := hour_min( Seconds() )
    Case nTypeFile == _XML_FILE_D02
      StrFile( hb_eol() + 'Тип файла: D02 (ответ на файл D01)' + hb_eol() + hb_eol(), cFileProtokol, .t. )
      nCountWithErr := 0
      read_xml_file_d02( arr_XML_info, aerr, @nCountWithErr )
      g_use( dir_server + 'mo_xml', , 'MO_XML' )
      Goto ( mXML_REESTR )
      g_rlock( forever )
      mo_xml->TWORK2 := hour_min( Seconds() )
    Endcase
  Endif
  Close databases
  rest_box( buf )
  If eq_any( nTypeFile, _XML_FILE_FLK, _XML_FILE_R02, _XML_FILE_R06, _XML_FILE_D02 )
    //
  Else
    mo_unlock_task( X_OMS )
  Endif
  If Empty( aerr ) .or. nCountWithErr > 0 // запишем файл протокола обработки
    chip_copy_zipxml( cFileProtokol, dir_server + dir_XML_TF )
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

// 22.06.23 прочитать реестр ФЛК
Function read_xml_file_flk( arr_XML_info, aerr )

  Local ii, pole, i, k, t_arr[ 2 ], adbf, ar

  mkod_reestr := arr_XML_info[ 7 ]
  Use ( cur_dir + 'tmp1file' ) New Alias TMP1
  r_use( dir_server + 'mo_rees', , 'REES' )
  Goto ( arr_XML_info[ 7 ] )
  StrFile( 'Обрабатывается ответ ТФОМС на реестр № ' + ;
    lstr( rees->NSCHET ) + ' от ' + full_date( rees->DSCHET ) + 'г. (' + ;
    lstr( rees->KOL ) + ' чел.)' + ;
    hb_eol(), cFileProtokol, .t. )
  If !emptyany( rees->nyear, rees->nmonth )
    StrFile( 'выставленный за ' + ;
      mm_month[ rees->nmonth ] + Str( rees->nyear, 5 ) + ' года' + ;
      hb_eol(), cFileProtokol, .t. )
  Endif
  Use ( cur_dir + 'tmp2file' ) New Alias TMP2
  Index On Str( tip, 1 ) + Str( oshib, 3 ) + soshib to ( cur_dir + 'tmp2' )
  If is_err_FLK
    If !extract_reestr( rees->( RecNo() ), rees->name_xml )
      AAdd( aerr, Center( 'Не найден ZIP-архив с РЕЕСТРом № ' + lstr( rees->nschet ) + ' от ' + date_8( rees->DSCHET ), 80 ) )
      AAdd( aerr, '' )
      AAdd( aerr, Center( dir_server + dir_XML_MO + cslash + AllTrim( rees->name_xml ) + szip, 80 ) )
      AAdd( aerr, '' )
      AAdd( aerr, Center( 'Без данного архива дальнейшая работа НЕВОЗМОЖНА!', 80 ) )
      Close databases
      Return .f.
    Endif
    Use ( cur_dir + 'tmp_r_t1' ) New Alias T1
    Index On Upper( ID_PAC ) to ( cur_dir + 'tmp_r_t1' )
    Use ( cur_dir + 'tmp_r_t2' ) New Alias T2
    Use ( cur_dir + 'tmp_r_t3' ) New Alias T3
    Use ( cur_dir + 'tmp_r_t4' ) New Alias T4
    Use ( cur_dir + 'tmp_r_t5' ) New Alias T5
    Use ( cur_dir + 'tmp_r_t6' ) New Alias T6
    Use ( cur_dir + 'tmp_r_t7' ) New Alias T7
    Use ( cur_dir + 'tmp_r_t8' ) New Alias T8
    // заполнить поле 'N_ZAP' в файле 'tmp2'
    fill_tmp2_file_flk()
    r_use( dir_server + 'mo_otd', , 'OTD' )
    g_use( dir_server + 'human_', , 'HUMAN_' )
    g_use( dir_server + 'human', , 'HUMAN' )
    Set Relation To RecNo() into HUMAN_, To otd into OTD
    g_use( dir_server + 'mo_rhum', , 'RHUM' )
    Index On Str( REES_ZAP, 6 ) to ( cur_dir + 'tmp_rhum' ) For reestr == mkod_reestr
    Select TMP2 // сначала проверка
    Go Top
    Do While !Eof()
      Select RHUM
      find ( Str( tmp2->N_ZAP, 6 ) )
      If Found()
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
      Select TMP2
      Skip
    Enddo
    If !Empty( aerr )
      Close databases
      Return .f.
    Endif
  Endif
  For ii := 1 To 2
    pole := 'tmp1->fname' + lstr( ii )
    StrFile( hb_eol() + 'Обработан файл ' + &pole + hb_eol(), cFileProtokol, .t. )
    Select TMP2
    find ( Str( ii, 1 ) )
    If Found()
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
          // s += alltrim(inieditspr(A__POPUPMENU, dir_exe()+'_mo_Q015', tmp2->SOSHIB))
          s += AllTrim( inieditspr( A__MENUVERT, loadq015(), tmp3->SREFREASON ) )
        Endif
        If !Empty( tmp2->IM_POL )
          s += ', имя поля = ' + AllTrim( tmp2->IM_POL )
        Endif
        If !Empty( tmp2->BAS_EL )
          s += ', имя базового элемента = ' + AllTrim( tmp2->BAS_EL )
        Endif
        If !Empty( tmp2->ID_BAS )
          s += ', GUID базового элемента = ' + AllTrim( tmp2->ID_BAS )
        Endif
        If !Empty( tmp2->COMMENT )
          s += ', описание ошибки = ' + AllTrim( tmp2->COMMENT )
        Endif
        If !Empty( tmp2->BAS_EL ) .and. !Empty( tmp2->ID_BAS )
          If Empty( tmp2->N_ZAP )
            s += ', СЛУЧАЙ НЕ НАЙДЕН!'
          Else
            Select RHUM
            find ( Str( tmp2->N_ZAP, 6 ) )
            g_rlock( forever )
            rhum->OPLATA := 2
            tmp2->kod_human := rhum->KOD_HUM
            Select HUMAN
            Goto ( rhum->KOD_HUM )
            If human_->REESTR == mkod_reestr
              g_rlock( forever )
              human_->( g_rlock( forever ) )
              human_->OPLATA := 2
              human_->REESTR := 0 // направляется на дальнейшее редактирование
              human_->ST_VERIFY := 0 // снова ещё не проверен
              If human_->REES_NUM > 0
                human_->REES_NUM := human_->REES_NUM - 1
              Endif
              Unlock
              s += ', ' + AllTrim( human->fio ) + ', ' + full_date( human->date_r ) + ;
                iif( Empty( otd->SHORT_NAME ), '', ' [' + AllTrim( otd->SHORT_NAME ) + ']' ) + ;
                ' ' + date_8( human->n_data ) + '-' + date_8( human->k_data )
            Endif
          Endif
        Endif
        k := perenos( t_arr, s, 75 )
        StrFile( hb_eol(), cFileProtokol, .t. )
        For i := 1 To k
          StrFile( Space( 5 ) + t_arr[ i ] + hb_eol(), cFileProtokol, .t. )
        Next
        Select TMP2
        Skip
      Enddo
    Else
      StrFile( '-- Ошибок не обнаружено -- ' + hb_eol(), cFileProtokol, .t. )
    Endif
  Next
  Close databases

  Return .t.

// 22.01.19 заполнить поле 'N_ZAP' в файле 'tmp2'
Function fill_tmp2_file_flk()

  Local i, s, s1, adbf, ar

  Use ( cur_dir + 'tmp22fil' ) New Alias TMP22
  Select TMP2
  adbf := Array( FCount() )
  Go Top
  Do While !Eof()
    If !Empty( tmp2->BAS_EL ) .and. !Empty( tmp2->ID_BAS )
      s := AllTrim( tmp2->BAS_EL )
      s1 := AllTrim( tmp2->ID_BAS )
      Do Case
      Case s == 'ZAP'
        Select T1
        Locate For t1->N_ZAP == PadR( s1, 6 )
        If Found()
          tmp2->N_ZAP := Val( t1->N_ZAP )
        Endif
      Case s == 'PACIENT'
        ar := {}
        Select T1
        find ( PadR( Upper( s1 ), 36 ) )
        Do While Upper( t1->ID_PAC ) == PadR( Upper( s1 ), 36 )
          AAdd( ar, Int( Val( t1->N_ZAP ) ) )
          Skip
        Enddo
        If Len( ar ) > 0
          Select TMP2
          tmp2->N_ZAP := ar[ 1 ]
          If Len( ar ) > 1
            AEval( adbf, {| x, i| adbf[ i ] := FieldGet( i ) } )
            Select TMP22
            For i := 2 To Len( ar )
              Append Blank
              AEval( adbf, {| x, i| FieldPut( i, x ) } )
              tmp22->N_ZAP := ar[ i ]
            Next
          Endif
        Endif
      Case eq_any( s, 'SLUCH', 'Z_SL' )
        Select T1
        Locate For Upper( t1->ID_C ) == PadR( Upper( s1 ), 36 )
        If Found()
          tmp2->N_ZAP := Val( t1->N_ZAP )
        Endif
      Case s == 'USL'
        Select T2
        Locate For Upper( t2->ID_U ) == PadR( Upper( s1 ), 36 )
        If Found()
          Select T1
          Locate For t1->N_ZAP == t2->IDCASE
          If Found()
            tmp2->N_ZAP := Val( t1->N_ZAP )
          Endif
        Endif
      Case s == 'PERS'
        Select T3
        Locate For Upper( t3->ID_PAC ) == PadR( Upper( s1 ), 36 )
        If Found()
          ar := {}
          Select T1
          find ( PadR( Upper( s1 ), 36 ) )
          Do While Upper( t1->ID_PAC ) == PadR( Upper( s1 ), 36 )
            AAdd( ar, Int( Val( t1->N_ZAP ) ) )
            Skip
          Enddo
          If Len( ar ) > 0
            Select TMP2
            tmp2->N_ZAP := ar[ 1 ]
            If Len( ar ) > 1
              AEval( adbf, {| x, i| adbf[ i ] := FieldGet( i ) } )
              Select TMP22
              For i := 2 To Len( ar )
                Append Blank
                AEval( adbf, {| x, i| FieldPut( i, x ) } )
                tmp22->N_ZAP := ar[ i ]
              Next
            Endif
          Endif
        Endif
      Endcase
    Endif
    Select TMP2
    Skip
  Enddo
  i := tmp22->( LastRec() )
  tmp22->( dbCloseArea() )
  If i > 0
    Select TMP2
    Append From tmp22fil codepage 'RU866'
    Index On Str( tip, 1 ) + Str( oshib, 3 ) to ( cur_dir + 'tmp2' )
  Endif

  Return Nil

// 22.06.23 прочитать и 'разнести' по базам данных реестр СП и ТК
Function read_xml_file_sp( arr_XML_info, aerr, /*@*/current_i2)

  Local count_in_schet := 0, mnschet, bSaveHandler, ii1, ii2, i, k, t_arr[ 2 ], ;
    ldate_sptk, s, fl_589, mANSREESTR

  Local reserveKSG_ID_C := '' // GUID для вложенных двойных случаев

  If !( Type( 'p_ctrl_enter_sp_tk' ) == 'L' )
    Private p_ctrl_enter_sp_tk := .f.
  Endif
  Use ( cur_dir + 'tmp1file' ) New Alias TMP1
  ldate_sptk := tmp1->_DATA
  mnschet := Int( Val( tmp1->_NSCHET ) )  // в число (отрезать всё, что после '-')
  mANSREESTR := AfterAtNum( '-', tmp1->_NSCHET )
  r_use( dir_server + 'mo_rees', , 'REES' )
  Index On Str( NSCHET, 6 ) to ( cur_dir + 'tmp_rees' ) For NYEAR == tmp1->_YEAR
  find ( Str( mnschet, 6 ) )
  If Found()
    mkod_reestr := arr_XML_info[ 7 ] := rees->kod
    StrFile( 'Обрабатывается ответ ТФОМС (' + AllTrim( tmp1->_NSCHET ) + ') на реестр № ' + ;
      lstr( rees->NSCHET ) + ' от ' + full_date( rees->DSCHET ) + 'г. (' + ;
      lstr( rees->KOL ) + ' чел.)' + ;
      hb_eol(), cFileProtokol, .t. )
    If !emptyany( rees->nyear, rees->nmonth )
      StrFile( 'выставленный за ' + ;
        mm_month[ rees->nmonth ] + Str( rees->nyear, 5 ) + ' года' + ;
        hb_eol(), cFileProtokol, .t. )
    Endif
    StrFile( hb_eol(), cFileProtokol, .t. )
    //
    r_use( dir_server + 'mo_xml', , 'MO_XML' )
    Index On ANSREESTR to ( cur_dir + 'tmp_xml' ) For reestr == mkod_reestr
    find ( mANSREESTR )
    If Found()
      AAdd( aerr, 'По реестру № ' + lstr( mnschet ) + ' от ' + date_8( tmp1->_DSCHET ) + ' уже прочитан ответ номер "' + AllTrim( tmp1->_NSCHET ) + '"' )
    Endif
  Else
    AAdd( aerr, 'Не найден РЕЕСТР № ' + lstr( mnschet ) + ' от ' + date_8( tmp1->_DSCHET ) )
  Endif
  If Empty( aerr ) .and. !extract_reestr( rees->( RecNo() ), rees->name_xml )
    AAdd( aerr, Center( 'Не найден ZIP-архив с РЕЕСТРом № ' + lstr( mnschet ) + ' от ' + date_8( tmp1->_DSCHET ), 80 ) )
    AAdd( aerr, '' )
    AAdd( aerr, Center( dir_server + dir_XML_MO + cslash + AllTrim( rees->name_xml ) + szip, 80 ) )
    AAdd( aerr, '' )
    AAdd( aerr, Center( 'Без данного архива дальнейшая работа НЕВОЗМОЖНА!', 80 ) )
  Endif
  If Empty( aerr )
    r_use( dir_server + 'human_3', { dir_server + 'human_3', dir_server + 'human_32' }, 'HUMAN_3' )
    r_use( dir_server + 'human', , 'HUMAN' )
    r_use( dir_server + 'human_', , 'HUMAN_' )
    r_use( dir_server + 'mo_rhum', , 'RHUM' )
    Index On Str( REES_ZAP, 6 ) to ( cur_dir + 'tmp_rhum' ) For reestr == mkod_reestr
    Use ( cur_dir + 'tmp2file' ) New Alias TMP2
    // сначала проверка
    ii1 := ii2 := 0
    Go Top
    Do While !Eof()
      If tmp2->_OPLATA == 1
        ++ii1
        If AScan( glob_arr_smo, {| x| x[ 2 ] == Int( Val( tmp2->_SMO ) ) } ) == 0
          AAdd( aerr, 'Некорректное значение атрибута SMO: ' + tmp2->_SMO )
        Endif
      Elseif tmp2->_OPLATA == 2
        ++ii2
      Else
        AAdd( aerr, 'Некорректное значение атрибута OPLATA: ' + lstr( tmp2->_OPLATA ) )
      Endif
      Select RHUM
      find ( Str( tmp2->_N_ZAP, 6 ) )
      If Found()
        human_->( dbGoto( rhum->KOD_HUM ) )
        human->( dbGoto( rhum->KOD_HUM ) )
        If human->ishod == 89 // это 2-ой случай в двойном случае
          Select HUMAN_3
          Set Order To 2
          find ( Str( rhum->KOD_HUM, 7 ) )
          If Found()
            reserveKSG_ID_C = human_3->ID_C
            human_->( dbGoto( human_3->kod ) )   // встать на 1-ый случай
            human->( dbGoto( human_3->kod ) )    // т.к. GUID'ы в реестре из 1-го случая
          Endif
        Endif
        tmp2->fio := human->fio
        If rhum->OPLATA > 0
          AAdd( aerr, 'Пациент с REES_ZAP=' + lstr( rhum->REES_ZAP ) + ' был прочитан в предыдущем реестре СП и ТК' )
          If !Empty( human->fio )
            AAdd( aerr, '└─>(ФИО пациента = ' + AllTrim( human->fio ) + ')' )
          Endif
        Endif
        If iif( p_ctrl_enter_sp_tk, ( tmp2->_OPLATA == 1 ), .t. )
          If !( rhum->REES_ZAP == human_->REES_ZAP )
            AAdd( aerr, 'Не равен параметр REES_ZAP: ' + lstr( rhum->REES_ZAP ) + ' != ' + lstr( human_->REES_ZAP ) )
          Endif
          If !( Upper( tmp2->_ID_PAC ) == Upper( human_->ID_PAC ) )
            AAdd( aerr, 'Не равен параметр ID_PAC: ' + tmp2->_ID_PAC + ' != ' + human_->ID_PAC )
          Endif
          If Empty( reserveKSG_ID_C ) .and. !( Upper( tmp2->_ID_C ) == Upper( human_->ID_C ) )
            AAdd( aerr, 'Не равен параметр ID_C: ' + tmp2->_ID_C + ' != ' + human_->ID_C )
          Elseif !Empty( reserveKSG_ID_C ) .and. !( Upper( tmp2->_ID_C ) == Upper( reserveKSG_ID_C ) )
            AAdd( aerr, 'Не равен параметр ID_C для вложенного двойного случая: ' + tmp2->_ID_C + ' != ' + reserveKSG_ID_C )
          Endif
        Endif
      Else
        AAdd( aerr, 'Не найден случай с N_ZAP=' + lstr( tmp2->_N_ZAP ) + ', _ID_PAC=' + tmp2->_ID_PAC )
      Endif
      reserveKSG_ID_C := ''
      Select TMP2
      Skip
    Enddo
    tmp1->kol1 := ii1
    tmp1->kol2 := ii2
    Close databases
    If Empty( aerr ) // если проверка прошла успешно
      Private fl_open := .t.
      bSaveHandler := ErrorBlock( {| x| Break( x ) } )
      Begin Sequence
        If ii1 > 0 // были пациенты без ошибок
          index_base( 'schet' ) // для составления счетов
          index_base( 'human' ) // для разноски счетов
          index_base( 'human_3' ) // двойные случаи
          Use ( dir_server + 'human_u' ) New READONLY
          Index On Str( kod, 7 ) + date_u to ( dir_server + 'human_u' ) progress
          Use
          Use ( dir_server + 'mo_hu' ) New READONLY
          Index On Str( kod, 7 ) + date_u to ( dir_server + 'mo_hu' ) progress
          Use
        Endif
        If ii2 > 0 // были пациенты с ошибками
          If !p_ctrl_enter_sp_tk
            index_base( 'mo_refr' )  // для записи причин отказов
          Endif
          If ii1 == 0 // в ответном файле не было пациентов без ошибок
            index_base( 'human' ) // для разноски ФИО
          Endif
        Endif
      RECOVER USING error
        AAdd( aerr, 'Возникла непредвиденная ошибка при переиндексировании!' )
      End
      ErrorBlock( bSaveHandler )
      Close databases
    Endif
    If Empty( aerr ) // если проверка прошла успешно
      // запишем принимаемый файл (реестр СП)
      // chip_copy_zipXML(hb_OemToAnsi(full_zip),dir_server+dir_XML_TF)
      chip_copy_zipxml( full_zip, dir_server + dir_XML_TF )
      g_use( dir_server + 'mo_xml', , 'MO_XML' )
      addrecn()
      mo_xml->KOD := RecNo()
      mo_xml->FNAME := cReadFile
      mo_xml->DFILE := ldate_sptk
      mo_xml->TFILE := ''
      mo_xml->DREAD := sys_date
      mo_xml->TREAD := hour_min( Seconds() )
      mo_xml->TIP_IN := _XML_FILE_SP // тип принимаемого файла;3-ФЛК, 4-СП, 5-РАК, 6-РПД пишем в каталог XML_TF
      mo_xml->DWORK  := sys_date
      mo_xml->TWORK1 := cTimeBegin
      mo_xml->REESTR := mkod_reestr
      mo_xml->ANSREESTR := mANSREESTR
      mo_xml->KOL1 := ii1
      mo_xml->KOL2 := ii2
      //
      mXML_REESTR := mo_xml->KOD
      Use
      If ii2 > 0
        If !p_ctrl_enter_sp_tk
          g_use( dir_server + 'mo_refr', dir_server + 'mo_refr', 'REFR' )
        Endif
        // G_Use(dir_server + 'mo_kfio',,'KFIO')
        // index on str(kod, 7) to (cur_dir + 'tmp_kfio')
      Endif
      // открыть распакованный реестр
      Use ( cur_dir + 'tmp_r_t1' ) New Alias T1
      Index On Str( Val( n_zap ), 6 ) to ( cur_dir + 'tmpt1' )
      Use ( cur_dir + 'tmp_r_t2' ) New Alias T2
      Index On IDCASE + Str( sluch, 6 ) to ( cur_dir + 'tmpt2' )
      Use ( cur_dir + 'tmp_r_t3' ) New Alias T3
      Index On Upper( ID_PAC ) to ( cur_dir + 'tmpt3' )
      Use ( cur_dir + 'tmp_r_t4' ) New Alias T4
      Index On IDCASE + Str( sluch, 6 ) to ( cur_dir + 'tmpt4' )
      Use ( cur_dir + 'tmp_r_t5' ) New Alias T5
      Index On IDCASE + Str( sluch, 6 ) to ( cur_dir + 'tmpt5' )
      Use ( cur_dir + 'tmp_r_t6' ) New Alias T6
      Index On IDCASE + Str( sluch, 6 ) to ( cur_dir + 'tmpt6' )
      Use ( cur_dir + 'tmp_r_t7' ) New Alias T7
      Index On IDCASE + Str( sluch, 6 ) to ( cur_dir + 'tmpt7' )
      Use ( cur_dir + 'tmp_r_t8' ) New Alias T8
      Index On IDCASE + Str( sluch, 6 ) to ( cur_dir + 'tmpt8' )
      Use ( cur_dir + 'tmp_r_t9' ) New Alias T9
      Index On IDCASE + Str( sluch, 6 ) to ( cur_dir + 'tmpt9' )
      Use ( cur_dir + 'tmp_r_t10' ) New Alias T10
      Index On IDCASE + Str( sluch, 6 ) + regnum + code_sh + date_inj to ( cur_dir + 'tmpt10' )
      Use ( cur_dir + 'tmp_r_t11' ) New Alias T11
      Index On IDCASE + Str( sluch, 6 ) to ( cur_dir + 'tmpt11' )
      Use ( cur_dir + 'tmp_r_t12' ) New Alias T12
      Index On IDCASE + Str( sluch, 6 ) to ( cur_dir + 'tmpt12' )
      Use ( cur_dir + 'tmp_r_t1_1' ) New Alias T1_1
      Index On IDCASE to ( cur_dir + 'tmpt1_1' )
      //
      g_use( dir_server + 'mo_kfio', , 'KFIO' )
      Index On Str( kod, 7 ) to ( cur_dir + 'tmp_kfio' )
      g_use( dir_server + 'kartote2', , 'KART2' )
      g_use( dir_server + 'kartote_', , 'KART_' )
      g_use( dir_server + 'kartotek', dir_server + 'kartoten', 'KART' )
      Set Order To 0 // индекс открыт для реконструкции при перезаписи ФИО и даты рождения
      r_use( dir_server + 'mo_otd', , 'OTD' )
      g_use( dir_server + 'human_', , 'HUMAN_' )
      g_use( dir_server + 'human', { dir_server + 'humann', dir_server + 'humans' }, 'HUMAN' )
      Set Order To 0 // индексы открыты для реконструкции при перезаписи ФИО
      Set Relation To RecNo() into HUMAN_, To otd into OTD
      g_use( dir_server + 'human_3', { dir_server + 'human_3', dir_server + 'human_32' }, 'HUMAN_3' )
      g_use( dir_server + 'mo_rhum', , 'RHUM' )
      Index On Str( REES_ZAP, 6 ) to ( cur_dir + 'tmp_rhum' ) For reestr == mkod_reestr
      Use ( cur_dir + 'tmp3file' ) New Alias TMP3
      Index On Str( _n_zap, 8 ) to ( cur_dir + 'tmp3' )
      Use ( cur_dir + 'tmp2file' ) New Alias TMP2
      count_in_schet := LastRec()
      current_i2 := 0
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
        g_rlock( forever )
        rhum->OPLATA := tmp2->_OPLATA
        tmp2->kod_human := rhum->KOD_HUM
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
            human_->( g_rlock( forever ) )
            human_->OPLATA := tmp2->_OPLATA
            If tmp2->_OPLATA > 1 .and. !p_ctrl_enter_sp_tk
              human_->REESTR := 0 // направляется на дальнейшее редактирование
              human_->ST_VERIFY := 0 // снова ещё не проверен
            Endif
            human_3->( g_rlock( forever ) )
            human_3->OPLATA := tmp2->_OPLATA
            human_3->REESTR := 0
          Endif
        Endif
        Select HUMAN
        Goto ( rhum->KOD_HUM )
        g_rlock( forever )
        human_->( g_rlock( forever ) )
        human_->OPLATA := tmp2->_OPLATA
        kart->( dbGoto( human->kod_k ) )
        fl_589 := .f.
        If tmp2->_OPLATA == 1
          human->POLIS   := make_polis( tmp2->_spolis, tmp2->_npolis )
          human_->VPOLIS := tmp2->_VPOLIS
          human_->SPOLIS := tmp2->_SPOLIS
          human_->NPOLIS := tmp2->_NPOLIS
          human_->OKATO  := tmp2->_SMO_OK
          If Int( Val( tmp2->_SMO ) ) != 34 // не иногородние
            human_->SMO := tmp2->_SMO
          Endif
          If kart->za_smo == -9
            Select KART
            g_rlock( forever )
            kart->za_smo := 0  // снять признак 'Проблемы с полисом'
            dbUnlock()
          Endif
          If !eq_any( tmp2->_MO_PR, Space( 6 ), Replicate( '0', 6 ) ) .or. !Empty( tmp2->_enp )
            Select KART2
            Do While kart2->( LastRec() ) < human->kod_k
              Append Blank
            Enddo
            Goto ( human->kod_k )
            If Empty( kart2->MO_PR )
              g_rlock( forever )
              If !eq_any( tmp2->_MO_PR, Space( 6 ), Replicate( '0', 6 ) )
                kart2->MO_PR := tmp2->_MO_PR
                kart2->TIP_PR := 2 // тип/статус прикрепления 2-из реестра СП и ТК
                kart2->DATE_PR := ldate_sptk
                If Empty( kart2->pc4 )
                  kart2->pc4 := date_8( kart2->pc4 )
                Endif
              Endif
              If !Empty( tmp2->_enp )
                kart2->kod_mis := tmp2->_enp
              Endif
              dbUnlock()
            Endif
          Endif
        Else // tmp2->_OPLATA == 2
          --count_in_schet    // не включается в счет,
          If !p_ctrl_enter_sp_tk
            human_->REESTR := 0 // а направляется на дальнейшее редактирование
            human_->ST_VERIFY := 0 // снова ещё не проверен
            If current_i2 == 0
              StrFile( Space( 10 ) + 'Список случаев с ошибками' + hb_eol() + hb_eol(), cFileProtokol, .t. )
            Endif
            ++current_i2
            lal := 'human'
            If is_2 > 0
              lal += '_3'
            Endif
            StrFile( lstr( current_i2 ) + '. ' + AllTrim( human->fio ) + ', ' + ;
              full_date( human->date_r ) + ;
              iif( Empty( otd->SHORT_NAME ), '', ' [' + AllTrim( otd->SHORT_NAME ) + ']' ) + ;
              ' ' + AllTrim( human->KOD_DIAG ) + ;
              ' ' + date_8( &lal.->n_data ) + '-' + ;
              date_8( &lal.->k_data ) + hb_eol(), cFileProtokol, .t. )
            // изменение ФИО
            If !emptyall( tmp2->CORRECT, tmp2->_FAM, tmp2->_IM, tmp2->_OT, tmp2->_DR )
              arr_fio := retfamimot( 2, .f., .t. )
              mdate_r := human->date_r
              s := ''
              // s := space(5) + '!Ошибки в персональных данных!'+eos
              If !Empty( tmp2->_FAM )
                // s += space(5) + 'старая фамилия '' + alltrim(arr_fio[1]) + '', изменена на '' + alltrim(tmp2->_FAM) + '''+eos
                s += Space( 5 ) + 'фамилия в нашей БД "' + AllTrim( arr_fio[ 1 ] ) + '", в регистре ТФОМС "' + AllTrim( tmp2->_FAM ) + '"' + eos
                arr_fio[ 1 ] := AllTrim( tmp2->_FAM )
              Endif
              If !Empty( tmp2->_IM )
                // s += space(5) + 'старое имя '' + alltrim(arr_fio[2]) + '', изменено на '' + alltrim(tmp2->_IM) + '''+eos
                s += Space( 5 ) + 'имя в нашей БД "' + AllTrim( arr_fio[ 2 ] ) + '", в регистре ТФОМС "' + AllTrim( tmp2->_IM ) + '"' + eos
                arr_fio[ 2 ] := AllTrim( tmp2->_IM )
              Endif
              If !emptyall( tmp2->CORRECT, tmp2->_OT )
                // s += space(5) + 'старое отчество '' + alltrim(arr_fio[3]) + '', изменено на '' + alltrim(tmp2->_OT) + '''+eos
                s += Space( 5 ) + 'отчество в нашей БД "' + AllTrim( arr_fio[ 3 ] ) + '", в регистре ТФОМС "' + AllTrim( tmp2->_OT ) + '"' + eos
                arr_fio[ 3 ] := AllTrim( tmp2->_OT )
              Endif
              If !Empty( tmp2->_DR )
                mdate_r := xml2date( tmp2->_DR )
                // s += space(5) + 'старая дата рождения ' + full_date(human->date_r) + ', изменена на ' + full_date(mdate_r) + eos
                s += Space( 5 ) + 'дата рождения в нашей БД ' + full_date( human->date_r ) + ', в регистре ТФОМС ' + full_date( mdate_r ) + eos
              Endif
              // s += space(5) + '(исправлено - войти в редактирование л/у и подтвердить запись)'+eos
              // s += space(5) + '(исправляйте самостоятельно; в случае несогласия обращайтесь в отдел ТФОМС'+eos
              // s += space(5) + ' по ведению регистра застрахованных лиц, тел.94-71-59, 95-87-88, 94-67-41)'+eos
              StrFile( s, cFileProtokol, .t. )
              /*
              newMEST_INOG := 0
              if TwoWordFamImOt(arr_fio[1]) .or. TwoWordFamImOt(arr_fio[2]) .or. TwoWordFamImOt(arr_fio[3])
                newMEST_INOG := 9
              endif
              mfio := arr_fio[1]+' '+arr_fio[2]+' '+arr_fio[3]
              if kart->MEST_INOG == 9 .or. newMEST_INOG == 9
                select KFIO
                find (str(kart->kod, 7))
                if found()
                  if newMEST_INOG == 9
                    G_RLock(forever)
                    kfio->FAM := arr_fio[1]
                    kfio->IM  := arr_fio[2]
                    kfio->OT  := arr_fio[3]
                    dbUnLock()
                  else
                    DeleteRec(.t.)
                  endif
                else
                  if newMEST_INOG == 9
                    AddRec(7)
                    kfio->kod := kart->kod
                    kfio->FAM := arr_fio[1]
                    kfio->IM  := arr_fio[2]
                    kfio->OT  := arr_fio[3]
                    dbUnLock()
                  endif
                endif
              endif
              select KART
              G_RLock(forever)
              kart->fio := mfio
              kart->date_r := mdate_r
              kart->MEST_INOG := newMEST_INOG
              dbUnLock()
              select HUMAN
              G_RLock(forever)
              human->fio := mfio
              human->date_r := mdate_r
              dbUnLock()
              */
            Endif
            Select REFR
            Do While .t.
              find ( Str( 1, 1 ) + Str( mkod_reestr, 6 ) + Str( 1, 1 ) + Str( rhum->KOD_HUM, 8 ) )
              If !Found()
                Exit
              Endif
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
                  StrFile( Space( 5 ) + lstr( refr->REFREASON ) + ' неизвестная причина отказа' + ;
                    hb_eol(), cFileProtokol, .t. )
                Else
                  If tmp3->_REFREASON == 562
                    s += ' (спец-ть врача ' + ret_tmp_prvs( human_->PRVS ) + ')'
                  Elseif tmp3->_REFREASON == 589 .and. Int( Val( tmp2->_SMO ) ) > 0
                    fl_589 := .t.
                    s += ' (в л/у и в карточке пациента исправлены полис и СМО - войти в редактирование л/у и подтвердить запись)'
                  Endif
                  k := perenos( t_arr, s, 75 )
                  For i := 1 To k
                    StrFile( Space( 5 ) + t_arr[ i ] + hb_eol(), cFileProtokol, .t. )
                  Next
                Endif
                If eq_any( refr->REFREASON, 57, 59 ) .and. kart->za_smo != -9
                  Select KART
                  g_rlock( forever )
                  kart->za_smo := -9  // установить признак 'Проблемы с полисом'
                  dbUnlock()
                Endif
                If refr->REFREASON == 513 .or. !eq_any( tmp2->_MO_PR, Space( 6 ), Replicate( '0', 6 ) )
                  Select KART2
                  Do While kart2->( LastRec() ) < human->kod_k
                    Append Blank
                  Enddo
                  Goto ( human->kod_k )
                  If Empty( kart2->MO_PR )
                    g_rlock( forever )
                    kart2->MO_PR := tmp2->_MO_PR
                    kart2->TIP_PR := 2
                    kart2->DATE_PR := ldate_sptk
                    If Empty( kart2->pc4 )
                      kart2->pc4 := date_8( kart2->pc4 )
                    Endif
                    dbUnlock()
                  Endif
                Endif
              Else
                s := 'код ошибки = ' + tmp3->SREFREASON + ' '
                s += '"' + getcategorycheckerrorbyid_q017( Left( tmp3->SREFREASON, 4 ) )[ 2 ] + '" '
                // s += alltrim(inieditspr(A__POPUPMENU, dir_exe()+'_mo_Q015', tmp3->SREFREASON))
                s += AllTrim( inieditspr( A__MENUVERT, loadq015(), tmp3->SREFREASON ) )
                k := perenos( t_arr, s, 75 )
                For i := 1 To k
                  StrFile( Space( 5 ) + t_arr[ i ] + hb_eol(), cFileProtokol, .t. )
                Next
              Endif
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
        Endif
        Unlock All
        If fl_589
          Select HUMAN
          g_rlock( forever )
          human->POLIS := make_polis( tmp2->_spolis, tmp2->_npolis )
          //
          human_->( g_rlock( forever ) )
          human_->VPOLIS := tmp2->_VPOLIS
          human_->SPOLIS := tmp2->_SPOLIS
          human_->NPOLIS := tmp2->_NPOLIS
          human_->SMO    := tmp2->_SMO
          human_->OKATO  := tmp2->_SMO_OK
          //
          Select KART_
          Goto ( human->kod_k )
          g_rlock( forever )
          kart_->VPOLIS    := tmp2->_VPOLIS
          kart_->SPOLIS    := tmp2->_SPOLIS
          kart_->NPOLIS    := tmp2->_NPOLIS
          kart_->SMO       := tmp2->_SMO
          kart_->KVARTAL_D := tmp2->_SMO_OK
          //
          Unlock All
        Endif
        Select TMP2
        If RecNo() % 1000 == 0
          Commit
        Endif
        Skip
      Enddo
    Endif
  Endif
  Close databases

  Return count_in_schet

// 28.01.23 создать счета по результатам прочитанного реестра СП
Function create_schet_from_xml( arr_XML_info, aerr, fl_msg, arr_s, name_sp_tk )

  Local arr_schet := {}, c, len_stand, _arr_stand, lshifr, i, j, k, lbukva, ;
    doplataF, doplataR, mnn, fl, name_zip, arr_zip := {}, lshifr1, ;
    CODE_LPU := glob_mo[ _MO_KOD_TFOMS ], code_schet, mb, me, nsh, ;
    CODE_MO  := glob_mo[ _MO_KOD_FFOMS ], s1

  Default fl_msg To .t., arr_s TO {}
  Private pole
  //
  Use ( cur_dir + 'tmp1file' ) New Alias TMP1
  mdate_schet := tmp1->_DSCHET
  nsh := f_mb_me_nsh( tmp1->_year, @mb, @me )
  k := tmp1->_year
  Close databases
  If k > 2018
    Return create_schet19_from_xml( arr_XML_info, aerr, fl_msg, arr_s, name_sp_tk )
  Else
    // см. файл not_use/create_schet17_from_XML.prg
    func_error( 10, 'Счет ранее 2019 не формируется!' )
    Return .f.
  Endif

  Return .t.

// 02.04.13 Просмотр списка счетов, запись для ТФОМС, печать счетов
Function view_list_schet()

  Local i, k, buf := SaveScreen(), tmp_help := chm_help_code, mdate := SToD( '20130101' )

  mywait()
  Close databases
  r_use( dir_server + 'mo_rees', , 'REES' )
  g_use( dir_server + 'mo_xml', , 'MO_XML' )
  g_use( dir_server + 'schet_', , 'SCHET_' )
  g_use( dir_server + 'schet', dir_server + 'schetd', 'SCHET' )
  Set Relation To RecNo() into SCHET_
  dbSeek( dtoc4( mdate ), .t. )
  Index On DToS( schet_->dschet ) + fsort_schet( schet_->nschet, nomer_s ) to ( cur_dir + 'tmp_sch' ) ;
    For schet_->dschet >= mdate .and. !Empty( pdate ) .and. ;
    ( schet_->IS_DOPLATA == 1 .or. !Empty( Val( schet_->smo ) ) ) ;
    DESCENDING
  Go Top
  If Eof()
    RestScreen( buf )
    Close databases
    Return func_error( 4, 'Нет выписанных счетов c ' + date_month( mdate ) )
  Endif
  chm_help_code := 122
  box_shadow( MaxRow() -3, 0, MaxRow() -1, 79, color0 )
  alpha_browse( T_ROW, 0, MaxRow() -4, 79, 'f1_view_list_schet', color0, , , , , , 'f21_view_list_schet', ;
    'f2_view_list_schet', , { '═', '░', '═', 'N/BG, W+/N, B/BG, BG+/B, R/BG, RB/BG, GR/BG', .t., 60 } )
  Close databases
  chm_help_code := tmp_help
  RestScreen( buf )

  Return Nil

// 24.04.25
Function f1_view_list_schet( oBrow )

  Local oColumn, ;
    blk := {|| iif( !Empty( schet_->NAME_XML ) .and. Empty( schet_->date_out ), { 3, 4 }, { 1, 2 } ) }

  oColumn := TBColumnNew( 'Номер счета', {|| schet_->nschet } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( '  Дата', {|| date_8( schet_->dschet ) } )
  oColumn:colorBlock := {|| f23_view_list_schet() }
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Пе-;риод', ;
    {|| iif( emptyany( schet_->nyear, schet_->nmonth ), ;
    Space( 5 ), ;
    Right( Str( schet_->nyear, 4 ), 2 ) + '/' + StrZero( schet_->nmonth, 2 ) ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( ' Сумма счета', {|| put_kop( schet->summa, 13 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Кол.;бол.', {|| Str( schet->kol, 4 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Критерий', {|| PadR( f3_view_list_schet(), 10 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Принадлежность;счета', {|| PadR( f4_view_list_schet(), 14 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( '  ', {|| f22_view_list_schet() } )
  oColumn:colorBlock := {|| f23_view_list_schet() }
  oBrow:addcolumn( oColumn )
//  status_key( '^<Esc>^ - выход;  ^<F5>^ - запись счетов за день;  ^<F9>^ - печать счёта/реестра' )
  status_key( '^<Esc>^-выход ^<F5>^-запись счетов за день ^<F6>^-документы за день ^<F9>^-печать счёта/реестра' )
  Return Nil

//
Function f21_view_list_schet()

  Local s := '', fl := .t., r := Row(), c := Col()

  If !emptyany( schet_->name_xml, schet_->kod_xml )
    fl := hb_FileExists( dir_server + dir_XML_MO + cslash + AllTrim( schet_->name_xml ) + szip )
    s := iif( fl, 'XML-файл: ', 'Нет XML-файла: ' ) + AllTrim( schet_->name_xml )
    mo_xml->( dbGoto( schet_->XML_REESTR ) )
    If mo_xml->REESTR > 0
      rees->( dbGoto( mo_xml->REESTR ) )
      s += ', по реестру № ' + lstr( rees->NSCHET ) + ' от ' + ;
        date_8( rees->DSCHET ) + 'г. (' + lstr( rees->KOL ) + ' чел.)'
    Endif
  Endif
  @ MaxRow() -2, 1 Say PadC( s, 78 ) Color iif( fl, color0, 'R/BG' )
  SetPos( r, c )

  Return Nil

//
Function f22_view_list_schet()

  Local s := '  '

  If schet_->NREGISTR == 1 // ещё не зарегистрирован
    s := ''
  Elseif schet_->NREGISTR == 2 // не будет зарегистрирован
    s := '▄▀'
  Elseif schet_->NREGISTR == 3 // удалён
    s := '--'
  Endif

  Return s

//
Function f23_view_list_schet()

  Local arr := iif( !Empty( schet_->NAME_XML ) .and. Empty( schet_->date_out ), { 3, 4 }, { 1, 2 } )

  If schet_->NREGISTR == 1 // ещё не зарегистрирован
    arr[ 1 ] := 5
  Elseif schet_->NREGISTR == 2 // не будет зарегистрирован
    arr[ 1 ] := 6
  Elseif schet_->NREGISTR == 3 // удалён
    arr[ 1 ] := 7
  Endif

  Return arr

// 24.04.25
Function f2_view_list_schet( nKey, oBrow )

  Local ret := -1, rec := schet->( RecNo() ), tmp_color := SetColor(), r, r1, r2, ;
    s, buf := SaveScreen(), arr, i, k, mdate, t_arr[ 2 ], arr_pmt := {}
  local destination, row, print_arr := {}

  Do Case
  Case nKey == K_F9
    print_schet( oBrow )
    Select SCHET
    ret := 0
  Case nKey == K_F6
    r := Row()
    arr := {}
    k := 0
    mdate := schet_->dschet
    find ( DToS( mdate ) )
    Do While schet_->dschet == mdate .and. !Eof()
      If !emptyany( schet_->name_xml, schet_->kod_xml )
        AAdd( arr, { schet_->nschet, schet_->name_xml, schet_->kod_xml, schet->( RecNo() ) } )
//        If Empty( schet_->date_out )
//          ++k
//        Endif
      Endif
      Skip
    Enddo
    If Len( arr ) == 0
      func_error( 4, 'Нечего записывать!' )
    Else
      If Len( arr ) > 1
        ASort( arr, , , {| x, y| x[ 1 ] < y[ 1 ] } )
        For i := 1 To Len( arr )
          schet->( dbGoto( arr[ i, 4 ] ) )
          AAdd( arr_pmt, { 'Счёт № ' + AllTrim( schet_->nschet ) + ' (' + ;
            lstr( schet_->nyear ) + '/' + StrZero( schet_->nmonth, 2 ) + ')', ;
            AClone( arr[ i ] ) } )
        Next
        If r + 2 + Len( arr ) > MaxRow() - 2
          r2 := r - 1
          r1 := r2 - Len( arr ) - 1
          If r1 < 0
            r1 := 0
          Endif
        Else
          r1 := r + 1
        Endif
        arr := {} // массив печатаемых счетов
        If ( t_arr := bit_popup( r1, 10, arr_pmt, , color5, 1, 'Запись документов (' + date_8( mdate ) + ')', 'B/W' ) ) != nil
          AEval( t_arr, {| x | AAdd( arr, AClone( x[ 2 ] ) ) } )
        Endif
        t_arr := Array( 2 )
      Endif
      If Len( arr ) > 0
        for each row in arr // выбираем только номера записей счетов для печати
          AAdd( print_arr , row[ 4 ] )
        next
        If f_esc_enter( 'записи документов за ' + date_8( mdate ) + 'г.' )
          Private p_var_manager := 'copy_schet'
          destination := manager( T_ROW, T_COL + 5, MaxRow() -2, , .t., 2, .f., , , ) // 'norton' для выбора каталога
          If ! Empty( destination )
            schet_reestr( print_arr, destination )
          Endif
        Endif
      Endif
    Endif
    Select SCHET
    Goto ( rec )
    ret := 0
  Case nKey == K_F5
    r := Row()
    arr := {}
    k := 0
    mdate := schet_->dschet
    find ( DToS( mdate ) )
    Do While schet_->dschet == mdate .and. !Eof()
      If !emptyany( schet_->name_xml, schet_->kod_xml )
        AAdd( arr, { schet_->nschet, schet_->name_xml, schet_->kod_xml, schet->( RecNo() ) } )
        If Empty( schet_->date_out )
          ++k
        Endif
      Endif
      Skip
    Enddo
    If Len( arr ) == 0
      func_error( 4, 'Нечего записывать!' )
    Else
      If Len( arr ) > 1
        ASort( arr, , , {| x, y| x[ 1 ] < y[ 1 ] } )
        For i := 1 To Len( arr )
          schet->( dbGoto( arr[ i, 4 ] ) )
          AAdd( arr_pmt, { 'Счёт № ' + AllTrim( schet_->nschet ) + ' (' + ;
            lstr( schet_->nyear ) + '/' + StrZero( schet_->nmonth, 2 ) + ;
            ') файл ' + AllTrim( schet_->name_xml ), AClone( arr[ i ] ) } )
        Next
        If r + 2 + Len( arr ) > MaxRow() -2
          r2 := r -1
          r1 := r2 - Len( arr ) -1
          If r1 < 0
            r1 := 0
          Endif
        Else
          r1 := r + 1
        Endif
        arr := {}
        If ( t_arr := bit_popup( r1, 10, arr_pmt, , color5, 1, 'Записываемые файлы счетов (' + date_8( mdate ) + ')', 'B/W' ) ) != NIL
          AEval( t_arr, {| x| AAdd( arr, AClone( x[ 2 ] ) ) } )
        Endif
        t_arr := Array( 2 )
      Endif
      If Len( arr ) > 0
        s := 'Количество счетов - ' + lstr( Len( arr ) ) + ;
          ', записываются в первый раз - ' + lstr( k ) + ':'
        For i := 1 To Len( arr )
          If i > 1
            s += ','
          Endif
          s += ' ' + AllTrim( arr[ i, 1 ] ) + ' (' + AllTrim( arr[ i, 2 ] ) + szip + ')'
        Next
        perenos( t_arr, s, 74 )
        f_message( t_arr, , color1, color8 )
        If f_esc_enter( 'записи счетов за ' + date_8( mdate ) + 'г.' )
          Private p_var_manager := 'copy_schet'
          s := manager( T_ROW, T_COL + 5, MaxRow() -2, , .t., 2, .f., , , ) // 'norton' для выбора каталога
          If !Empty( s )
            goal_dir := dir_server + dir_XML_MO + cslash
            If Upper( s ) == Upper( goal_dir )
              func_error( 4, 'Вы выбрали каталог, в котором уже записаны целевые файлы! Это недопустимо.' )
            Else
              cFileProtokol := 'prot_sch' + stxt
              StrFile( hb_eol() + Center( glob_mo[ _MO_SHORT_NAME ], 80 ) + hb_eol() + hb_eol(), cFileProtokol )
              smsg := 'Счета записаны на: ' + s + ;
                ' (' + full_date( sys_date ) + 'г. ' + hour_min( Seconds() ) + ')'
              StrFile( Center( smsg, 80 ) + hb_eol(), cFileProtokol, .t. )
              k := 0
              For i := 1 To Len( arr )
                zip_file := AllTrim( arr[ i, 2 ] ) + szip
                If hb_FileExists( goal_dir + zip_file )
                  mywait( 'Копирование "' + zip_file + '" в каталог "' + s + '"' )
                  // copy file (goal_dir+zip_file) to (hb_OemToAnsi(s)+zip_file)
                  Copy File ( goal_dir + zip_file ) to ( s + zip_file )
                  // if hb_fileExists(hb_OemToAnsi(s)+zip_file)
                  If hb_FileExists( s + zip_file )
                    ++k
                    schet->( dbGoto( arr[ i, 4 ] ) )
                    smsg := lstr( i ) + '. Счёт № ' + AllTrim( schet_->nschet ) + ;
                      ' от ' + date_8( mdate ) + 'г. (отч.период ' + ;
                      lstr( schet_->nyear ) + '/' + StrZero( schet_->nmonth, 2 ) + ;
                      ') ' + AllTrim( schet_->name_xml ) + szip
                    StrFile( hb_eol() + smsg + hb_eol(), cFileProtokol, .t. )
                    smsg := '   количество пациентов - ' + lstr( schet->kol ) + ;
                      ', сумма счёта - ' + expand_value( schet->summa, 2 )
                    StrFile( smsg + hb_eol(), cFileProtokol, .t. )
                    schet_->( g_rlock( forever ) )
                    schet_->DATE_OUT := sys_date
                    If schet_->NUMB_OUT < 99
                      schet_->NUMB_OUT++
                    Endif
                    //
                    mo_xml->( dbGoto( arr[ i, 3 ] ) )
                    mo_xml->( g_rlock( forever ) )
                    mo_xml->DREAD := sys_date
                    mo_xml->TREAD := hour_min( Seconds() )
                  Else
                    smsg := '! Ошибка записи файла ' + s + zip_file
                    func_error( 4, smsg )
                    StrFile( smsg + hb_eol(), cFileProtokol, .t. )
                  Endif
                Else
                  smsg := '! Не обнаружен файл ' + goal_dir + zip_file
                  func_error( 4, smsg )
                  StrFile( smsg + hb_eol(), cFileProtokol, .t. )
                Endif
              Next
              Unlock
              Commit
              viewtext( cFileProtokol, , , , .t., , , 2 )
                /*asize(t_arr, 1)
                perenos(t_arr,'Записано счетов - ' + lstr(k) + ' в каталог '+s+;
                     iif(k == len(arr), '', ', не записано счетов - ' + lstr(len(arr)-k)), 60)
                stat_msg('Запись завершена!')
                n_message(t_arr,,'GR+/B','W+/B', 18,,'G+/B')*/
            Endif
          Endif
        Endif
      Endif
    Endif
    Select SCHET
    Goto ( rec )
    ret := 0
  Case nKey == K_CTRL_F11 .and. !Empty( schet_->NAME_XML ) .and. schet_->XML_REESTR > 0
    k := schet_->XML_REESTR // ссылка на реестр СП и ТК
    arr := {}
    Go Top
    Do While !Eof()
      If !emptyany( schet_->name_xml, schet_->kod_xml ) .and. k == schet_->XML_REESTR
        AAdd( arr, schet->( RecNo() ) )
      Endif
      Skip
    Enddo
    If Len( arr ) == 0
      func_error( 4, 'Неудачный поиск!' )
    Else
      If Len( arr ) > 1
        For i := 1 To Len( arr )
          schet->( dbGoto( arr[ i ] ) )
          AAdd( arr_pmt, { 'Счёт № ' + AllTrim( schet_->nschet ) + ' (' + ;
            lstr( schet_->nyear ) + '/' + StrZero( schet_->nmonth, 2 ) + ;
            ') файл ' + AllTrim( schet_->name_xml ), arr[ i ] } )
        Next
        r := Row()
        If r + 2 + Len( arr ) > MaxRow() -2
          r2 := r -1
          r1 := r2 - Len( arr ) -1
          If r1 < 0
            r1 := 0
          Endif
        Else
          r1 := r + 1
        Endif
        arr := {}
        If ( t_arr := bit_popup( r1, 10, arr_pmt, , 'N/W*, GR+/R', 1, 'Пересоздаваемые файлы счетов', 'B/W*' ) ) != NIL
          AEval( t_arr, {| x| AAdd( arr, x[ 2 ] ) } )
        Endif
      Endif
      If Len( arr ) > 0
        recreate_some_schet_from_file_sp( arr )
        Close databases
        r_use( dir_server + 'mo_rees', , 'REES' )
        g_use( dir_server + 'mo_xml', , 'MO_XML' )
        g_use( dir_server + 'schet_', , 'SCHET_' )
        g_use( dir_server + 'schet', dir_server + 'schetd', 'SCHET' )
        Set Relation To RecNo() into SCHET_
        Go Top
        ret := 1
      Endif
    Endif
  Case nKey == K_CTRL_F12 .and. !Empty( schet_->NAME_XML ) .and. schet_->XML_REESTR > 0
    recreate_some_schet_from_file_sp( { schet->( RecNo() ) } )
    Close databases
    r_use( dir_server + 'mo_rees', , 'REES' )
    g_use( dir_server + 'mo_xml', , 'MO_XML' )
    g_use( dir_server + 'schet_', , 'SCHET_' )
    g_use( dir_server + 'schet', dir_server + 'schetd', 'SCHET' )
    Set Relation To RecNo() into SCHET_
    Go Top
    ret := 1
  Endcase
  SetColor( tmp_color )
  RestScreen( buf )

  Return ret

// 26.04.15
Function f3_view_list_schet()

  Local s := ''

  If schet_->nyear < 2013 .and. schet_->IS_MODERN == 1 // является модернизацией?;0-нет, 1-да для IFIN=1
    s := 'модернизация'
  Endif
  If schet_->IS_DOPLATA == 1 // является доплатой?;0-нет, 1-да для IFIN=1 или 2
    s := 'допл.'
    If schet_->IFIN == 1
      s += 'ТФОМС'
    Elseif schet_->IFIN == 2
      s += 'ФФОМС'
    Endif
  Endif
  If Empty( s ) .and. schet_->IFIN > 0
    s := 'ОМС '
    If schet_->bukva     == 'A'
      s += 'п-ка'
    Elseif schet_->bukva == 'D'
      s += 'ДДС'
    Elseif schet_->bukva == 'E'
      s += 'СМП'
    Elseif schet_->bukva == 'F'
      s += 'Нпроф.'
    Elseif schet_->bukva == 'G'
      s += 'дермат'
    Elseif schet_->bukva == 'H'
      s += 'ВМП'
    Elseif schet_->bukva == 'I'
      s += 'Нперио'
    Elseif schet_->bukva == 'J'
      s += 'п-ка'
    Elseif schet_->bukva == 'K'
      s += 'о/м/у'
    Elseif schet_->bukva == 'M'
      s += 'зак/с'
    Elseif schet_->bukva == 'O'
      s += 'ВНдисп'
    Elseif schet_->bukva == 'R'
      s += 'ВНпроф'
    Elseif schet_->bukva == 'S'
      s += 'стац.'
    Elseif schet_->bukva == 'T'
      s += 'стомат'
    Elseif schet_->bukva == 'U'
      s += 'ДДСоп'
    Elseif schet_->bukva == 'V'
      s += 'Нпред.'
    Elseif schet_->bukva == 'Z'
      s += 'дн/ст.'
    Elseif schet_->IFIN == 1
      s += 'ТФОМС'
    Elseif schet_->IFIN == 2
      s += 'ФФОМС'
    Endif
  Endif

  Return s

//
Function f4_view_list_schet( lkomu, lsmo, lstr_crb )

  Local s := ''

  Default lkomu To schet->komu, lsmo To schet_->smo, lstr_crb To schet->str_crb
  If lkomu == 5
    s := 'Личный счёт'
  Elseif !Empty( lsmo )
    s := inieditspr( A__MENUVERT, glob_arr_smo, Int( Val( lsmo ) ) )
    If Empty( s )
      s := inieditspr( A__POPUPMENU, dir_server + 'str_komp', lstr_crb )
      If Empty( s )
        s := lsmo
      Endif
    Endif
  Elseif lkomu == 1
    s := inieditspr( A__POPUPMENU, dir_server + 'str_komp', lstr_crb )
  Elseif lkomu == 3
    s := inieditspr( A__POPUPMENU, dir_server + 'komitet', lstr_crb )
  Endif

  Return s

// для совместимости со старой версией программы
Function func1_komu( lkomu, lstr_crb )
  Return f4_view_list_schet( lkomu, '', lstr_crb )

//
Function print_schet( oBrow )

  Static si := 1
  Local i, r := Row(), r1, r2, mm_menu := {}

  If schet_->IS_DOPLATA == 1 // является доплатой?;0-нет, 1-да для IFIN=1 или 2
    If schet_->IFIN == 1  // 'ТФОМС'
      print_schet_doplata( 1 )
    Elseif schet_->IFIN == 2 // 'ФФОМС'
      print_schet_doplata( 2 )
    Endif
  Elseif !Empty( Val( schet_->smo ) )
    For i := 1 To 2
      AAdd( mm_menu, 'Печать ' + iif( i == 1, '', 'реестра ' ) + 'счёта на оплату медицинской помощи' )
    Next
    If r <= MaxRow() / 2
      r1 := r + 1
      r2 := r1 + 3
    Else
      r2 := r -1
      r1 := r2 -3
    Endif
    If ( i := popup_prompt( r1, 10, si, mm_menu, , , color5 ) ) > 0
      si := i
      print_schet_s( i )
    Endif
  Else
    print_other_schet( 1 )
  Endif

  Return Nil

// Просмотр и печать выписанных счетов/реестров на доплату
Function print_schet_doplata( reg )

  // reg = 1 - доплата ТФОМС
  // reg = 2 - доплата ФФОМС
  Local arr_title, arr1title, sh, HH := 57, n_file := cur_dir + 'schetd' + stxt, ;
    s, i, j, j1, a_shifr[ 10 ], k1, k2, k3, lshifr, v_doplata, rec, ;
    buf := save_maxrow(), t_arr[ 2 ], llpu, lbank, ssumma := 0, ;
    fl_numeration, is_20_11, sdate := SToD( '20121120' ) // 20.11.2012г.

  If schet_->NREGISTR == 0 // зарегистрированные счета
    is_20_11 := ( date_reg_schet() >= sdate )
  Else
    is_20_11 := ( schet_->DSCHET > SToD( '20121210' ) ) // 10.12.2012г.
  Endif
  s1 := iif( reg == 2, Space( 11 ), 'и сопутст. ' )
  s2 := iif( reg == 2, Space( 11 ), 'диагноза   ' )
  arr_title := { ;
    '────┬───────────────┬────────────┬────────┬──────────┬───────────┬──────────────', ;
    '№   │№ счета по ОМС │№ страхового│Дата    │Код       │Код        │Доплата по    ', ;
    'пози│               │случая в    │счета по│закончен- │основного  │данной услуге ', ;
    'ции │               │счете по ОМС│ОМС     │ного      │диагноза   │из средств    ', ;
    'реес│               │            │        │случая    │' + s1 +     '│бюджета ' + iif( reg == 2, 'ФФОМС ', 'ТФОМС ' ), ;
    'тра │               │            │        │          │' + s2 +     '│(рублей)      ', ;
    '────┼───────────────┼────────────┼────────┼──────────┼───────────┼──────────────', ;
    ' 1  │       2       │      3     │   4    │    5     │     6     │       7      ', ;
    '────┴───────────────┴────────────┴────────┴──────────┴───────────┴──────────────' }
  arr1title := { ;
    '────┬───────────────┬────────────┬────────┬──────────┬───────────┬──────────────', ;
    ' 1  │       2       │      3     │   4    │    5     │     6     │       7      ', ;
    '────┴───────────────┴────────────┴────────┴──────────┴───────────┴──────────────' }
  //
  use_base( 'lusl' )
  use_base( 'lusld' )
  use_base( 'luslf' )
  r_use( dir_server + 'uslugi', , 'USL' )
  r_use( dir_server + 'human_u', dir_server + 'human_u', 'HU' )
  Set Relation To u_kod into USL
  r_use( dir_server + 'human_', , 'HUMAN_' )
  r_use( dir_server + 'human', dir_server + 'humans', 'HUMAN' )
  Set Relation To RecNo() into HUMAN_
  r_use( dir_server + 'organiz', , 'ORG' )
  r_use( dir_server + 'schetd', , 'SD' )
  Index On Str( kod, 6 ) to ( cur_dir + 'tmp_sd' )
  //
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( n_file )
  n_list := 1
  tek_stroke := 0
  add_string( Center( 'Счет № ' + AllTrim( schet_->nschet ) + ' от ' + full_date( schet_->dschet ) + ' г.', sh ) )
  s := 'на оплату медицинской помощи за счет средств бюджета ' + iif( reg == 2, 'Федерального', 'Территориального' ) + ' фонда '
  s += 'обязательного медицинского страхования ' + iif( reg == 2, '', 'Волгоградской области ' ) + 'по Программе модернизации здравоохранения '
  s += 'Волгоградской области на 2011-2012 годы в части реализации мероприятий по '
  s += 'поэтапному внедрению стандартов медицинской помощи'
  For k := 1 To perenos( t_arr, s, sh )
    add_string( Center( AllTrim( t_arr[ k ] ), sh ) )
  Next
  add_string( '' )
  sinn := org->inn
  skpp := ''
  If '/' $ sinn
    skpp := AfterAtNum( '/', sinn )
    sinn := BeforAtNum( '/', sinn )
  Endif
  sname    := org->name
  sbank    := org->bank
  sr_schet := org->r_schet
  sbik     := org->smfo
  If reg == 2
    If !Empty( org->r_schet2 )
      sbank    := org->bank2
      sr_schet := org->r_schet2
      sbik     := org->smfo2
    Endif
    If !Empty( org->name2 )
      sname := org->name2
    Endif
  Endif
  k := perenos( t_arr, sname, sh -11 )
  add_string( 'Поставщик: ' + t_arr[ 1 ] )
  For i := 2 To k
    add_string( Space( 11 ) + t_arr[ 2 ] )
  Next
  add_string( 'ИНН: ' + PadR( sinn, 12 ) + ', КПП: ' + skpp )
  add_string( 'Адрес: ' + RTrim( org->adres ) )
  k := perenos( t_arr, sbank, sh -17 )
  add_string( 'Банк поставщика: ' + t_arr[ 1 ] )
  For i := 2 To k
    add_string( Space( 17 ) + t_arr[ 2 ] )
  Next
  add_string( 'Расчетный счет: ' + AllTrim( sr_schet ) + ', БИК: ' + AllTrim( sbik ) )
  add_string( '' )
  add_string( '' )
  If ( j := AScan( get_rekv_smo(), {| x| x[ 1 ] == schet_->SMO } ) ) == 0
    j := Len( get_rekv_smo() ) // если не нашли - печатаем реквизиты ТФОМС
  Endif
  k := perenos( t_arr, get_rekv_smo()[ j, 2 ], sh -12 )
  add_string( 'Плательщик: ' + t_arr[ 1 ] )
  For i := 2 To k
    add_string( Space( 12 ) + t_arr[ 2 ] )
  Next
  add_string( 'ИНН: ' + get_rekv_smo()[ j, 3 ] + ', КПП: ' + get_rekv_smo()[ j, 4 ] )
  k := perenos( t_arr, get_rekv_smo()[ j, 6 ], sh -7 )
  add_string( 'Адрес: ' + t_arr[ 1 ] )
  For i := 2 To k
    add_string( Space( 7 ) + t_arr[ 2 ] )
  Next
  k := perenos( t_arr, get_rekv_smo()[ j, 7 ], sh -18 )
  add_string( 'Банк плательщика: ' + t_arr[ 1 ] )
  For i := 2 To k
    add_string( Space( 18 ) + t_arr[ 2 ] )
  Next
  add_string( 'Расчетный счет: ' + AllTrim( get_rekv_smo()[ j, 8 ] ) + ', БИК: ' + AllTrim( get_rekv_smo()[ j, 9 ] ) )
  add_string( '' )
  add_string( '' )
  add_string( Center( 'Реестр счета № ' + AllTrim( schet_->nschet ) + ' от ' + full_date( schet_->dschet ) + ' г.', sh ) )
  add_string( '' )
  AEval( arr_title, {| x| add_string( x ) } )
  Select SCHET
  fl_numeration := emptyany( schet_->nyear, schet_->nmonth )
  rec := RecNo()
  Set Index To
  j := 0
  Select SD
  find ( Str( rec, 6 ) )
  Do While sd->kod == rec .and. !Eof()
    schet->( dbGoto( sd->kod2 ) )
    j1 := 0
    Select HUMAN
    find ( Str( sd->kod2, 6 ) )
    Do While human->schet == sd->kod2 .and. !Eof()
      lshifr := ''
      v_doplata := r_doplata := 0
      ret_zak_sl( @lshifr, @v_doplata, @r_doplata, , , iif( is_20_11, sdate, nil ) )
      If iif( reg == 1, !Empty( r_doplata ), .t. )
        a_diag := diag_for_xml(, .t., , , .t. )
        s_diag := a_diag[ 1 ]
        If reg == 1 .and. Len( a_diag ) > 1 .and. !Empty( a_diag[ 2 ] )
          s_diag += ' ' + a_diag[ 2 ]
        Endif
        s := PadR( lstr( ++j ), 5 ) + ;
          PadC( AllTrim( schet_->nschet ), 15 ) + ' ' + ;
          PadR( Str( iif( fl_numeration, ++j1, human_->SCHET_ZAP ), 7 ), 13 ) + ;
          date_8( schet_->dschet ) + ' ' + ;
          PadC( lshifr, 10 ) + ;
          PadC( AllTrim( s_diag ), 13 ) + ;
          Str( iif( reg == 2, v_doplata, r_doplata ), 11, 2 )
        ssumma += iif( reg == 2, v_doplata, r_doplata )
        If verify_ff( HH, .t., sh )
          AEval( arr1title, {| x| add_string( x ) } )
        Endif
        add_string( s )
      Endif
      //
      Select HUMAN
      Skip
    Enddo
    Select SD
    Skip
  Enddo
  If verify_ff( HH -8, .t., sh )
    AEval( arr1title, {| x| add_string( x ) } )
  Endif
  add_string( Replicate( '─', sh ) )
  add_string( PadL( 'Всего: ' + lstr( ssumma, 14, 2 ), sh -3 ) )
  add_string( '' )
  k := perenos( t_arr, 'К оплате: ' + srub_kop( ssumma, .t. ), sh )
  add_string( t_arr[ 1 ] )
  For j := 2 To k
    add_string( PadL( AllTrim( t_arr[ j ] ), sh ) )
  Next
  add_string( '' )
  add_string( '  Главный врач медицинской организации      _____________ / ' + AllTrim( org->ruk ) + ' /' )
  add_string( '  Главный бухгалтер медицинской организации _____________ / ' + AllTrim( org->bux ) + ' /' )
  add_string( '                                        М.П.' )
  FClose( fp )

  rest_box( buf )
  close_use_base( 'lusl' )
  lusld->( dbCloseArea() )
  close_use_base( 'luslf' )
  usl->( dbCloseArea() )
  hu->( dbCloseArea() )
  human_->( dbCloseArea() )
  human->( dbCloseArea() )
  org->( dbCloseArea() )
  sd->( dbCloseArea() )
  If Select( 'USL1' ) > 0
    usl1->( dbCloseArea() )
  Endif
  Select SCHET
  If !( Round( ssumma, 2 ) == Round( schet->summa, 2 ) )
    // если ТФОМС поменял ценник - перезапишем сумму счёта
    Goto ( rec )
    g_rlock( forever )
    schet->summa := schet->summa_ost := ssumma
    Unlock
    Commit
  Endif
  Set Index to ( cur_dir + 'tmp_sch' )
  Goto ( rec )
  viewtext( n_file, , , , .t., , , 2 )

  Return Nil

// 23.04.13 вынуть ЛЮБОЙ реестр из XML-файлов и записать во временные DBF-файлы
Function my_extract_reestr()

  Local cName, full_zip

  full_zip := manager( T_ROW, T_COL + 5, MaxRow() -2, , .t., 1, , , , '*' + szip )
  If !Empty( full_zip )
    cName := name_without_ext( strippath( full_zip ) )
    If Left( cName, 3 ) == 'HRM' // файл реестра
      extract_reestr( 1, cName, , , keeppath( full_zip ) + cslash )
    Else
      func_error( 4, 'Это не файл реестра' )
    Endif
  Endif

  Return Nil

// 15.10.24 зачитать протокол ФЛК во временные файлы
Function protokol_flk_tmpfile( arr_f, aerr )

  Local adbf, ii, j, s, oXmlDoc, oXmlNode, is_err_FLK := .f.

  adbf := { ;
    { 'FNAME',  'C', 27, 0 }, ;
    { 'FNAME1', 'C', 26, 0 }, ;
    { 'FNAME2', 'C', 26, 0 }, ;
    { 'DATE_F', 'D',  8, 0 }, ;
    { 'KOL2',   'N',  6, 0 };   // кол-во ошибок
  }
  dbCreate( cur_dir + 'tmp1file', adbf )
  adbf := { ; // элементы PR
  { 'TIP',        'N',  1, 0 }, ;  // тип(номер) обрабатываемого файла
  { 'OSHIB',      'N',  3, 0 }, ;  // код ошибки T005
  { 'SOSHIB',     'C', 12, 0 }, ;  // код ошибки Q015, Q022
  { 'IM_POL',     'C', 20, 0 }, ;  // имя поля, в котором ошибка
  { 'BAS_EL',     'C', 20, 0 }, ;  // имя базового элемента
  { 'ID_BAS',     'C', 36, 0 }, ;  // GUID базового элемента
  { 'COMMENT',    'C', 250, 0 }, ;  // описание ошибки
  { 'N_ZAP',      'N',  6, 0 }, ;  // поле из первичного реестра
  { 'KOD_HUMAN',  'N',  7, 0 };   // код по БД листов учёта
  }
  dbCreate( cur_dir + 'tmp2file', adbf ) // элементы PR
  dbCreate( cur_dir + 'tmp22fil', adbf ) // доп.файл, если по одному пациенту > 1 листа учёта
  Use ( cur_dir + 'tmp1file' ) New Alias TMP1
  Append Blank
  Use ( cur_dir + 'tmp2file' ) New Alias TMP2
  For ii := 1 To Len( arr_f )
    // т.к. в ZIP'е два XML-файла, второй файл также прочитать
    If Upper( Right( arr_f[ ii ], 4 ) ) == sxml .and. ValType( oXmlDoc := hxmldoc():read( _tmp_dir1() + arr_f[ ii ] ) ) == 'O'
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
        Case 'DATE_F' == oXmlNode:title
          tmp1->DATE_F := xml2date( mo_read_xml_stroke( oXmlNode, 'DATE_F', aerr, .f. ) )
        Case 'PR' == oXmlNode:title
          Select TMP2
          Append Blank
          tmp2->tip := ii
          s := AllTrim( mo_read_xml_stroke( oXmlNode, 'OSHIB', aerr ) )
          If Len( s ) > 3 .or. '.' $ s
            tmp2->SOSHIB := s
          Else
            tmp2->OSHIB := Val( s )
          Endif
          tmp2->IM_POL  := mo_read_xml_stroke( oXmlNode, 'IM_POL', aerr, .f. )
          tmp2->BAS_EL  := mo_read_xml_stroke( oXmlNode, 'BAS_EL', aerr, .f. )
          tmp2->ID_BAS  := mo_read_xml_stroke( oXmlNode, 'ID_BAS', aerr, .f. )
          tmp2->COMMENT := mo_read_xml_stroke( oXmlNode, 'COMMENT', aerr, .f. )
          If !Empty( tmp2->BAS_EL ) .and. !Empty( tmp2->ID_BAS )
            is_err_FLK := .t.
            tmp1->KOL2++
          Endif
        Endcase
      Next j
    Endif
  Next ii
  Commit

  Return is_err_FLK

// 27.04.20 зачитать реестр СП и ТК во временные файлы
Function reestr_sp_tk_tmpfile( oXmlDoc, aerr, mname_xml )

  Local j, j1, _ar, oXmlNode, oNode1, oNode2, buf := save_maxrow()

  Default aerr TO {}, mname_xml To ''
  stat_msg( 'Распаковка/чтение/анализ реестра СП и ТК ' + BeforAtNum( '.', mname_xml ) )
  dbCreate( cur_dir + 'tmp1file', { ;
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
  dbCreate( cur_dir + 'tmp2file', { ;
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
  dbCreate( cur_dir + 'tmp3file', { ;
    { '_N_ZAP',     'N',  8, 0 }, ;
    { '_REFREASON', 'N',  3, 0 }, ;
    { 'SREFREASON', 'C', 12, 0 };
    } )
  Use ( cur_dir + 'tmp1file' ) New Alias TMP1
  Append Blank
  Use ( cur_dir + 'tmp2file' ) New Alias TMP2
  Use ( cur_dir + 'tmp3file' ) New Alias TMP3
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

// 18.04.25 печать счета
Function print_schet_s( reg )

  Local adbf, j, s, ii := 0, fl_numeration := .f., ;
    lshifr1, ldate1, ldate2, hGauge
  local  buf := save_maxrow()

  local fNameSchet

  mywait()
  delfrfiles()
  adbf := { { 'name', 'C', 130, 0 }, ;
    { 'name_schet', 'C', 130, 0 }, ;
    { 'adres', 'C', 110, 0 }, ;
    { 'ogrn', 'C', 15, 0 }, ;
    { 'inn', 'C', 12, 0 }, ;
    { 'kpp', 'C', 9, 0 }, ;
    { 'bank', 'C', 130, 0 }, ;
    { 'r_schet', 'C', 45, 0 }, ;
    { 'bik', 'C', 10, 0 }, ;
    { 'ruk', 'C', 20, 0 }, ;
    { 'bux', 'C', 20, 0 }, ;
    { 'k_schet', 'C', 45, 0 }, ;
    { 'ispolnit', 'C', 20, 0 }, ;
    { 'plat', 'C', 250, 0 }, ;
    { 'nschet', 'C', 20, 0 }, ;
    { 'dschet', 'C', 30, 0 }, ;
    { 'date_begin', 'C', 30, 0 }, ;
    { 'date_end', 'C', 30, 0 }, ;
    { 'date_podp', 'C', 13, 0 }, ;
    { 'susluga', 'C', 250, 0 }, ;
    { 'summa', 'N', 15, 2 } }
  dbCreate( fr_titl, adbf )
  r_use( dir_server + 'organiz', , 'ORG' )
  Use ( fr_titl ) New Alias FRT
  Append Blank
  frt->name := frt->name_schet := org->name
  If !Empty( org->name_schet )
    frt->name_schet := org->name_schet
  Endif
  s := AllTrim( org->adres )
  If !Empty( CharRem( '-', org->telefon ) )
    s += ' тел.' + AllTrim( org->telefon )
  Endif
  frt->adres := s
  frt->ogrn := org->ogrn
  sinn := org->inn
  skpp := ''
  If '/' $ sinn
    skpp := AfterAtNum( '/', sinn )
    sinn := BeforAtNum( '/', sinn )
  Endif
  frt->inn := sinn
  frt->kpp := skpp
  frt->bank := org->bank
  frt->r_schet := org->r_schet
  frt->bik := org->smfo
  frt->ruk := org->ruk
  frt->bux := org->bux
  frt->k_schet := org->k_schet
  frt->ispolnit := org->ispolnit
  frt->date_podp := full_date( sys_date ) + ' г.'
  s := ''
  If ( j := AScan( get_rekv_smo(), {| x| x[ 1 ] == schet_->SMO } ) ) > 0
    s := get_rekv_smo()[ j, 2 ]
    If reg == 2 .and. Int( Val( schet_->SMO ) ) == 34 // иногородние !
      reg := 3
    Endif
  Elseif schet->str_crb > 0
    If schet->komu == 3
      s := inieditspr( A__POPUPMENU, dir_server + 'komitet', schet->str_crb )
    Else
      s := inieditspr( A__POPUPMENU, dir_server + 'str_komp', schet->str_crb )
    Endif
  Endif
  frt->plat := s
  frt->nschet := schet_->nschet
  frt->dschet := date_month( schet_->dschet )

  fNameSchet := iif( reg == 1, 'SCM', 'SRM' ) + AllTrim( glob_mo[ _MO_KOD_TFOMS ] ) ;
    + iif( AllTrim( schet_->SMO ) == '34', 'T34', 'S' + AllTrim( schet_->SMO ) ) ;
    + '_' + AllTrim( schet_->nschet ) + '_' ;
    + str( Year( schet_->DSCHET ), 4 ) + StrZero( Month( schet_->DSCHET ), 2 ) + StrZero( Day( schet_->DSCHET ), 2 )

  s := 'За медицинскую помощь, оказанную '
  If !Empty( schet_->SMO )
    s += 'застрахованным лицам '
  Endif
  If !emptyany( schet_->nyear, schet_->nmonth )
    s += 'за ' + mm_month[ schet_->nmonth ] + Str( schet_->nyear, 5 ) + ' года'
    ldate := SToD( StrZero( schet_->nyear, 4 ) + StrZero( schet_->nmonth, 2 ) + '01' )
    frt->date_begin := date_month( ldate )
    frt->date_end   := date_month( EoM( ldate ) )
  Else
    s := 'За оказанную медицинскую помощь'
    fl_numeration := .t.
  Endif
  frt->susluga := s
  frt->summa := schet->summa
  org->( dbCloseArea() )
  rest_box( buf )
  //
  If reg > 1
    hGauge := gaugenew( , , { 'GR+/RB', 'BG+/RB', 'G+/RB' }, 'Составление счёта', .t. )
    gaugedisplay( hGauge )
    adbf := { { 'nomer', 'N', 4, 0 }, ;
      { 'fio', 'C', 50, 0 }, ;
      { 'pol', 'C', 10, 0 }, ;
      { 'date_r', 'C', 10, 0 }, ;
      { 'mesto_r', 'C', 100, 0 }, ;
      { 'pasport', 'C', 50, 0 }, ;
      { 'adresp', 'C', 250, 0 }, ;
      { 'adresg', 'C', 250, 0 }, ;
      { 'snils', 'C', 50, 0 }, ;
      { 'polis', 'C', 50, 0 }, ;
      { 'vid_pom', 'C', 10, 0 }, ;
      { 'diagnoz', 'C', 10, 0 }, ;
      { 'n_data', 'C', 10, 0 }, ;
      { 'k_data', 'C', 10, 0 }, ;
      { 'ob_em', 'N', 5, 0 }, ;
      { 'profil', 'C', 10, 0 }, ;
      { 'vrach', 'C', 10, 0 }, ;
      { 'cena', 'N', 12, 2 }, ;
      { 'stoim', 'N', 12, 2 }, ;
      { 'rezultat', 'C', 10, 0 } }
    dbCreate( fr_data, adbf )
    Use ( fr_data ) New Alias FRD
    Index On Str( nomer, 4 ) to ( fr_data )
    use_base( 'lusl' )
    r_use( dir_server + 'uslugi1', { dir_server + 'uslugi1', ;
      dir_server + 'uslugi1s' }, 'USL1' )
    r_use( dir_server + 'uslugi', , 'USL' )
    r_use( dir_server + 'human_u', dir_server + 'human_u', 'HU' )
    Set Relation To u_kod into USL
    r_use( dir_server + 'kartote_', , 'KART_' )
    r_use( dir_server + 'kartotek', , 'KART' )
    Set Relation To RecNo() into KART_
    g_use( dir_server + 'human_3', { dir_server + 'human_3', dir_server + 'human_32' }, 'HUMAN_3' )
    r_use( dir_server + 'human_', , 'HUMAN_' )
    r_use( dir_server + 'human', dir_server + 'humans', 'HUMAN' )
    Set Relation To RecNo() into HUMAN_, To kod_k into KART
    Select HUMAN
    find ( Str( schet->kod, 6 ) )
    Do While human->schet == schet->kod .and. !Eof()
      fl := .t.
      fl_2 := .f.
      lal := 'human'
      If human->ishod == 88
        fl_2 := .t.
        lal += '_3'
        Select HUMAN_3
        find ( Str( human->kod, 7 ) )
      Elseif human->ishod == 89
        fl := .f. // второй случай в двойном пропускаем
      Endif
      If fl
        gaugeupdate( hGauge, ++ii / schet->kol )
        ldate1 := iif( ldate1 == nil, &lal.->k_data, Min( ldate1, &lal.->k_data ) )
        ldate2 := iif( ldate2 == nil, &lal.->k_data, Max( ldate2, &lal.->k_data ) )
        a_diag := diag_for_xml( , .t., , , .t. )
        is_zak_sl := is_zak_sl_d := is_zak_sl_v := .f.
        lst := kol_dn := mcena := 0
        lvidpom := 1
        au := {}
        Select HU
        find ( Str( human->kod, 7 ) )
        Do While hu->kod == human->kod .and. !Eof()
          lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
          If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data, , , @lst )
            lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
            If ( i := ret_vid_pom( 1, lshifr, human->k_data ) ) > 0
              lvidpom := i
            Endif
            If Left( lshifr, 5 ) == '55.1.' // дневной стационар с 1 апреля 2013 года
              kol_dn += hu->KOL_1
            Elseif eq_any( Left( lshifr, 4 ), '55.2', '55.3', '55.4' ) // старый дневной стационар
              kol_dn += hu->KOL_1
              mcena := hu->u_cena
            Elseif Left( lshifr, 2 ) == '1.'
              kol_dn += hu->KOL_1
              mcena := hu->u_cena
            Endif
            If lst == 1
              If Left( lshifr, 2 ) == '1.'
                is_zak_sl := .t.
                mcena := hu->u_cena
              Elseif Left( lshifr, 3 ) == '55.'
                If human->k_data < 0d20130401 // дневной стационар до 1 апреля 2013
                  is_zak_sl_d := .t.
                Endif
                mcena := hu->u_cena
              Elseif f_is_zak_sl_vr( lshifr ) // зак.случай в п-ке
                is_zak_sl_v := .t.
                mcena := hu->u_cena
              Endif
            Else
              j := AScan( au, {| x| x[ 1 ] == lshifr .and. x[ 2 ] == hu->date_u } )
              If j == 0
                AAdd( au, { lshifr, hu->date_u, 0, hu->u_cena } )
                j := Len( au )
              Endif
              au[ j, 3 ] += hu->kol_1
            Endif
          Endif
          Select HU
          Skip
        Enddo
        If fl_2
          kol_dn := human_3->k_data - human_3->n_data
        Elseif is_zak_sl
          kol_dn := human->k_data - human->n_data
        Elseif is_zak_sl_d
          kol_dn := human->k_data - human->n_data + 1
        Elseif is_zak_sl_v
          For j := 1 To Len( au )
            If Left( au[ j, 1 ], 2 ) == '2.'
              kol_dn += au[ j, 3 ]
            Endif
          Next
        Elseif Empty( kol_dn )
          For j := 1 To Len( au )
            kol_dn += au[ j, 3 ]
          Next
          If kol_dn > 0
            mcena := round_5( human->cena_1 / kol_dn, 2 )
            If !( Round( mcena, 2 ) == Round( au[ 1, 4 ], 2 ) )
              kol_dn := mcena := 0
            Endif
          Endif
        Endif
        Select FRD
        Append Blank
        frd->nomer := iif( fl_numeration, ii, human_->SCHET_ZAP )
        frd->fio := human->fio
        frd->pol := iif( human->pol == 'М', 'муж', 'жен' )
        frd->date_r := full_date( human->date_r )
        frd->mesto_r := kart_->mesto_r
        s :=  get_name_vid_ud( kart_->vid_ud, , ' ' )
        If !Empty( kart_->ser_ud )
          s += AllTrim( kart_->ser_ud ) + ' '
        Endif
        If !Empty( kart_->nom_ud )
          s += AllTrim( kart_->nom_ud )
        Endif
        frd->pasport := s
        frd->adresg := ret_okato_ulica( kart->adres, kart_->okatog, 0, 2 )
        If Empty( kart_->okatop )
          frd->adresp := frd->adresg
        Else
          frd->adresp := ret_okato_ulica( kart_->adresp, kart_->okatop, 0, 2 )
        Endif
        If !Empty( kart->snils )
          frd->snils := Transform( kart->SNILS, picture_pf )
        Endif
        frd->polis := AllTrim( AllTrim( human_->SPOLIS ) + ' ' + human_->NPOLIS )
        frd->vid_pom := lstr( lvidpom )
        If diagnosis_for_replacement( a_diag[ 1 ], human_->USL_OK )
          frd->diagnoz := a_diag[ 2 ]
        Else
          frd->diagnoz := a_diag[ 1 ]
        Endif
        frd->n_data := full_date( &lal.->n_data )
        frd->k_data := full_date( &lal.->k_data )
        frd->ob_em := kol_dn
        If human_->PROFIL > 0
          frd->profil := lstr( human_->PROFIL )
        Endif
        If !Empty( human_->PRVS )
          frd->vrach := put_prvs_to_reestr( human_->PRVS, schet_->nyear )
          lstr( Abs( human_->PRVS ) )
        Endif
        If fl_2
          frd->cena := frd->stoim := human_3->cena_1
          frd->rezultat := lstr( human_3->RSLT_NEW )
        Else
          frd->cena := mcena
          frd->stoim := human->cena_1
          frd->rezultat := lstr( human_->RSLT_NEW )
        Endif
      Endif
      Select HUMAN
      Skip
    Enddo
    close_use_base( 'lusl' )
    usl1->( dbCloseArea() )
    usl->( dbCloseArea() )
    hu->( dbCloseArea() )
    kart_->( dbCloseArea() )
    kart->( dbCloseArea() )
    human_3->( dbCloseArea() )
    human_->( dbCloseArea() )
    human->( dbCloseArea() )
    frd->( dbCloseArea() )
    If fl_numeration .and. !emptyany( ldate1, ldate2 )
      frt->date_begin := date_month( ldate1 )
      frt->date_end   := date_month( ldate2 )
    Endif
    closegauge( hGauge )
  Endif
  frt->( dbCloseArea() )

  fNameSchet := cur_dir() + fNameSchet + '.pdf'
  Do Case
  Case reg == 1
    call_fr( 'mo_schet' )
//    print_pdf_order( fNameSchet )
  Case reg == 2
    call_fr( 'mo_reesv' )
//    print_pdf_reestr( fNameSchet )
  Case reg == 3
    call_fr( 'mo_reesi' )
  Endcase
  Select SCHET

  Return Nil
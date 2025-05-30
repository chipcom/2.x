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
      viewtext( devide_into_pages( dir_server + dir_XML_TF() + hb_ps() + cName + stxt, 60, 80 ), , , , .t., , , 2 )
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
    If !myfiledeleted( cur_dir() + 'tmp' + lstr( j ) + 'file' + sdbf() )
      Return Nil
    Endif
  Next
  For j := 1 To 8
    If !myfiledeleted( cur_dir() + 'tmp_r_t' + lstr( j ) + sdbf() )
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
        // chip_copy_zipXML(hb_OemToAnsi(full_zip),dir_server+dir_XML_TF())
        chip_copy_zipxml( full_zip, dir_server + dir_XML_TF() )
        Use ( cur_dir() + 'tmp1file' ) New Alias TMP1
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
    chip_copy_zipxml( cFileProtokol, dir_server + dir_XML_TF() )
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
  Use ( cur_dir() + 'tmp1file' ) New Alias TMP1
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
  Use ( cur_dir() + 'tmp2file' ) New Alias TMP2
  Index On Str( tip, 1 ) + Str( oshib, 3 ) + soshib to ( cur_dir() + 'tmp2' )
  If is_err_FLK
    If !extract_reestr( rees->( RecNo() ), rees->name_xml )
      AAdd( aerr, Center( 'Не найден ZIP-архив с РЕЕСТРом № ' + lstr( rees->nschet ) + ' от ' + date_8( rees->DSCHET ), 80 ) )
      AAdd( aerr, '' )
      AAdd( aerr, Center( dir_server + dir_XML_MO() + hb_ps() + AllTrim( rees->name_xml ) + szip, 80 ) )
      AAdd( aerr, '' )
      AAdd( aerr, Center( 'Без данного архива дальнейшая работа НЕВОЗМОЖНА!', 80 ) )
      Close databases
      Return .f.
    Endif
    Use ( cur_dir() + 'tmp_r_t1' ) New Alias T1
    Index On Upper( ID_PAC ) to ( cur_dir() + 'tmp_r_t1' )
    Use ( cur_dir() + 'tmp_r_t2' ) New Alias T2
    Use ( cur_dir() + 'tmp_r_t3' ) New Alias T3
    Use ( cur_dir() + 'tmp_r_t4' ) New Alias T4
    Use ( cur_dir() + 'tmp_r_t5' ) New Alias T5
    Use ( cur_dir() + 'tmp_r_t6' ) New Alias T6
    Use ( cur_dir() + 'tmp_r_t7' ) New Alias T7
    Use ( cur_dir() + 'tmp_r_t8' ) New Alias T8
    // заполнить поле 'N_ZAP' в файле 'tmp2'
    fill_tmp2_file_flk()
    r_use( dir_server + 'mo_otd', , 'OTD' )
    g_use( dir_server + 'human_', , 'HUMAN_' )
    g_use( dir_server + 'human', , 'HUMAN' )
    Set Relation To RecNo() into HUMAN_, To otd into OTD
    g_use( dir_server + 'mo_rhum', , 'RHUM' )
    Index On Str( REES_ZAP, 6 ) to ( cur_dir() + 'tmp_rhum' ) For reestr == mkod_reestr
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

  Use ( cur_dir() + 'tmp22fil' ) New Alias TMP22
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
    Index On Str( tip, 1 ) + Str( oshib, 3 ) to ( cur_dir() + 'tmp2' )
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
  Use ( cur_dir() + 'tmp1file' ) New Alias TMP1
  ldate_sptk := tmp1->_DATA
  mnschet := Int( Val( tmp1->_NSCHET ) )  // в число (отрезать всё, что после '-')
  mANSREESTR := AfterAtNum( '-', tmp1->_NSCHET )
  r_use( dir_server + 'mo_rees', , 'REES' )
  Index On Str( NSCHET, 6 ) to ( cur_dir() + 'tmp_rees' ) For NYEAR == tmp1->_YEAR
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
    Index On ANSREESTR to ( cur_dir() + 'tmp_xml' ) For reestr == mkod_reestr
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
    AAdd( aerr, Center( dir_server + dir_XML_MO() + hb_ps() + AllTrim( rees->name_xml ) + szip, 80 ) )
    AAdd( aerr, '' )
    AAdd( aerr, Center( 'Без данного архива дальнейшая работа НЕВОЗМОЖНА!', 80 ) )
  Endif
  If Empty( aerr )
    r_use( dir_server + 'human_3', { dir_server + 'human_3', dir_server + 'human_32' }, 'HUMAN_3' )
    r_use( dir_server + 'human', , 'HUMAN' )
    r_use( dir_server + 'human_', , 'HUMAN_' )
    r_use( dir_server + 'mo_rhum', , 'RHUM' )
    Index On Str( REES_ZAP, 6 ) to ( cur_dir() + 'tmp_rhum' ) For reestr == mkod_reestr
    Use ( cur_dir() + 'tmp2file' ) New Alias TMP2
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
      // chip_copy_zipXML(hb_OemToAnsi(full_zip),dir_server+dir_XML_TF())
      chip_copy_zipxml( full_zip, dir_server + dir_XML_TF() )
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
        // index on str(kod, 7) to (cur_dir() + 'tmp_kfio')
      Endif
      // открыть распакованный реестр
      Use ( cur_dir() + 'tmp_r_t1' ) New Alias T1
      Index On Str( Val( n_zap ), 6 ) to ( cur_dir() + 'tmpt1' )
      Use ( cur_dir() + 'tmp_r_t2' ) New Alias T2
      Index On IDCASE + Str( sluch, 6 ) to ( cur_dir() + 'tmpt2' )
      Use ( cur_dir() + 'tmp_r_t3' ) New Alias T3
      Index On Upper( ID_PAC ) to ( cur_dir() + 'tmpt3' )
      Use ( cur_dir() + 'tmp_r_t4' ) New Alias T4
      Index On IDCASE + Str( sluch, 6 ) to ( cur_dir() + 'tmpt4' )
      Use ( cur_dir() + 'tmp_r_t5' ) New Alias T5
      Index On IDCASE + Str( sluch, 6 ) to ( cur_dir() + 'tmpt5' )
      Use ( cur_dir() + 'tmp_r_t6' ) New Alias T6
      Index On IDCASE + Str( sluch, 6 ) to ( cur_dir() + 'tmpt6' )
      Use ( cur_dir() + 'tmp_r_t7' ) New Alias T7
      Index On IDCASE + Str( sluch, 6 ) to ( cur_dir() + 'tmpt7' )
      Use ( cur_dir() + 'tmp_r_t8' ) New Alias T8
      Index On IDCASE + Str( sluch, 6 ) to ( cur_dir() + 'tmpt8' )
      Use ( cur_dir() + 'tmp_r_t9' ) New Alias T9
      Index On IDCASE + Str( sluch, 6 ) to ( cur_dir() + 'tmpt9' )
      Use ( cur_dir() + 'tmp_r_t10' ) New Alias T10
      Index On IDCASE + Str( sluch, 6 ) + regnum + code_sh + date_inj to ( cur_dir() + 'tmpt10' )
      Use ( cur_dir() + 'tmp_r_t11' ) New Alias T11
      Index On IDCASE + Str( sluch, 6 ) to ( cur_dir() + 'tmpt11' )
      Use ( cur_dir() + 'tmp_r_t12' ) New Alias T12
      Index On IDCASE + Str( sluch, 6 ) to ( cur_dir() + 'tmpt12' )
      Use ( cur_dir() + 'tmp_r_t1_1' ) New Alias T1_1
      Index On IDCASE to ( cur_dir() + 'tmpt1_1' )
      //
      g_use( dir_server + 'mo_kfio', , 'KFIO' )
      Index On Str( kod, 7 ) to ( cur_dir() + 'tmp_kfio' )
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
      Index On Str( REES_ZAP, 6 ) to ( cur_dir() + 'tmp_rhum' ) For reestr == mkod_reestr
      Use ( cur_dir() + 'tmp3file' ) New Alias TMP3
      Index On Str( _n_zap, 8 ) to ( cur_dir() + 'tmp3' )
      Use ( cur_dir() + 'tmp2file' ) New Alias TMP2
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
  Use ( cur_dir() + 'tmp1file' ) New Alias TMP1
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

// 23.04.13 вынуть ЛЮБОЙ реестр из XML-файлов и записать во временные DBF-файлы
Function my_extract_reestr()

  Local cName, full_zip

  full_zip := manager( T_ROW, T_COL + 5, MaxRow() -2, , .t., 1, , , , '*' + szip )
  If !Empty( full_zip )
    cName := name_without_ext( strippath( full_zip ) )
    If Left( cName, 3 ) == 'HRM' // файл реестра
      extract_reestr( 1, cName, , , keeppath( full_zip ) + hb_ps() )
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
  dbCreate( cur_dir() + 'tmp1file', adbf )
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
  dbCreate( cur_dir() + 'tmp2file', adbf ) // элементы PR
  dbCreate( cur_dir() + 'tmp22fil', adbf ) // доп.файл, если по одному пациенту > 1 листа учёта
  Use ( cur_dir() + 'tmp1file' ) New Alias TMP1
  Append Blank
  Use ( cur_dir() + 'tmp2file' ) New Alias TMP2
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

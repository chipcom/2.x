#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 21.08.25 читать файлы из ТФОМС (или СМО)
Function read_from_tf_2025()

  Local name_zip, cName
  local _date, _time, s, arr_f := {}, buf, blk_sp_tk, fl := .f., n, ;
    arr_XML_info[ 7 ], tip_csv_file := 0, kod_csv_reestr := 0

  private full_zip  // используется в is_our_zip()
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
    If ! is_our_zip( cName, @tip_csv_file, @kod_csv_reestr )
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
        s += 'протокола ФЛК для нового обмена'
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
        fl := read_xml_from_tf_2025( arr_f[ n ], arr_XML_info, arr_f )
      Else
        fl := func_error( 4, 'В архиве ' + name_zip + ' нет файла ' + cName + sxml() )
      Endif
    Endif
  Endif
  Return fl

// 22.08.25 чтение в память и анализ XML-файла
Function read_xml_from_tf_2025( cFile, arr_XML_info, arr_f )

  Local nTypeFile := 0, aerr := {}, j, oXmlDoc, ;
    nCountWithErr := 0, go_to_schet := .f., go_to_akt := .f., go_to_rpd := .f., ;
    nerror, buf := save_maxrow()

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
  Private cReadFile := name_without_ext( cFile ), ;
    cTimeBegin := hour_min( Seconds() ), ;
    mkod_reestr := 0, mXML_REESTR := 0, mdate_schet, is_err_FLK := .f.
  Private cFileProtokol := cReadFile + stxt()
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
    altd()
    is_err_FLK := protokol_flk_tmpfile_2025( arr_f, aerr )

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
  Close databases
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
  Delete File ( cFileProtokol )
  If go_to_schet // если выписаны счета
    Keyboard Chr( K_TAB ) + Chr( K_ENTER )
  Elseif go_to_akt // если приняты акты
    Keyboard Replicate( Chr( K_TAB ), 3 ) + Replicate( Chr( K_ENTER ), 2 )
  Elseif go_to_rpd // если приняты платёжки
    Keyboard Replicate( Chr( K_TAB ), 4 ) + Chr( K_ENTER )
  Endif
  Return Nil

// 21.08.25 зачитать новый Протокол ФЛК.
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
//      Select TMP2
//      Append Blank
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
//            Select TMP3
//            Append Blank
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
//  Commit
  dbCommitAll()
  rest_box( buf )
  Return Nil

// 21.08.25 зачитать протокол ФЛК во временные файлы новая версия
Function protokol_flk_tmpfile_2025( arr_f, aerr )

  Local adbf, ii, j, s, oXmlDoc, oXmlNode, is_err_FLK := .f.

  adbf := { ;
    { 'FNAME',  'C', 27, 0 }, ;
    { 'FNAME1', 'C', 26, 0 }, ;
    { 'FNAME2', 'C', 26, 0 }, ;
    { 'KOL2',   'N',  6, 0 };   // кол-во ошибок
  }
//  { 'DATE_F', 'D',  8, 0 }, ;
  dbCreate( cur_dir() + 'tmp1file', adbf, , .t., 'TMP1' )
//  Use ( cur_dir() + 'tmp1file' ) New Alias TMP1
//  Append Blank
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
//  Use ( cur_dir() + 'tmp2file' ) New Alias TMP2

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
            tmp2->SOSHIB := s
          Else
            tmp2->OSHIB := Val( s )
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
//  Commit
  dbCommitAll()
  Return is_err_FLK
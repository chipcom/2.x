#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 15.10.24 создание первичной БД из реестров
Function create_main_base_from_reestrs()

  Local full_zip, name_zip, i, k, n, fl := .t., buf := save_maxrow(), ;
    arr_r := {}, arr_rsptk := {}, arr_s := {}, a_reestr := {}, ;
    oXmlDoc, cFile, cbukva

  r_use( dir_server() + "human" )
  k := LastRec()
  Use
  Private p_lpu := 1, p_otd := 1 // для КДГБ
  Private flag_is_lu := .t. // для пустой БД поставить .f.
  If flag_is_lu
    // уже есть (какие-то) листы учёта
  Elseif k > 0 // иначе работаем только с пустой БД листов учёта
    Return Nil
  Endif
  Private cImportProtokol := "protokol.txt", pr_array_schet := {}
  Private p_var_manager := "Read_reestrs"
  full_zip := manager( T_ROW, T_COL + 5, MaxRow() -2,, .t., 1,,,, "*" + szip() )
  If !Empty( full_zip )
    mywait()
    StrFile( Space( 10 ) + "Протокол создания БД из реестров ТФОМС " + ;
      date_8( sys_date ) + " " + hour_min( Seconds() ) + ;
      hb_eol() + hb_eol(), cImportProtokol )
    name_zip := strippath( full_zip )
    Private name_path := keeppath( full_zip ) + hb_ps()
    scandirfiles( name_path, "HRM*" + szip(), {| x| AAdd( arr_r, x )     } )
    scandirfiles( name_path, "FRM*" + szip(), {| x| AAdd( arr_r, x )     } )
    scandirfiles( name_path, "HRT*" + szip(), {| x| AAdd( arr_rsptk, x ) } )
    scandirfiles( name_path, "FRT*" + szip(), {| x| AAdd( arr_rsptk, x ) } )
    scandirfiles( name_path, "HM*" + szip(), {| x| AAdd( arr_s, x )     } )
    scandirfiles( name_path, "FM*" + szip(), {| x| AAdd( arr_s, x )     } )
    If Empty( arr_r )
      fl := .f.
      StrFile( "Не обнаружено реестров для импорта" + hb_eol(), cImportProtokol, .t. )
    Else
      ASort( arr_r )
      ASort( arr_rsptk )
    Endif
    // реестры
    For i := 1 To Len( arr_r )
      s := SubStr( strippath( arr_r[ i ] ), 4, 6 )
      If s == glob_MO[ _MO_KOD_TFOMS ]
        s := name_without_ext( arr_r[ i ] )
        If chip_copy_zipxml( arr_r[ i ], dir_server() + dir_XML_MO() )
          If extract_reestr( 1, s, .t., .f. )
            Use ( cur_dir() + "tmp1file" ) New Alias TMP1
            s1 := SubStr( AfterAtNum( "_", name_without_ext( strippath( arr_r[ i ] ) ) ), 5 )
            n := Int( Val( s1 ) )
            AAdd( a_reestr, { arr_r[ i ], ;       // 1
            tmp1->_CODE, ;    // 2
            Int( Val( tmp1->_NSCHET ) ), ;  // 3
            tmp1->_DSCHET, ;  // 4
            tmp1->_YEAR, ;    // 5
            tmp1->_MONTH, ;   // 6
            {}, ;             // 7
              0, ;              // 8
            n } )              // 9 длина номера пакета = 5
            Use
          Else
            StrFile( arr_r[ i ] + ": не удалось открыть реестр" + hb_eol(), cImportProtokol, .t. )
            fl := .f. ; Exit
          Endif
        Else
          StrFile( arr_r[ i ] + ": ошибка записи реестра в XML_MO" + hb_eol(), cImportProtokol, .t. )
          fl := .f. ; Exit
        Endif
      Else
        StrFile( arr_r[ i ] + ": несоответствие кода МО " + s + hb_eol(), cImportProtokol, .t. )
        fl := .f. ; Exit
      Endif
    Next
    // счета
    dbCreate( cur_dir() + "tmp_s_id", { { "KOD",    "N", 6, 0 }, ;
      { "NIDCASE", "N", 12, 0 }, ;
      { "IDCASE", "C", 12, 0 }, ;
      { "ID_C",   "C", 36, 0 } } )
    For i := 1 To Len( arr_s )
      s := SubStr( strippath( arr_s[ i ] ), 3, 6 )
      If s == glob_MO[ _MO_KOD_TFOMS ]
        s := name_without_ext( arr_s[ i ] )
        If chip_copy_zipxml( arr_s[ i ], dir_server() + dir_XML_MO() )
          k := Len( pr_array_schet ) + 1
          If extract_reestr( k, s, .t., .t. )
            Use ( cur_dir() + "tmp1file" ) New Alias TMP1
            s1 := SubStr( AfterAtNum( "_", name_without_ext( strippath( arr_s[ i ] ) ) ), 5 )
            n := Int( Val( s1 ) )
            cbukva := " "
            If Asc( Right( AllTrim( tmp1->_NSCHET ), 1 ) ) >= 65 // т.е. "A" и т.д.
              cbukva := Right( AllTrim( tmp1->_NSCHET ), 1 )
            Endif
            AAdd( pr_array_schet, { s, ;              // 1 имя файла
            n, ;              // 2 номер пакета
              tmp1->_NSCHET, ;  // 3 номер счёта
            tmp1->_DSCHET, ;  // 4 дата счёта
            tmp1->_SUMMAV, ;  // 5 сумма счёта
            tmp1->_YEAR, ;    // 6 год отчётного периода
            tmp1->_KOL, ;     // 7 кол-во пациентов
            tmp1->_MAX, ;     // 8 максимальный N_ZAP
            Len( s1 ), ;        // 9 длина номера пакета = 5
            cbukva, ;         // 10 буква счёта
            k } )              // 11 код счёта в массиве
            Use
            Use ( cur_dir() + "tmp_s_id" ) new
            Append From tmp_r_t1
            Use
          Else
            StrFile( arr_s[ i ] + ": не удалось открыть архив счетов" + hb_eol(), cImportProtokol, .t. )
            fl := .f. ; Exit
          Endif
          Delete File ( dir_server() + dir_XML_MO() + hb_ps() + s + szip() )
        Else
          StrFile( arr_s[ i ] + ": ошибка записи счёта в XML_MO" + hb_eol(), cImportProtokol, .t. )
          fl := .f. ; Exit
        Endif
      Else
        StrFile( arr_s[ i ] + ": несоответствие кода МО " + s + hb_eol(), cImportProtokol, .t. )
        fl := .f. ; Exit
      Endif
    Next
    ASort( pr_array_schet,,, {| x, y| iif( x[ 4 ] == y[ 4 ], ;
      Val( x[ 3 ] ) < Val( y[ 3 ] ), ;
      x[ 4 ] < y[ 4 ] ) } )
    For i := 1 To Len( pr_array_schet )
      my_debug(, print_array( pr_array_schet[ i ] ) )
    Next
    // реестры СП и ТК
    For i := 1 To Len( arr_rsptk )
      s := AfterAtNum( "_", strippath( arr_rsptk[ i ] ) )
      If Left( s, 1 ) == "M"
        s := SubStr( s, 2 )
      Else
        StrFile( arr_rsptk[ i ] + ": неверная буква в обозначении получателя" + hb_eol(), cImportProtokol, .t. )
        fl := .f. ; Exit
      Endif
      If fl
        s := Left( s, 6 )
        If s == glob_MO[ _MO_KOD_TFOMS ]
          If extract_zip_xml( keeppath( arr_rsptk[ i ] ), strippath( arr_rsptk[ i ] ) ) != NIL
            s := name_without_ext( arr_rsptk[ i ] )
            cFile := s + sxml()
            // читаем XML-файл в память
            oXmlDoc := hxmldoc():read( _tmp_dir1() + cFile )
            reestr_sp_tk_tmpfile( oXmlDoc,, cFile )
            n := Int( Val( tmp1->_NSCHET ) )  // в число (отрезать всё, что после "-")
            If ( k := AScan( a_reestr, {| x| x[ 3 ] == n .and. x[ 5 ] == tmp1->_YEAR } ) ) > 0
              n := Int( Val( SubStr( AfterAtNum( "_", name_without_ext( strippath( arr_rsptk[ i ] ) ) ), 12 ) ) ) // номер пакета
              If Empty( a_reestr[ k, 8 ] )
                a_reestr[ k, 8 ] := n
              Endif
              a_reestr[ k, 8 ] := Min( a_reestr[ k, 8 ], n )
              AAdd( a_reestr[ k, 7 ], { arr_rsptk[ i ], tmp1->_NSCHET, tmp1->_DSCHET, n } )
            Endif
            Close databases
          Endif
        Else
          StrFile( arr_rsptk[ i ] + ": несоответствие кода МО" + hb_eol(), cImportProtokol, .t. )
          fl := .f. ; Exit
        Endif
      Endif
    Next
    If fl
      For i := 1 To Len( a_reestr )
        If Empty( a_reestr[ i, 8 ] )  // если ещё не было реестров СП и ТК,
          a_reestr[ i, 8 ] := 1000  // то данный реестр обрабатывается последним
        Endif
      Next
      // реестры сортируем: отчётный период + min номер пакета реестров СП и ТК
      ASort( a_reestr,,, {| x, y| iif( x[ 5 ] == y[ 5 ], ;
        iif( x[ 6 ] == y[ 6 ], ;
        iif( x[ 3 ] == y[ 3 ], x[ 8 ] < y[ 8 ], x[ 3 ] < y[ 3 ] ), ;
        x[ 6 ] < y[ 6 ] ), ;
        x[ 5 ] < y[ 5 ] ) } )
      For i := 1 To Len( a_reestr )
        StrFile( a_reestr[ i, 1 ] + ", " + lstr( a_reestr[ i, 3 ] ) + ", " + ;
          DToC( a_reestr[ i, 4 ] ) + ", " + lstr( a_reestr[ i, 8 ] ) + hb_eol(), cImportProtokol, .t. )
        // реестры СП и ТК сортируем по номеру пакета СП и ТК
        ASort( a_reestr[ i, 7 ],,, {| x, y| x[ 4 ] < y[ 4 ] } )
        For k := 1 To Len( a_reestr[ i, 7 ] )
          StrFile( " " + print_array( a_reestr[ i, 7, k ] ) + hb_eol(), cImportProtokol, .t. )
        Next
      Next
      Use ( cur_dir() + "tmp_s_id" ) New Alias TS
      dbEval( {|| ts->NIDCASE := Int( Val( ts->IDCASE ) ) } )
      Use
      fl := f1_create_main_base_from_reestrs( a_reestr )
    Endif
    viewtext( devide_into_pages( cImportProtokol, 60, 80 ),,,, .t.,,, 2 )
    rest_box( buf )
  Endif

  Return Nil


// 22.11.19
Function f1_create_main_base_from_reestrs( a_reestr )

  Local aerr, oXmlDoc, oXmlNode, oNode1, oNode2, cFile, old_sys_date, ;
    i, j, n, s, arr_XML_info[ 7 ], fl := .t., arr_f, nCountWithErr

  arr_XML_info[ 1 ] := _XML_FILE_SP
  arr_XML_info[ 2 ] := '34'
  arr_XML_info[ 3 ] := glob_MO[ _MO_KOD_TFOMS ]
  Private cReadFile, cTimeBegin, mkod_reestr, mdate_schet, is_err_FLK, cFileProtokol, full_zip, mXML_REESTR
  glob_podr := "" ; glob_otd_dep := 0 // пока без кода подразделения
  For i := 1 To Len( a_reestr )
    If chip_copy_zipxml( a_reestr[ i, 1 ], dir_server() + dir_XML_MO() )
      StrFile( strippath( a_reestr[ i, 1 ] ) + ": обработка реестра № " + lstr( a_reestr[ i, 3 ] ) + hb_eol(), cImportProtokol, .t. )
      s := name_without_ext( a_reestr[ i, 1 ] )
      If extract_reestr( 1, s, .t. )
        If ( fl := f2_create_main_base_from_reestrs( s ) )
          // s := "P"+s // до 1 ноября
          s := "V" + s // после 1 ноября
          full_zip := name_path + s + szip()
          If hb_FileExists( full_zip ) // читать протокол ФЛК
            StrFile( " " + strippath( full_zip ) + ": обработка протокола ФЛК" + hb_eol(), cImportProtokol, .t. )
            If ( arr_f := extract_zip_xml( keeppath( full_zip ), s + szip() ) ) != NIL
              If ( n := AScan( arr_f, {| x| Upper( name_without_ext( x ) ) == Upper( s ) } ) ) > 0
                arr_XML_info[ 4 ] := a_reestr[ i, 5 ]
                arr_XML_info[ 5 ] := a_reestr[ i, 6 ]
                arr_XML_info[ 6 ] := a_reestr[ i, 9 ]
                arr_XML_info[ 7 ] := mkod_reestr
                // читаем файл в память
                cFile := arr_f[ n ]
                // читаем XML-файл в память
                oXmlDoc := hxmldoc():read( _tmp_dir1() + cFile )
                If oXmlDoc == Nil .or. Empty( oXmlDoc:aItems )
                  StrFile( full_zip + ": ошибка в чтении файла" + hb_eol(), cImportProtokol, .t. )
                  fl := .f. ; Exit
                Endif
                aerr := {}
                is_err_FLK := protokol_flk_tmpfile( arr_f, aerr )
                Close databases
                If !Empty( aerr )
                  ins_array( aerr, 1, "" )
                  ins_array( aerr, 1, Center( "Ошибки в чтении файла " + cFile, 80 ) )
                  AEval( aerr, {| x| StrFile( x + hb_eol(), cImportProtokol, .t. ) } )
                  fl := .f. ; Exit
                Endif
                old_sys_date := sys_date
                sys_date := a_reestr[ i, 4 ]
                //
                cReadFile := name_without_ext( cFile )
                cTimeBegin := hour_min( Seconds() )
                cFileProtokol := cReadFile + stxt()
                StrFile( Space( 10 ) + "Протокол обработки файла: " + cFile + hb_eol(), cFileProtokol )
                StrFile( Space( 10 ) + full_date( sys_date ) + "г. " + cTimeBegin + hb_eol(), cFileProtokol, .t. )
                StrFile( hb_eol() + "Тип файла: протокол ФЛК (форматно-логического контроля)" + hb_eol() + hb_eol(), cFileProtokol, .t. )
                If read_xml_file_flk( arr_XML_info, aerr )
                  // запишем принимаемый файл (протокол ФЛК)
                  // chip_copy_zipXML(hb_OemToAnsi(full_zip),dir_server()+dir_XML_TF())
                  chip_copy_zipxml( full_zip, dir_server() + dir_XML_TF() )
                  Use ( cur_dir() + "tmp1file" ) New Alias TMP1
                  g_use( dir_server() + "mo_xml",, "MO_XML" )
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
                  Close databases
                Endif
                If Empty( aerr )
                  // запишем файл протокола обработки
                  chip_copy_zipxml( cFileProtokol, dir_server() + dir_XML_TF() )
                  Delete File ( cFileProtokol )
                Else
                  ins_array( aerr, 1, "" )
                  ins_array( aerr, 1, Center( "Ошибки в чтении файла " + cFile, 80 ) )
                  AEval( aerr, {| x| StrFile( x + hb_eol(), cImportProtokol, .t. ) } )
                  fl := .f. ; Exit
                Endif
                //
                sys_date := old_sys_date
              Else
                StrFile( s + ": нет файла " + s + sxml() + hb_eol(), cImportProtokol, .t. )
                fl := .f. ; Exit
              Endif
            Endif
          Endif
          For j := 1 To Len( a_reestr[ i, 7 ] )
            s := name_without_ext( a_reestr[ i, 7, j, 1 ] )
            arr_XML_info[ 6 ] := a_reestr[ i, 7, j, 4 ]
            arr_XML_info[ 7 ] := 0
            If ( arr_f := extract_zip_xml( keeppath( a_reestr[ i, 7, j, 1 ] ), s + szip() ) ) != NIL
              If ( n := AScan( arr_f, {| x| Upper( name_without_ext( x ) ) == Upper( s ) } ) ) > 0
                cFile := arr_f[ n ]
                // читаем XML-файл в память
                oXmlDoc := hxmldoc():read( _tmp_dir1() + cFile )
                If oXmlDoc == Nil .or. Empty( oXmlDoc:aItems )
                  StrFile( a_reestr[ i, 7, j, 1 ] + ": ошибка в чтении файла" + hb_eol(), cImportProtokol, .t. )
                  fl := .f. ; Exit
                Endif
                aerr := {}
                reestr_sp_tk_tmpfile( oXmlDoc, aerr, cFile )
                Close databases
                If !Empty( aerr )
                  ins_array( aerr, 1, "" )
                  ins_array( aerr, 1, Center( "Ошибки в чтении файла " + cFile, 80 ) )
                  AEval( aerr, {| x| StrFile( x + hb_eol(), cImportProtokol, .t. ) } )
                  fl := .f. ; Exit
                Endif
                old_sys_date := sys_date
                Use ( cur_dir() + "tmp1file" ) New Alias TMP1
                sys_date := tmp1->_DSCHET
                Use
                full_zip := a_reestr[ i, 7, j, 1 ]
                StrFile( " " + strippath( a_reestr[ i, 7, j, 1 ] ) + ": обработка реестра СП и ТК " + a_reestr[ i, 7, j, 2 ] + hb_eol(), cImportProtokol, .t. )
                cReadFile := name_without_ext( cFile )
                cTimeBegin := hour_min( Seconds() )
                cFileProtokol := cReadFile + stxt()
                StrFile( Space( 10 ) + "Протокол обработки файла: " + cFile + hb_eol(), cFileProtokol )
                StrFile( Space( 10 ) + full_date( sys_date ) + "г. " + cTimeBegin + hb_eol(), cFileProtokol, .t. )
                StrFile( hb_eol() + "Тип файла: реестр СП и ТК (страховой принадлежности и технологического контроля)" + hb_eol() + hb_eol(), cFileProtokol, .t. )
                nCountWithErr := mXML_REESTR := 0
                If read_xml_file_sp( arr_XML_info, aerr, @nCountWithErr ) > 0
                  stat_msg( "" )
                  create_schet_from_xml( arr_XML_info, aerr, .f.,, cReadFile )
                  stat_msg( "" )
                Elseif nCountWithErr > 0 // все пришли с ошибкой
                  g_use( dir_server() + "mo_xml",, "MO_XML" )
                  Goto ( mXML_REESTR )
                  g_rlock( forever )
                  mo_xml->TWORK2 := hour_min( Seconds() )
                  Close databases
                Endif
                If Empty( aerr ) .or. nCountWithErr > 0
                  // запишем файл протокола обработки
                  chip_copy_zipxml( cFileProtokol, dir_server() + dir_XML_TF() )
                  Delete File ( cFileProtokol )
                Endif
                If !Empty( aerr )
                  ins_array( aerr, 1, "" )
                  ins_array( aerr, 1, Center( "Ошибки в чтении файла " + cFile, 80 ) )
                  AEval( aerr, {| x| StrFile( x + hb_eol(), cImportProtokol, .t. ) } )
                  fl := .f. ; Exit
                Endif
                sys_date := old_sys_date
              Else
                StrFile( a_reestr[ i, 7, j, 1 ] + ": нет файла " + s + sxml() + hb_eol(), cImportProtokol, .t. )
                fl := .f. ; Exit
              Endif
            Else
              StrFile( a_reestr[ i, 7, j, 1 ] + ": ошибка Extract_Zip_XML " + s + sxml() + hb_eol(), cImportProtokol, .t. )
              fl := .f. ; Exit
            Endif
            Close databases
          Next
        Else
          StrFile( a_reestr[ i, 1 ] + ": ошибка f2_create_main_base_from_reestrs" + hb_eol(), cImportProtokol, .t. )
          Exit
        Endif
      Else
        StrFile( a_reestr[ i, 1 ] + ": не удалось открыть реестр" + hb_eol(), cImportProtokol, .t. )
        fl := .f. ; Exit
      Endif
    Else
      StrFile( a_reestr[ i, 1 ] + ": ошибка записи реестра в XML_MO" + hb_eol(), cImportProtokol, .t. )
      fl := .f. ; Exit
    Endif
    Close databases
  Next
  Close databases

  Return fl

// 11.04.19
Function f2_create_main_base_from_reestrs( mname_xml )

  Local fl := .t., auch_otd, _tip_lu

  Use ( cur_dir() + "tmp_r_t1" ) New Alias T1
  Use ( cur_dir() + "tmp_r_t2" ) New Alias T2
  Index On IDCASE to ( cur_dir() + "tmp_t2" )
  Use ( cur_dir() + "tmp_r_t3" ) New Alias T3
  Index On Upper( ID_PAC ) to ( cur_dir() + "tmp_t3" )
  Use ( cur_dir() + "tmp1file" ) New Alias TMP1
  Use ( cur_dir() + "tmp_r_t4" ) New Alias T4
  Index On IDCASE to ( cur_dir() + "tmp_t4" )
  //
  mkod_reestr := 0
  g_use( dir_server() + "mo_rees",, "REES" )
  If flag_is_lu
    Locate For NAME_XML == PadR( mname_xml, 26 )
    If Found()
      mkod_reestr := RecNo()
      Close databases
      Return fl
    Endif
  Endif
  addrecn()
  rees->KOD      := RecNo()
  rees->NSCHET   := Int( Val( tmp1->_NSCHET ) )
  rees->DSCHET   := tmp1->_DSCHET
  rees->NYEAR    := tmp1->_YEAR
  rees->NMONTH   := tmp1->_MONTH
  rees->NN       := Val( SubStr( AfterAtNum( "_", mname_xml ), 5 ) )
  rees->NAME_XML := mname_xml
  rees->SUMMA    := tmp1->_SUMMAV
  rees->CODE     := tmp1->_CODE
  rees->DATE_OUT := tmp1->_DSCHET
  rees->NUMB_OUT := 1
  mkod_reestr := RecNo()
  //
  g_use( dir_server() + "mo_xml",, "MO_XML" )
  addrecn()
  mo_xml->KOD    := RecNo()
  mo_xml->FNAME  := mname_xml
  mo_xml->FNAME2 := "L" + SubStr( mname_xml, 2 )
  mo_xml->DFILE  := rees->DSCHET
  mo_xml->TIP_OUT := _XML_FILE_REESTR // тип высылаемого файла;1-реестр
  mo_xml->REESTR := mkod_reestr
  mo_xml->DREAD := tmp1->_DSCHET
  mo_xml->TREAD := '12:00'
  rees->KOD_XML := mo_xml->KOD
  Unlock
  Commit
  //
  use_base( "lusl" )
  use_base( "luslc" )
  use_base( "luslf" )
  g_use( dir_server() + "mo_rhum",, "RHUM" )
  g_use( dir_server() + "mo_pers",, "PERSO" )
  Index On snils + Str( prvs_new, 4 ) to ( cur_dir() + "tmppsnils" )
  Index On snils + Str( prvs, 9 ) to ( cur_dir() + "tmppsnils1" )
  Set Index to ( cur_dir() + "tmppsnils" ), ( cur_dir() + "tmppsnils1" )
  use_base( "mo_su" )
  use_base( "uslugi" )
  r_use( dir_server() + "uslugi1", { dir_server() + "uslugi1", ;
    dir_server() + "uslugi1s" }, "USL1" )
  g_use( dir_server() + "mo_kfio",, "KFIO" )
  Index On Str( kod, 7 ) to ( cur_dir() + "tmp_kfio" )
  g_use( dir_server() + "mo_kismo",, "KSN" )
  Index On Str( kod, 7 ) to ( cur_dir() + "tmpkismo" )
  g_use( dir_server() + "mo_hismo",, "HSN" )
  Index On Str( kod, 7 ) to ( cur_dir() + "tmphismo" )
  r_use( dir_server() + "mo_otd",, "OTD" )
  Index On Str( tiplu, 2 ) + Str( kod_lpu, 3 ) to ( cur_dir() + "tmpotd1" ) ;
    For Empty( dend ) .and. kod > 0 .and. kod_lpu > 0
  Index On Str( profil, 3 ) + Str( idump, 2 ) + Str( kod_lpu, 3 ) to ( cur_dir() + "tmpotd2" ) ;
    For Empty( dend ) .and. kod > 0 .and. kod_lpu > 0
  Index On Str( code_dep, 3 ) + Str( idump, 2 ) + Str( kod_lpu, 3 ) to ( cur_dir() + "tmpotd3" ) ;
    For Empty( dend ) .and. kod > 0 .and. kod_lpu > 0
  Set Index to ( cur_dir() + "tmpotd1" ), ( cur_dir() + "tmpotd2" ), ( cur_dir() + "tmpotd3" )
  use_base( "kartotek" )
  use_base( "mo_hu" )
  use_base( "human_u" )
  use_base( "human" )
  Select HUMAN_
  Index On Upper( ID_C ) to ( cur_dir() + "tmp_h_" )
  //
  stat_msg( "Импорт из реестра " + mname_xml )
  pkol := 0
  Select T1
  Go Top
  Do While !Eof()
    pkol++
    is_zak_sl := .f. ; a_usl := {}
    @ MaxRow(), 1 Say lstr( pkol ) Color cColorSt2Msg
    Select T3
    find ( Upper( t1->ID_PAC ) )
    If Found()
      afio := Array( 3 )
      If Left( t1->NOVOR, 1 ) == '0' .or. Empty( t3->FAM_P )
        afio[ 1 ] := t3->fam
        afio[ 2 ] := t3->im
        afio[ 3 ] := t3->ot
        mpol    := t3->W
        mdate_r := t3->DR
      Else
        afio[ 1 ] := t3->FAM_P
        afio[ 2 ] := t3->IM_P
        afio[ 3 ] := t3->OT_P
        mpol    := t3->W_P
        mdate_r := t3->DR_P
      Endif
      mfio := PadR( AllTrim( afio[ 1 ] ) + " " + AllTrim( afio[ 2 ] ) + " " + AllTrim( afio[ 3 ] ), 50 )
      mpol := iif( mpol == '1', "М", "Ж" )
      mdate_r := xml2date( mdate_r )
      mpolis := PadR( make_polis( t1->spolis, t1->npolis ), 17 )
      If Empty( mfio )
        my_debug(, "реестр=" + lstr( mkod_reestr ) + ", запись=" + t1->IDCASE )
        my_debug(, "|NOVOR|" + t1->NOVOR )
        my_debug(, "|фио|" + RTrim( mfio ) )
        my_debug(, "|д.рожд.|" + DToC( mdate_r ) )
        my_debug(, "|полис|" + RTrim( mpolis ) )
      Endif
      //
      mkod := lkod_k := 0 ; _is_lu := .f.
      If flag_is_lu
        Select HUMAN_
        find ( Upper( t1->ID_C ) )
        If Found()
          _is_lu := .t. // уже есть такой л/у
          mkod := human_->( RecNo() )
          human->( dbGoto( mkod ) )
          kart->( dbGoto( human->kod_k ) )
          lkod_k := kart->kod
        Endif
      Endif
      If _is_lu // если уже есть такой л/у
        f3_create_main_base_from_reestrs()
      Else
        If Empty( lkod_k )
          Select KART
          Set Order To 2 // index on if(kod>0,"1","0")+upper(fio)+dtos(date_r) to (dir_server() + "kartoten") progress
          find ( "1" + Upper( mfio ) + DToS( mdate_r ) )
          If Found()
            lkod_k := kart->kod
          Endif
        Endif
        Select KART
        Set Order To 1 // index on str(kod,7) to (dir_server() + "kartotek") progress
        If Empty( lkod_k )
          add1rec( 7 )
          lkod_k := kart->kod := RecNo()
          kart->PC3 := '000'
          my_debug(, print_array( { "добавление", lkod_k, mfio } ) )
        Else
          find ( Str( lkod_k, 7 ) )
          g_rlock( forever )
        Endif
        If !Empty( mfio )
          kart->FIO    := mFIO
        Endif
        If !Empty( mdate_r )
          kart->DATE_R := mdate_r
        Endif
        m1VZROS_REB := M1NOVOR := 0
        fv_date_r()
        kart->pol       := mpol
        kart->VZROS_REB := m1VZROS_REB
        kart->POLIS     := mpolis
        kart->snils     := CharRem( "- ", t3->SNILS )
        If twowordfamimot( afio[ 1 ] ) .or. twowordfamimot( afio[ 2 ] ) .or. twowordfamimot( afio[ 3 ] )
          kart->MEST_INOG := 9
        Else
          kart->MEST_INOG := 0
        Endif
        Select KART_
        Do While kart_->( LastRec() ) < lkod_k
          Append Blank
        Enddo
        Goto ( lkod_k )
        g_rlock( forever )
        kart_->VPOLIS := Val( t1->vpolis )
        kart_->SPOLIS := t1->SPOLIS
        kart_->NPOLIS := t1->NPOLIS
        kart_->SMO    := t1->smo
        kart_->vid_ud := Val( t3->DOCTYPE )
        kart_->ser_ud := t3->DOCSER
        kart_->nom_ud := t3->DOCNUM
        kart_->mesto_r := t3->MR
        kart_->okatog := t3->OKATOG
        kart_->okatop := iif( t3->OKATOG == t3->OKATOP, "", t3->OKATOP )
        kart_->KVARTAL_D := t1->SMO_OK // ОКАТО субъекта РФ территории страхования
        //
        Select KFIO
        find ( Str( lkod_k, 7 ) )
        If Found()
          If kart->MEST_INOG == 9
            g_rlock( forever )
            kfio->FAM := afio[ 1 ]
            kfio->IM  := afio[ 2 ]
            kfio->OT  := afio[ 3 ]
          Else
            deleterec( .t. )
          Endif
        Else
          If kart->MEST_INOG == 9
            addrec( 7 )
            kfio->kod := lkod_k
            kfio->FAM := afio[ 1 ]
            kfio->IM  := afio[ 2 ]
            kfio->OT  := afio[ 3 ]
          Endif
        Endif
        //
        fl_nameismo := ( Empty( t1->SMO ) .and. !Empty( t1->SMO_NAM ) )
        If fl_nameismo
          kart_->SMO := "34"
        Endif
        Select KSN
        find ( Str( lkod_k, 7 ) )
        If Found()
          If fl_nameismo
            g_rlock( forever )
            ksn->smo_name := t1->SMO_NAM
          Else
            deleterec( .t. )
          Endif
        Else
          If fl_nameismo
            addrec( 7 )
            ksn->kod := lkod_k
            ksn->smo_name := t1->SMO_NAM
          Endif
        Endif
        Unlock
        //
        lvrach := 0 ; n := prvs_v021_to_v015( t1->PRVS )
        If Len( AllTrim( t1->IDDOKT ) ) == 11
          lvrach := ret_perso_with_tab_nom( t1->IDDOKT, n )
          If Empty( lvrach ) .and. !flag_is_lu
            Select PERSO
            addrecn()
            lvrach := perso->kod := RecNo()
            perso->tab_nom := RecNo()
            perso->fio  := "Сотрудник с кодом " + lstr( lvrach )
            perso->uch  := p_lpu
            perso->otd  := p_otd
            perso->prvs_new := n
            perso->snils := t1->IDDOKT
            Unlock
          Endif
        Endif
        //
        mDATE_R2 := CToD( "" )
        If ( M1NOVOR := Int( Val( Left( t1->NOVOR, 1 ) ) ) ) > 0
          mDATE_R2 := mdate_r
        Endif
        fv_date_r( xml2date( t1->DATE_1 ) )
        Select HUMAN
        Set Order To 1
        If mkod == 0
          add1rec( 7 )
          mkod := human->kod := RecNo()
        Else
          Goto ( mkod )
          g_rlock( forever )
          If human->kod_k != lkod_k
            my_debug(, "  " + RTrim( human->fio ) + "|фио|" + RTrim( mfio ) )
            my_debug(, "  " + DToC( human->date_r ) + "|д.рожд.|" + DToC( mdate_r ) )
            my_debug(, "  " + RTrim( human->polis ) + "|полис|" + RTrim( mpolis ) )
          Endif
          If human_->REESTR == mkod_reestr
            my_debug(, "  " + RTrim( human->fio ) + "=второй раз в реестре=" + lstr( mkod_reestr ) )
          Endif
        Endif
        Select HUMAN_
        Do While human_->( LastRec() ) < mkod
          Append Blank
        Enddo
        Goto ( mkod )
        g_rlock( forever )
        //
        Select HUMAN_2
        Do While human_2->( LastRec() ) < mkod
          Append Blank
        Enddo
        Goto ( mkod )
        g_rlock( forever )
        //
        human->kod_k      := lkod_k
        human->TIP_H      := B_STANDART
        human->FIO        := kart->FIO    // Ф.И.О. больного
        human->POL        := kart->POL    // пол
        human->DATE_R     := kart->DATE_R // дата рождения больного
        human->VZROS_REB  := M1VZROS_REB  // 0-взрослый, 1-ребенок, 2-подросток
        human->KOD_DIAG   := t1->ds1
        s := Right( t1->ds1, 1 )
        For i := 1 To 7
          pole := "t1->DS2" + iif( i == 1, "", "_" + lstr( i ) )
          s += Right( &pole, 1 )
          If !Empty( &pole )
            poleh := { "KOD_DIAG2", "KOD_DIAG3", "KOD_DIAG4", ;
              "SOPUT_B1", "SOPUT_B2", "SOPUT_B3", "SOPUT_B4" }[ i ]
            poleh := "human->" + poleh
            &poleh := &pole
          Endif
        Next
        human->DIAG_PLUS  := s
        human->KOMU       := 0
        human_->SMO       := kart_->smo
        human->POLIS      := kart->polis
        human->UCH_DOC    := t1->NHISTORY
        human->N_DATA     := xml2date( t1->DATE_1 )
        human->K_DATA     := xml2date( t1->DATE_2 )
        human->CENA := human->CENA_1 := Val( t1->SUMV )
        human->OBRASHEN   := t1->ds_onk
        human_->VPOLIS    := Val( t1->vpolis )
        human_->SPOLIS    := t1->SPOLIS
        human_->NPOLIS    := t1->NPOLIS
        human_->OKATO     := t1->SMO_OK // ОКАТО субъекта РФ территории страхования
        If M1NOVOR == 0
          human_->NOVOR   := 0
          human_->DATE_R2 := CToD( "" )
          human_->POL2    := ""
        Else
          human_->NOVOR   := Val( Right( t1->NOVOR, 2 ) )
          human_->DATE_R2 := SToD( "20" + SubStr( t1->NOVOR, 6, 2 ) + SubStr( t1->NOVOR, 4, 2 ) + SubStr( t1->NOVOR, 2, 2 ) )
          human_->POL2    := iif( M1NOVOR == 1, "М", "Ж" )
        Endif
        human_->USL_OK    := Val( t1->USL_OK )
        human_->VIDPOM    := Val( t1->VIDPOM )
        human_->PROFIL    := Val( t1->PROFIL )
        human_->IDSP      := Val( t1->IDSP )
        human_->NPR_MO    := t1->NPR_MO
        s := '0'
        // 1 - экстренная, 2 - неотложная, 3 - плановая
        If human_->USL_OK == 1 // стационар
          s := iif( t1->FOR_POM == '1', '1', '0' )
        Elseif human_->USL_OK == 4 // скорая помощь
          s := iif( t1->FOR_POM == '1', '1', '0' )
        Endif
        human_->FORMA14   := s + "000"
        human_->KOD_DIAG0 := t1->ds0
        human_->RSLT_NEW  := Val( t1->rslt )
        human_->ISHOD_NEW := Val( t1->ishod )
        human_->VRACH     := lvrach
        human_->PRVS      := -prvs_v021_to_v015( t1->prvs )
        human_->OPLATA    := 0
        human_->ST_VERIFY := 0
        human_->ID_PAC    := t1->ID_PAC
        human_->ID_C      := t1->ID_C
        human_->REESTR    := mkod_reestr
        human_->REES_ZAP  := Val( t1->N_ZAP )
        If human_->REES_NUM < 99
          human_->REES_NUM := human_->REES_NUM + 1
        Endif
        human->schet      := 0
        human_->SCHET_ZAP := 0
        human->kod_p      := Chr( 0 )
        human->date_e     := ''
        If !Empty( t1->CRIT )  // потом добавим t1->CRIT2 и онкологию
          human_2->pc3 := t1->CRIT
        Endif
        If t1->SL_K == '1'
          s := lstr( Int( Val( t1->kod_kslp ) ) ) + "," + lstr( Val( t1->koef_kslp ), 5, 2 )
          If !Empty( t1->kod_kslp2 )
            s += "," + lstr( Int( Val( t1->kod_kslp2 ) ) ) + "," + lstr( Val( t1->koef_kslp2 ), 5, 2 )
          Endif
          human_2->pc1 := s
        Endif
        If !Empty( t1->CODE_KIRO )
          human_2->pc2 := lstr( Int( Val( t1->CODE_KIRO ) ) ) + "," + lstr( Val( t1->VAL_K ), 5, 2 )
        Endif
        _tip_lu := 0
        // проверяем диспансеризацию
        m1veteran := m1gruppa := m1etap := 0
        k := Int( Val( t1->COMENTSL ) )
        If eq_any( k, 4, 5 )
          human_2->PN2 := 1
        Elseif k == 20
          human->RAB_NERAB := 0
        Elseif k == 10
          human->RAB_NERAB := 1
        Elseif k == 14
          human->RAB_NERAB := 2
        Elseif k == 21
          human->RAB_NERAB := 0 ; m1veteran := 1
        Elseif k == 11
          human->RAB_NERAB := 1 ; m1veteran := 1
        Endif
        If !Empty( t1->DISP )
          Do Case
          Case t1->DISP == "ДВ1" // "Первый этап диспансеризации определенных групп взрослого населения",stod("2016-01-01")})
            m1etap := 1
            human->ishod := 201
            _tip_lu := TIP_LU_DVN
          Case t1->DISP == "ДВ2" // "Второй этап диспансеризации определенных групп взрослого населения",stod("2016-01-01")})
            m1etap := 2 // или 5
            human->ishod := 202 // или 205
            _tip_lu := TIP_LU_DVN
            mdvozrast := Year( human->K_DATA ) - Year( human->date_r )
            /*if ascan(arr2m_vozrast_DVN,mdvozrast) > 0
              m1etap := 5
              human->ishod := 205
            elseif human->POL == "Ж" .and. ascan(arr2g_vozrast_DVN(),mdvozrast) > 0
              m1etap := 5
              human->ishod := 205
            endif*/
          Case t1->DISP == "ОПВ" // "Профилактические медицинские осмотры взрослого населения",stod("2013-12-26")})
            m1etap := 3
            human->ishod := 203
            _tip_lu := TIP_LU_DVN
          Case t1->DISP == "ДВ3" // "Первый этап диспансеризации определенных групп взрослого населения (1 раз в 2 года)",stod("18-01-01")})
            m1etap := 4
            human->ishod := 204
            _tip_lu := TIP_LU_DVN
          Case t1->DISP == "ДС1" // "Диспансеризация пребывающих в стационарных учреждениях детей-сирот и детей, находящихся в трудной жизненной ситуации (состоящая из 1 этапа)",stod("17-01-01")})
            m1etap := 1
            human->ishod := 101
            human->ZA_SMO := 1
            If Between( human_->RSLT_NEW, 321, 325 ) // TIP_LU_DDS
              _tip_lu := TIP_LU_DDS
              m1gruppa := human_->RSLT_NEW -321 + 1
            Endif
          Case t1->DISP == "ДС2" // "Диспансеризация пребывающих в стационарных учреждениях детей-сирот и детей, находящихся в трудной жизненной ситуации  (состоящая из 2-х этапов)",stod("2017-01-01")})
            m1etap := 2
            human->ishod := 102
            human->ZA_SMO := 1
            If Between( human_->RSLT_NEW, 321, 325 ) // TIP_LU_DDS
              _tip_lu := TIP_LU_DDS
              m1gruppa := human_->RSLT_NEW -321 + 1
            Endif
          Case t1->DISP == "ДУ1" // "Диспансеризация детей-сирот и детей, оставшихся без попечения родителей, в том числе усыновленных (удочеренных), принятых под опеку (попечительство) в приемную или патронатную семью  (состоящая из 1 этапа)",stod("2017-01-01")})
            m1etap := 1
            human->ishod := 101
            If Between( human_->RSLT_NEW, 347, 351 ) // TIP_LU_DDSOP
              _tip_lu := TIP_LU_DDSOP
              m1gruppa := human_->RSLT_NEW -347 + 1
            Endif
          Case t1->DISP == "ДУ2" // "Диспансеризация детей-сирот и детей, оставшихся без попечения родителей, в том числе усыновленных (удочеренных), принятых под опеку (попечительство) в приемную или патронатную семью  (состоящая из 2-х этапов)",stod("2017-01-01")})
            m1etap := 2
            human->ishod := 102
            If Between( human_->RSLT_NEW, 347, 351 ) // TIP_LU_DDSOP
              _tip_lu := TIP_LU_DDSOP
              m1gruppa := human_->RSLT_NEW -347 + 1
            Endif
          Case t1->DISP == "ОН1" // "Медицинские осмотры несовершеннолетних, в том числе при поступлении в образовательные учреждения и в период обучения в них (профилактические) (состоящие из 1 этапа)",stod("2017-01-01")})
            m1etap := 1
            human->ishod := 301
            If Between( human_->RSLT_NEW, 332, 336 ) // ПН - TIP_LU_PN
              _tip_lu := TIP_LU_PN
              m1gruppa := human_->RSLT_NEW -332 + 1
            Endif
          Case t1->DISP == "ОН2" // "Медицинские осмотры несовершеннолетних, в том числе при поступлении в образовательные учреждения и в период обучения в них (профилактические) (состоящие из 2-х этапов)",stod("2017-01-01")})
            m1etap := 2
            human->ishod := 302
            If Between( human_->RSLT_NEW, 332, 336 ) // ПН - TIP_LU_PN
              _tip_lu := TIP_LU_PN
              m1gruppa := human_->RSLT_NEW -332 + 1
            Endif
          Endcase
        Endif
        If human_->USL_OK == 4 // скорая помощь
          _tip_lu := TIP_LU_SMP
        Endif
        auch_otd := ret_otd_with_lu_prof( Int( Val( t1->PODR ) ), human_->USL_OK, _tip_lu, human_->PROFIL, human_->VRACH )
        human->LPU := auch_otd[ 1 ]
        human->OTD := auch_otd[ 2 ]
        // if human->LPU == 6 .and. human->OTD == 25 // специально для онкологии
        // human->ishod := 98 // жидкостная цитология рака шейки матки
        // endif
        //
        For i := 1 To 3
          pole := "t1->ds3" + iif( i == 1, "", "_" + lstr( i ) )
          If !Empty( &pole )
            poleh := "human_2->osl" + lstr( i )
            &poleh := &pole
          Endif
        Next
        If !Empty( t1->VID_HMP )
          human_2->VMP    := 1
          human_2->VIDVMP := t1->VID_HMP
          human_2->METVMP := Val( t1->METOD_HMP )
        Endif
        If !Empty( t1->VNOV_D )
          human_2->VNR  := Val( t1->VNOV_D )
        Endif
        If !Empty( t1->VNOV_M )
          human_2->VNR1 := Val( t1->VNOV_M )
        Endif
        If !Empty( t1->VNOV_M_2 )
          human_2->VNR2 := Val( t1->VNOV_M_2 )
        Endif
        If !Empty( t1->VNOV_M_3 )
          human_2->VNR3 := Val( t1->VNOV_M_3 )
        Endif
        Select HSN
        find ( Str( mkod, 7 ) )
        If Found()
          If fl_nameismo
            g_rlock( forever )
            hsn->smo_name := t1->SMO_NAM
          Else
            deleterec( .t. )
          Endif
        Else
          If fl_nameismo
            addrec( 7 )
            hsn->kod := mkod
            hsn->smo_name := t1->SMO_NAM
          Endif
        Endif
        Unlock
        // если присутствует шифр законченного случая
        fl1 := .f.
        If t1->ED_COL == '1' .and. !Empty( t1->CODE_MES1 )
          fl1 := .t. ; s := t1->CODE_MES1
        Elseif !Empty( t1->n_ksg )
          fl1 := .t. ; s := t1->n_ksg
        Endif
        If fl1
          kod_usl := foundourusluga( s, human->k_data, human_->profil, human->VZROS_REB )
          //
          Select HU
          add1rec( 7 )
          hu->kod     := human->kod
          hu->kod_vr  := human_->VRACH
          hu->kod_as  := 0
          hu->u_koef  := 1
          hu->u_kod   := kod_usl
          hu->u_cena  := Val( t1->TARIF )
          hu->is_edit := 0
          hu->date_u  := dtoc4( human->N_DATA )
          hu->otd     := human->OTD
          hu->kol := hu->kol_1 := 1
          hu->stoim := hu->stoim_1 := human->CENA_1
          Select HU_
          Do While hu_->( LastRec() ) < hu->( RecNo() )
            Append Blank
          Enddo
          Goto ( hu->( RecNo() ) )
          g_rlock( forever )
          hu_->ID_U := mo_guid( 3, hu_->( RecNo() ) )
          hu_->date_u2 := dtoc4( human->K_DATA )
          hu_->PROFIL := Val( t1->PROFIL )
          hu_->PRVS   := -prvs_v021_to_v015( t1->PRVS )
          hu_->kod_diag := t1->ds1
          Unlock
        Endif
        // остальные услуги
        Select T2
        find ( t1->IDCASE )
        Do While t1->IDCASE == t2->IDCASE .and. !Eof()
          lvrach := 0 ; n := prvs_v021_to_v015( t2->PRVS )
          If Len( AllTrim( t2->CODE_MD ) ) == 11
            lvrach := ret_perso_with_tab_nom( t2->CODE_MD, n )
            If Empty( lvrach ) .and. !flag_is_lu
              Select PERSO
              addrecn()
              lvrach := perso->kod := RecNo()
              perso->tab_nom := RecNo()
              perso->fio  := "Сотрудник с кодом " + lstr( lvrach )
              perso->uch  := p_lpu
              perso->otd  := p_otd
              perso->prvs_new := n
              perso->snils := t2->CODE_MD
              Unlock
            Endif
          Endif
          If Empty( lvrach ) .and. !Empty( human_->VRACH )
            lvrach := human_->VRACH
          Endif
          //
          kod_usl := kod_uslf := 0
          If Len( AllTrim( t2->CODE_USL ) ) > 9
            Select MOSU
            Set Order To 3 // по шифру ФФОМС
            find ( PadR( t2->CODE_USL, 20 ) )
            If Found()
              kod_uslf := mosu->kod
            Else
              Select LUSLF
              find ( PadR( t2->CODE_USL, 20 ) )
              If Found()
                Select MOSU
                Set Order To 1
                find ( Str( -1, 6 ) )
                If Found()
                  g_rlock( forever )
                Else
                  addrec( 6 )
                Endif
                kod_uslf := mosu->kod := RecNo()
                mosu->name := luslf->name
                mosu->shifr1 := t2->CODE_USL
                mosu->PROFIL := Val( t2->PROFIL )
                Unlock
              Endif
            Endif
            If !Empty( kod_uslf )
              Select MOHU
              add1rec( 7 )
              mohu->kod     := human->kod
              mohu->kod_vr  := lvrach
              mohu->kod_as  := 0
              mohu->u_kod   := kod_uslf
              mohu->u_cena  := 0
              mohu->date_u  := dtoc4( xml2date( t2->DATE_IN ) )
              mohu->otd     := human->OTD
              mohu->kol_1   := Val( t2->KOL_USL )
              mohu->stoim_1 := 0
              mohu->ID_U    := t2->ID_U
              mohu->PROFIL  := Val( t2->PROFIL )
              mohu->PRVS    := -prvs_v021_to_v015( t2->PRVS )
              mohu->kod_diag := t2->ds
              Unlock
            Endif
          Endif
          If Empty( kod_uslf ) .and. !eq_any( t2->p_otk, '1', '2' )
            kod_usl := foundourusluga( t2->CODE_USL, human->k_data, Val( t2->PROFIL ), human->VZROS_REB )
            Select HU
            add1rec( 7 )
            hu->kod     := human->kod
            hu->kod_vr  := lvrach
            hu->kod_as  := 0
            hu->u_koef  := 1
            hu->u_kod   := kod_usl
            hu->u_cena  := Val( t2->TARIF )
            hu->is_edit := 0
            hu->date_u  := dtoc4( xml2date( t2->DATE_IN ) )
            hu->otd     := human->OTD
            hu->kol := hu->kol_1 := Val( t2->KOL_USL )
            hu->stoim := hu->stoim_1 := Val( t2->SUMV_USL )
            If human_->USL_OK == 3
              If t2->PODR == '0' .and. hu->KOL_RCP >= 0
                hu->KOL_RCP := -1 // на дому
              Endif
              If !( AllTrim( t2->CODE_USL ) == "4.20.2" )
                If ( j := AScan( { '125901', '805965', '103001' }, t2->LPU ) ) > 0
                  hu->is_edit := j
                Endif
              Endif
            Endif
            Select HU_
            Do While hu_->( LastRec() ) < hu->( RecNo() )
              Append Blank
            Enddo
            Goto ( hu->( RecNo() ) )
            g_rlock( forever )
            hu_->ID_U := t2->ID_U
            hu_->date_u2 := dtoc4( xml2date( t2->DATE_OUT ) )
            hu_->PROFIL := Val( t2->PROFIL )
            hu_->PRVS   := -prvs_v021_to_v015( t2->PRVS )
            hu_->kod_diag := t2->ds
            Unlock
          Endif
          Select T2
          Skip
        Enddo
      Endif
      //
      Select RHUM
      Append Blank
      rhum->REESTR := mkod_reestr
      rhum->KOD_HUM := human->kod
      rhum->REES_ZAP := human_->REES_ZAP
      Unlock
    Else
      fl := .f.
      StrFile( mname_xml + ": не найден пациент в T3 " + t1->ID_PAC + hb_eol(), cImportProtokol, .t. )
    Endif
    If pkol % 2000 == 0
      Commit
    Endif
    Select T1
    Skip
  Enddo
  Select REES
  g_rlock( forever )
  rees->KOL := pkol
  Close databases

  Return fl

// 11.04.19 перезаписать лист учёта, если таковой уже есть в БД
Function f3_create_main_base_from_reestrs()

  Local i, j, k, arr_hu, ta, arr_ne, fl

  Select KART
  g_rlock( forever )
  If !Empty( mfio )
    kart->FIO := mFIO
  Endif
  If !Empty( mdate_r )
    kart->DATE_R := mdate_r
  Endif
  m1VZROS_REB := M1NOVOR := 0
  fv_date_r()
  kart->pol       := mpol
  kart->VZROS_REB := m1VZROS_REB
  kart->POLIS     := mpolis
  kart->snils     := CharRem( "- ", t3->SNILS )
  If twowordfamimot( afio[ 1 ] ) .or. twowordfamimot( afio[ 2 ] ) .or. twowordfamimot( afio[ 3 ] )
    kart->MEST_INOG := 9
  Else
    kart->MEST_INOG := 0
  Endif
  Select KART_
  Do While kart_->( LastRec() ) < lkod_k
    Append Blank
  Enddo
  Goto ( lkod_k )
  g_rlock( forever )
  kart_->VPOLIS := Val( t1->vpolis )
  kart_->SPOLIS := t1->SPOLIS
  kart_->NPOLIS := t1->NPOLIS
  kart_->SMO    := t1->smo
  kart_->vid_ud := Val( t3->DOCTYPE )
  kart_->ser_ud := t3->DOCSER
  kart_->nom_ud := t3->DOCNUM
  kart_->mesto_r := t3->MR
  kart_->okatog := t3->OKATOG
  kart_->okatop := iif( t3->OKATOG == t3->OKATOP, "", t3->OKATOP )
  kart_->KVARTAL_D := t1->SMO_OK // ОКАТО субъекта РФ территории страхования
  //
  Select KFIO
  find ( Str( lkod_k, 7 ) )
  If Found()
    If kart->MEST_INOG == 9
      g_rlock( forever )
      kfio->FAM := afio[ 1 ]
      kfio->IM  := afio[ 2 ]
      kfio->OT  := afio[ 3 ]
    Else
      deleterec( .t. )
    Endif
  Else
    If kart->MEST_INOG == 9
      addrec( 7 )
      kfio->kod := lkod_k
      kfio->FAM := afio[ 1 ]
      kfio->IM  := afio[ 2 ]
      kfio->OT  := afio[ 3 ]
    Endif
  Endif
  //
  fl_nameismo := ( Empty( t1->SMO ) .and. !Empty( t1->SMO_NAM ) )
  If fl_nameismo
    kart_->SMO := "34"
  Endif
  Select KSN
  find ( Str( lkod_k, 7 ) )
  If Found()
    If fl_nameismo
      g_rlock( forever )
      ksn->smo_name := t1->SMO_NAM
    Else
      deleterec( .t. )
    Endif
  Else
    If fl_nameismo
      addrec( 7 )
      ksn->kod := lkod_k
      ksn->smo_name := t1->SMO_NAM
    Endif
  Endif
  Unlock
  //
  lvrach := human_->VRACH ; n := prvs_v021_to_v015( t1->PRVS )
  If Empty( lvrach ) .and. Len( AllTrim( t1->IDDOKT ) ) == 11
    lvrach := ret_perso_with_tab_nom( t1->IDDOKT, n )
    If Empty( lvrach ) .and. !flag_is_lu
      Select PERSO
      addrecn()
      lvrach := perso->kod := RecNo()
      perso->tab_nom := RecNo()
      perso->fio  := "Сотрудник с кодом " + lstr( lvrach )
      perso->uch  := human->LPU
      perso->otd  := human->OTD
      perso->prvs_new := n
      perso->snils := t1->IDDOKT
      Unlock
    Endif
  Endif
  //
  mDATE_R2 := CToD( "" )
  If ( M1NOVOR := Int( Val( Left( t1->NOVOR, 1 ) ) ) ) > 0
    mDATE_R2 := mdate_r
  Endif
  fv_date_r( xml2date( t1->DATE_1 ) )
  //
  Select HUMAN
  g_rlock( forever )
  //
  Select HUMAN_
  Do While human_->( LastRec() ) < mkod
    Append Blank
  Enddo
  Goto ( mkod )
  g_rlock( forever )
  //
  Select HUMAN_2
  Do While human_2->( LastRec() ) < mkod
    Append Blank
  Enddo
  Goto ( mkod )
  g_rlock( forever )
  //
  human->kod_k     := lkod_k
  human->TIP_H     := B_STANDART
  human->FIO       := kart->FIO    // Ф.И.О. больного
  human->POL       := kart->POL    // пол
  human->DATE_R    := kart->DATE_R // дата рождения больного
  human->VZROS_REB := M1VZROS_REB  // 0-взрослый, 1-ребенок, 2-подросток
  human->KOD_DIAG  := t1->ds1
  s := Right( t1->ds1, 1 )
  For i := 1 To 7
    pole := "t1->DS2" + iif( i == 1, "", "_" + lstr( i ) )
    s += Right( &pole, 1 )
    If !Empty( &pole )
      poleh := { "KOD_DIAG2", "KOD_DIAG3", "KOD_DIAG4", "SOPUT_B1", "SOPUT_B2", "SOPUT_B3", "SOPUT_B4" }[ i ]
      poleh := "human->" + poleh
      &poleh := &pole
    Endif
  Next
  human->DIAG_PLUS := s
  human->KOMU      := 0
  human_->SMO      := kart_->smo
  human->POLIS     := kart->polis
  If Empty( human->LPU )
    human->LPU := p_lpu
  Endif
  If Empty( human->OTD )
    human->OTD := p_otd
  Endif
  human->UCH_DOC := t1->NHISTORY
  human->N_DATA  := xml2date( t1->DATE_1 )
  human->K_DATA  := xml2date( t1->DATE_2 )
  human_->VPOLIS := Val( t1->vpolis )
  human_->SPOLIS := t1->SPOLIS
  human_->NPOLIS := t1->NPOLIS
  human_->OKATO  := t1->SMO_OK // ОКАТО субъекта РФ территории страхования
  human->CENA := human->CENA_1 := Val( t1->SUMV )
  human->OBRASHEN := t1->DS_ONK
  If M1NOVOR == 0
    human_->NOVOR   := 0
    human_->DATE_R2 := CToD( "" )
    human_->POL2    := ""
  Else
    human_->NOVOR   := Val( Right( t1->NOVOR, 2 ) )
    human_->DATE_R2 := SToD( "20" + SubStr( t1->NOVOR, 6, 2 ) + SubStr( t1->NOVOR, 4, 2 ) + SubStr( t1->NOVOR, 2, 2 ) )
    human_->POL2    := iif( M1NOVOR == 1, "М", "Ж" )
  Endif
  human_->USL_OK := Val( t1->USL_OK )
  human_->VIDPOM := Val( t1->VIDPOM )
  human_->PROFIL := Val( t1->PROFIL )
  human_->IDSP   := Val( t1->IDSP )
  human_->NPR_MO := t1->NPR_MO
  s := '0'
  // 1 - экстренная, 2 - неотложная, 3 - плановая
  If human_->USL_OK == 1 // стационар
    s := iif( t1->FOR_POM == '1', '1', '0' )
  Elseif human_->USL_OK == 4 // скорая помощь
    s := iif( t1->FOR_POM == '1', '1', '0' )
  Endif
  human_->FORMA14   := s + "000"
  human_->KOD_DIAG0 := t1->ds0
  human_->RSLT_NEW  := Val( t1->rslt )
  human_->ISHOD_NEW := Val( t1->ishod )
  human_->VRACH     := lvrach
  human_->PRVS      := -prvs_v021_to_v015( t1->prvs )
  human_->OPLATA    := 0
  human_->ST_VERIFY := 0
  human_->ID_PAC    := t1->ID_PAC
  // human_->ID_C := t1->ID_C // данное поле заполнено - по нему искали
  human_->REESTR    := mkod_reestr
  human_->REES_ZAP  := Val( t1->N_ZAP ) // val(t1->IDCASE)
  If human_->REES_NUM < 99
    human_->REES_NUM := human_->REES_NUM + 1
  Endif
  human->schet      := 0
  human_->SCHET_ZAP := 0
  If !Empty( t1->CRIT )  // потом добавим t1->CRIT2 и онкологию
    human_2->pc3 := t1->CRIT
  Endif
  If t1->SL_K == '1'
    s := lstr( Int( Val( t1->kod_kslp ) ) ) + "," + lstr( Val( t1->koef_kslp ), 5, 2 )
    If !Empty( t1->kod_kslp2 )
      s += "," + lstr( Int( Val( t1->kod_kslp2 ) ) ) + "," + lstr( Val( t1->koef_kslp2 ), 5, 2 )
    Endif
    human_2->pc1 := s
  Endif
  If !Empty( t1->CODE_KIRO )
    human_2->pc2 := lstr( Int( Val( t1->CODE_KIRO ) ) ) + "," + lstr( Val( t1->VAL_K ), 5, 2 )
  Endif
  // human->kod_p  := chr(0) // данное поле заполнено
  // human->date_e := ''     // данное поле заполнено
  // проверяем диспансеризацию
  m1veteran := m1gruppa := m1etap := 0
  k := Int( Val( t1->COMENTSL ) )
  If eq_any( k, 4, 5 )
    human_2->PN2 := 1
  Elseif k == 20
    human->RAB_NERAB := 0
  Elseif k == 10
    human->RAB_NERAB := 1
  Elseif k == 14
    human->RAB_NERAB := 2
  Elseif k == 21
    human->RAB_NERAB := 0 ; m1veteran := 1
  Elseif k == 11
    human->RAB_NERAB := 1 ; m1veteran := 1
  Endif
  If !Empty( t1->DISP )
    Do Case
    Case t1->DISP == "ДВ1" // "Первый этап диспансеризации определенных групп взрослого населения",stod("2016-01-01")})
      m1etap := 1
      human->ishod := 201
      _tip_lu := TIP_LU_DVN
    Case t1->DISP == "ДВ2" // "Второй этап диспансеризации определенных групп взрослого населения",stod("2016-01-01")})
      m1etap := 2 // или 5
      human->ishod := 202 // или 205
      _tip_lu := TIP_LU_DVN
      mdvozrast := Year( human->K_DATA ) - Year( human->date_r )
      /*if ascan(arr2m_vozrast_DVN,mdvozrast) > 0
        m1etap := 5
        human->ishod := 205
      elseif human->POL == "Ж" .and. ascan(arr2g_vozrast_DVN(),mdvozrast) > 0
        m1etap := 5
        human->ishod := 205
      endif*/
    Case t1->DISP == "ОПВ" // "Профилактические медицинские осмотры взрослого населения",stod("2013-12-26")})
      m1etap := 3
      human->ishod := 203
      If Between( human_->RSLT_NEW, 343, 345 ) // ДВН(проф.) - TIP_LU_DVN
        _tip_lu := TIP_LU_DVN
        m1gruppa := human_->RSLT_NEW -343 + 1
      Endif
    Case t1->DISP == "ДВ3" // "Первый этап диспансеризации определенных групп взрослого населения (1 раз в 2 года)",stod("18-01-01")})
      m1etap := 4
      human->ishod := 204
      _tip_lu := TIP_LU_DVN
    Case t1->DISP == "ДС1" // "Диспансеризация пребывающих в стационарных учреждениях детей-сирот и детей, находящихся в трудной жизненной ситуации (состоящая из 1 этапа)",stod("17-01-01")})
      m1etap := 1
      human->ishod := 101
      human->ZA_SMO := 1
      If Between( human_->RSLT_NEW, 321, 325 ) // TIP_LU_DDS
        _tip_lu := TIP_LU_DDS
        m1gruppa := human_->RSLT_NEW -321 + 1
      Endif
    Case t1->DISP == "ДС2" // "Диспансеризация пребывающих в стационарных учреждениях детей-сирот и детей, находящихся в трудной жизненной ситуации  (состоящая из 2-х этапов)",stod("2017-01-01")})
      m1etap := 2
      human->ishod := 102
      human->ZA_SMO := 1
      If Between( human_->RSLT_NEW, 321, 325 ) // TIP_LU_DDS
        _tip_lu := TIP_LU_DDS
        m1gruppa := human_->RSLT_NEW -321 + 1
      Endif
    Case t1->DISP == "ДУ1" // "Диспансеризация детей-сирот и детей, оставшихся без попечения родителей, в том числе усыновленных (удочеренных), принятых под опеку (попечительство) в приемную или патронатную семью  (состоящая из 1 этапа)",stod("2017-01-01")})
      m1etap := 1
      human->ishod := 101
      If Between( human_->RSLT_NEW, 347, 351 ) // TIP_LU_DDSOP
        _tip_lu := TIP_LU_DDSOP
        m1gruppa := human_->RSLT_NEW -347 + 1
      Endif
    Case t1->DISP == "ДУ2" // "Диспансеризация детей-сирот и детей, оставшихся без попечения родителей, в том числе усыновленных (удочеренных), принятых под опеку (попечительство) в приемную или патронатную семью  (состоящая из 2-х этапов)",stod("2017-01-01")})
      m1etap := 2
      human->ishod := 102
      If Between( human_->RSLT_NEW, 347, 351 ) // TIP_LU_DDSOP
        _tip_lu := TIP_LU_DDSOP
        m1gruppa := human_->RSLT_NEW -347 + 1
      Endif
    Case t1->DISP == "ОН1" // "Медицинские осмотры несовершеннолетних, в том числе при поступлении в образовательные учреждения и в период обучения в них (профилактические) (состоящие из 1 этапа)",stod("2017-01-01")})
      m1etap := 1
      human->ishod := 301
      If Between( human_->RSLT_NEW, 332, 336 ) // ПН - TIP_LU_PN
        _tip_lu := TIP_LU_PN
        m1gruppa := human_->RSLT_NEW -332 + 1
      Endif
    Case t1->DISP == "ОН2" // "Медицинские осмотры несовершеннолетних, в том числе при поступлении в образовательные учреждения и в период обучения в них (профилактические) (состоящие из 2-х этапов)",stod("2017-01-01")})
      m1etap := 2
      human->ishod := 302
      If Between( human_->RSLT_NEW, 332, 336 ) // ПН - TIP_LU_PN
        _tip_lu := TIP_LU_PN
        m1gruppa := human_->RSLT_NEW -332 + 1
      Endif
    Endcase
  Endif
  //
  For i := 1 To 3
    pole := "t1->ds3" + iif( i == 1, "", "_" + lstr( i ) )
    If !Empty( &pole )
      poleh := "human_2->osl" + lstr( i )
      &poleh := &pole
    Endif
  Next
  If !Empty( t1->VID_HMP )
    human_2->VMP    := 1
    human_2->VIDVMP := t1->VID_HMP
    human_2->METVMP := Val( t1->METOD_HMP )
  Endif
  If !Empty( t1->VNOV_D )
    human_2->VNR  := Val( t1->VNOV_D )
  Endif
  If !Empty( t1->VNOV_M )
    human_2->VNR1 := Val( t1->VNOV_M )
  Endif
  If !Empty( t1->VNOV_M_2 )
    human_2->VNR2 := Val( t1->VNOV_M_2 )
  Endif
  If !Empty( t1->VNOV_M_3 )
    human_2->VNR3 := Val( t1->VNOV_M_3 )
  Endif
  Select HSN
  find ( Str( mkod, 7 ) )
  If Found()
    If fl_nameismo
      g_rlock( forever )
      hsn->smo_name := t1->SMO_NAM
    Else
      deleterec( .t. )
    Endif
  Else
    If fl_nameismo
      addrec( 7 )
      hsn->kod := mkod
      hsn->smo_name := t1->SMO_NAM
    Endif
  Endif
  Unlock
  //
  arr_hu := {}
  Select HU
  find ( Str( mkod, 7 ) )
  Do While hu->kod == mkod .and. !Eof()
    AAdd( arr_hu, { hu->( RecNo() ), ;      // номер записи
    "", ;                 // занесём шифр услуги
      0, ;                  // занесём номер записи по БД T2
      hu->u_kod } )          // код услуги
    Select HU
    Skip
  Enddo
  arr_mohu := {}
  Select MOHU
  find ( Str( mkod, 7 ) )
  Do While mohu->kod == mkod .and. !Eof()
    AAdd( arr_mohu, { mohu->( RecNo() ), ;      // номер записи
    "", ;                   // занесём шифр услуги
      0, ;                    // занесём номер записи по БД T2
      mohu->u_kod } )          // код услуги
    Select MOHU
    Skip
  Enddo
  arr_ne := {}
  Select T2
  find ( t1->IDCASE )
  Do While t1->IDCASE == t2->IDCASE .and. !Eof()
    If !eq_any( t2->p_otk, '1', '2' ) // не отказ и невозможность в диспансеризации
      fl := .t.
      For i := 1 To Len( arr_hu )
        Select HU
        Goto ( arr_hu[ i, 1 ] )
        If Upper( t2->ID_U ) == Upper( hu_->ID_U )
          arr_hu[ i, 2 ] := AllTrim( t2->CODE_USL )
          arr_hu[ i, 3 ] := t2->( RecNo() )
          fl := .f.
          Exit
        Endif
      Next
      If fl
        For i := 1 To Len( arr_mohu )
          Select MOHU
          Goto ( arr_mohu[ i, 1 ] )
          If Upper( t2->ID_U ) == Upper( mohu->ID_U )
            arr_mohu[ i, 2 ] := AllTrim( t2->CODE_USL )
            arr_mohu[ i, 3 ] := t2->( RecNo() )
            fl := .f.
            Exit
          Endif
        Next
      Endif
      If fl
        AAdd( arr_ne, t2->( RecNo() ) ) // не найденные записи
      Endif
    Endif
    Select T2
    Skip
  Enddo
  my_debug(, print_array( arr_mohu ) )
  // если присутствует шифр законченного случая
  fl := .f.
  If t1->ED_COL == '1' .and. !Empty( t1->CODE_MES1 )
    fl := .t. ; s := t1->CODE_MES1
  Elseif !Empty( t1->n_ksg )
    fl := .t. ; s := t1->n_ksg
  Endif
  If fl
    ta := foundallshifrtf( s, human->k_data )
    If Len( ta ) > 0 // попытаемся найти в массиве необходимый код услуг
      For i := 1 To Len( arr_hu )
        If Empty( arr_hu[ i, 3 ] ) .and. AScan( ta, arr_hu[ i, 4 ] ) > 0
          arr_hu[ i, 2 ] := AllTrim( s )
          arr_hu[ i, 3 ] := -1
          Exit
        Endif
      Next
    Endif
    If AScan( arr_hu, {| x| x[ 3 ] < 0 } ) == 0 // если не нашли
      kod_usl := foundourusluga( s, human->k_data, human_->profil, human->VZROS_REB )
      //
      Select HU
      add1rec( 7 )
      hu->kod     := human->kod
      hu->kod_vr  := lvrach
      hu->kod_as  := 0
      hu->u_koef  := 1
      hu->u_kod   := kod_usl
      hu->u_cena  := Val( t1->TARIF )
      hu->is_edit := 0
      hu->date_u  := dtoc4( human->N_DATA )
      hu->otd     := human->otd
      hu->kol := hu->kol_1 := 1
      hu->stoim := hu->stoim_1 := human->CENA_1
      Select HU_
      Do While hu_->( LastRec() ) < hu->( RecNo() )
        Append Blank
      Enddo
      Goto ( hu->( RecNo() ) )
      g_rlock( forever )
      hu_->ID_U := mo_guid( 3, hu_->( RecNo() ) )
      hu_->date_u2 := dtoc4( human->K_DATA )
      hu_->PROFIL := Val( t1->PROFIL )
      hu_->PRVS   := -prvs_v021_to_v015( t1->PRVS )
      hu_->kod_diag := t1->ds1
      Unlock
    Endif
  Endif
  For i := 1 To Len( arr_hu )
    If Empty( arr_hu[ i, 3 ] ) // услуга есть в нашей БД, но нет в реестре
      Select HU
      Goto ( arr_hu[ i, 1 ] )
      deleterec( .t., .f. )  // очистка записи без пометки на удаление
    Else // услуга есть и в нашей БД, и в реестре
      Select HU
      Goto ( arr_hu[ i, 1 ] )
      g_rlock( forever )
      Select HU_
      Do While hu_->( LastRec() ) < hu->( RecNo() )
        Append Blank
      Enddo
      Goto ( hu->( RecNo() ) )
      g_rlock( forever )
      If arr_hu[ i, 3 ] < 0 // код законченного случая
        hu->u_cena  := Val( t1->TARIF )
        hu->date_u  := dtoc4( human->N_DATA )
        hu->kol := hu->kol_1 := 1
        hu->stoim := hu->stoim_1 := human->CENA_1
        If Empty( hu_->ID_U )
          hu_->ID_U := mo_guid( 3, hu_->( RecNo() ) )
        Endif
        hu_->date_u2 := dtoc4( human->K_DATA )
        hu_->PROFIL := Val( t1->PROFIL )
        hu_->PRVS   := -prvs_v021_to_v015( t1->PRVS )
        hu_->kod_diag := t1->ds1
      Else
        Select T2
        Goto ( arr_hu[ i, 3 ] )
        hu->u_cena  := Val( t2->TARIF )
        hu->date_u  := dtoc4( xml2date( t2->DATE_IN ) )
        hu->kol := hu->kol_1 := Val( t2->KOL_USL )
        hu->stoim := hu->stoim_1 := Val( t2->SUMV_USL )
        hu_->ID_U := t2->ID_U
        hu_->date_u2 := dtoc4( xml2date( t2->DATE_OUT ) )
        hu_->PROFIL := Val( t2->PROFIL )
        hu_->PRVS   := -prvs_v021_to_v015( t2->PRVS )
        hu_->kod_diag := t2->ds
        If human_->USL_OK == 3
          If t2->PODR == '0' .and. hu->KOL_RCP >= 0
            hu->KOL_RCP := -1 // на дому
          Endif
          If !( AllTrim( arr_hu[ i, 2 ] ) == "4.20.2" )
            If ( j := AScan( { '125901', '805965', '103001' }, t2->LPU ) ) > 0
              hu->is_edit := j
            Endif
          Endif
        Endif
      Endif
      If Empty( hu->kod_vr )
        hu->kod_vr := human_->vrach
      Endif
      hu->u_koef  := 1
      hu->is_edit := 0
      If Empty( hu->otd )
        hu->otd := human->otd
      Endif
      Unlock
    Endif
  Next
  For i := 1 To Len( arr_mohu )
    If Empty( arr_mohu[ i, 3 ] ) // услуга есть в нашей БД, но нет в реестре
      Select MOHU
      Goto ( arr_mohu[ i, 1 ] )
      deleterec( .t., .f. )  // очистка записи без пометки на удаление
    Else // услуга есть и в нашей БД, и в реестре
      Select MOHU
      Goto ( arr_mohu[ i, 1 ] )
      g_rlock( forever )
      Select T2
      Goto ( arr_mohu[ i, 3 ] )
      mohu->u_cena  := Val( t2->TARIF )
      mohu->date_u  := dtoc4( xml2date( t2->DATE_IN ) )
      mohu->kol_1 := Val( t2->KOL_USL )
      mohu->stoim_1 := Val( t2->SUMV_USL )
      mohu->ID_U := t2->ID_U
      mohu->date_u2 := dtoc4( xml2date( t2->DATE_OUT ) )
      mohu->PROFIL := Val( t2->PROFIL )
      mohu->PRVS   := -prvs_v021_to_v015( t2->PRVS )
      mohu->kod_diag := t2->ds
      If Empty( mohu->kod_vr )
        mohu->kod_vr := human_->vrach
      Endif
      If Empty( mohu->otd )
        mohu->otd := human->otd
      Endif
      Unlock
    Endif
  Next
  // услуги, которые есть в реестре и нет в БД услуг
  For i := 1 To Len( arr_ne )
    Select T2
    Goto ( arr_ne[ i ] )
    lvrach := 0 ; n := prvs_v021_to_v015( t2->PRVS )
    If Abs( human_->PRVS ) == n // если спец-ть как в случае
      lvrach := human_->VRACH  // берём код врача из случая
      n := 0 // обнуляем, чтобы больше не искать врача
    Endif
    If n > 0 .and. Len( AllTrim( t2->CODE_MD ) ) == 11
      lvrach := ret_perso_with_tab_nom( t2->CODE_MD, n )
      If Empty( lvrach ) .and. !flag_is_lu
        Select PERSO
        addrecn()
        lvrach := perso->kod := RecNo()
        perso->tab_nom := RecNo()
        perso->fio  := "Сотрудник с кодом " + lstr( lvrach )
        perso->uch  := human->uch
        perso->otd  := human->otd
        perso->prvs_new := n
        perso->snils := t2->CODE_MD
        Unlock
      Endif
    Endif
    //
    kod_usl := kod_uslf := 0
    If Len( AllTrim( t2->CODE_USL ) ) > 9
      Select MOSU
      Set Order To 3 // по шифру ФФОМС
      find ( PadR( t2->CODE_USL, 20 ) )
      If Found()
        kod_uslf := mosu->kod
      Else
        Select LUSLF
        find ( PadR( t2->CODE_USL, 20 ) )
        If Found()
          Select MOSU
          Set Order To 1
          find ( Str( -1, 6 ) )
          If Found()
            g_rlock( forever )
          Else
            addrec( 6 )
          Endif
          kod_uslf := mosu->kod := RecNo()
          mosu->name := luslf->name
          mosu->shifr1 := t2->CODE_USL
          mosu->PROFIL := Val( t2->PROFIL )
          Unlock
        Endif
      Endif
      If !Empty( kod_uslf )
        Select MOHU
        add1rec( 7 )
        mohu->kod     := human->kod
        mohu->kod_vr  := lvrach
        mohu->kod_as  := 0
        mohu->u_kod   := kod_uslf
        mohu->u_cena  := 0
        mohu->date_u  := dtoc4( xml2date( t2->DATE_IN ) )
        mohu->otd     := human->otd
        mohu->kol_1   := Val( t2->KOL_USL )
        mohu->stoim_1 := 0
        mohu->ID_U    := t2->ID_U
        mohu->PROFIL  := Val( t2->PROFIL )
        mohu->PRVS    := -prvs_v021_to_v015( t2->PRVS )
        mohu->kod_diag := t2->ds
        Unlock
      Endif
    Endif
    If Empty( kod_uslf )
      kod_usl := foundourusluga( t2->CODE_USL, human->k_data, Val( t2->PROFIL ), human->VZROS_REB )
      Select HU
      add1rec( 7 )
      hu->kod     := human->kod
      hu->kod_vr  := lvrach
      hu->kod_as  := 0
      hu->u_koef  := 1
      hu->u_kod   := kod_usl
      hu->u_cena  := Val( t2->TARIF )
      hu->is_edit := 0
      hu->date_u  := dtoc4( xml2date( t2->DATE_IN ) )
      hu->otd     := human->otd
      hu->kol := hu->kol_1 := Val( t2->KOL_USL )
      hu->stoim := hu->stoim_1 := Val( t2->SUMV_USL )
      Select HU_
      Do While hu_->( LastRec() ) < hu->( RecNo() )
        Append Blank
      Enddo
      Goto ( hu->( RecNo() ) )
      g_rlock( forever )
      hu_->ID_U := t2->ID_U
      hu_->date_u2 := dtoc4( xml2date( t2->DATE_OUT ) )
      hu_->PROFIL := Val( t2->PROFIL )
      hu_->PRVS   := -prvs_v021_to_v015( t2->PRVS )
      hu_->kod_diag := t2->ds
      Unlock
    Endif
  Next

  Return Nil


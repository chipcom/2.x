// mo_serv.prg - сервисы и настройки
#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

  
// 03.08.25 ОКАТО ПРАВКА Волжский
Function OKATO_V()

  Local buf := save_maxrow(), i_kart := 0
  Local oPb
  
  n_message( { 'Данный режим предназначен для изменения ОКАТО', ;
    'г. Волжский' },, ;
    'GR+/R', 'W+/R',,, 'G+/R' )
  If f_esc_enter( 'изменения ОКАТО', .t. ) 
    //
    g_use( dir_server() + 'kartote_' )
    go top
    oPb := TProgressBar():New( MaxRow(), 0, 20, 0, kartote_->( LastRec() ) )
    oPb:Symbol := Chr( 219 )
    oPb:Display()
    do while !eof()
      ++i_kart
      oPb:Update( i_kart )
      if kartote_->okatog == '18410560000'
        // меняем   
        kartote_->( g_rlock( forever ) )
        kartote_->okatog := '18410000000'
        Unlock All
      endif
      if kartote_->okatop == '18410560000'
        // меняем   
        kartote_->( g_rlock( forever ) ) 
        kartote_->okatop := '18410000000'
        Unlock All
      endif
      skip
    enddo
    oPb := nil
    n_message( { 'Изменение ОКАТО произведено ' },, 'W/RB', 'BG+/RB',,, 'G+/RB' )
  Endif
  Close databases
  Return Nil

// 08.01.17
Function f_import( k )

  Static si1 := 1, sds := 1, ssp := 1
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 1
  If AScan( kod_LIS(), glob_mo[ _MO_KOD_TFOMS ] ) > 0 // КДП-2
    import_from_lis()
  Else
    Do Case
    Case k == 1
      mas_pmt := { "Импорт ~случаев ОМС", ;
        "Инте~грация с SDS", ;
        "Импорт из ~флюоротеки" }
      mas_msg := { "Импорт случаев ОМС (листов учёта) из других программ (в формате ЧИП плюс)", ;
        "Интеграция с программой Smart Delta Systems", ;
        'Импорт данных из программы "Флюоротека" фирмы "ЧИП плюс"' }
      mas_fun := { "f_import(11)", ;
        "f_import(12)", ;
        "f_import(13)" }
      popup_prompt( T_ROW, T_COL + 5, si1, mas_pmt, mas_msg, mas_fun )
    Case k == 11
      import_sluch_oms()
    Case k == 12
      integration_sds()
    Case k == 13
      import_fluoroteka()
    Endcase
  Endif
  If k > 10
    If Between( k, 11, 19 )
      si1 := Int( Val( Right( lstr( k ), 1 ) ) )
    Endif
  Endif

  Return Nil

// 10.09.25
Function import_from_lis()

  Local full_o79
  Private p_var_manager := "Read_from_LIS", cFileProtokol := "protokol.txt"

  full_o79 := manager( T_ROW, T_COL + 5, MaxRow() -2,, .t., 1,,,, "*.?79" )
  If !Empty( full_o79 ) .and. hb_FileExists( full_o79 )
    Delete File ( cur_dir() + cFileProtokol )
    g_splus( f_name_task( X_OMS ) ) // плюс 1 пользователь зашёл в задачу ОМС
    If g_sislock( sem_vagno_task()[ X_OMS ] )
      f_err_sem_vagno_task( X_OMS )
    Elseif Lower( Right( full_o79, 3 ) ) == "x79" // XML-файл
      f1_impxml_from_lis( full_o79 )
    Elseif Lower( Right( full_o79, 3 ) ) == "o79" // текстовый файл с разделителями
      f1_import_from_lis( full_o79 )
    Endif
    g_sminus( f_name_task( X_OMS ) )  // минус 1 пользователь (вышел из задачи ОМС)
    If hb_FileExists( cur_dir() + cFileProtokol )
      viewtext( devide_into_pages( cur_dir() + cFileProtokol, 60, 80 ),,,, .t.,,, 2 )
    Endif
  Endif

  Return Nil

// 12.09.23
Function f1_impxml_from_lis( name_file )

  Local buf := save_maxrow(), aerr := {}, arr, fl_exit := .f., fl := .f., i, j, t1, t2, s, s1

  If !hb_FileExists( dir_server() + "mo_flis" + sdbf() )
    dbCreate( dir_server() + "mo_flis", { ; // Список принятых файлов из ЛИС
      { "KOD",         "N", 6, 0 }, ; // код;номер записи
      { "FNAME",       "C", 50, 0 }, ; // имя файла
      { "DREAD",       "D", 8, 0 }, ; // дата чтения
      { "TREAD1",      "C", 5, 0 }, ; // время начала чтения
      { "TREAD2",      "C", 5, 0 }, ; // время окончания чтения
      { "KOLP",        "N", 6, 0 }, ; // количество пациентов
      { "KOLS",        "N", 6, 0 }, ; // количество случаев
      { "KOLU",        "N", 6, 0 };  // количество услуг
    } )
  Endif
  sname := strippath( name_file )
  g_use( dir_server() + "mo_flis",, "FL" )
  Index On Upper( fname ) To tmp_fl
  find ( PadR( Upper( sname ), 50 ) )
  If Found()
    If Empty( fl->tread2 )
      fl := f_alert( { 'Файл "' + AllTrim( sname ) + '".', ;
        "Чтение начато " + date_8( fl->dread ) + " в " + fl->tread1 + " и не было завершено.", ;
        "", ;
        "Выберите действие:" }, ;
        { " Выход ", " Попытка повторного чтения " }, ;
        1, "GR+/R", "W+/R",,, "GR+/R,N/BG" ) == 2
    Else
      func_error( 4, "Файл " + AllTrim( sname ) + " уже был прочитан " + date_8( fl->dread ) + " в " + fl->tread2 )
    Endif
  Else
    fl := .t.
  Endif
  If fl .and. f_esc_enter( "чтения файла из ЛИС" )
    Select FL
    g_rlock( !Found(), forever ) // добавить ИЛИ заблокировать запись
    fl->KOD := RecNo()
    fl->FNAME := Upper( sname )
    fl->DREAD := sys_date
    fl->TREAD1 := hour_min( Seconds() )
    fl->TREAD2 := ""
    fl->KOLP := fl->KOLS := fl->KOLU := 0
    Unlock
    Commit
    //
    t1 := Seconds()
    @ MaxRow(), 0 Say PadL( sname, 80 ) Color "W/R"
    r_use( dir_exe() + "_mo_mkb", cur_dir() + "_mo_mkb", "MKB_10" )
    use_base( "lusl" )
    use_base( "luslc" )
    use_base( "uslugi" )
    r_use( dir_exe() + "_mo_prof", cur_dir() + "_mo_prof", "MOPROF" )
    r_use( dir_server() + "uslugi1", { dir_server() + "uslugi1", ;
      dir_server() + "uslugi1s" }, "USL1" )
    // R_Use(dir_exe()+"_mo_N012",,"N12")
    g_use( dir_server() + "mo_onkco", dir_server() + "mo_onkco", "CO" )
    g_use( dir_server() + "mo_onksl", dir_server() + "mo_onksl", "SL" )
    g_use( dir_server() + "mo_onkdi", dir_server() + "mo_onkdi", "DIAG" ) // Диагностический блок
    g_use( dir_server() + "human_u_",, "HU_" )
    Index On PadR( zf, 30 ) to ( cur_dir() + "tmp_hu_" ) progress
    Set Order To 0
    g_use( dir_server() + "human_u", { dir_server() + "human_u", ;
      dir_server() + "human_uk", ;
      dir_server() + "human_ud", ;
      dir_server() + "human_uv", ;
      dir_server() + "human_ua" }, "HU" )
    g_use( dir_server() + "human_",, "HUMAN_" )
    g_use( dir_server() + "human_2",, "HUMAN_2" )
    // index on str(pn3,10) to (cur_dir() + "tmp_human2") progress
    g_use( dir_server() + "human", { dir_server() + "humank", ;
      dir_server() + "humankk", ;
      dir_server() + "humann", ;
      dir_server() + "humand", ;
      dir_server() + "humano", ;
      dir_server() + "humans" }, "HUMAN" )
    g_use( dir_server() + "mo_pers",, "PERSO" )
    Index On snils to ( cur_dir() + "tmp_pers" )
    Set Index to ( cur_dir() + "tmp_pers" ), ( dir_server() + "mo_pers" )
    g_use( dir_server() + "mo_kfio",, "KFIO" )
    Index On Str( kod, 7 ) to ( cur_dir() + "tmp_kfio" )
    g_use( dir_server() + "mo_kismo",, "KSN" )
    Index On Str( kod, 7 ) to ( cur_dir() + "tmpkismo" )
    g_use( dir_server() + "mo_hismo",, "HSN" )
    Index On Str( kod, 7 ) to ( cur_dir() + "tmphismo" )
    g_use( dir_server() + "kartote_",, "KART_" )
    g_use( dir_server() + "kartote2",, "KART2" )
    Index On kod_AK to ( cur_dir() + "tmp_kart2" ) progress
    g_use( dir_server() + "kartotek", { dir_server() + "kartotek", ;
      dir_server() + "kartoten", ;
      dir_server() + "kartotep", ;
      dir_server() + "kartoteu", ;
      dir_server() + "kartotes" }, "KART" )
    Private such := 1, sotd := 1, ; // код отделения "Лаборатория-ЛИС на Ангарском"
    sotd2 := 3 // код отделения "ЛИС в Краснооктябрьском р-не"
    // sotd4 := 4   // код отделения "ЛИС на Елецкой"
    Private _arr_otd := { { "MIH", 1 }, { "ANG", 2 }, { "MET", 3 }, { "ELE", 4 } }
    For i := 1 To Len( _arr_otd )
      If _arr_otd[ i, 1 ] $ Upper( name_file )
        sotd2 := i
        Exit
      Endif
    Next
    dbCreate( "ttmp", { ;
      { "nn", "N", 6, 0 }, ;
      { "ko", "N", 6, 0 }, ;
      { "ko1", "N", 6, 0 }, ;
      { "ku", "N", 6, 0 }, ;
      { "ku1", "N", 6, 0 }, ;
      { "t2", "N", 7, 3 }, ;
      { "t3", "N", 7, 3 }, ;
      { "t4", "N", 7, 3 }, ;
      { "fc", "C", 1, 0 } } )
    Use ttmp New Alias TMP
    Private arr_pac[ 15 ], arr_order, arr_usl := {}, ip := 0, is := 0, isp := 0, iu := 0
    glob_podr := "" ; glob_otd_dep := 0
    fl_exit := .f.
    // читаем XML-файл
    lfp := FOpen( name_file )
    Do While !feof( lfp )
      s := utf82oem( freadln( lfp ) )
      If "<PAT " $ s
        arr := { s }
        Do While !feof( lfp )
          s := freadln( lfp )
          AAdd( arr, s )
          If "</PAT>" $ s
            Exit
          Endif
        Enddo
        If !Empty( aerr := f2_impxml_from_lis( arr ) )
          fl_exit := .t.
          Exit
        Endif
      Endif
      If Inkey() == K_ESC
        fl_exit := .t.
        Exit
      Endif
    Enddo
    FClose( lfp )
    If !fl_exit
      Select FL
      g_rlock( forever ) // заблокировать запись
      fl->TREAD2 := hour_min( Seconds() )
      fl->KOLP := ip
      fl->KOLS := is
      fl->KOLU := iu
    Endif
    dbUnlockAll()
    dbCommitAll()
    Close databases
    Keyboard ""
    t2 := Seconds() - t1
    rest_box( buf )
    If fl_exit
      arr := AClone( aerr )
      If !Empty( arr )
        ins_array( arr, 1, 'Ошибка в файле "' + AllTrim( sname ) + '":' )
      Endif
      AAdd( arr, "" )
      AAdd( arr, "Операция импорта прервана!" )
    Else
      arr := { 'Файл "' + AllTrim( sname ) + '" импортирован.', ;
        "", ;
        "Время работы - " + SecToTime( t2 ) + ".", ;
        "", ;
        "Пациентов " + lstr( ip ) + ", случаев " + lstr( is ) + iif( isp == 0, "", " (в т.ч.повторно " + lstr( isp ) + ")" ) + ", услуг " + lstr( iu ) + "." }
    Endif
    n_message( arr,, "GR+/R", "W+/R",,, "G+/R" )
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 03.05.17
Function f1_import_from_lis( name_file )

  Local buf := save_maxrow(), aerr := {}, arr, fl_exit, fl := .f., i, j, t1, t2, s, s1, iencode

  If !hb_FileExists( dir_server() + "mo_flis" + sdbf() )
    dbCreate( dir_server() + "mo_flis", { ; // Список принятых файлов из ЛИС
      { "KOD",         "N", 6, 0 }, ; // код;номер записи
      { "FNAME",       "C", 50, 0 }, ; // имя файла
      { "DREAD",       "D", 8, 0 }, ; // дата чтения
      { "TREAD1",      "C", 5, 0 }, ; // время начала чтения
      { "TREAD2",      "C", 5, 0 }, ; // время окончания чтения
      { "KOLP",        "N", 6, 0 }, ; // количество пациентов
      { "KOLS",        "N", 6, 0 }, ; // количество случаев
      { "KOLU",        "N", 6, 0 };  // количество услуг
    } )
  Endif
  sname := strippath( name_file )
  g_use( dir_server() + "mo_flis",, "FL" )
  Index On Upper( fname ) To tmp_fl
  find ( PadR( Upper( sname ), 50 ) )
  If Found()
    If Empty( fl->tread2 )
      fl := f_alert( { 'Файл "' + AllTrim( sname ) + '".', ;
        "Чтение начато " + date_8( fl->dread ) + " в " + fl->tread1 + " и не было завершено.", ;
        "", ;
        "Выберите действие:" }, ;
        { " Выход ", " Попытка повторного чтения " }, ;
        1, "GR+/R", "W+/R",,, "GR+/R,N/BG" ) == 2
    Else
      func_error( 4, "Файл " + AllTrim( sname ) + " уже был прочитан " + date_8( fl->dread ) + " в " + fl->tread2 )
    Endif
  Else
    fl := .t.
  Endif
  If fl .and. f_esc_enter( "чтения файла из ЛИС" ) .and. ( iencode := f_define_lis_coding( name_file ) ) > 0
    g_rlock( !Found(), forever ) // добавить ИЛИ заблокировать запись
    fl->KOD := RecNo()
    fl->FNAME := Upper( sname )
    fl->DREAD := sys_date
    fl->TREAD1 := hour_min( Seconds() )
    fl->TREAD2 := ""
    fl->KOLP := fl->KOLS := fl->KOLU := 0
    Unlock
    Commit
    //
    t1 := Seconds()
    @ MaxRow(), 0 Say PadL( sname, 80 ) Color "W/R"
    r_use( dir_exe() + "_mo_mkb", cur_dir() + "_mo_mkb", "MKB_10" )
    use_base( "lusl" )
    use_base( "luslc" )
    use_base( "uslugi" )
    r_use( dir_exe() + "_mo_prof", cur_dir() + "_mo_prof", "MOPROF" )
    r_use( dir_server() + "uslugi1", { dir_server() + "uslugi1", ;
      dir_server() + "uslugi1s" }, "USL1" )
    use_base( "human_u" )
    g_use( dir_server() + "human_",, "HUMAN_" )
    g_use( dir_server() + "human_2",, "HUMAN_2" )
    Index On Str( pn3, 10 ) to ( cur_dir() + "tmp_human2" )
    g_use( dir_server() + "human", { dir_server() + "humank", ;
      dir_server() + "humankk", ;
      dir_server() + "humann", ;
      dir_server() + "humand", ;
      dir_server() + "humano", ;
      dir_server() + "humans" }, "HUMAN" )
    g_use( dir_server() + "mo_pers",, "PERSO" )
    Index On snils to ( cur_dir() + "tmp_pers" )
    Set Index to ( cur_dir() + "tmp_pers" ), ( dir_server() + "mo_pers" )
    g_use( dir_server() + "mo_kfio",, "KFIO" )
    Index On Str( kod, 7 ) to ( cur_dir() + "tmp_kfio" )
    g_use( dir_server() + "mo_kismo",, "KSN" )
    Index On Str( kod, 7 ) to ( cur_dir() + "tmpkismo" )
    g_use( dir_server() + "mo_hismo",, "HSN" )
    Index On Str( kod, 7 ) to ( cur_dir() + "tmphismo" )
    g_use( dir_server() + "kartote_",, "KART_" )
    g_use( dir_server() + "kartote2",, "KART2" )
    Index On kod_AK to ( cur_dir() + "tmp_kart2" )
    g_use( dir_server() + "kartotek", { dir_server() + "kartotek", ;
      dir_server() + "kartoten", ;
      dir_server() + "kartotep", ;
      dir_server() + "kartoteu", ;
      dir_server() + "kartotes" }, "KART" )
    Private such := 1, sotd := 1 // код отделения "Лаборатория-ЛИС на Ангарском"
    If Left( fl->FNAME, 4 ) == "LAB2"
      sotd := 3 // код отделения "ЛИС в Краснооктябрьском р-не"
    Endif
    Private arr_pac := {}, arr_order := {}, arr_usl := {}, ip := 0, is := 0, isp := 0, iu := 0
    glob_podr := "" ; glob_otd_dep := 0
    fl_exit := .f.
    ft_use( name_file )
    ft_gotop()
    Do While !ft_eof()
      If !Empty( s := ft_readln() )
        If iencode == 1
          s := hb_ANSIToOEM( s )
        Else
          s := utf82oem( s )
        Endif
        If Upper( Left( s, 3 ) ) == "PAT"
          If !Empty( arr_pac )
            If !Empty( aerr := f2_import_from_lis( 1 ) )
              fl_exit := .t.
              Exit
            Endif
            arr_pac := {}
            arr_order := {}
          Endif
          For i := 2 To NumToken( s, ";", 1 )
            s1 := AllTrim( Token( s, ";", i, 1 ) )
            AAdd( arr_pac, s1 )
          Next
          Do While Len( arr_pac ) < 15 // добавим пустые поля (вдруг что-то не так со строкой)
            AAdd( arr_pac, " " )
          Enddo
        Elseif Upper( Left( s, 5 ) ) == "ORDER"
          AAdd( arr_order, {} ) ; j := Len( arr_order )
          For i := 2 To NumToken( s, ";", 1 )
            s1 := AllTrim( Token( s, ";", i, 1 ) )
            AAdd( arr_order[ j ], s1 )
          Next
          Do While Len( arr_order[ j ] ) < 6 // 5 И 6 ЭЛЕМЕНТЫ ДЛЯ СРОКОВ ЛЕЧЕНИЯ
            AAdd( arr_order[ j ], " " )
          Enddo
          arr_order[ j, 4 ] := {} // для занесения услуг
        Elseif Upper( Left( s, 4 ) ) == "EXAM" .and. Len( arr_order ) > 0
          arr := {}
          For i := 2 To NumToken( s, ";", 1 )
            s1 := AllTrim( Token( s, ";", i, 1 ) )
            AAdd( arr, s1 )
          Next
          Do While Len( arr ) < 7
            AAdd( arr, " " )
          Enddo
          AAdd( arr_order[ j, 4 ], AClone( arr ) )
        Endif
      Endif
      ft_skip()
    Enddo
    ft_use()
    If !fl_exit .and. !Empty( arr_pac ) .and. !Empty( aerr := f2_import_from_lis( 1 ) )
      fl_exit := .t.
    Endif
    If !fl_exit
      Select FL
      g_rlock( forever ) // заблокировать запись
      fl->TREAD2 := hour_min( Seconds() )
      fl->KOLP := ip
      fl->KOLS := is
      fl->KOLU := iu
    Endif
    dbUnlockAll()
    dbCommitAll()
    Close databases
    t2 := Seconds() - t1
    rest_box( buf )
    If fl_exit
      arr := AClone( aerr )
      ins_array( arr, 1, 'Ошибка в файле "' + AllTrim( sname ) + '":' )
      AAdd( arr, "" )
      AAdd( arr, "Операция импорта прервана!" )
    Else
      arr := { 'Файл "' + AllTrim( sname ) + '" импортирован.', ;
        "", ;
        "Время работы - " + SecToTime( t2 ) + ".", ;
        "", ;
        "Пациентов " + lstr( ip ) + ", случаев " + lstr( is ) + iif( isp == 0, "", " (в т.ч.повторно " + lstr( isp ) + ")" ) + ", услуг " + lstr( iu ) + "." }
    Endif
    n_message( arr,, "GR+/R", "W+/R",,, "G+/R" )
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 02.01.17
Static Function utf82oem( s )
  Return hb_UTF8ToStr( s, "RU866" )

#define LIS_KOD_AK     1
#define LIS_FAM        2
#define LIS_IMA        3
#define LIS_OTS        4
#define LIS_DATE_R     5
#define LIS_POL        6
#define LIS_VPOLIS     7
#define LIS_SPOLIS     8
#define LIS_NPOLIS     9
#define LIS_OKATO     10
#define LIS_VID_UD    11
#define LIS_SER_UD    12
#define LIS_NOM_UD    13
#define LIS_MESTO_R   14
#define LIS_SNILS     15
//
#define LISS_KOD       1
#define LISS_DIAG      2
#define LISS_MO        3
#define LISS_USL       4
#define LISS_NDATA     5
#define LISS_KDATA     6
#define LISS_OTD       7
//
#define LISU_SHIFR     1
#define LISU_DATE      2
#define LISU_SPEC      3
#define LISU_SNILS     4
#define LISU_KODU      5
#define LISU_CENA      6
#define LISU_UNIT      7
#define LISU_ID        8
#define LISU_D_RSLT    9

// 28.04.20
Function f2_impxml_from_lis( ta )

  Static arr[ LISU_D_RSLT ]
  Local i, j := 1, s

  s := AfterAtNum( 'Pat_code="', ta[ 1 ] ) ; arr_pac[ LIS_KOD_AK ] := BeforAtNum( '"', s, 1 )
  s := AfterAtNum( 'Last_name="', s )    ; arr_pac[ LIS_FAM    ] := BeforAtNum( '"', s, 1 )
  s := AfterAtNum( 'First_name="', s )   ; arr_pac[ LIS_IMA    ] := BeforAtNum( '"', s, 1 )
  s := AfterAtNum( 'Father_name="', s )  ; arr_pac[ LIS_OTS    ] := BeforAtNum( '"', s, 1 )
  s := AfterAtNum( 'Birth_date="', s )   ; arr_pac[ LIS_DATE_R ] := BeforAtNum( '"', s, 1 )
  s := AfterAtNum( 'Sex="', s )          ; arr_pac[ LIS_POL    ] := BeforAtNum( '"', s, 1 )
  s := AfterAtNum( 'OMS_type="', s )     ; arr_pac[ LIS_VPOLIS ] := BeforAtNum( '"', s, 1 )
  s := AfterAtNum( 'OMS_series="', s )   ; arr_pac[ LIS_SPOLIS ] := BeforAtNum( '"', s, 1 )
  s := AfterAtNum( 'OMS_number="', s )   ; arr_pac[ LIS_NPOLIS ] := BeforAtNum( '"', s, 1 )
  s := AfterAtNum( 'Ins_OKATO="', s )    ; arr_pac[ LIS_OKATO  ] := BeforAtNum( '"', s, 1 )
  s := AfterAtNum( 'UDL_type="', s )     ; arr_pac[ LIS_VID_UD ] := BeforAtNum( '"', s, 1 )
  s := AfterAtNum( 'UDL_series="', s )   ; arr_pac[ LIS_SER_UD ] := BeforAtNum( '"', s, 1 )
  s := AfterAtNum( 'UDL_number="', s )   ; arr_pac[ LIS_NOM_UD ] := BeforAtNum( '"', s, 1 )
  s := AfterAtNum( 'Birth_place="', s )  ; arr_pac[ LIS_MESTO_R ] := BeforAtNum( '"', s, 1 )
  s := AfterAtNum( 'SNILS="', s )        ; arr_pac[ LIS_SNILS  ] := BeforAtNum( '"', s, 1 )
  arr_order := {}
  For i := 2 To Len( ta )
    ta[ i ] := LTrim( ta[ i ] )
    If Left( ta[ i ], 7 ) == "<ORDER "
      AAdd( arr_order, {} ) ; j := Len( arr_order )
      s := AfterAtNum( 'Number="', ta[ i ] )  ; AAdd( arr_order[ j ], BeforAtNum( '"', s, 1 ) )
      s := AfterAtNum( 'DS="', s )          ; AAdd( arr_order[ j ], BeforAtNum( '"', s, 1 ) )
      s := AfterAtNum( 'Sender_code="', s ) ; AAdd( arr_order[ j ], BeforAtNum( '"', s, 1 ) )
      AAdd( arr_order[ j ], {} ) // для занесения услуг
      AAdd( arr_order[ j ], " " ) // 5 И 6 ЭЛЕМЕНТЫ ДЛЯ СРОКОВ ЛЕЧЕНИЯ
      AAdd( arr_order[ j ], " " )
      AAdd( arr_order[ j ], sotd )
    Endif
    If Left( ta[ i ], 6 ) == "<EXAM "
      AFill( arr, "" )
      s := AfterAtNum( 'ExamID="', ta[ i ] ) ; arr[ LISU_ID   ] := BeforAtNum( '"', s, 1 )
      s := AfterAtNum( 'Exam_code="', s )  ; arr[ LISU_SHIFR ] := BeforAtNum( '"', s, 1 )
      s := AfterAtNum( 'Exec_date="', s )  ; arr[ LISU_DATE ] := BeforAtNum( '"', s, 1 )
      s := AfterAtNum( 'Doc_spec="', s )   ; arr[ LISU_SPEC ] := BeforAtNum( '"', s, 1 )
      s := AfterAtNum( 'Doc_SNILS="', s )  ; arr[ LISU_SNILS ] := BeforAtNum( '"', s, 1 )
      If 'Diag_rslt' $ s
        s := AfterAtNum( 'Diag_rslt="', s ) ; arr[ LISU_D_RSLT ] := BeforAtNum( '"', s, 1 )
      Endif
      If j <= Len( arr_order )
        AAdd( arr_order[ j, 4 ], AClone( arr ) )
      Endif
    Endif
  Next j

  Return f2_import_from_lis( 2 )

// 28.04.20
Function f2_import_from_lis( par )

  Static siu := 0, jsiu := 0
  Local i, j, k, fl, afio[ 3 ], mfio, aerr := {}, tmp_arr := {}, arr_unit, lvzros_reb, i_738, i_739
  Local t1, t2, t3, t4, ku := 0, ku1 := 0, is_mgi, ko := Len( arr_order )

  t1 := Seconds()
  ++ip
  afio[ 1 ] := f_lis_fio( arr_pac[ LIS_FAM ], 1 )
  afio[ 2 ] := f_lis_fio( arr_pac[ LIS_IMA ], 2 )
  afio[ 3 ] := f_lis_fio( arr_pac[ LIS_OTS ], 3 )
  mfio := afio[ 1 ] + " " + afio[ 2 ] + " " + afio[ 3 ]
  If Empty( Int( Val( arr_pac[ LIS_KOD_AK ] ) ) )
    AAdd( aerr, "Некорректный код PAT у пациента - " + mfio )
    Return aerr
  Endif
  If !val_fio( afio, aerr )
    AAdd( aerr, "PAT=" + arr_pac[ LIS_KOD_AK ] + ' "' + mfio + '"' )
    Return aerr
  Endif
  arr_pac[ LIS_DATE_R ] := CToD( arr_pac[ LIS_DATE_R ] )
  If Empty( arr_pac[ LIS_DATE_R ] )
    AAdd( aerr, "Некорректная дата рождения у пациента" )
    AAdd( aerr, "PAT=" + arr_pac[ LIS_KOD_AK ] + ' "' + mfio + '"' )
    Return aerr
  Endif
  arr_pac[ LIS_POL ] := iif( arr_pac[ LIS_POL ] == "M", "М", "Ж" )
  f_lis_polis()
  f_lis_pasport()
  arr_pac[ LIS_SNILS ] := CharRem( "- ", arr_pac[ LIS_SNILS ] )
  For j := 1 To Len( arr_order )
    arr_order[ j, LISS_KOD ] := Int( Val( arr_order[ j, LISS_KOD ] ) )
    If Empty( arr_order[ j, LISS_KOD ] )
      AAdd( aerr, "Некорректный ORDER у пациента" )
      AAdd( aerr, "PAT=" + arr_pac[ LIS_KOD_AK ] + ' "' + mfio + '"' )
      Return aerr
    Endif
    If Empty( arr_order[ j, LISS_MO ] )
      AAdd( aerr, "Не заполнена направляющая мед.организация у пациента" )
      AAdd( aerr, "PAT=" + arr_pac[ LIS_KOD_AK ] + ' "' + mfio + '" (ORDER=' + lstr( arr_order[ j, LISS_KOD ] ) + ')' )
      Return aerr
    Elseif ( i := AScan( glob_arr_mo(), {| x| x[ _MO_KOD_FFOMS ] == arr_order[ j, LISS_MO ] } ) ) == 0
      AAdd( aerr, "В справочнике МО не найдена направляющая мед.организация " + arr_order[ j, LISS_MO ] + " у пациента" )
      AAdd( aerr, "PAT=" + arr_pac[ LIS_KOD_AK ] + ' "' + mfio + '" (ORDER=' + lstr( arr_order[ j, LISS_KOD ] ) + ')' )
      Return aerr
    Else
      arr_order[ j, LISS_MO ] := ret_mo( arr_order[ j, LISS_MO ] )[ _MO_KOD_TFOMS ]
    Endif
    // asort(arr_order[j,LISS_USL],,,{|x,y| iif(x[2] == y[2], fsort_usl(x[1]) < fsort_usl(y[1]), x[2] < y[2])})
    i_738 := i_739 := 0
    If Len( arr_order[ j, LISS_USL ] ) == 0
      AAdd( aerr, "Не введены услуги у пациента" )
      AAdd( aerr, "PAT=" + arr_pac[ LIS_KOD_AK ] + ' "' + mfio + '" (ORDER=' + lstr( arr_order[ j, LISS_KOD ] ) + ')' )
      Return aerr
    Endif
    For i := 1 To Len( arr_order[ j, LISS_USL ] )
      ++iu
      ++ku
      If Empty( arr_order[ j, LISS_USL, i, LISU_SHIFR ] )
        AAdd( aerr, "Не введена услуга у пациента" )
        AAdd( aerr, "PAT=" + arr_pac[ LIS_KOD_AK ] + ' "' + mfio + '" (ORDER=' + lstr( arr_order[ j, LISS_KOD ] ) + ')' )
        Return aerr
      Endif
      If par == 2 // по-новому / из XML-файла / ключевое поле - ID услуги
        If Empty( arr_order[ j, LISS_USL, i, LISU_ID ] )
          AAdd( aerr, "Некорректное значение ExamID в услуге " + arr_order[ j, LISS_USL, i, LISU_SHIFR ] + " у пациента" )
          AAdd( aerr, "PAT=" + arr_pac[ LIS_KOD_AK ] + ' "' + mfio + '" (ORDER=' + lstr( arr_order[ j, LISS_KOD ] ) + ')' )
          Return aerr
        Endif
        // if eq_any(left(arr_order[j,LISS_USL,i,LISU_SHIFR],5),"4.16.","4.17.")
        // arr_order[j,LISS_OTD] := sotd2 // код отделения в Краснооктябрьском р-не
        // endif
      Endif
      Select LUSL
      find ( PadR( arr_order[ j, LISS_USL, i, LISU_SHIFR ], 10 ) )
      If Found()
        arr_order[ j, LISS_USL, i, LISU_UNIT ] := lusl->unit_code
      Else
        AAdd( aerr, "В справочнике не найдена услуга " + arr_order[ j, LISS_USL, i, LISU_SHIFR ] + " у пациента" )
        AAdd( aerr, "PAT=" + arr_pac[ LIS_KOD_AK ] + ' "' + mfio + '" (ORDER=' + lstr( arr_order[ j, LISS_KOD ] ) + ')' )
        Return aerr
      Endif
      If Left( arr_order[ j, LISS_USL, i, LISU_SHIFR ], 5 ) == "60.9." .and. !( Left( arr_order[ j, LISS_DIAG ], 1 ) == "C" )
        AAdd( aerr, "Для МГИ диагноз должен быыть ОНКОЛОГИЯ у пациента" )
        AAdd( aerr, "PAT=" + arr_pac[ LIS_KOD_AK ] + ' "' + mfio + '" (ORDER=' + lstr( arr_order[ j, LISS_KOD ] ) + ')' )
        Return aerr
      Endif
      If arr_order[ j, LISS_USL, i, LISU_SHIFR ] == "4.11.738"
        i_738 := i
      Elseif arr_order[ j, LISS_USL, i, LISU_SHIFR ] == "4.11.739"
        i_739 := i
      Endif
      arr_order[ j, LISS_USL, i, LISU_DATE ] := CToD( arr_order[ j, LISS_USL, i, LISU_DATE ] )
      If Empty( arr_order[ j, LISS_USL, i, LISU_DATE ] )
        AAdd( aerr, "Некорректная дата услуги у пациента" )
        AAdd( aerr, "PAT=" + arr_pac[ LIS_KOD_AK ] + ' "' + mfio + '" (ORDER=' + lstr( arr_order[ j, LISS_KOD ] ) + ')' )
        Return aerr
      Endif
      If Empty( arr_order[ j, LISS_NDATA ] )
        arr_order[ j, LISS_NDATA ] := arr_order[ j, LISS_KDATA ] := arr_order[ j, LISS_USL, i, LISU_DATE ]
      Else
        arr_order[ j, LISS_NDATA ] := Min( arr_order[ j, LISS_NDATA ], arr_order[ j, LISS_USL, i, LISU_DATE ] )
        arr_order[ j, LISS_KDATA ] := Max( arr_order[ j, LISS_KDATA ], arr_order[ j, LISS_USL, i, LISU_DATE ] )
      Endif
      arr_order[ j, LISS_USL, i, LISU_SPEC ] := Int( Val( arr_order[ j, LISS_USL, i, LISU_SPEC ] ) )
      If AScan( getv004(), {| x| x[ 2 ] == arr_order[ j, LISS_USL, i, LISU_SPEC ] } ) == 0
        arr_order[ j, LISS_USL, i, LISU_SPEC ] := 1107 // Клиническая лабораторная диагностика
      Endif
      arr_order[ j, LISS_USL, i, LISU_SNILS ] := CharRem( "- ", arr_order[ j, LISS_USL, i, LISU_SNILS ] )
      If Empty( arr_order[ j, LISS_USL, i, LISU_SNILS ] )
        arr_order[ j, LISS_USL, i, LISU_SNILS ] := 0
      Else
        Select PERSO
        Set Order To 1
        find ( PadR( arr_order[ j, LISS_USL, i, LISU_SNILS ], 11 ) )
        If !Found()
          Set Order To 2
          addrec( 5 )
          perso->kod := RecNo()
          perso->tab_nom := -perso->kod
          perso->fio  := "Сотрудник с кодом " + lstr( perso->kod )
          perso->uch  := such
          perso->otd  := sotd2
          // if par == 1
          // perso->otd := sotd
          // else
          // perso->otd := arr_order[j,LISS_OTD]
          // endif
          perso->prvs := arr_order[ j, LISS_USL, i, LISU_SPEC ]
          perso->snils := arr_order[ j, LISS_USL, i, LISU_SNILS ]
        Endif
        arr_order[ j, LISS_USL, i, LISU_SPEC ] := perso->prvs
        arr_order[ j, LISS_USL, i, LISU_SNILS ] := perso->kod
      Endif
    Next i
    If i_738 > 0 .and. i_739 > 0 // если встречаются в одном случае "4.11.738" и "4.11.739"
      del_array( arr_order[ j, LISS_USL ], i_738 ) // то удаляем "4.11.738" (она дешевле)
    Endif
  Next
  t2 := Seconds()
  Private mdate_r, m1vzros_reb := 0, M1NOVOR := 0, mprofil
  Select KART2
  Set Order To 1
  find ( PadR( arr_pac[ LIS_KOD_AK ], 10 ) )
  If Found()
    lkod_k := RecNo()
    Select KART
    Set Order To 0
    Goto ( lkod_k )
    Select KART_
    Goto ( lkod_k )
  Else
    Select KART
    Set Order To 1
    add1rec( 7 )
    lkod_k := kart->kod := RecNo()
    kart->FIO := mfio
    kart->DATE_R := arr_pac[ LIS_DATE_R ]
    kart->PC3 := '000'
    mdate_r := kart->DATE_R
    fv_date_r()
    kart->pol := arr_pac[ LIS_POL ]
    kart->VZROS_REB := m1VZROS_REB
    kart->POLIS := make_polis( arr_pac[ LIS_SPOLIS ], arr_pac[ LIS_NPOLIS ] )
    kart->snils := arr_pac[ LIS_SNILS ]
    If twowordfamimot( afio[ 1 ] ) .or. twowordfamimot( afio[ 2 ] ) .or. twowordfamimot( afio[ 3 ] )
      kart->MEST_INOG := 9
    Else
      kart->MEST_INOG := 0
    Endif
    //
    dbf_equalization( "KART_", lkod_k )
    kart_->VPOLIS := arr_pac[ LIS_VPOLIS ]
    kart_->SPOLIS := arr_pac[ LIS_SPOLIS ]
    kart_->NPOLIS := arr_pac[ LIS_NPOLIS ]
    kart_->vid_ud := arr_pac[ LIS_VID_UD ]
    kart_->ser_ud := arr_pac[ LIS_SER_UD ]
    kart_->nom_ud := arr_pac[ LIS_NOM_UD ]
    kart_->mesto_r := arr_pac[ LIS_MESTO_R ]
    kart_->okatog := arr_pac[ LIS_OKATO ]
    kart_->okatop := kart_->okatog
    If Left( kart_->okatog, 2 ) == "18" // Волгоградская область
      kart_->SMO := "34007" // ООО "РГС-Медицина"
    Else
      kart_->SMO := "34"    // ТФОМС
      kart_->KVARTAL_D := Left( kart_->okatog, 5 ) // ОКАТО субъекта РФ территории страхования
    Endif
    //
    Select KART2
    Set Order To 0
    dbf_equalization( "KART2", lkod_k )
    kart2->kod_tf := 0
    kart2->kod_mis := ""
    kart2->kod_AK := arr_pac[ LIS_KOD_AK ]  // ключевое поле !!!
    kart2->MO_PR := ""
    kart2->TIP_PR := 0
    kart2->DATE_PR := CToD( "" )
    kart2->SNILS_VR := "" // уч.врач ещё не привязан
    kart2->PC1 := kod_polzovat + c4sys_date + hour_min( Seconds() )
    kart2->PC2 := ""
    kart2->PC3 := ""
    kart2->PC4 := ""
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
  Endif
  If par == 1 // по-старому / из текстового файла / ключевое поле - номер наряда-заказа
    For j := 1 To Len( arr_order )
      Select HUMAN_2
      Set Order To 1
      find ( Str( arr_order[ j, LISS_KOD ], 10 ) )
      If Found()
        arr_order[ j, LISS_KOD ] := 0 // т.е. данный случай заносили
      Endif
    Next
  Endif
  For j := 1 To Len( arr_order ) // разбивка случаев по план-заказу
    arr_unit := {}
    For i := 1 To Len( arr_order[ j, LISS_USL ] )
      If AScan( arr_unit, arr_order[ j, LISS_USL, i, LISU_UNIT ] ) == 0
        AAdd( arr_unit, arr_order[ j, LISS_USL, i, LISU_UNIT ] )
      Endif
    Next
    If Len( arr_unit ) > 1
      For k := 1 To Len( arr_unit )
        If par == 1
          AAdd( tmp_arr, { arr_order[ j, 1 ], arr_order[ j, 2 ], arr_order[ j, 3 ], {}, CToD( "" ), CToD( "" ) } )
        Else
          AAdd( tmp_arr, { arr_order[ j, 1 ], arr_order[ j, 2 ], arr_order[ j, 3 ], {}, CToD( "" ), CToD( "" ), arr_order[ j, 7 ] } )
        Endif
        n := Len( tmp_arr )
        For i := 1 To Len( arr_order[ j, LISS_USL ] )
          If arr_unit[ k ] == arr_order[ j, LISS_USL, i, LISU_UNIT ]
            AAdd( tmp_arr[ n, LISS_USL ], AClone( arr_order[ j, LISS_USL, i ] ) )
            If Empty( tmp_arr[ n, LISS_NDATA ] )
              tmp_arr[ n, LISS_NDATA ] := tmp_arr[ n, LISS_KDATA ] := arr_order[ j, LISS_USL, i, LISU_DATE ]
            Else
              tmp_arr[ n, LISS_NDATA ] := Min( tmp_arr[ n, LISS_NDATA ], arr_order[ j, LISS_USL, i, LISU_DATE ] )
              tmp_arr[ n, LISS_KDATA ] := Max( tmp_arr[ n, LISS_KDATA ], arr_order[ j, LISS_USL, i, LISU_DATE ] )
            Endif
          Endif
        Next
      Next
    Else
      AAdd( tmp_arr, AClone( arr_order[ j ] ) )
    Endif
  Next
  arr_order := AClone( tmp_arr ) ; tmp_arr := nil
  t3 := Seconds()
  If par == 2 // по-новому / из XML-файла / ключевое поле - ID услуги
    Select HU_
    Set Order To 1
    For j := 1 To Len( arr_order )
      For i := 1 To Len( arr_order[ j, LISS_USL ] )
        find ( PadR( arr_order[ j, LISS_USL, i, LISU_ID ], 30 ) )
        If Found() // данную услугу уже заносили
          arr_order[ j, LISS_KOD ] := 0 // значит считаем, что данный случай также заносили
          Exit
        Endif
      Next i
    Next j
    Set Order To 0
  Endif
  Select HUMAN
  Set Order To 1
  Select HUMAN_2
  Set Order To 0
  aat := {}
  For j := 1 To Len( arr_order )
    ++is
    If arr_order[ j, LISS_KOD ] == 0 .or. Len( arr_order[ j, LISS_USL ] ) == 0
      ++isp
    Else // т.е. данный случай ещё не заносили
      lvzros_reb := 1 // ребенок по умолчанию
      If ( k := count_years( kart->DATE_R, arr_order[ j, LISS_NDATA ] ) ) < 14
        m1vzros_reb := 1  // ребенок
      Elseif k < 18
        m1vzros_reb := 2  // подросток
      Else
        lvzros_reb := m1vzros_reb := 0  // взрослый
      Endif
      mprofil := 34
      Select MOPROF
      find ( PadR( arr_order[ j, LISS_USL, 1, LISU_SHIFR ], 20 ) + Str( lvzros_reb, 1 ) )
      If Found()
        mprofil := moprof->profil
      Endif
      is_mgi := ( Left( arr_order[ j, LISS_USL, 1, LISU_SHIFR ], 5 ) == "60.9." )
      If is_mgi
        //
      Else
        arr_order[ j, LISS_DIAG ] := "Z01.7" // всегда
      Endif
      Select HUMAN
      add1rec( 7 )
      mkod := human->kod := RecNo()
      dbf_equalization( "HUMAN_", mkod )
      dbf_equalization( "HUMAN_2", mkod )
      //
      human->kod_k      := lkod_k
      human->TIP_H      := B_STANDART
      human->FIO        := kart->FIO          // Ф.И.О. больного
      human->POL        := kart->POL          // пол
      human->DATE_R     := kart->DATE_R       // дата рождения больного
      human->VZROS_REB  := M1VZROS_REB        // 0-взрослый, 1-ребенок, 2-подросток
      human->KOD_DIAG   := arr_order[ j, LISS_DIAG ]
      human->KOD_DIAG2  := human->KOD_DIAG3 := human->KOD_DIAG4 := ""
      human->SOPUT_B1   := human->SOPUT_B2 := human->SOPUT_B3 := human->SOPUT_B4 := ""
      If Len( arr_order[ j, LISS_DIAG ] ) == 6
        human->diag_plus := PadR( Right( arr_order[ j, LISS_DIAG ], 1 ), 8 )
      Endif
      human->KOMU       := 0
      human->POLIS      := kart->polis
      human->LPU        := such
      human->OTD        := sotd2
      // if par == 1
      // human->OTD      := sotd
      // else
      // human->OTD      := arr_order[j,LISS_OTD]
      // endif
      human->UCH_DOC    := lstr( arr_order[ j, LISS_KOD ] ) // ORDER по ЛИС
      human->N_DATA     := arr_order[ j, LISS_NDATA ]
      human->K_DATA     := arr_order[ j, LISS_KDATA ]
      //
      human_->SMO       := kart_->SMO
      human_->VPOLIS    := kart_->VPOLIS
      human_->SPOLIS    := kart_->SPOLIS
      human_->NPOLIS    := kart_->NPOLIS
      If AllTrim( human_->smo ) == '34'
        human_->OKATO   := kart_->KVARTAL_D
      Endif
      human_->NOVOR     := 0
      human_->DATE_R2   := CToD( "" )
      human_->POL2      := ""
      human_->USL_OK    := 3  // амбулаторно
      human_->VIDPOM    := 13 // первичная специализированная
      human_->PROFIL    := mprofil // клиническая лабораторная диагностика или бактериология
      human_->IDSP      := 4  // лечебно-диагностическая процедура
      human_->NPR_MO    := arr_order[ j, LISS_MO ]
      human_->KOD_DIAG0 := ""
      human_->RSLT_NEW  := 314 // динамическое наблюдение
      human_->ISHOD_NEW := 304 // без перемен
      human_->VRACH     := 0
      human_->PRVS      := iif( mprofil == 34, -13, -54 ) // Клиническая лабораторная диагностика
      human_->OPLATA    := 0 // уберём "2", если отредактировали запись из реестра СП и ТК
      human_->ST_VERIFY := 0 // снова ещё не проверен
      human_->ID_PAC    := mo_guid( 1, human_->( RecNo() ) )
      human_->ID_C      := mo_guid( 2, human_->( RecNo() ) )
      human_->SUMP      := 0
      human_->OPLATA    := 0
      human_->SANK_MEK  := 0
      human_->SANK_MEE  := 0
      human_->SANK_EKMP := 0
      human_->REESTR    := 0
      human_->REES_ZAP  := 0
      human->schet      := 0
      human_->SCHET_ZAP := 0
      human->kod_p   := Chr( 0 )
      human->date_e  := ''
      //
      human_2->NPR_DATE := human->N_DATA
      human_2->OSL1 := human_2->OSL2 := human_2->OSL3 := ""
      human_2->VMP := 0
      human_2->VIDVMP := ""
      human_2->METVMP := 0
      human_2->VNR := human_2->VNR1 := human_2->VNR2 := human_2->VNR3 := 0
      human_2->PC1 := human_2->PC2 := human_2->PC3 := ""
      human_2->PN1 := human_2->PN2 := 0
      human_2->PN3 := arr_order[ j, LISS_KOD ] // ключевое поле
      sstoim := 0
      For i := 1 To Len( arr_order[ j, LISS_USL ] )
        If ( n := AScan( arr_usl, {| x| x[ 1 ] == arr_order[ j, LISS_USL, i, LISU_SHIFR ] .and. x[ 4 ] == lvzros_reb } ) ) == 0
          ++ku1
          arr_order[ j, LISS_USL, i, LISU_CENA ] := 0
          arr_order[ j, LISS_USL, i, LISU_KODU ] := foundourusluga( arr_order[ j, LISS_USL, i, LISU_SHIFR ], ;
            arr_order[ j, LISS_KDATA ], ;
            mprofil, ;
            m1VZROS_REB, ;
            @arr_order[ j, LISS_USL, i, LISU_CENA ], 1, .f. )
          AAdd( arr_usl, { arr_order[ j, LISS_USL, i, LISU_SHIFR ], ;
            arr_order[ j, LISS_USL, i, LISU_KODU ], ;
            arr_order[ j, LISS_USL, i, LISU_CENA ], ;
            lvzros_reb } )
        Else
          arr_order[ j, LISS_USL, i, LISU_KODU ] := arr_usl[ n, 2 ]
          arr_order[ j, LISS_USL, i, LISU_CENA ] := arr_usl[ n, 3 ]
        Endif
        sstoim += arr_order[ j, LISS_USL, i, LISU_CENA ]
        Select HU
        add1rec( 7 )
        hu->kod     := human->kod
        hu->kod_vr  := arr_order[ j, LISS_USL, i, LISU_SNILS ]
        hu->kod_as  := 0
        hu->u_koef  := 1
        hu->u_kod   := arr_order[ j, LISS_USL, i, LISU_KODU ]
        hu->u_cena  := arr_order[ j, LISS_USL, i, LISU_CENA ]
        hu->is_edit := 0
        hu->date_u  := dtoc4( arr_order[ j, LISS_USL, i, LISU_DATE ] )
        hu->otd     := human->OTD
        hu->kol := hu->kol_1 := 1
        hu->stoim := hu->stoim_1 := arr_order[ j, LISS_USL, i, LISU_CENA ]
        hu->KOL_RCP := 0
        //
        dbf_equalization( "HU_", hu->( RecNo() ) )
        hu_->ID_U := mo_guid( 3, hu_->( RecNo() ) )
        hu_->PROFIL := human_->PROFIL
        hu_->PRVS   := arr_order[ j, LISS_USL, i, LISU_SPEC ]
        hu_->kod_diag := human->KOD_DIAG
        If par == 2 // по-новому / из XML-файла / ключевое поле - ID услуги
          hu_->zf := arr_order[ j, LISS_USL, i, LISU_ID ]
        Else
          hu_->zf := ""
        Endif
        ++siu
      Next
      human->CENA := human->CENA_1 := sstoim
      If is_mgi
        human_->VRACH := hu->kod_vr
        f_lis_mgi( human->kod, arr_order[ j ] )
      Endif
      AAdd( aat, { Seconds(), Len( arr_order[ j, LISS_USL ] ) } )
    Endif
  Next
  t4 := Seconds()
  @ MaxRow(), 0 Say "пациентов " + lstr( ip ) Color "G+/R"
  @ Row(), Col() Say "/" Color "W/R"
  @ Row(), Col() Say "случаев " + lstr( is ) + iif( isp == 0, "", " (повтор " + lstr( isp ) + ")" ) Color cColorSt2Msg
  @ Row(), Col() Say "/" Color "W/R"
  @ Row(), Col() Say "услуг " + lstr( iu ) Color cColorStMsg
  If siu > 500
    // tmp->fc := "t"
    @ MaxRow(), 0 Say "запись... " Color "W/R"
    dbUnlockAll()
    dbCommitAll()
    siu := 0
  Endif

  Return aerr

// 12.09.23 записать онкологическую добавку по МГИ
Function f_lis_mgi( mkod, ao )

  Local i, ar_N012 := {}
  Local aN012_DS := getds_n012(), it

  Select CO
  addrec( 7 )
  co->kod := mkod
  co->PR_CONS := 0
  co->DT_CONS := CToD( '' )
  //
  Select SL
  addrec( 7 )
  sl->kod := mkod
  sl->DS1_T := 5
  sl->b_diag := 98 // выполнено (результат получен)
  //
  If ( i := AScan( glob_MGI, {| x| x[ 1 ] == ao[ LISS_USL, 1, LISU_SHIFR ] } ) ) > 0 // услуга входит в список ТФОМС
    // select N12
    // dbeval({|| aadd(ar_N012, n12->id_igh) }, ;
    // {|| between_date(n12->datebeg, n12->dateend, ao[LISS_USL, 1, LISU_DATE]) .and. left(human->KOD_DIAG,3) == n12->ds_igh })
    If ( it := AScan( aN012_DS, {| x| Left( x[ 1 ], 3 ) == Left( human->KOD_DIAG, 3 ) } ) ) > 0
      ar_N012 := AClone( aN012_DS[ it, 2 ] )
    Endif

    If AScan( ar_N012, glob_MGI[ i, 2 ] ) > 0 // по данному диагнозу присутствует необходимый маркер
      Select DIAG
      addrec( 7 )
      diag->kod       := mkod
      diag->DIAG_DATE := ao[ LISS_USL, 1, LISU_DATE ]
      diag->DIAG_TIP  := 2
      diag->DIAG_CODE := glob_MGI[ i, 2 ]
      diag->DIAG_RSLT := iif( ao[ LISS_USL, 1, LISU_D_RSLT ] == '1', glob_MGI[ i, 4 ], glob_MGI[ i, 3 ] )
      diag->REC_RSLT  := 1
    Endif
  Endif

  Return Nil

// 14.01.17 проверить отдельно фамилию, имя или отчество при импорте из ЛИС
Function f_lis_fio( s, n )

  Static arr_char := { " ", "-", ".", "'", '"' } // разрешённые спецсимволы
  Local i, c, s1 := ""

  s := AllTrim( s ) // убрать пробелы
  For i := 1 To Len( arr_char )
    s := CharOne( arr_char[ i ], s ) // оставить 1 спецсимвол подряд
  Next
  s := lat_rus( s )  // заменить латинские символы на соответствующие русские (если встретились)
  s1 := CharRem( "0123456789", s ) // убрать цифры
  If Empty( s1 ) .and. n < 3 // если в фамилии или имени были только цифры, - оставить их
    s1 := s
  Endif
  s := s1 ; s1 := ""
  For i := 1 To Len( s )
    c := SubStr( s, i, 1 )
    If isralpha( c ) // буква
      s1 += c
    Elseif AScan( arr_char, c ) > 0 // разрешённый спецсимвол
      s1 += c
    Elseif Between( Asc( c ), 48, 57 ) // в фамилии или имени были только цифры
      s1 += c
    Endif
  Next

  Return s1

// 15.01.17 проверить полис при импорте из ЛИС
Function f_lis_polis()

  Local n

  If Empty( arr_pac[ LIS_OKATO ] ) .or. mo_nodigit( arr_pac[ LIS_OKATO ] ) // пустое или не цифры
    arr_pac[ LIS_OKATO ] := "18"
  Endif
  arr_pac[ LIS_OKATO ] := PadR( arr_pac[ LIS_OKATO ], 11, "0" )
  If AScan( glob_array_srf(), {| x| x[ 2 ] == Left( arr_pac[ LIS_OKATO ], 2 ) } ) == 0
    arr_pac[ LIS_OKATO ] := PadR( "18", 11, "0" )
  Endif
  //
  arr_pac[ LIS_VPOLIS ] := Int( Val( arr_pac[ LIS_VPOLIS ] ) )
  If !Between( arr_pac[ LIS_VPOLIS ], 1, 3 )
    arr_pac[ LIS_VPOLIS ] := 3
  Endif
  arr_pac[ LIS_SPOLIS ] := val_polis( arr_pac[ LIS_SPOLIS ] )
  arr_pac[ LIS_NPOLIS ] := val_polis( arr_pac[ LIS_NPOLIS ] )
  If !Empty( arr_pac[ LIS_SPOLIS ] ) .and. !mo_nodigit( arr_pac[ LIS_SPOLIS ] ) // цифры в серии полиса
    arr_pac[ LIS_NPOLIS ] := arr_pac[ LIS_SPOLIS ] + arr_pac[ LIS_NPOLIS ] // склеим серию и номер = получим номер
    arr_pac[ LIS_SPOLIS ] := ""
  Endif
  n := Len( arr_pac[ LIS_NPOLIS ] )
  If n == 9 .and. Empty( arr_pac[ LIS_SPOLIS ] )
    arr_pac[ LIS_VPOLIS ] := 2  // то пусть это будет временный полис
  Endif
  If n == 16 .and. !Empty( arr_pac[ LIS_SPOLIS ] )
    arr_pac[ LIS_SPOLIS ] := ""  // то очистим - какой-то мусор
  Endif
  If arr_pac[ LIS_VPOLIS ] == 1
    If Left( arr_pac[ LIS_OKATO ], 2 ) == "18" .and. Empty( arr_pac[ LIS_SPOLIS ] ) .and. n != 16
      arr_pac[ LIS_NPOLIS ] := PadR( arr_pac[ LIS_NPOLIS ], 16, "0" )
    Endif
  Elseif arr_pac[ LIS_VPOLIS ] == 2
    If n != 9
      arr_pac[ LIS_NPOLIS ] := PadR( arr_pac[ LIS_NPOLIS ], 9, "0" )
    Endif
  Elseif arr_pac[ LIS_VPOLIS ] == 3
    If n != 16
      arr_pac[ LIS_NPOLIS ] := PadR( arr_pac[ LIS_NPOLIS ], 16, "0" )
    Endif
    If !f_checksum_polis( arr_pac[ LIS_NPOLIS ] ) // если неверная контрольная сумма в новом полисе
      arr_pac[ LIS_VPOLIS ] := 1  // то пусть это будет старый полис
    Endif
  Endif

  Return Nil

// 29.03.23 проверить паспорт при импорте из ЛИС
Function f_lis_pasport()

  Local i, _sl, _sr

  arr_pac[ LIS_VID_UD ] := Int( Val( arr_pac[ LIS_VID_UD ] ) )
  If AScan( getvidud(), {| x| x[ 2 ] == arr_pac[ LIS_VID_UD ] } ) == 0
    arr_pac[ LIS_VID_UD ] := iif( arr_pac[ LIS_VPOLIS ] < 3, 14, 0 )
  Endif
  If arr_pac[ LIS_VID_UD ] == 0 // ели новый полис и нет документа, очистим серию и номер документа
    arr_pac[ LIS_SER_UD ] := ""
    arr_pac[ LIS_NOM_UD ] := ""
  Else
    arr_pac[ LIS_SER_UD ] := Upper( arr_pac[ LIS_SER_UD ] )
    If eq_any( arr_pac[ LIS_VID_UD ], 1, 3 ) // "Паспорт гражд.СССР" или "Свид-во о рождении"
      If "-" $ arr_pac[ LIS_SER_UD ]
        _sl := AllTrim( Token( arr_pac[ LIS_SER_UD ], "-", 1 ) )
        _sr := AllTrim( Token( arr_pac[ LIS_SER_UD ], "-", 2 ) )
        arr_pac[ LIS_SER_UD ] := _sl + "-" + lat_rus( _sr ) // латынь -> в русский
      Else
        If !mo_nodigit( CharRem( " ", arr_pac[ LIS_SER_UD ] ) ) // если только цифры в серии
          arr_pac[ LIS_VID_UD ] := 14 // то это паспорт РФ
        Else
          arr_pac[ LIS_VID_UD ] := 18 // иначе "Иные документы"
        Endif
      Endif
    Endif
    If arr_pac[ LIS_VID_UD ] == 14 .and. !( " " $ arr_pac[ LIS_SER_UD ] ) // если серия в виде "1803" - без пробела
      arr_pac[ LIS_SER_UD ] := Left( arr_pac[ LIS_SER_UD ], 2 ) + " " + SubStr( arr_pac[ LIS_SER_UD ], 3 )
    Endif
    If mo_nodigit( arr_pac[ LIS_NOM_UD ] ) // не цифры
      arr_pac[ LIS_VID_UD ] := 18 // "Иные документы"
    Else
      If ( eq_any( arr_pac[ LIS_VID_UD ], 1, 3 ) .and. Len( arr_pac[ LIS_NOM_UD ] ) != 6 ) .or. ;
          ( arr_pac[ LIS_VID_UD ] == 14 .and. !eq_any( Len( arr_pac[ LIS_NOM_UD ] ), 6, 7 ) )
        arr_pac[ LIS_NOM_UD ] := PadR( arr_pac[ LIS_NOM_UD ], 6, "9" ) // т.е. делаем 6 знаков в длину
      Endif
    Endif
    If eq_any( arr_pac[ LIS_VID_UD ], 3, 14 )
      If Empty( arr_pac[ LIS_MESTO_R ] )
        arr_pac[ LIS_MESTO_R ] := "г.Волгоград"
      Else
        arr_pac[ LIS_MESTO_R ] := del_spec_symbol( arr_pac[ LIS_MESTO_R ] )
      Endif
    Endif
  Endif

  Return Nil

// 03.05.17
Function f_define_lis_coding( name_file )

  Local arr_pac, a1[ 3 ], a2[ 3 ], fl[ 3 ], i, j := 0, ret := { .t., .t. }

  ft_use( name_file )
  ft_gotop()
  Do While !ft_eof()
    If !Empty( s := ft_readln() )
      If Upper( Left( s, 3 ) ) == "PAT"
        arr_pac := {}
        For i := 3 To NumToken( s, ";", 1 )
          s1 := AllTrim( Token( s, ";", i, 1 ) )
          AAdd( arr_pac, s1 )
          If Len( arr_pac ) == 3 ; exit ; Endif
        Next
        For i := 1 To 3
          a1[ i ] := hb_ANSIToOEM( arr_pac[ i ] )
          a2[ i ] := hb_OEMToANSI( a1[ i ] )
          fl[ i ] := ( arr_pac[ i ] == a2[ i ] )
          If !fl[ i ]
            ret[ 1 ] := .f.
          Endif
        Next
        For i := 1 To 3
          a1[ i ] := hb_UTF8ToStr( arr_pac[ i ], "RU866" )
          a2[ i ] := hb_StrToUTF8( a1[ i ], "RU866" )
          fl[ i ] := ( arr_pac[ i ] == a2[ i ] )
          If !fl[ i ]
            ret[ 2 ] := .f.
          Endif
        Next
        If++j == 5 ; exit ; Endif
      Endif
    Endif
    ft_skip()
  Enddo
  ft_use()
  j := 0
  If ret[ 1 ] == ret[ 2 ]
    func_error( 4, "Не удалось автоматически определить кодировку файла " + strippath( name_file ) )
  Else
    j := iif( ret[ 1 ], 1, 2 )
  Endif

  Return j

// Импорт случаев ОМС (листов учёта) из других программ (по-старому)
Function import_sluch_oms()

  Local full_dbf, name_dbf, i, s := "", fl := .t.
  Private arr_f := { "_lpu", "_otd", "_sluch", "_sluch_u" }, ;
    cFileProtokol := "protokol.txt"
  Private p_var_manager := "Read_sluch_OMS"

  full_dbf := manager( T_ROW, T_COL + 5, MaxRow() -2,, .t., 1,,,, "*" + sdbf() )
  If !Empty( full_dbf )
    name_dbf := strippath( full_dbf )
    Private name_path := keeppath( full_dbf ) + hb_ps()
    For i := 1 To Len( arr_f )
      arr_f[ i ] := Upper( arr_f[ i ] ) + sdbf()
      s += iif( Empty( s ), "", "," ) + arr_f[ i ]
    Next
    If AScan( arr_f, name_dbf ) == 0
      fl := func_error( 4, "Необходимо выбрать один из файлов: " + s )
    Else
      For i := 1 To Len( arr_f )
        // if !hb_FileExists(hb_OemToAnsi(name_path)+arr_f[i])
        If !hb_FileExists( name_path + arr_f[ i ] )
          fl := func_error( 4, "Не обнаружен файл: " + name_path + arr_f[ i ] )
          Exit
        Endif
      Next
    Endif
    If fl
      g_splus( f_name_task( X_OMS ) ) // плюс 1 пользователь зашёл в задачу ОМС
      If g_sislock( sem_vagno_task()[ X_OMS ] )
        fl := f_err_sem_vagno_task( X_OMS )
      Else
        fl := f1_import_sluch_oms()
      Endif
      g_sminus( f_name_task( X_OMS ) )  // минус 1 пользователь (вышел из задачи ОМС)
    Endif
    If hb_FileExists( cFileProtokol )
      // copy file (cFileProtokol) to (hb_OemToAnsi(name_path)+cFileProtokol)
      Copy File ( cFileProtokol ) to ( name_path + cFileProtokol )
      viewtext( devide_into_pages( cFileProtokol, 60, 80 ),,,, .t.,,, 2 )
    Endif
  Endif

  Return Nil

// 09.09.25
Function f1_import_sluch_oms()

  Local _lpu := { ;
    { "KOD",     "N",  3, 0 }, ; // ваш код учреждения
    { "NAME",    "C", 30, 0 };  // наименование учреждения
  }
  Local _otd := { ;
    { "KOD",     "N",  3, 0 }, ; // ваш код отделения
    { "NAME",    "C", 30, 0 }, ; // наименование отделения
    { "KOD_LPU", "N",  3, 0 };  // код учреждения, в котором находится отделение
  }
  Local _sluch := { ;
    { "REC_HUMAN",   "N",     8,     0 }, ;
    { "YOUR_RECNO",  "N",    10,     0 }, ;
    { "KOD",   "N",     7,     0 }, ;
    { "FIO",   "C",    50,     0 }, ;
    { "FAM",   "C",    40,     0 }, ;
    { "IM",   "C",    40,     0 }, ;
    { "OT",   "C",    40,     0 }, ;
    { "W",   "N",     1,     0 }, ;
    { "DR",   "D",     8,     0 }, ;
    { "VPOLIS",    "N",     1,     0 }, ;
    { "SPOLIS",    "C",    10,     0 }, ;
    { "NPOLIS",    "C",    20,     0 }, ;
    { "SMO",         "C",     5,     0 }, ;
    { "SMO_OK",      "C",     5,     0 }, ;
    { "SMO_NAM",     "C",   100,     0 }, ; // наименование иногородней СМО
    { "DOCTYPE",     "N",     2,     0 }, ;
    { "DOCSER",      "C",    10,     0 }, ;
    { "DOCNUM",      "C",    20,     0 }, ;
    { "MR",          "C",   100,     0 }, ;
    { "OKATOG",      "C",    11,     0 }, ;
    { "OKATOP",      "C",    11,     0 }, ;
    { "ADRES",       "C",    50,     0 }, ;
    { "ADRESP",      "C",    50,     0 }, ;
    { "SNILS",   "C",    11,     0 }, ;
    { "OTD",   "N",     3,     0 }, ;
    { "PROFIL",      "N",     3,     0 }, ;
    { "NHISTORY",  "C",    10,     0 }, ;
    { "DATE_1",   "D",     8,     0 }, ;
    { "DATE_2",   "D",     8,     0 }, ;
    { "DS0",         "C",     6,     0 }, ;
    { "DS1",        "C",     5,     0 }, ;
    { "DS2",         "C",     5,     0 }, ;
    { "DS2_2",       "C",     5,     0 }, ;
    { "DS2_3",       "C",     5,     0 }, ;
    { "DS2_4",       "C",     5,     0 }, ;
    { "DS2_5",       "C",     5,     0 }, ;
    { "DS2_6",       "C",     5,     0 }, ;
    { "DS2_7",       "C",     5,     0 }, ;
    { "DS3",         "C",     5,     0 }, ;
    { "DS3_2",       "C",     5,     0 }, ;
    { "DS3_3",       "C",     5,     0 }, ;
    { "NOVOR",       "N",     1,     0 }, ;
    { "REB_NUMBER",  "N",     2,     0 }, ;
    { "REB_DR",      "D",     8,     0 }, ;
    { "REB_POL",     "N",     1,     0 }, ;
    { "USL_OK",      "N",     2,     0 }, ;
    { "VIDPOM",      "N",     4,     0 }, ;
    { "IDSP",        "N",     2,     0 }, ;
    { "NPR_MO",      "C",     6,     0 }, ;
    { "EXTR",        "N",     1,     0 }, ;
    { "F_SP",        "N",     1,     0 }, ;
    { "RSLT",        "N",     3,     0 }, ;
    { "ISHOD",       "N",     3,     0 }, ;
    { "VRACH",       "N",     5,     0 }, ;
    { "PRVS",        "N",     9,     0 }, ;
    { "VRACH_FIO",   "C",    50,     0 }, ;
    { "VID_HMP",     "C",    12,     0 }, ; // вид ВМП по справочнику V018
    { "METOD_HMP",   "N",     4,     0 }, ; // метод ВМП по справочнику V019 с 01.01.21 (был N(3))
    { "AD_CR",       "C",    10,     0 }, ;
    { "KSG",         "C",    10,     0 }, ;
    { "CENA_KSG",   "N",    10,     2 }, ;
    { "SUMV",   "N",    10,     2 };
    }
  Local _sluch_u := { ;
    { "REC_HUMANU",  "N",     8,     0 }, ;
    { "YOUR_RECNO",  "N",    10,     0 }, ;
    { "KOD",   "N",     7,     0 }, ;
    { "OTD",   "N",     3,     0 }, ;
    { "PROFIL",      "N",     3,     0 }, ;
    { "DS",          "C",     6,     0 }, ;
    { "CODE_USL", "C",    20,     0 }, ;
    { "DATE_IN",  "D",     8,     0 }, ;
    { "KOL_USL",   "N",     3,     0 }, ;
    { "TARIF",    "N",    10,     2 }, ;
    { "SUMV_USL",   "N",    10,     2 }, ;
    { "VRACH",       "N",     5,     0 }, ;
    { "PRVS",        "N",     9,     0 }, ;
    { "VRACH_FIO",   "C",    50,     0 };
    }
  Local i, j, k, arr_ksg, cType, cName, a_struct, fl := .t., buf := save_maxrow()
  Local arrV018
  Local arrV019

  mywait()
  a_struct := { _lpu, _otd, _sluch, _sluch_u }
  StrFile( Space( 10 ) + "Протокол импорта случаев " + ;
    date_8( sys_date ) + " " + hour_min( Seconds() ) + ;
    hb_eol() + hb_eol(), cFileProtokol )
  For i := 1 To Len( arr_f )
    // use (hb_OemToAnsi(name_path)+arr_f[i]) new alias TMP
    Use ( name_path + arr_f[ i ] ) New Alias TMP
    For j := 1 To Len( a_struct[ i ] )
      cName := a_struct[ i, j, 1 ]
      If ( k := FieldPos( cName ) ) == 0
        fl := .f.
        StrFile( Upper( arr_f[ i ] ) + ": не обнаружено поле " + cName + hb_eol(), cFileProtokol, .t. )
      Else
        pole := "tmp->" + cName
        cType := ValType( &pole )
        If !( cType == a_struct[ i, j, 2 ] )
          fl := .f.
          StrFile( Upper( arr_f[ i ] ) + ", тип поля " + cName + ": " + cType + ;
            ", а должно быть " + a_struct[ i, j, 2 ] + hb_eol(), cFileProtokol, .t. )
        Endif
      Endif
    Next
    Use
  Next
  If fl
    glob_podr := "" ; glob_otd_dep := 0 // пока без кодов подразделений
    dbCreate( cur_dir() + "tmp_ksg", { ;
      { "REC",   "N",     7,     0 }, ;
      { "CODE_USL", "C",    10,     0 }, ;
      { "TARIF",    "N",    10,     2 } } )
    Use ( cur_dir() + "tmp_ksg" ) new
    r_use( dir_exe() + "_okator", cur_dir() + "_okatr", "REGION" )
    r_use( dir_exe() + "_okatoo", cur_dir() + "_okato", "OBLAST" )
    r_use( dir_exe() + "_okatos", cur_dir() + "_okats", "SELO" )
    r_use( dir_exe() + "_mo_mkb", cur_dir() + "_mo_mkb", "MKB_10" )
    use_base( "lusl" )
    use_base( "luslc" )
    use_base( "luslf" )
    g_use( dir_server() + "mo_uch",, "LPU" )
    g_use( dir_server() + "mo_otd",, "OTD" )
    use_base( "mo_su" )
    use_base( "uslugi" )
    r_use( dir_server() + "uslugi1", { dir_server() + "uslugi1", ;
      dir_server() + "uslugi1s" }, "USL1" )
    use_base( "mo_hu" )
    use_base( "human_u" )
    use_base( "human" )
    //
    r_use( dir_exe() + "_mo_smo", { cur_dir() + "_mo_smo", cur_dir() + "_mo_smo2" }, "SMO" )
    Use ( name_path + "_lpu" ) New Alias ILPU
    Index On Str( kod, 3 ) to ( cur_dir() + "tmp_ilpu" )
    Use ( name_path + "_otd" ) New Alias IOTD
    Index On Str( kod, 3 ) to ( cur_dir() + "tmp_iotd" )
    Use ( name_path + "_sluch_u" ) New Alias IHU
    Index On Str( kod, 10 ) to ( cur_dir() + "tmp_ihu" )
    Use ( name_path + "_sluch" ) New Alias IHUMAN
    Index On Str( kod, 10 ) to ( cur_dir() + "tmp_ihum" )
    Go Top
    Do While !Eof()
      Select MKB_10
      find ( PadR( ihuman->ds1, 6 ) )
      If !between_date( mkb_10->dbegin, mkb_10->dend, ihuman->DATE_2 )
        fl := .f.
        StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + ;
          ', DS1="' + ihuman->DS1 + '"-основной диагноз не входит в ОМС' + hb_eol(), cFileProtokol, .t. )
      Endif
      If !Empty( mkb_10->pol ) .and. !( mkb_10->pol == iif( ihuman->W == 1, "М", "Ж" ) )
        fl := .f.
        StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + ;
          ', DS1="' + ihuman->DS1 + '"-несовместимость диагноза по полу' + hb_eol(), cFileProtokol, .t. )
      Endif
      If AScan( getvidud(), {| x| x[ 2 ] == ihuman->DOCTYPE } ) == 0
        fl := .f.
        StrFile( '_SLUCH: запись № ' + lstr( ihuman->( RecNo() ) ) + ;
          ', DOCTYPE-не заполнено поле "ВИД удостоверения личности"' + hb_eol(), cFileProtokol, .t. )
      Else
        If Empty( ihuman->DOCNUM )
          fl := .f.
          StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + ;
            ', DOCNUM-должно быть заполнено поле "НОМЕР удостоверения личности"' + hb_eol(), cFileProtokol, .t. )
        Elseif !ver_number( ihuman->DOCNUM )
          fl := .f.
          StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + ;
            ', DOCNUM-поле "НОМЕР удостоверения личности" должно быть цифровым' + hb_eol(), cFileProtokol, .t. )
        Endif
        If !Empty( ihuman->DOCNUM )
          s := Space( 80 )
          If !val_ud_nom( 2, ihuman->DOCTYPE, ihuman->DOCNUM, @s )
            fl := .f.
            StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + ;
              ', DOCNUM-' + s + hb_eol(), cFileProtokol, .t. )
          Endif
        Endif
        If eq_any( ihuman->DOCTYPE, 1, 3, 14 ) .and. Empty( ihuman->DOCSER )
          fl := .f.
          StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + ;
            ', DOCSER-должно быть заполнено поле "СЕРИЯ удостоверения личности"' + hb_eol(), cFileProtokol, .t. )
        Endif
        If !Empty( ihuman->DOCSER )
          s := Space( 80 )
          If !val_ud_ser( 2, ihuman->DOCTYPE, ihuman->DOCSER, @s )
            fl := .f.
            StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + ;
              ', DOCSER-' + s + hb_eol(), cFileProtokol, .t. )
          Endif
        Endif
      Endif
      fl_fio := .f. ; afio := Array( 3 ) ; AFill( afio, "" )
      If !Empty( ihuman->fam ) .and. !Empty( ihuman->im )
        fl_fio := .t.
        afio[ 1 ] := ihuman->fam
        afio[ 2 ] := ihuman->im
        afio[ 3 ] := ihuman->ot
        mfio := AllTrim( afio[ 1 ] ) + " " + AllTrim( afio[ 2 ] ) + " " + AllTrim( afio[ 3 ] )
      Endif
      If !fl_fio .and. !Empty( ihuman->fio )
        k := 0 ; s := ""
        mfio := AllTrim( ihuman->fio )
        For i := 1 To NumToken( mfio, " ." )
          s1 := AllTrim( Token( mfio, " .", i ) )
          If !Empty( s1 )
            ++k
            If k < 3
              afio[ k ] := s1
            Else
              s += s1 + " "
            Endif
          Endif
        Next
        afio[ 3 ] := AllTrim( s )
      Endif
      aerr := {}
      If !val_fio( afio, aerr )
        For i := 1 To Len( aerr )
          fl := .f.
          StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + ;
            ', "' + AllTrim( ihuman->fio ) + '"-' + aerr[ i ] + hb_eol(), cFileProtokol, .t. )
        Next
      Endif
      If !Empty( ihuman->SNILS )
        s := Space( 80 )
        If !val_snils( ihuman->snils, 2, @s )
          fl := .f.
          StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + ;
            ', SNILS="' + ihuman->SNILS + '"-' + s + hb_eol(), cFileProtokol, .t. )
        Endif
      Endif
      If !Empty( ihuman->NPR_MO )
        If ( i := AScan( glob_arr_mo(), {| x| x[ _MO_KOD_TFOMS ] == ihuman->NPR_MO } ) ) > 0
          //
        Elseif ( i := AScan( glob_arr_mo(), {| x| x[ _MO_KOD_FFOMS ] == ihuman->NPR_MO } ) ) > 0
          //
        Endif
        If i == 0
          fl := .f.
          StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + ;
            ", неверное значение поля NPR_MO = " + ihuman->NPR_MO + hb_eol(), cFileProtokol, .t. )
        Endif
      Endif
      fl_okatosmo := .f. ; fl_nameismo := .f. ; fl_34 := .f.
      If Empty( ihuman->SMO )
        fl := .f.
        StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + ;
          ", не введен код СМО" + hb_eol(), cFileProtokol, .t. )
      Else
        Select SMO
        Set Order To 2
        find ( ihuman->SMO )
        If Found()
          //
        Elseif Int( Val( ihuman->SMO ) ) == 34
          fl_34 := .t.
        Else
          fl := .f.
          StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + ;
            ", неверное значение поля SMO = " + ihuman->SMO + hb_eol(), cFileProtokol, .t. )
        Endif
      Endif
      If fl_34 .and. !Empty( ihuman->SMO_OK )
        Select SMO
        Set Order To 1
        find ( ihuman->SMO_OK )
        If Found()
          fl_okatosmo := .t.
        Else
          fl := .f.
          StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + ;
            ", неверное значение поля SMO_OK = " + ihuman->SMO_OK + hb_eol(), cFileProtokol, .t. )
        Endif
      Endif
      If fl_34 .and. !Empty( ihuman->SMO_NAM )
        fl_nameismo := .t.
      Endif
      If fl_34
        If !fl_okatosmo
          fl := .f.
          StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + ;
            ", не введено ОКАТО территории страхования" + hb_eol(), cFileProtokol, .t. )
        Endif
        If !fl_nameismo
          fl := .f.
          StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + ;
            ", не введено наименование иногородней СМО" + hb_eol(), cFileProtokol, .t. )
        Endif
      Endif
      If !Empty( ihuman->OKATOG ) .and. !import_verify_okato( ihuman->OKATOG )
        fl := .f.
        StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + ;
          ", неверное значение поля OKATOG = " + ihuman->OKATOG + hb_eol(), cFileProtokol, .t. )
      Endif
      If !Empty( ihuman->OKATOP ) .and. !import_verify_okato( ihuman->OKATOP )
        fl := .f.
        StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + ;
          ", неверное значение поля OKATOP = " + ihuman->OKATOP + hb_eol(), cFileProtokol, .t. )
      Endif
      If !Empty( ihuman->PROFIL ) .and. AScan( getv002(), {| x| x[ 2 ] == ihuman->PROFIL } ) == 0
        fl := .f.
        StrFile( '_SLUCH: запись № ' + lstr( ihuman->( RecNo() ) ) + ;
          ', неверное значение поля PROFIL = ' + lstr( ihuman->PROFIL ) + hb_eol(), cFileProtokol, .t. )
      Endif
      If !Empty( ihuman->USL_OK ) .and. AScan( getv006(), {| x| x[ 2 ] == ihuman->USL_OK } ) == 0
        fl := .f.
        StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + ;
          ", неверное значение поля USL_OK = " + lstr( ihuman->USL_OK ) + hb_eol(), cFileProtokol, .t. )
      Endif
    /*
    if !empty(ihuman->IDSP) .and. ascan(getV010(),{|x| x[2]==ihuman->IDSP})==0
      fl := .f.
      strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
              ", неверное значение поля IDSP = "+lstr(ihuman->IDSP)+hb_eol(),cFileProtokol,.t.)
    endif
    */
      If !Empty( ihuman->RSLT ) .and. AScan( getv009(), {| x| x[ 2 ] == ihuman->RSLT } ) == 0
        fl := .f.
        StrFile( '_SLUCH: запись № ' + lstr( ihuman->( RecNo() ) ) + ;
          ', неверное значение поля RSLT = ' + lstr( ihuman->RSLT ) + hb_eol(), cFileProtokol, .t. )
      Endif
      If !Empty( ihuman->ISHOD ) .and. AScan( getv012(), {| x| x[ 2 ] == ihuman->ISHOD } ) == 0
        fl := .f.
        StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + ;
          ", неверное значение поля ISHOD = " + lstr( ihuman->ISHOD ) + hb_eol(), cFileProtokol, .t. )
      Endif
      If !Empty( ihuman->PRVS ) .and. AScan( getv004(), {| x| x[ 2 ] == ihuman->PRVS } ) == 0
        fl := .f.
        StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + ;
          ", неверное значение поля PRVS = " + lstr( ihuman->PRVS ) + hb_eol(), cFileProtokol, .t. )
      Endif
      If ihuman->otd <= 0
        fl := .f.
        StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + ;
          ", поле OTD = " + lstr( ihuman->otd ) + hb_eol(), cFileProtokol, .t. )
      Else
        Select IOTD
        find ( Str( ihuman->otd, 3 ) )
        If Found()
          Select ILPU
          find ( Str( iotd->kod_lpu, 3 ) )
          If !Found()
            fl := .f.
            StrFile( "_OTD: запись № " + lstr( iotd->( RecNo() ) ) + ;
              ", KOD_LPU = " + lstr( iotd->kod_lpu ) + " не найдено в справочнике _LPU" + hb_eol(), cFileProtokol, .t. )
          Endif
        Else
          fl := .f.
          StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + ;
            ", OTD = " + lstr( ihuman->otd ) + " не найдено в справочнике _OTD" + hb_eol(), cFileProtokol, .t. )
        Endif
      Endif
      If ihuman->kod <= 0
        fl := .f.
        StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + ;
          ", поле KOD = " + lstr( ihuman->kod ) + hb_eol(), cFileProtokol, .t. )
      Else
        mdate_r := ihuman->dr ; m1VZROS_REB := 0 ; M1NOVOR := ihuman->novor
        mDATE_R2 := CToD( "" )
        fv_date_r( ihuman->DATE_1 )
        s := 0
        Select IHU
        find ( Str( ihuman->kod, 10 ) )
        Do While ihu->kod == ihuman->kod .and. !Eof()
          If !Between( ihu->DATE_IN, ihuman->date_1, ihuman->date_2 )
            fl := .f.
            StrFile( "_SLUCH_U: запись № " + lstr( ihu->( RecNo() ) ) + ;
              ", дата услуги " + full_date( ihu->DATE_IN ) + " не попадает в диапазон лечения: " + ;
              full_date( ihuman->date_1 ) + "-" + full_date( ihuman->date_2 ) + hb_eol(), cFileProtokol, .t. )
          Endif
          Select LUSLF
          find ( PadR( ihu->CODE_USL, 20 ) )
          If !Found()
            Select LUSL
            find ( PadR( ihu->CODE_USL, 10 ) )
            If Found()
              If ( v := f1cena_oms( ihu->CODE_USL, ;
                  '', ;
                  ( m1vzros_reb == 0 ), ;
                  ihuman->date_2 ) ) != Nil .and. ;
                  !( Round( ihu->TARIF, 2 ) == Round( v, 2 ) )
                fl := .f.
                StrFile( "_SLUCH_U: запись № " + lstr( ihu->( RecNo() ) ) + ;
                  ", " + AllTrim( ihu->CODE_USL ) + " цена " + ;
                  lstr( ihu->TARIF ) + " != цене по ОМС " + lstr( v ) + hb_eol(), cFileProtokol, .t. )
              Endif
            Else
              fl := .f.
              StrFile( "_SLUCH_U: запись № " + lstr( ihu->( RecNo() ) ) + ;
                ", " + AllTrim( ihu->CODE_USL ) + ;
                " не найдена услуга в справочниках ТФОМС (ФФОМС)" + hb_eol(), cFileProtokol, .t. )
            Endif
          Endif
          If !( Round( ihu->TARIF * ihu->KOL_USL, 2 ) == Round( ihu->SUMV_USL, 2 ) )
            fl := .f.
            StrFile( "_SLUCH_U: запись № " + lstr( ihu->( RecNo() ) ) + ;
              ", " + AllTrim( ihu->CODE_USL ) + " " + ;
              lstr( ihu->TARIF ) + "*" + lstr( ihu->KOL_USL ) + " != " + ;
              lstr( ihu->SUMV_USL ) + hb_eol(), cFileProtokol, .t. )
          Endif
          s += ihu->SUMV_USL
          Select IHU
          Skip
        Enddo
        If !( Round( s, 2 ) == Round( ihuman->SUMV, 2 ) )
          fl := .f.
          StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + ;
            ", SUMV = " + lstr( ihuman->sumv ) + " != " + lstr( s ) + hb_eol(), cFileProtokol, .t. )
        Endif
        If !Empty( ihuman->VID_HMP )
          s := ""
          If ihuman->USL_OK == 1 // стационар

            arrV018 := getv018( ihuman->date_2 )
            arrV019 := getv019( ihuman->date_2 )

            If AScan( arrV018, {| x| x[ 1 ] == ihuman->VID_HMP } ) == 0
              s := 'не найден вид ВМП "' + ihuman->VID_HMP + '" в справочнике V018'
            Elseif Empty( ihuman->METOD_HMP )
              s := 'ВМП оказана, введён вид ВМП, но не введён метод ВМП'
            Elseif ( i := AScan( arrV019, {| x| x[ 1 ] == ihuman->METOD_HMP } ) ) > 0
              If arrV019[ i, 4 ] == ihuman->VID_HMP
                If AScan( arrV019[ i, 3 ], {| x| Left( ihuman->ds1, Len( x ) ) == x } ) == 0
                  s := 'основной диагноз не соответствует методу ВМП'
                Endif
              Else
                s := 'метод ВМП ' + lstr( ihuman->METOD_HMP ) + ' не соответствует виду ВМП ' + ihuman->VID_HMP
              Endif
            Else
              s := 'не найден метод ВМП ' + lstr( ihuman->METOD_HMP ) + ' в справочнике V019'
            Endif
          Else
            s := "введен вид ВМП, а случай не стационарный"
          Endif
          If !Empty( s )
            fl := .f.
            StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + ", " + s + hb_eol(), cFileProtokol, .t. )
          Endif
        Endif
        If Empty( ihuman->SUMV )
          If eq_any( ihuman->USL_OK, 1, 2 ) // стационар и дневной стационар
            arr_ksg := definition_ksg( 2 ) // уже 18 год
            If Len( arr_ksg ) == 7 // диализ
              //
            Elseif Empty( arr_ksg[ 2 ] ) // если нет ошибок
              AEval( arr_ksg[ 1 ], {| x| my_debug(, x ) } )
              Select TMP_KSG
              Append Blank
              tmp_ksg->REC      := ihuman->( RecNo() )
              tmp_ksg->CODE_USL := arr_ksg[ 3 ]
              tmp_ksg->TARIF    := arr_ksg[ 4 ]
            Else
              AEval( arr_ksg[ 1 ], {| x| my_debug(, x ) } )
              my_debug(, "ОШИБКА:" )
              AEval( arr_ksg[ 2 ], {| x| my_debug(, x ) } )
              fl := .f.
              StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + hb_eol(), cFileProtokol, .t. )
              AEval( arr_ksg[ 1 ], {| x| StrFile( Space( 8 ) + x + hb_eol(), cFileProtokol, .t. ) } )
              AEval( arr_ksg[ 2 ], {| x| StrFile( Space( 8 ) + x + hb_eol(), cFileProtokol, .t. ) } )
            Endif
          Elseif ihuman->USL_OK == 3 // не скорая помощь
            fl := .f.
            StrFile( "_SLUCH: запись № " + lstr( ihuman->( RecNo() ) ) + ;
              ", SUMV = 0" + hb_eol(), cFileProtokol, .t. )
          Endif
        Endif
      Endif
      Select IHUMAN
      Skip
    Enddo
    Select IHU
    Go Top
    Do While !Eof()
      If !Empty( ihu->PROFIL ) .and. AScan( getv002(), {| x| x[ 2 ] == ihu->PROFIL } ) == 0
        fl := .f.
        StrFile( '_SLUCH_U: запись № ' + lstr( ihu->( RecNo() ) ) + ;
          ', неверное значение поля PROFIL = ' + lstr( ihu->PROFIL ) + hb_eol(), cFileProtokol, .t. )
      Endif
      If !Empty( ihu->PRVS ) .and. AScan( getv004(), {| x| x[ 2 ] == ihu->PRVS } ) == 0
        fl := .f.
        StrFile( '_SLUCH_U: запись № ' + lstr( ihu->( RecNo() ) ) + ;
          ', неверное значение поля PRVS = ' + lstr( ihu->PRVS ) + hb_eol(), cFileProtokol, .t. )
      Endif
      If ihu->otd <= 0
        fl := .f.
        StrFile( "_SLUCH_U: запись № " + lstr( ihu->( RecNo() ) ) + ;
          ", поле OTD = " + lstr( ihu->otd ) + hb_eol(), cFileProtokol, .t. )
      Else
        Select IOTD
        find ( Str( ihu->otd, 3 ) )
        If Found()
          Select ILPU
          find ( Str( iotd->kod_lpu, 3 ) )
          If !Found()
            fl := .f.
            StrFile( "_OTD: запись № " + lstr( iotd->( RecNo() ) ) + ;
              ", KOD_LPU = " + lstr( iotd->kod_lpu ) + " не найдено в справочнике _LPU" + hb_eol(), cFileProtokol, .t. )
          Endif
        Else
          fl := .f.
          StrFile( "_SLUCH_U: запись № " + lstr( ihu->( RecNo() ) ) + ;
            ", OTD = " + lstr( ihu->otd ) + " не найдено в справочнике _OTD" + hb_eol(), cFileProtokol, .t. )
        Endif
      Endif
      If ihu->kod <= 0
        fl := .f.
        StrFile( "_SLUCH_U: запись № " + lstr( ihu->( RecNo() ) ) + ;
          ", поле KOD = " + lstr( ihu->kod ) + hb_eol(), cFileProtokol, .t. )
      Else
        Select IHUMAN
        find ( Str( ihu->kod, 10 ) )
        If !Found()
          fl := .f.
          StrFile( "_SLUCH_U: запись № " + lstr( ihu->( RecNo() ) ) + ;
            ", KOD = " + lstr( ihu->kod ) + " не обнаружен в _SLUCH" + hb_eol(), cFileProtokol, .t. )
        Endif
      Endif
      Select IHU
      Skip
    Enddo
    If fl
      iz := ip := 0
      lOldDeleted := Set( _SET_DELETED, .f. )
      Select TMP_KSG
      Index On Str( rec, 7 ) to ( cur_dir() + "tmp_ksg" )
      g_use( dir_server() + "mo_pers", dir_server() + "mo_pers", "PERSO" )
      g_use( dir_server() + "mo_kfio",, "KFIO" )
      Index On Str( kod, 7 ) to ( cur_dir() + "tmp_kfio" )
      g_use( dir_server() + "mo_kismo",, "KSN" )
      Index On Str( kod, 7 ) to ( cur_dir() + "tmpkismo" )
      g_use( dir_server() + "mo_hismo",, "HSN" )
      Index On Str( kod, 7 ) to ( cur_dir() + "tmphismo" )
      use_base( "kartotek" )
      Select IHUMAN
      Go Top
      Do While !Eof()
        fl_fio := .f. ; afio := Array( 3 )
        If !Empty( ihuman->fam ) .and. !Empty( ihuman->im )
          fl_fio := .t.
          afio[ 1 ] := ihuman->fam
          afio[ 2 ] := ihuman->im
          afio[ 3 ] := ihuman->ot
          mfio := AllTrim( afio[ 1 ] ) + " " + AllTrim( afio[ 2 ] ) + " " + AllTrim( afio[ 3 ] )
        Endif
        If !fl_fio
          k := 0 ; s := ""
          mfio := AllTrim( ihuman->fio )
          For i := 1 To NumToken( mfio, " ." )
            s1 := AllTrim( Token( mfio, " .", i ) )
            If !Empty( s1 )
              ++k
              If k < 3
                afio[ k ] := s1
              Else
                s += s1 + " "
              Endif
            Endif
          Next
          afio[ 3 ] := AllTrim( s )
        Endif
        lkod_k := 0 ; mfio := PadR( mfio, 50 )
        Select KART
        Set Order To 2
        find ( "1" + Upper( mfio ) + DToS( ihuman->dr ) )
        If Found()
          lkod_k := kart->kod
        Endif
        Set Order To 1
        If Empty( lkod_k )
          add1rec( 7 )
          lkod_k := kart->kod := RecNo()
          kart->FIO    := mFIO
          kart->DATE_R := ihuman->dr
          kart->PC3 := '000'
        Else
          Goto ( lkod_k )
          g_rlock( forever )
        Endif
        mdate_r := kart->DATE_R ; m1VZROS_REB := M1NOVOR := 0
        fv_date_r()
        kart->pol       := iif( ihuman->W == 1, "М", "Ж" )
        kart->VZROS_REB := m1VZROS_REB
        kart->POLIS     := make_polis( ihuman->spolis, ihuman->npolis )
        kart->snils     := ihuman->snils
        If !Empty( ihuman->adres )
          kart->adres := ihuman->adres
        Endif
        If twowordfamimot( afio[ 1 ] ) .or. twowordfamimot( afio[ 2 ] ) .or. twowordfamimot( afio[ 3 ] )
          kart->MEST_INOG := 9
        Else
          kart->MEST_INOG := 0
        Endif
        Select KART2
        Do While kart2->( LastRec() ) < lkod_k
          Append Blank
        Enddo
        Goto ( lkod_k )
        g_rlock( forever )
        //
        Select KART_
        Do While kart_->( LastRec() ) < lkod_k
          Append Blank
        Enddo
        Goto ( lkod_k )
        g_rlock( forever )
        //
        kart_->VPOLIS := ihuman->vpolis
        kart_->SPOLIS := ihuman->SPOLIS
        kart_->NPOLIS := ihuman->NPOLIS
        kart_->SMO    := ihuman->smo
        kart_->vid_ud := ihuman->DOCTYPE
        kart_->ser_ud := ihuman->DOCSER
        kart_->nom_ud := ihuman->DOCNUM
        kart_->mesto_r := ihuman->MR
        kart_->okatog := ihuman->OKATOG
        kart_->okatop := ihuman->OKATOP
        If !Empty( ihuman->adresp )
          kart_->adresp := ihuman->adresp
        Endif
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
        fl_nameismo := .f.
        If Int( Val( ihuman->SMO ) ) == 34
          fl_nameismo := .t.
          kart_->KVARTAL_D := ihuman->SMO_OK // ОКАТО субъекта РФ территории страхования
        Endif
        Select KSN
        find ( Str( lkod_k, 7 ) )
        If Found()
          If fl_nameismo
            g_rlock( forever )
            ksn->smo_name := ihuman->SMO_NAM
          Else
            deleterec( .t. )
          Endif
        Else
          If fl_nameismo
            addrec( 7 )
            ksn->kod := lkod_k
            ksn->smo_name := ihuman->SMO_NAM
          Endif
        Endif
        Unlock
        //
        Select TMP_KSG
        find ( Str( ihuman->( RecNo() ), 7 ) )
        If Found()
          ihuman->KSG := tmp_ksg->CODE_USL
          ihuman->CENA_KSG := tmp_ksg->TARIF
        Endif
        //
        fl_povtor := .f.
        Select HUMAN
        Set Order To 2
        find ( Str( lkod_k, 7 ) )
        Do While human->kod_k == lkod_k .and. !Eof()
          v1 := iif( tmp_ksg->( Found() ), tmp_ksg->TARIF, ihuman->SUMV )
          If human->K_DATA == ihuman->DATE_2 .and. ;
              Upper( human->uch_doc ) == Upper( PadR( ihuman->NHISTORY, 10 ) ) .and. ;
              Round( human->CENA_1, 2 ) == Round( v1, 2 )
            //
            ausl_i := {}
            Select IHU
            find ( Str( ihuman->kod, 10 ) )
            Do While ihu->kod == ihuman->kod .and. !Eof()
              AAdd( ausl_i, { PadR( ihu->CODE_USL, 20 ), ihu->PROFIL } )
              Skip
            Enddo
            If tmp_ksg->( Found() ) // добавим в массив услугу КСГ
              AAdd( ausl_i, { PadR( tmp_ksg->CODE_USL, 20 ), ihuman->PROFIL } )
            Endif
            ASort( ausl_i,,, {| x, y| fsort_usl( x[ 1 ] ) < fsort_usl( y[ 1 ] ) } )
            //
            ausl_o := {}
            Select HU
            find ( Str( human->kod, 7 ) )
            Do While hu->kod == human->kod .and. !Eof()
              usl->( dbGoto( hu->u_kod ) )
              AAdd( ausl_o, { PadR( usl->shifr, 20 ), hu_->PROFIL } )
              Skip
            Enddo
            Select MOHU
            find ( Str( human->kod, 7 ) )
            Do While mohu->kod == human->kod .and. !Eof()
              mosu->( dbGoto( mohu->u_kod ) )
              AAdd( ausl_o, { mosu->shifr1, hu_->PROFIL } )
              Skip
            Enddo
            ASort( ausl_o,,, {| x, y| fsort_usl( x[ 1 ] ) < fsort_usl( y[ 1 ] ) } )
            //
            If !emptyany( ausl_i, ausl_o ) .and. ausl_i[ 1, 1 ] == ausl_o[ 1, 1 ] ;
                .and. ausl_i[ 1, 2 ] == ausl_o[ 1, 2 ]
              StrFile( "запись № " + lstr( ihuman->( RecNo() ) ) + ;
                "(KOD = " + lstr( ihuman->kod ) + ;
                ") повторная: " + RTrim( ihuman->fio ) + hb_eol(), cFileProtokol, .t. )
              fl_povtor := .t. ; Exit
            Endif
          Endif
          Select HUMAN
          Skip
        Enddo
        //
        If fl_povtor
          ++ip
        Else
          ++iz
          Select IOTD
          find ( Str( ihuman->otd, 3 ) )
          Select OTD
          Do While otd->( LastRec() ) < ihuman->otd
            Append Blank
          Enddo
          For i := 1 To ihuman->otd - 1
            Goto ( i )
            If otd->kod == 0 .and. !Deleted()
              deleterec( .t. )
            Endif
          Next
          Goto ( ihuman->otd )
          If Deleted()
            g_rlock( forever )
            Recall
          Else
            g_rlock( forever )
          Endif
          otd->KOD     := iotd->KOD
          otd->NAME    := iotd->NAME
          otd->KOD_LPU := iotd->KOD_LPU
          Unlock
          //
          Select ILPU
          find ( Str( iotd->kod_lpu, 3 ) )
          Select LPU
          Do While lpu->( LastRec() ) < iotd->kod_lpu
            Append Blank
          Enddo
          For i := 1 To iotd->kod_lpu - 1
            Goto ( i )
            If lpu->kod == 0 .and. !Deleted()
              deleterec( .t. )
            Endif
          Next
          Goto ( iotd->kod_lpu )
          If Deleted()
            g_rlock( forever )
            Recall
          Else
            g_rlock( forever )
          Endif
          lpu->KOD  := ilpu->KOD
          lpu->NAME := ilpu->NAME
          Unlock
          //
          lvrach := 0
          If ihuman->VRACH > 0
            Select PERSO
            find ( Str( ihuman->VRACH, 5 ) )
            If Found()
              g_rlock( forever )
            Else
              addrecn()
              perso->kod := RecNo()
              perso->tab_nom := ihuman->VRACH
            Endif
            lvrach := perso->kod
            perso->fio  := ihuman->VRACH_FIO
            perso->uch  := iotd->kod_lpu
            perso->otd  := ihuman->otd
            perso->prvs := ihuman->PRVS
            Unlock
          Endif
          //
          M1NOVOR := ihuman->NOVOR ; mDATE_R2 := ihuman->REB_DR
          fv_date_r( ihuman->DATE_1 )
          Select HUMAN
          Set Order To 1
          add1rec( 7 )
          mkod := human->kod := RecNo()
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
          human->FIO        := kart->FIO          // Ф.И.О. больного
          human->POL        := kart->POL          // пол
          human->DATE_R     := kart->DATE_R       // дата рождения больного
          human->VZROS_REB  := M1VZROS_REB   // 0-взрослый, 1-ребенок, 2-подросток
          human->KOD_DIAG   := ihuman->ds1
          For i := 1 To 7
            pole := "ihuman->ds2" + iif( i == 1, "", "_" + lstr( i ) )
            If !Empty( &pole )
              poleh := { "KOD_DIAG2", "KOD_DIAG3", "KOD_DIAG4", ;
                "SOPUT_B1", "SOPUT_B2", "SOPUT_B3", "SOPUT_B4" }[ i ]
              poleh := "human->" + poleh
              &poleh := &pole
            Endif
          Next
          human->KOMU       := 0
          human_->SMO       := ihuman->smo
          human->POLIS      := make_polis( ihuman->spolis, ihuman->npolis )
          human->LPU        := iotd->kod_lpu
          human->OTD        := ihuman->otd
          human->UCH_DOC    := ihuman->NHISTORY
          human->N_DATA     := ihuman->DATE_1
          human->K_DATA     := ihuman->DATE_2
          If tmp_ksg->( Found() ) // тариф КСГ
            human->CENA := human->CENA_1 := tmp_ksg->TARIF
          Else
            human->CENA := human->CENA_1 := ihuman->SUMV
          Endif
          If otd->TIPLU == TIP_LU_G_CIT // жидкостная цитология рака шейки матки
            human->ishod := 98
          Elseif otd->TIPLU == TIP_LU_PREND // пренатальная диагностика
            human->ishod := 99
          Endif
          human_->VPOLIS    := ihuman->vpolis
          human_->SPOLIS    := ihuman->SPOLIS
          human_->NPOLIS    := ihuman->NPOLIS
          human_->OKATO     := ""
          If ihuman->novor == 0
            human_->NOVOR   := 0
            human_->DATE_R2 := CToD( "" )
            human_->POL2    := ""
          Else
            human_->NOVOR   := ihuman->REB_NUMBER
            human_->DATE_R2 := ihuman->REB_DR
            human_->POL2    := iif( ihuman->REB_POL == 1, "М", "Ж" )
          Endif
          human_->USL_OK    := ihuman->USL_OK
          human_->VIDPOM    := 1// ihuman->VIDPOM
          human_->PROFIL    := ihuman->PROFIL
          human_->IDSP      := ihuman->IDSP
          human_->NPR_MO    := ihuman->NPR_MO
          If ihuman->USL_OK == 1
            v := iif( Between( ihuman->EXTR, 1, 2 ), ihuman->EXTR, 1 )
            human_->FORMA14 := Str( v - 1, 1 ) + "000"
          Elseif ihuman->USL_OK == 4
            v := iif( Between( ihuman->F_SP, 1, 2 ), ihuman->F_SP, 1 )
            human_->FORMA14 := Str( v - 1, 1 ) + "000"
          Endif
          human_->KOD_DIAG0 := ihuman->ds0
          human_->RSLT_NEW  := ihuman->rslt
          human_->ISHOD_NEW := ihuman->ishod
          human_->VRACH     := lvrach
          human_->PRVS      := ihuman->prvs
          human_->OPLATA    := 0 // уберём "2", если отредактировали запись из реестра СП и ТК
          human_->ST_VERIFY := 0 // снова ещё не проверен
          human_->ID_PAC    := mo_guid( 1, human_->( RecNo() ) )
          human_->ID_C      := mo_guid( 2, human_->( RecNo() ) )
          human_->SUMP      := 0
          human_->OPLATA    := 0
          human_->SANK_MEK  := 0
          human_->SANK_MEE  := 0
          human_->SANK_EKMP := 0
          human_->REESTR    := 0
          human_->REES_ZAP  := 0
          human->schet      := 0
          human_->SCHET_ZAP := 0
          human->kod_p   := Chr( 0 )
          human->date_e  := ''
          If fl_nameismo
            human_->OKATO := ihuman->SMO_OK // ОКАТО субъекта РФ территории страхования
          Endif
          For i := 1 To 3
            pole := "ihuman->ds3" + iif( i == 1, "", "_" + lstr( i ) )
            If !Empty( &pole )
              poleh := "human_2->osl" + lstr( i )
              &poleh := &pole
            Endif
          Next
          If !Empty( ihuman->VID_HMP )
            human_2->VMP := 1
            human_2->VIDVMP := ihuman->VID_HMP
            human_2->METVMP := ihuman->METOD_HMP
          Endif
          Select HSN
          find ( Str( mkod, 7 ) )
          If Found()
            If fl_nameismo
              g_rlock( forever )
              hsn->smo_name := ihuman->SMO_NAM
            Else
              deleterec( .t. )
            Endif
          Else
            If fl_nameismo
              addrec( 7 )
              hsn->kod := mkod
              hsn->smo_name := ihuman->SMO_NAM
            Endif
          Endif
          Unlock
          //
          ihuman->REC_HUMAN := mkod
          If tmp_ksg->( Found() ) // добавить услугу - КСГ
            v1 := 0
            kod_usl := foundourusluga( tmp_ksg->CODE_USL, human->k_data, human_->profil, human->VZROS_REB, @v1 )
            Select HU
            add1rec( 7 )
            hu->kod     := human->kod
            hu->kod_vr  := human_->VRACH
            hu->kod_as  := 0
            hu->u_koef  := 1
            hu->u_koef  := 1
            hu->u_kod   := kod_usl
            hu->u_cena  := tmp_ksg->TARIF
            hu->is_edit := 0
            hu->date_u  := dtoc4( human->n_data )
            hu->otd     := human->otd
            hu->kol := hu->kol_1 := 1
            hu->stoim := hu->stoim_1 := tmp_ksg->TARIF
            hu->KOL_RCP := 0
            Select HU_
            Do While hu_->( LastRec() ) < hu->( RecNo() )
              Append Blank
            Enddo
            Goto ( hu->( RecNo() ) )
            g_rlock( forever )
            hu_->ID_U := mo_guid( 3, hu_->( RecNo() ) )
            hu_->PROFIL := human_->PROFIL
            hu_->PRVS   := human_->PRVS
            hu_->kod_diag := human->KOD_DIAG
            hu_->zf := ""
            Unlock
          Endif
          //
          Select IHU
          find ( Str( ihuman->kod, 10 ) )
          Do While ihu->kod == ihuman->kod .and. !Eof()
            Select IOTD
            find ( Str( ihu->otd, 3 ) )
            Select OTD
            Do While otd->( LastRec() ) < ihu->otd
              Append Blank
            Enddo
            For i := 1 To ihu->otd - 1
              Goto ( i )
              If otd->kod == 0 .and. !Deleted()
                deleterec( .t. )
              Endif
            Next
            Goto ( ihu->otd )
            If Deleted()
              g_rlock( forever )
              Recall
            Else
              g_rlock( forever )
            Endif
            otd->KOD     := iotd->KOD
            otd->NAME    := iotd->NAME
            otd->KOD_LPU := iotd->KOD_LPU
            Unlock
            //
            lvrach := 0
            If ihu->VRACH > 0
              Select PERSO
              find ( Str( ihu->VRACH, 5 ) )
              If Found()
                g_rlock( forever )
              Else
                addrecn()
                perso->kod := RecNo()
                perso->tab_nom := ihu->VRACH
              Endif
              lvrach := perso->kod
              perso->fio  := ihu->VRACH_FIO
              perso->uch  := iotd->kod_lpu
              perso->otd  := ihu->otd
              perso->prvs := ihu->PRVS
              Unlock
            Endif
            lassis := 0
            If ihu->( FieldPos( "assis" ) ) > 0 ;
                .and. ihu->( FieldType( "assis" ) ) == "N" ;
                .and. !Empty( ihu->assis )
              Select PERSO
              find ( Str( ihu->assis, 5 ) )
              If Found()
                g_rlock( forever )
              Else
                addrecn()
                perso->kod := RecNo()
                perso->tab_nom := ihu->assis
              Endif
              lassis := perso->kod
              perso->uch := iotd->kod_lpu
              perso->otd := ihu->otd
              If ihu->( FieldPos( "assis_fio" ) ) > 0 ;
                  .and. ihu->( FieldType( "assis_fio" ) ) == "C" ;
                  .and. !Empty( ihu->assis_fio )
                perso->fio := ihu->assis_fio
              Endif
              Unlock
            Endif
            //
            kod_usl := kod_uslf := 0
            If Len( AllTrim( ihu->CODE_USL ) ) > 9
              Select MOSU
              Set Order To 3 // по шифру ФФОМС
              find ( PadR( ihu->CODE_USL, 20 ) )
              If Found()
                kod_uslf := mosu->kod
              Else
                Select LUSLF
                find ( PadR( ihu->CODE_USL, 20 ) )
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
                  mosu->shifr1 := ihu->CODE_USL
                  mosu->PROFIL := ihu->PROFIL
                  Unlock
                Endif
              Endif
              If !Empty( kod_uslf )
                Select MOHU
                add1rec( 7 )
                mohu->kod     := human->kod
                mohu->kod_vr  := lvrach
                mohu->kod_as  := lassis
                mohu->u_kod   := kod_uslf
                mohu->u_cena  := 0// ihu->tarif
                mohu->date_u  := dtoc4( ihu->DATE_IN )
                mohu->otd     := ihu->otd
                mohu->kol_1   := ihu->KOL_USL
                mohu->stoim_1 := 0// ihu->SUMV_USL
                mohu->ID_U    := mo_guid( 4, mohu->( RecNo() ) )
                mohu->PROFIL  := ihu->PROFIL
                mohu->PRVS    := ihu->PRVS
                mohu->kod_diag := ihu->ds
                Unlock
                //
                ihu->REC_HUMANU := mohu->( RecNo() )
              Endif
            Endif
            If Empty( kod_uslf )
              Select USL
              Set Order To 2
              find ( PadR( ihu->CODE_USL, 10 ) )
              If Found()
                kod_usl := usl->kod
              Else
                v1 := v2 := 0 ; mname := ""
                Select LUSL
                find ( PadR( ihu->CODE_USL, 10 ) )
                If Found()
                  mname := lusl->name
                  v1 := fcena_oms( lusl->shifr, .t., sys_date )
                  v2 := fcena_oms( lusl->shifr, .f., sys_date )
                Endif
                Select USL
                Set Order To 1
                find ( Str( -1, 4 ) )
                If Found()
                  g_rlock( forever )
                Else
                  addrec( 4 )
                Endif
                kod_usl := usl->kod := RecNo()
                usl->name := mname
                usl->shifr := ihu->CODE_USL
                usl->PROFIL := ihu->PROFIL
                usl->cena   := v1
                usl->cena_d := v2
                Unlock
              Endif
              //
              Select HU
              add1rec( 7 )
              hu->kod     := human->kod
              hu->kod_vr  := lvrach
              hu->kod_as  := lassis
              hu->u_koef  := 1
              hu->u_kod   := kod_usl
              If ihu->( FieldPos( "dom" ) ) > 0 ;
                  .and. ihu->( FieldType( "dom" ) ) == "N" ;
                  .and. eq_any( ihu->dom, 1, 2 )
                hu->KOL_RCP := -ihu->dom
              Endif
              hu->u_cena  := ihu->tarif
              hu->is_edit := 0
              hu->date_u  := dtoc4( ihu->DATE_IN )
              hu->otd     := ihu->otd
              hu->kol := hu->kol_1 := ihu->KOL_USL
              hu->stoim := hu->stoim_1 := ihu->SUMV_USL
              Select HU_
              Do While hu_->( LastRec() ) < hu->( RecNo() )
                Append Blank
              Enddo
              Goto ( hu->( RecNo() ) )
              g_rlock( forever )
              hu_->ID_U := mo_guid( 3, hu_->( RecNo() ) )
              hu_->PROFIL := ihu->PROFIL
              hu_->PRVS   := ihu->PRVS
              hu_->kod_diag := ihu->ds
              Unlock
              //
              ihu->REC_HUMANU := hu->( RecNo() )
            Endif
            //
            Select IHU
            Skip
          Enddo
        Endif
        //
        Select IHUMAN
        Skip
      Enddo
      Set( _SET_DELETED, lOldDeleted )  // Восстановление среды
      If iz > 0
        StrFile( "Успешно импортировано " + lstr( iz ) + " записей" + hb_eol(), cFileProtokol, .t. )
      Endif
      If ip > 0
        StrFile( "Попытка повторно импортировать " + lstr( ip ) + " записей" + hb_eol(), cFileProtokol, .t. )
      Endif
    Endif
    Close databases
  Endif
  rest_box( buf )

  Return fl

//
Function import_verify_okato( s )

  Local fl := .t.

  If Right( s, 9 ) == Replicate( '0', 9 )
    Select REGION
    find ( Left( s, 2 ) )
    fl := Found()
  Elseif Right( s, 6 ) == Replicate( '0', 6 )
    Select OBLAST
    find ( Left( s, 5 ) )
    fl := Found()
  Else
    Select SELO
    find ( s )
    fl := Found()
  Endif

  Return fl

// Импорт данных из программы "Флюоротека" фирмы "ЧИП плюс"
Function import_fluoroteka()

  Local full_zip, buf, k, str_sem := "Импорт флюоротеки"

  If g_slock( str_sem )
    Private p_var_manager := str_sem
    buf := box_shadow( T_ROW - 2, T_COL + 5, T_ROW - 2, T_COL + 5 + 26 + 28, color1, "Выбор архива REGI_FL.ZIP",, 0 )
    full_zip := manager( T_ROW, T_COL + 5, MaxRow() -2,, .t., 1,,,, "*" + szip() )
    If !Empty( full_zip ) .and. ;
        ( arr_f := extract_zip_xml( keeppath( full_zip ), strippath( full_zip ) ) ) != NIL
      rest_box( buf )
      If AScan( arr_f, {| x| Upper( x ) == "_REG.D" } ) == 0
        func_error( 4, "В архиве REGI_FL.ZIP нет необходимых файлов" )
      Else
        hGauge := gaugenew(,,, "Синхронизация флюоротеки с картотекой", .t. )
        gaugedisplay( hGauge )
        Use ( _tmp_dir1() + "_reg.d" ) New Alias RG
        Index On Upper( fio ) + DToS( data_r ) to ( cur_dir() + "tmp_r" ) progress
        g_use( dir_server() + "kartote_",, "KART_" )
        r_use( dir_server() + "kartotek",, "KART" )
        Go Top
        Do While !Eof()
          gaugeupdate( hGauge, RecNo() / LastRec() )
          Select KART_
          If kart_->( LastRec() ) < kart->( LastRec() )
            k := 0 // Добавляем записи
            Do While kart_->( LastRec() ) < kart->( LastRec() )
              Append Blank
              If++k % 4000 == 0
                Commit
              Endif
            Enddo
            Commit
          Endif
          If Len( AllTrim( kart->fio ) ) > 5
            kart_->( dbGoto( kart->( RecNo() ) ) )
            Select RG
            find ( Upper( kart->fio ) + DToS( kart->date_r ) )
            If Found()
              If !( kart_->date_fl == dtoc4( rg->data_i ) .and. kart_->gr_risk == rg->gr_risk )
                Select KART_
                g_rlock( forever )
                kart_->date_fl := dtoc4( rg->data_i )
                kart_->gr_risk := rg->gr_risk
                dbUnlock()
              Endif
            Else
              If !( kart_->date_fl == Space( 4 ) .and. kart_->gr_risk == 0 )
                // очищаем
                Select KART_
                g_rlock( forever )
                kart_->date_fl := ""
                kart_->gr_risk := 0
                dbUnlock()
              Endif
            Endif
          Endif
          Select KART
          If RecNo() % 4000 == 0
            Commit
          Endif
          Skip
        Enddo
        closegauge( hGauge )
        Close databases
        n_message( { "", "Прием данных завершен" } )
      Endif
    Endif
    g_sunlock( str_sem )
    rest_box( buf )
  Else
    func_error( 4, "Ошибка! Импорт флюоротеки производит другой пользователь." )
  Endif

  Return Nil

// 07.11.22
Function f_export( k )

  Static si1 := 1, sds := 1, ssp := 1
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 1
  Do Case
  Case k == 1
    If AScan( kod_LIS(), glob_mo[ _MO_KOD_TFOMS ] ) > 0 // КДП-2
      mas_pmt := { "Экспорт в ~ЛИС", ;
        "Экспорт ~счетов в ВОМИАЦ" }
      mas_msg := { "Экспорт сведений в ЛИС", ;
        "Экспорт счетов за отчётный период январь 2018 - июнь 2019 года в ВОМИАЦ" }
      mas_fun := { "export_to_LIS()", ;
        "f_export(13)" }
    Else
      mas_pmt := { "Экспорт ~военнослужащих", ;
        'Экспорт в программную систему "~БАРС"', ;
        "Экспорт ~счетов в ВОМИАЦ" }
      mas_msg := { "Экспорт в ТФОМС сведений о медицинской помощи, оказанной военнослужащим", ;
        "Экспорт всей картотеки в файл для передачи в программную систему БАРС", ;
        "Экспорт счетов за отчётный период январь 2018 - июнь 2019 года в ВОМИАЦ" }
      mas_fun := { "f_export(11)", ;
        "f_export(12)", ;
        "f_export(13)" }
      If glob_mo[ _MO_IS_UCH ]
        AAdd( mas_pmt, "Экспорт прикрепленного населения в ВОМИАЦ" )
        AAdd( mas_msg, 'Создание файла для передачи в ВОМИАЦ (письмо №14-10-1/328 от 07.11.18г.)' )
        AAdd( mas_fun, "f_export(14)" )
        AAdd( mas_pmt, "Экспорт населения старше 60 лет в ВОМИАЦ" )
        AAdd( mas_msg, 'Создание файла для передачи в ВОМИАЦ (письмо №647 от 23.03.21г.)' )
        AAdd( mas_fun, "f_export(15)" )
      Endif
    Endif
    popup_prompt( T_ROW, T_COL + 5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    mas_pmt := { "~Просмотр/запись", ;
      "~Создать файл отправки" }
    mas_msg := { "Просмотреть созданные файлы для отправки в ТФОМС и записать их на носитель", ;
      "Создание файла экспорта сведений о медицинской помощи, оказанной военнослужащим" }
    mas_fun := { "f_export(21)", ;
      "f_export(22)" }
    Private sbase := "mo_voen", goal_dir := dir_server() + dir_XML_MO() + hb_ps(), ;
      Svoenn_sem := "Работа с военнослужащими", ;
      Svoenn_err := "В данный момент с военнослужащими работает другой пользователь"
    popup_prompt( T_ROW - Len( mas_pmt ) -3, T_COL + 5, 1, mas_pmt, mas_msg, mas_fun )
  Case k == 12
    // if hb_user_curUser:IsAdmin()
    // str_sem := "Создание файла отправки в систему БАРС"
    // if G_SLock(str_sem)
    // full_naselenie_create_BARS()
    // G_SUnLock(str_sem)
    // else
    // func_error(4,err_slock())
    // endif
    // else
    // func_error(4,err_admin())
    // endif
  Case k == 13
    If hb_user_curUser:isadmin()
      str_sem := "Создание файла отправки в ОБЛЗДРАВ"
      If g_slock( str_sem )
        create_schets_oblsdrav()
        g_sunlock( str_sem )
      Else
        func_error( 4, err_slock() )
      Endif
    Else
      func_error( 4, err_admin() )
    Endif
  Case k == 14
    If hb_user_curUser:isadmin()
      str_sem := "Создание файла отправки в ОБЛЗДРАВ"
      If g_slock( str_sem )
        pripisnoe_naselenie_create_oblsdrav()
        g_sunlock( str_sem )
      Else
        func_error( 4, err_slock() )
      Endif
    Else
      func_error( 4, err_admin() )
    Endif
  Case k == 15
    If hb_user_curUser:isadmin()
      str_sem := "Создание файла отправки в ВОМИАЦ"
      If g_slock( str_sem )
        pripisnoe_naselenie_create_vomiac()
        g_sunlock( str_sem )
      Else
        func_error( 4, err_slock() )
      Endif
    Else
      func_error( 4, err_admin() )
    Endif
  Case k == 21
    export_military()
  Case k == 22
    f_create_military()
  Endcase
  If k > 10
    If Between( k, 11, 19 )
      si1 := Int( Val( Right( lstr( k ), 1 ) ) )
    Endif
  Endif

  Return Nil

// 08.05.17 Создание файла для ЛИС из БД КДП2 (пациенты с кодом ЛИС и, возможно, изменёнными реквизитами)
Function export_to_lis()

  create_dbf_for_lis( 2 )

  Return Nil

// 20.11.16
Function create_file_export_military()

  If !hb_FileExists( dir_server() + sbase + sdbf() )
    adbf := { ;
      { "period",      "C", 26, 0 }, ; // отчетный период
      { "KOL",         "N",  6, 0 }, ; // количество пациентов
      { "FNAME",       "C", 18, 0 }, ; // имя файла без расширения
      { "DFILE",       "D",  8, 0 }, ; // дата создания файла
      { "TFILE",       "C",  5, 0 }, ; // время создания файла
      { "DATE_OUT",    "D",  8, 0 }, ; // дата отправки в ТФОМС
      { "NUMB_OUT",    "N",  2, 0 }, ; // номер отправки в ТФОМС;сколько раз всего записывали файл на носитель;
      { "company",     "C", 255, 0 };  // список компаний
    }
    reconstruct( dir_server() + sbase, adbf,,, .t. )
  Endif

  Return Nil

// 20.11.16
Function export_military()

  Local adbf, buf := SaveScreen()

  If !g_slock( Svoenn_sem )
    Return func_error( 4, Svoenn_err )
  Endif
  create_file_export_military()
  g_use( dir_server() + sbase,, "VOEN" )
  Index On DToS( dfile ) to ( cur_dir() + "tmp_voen" ) DESCENDING
  Go Top
  If Eof()
    Keyboard Chr( K_END ) + Chr( K_ENTER )
  Else
    alpha_browse( T_ROW, 2, 22, 77, "f1_export_military", color0,,,,,,, ;
      "f2_export_military",, { '═', '░', '═', "N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R", .t., 180 } )
  Endif
  Close databases
  g_sunlock( Svoenn_sem )
  RestScreen( buf )

  Return Nil

// 20.11.16
Function f1_export_military( oBrow )

  Local oColumn, ;
    blk := {|| iif( hb_FileExists( goal_dir + AllTrim( voen->FNAME ) + sxls() ), ;
    iif( Empty( voen->date_out ), { 3, 4 }, { 1, 2 } ), ;
    { 5, 6 } ) }

  oColumn := TBColumnNew( "Наименование файла", {|| voen->FNAME } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "  Дата", {|| date_8( voen->dfile ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " за период", {|| voen->period } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Кол-во", {|| put_val( voen->kol, 6 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Примечание", {|| f11_export_military() } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  status_key( "^<Esc>^ выход;  ^<F5>^ запись файла для ТФОМС;  ^<Del>^ удалить ещё не записанный файл" )

  Return Nil

//
Static Function f11_export_military()

  Local s := ""

  If !hb_FileExists( goal_dir + AllTrim( voen->FNAME ) + sxls() )
    s := "нет файла"
  Elseif Empty( voen->date_out )
    s := "не записан"
  Else
    s := "зап. " + lstr( voen->NUMB_OUT ) + " раз"
  Endif

  Return PadR( s, 10 )

// 20.11.16
Function f2_export_military( nKey, oBrow )

  Local ret := -1, s, buf := SaveScreen()

  Do Case
  Case nKey == K_F5
    If f_esc_enter( "записи файла за " + date_8( voen->dfile ) )
      Private p_var_manager := "copy_schet"
      s := manager( T_ROW, T_COL + 5, MaxRow() -2,, .t., 2, .f.,,, ) // "norton" для выбора каталога
      If !Empty( s )
        If Upper( s ) == Upper( goal_dir )
          func_error( 4, "Вы выбрали каталог, в котором уже записан целевой файл! Это недопустимо." )
        Else
          zip_file := AllTrim( voen->FNAME ) + sxls()
          If hb_FileExists( goal_dir + zip_file )
            mywait( 'Копирование "' + zip_file + '" в каталог "' + s + '"' )
            // copy file (goal_dir+zip_file) to (hb_OemToAnsi(s)+zip_file)
            Copy File ( goal_dir + zip_file ) to ( s + zip_file )
            // if hb_fileExists(hb_OemToAnsi(s)+zip_file)
            If hb_FileExists( s + zip_file )
              voen->( g_rlock( forever ) )
              voen->DATE_OUT := sys_date
              If voen->NUMB_OUT < 99
                voen->NUMB_OUT++
              Endif
              Unlock
              Commit
            Else
              smsg := "Ошибка записи файла " + s + zip_file
              func_error( 4, "Ошибка записи файла " + s + zip_file )
            Endif
          Else
            func_error( 4, "Не обнаружен файл " + goal_dir + zip_file )
          Endif
        Endif
      Endif
    Endif
    ret := 0
  Case nKey == K_DEL .and. Empty( voen->DATE_OUT )
    If f_esc_enter( "удаления файла за " + date_8( voen->dfile ), .t. )
      stat_msg( "Подтвердите удаление ещё раз." ) ; mybell( 2 )
      If f_esc_enter( "удаления файла за " + date_8( voen->dfile ), .t. )
        mywait( "Ждите. Производится удаление файла с военнослужащими." )
        zip_file := AllTrim( voen->fname ) + sxls()
        If hb_FileExists( goal_dir + zip_file )
          Delete File ( goal_dir + zip_file )
        Endif
        Select VOEN
        deleterec( .t. )
        stat_msg( "Файл с военнослужащими удалён!" ) ; mybell( 2, OK )
        ret := 1
      Endif
    Endif
  Endcase
  RestScreen( buf )

  Return ret

// 20.11.16
Function voenlist2arr( sList )

  Local i, j, s, arr := {}, ar

  If !Empty( sList )
    For i := 1 To NumToken( sList, ";" )
      s := AllTrim( Token( sList, ";", i ) )
      ar := {}
      For j := 1 To NumToken( s, "," )
        AAdd( ar, Int( Val( AllTrim( Token( s, ",", j ) ) ) ) )
      Next
      AAdd( arr, AClone( ar ) )
    Next
  Endif

  Return arr

// 20.11.16
Function f_create_military()

  Local fl := .f., k, buf24 := save_maxrow(), t_arr[ BR_LEN ], blk, arr := {}, arr_m

  If !myfiledeleted( cur_dir() + "tmp" + sdbf() )
    Return Nil
  Endif
  If !g_slock( Svoenn_sem )
    Return func_error( 4, Svoenn_err )
  Endif
  mywait()
  create_file_export_military()
  g_use( dir_server() + sbase,, "VOEN" )
  Go Top
  If !Eof()
    Go Bottom
    arr := voenlist2arr( AllTrim( voen->company ) )
    Locate For dfile == sys_date
    fl := Found()
  Endif
  Close databases
  If fl
    g_sunlock( Svoenn_sem )
    Return func_error( 4, "Уже создан файл экспорта с датой " + full_date( sys_date ) + "г." )
  Endif
  dbCreate( cur_dir() + "tmp", { ;
    { "kod", "N", 4, 0 }, ;
    { "tip", "N", 1, 0 }, ;
    { "name", "C", 30, 0 }, ;
    { "is", "L", 1, 0 } } )
  Use ( cur_dir() + "tmp" ) new
  r_use( dir_server() + "komitet",, "KOM" )
  Go Top
  Do While !Eof()
    Select TMP
    Append Blank
    Replace kod With kom->kod, ;
      tip With 3, ;
      name With kom->name, ;
      is with ( AScan( arr, {| x| x[ 1 ] == 3 .and. x[ 2 ] == kom->kod } ) > 0 )
    Select KOM
    Skip
  Enddo
  r_use( dir_server() + "str_komp",, "SK" )
  Go Top
  Do While !Eof()
    If !Between( sk->tfoms, 44, 47 )
      Select TMP
      Append Blank
      Replace kod With sk->kod, ;
        tip With 1, ;
        name With sk->name, ;
        is with ( AScan( arr, {| x| x[ 1 ] == 1 .and. x[ 2 ] == sk->kod } ) > 0 )
    Endif
    Select SK
    Skip
  Enddo
  k := tmp->( LastRec() )
  Close databases
  rest_box( buf24 )
  If k == 0
    func_error( 4, "В Вашей МО не работают с комитетами и прочими компаниями." )
  Else
    Close databases
    Use ( cur_dir() + "tmp" ) new
    Index On Upper( name ) to ( cur_dir() + "tmp" )
    //
    t_arr[ BR_TOP ] := T_ROW
    t_arr[ BR_BOTTOM ] := MaxRow() -2
    t_arr[ BR_LEFT ] := T_COL + 5
    t_arr[ BR_RIGHT ] := t_arr[ BR_LEFT ] + 44
    t_arr[ BR_COLOR ] := color0
    t_arr[ BR_TITUL ] := "Выбор компаний (военнослужащих)"
    t_arr[ BR_TITUL_COLOR ] := "B/BG"
    t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', "N/BG,W+/N,B/BG,W+/B", .t. }
    blk := {|| iif( tmp->is, { 1, 2 }, { 3, 4 } ) }
    t_arr[ BR_COLUMN ] := { { ' ', {|| iif( tmp->is, '', ' ' ) }, blk }, ;
      { " Наименование", {|| tmp->name }, blk }, ;
      { " ", {|| iif( tmp->tip == 3, " комитет", "компания" ) }, blk } }
    t_arr[ BR_EDIT ] := {| nk, ob| f1create_military( nk, ob, "edit" ) }
    t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ выход;  ^<+,-,Ins>^ отметить компанию для отправки военнослужащих в ТФОМС" ) }
    Go Top
    edit_browse( t_arr )
    arr := {}
    Go Top
    Do While !Eof()
      If tmp->is
        AAdd( arr, { tmp->tip, tmp->kod, tmp->name } )
      Endif
      Skip
    Enddo
    k := Len( arr )
    Close databases
  Endif
  If k == 0
    func_error( 4, "Не выбрано ни одной компании" )
  Elseif ( arr_m := year_month( T_ROW, T_COL + 5 ) ) != NIL
    mywait()
    dbCreate( cur_dir() + "tmp1", { ;
      { "KOD",   "N",     7,     0 }, ; // код человека по kartotek.dbf
      { "DATE_R",   "D",     8,     0 }, ; // дата рождения больного
      { "KOMU",   "N",     1,     0 }, ; // от 1 до 5
      { "STR_CRB",   "N",     2,     0 }, ; // код стр.компании, комитета и т.п.
      { "N_DATA",   "D",     8,     0 }, ; // дата начала лечения
      { "K_DATA",   "D",     8,     0 }, ; // дата окончания лечения
      { "name",   "C",    40,     0 }, ;
      { "FAM",   "C",    40,     0 }, ;
      { "IM",   "C",    40,     0 }, ;
      { "OT",   "C",    40,     0 } } )
    Use ( cur_dir() + "tmp1" ) new
    Index On Str( kod, 7 ) to ( cur_dir() + "tmp1" )
    r_use( dir_server() + "mo_kfio",, "KFIO" )
    Index On Str( kod, 7 ) to ( cur_dir() + "tmp_kfio" )
    r_use( dir_server() + "kartotek",, "KART" )
    r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
    Set Relation To kod_k into KART
    old := arr_m[ 5 ]
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
      If old != human->k_data
        old := human->k_data
        @ MaxRow(), 0 Say date_8( old ) Color "W/R"
      Endif
      If human->komu > 0 .and. ( k := AScan( arr, {| x| x[ 1 ] == human->komu .and. x[ 2 ] == human->STR_CRB } ) ) > 0
        arr_fio := retfamimot( 2, .f., .t. )
        Select TMP1
        find ( Str( human->kod_k, 7 ) )
        If !Found()
          Append Blank
          tmp1->KOD := human->kod_k
          tmp1->DATE_R := kart->date_r
          tmp1->KOMU := arr[ k, 1 ]
          tmp1->STR_CRB := arr[ k, 2 ]
          tmp1->N_DATA := human->n_data
          tmp1->K_DATA := human->k_data
          tmp1->name := arr[ k, 3 ]
          tmp1->FAM := arr_fio[ 1 ]
          tmp1->IM  := arr_fio[ 2 ]
          tmp1->OT  := arr_fio[ 3 ]
        Endif
      Endif
      Select HUMAN
      Skip
    Enddo
    k := tmp1->( LastRec() )
    rest_box( buf24 )
    If k == 0
      func_error( 4, "Не найдено листов учёта военнослужащих " + arr_m[ 4 ] )
    Elseif f_alert( { 'Составляется таблица Excel с военнослужащими', ;
        '(количество пациентов - ' + lstr( k ) + ').', ;
        '', ;
        'Выберите действие:' }, ;
        { " Отказ ", " Создание файла Excel " }, ;
        2, "GR+/R", "W+/R", 16,, "GR+/R,N/BG" ) == 2
      s := ""
      For k := 1 To Len( arr )
        s += lstr( arr[ k, 1 ] ) + "," + lstr( arr[ k, 2 ] )
        If k < Len( arr )
          s += ";"
        Endif
      Next
      n_file := "V_" + glob_mo[ _MO_KOD_TFOMS ] + "_" + DToS( sys_date )
      Delete File ( n_file + sxls() )
      delfrfiles()
      adbf := { { "name_f", "C", 30, 0 }, ;
        { "codemo", "C", 6, 0 }, ;
        { "name", "C", 60, 0 }, ;
        { "period", "C", 60, 0 }, ;
        { "data", "C", 10, 0 } }
      dbCreate( fr_titl, adbf )
      Use ( fr_titl ) New Alias FRT
      Append Blank
      frt->name_f := n_file + sxls()
      frt->codemo := glob_mo[ _MO_KOD_TFOMS ]
      frt->name   := glob_mo[ _MO_SHORT_NAME ]
      frt->data   := full_date( sys_date )
      frt->period := arr_m[ 4 ]
      adbf := { { "nomer", "N", 4, 0 }, ;
        { "fam", "C", 50, 0 }, ;
        { "im", "C", 50, 0 }, ;
        { "ot", "C", 50, 0 }, ;
        { "date_r", "C", 10, 0 }, ;
        { "N_DATA", "C", 10, 0 }, ; // дата начала лечения
      { "K_DATA", "C", 10, 0 }, ; // дата окончания лечения
      { "name", "C", 40, 0 } }
      dbCreate( fr_data, adbf )
      Use ( fr_data ) New Alias FRD
      Select TMP1
      Index On Upper( fam + im + ot ) To tmp1
      k := 0
      Go Top
      Do While !Eof()
        Select FRD
        Append Blank
        frd->nomer := ++k
        frd->fam := tmp1->fam
        frd->im := tmp1->im
        frd->ot := tmp1->ot
        frd->date_r := full_date( tmp1->date_r )
        frd->N_DATA := full_date( tmp1->n_data )
        frd->K_DATA := full_date( tmp1->k_data )
        frd->name := tmp1->name
        Select TMP1
        Skip
      Enddo
      Close databases
      call_fr( "mo_voenn", 3, n_file + sxls(),, .f. )
      g_use( dir_server() + sbase,, "VOEN" )
      addrecn()
      voen->period := arr_m[ 4 ]
      voen->KOL := k
      voen->FNAME := n_file
      voen->DFILE := sys_date
      voen->TFILE := hour_min( Seconds() )
      voen->DATE_OUT := CToD( "" )
      voen->NUMB_OUT := 0
      voen->company := s
      Close databases
      If chip_copy_zipxml( n_file + sxls(), goal_dir, .t. )
        Keyboard Chr( K_HOME ) + Chr( K_ENTER )
      Endif
    Endif
    Close databases
  Endif
  g_sunlock( Svoenn_sem )
  rest_box( buf24 )

  Return Nil

// 20.11.16
Function f1create_military( nKey, oBrow, regim )

  Local k := -1, rec, fl

  If regim == "edit"
    Do Case
    Case nkey == K_INS
      Replace tmp->is With !tmp->is
      k := 0
      Keyboard Chr( K_TAB )
    Case nkey == 43 .or. nkey == 45  // + или -
      rec := RecNo()
      tmp->( dbEval( {|| tmp->is := ( nkey == 43 ) } ) )
      Goto ( rec )
      k := 0
    Endcase
  Endif

  Return k

// 14.07.19 создать файл счетов в Облздрав
Function create_schets_oblsdrav()

  Local arr_f, ar, hZip, i, cPassword, fl := .t., hGauge, s, y, cFile, buf := SaveScreen()

  f_message( { "Ждите! Создаётся архив счетов", ;
    "за отчётный период январь 2018 - июнь 2019 года.", ;
    "", ;
    "Ни в коем случае не прерывайте процесс", ;
    "во избежание нежелательных последствий!" },, "GR+/R", "W+/R", 12 )
  zip_file := "СОМП_" + AllTrim( glob_mo[ _MO_SHORT_NAME ] )
  zip_file := CharRem( '№",', zip_file )
  zip_file := CharOne( " ", zip_file )
  zip_file := CharRepl( " ", zip_file, "_" )
  zip_file := CharRepl( ".", zip_file, "_" )
  zip_file := CharRepl( "-", zip_file, "_" )
  zip_file += szip()
  arr_f := {}
  g_use( dir_server() + "schet_",, "SCHET_" )
  Index On DToS( schet_->dschet ) to ( cur_dir() + "tmp_sch" ) ;
    For schet_->nyear == 2018 .or. ( schet_->nyear == 2019 .and. Between( schet_->nmonth, 1, 6 ) )
  Go Top
  Do While !Eof()
    cFile := dir_server() + dir_XML_MO() + hb_ps() + AllTrim( schet_->name_xml ) + szip()
    If hb_FileExists( cFile )
      AAdd( arr_f, cFile )
    Endif
    Skip
  Enddo
  Close databases
  my_debug(, zip_file )
  Delete File ( zip_file )
  If Len( arr_f ) == 0
    fl := func_error( 4, "Не обнаружено файлов счетов для архивирования." )
  Elseif !Empty( hZip := hb_zipOpen( hb_OEMToANSI( zip_file ) ) )
    Private p_var_manager := "m_copy_DB"
    hGauge := gaugenew(,, { "B/BG*", "B/BG*", "B/BG*" }, "Создание архива счетов", .t. )
    gaugedisplay( hGauge )
    For i := 1 To Len( arr_f )
      cFile := strippath( arr_f[ i ] )  // имя файла без пути
      gaugeupdate( hGauge, i / Len( arr_f ) )
      stat_msg( "Добавление в архив файла " + cFile )
      hb_zipStoreFile( hZip, arr_f[ i ], cFile )// , cPassword )
    Next
    closegauge( hGauge ) // Закроем окно отображения
    hb_zipClose( hZip )
  Else
    fl := func_error( 4, "Возникла ошибка при архивировании базы данных." )
  Endif
  RestScreen( buf )
  If fl
    s := manager( T_ROW, T_COL + 5, MaxRow() -2,, .f., 2 ) // "norton" для выбора каталога
    If !Empty( s )
      mywait( 'Копирование "' + zip_file + '" в каталог "' + s + '"' )
      Delete File ( s + zip_file )
      Copy File ( zip_file ) to ( s + zip_file )
      If hb_FileExists( s + zip_file )
        stat_msg( "Файл " + s + zip_file + " успешно записан!" )
      Else
        stat_msg( "Ошибка записи файла " + s + zip_file + "!" )
      Endif
      mybell( 2, OK )
    Endif
  Endif
  Delete File ( zip_file )
  RestScreen( buf )

  Return Nil

// 29.03.21 создать файл приписного населения в Облздрав
Function pripisnoe_naselenie_create_vomiac()

  Local name_file := 'Пациенты старше 60 лет'
  Local name_file_full := name_file + '.xlsx'

  // if !f_Esc_Enter("создания файла для ВОМИАЦ",.t.)
  // return NIL
  // endif

  If ( dCreate := input_value( 20, 9, 22, 70, color1, ;
      'Дата, на которую необходимо получить информацию', ;
      sys_date ) ) != nil

    writexlsxgreater60( hb_OEMToANSI( name_file_full ), dCreate )
    saveto( cur_dir() + name_file_full )
  Endif

  Return Nil

// 12.09.25 создать файл приписного населения в Облздрав
Function pripisnoe_naselenie_create_oblsdrav()

  Local buf := SaveScreen(),  arr_fio, pr_date, name_file, name_zip
  Local mo_bars :=  { ;
    { "UCHAST",     "C",     20,      0 }, ; // У
    { "FAM",        "C",     40,      0 }, ; // Да
    { "NAME",       "C",     40,      0 }, ; // Да
    { "OTCH",       "C",     40,      0 }, ; // Да
    { "POL",        "N",      1,      0 }, ; // Да
    { "DATE_R",     "D",      8,      0 }, ; // Да
    { "MESTO_R",    "C",    100,      0 }, ; // У
    { "OKATOP",     "C",     11,      0 }, ; // Да
    { "ADRESP",     "C",    120,      0 }, ; // Да
    { "RABOTA",     "N",      1,      0 }, ; // У
    { "BEG_POLIS",  "D",      8,      0 }, ; // У
    { "END_POLIS",  "D",      8,      0 }, ; // У
    { "VPOLIS",     "N",      1,      0 }, ; // У
    { "POLIS",      "C",     16,      0 }, ; // У
    { "KOD_SMO",    "C",      5,      0 }, ; // У
    { "SMO",        "C",    250,      0 }, ; // У
    { "SNILS",      "C",     14,      0 }, ; // У XXX-XXX-XXX XX
    { "VID_UD",     "C",      2,      0 }, ; // У
    { "SER_UD",     "C",     10,      0 }, ; // У
    { "NOM_UD",     "C",     20,      0 }, ; // У
    { "KEMVYD",     "C",     80,      0 }, ; // У
    { "KOGDAVYD",   "D",      8,      0 }, ; // У
    { "MO_PR",      "C",      6,      0 }, ; // Да
    { "DATE_PR",    "D",      8,      0 }, ; // Да
    { "SNILS_VR",   "C",     14,      0 }; // У XXX-XXX-XXX XX
  }
  If !f_esc_enter( "создания файла для ВОМИАЦ", .t. )
    Return Nil
  Endif
  clrline( MaxRow(), color0 )
  dbCreate( cur_dir() + "tmpbars", mo_bars )
  Use ( cur_dir() + "tmpbars" ) New Alias BARS
  hGauge := gaugenew(,,, "Составление файла для ВОМИАЦ", .t. )
  gaugedisplay( hGauge )
  curr := 0
  r_use( dir_server() + "s_kemvyd",, "VID" )
  r_use( dir_exe() + "_mo_smo", cur_dir() + "_mo_smo2", "SMO" )
  // index on smo to (cur_dir()+sbase+'2')
  // G_Use(dir_server() + "mo_krtr",,"KRTR")
  // index on str(kod,6) to (cur_dir() + "tmp_krtr")
  // G_Use(dir_server() + "mo_krtf",,"KRTF")
  // index on str(kod,6) to (cur_dir() + "tmp_krtf")
  // G_Use(dir_server() + "mo_krtp",,"KRTP")
  // index on str(reestr,6) to (cur_dir() + "tmp_k")
  // R_Use(dir_server() + "mo_kfio",cur_dir() + "tmp_kfio","KFIO")
  r_use_base( "kartotek" )
  Set Order To 0
  Go Top
  Do While  !Eof()
    gaugeupdate( hGauge, ++curr / LastRec() )
    If kart->kod > 0 .and. kart2->mo_pr == glob_MO[ _MO_KOD_TFOMS ]
      // a1[i] := hb_AnsiToOem(arr_pac[i])
      // a2[i] := hb_OemToAnsi(a1[i])
      Select BARS
      Append Blank
      bars->UCHAST       :=  lstr( kart->uchast )       // У
      arr_fio := retfamimot( 1, .f., .f. )
      bars->FAM          := arr_fio[ 1 ]                // Да
      bars->NAME         := arr_fio[ 2 ]                // Да
      bars->OTCH         := arr_fio[ 3 ]                // Да
      bars->POL          := iif( kart->pol == "М", 1, 2 )   // Да
      bars->DATE_R       := kart->DATE_R              // Да
      bars->MESTO_R      := kart_->mesto_r            // У
      If Len( AllTrim( kart_->okatop ) ) > 1
        bars->OKATOP     := kart_->okatop             // Да
        bars->ADRESP     := kart_->adresp             // Да
      Else
        bars->OKATOP     := kart_->okatog             // Да
        bars->ADRESP     := kart->adres               // Да
      Endif
      bars->RABOTA       := iif( kart->rab_nerab == 0, 1, 0 )// У
      // bars->BEG_POLIS",  "D",      8,      0},; //У
      bars->END_POLIS    := c4tod( kart->srok_polis )   // У
      // 1 старый 2 - врем 3 новый == 1 новый 2 врем 3 старый
      If kart_->vpolis == 2
        bars->VPOLIS     := 2                       // У
      Elseif kart_->vpolis == 1
        bars->VPOLIS     := 3                       // У
      Else
        bars->VPOLIS     := 1                       // У
      Endif
      bars->POLIS        := kart->polis               // У
      bars->KOD_SMO      := kart_->smo                // У
      Select SMO
      find ( kart_->smo )
      If Found()
        bars->SMO        := smo->name                 // У
      Endif
//      bars->SNILS        := Transform( kart->snils, picture_pf ) // У XXX-XXX-XXX XX
      bars->SNILS        := Transform_SNILS( kart->snils ) // У XXX-XXX-XXX XX
      bars->VID_UD       := lstr( kart_->vid_ud )       // У
      bars->SER_UD       := kart_->ser_ud             // У
      bars->NOM_UD       := kart_->nom_ud             // У
      Select VID
      Goto ( kart_->kemvyd )
      bars->KEMVYD       := vid->name                 // У
      bars->KOGDAVYD     := kart_->kogdavyd           // У
      bars->MO_PR        := glob_MO[ _MO_KOD_TFOMS ]    // Да
      pr_date := Date()
      If !Empty( kart2->pc4 )
        pr_date := CToD( AllTrim( Left( kart2->pc4, 6 ) + "20" + SubStr( kart2->pc4, 7 ) ) )
      Elseif !Empty( kart2->DATE_PR )
        pr_date := kart2->DATE_PR
      Endif
      bars->DATE_PR      := pr_date            // Да
      If !Empty( kart2->snils_vr )
//        bars->SNILS_VR     := Transform( kart2->snils_vr, picture_pf ) // У XXX-XXX-XXX XX
        bars->SNILS_VR     := Transform_SNILS( kart2->snils_vr ) // У XXX-XXX-XXX XX
      Endif
      If bars->( RecNo() ) % 100 == 0
        @ MaxRow(), 1 Say lstr( bars->( RecNo() ) ) Color color0
        If bars->( RecNo() ) % 2000 == 0
          Commit
        Endif
      Endif
    Endif
    Select KART
    Skip
  Enddo
  Close databases
  closegauge( hGauge )
  //
  name_file := AllTrim( "ZLERPN2" + glob_MO[ _MO_KOD_TFOMS ] + DToS( Date() ) )
  name_zip := name_file + szip()
  Copy File ( cur_dir() + "tmpbars" + sdbf() ) to ( cur_dir() + name_file + sdbf() )
  //
  If hb_FileExists( name_file + sdbf() )
    If chip_create_zipxml( name_zip, { name_file + sdbf() }, .t. )
      Copy File ( dir_server() + dir_XML_MO() + hb_ps() + name_zip ) to ( cur_dir() + name_zip )
      n_message( { "В каталоге " + cur_dir() + " создан файл " + Upper( name_zip ), ;
        "c прикрепленным населением для отправки в ВОМИАЦ." },, ;
        cColorSt2Msg, cColorStMsg,,, "G+/R" )
      Delete File ( dir_server() + dir_XML_MO() + hb_ps() + name_zip )
    Endif
  Else
    func_error( 4, "Ошибка создания файла " + name_file )
  Endif

  Return Nil

// 10.09.25 Общие настройки каждой задачи
Function nastr_all( k, nTask )

  Static sk := 1, mas_pmt
  Local str_sem, mas_msg, mas_fun, j, n

  Default k To 0
  Do Case
  Case k == 0
    If ! hb_user_curUser:isadmin()
      Return func_error( 4, err_admin() )
    Endif
    mas_pmt := { "Общие настройки" }
    mas_msg := { "Общие настройки работы с программой" }
    mas_fun := { "nastr_all(1,0)" }
    n := 1
    If is_task( X_PPOKOJ )
      ++n
      AAdd( mas_pmt, array_tasks()[ ind_task( X_PPOKOJ ), 1 ] )
      AAdd( mas_msg, 'Общие настройки задачи "' + array_tasks()[ ind_task( X_PPOKOJ ), 1 ] + '"' )
      AAdd( mas_fun, 'nastr_all(' + lstr( n ) + ',' + lstr( X_PPOKOJ ) + ')' )
    Endif
    If is_task( X_PLATN ) .or. is_task( X_KASSA )
      ++n
      AAdd( mas_pmt, array_tasks()[ ind_task( X_PLATN ), 1 ] )
      AAdd( mas_msg, 'Общие настройки задачи "' + array_tasks()[ ind_task( X_PLATN ), 1 ] + '"' )
      AAdd( mas_fun, 'nastr_all(' + lstr( n ) + ',' + lstr( X_PLATN ) + ')' )
    Endif
    If is_task( X_ORTO )
      ++n
      AAdd( mas_pmt, array_tasks()[ ind_task( X_ORTO ), 1 ] )
      AAdd( mas_msg, 'Общие настройки задачи "' + array_tasks()[ ind_task( X_ORTO ), 1 ] + '"' )
      AAdd( mas_fun, 'nastr_all(' + lstr( n ) + ',' + lstr( X_ORTO ) + ')' )
    Endif
    If is_task( X_PLATN ) .or. is_task( X_KASSA ) .or. is_task( X_ORTO )
      ++n
      AAdd( mas_pmt, 'Обмен данными с ФНС' )
      AAdd( mas_msg, 'Общие настройки задачи для обмена с ФНС' )
      AAdd( mas_fun, 'nastr_all(' + lstr( n ) + ',' + lstr( X_FNS ) + ')' )
    Endif
    If n == 1
      j := &( mas_fun[ 1 ] )
    Elseif n > 1
      popup_prompt( T_ROW, T_COL + 5, sk, mas_pmt, mas_msg, mas_fun )
    Endif
  Case k > 0
    f1nastr_all( mas_pmt[ k ], nTask )
  Endcase
  If k > 0
    sk := k
  Endif

  Return Nil

// 17.07.25 Общие настройки каждой задачи
Function f1nastr_all( nameTask, nTask )

  Local mm_tmp := {}, ctitle
  Local str_sem := "Редактирование общих настроек задачи " + lstr( nTask )

  If g_slock( str_sem )
    Private mm_uchastok := { { 'Не работаем с участком', 0 }, ;
      { 'буква + № участка + № в участке "У25/123"', 1 }, ;
      { 'буква + № участка + код пациента "У25/456789"', 2 }, ;
      { 'буква + № участка + номер АК МИС "У25/765432"', 3 } }
    Private mm_oplata := { { "в зависимости от цены услуги (!рекомендуется!)", 5 }, ;
      { "в зависимости от стоимости УЕТ",                6 }, ;
      { "% от услуги + зависимость от стоимости УЕТ",    7 } }
    Private mm_h_otd := { { "с выбором отделения", 1 }, ;
      { "без выбора отделения", 2 } }
    Private mm_close := { { "платные, ДМС и в/зачет вручную", 1 }, ;
      { "платные и в/зачет вручную, ДМС по оплате", 0 } }
    Private mm_many_uch := { { "из списка отделений выбранного учреждения", 1 }, ;
      { "из списка отделений всех доступных учреждений", 2 } }
    Private mm_num_lu := { { "не работаем с номерами листов учета", 0 }, ;
      { "сквозной номер л/у равен номеру записи", 1 } }
    Private mm_kassa := { { "Нет кассового аппарата", 0 }, ;
      { "Кассовый аппарат: Штрих-ФР-Ф", 1 } }
    Private mm_pol    := { { 'Выбор из меню', 1 }, { 'Ввод буквы вручную', 2 } }
    Private mm_ordusl := { { "По дате", 1 }, { "По шифру услуги", 2 } }
    Private mm_kodkrt := { { "Не выводить", 1 }, { "Выводить", 2 } }
    Private mm_otdusl := { { "Ввод отделения вручную", 1 }, ;
      { "Автоматический выбор отделения по месту работы персонала", 2 } }
    Private mm_stalon := { { 'Выбор из меню', 1 }, { 'Ввод числового значения', 2 } }
    Private mm_zav_l  := { { "да", 1 }, { "нет", 2 }, { "запоминать предыдущий", 3 } }
    Private mm_da_net := { { "нет", 1 }, { "да ", 2 } }
    Private mm_otdort := { { "Ввод отделения вручную", 1 }, ;
      { "Использовать отделение по УМОЛЧАНИЮ", 2 } }
    Private mm_ort_f39 := { { "Три диагноза + итого протезов", 0 }, ;
      { "Семь диагнозов + уточнение типов протезов", 1 } }
    Private mm_v_034 := { { "краткое наименование", 0 }, ;
      { "полное наименование", 1 } }
    Private mm_v_methodinj := { { "на русском", 0 }, ;
      { "на английском", 1 } }
    Private mm_dms := { { "внутренние", 0 }, ;
      { "ФФОМС", 1 } }
    private mm_danet := { { 'да', 1 }, { 'нет', 0 } }
    private mm_versionTNM := { { 'версия 7', 7 }, { 'версия 8', 8 } }

    Delete file tmp.dbf
    Do Case
    Case nTask == 0 .and. tools_ini_oms( 1, 0, 0, .t. ) //  настройка на все задачи
      ctitle := "настройке на все задачи"
      AAdd( mm_tmp, { "_okato", "C", 11, 0, NIL, ;
        {| x| menu_reader( x, ;
        { {|k, r, c| get_okato_ulica( k, r, c, { k, m_okato, } ) } }, A__FUNCTION ) }, ;
        Space( 11 ), {| x| ret_okato_ulica( '', x ) }, ;
        'ОКАТО по умолчанию' } )
      AAdd( mm_tmp, { "a_sound", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
        2, {| x| inieditspr( A__MENUVERT, mm_da_net, x ) }, ;
        'Использовать при работе программы звуковое сопровождение' } )
      AAdd( mm_tmp, { "a_pol", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_pol, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_pol, x ) }, ;
        'Каким образом вводится поле "Пол больного"' } )
      AAdd( mm_tmp, { "a_smp_inp", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_danet, A__MENUVERT ) }, ;
        0, {| x| inieditspr( A__MENUVERT, mm_danet, x ) }, ;
        'Для СМП реквизиты пациента редактируются внутри листа учета?' } )
      AAdd( mm_tmp, { "a_smp_tel", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_danet, A__MENUVERT ) }, ;
        0, {| x| inieditspr( A__MENUVERT, mm_danet, x ) }, ;
        'В специализированном листе учёта по СМП вводим услуги телемедицины?' } )
      AAdd( mm_tmp, { "a_dom_akt", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_danet, A__MENUVERT ) }, ;
        0, {| x| inieditspr( A__MENUVERT, mm_danet, x ) }, ;
        'Работаем с активными посещениями на дому (дом-АКТИВ)?' } )
      AAdd( mm_tmp, { "a_diagno", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_da_net, x ) }, ;
        'Выводить наименование диагнозов при вводе листа учета?' } )
      AAdd( mm_tmp, { "a_diag4", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_da_net, x ) }, ;
        'Проверять обязательность ввода четырехзначного диагноза?' } )
      If yes_parol
        AAdd( mm_tmp, { "a_op_out", "N", 1, 0, NIL, ;
          {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
          1, {| x| inieditspr( A__MENUVERT, mm_da_net, x ) }, ;
          'Выводить Ф.И.О. оператора при записи листа учета?' } )
      Endif
      AAdd( mm_tmp, { "a_ordusl", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_ordusl, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_ordusl, x ) }, ;
        "Порядок сортировки при редактировании услуг" } )
      AAdd( mm_tmp, { "a_ordu_1", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_da_net, x ) }, ;
        "Включать сортировку при добавлении услуг?" } )
      AAdd( mm_tmp, { "a_por_vr", "N", 1, 0, NIL, ;
        nil, ;
        0, nil, ;
        'Порядок расположения полей при вводе услуги: "код врача"     ' } )
      AAdd( mm_tmp, { "a_por_ass", "N", 1, 0, NIL, ;
        nil, ;
        0, nil, ;
        '                                             "код ассистента"' } )
      AAdd( mm_tmp, { "a_por_kol", "N", 1, 0, NIL, ;
        nil, ;
        0, nil, ;
        '                                             "кол-во услуг"  ' } )
      AAdd( mm_tmp, { "a_vv_v_a", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_da_net, x ) }, ;
        'Допускается не вводить и код врача и код ассистента?' } )
      AAdd( mm_tmp, { "a_pom_va", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_da_net, x ) }, ;
        'Запоминать последние коды врача и ассистента для ввода в след.услуге?' } )
      AAdd( mm_tmp, { "a_coplec", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_da_net, x ) }, ;
        "Копировать лечащего врача в первую услугу?" } )
      AAdd( mm_tmp, { "a_date_1", "D", 8, 0, NIL, ;
        nil, ;
        CToD( "" ), nil, ;
        "Допустимая наименьшая дата для ввода информации" } )
      AAdd( mm_tmp, { "a_date_2", "D", 8, 0, NIL, ;
        nil, ;
        CToD( "" ), nil, ;
        "Допустимая наибольшая дата для ввода информации" } )
      AAdd( mm_tmp, { "a_kodkrt", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_kodkrt, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_kodkrt, x ) }, ;
        "Выводить ли в меню код больного по картотеке?" } )
      AAdd( mm_tmp, { "a_trudoem", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_da_net, x ) }, ;
        "Работать ли с коэффициентом трудоемкости услуги (УЕТ)?" } )
      AAdd( mm_tmp, { "a_tr_plan", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_da_net, x ) }, ;
        "Подсчитывать процент выполнения плана по УЕТ?" } )
      AAdd( mm_tmp, { "a_kodotd", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_da_net, x ) }, ;
        "Работать ли с кодами отделений?" } )
      AAdd( mm_tmp, { "e_2", "C", 1, 0, NIL, ;
        nil, ;
        " ", nil, ;
        "Ввод поля ОТДЕЛЕНИЕ, ГДЕ ОКАЗАНА УСЛУГА при вводе услуг",, {|| .f. } } )
      AAdd( mm_tmp, { "a_otdusl", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_otdusl, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_otdusl, x ) }, ;
        "  для больного" } )
      AAdd( mm_tmp, { "e_15", "C", 1, 0, NIL, ;
        nil, ;
        " ", nil, ;
        "Проверять при вводе услуг врача(ассистента) на соответствие категории",, {|| .f. } } )
      AAdd( mm_tmp, { "a_kat_va", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_da_net, x ) }, ;
        "  врач(ср.мед.персонал) по штатному расписанию?" } )
      AAdd( mm_tmp, { "schet_nul", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_danet, A__MENUVERT ) }, ;
        0, {| x| inieditspr( A__MENUVERT, mm_danet, x ) }, ;
        'Разрешается выписывать счета с нулевой суммой (по параклинике):' } )
      AAdd( mm_tmp, { "kart_error", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_danet, A__MENUVERT ) }, ;
        0, {| x| inieditspr( A__MENUVERT, mm_danet, x ) }, ;
        'Разрешается администратору устанавливать статус карточки пациента:' } )
      AAdd( mm_tmp, { "uchastok", "N", 1, 0,, ;
        {| x| menu_reader( x, mm_uchastok, A__MENUVERT ) }, ;
        0, {| x| inieditspr( A__MENUVERT, mm_uchastok, x ) }, ;
        'Работа с УЧАСТКАМИ:' } )
      AAdd( mm_tmp, { "a_edit_ist", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_da_net, x ) }, ;
        'Разрешается редактировать поле "№ амб.карты (истории болезни)"?' } )
      AAdd( mm_tmp, { "a_e_istbol", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_da_net, x ) }, ;
        'Редактировать номер истории болезни, присвоенный в задаче "Приёмный покой"' } )
      AAdd( mm_tmp, { "is_zf", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_danet, A__MENUVERT ) }, ;
        0, {| x| inieditspr( A__MENUVERT, mm_danet, x ) }, ;
        'Работа с зубной формулой:' } )
      AAdd( mm_tmp, { "bukva", "C", 20, 0, "@!", ;
        NIL, ;
        "", NIL, ;
        'Разрешённые БУКВЫ в поле "Стоматологический статус":' } )
      AAdd( mm_tmp, { "oplata", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_oplata, A__MENUVERT ) }, ;
        0, {| x| inieditspr( A__MENUVERT, mm_oplata, x ) }, ;
        'Режим ОПЛАТЫ по труду:' } )
      AAdd( mm_tmp, { "h_otd", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_h_otd, A__MENUVERT ) }, ;
        0, {| x| inieditspr( A__MENUVERT, mm_h_otd, x ) }, ;
        'Режим редактирования листа учета:' } )
      AAdd( mm_tmp, { "standart", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
        0, {| x| inieditspr( A__MENUVERT, mm_da_net, x ) }, ;
        'Работа с режимом НЕЗАВЕРШЕННОГО лечения:' } )
      AAdd( mm_tmp, { "v_zav_l", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_zav_l, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_zav_l, x ) }, ;
        '- вид поля "Лечение завершено" по умолчанию:' } )
      AAdd( mm_tmp, { "e_1", "C", 1, 0, NIL, ;
        NIL, ;
        "", NIL, ;
        'При вводе оказанных услуг из какого СПИСКА выбирается',, ;
        {|| .f. } } )
      AAdd( mm_tmp, { "many_uch", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_many_uch, A__MENUVERT ) }, ;
        0, {| x| inieditspr( A__MENUVERT, mm_many_uch, x ) }, ;
        ' отделение:' } )
      AAdd( mm_tmp, { "e_2", "C", 1, 0, NIL, ;
        NIL, ;
        "", NIL, ;
        'При добавлении листа учета необходимо запоминать ПОРЯДКОВЫЙ НОМЕР последнего',, ;
        {|| .f. } } )
      AAdd( mm_tmp, { "num_lu", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_num_lu, A__MENUVERT ) }, ;
        0, {| x| inieditspr( A__MENUVERT, mm_num_lu, x ) }, ;
        ' листа учета:' } )
      AAdd( mm_tmp, { "st_kat", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_stalon, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_stalon, x ) }, ;
        'Каким образом вводится поле "Категория"' } )
      AAdd( mm_tmp, { "st_pov", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_stalon, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_stalon, x ) }, ;
        'Каким образом вводится поле "Повод обращения"' } )
      AAdd( mm_tmp, { "st_trav", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_stalon, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_stalon, x ) }, ;
        'Каким образом вводится поле "Вид травмы"' } )
      AAdd( mm_tmp, { "ls_parakl", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_danet, A__MENUVERT ) }, ;
        0, {| x| inieditspr( A__MENUVERT, mm_danet, x ) }, ;
        'Включать ПАРАКЛИНИКУ в сумму ЛИЧНОГО СЧЁТА:' } )

      AAdd( mm_tmp, { 'ver_tnm', 'N', 2, 0, NIL, ;
        {| x| menu_reader( x, mm_versionTNM, A__MENUVERT ) }, ;
        0, {| x| inieditspr( A__MENUVERT, mm_versionTNM, x ) }, ;
        'Используемая версия TNM:' } )


      AAdd( mm_tmp, { "path_rab", "C", 70, 0, NIL, ;
        NIL, ;
        "", NIL, ;
        'Рабочий каталог:',, ;
        {|| .f. } } )
      AAdd( mm_tmp, { "path_exe", "C", 70, 0, NIL, ;
        NIL, ;
        "", NIL, ;
        'Каталог запуска задачи:',, ;
        {|| .f. } } )
      AAdd( mm_tmp, { "path_dbf", "C", 70, 0, NIL, ;
        NIL, ;
        "", NIL, ;
        'Каталог баз данных:',, ;
        {|| .f. } } )
      AAdd( mm_tmp, { "ls_v034", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_v_034, A__MENUVERT ) }, ;
        0, {| x| inieditspr( A__MENUVERT, mm_v_034, x ) }, ;
        'Выводить Справочник ФФОМС V034:' } )
      AAdd( mm_tmp, { "ls_method", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_v_methodinj, A__MENUVERT ) }, ;
        0, {| x| inieditspr( A__MENUVERT, mm_v_methodinj, x ) }, ;
        'Выводить Справочник ФФОМС ПУТИ ВВЕДЕНИЯ:' } )
      AAdd( mm_tmp, { "beg_rees", "N", 6, 0, NIL, ;
        nil, ;
        1, nil, ;
        "Допустимый наименьший номер реестра случаев", ;
        {|| mbeg_rees > 0 .and. mbeg_rees < mend_rees } } )
      AAdd( mm_tmp, { "end_rees", "N", 6, 0, NIL, ;
        nil, ;
        999999, nil, ;
        "Допустимый наибольший номер реестра случаев", ;
        {|| mend_rees > 0 .and. mbeg_rees < mend_rees } } )
      AAdd( mm_tmp, { "bnn_rees", "N", 3, 0, NIL, ;
        nil, ;
        1, nil, ;
        "Допустимый наименьший порядковый номер пакета в ТФОМС", ;
        {|| mbnn_rees > 0 .and. mbnn_rees < menn_rees } } )
      AAdd( mm_tmp, { "enn_rees", "N", 3, 0, NIL, ;
        nil, ;
        999, nil, ;
        "Допустимый наибольший порядковый номер пакета в ТФОМС", ;
        {|| menn_rees > 0 .and. mbnn_rees < menn_rees } } )
      AAdd( mm_tmp, { "date_edit", "D", 8, 0, NIL, ;
        NIL, ;
        CToD( "" ), NIL, ;
        "По какую дату (включительно) разрешается редактировать информацию" } )
      init_base( cur_dir() + "tmp",, mm_tmp, 0 )
      f_mb_me_nsh( 2013 )
      Use ( cur_dir() + "tmp" ) new
      Append Blank
      tmp->_okato    := okato_umolch
      tmp->a_smp_inp := mem_smp_input
      tmp->a_smp_tel := mem_smp_tel
      tmp->a_dom_akt := mem_dom_aktiv
      tmp->standart  := iif( yes_vypisan == B_END, 2, 1 ) //
      tmp->many_uch  := iif( yes_many_uch, 2, 1 )
      tmp->schet_nul := is_0_schet
      tmp->kart_error := mem_kart_error
      tmp->uchastok  := is_uchastok
      tmp->a_edit_ist := mem_edit_ist
      tmp->a_e_istbol := mem_e_istbol
      tmp->bukva     := yes_d_plus
      tmp->oplata    := is_oplata
      tmp->h_otd     := yes_h_otd
      tmp->standart  := iif( yes_vypisan == B_END, 2, 1 )
      tmp->many_uch  := iif( yes_many_uch, 2, 1 )
      tmp->num_lu    := yes_num_lu
      tmp->is_zf     := is_zf_stomat  //
      tmp->a_sound   := mem_sound     //
      tmp->a_pol     := mem_pol       //
      tmp->a_diagno  := mem_diagno    //
      tmp->a_diag4   := mem_diag4     //
      tmp->a_pom_va  := mem_pom_va    //
      tmp->a_coplec  := mem_coplec    //
      If yes_parol
        tmp->a_op_out  := mem_op_out  //
      Endif
      tmp->a_ordusl  := mem_ordusl    //
      tmp->a_ordu_1  := mem_ordu_1    //
      tmp->a_kodkrt  := mem_kodkrt    //
      tmp->a_trudoem := mem_trudoem   //
      tmp->a_tr_plan := mem_tr_plan   //
      tmp->a_kodotd  := mem_kodotd    //
      tmp->a_otdusl  := mem_otdusl    //
      tmp->a_kat_va  := mem_kat_va    //
      tmp->a_por_vr  := mem_por_vr    //
      tmp->a_por_ass := mem_por_ass   //
      tmp->a_por_kol := mem_por_kol   //
      tmp->a_vv_v_a  := mem_vv_v_a    //
      tmp->a_date_1  := mem_date_1    //
      tmp->a_date_2  := mem_date_2    //
      tmp->st_kat    := mem_st_kat    //
      tmp->st_pov    := mem_st_pov    //
      tmp->st_trav   := mem_st_trav   //
      tmp->v_zav_l   := mem_zav_l     //
      tmp->ls_parakl := mem_ls_parakl     //
      tmp->path_rab  := cur_dir()
      tmp->path_exe  := dir_exe()
      tmp->path_dbf  := Upper( dir_server() )
      tmp->beg_rees  := mem_beg_rees
      tmp->end_rees  := mem_end_rees
      tmp->bnn_rees  := mem_bnn13rees
      tmp->enn_rees  := mem_enn13rees
      tmp->date_edit := public_date        //
      tmp->ls_v034   := mem_n_V034
      tmp->ls_method := mem_methodinj
      tmp->ver_tnm := mem_ver_TNM

      Close databases
    Case nTask == X_FNS //  Обмен данными с ФНС
      ctitle := 'настройке обмена данными с ФНС'
      _fns_nastr( 0 ) // проверить, а создан ли файл "fns_nastr.dbf"
      AAdd( mm_tmp, { 'n_spr_fns', 'N', 7, 0, NIL, ;
        NIL, ;
        0, NIL, ;
        'Номер последней введенной справки ФНС' } )
      AAdd( mm_tmp, { 'n_file_up', 'N', 7, 0, NIL, ;
        NIL, ;
        0, NIL, ;
        'Номер последнего файла выгрузки в ФНС' } )
      AAdd( mm_tmp, { 'podpis', "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_danet, A__MENUVERT ) }, ;
        0, {| x| inieditspr( A__MENUVERT, mm_danet, x ) }, ;
        'Подписант, руководитель МО:' } )
      AAdd( mm_tmp, { 'predst', 'C', 50, 0, '@!S30', ;
        NIL, ;
        space( 50 ), NIL, ;
        'Представитель МО' } )
      AAdd( mm_tmp, { 'pred_doc', 'C', 50, 0, '@S30', ;
        NIL, ;
        space( 50 ), NIL, ;
        'Документ представителя МО' } )
      AAdd( mm_tmp, { 'edit_sum', "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_danet, A__MENUVERT ) }, ;
        0, {| x| inieditspr( A__MENUVERT, mm_danet, x ) }, ;
        'Разрешать редактирование суммы оплаты:' } )
      AAdd( mm_tmp, { 'id_pol', 'C', 4, 0, '9999', ;
        NIL, ;
        space( 4 ), NIL, ;
        'Идентификатор получателя, которому направляется файл обмена' } )
      AAdd( mm_tmp, { 'id_end', 'C', 4, 0, '9999', ;
        NIL, ;
        space( 4 ), NIL, ;
        'Идентификатор конечного получателя, для которого предназначен файл обмена' } )
      init_base( cur_dir() + 'tmp',, mm_tmp, 0 )
      r_use( dir_server() + 'reg_fns_nastr', , 'NASTR_FNS' )
      Use ( cur_dir() + 'tmp' ) new
      Append Blank
      tmp->N_SPR_FNS := NASTR_FNS->N_SPR_FNS
      tmp->N_FILE_UP := NASTR_FNS->N_FILE_UP
      tmp->PODPIS    := NASTR_FNS->PODPIS
      tmp->PREDST    := NASTR_FNS->PREDST
      tmp->PRED_DOC  := NASTR_FNS->PRED_DOC
      tmp->ID_POL    := NASTR_FNS->ID_POL
      tmp->ID_END    := NASTR_FNS->ID_END
      tmp->EDIT_SUM  := NASTR_FNS->EDIT_SUM

      Close databases
    Case nTask == X_PPOKOJ //  Приёмный покой
      ctitle := "настройке приёмного покоя"
      _pp_nastr( 0 ) // проверить, а создан ли файл "pp_nastr.dbf"
      AAdd( mm_tmp, { "ist_bol", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_danet, A__MENUVERT ) }, ;
        0, {| x| inieditspr( A__MENUVERT, mm_danet, x ) }, ;
        'Вести сквозную нумерацию истории болезни' } )
      AAdd( mm_tmp, { "n_ist_bol", "N", 6, 0, NIL, ;
        NIL, ;
        0, NIL, ;
        "Номер последней введенной истории болезни" } )
      AAdd( mm_tmp, { "file_6", "C", 8, 0, "@!", ;
        NIL, ;
        "", NIL, ;
        "Имя файла шаблона согласия на обр-ку перс.данных (по <F6>)" } )
      AAdd( mm_tmp, { "file_7", "C", 12, 0, "@!", ;
        NIL, ;
        "", NIL, ;
        "Имя файла шаблона листа учета................... (по <F7>)" } )
      AAdd( mm_tmp, { "file_8", "C", 12, 0, "@!", ;
        NIL, ;
        "", NIL, ;
        "Имя файла шаблона истории болезни............... (по <F8>)" } )
      AAdd( mm_tmp, { "file_9", "C", 12, 0, "@!", ;
        NIL, ;
        "", NIL, ;
        "Имя файла шаблона стат.карты (форма 066)........ (по <F9>)" } )
      AAdd( mm_tmp, { "file_12", "C", 12, 0, "@!", ;
        NIL, ;
        "", NIL, ;
        "Наименование файла шаблона индивидуальной карты (по <F12>)" } )
      AAdd( mm_tmp, { "file_xx", "C", 3, 0, "@!", ;
        NIL, ;
        "", NIL, ;
        "Расширение прочих файлов шаблонов организации... (по <F5>)" } )
      init_base( cur_dir() + "tmp",, mm_tmp, 0 )
      r_use( dir_server() + "pp_nastr",, "MV" )
      Use ( cur_dir() + "tmp" ) new
      Append Blank
      tmp->IST_BOL   := mv->IST_BOL
      tmp->N_IST_BOL := mv->N_IST_BOL
      tmp->FILE_6    := mv->FILE_6
      tmp->FILE_7    := mv->FILE_7
      tmp->FILE_8    := mv->FILE_8
      tmp->FILE_9    := mv->FILE_9
      tmp->FILE_12   := mv->FILE_12
      tmp->FILE_XX   := mv->FILE_XX
      Close databases
    Case nTask == X_PLATN .and. tools_ini_platn( 1, 0, 0, .t. ) //  Платные услуги
      ctitle := "настройке платных услуг"
      AAdd( mm_tmp, { "anonim", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_danet, A__MENUVERT ) }, ;
        0, {| x| inieditspr( A__MENUVERT, mm_danet, x ) }, ;
        'Разрешается работать с АНОНИМами?' } )
      AAdd( mm_tmp, { "a_naprvr", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_da_net, x ) }, ;
        'Работать с кодом направившего врача?' } )
      AAdd( mm_tmp, { "a_plsoput", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_da_net, x ) }, ;
        'Работать с сопутствующими заболеваниями?' } )
      AAdd( mm_tmp, { "a_edit_s", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_da_net, x ) }, ;
        'Редактировать поле "Стоимость услуги"?' } )
      AAdd( mm_tmp, { "a_dogovor", "C", 12, 0, "@!", ;
        nil, ;
        Space( 12 ), nil, ;
        'Файл шаблона договора на платные услуги' } )
      AAdd( mm_tmp, { "a_proc_ms", "N", 5, 2, NIL, ;
        nil, ;
        0, nil, ;
        "Процент оплаты МЕДСЕСТРАМ (от ст-ти услуги)" } )
      AAdd( mm_tmp, { "a_proc_sn", "N", 5, 2, NIL, ;
        nil, ;
        0, nil, ;
        "Процент оплаты САНИТАРКАМ (от ст-ти услуги)" } )
      AAdd( mm_tmp, { "a_mfile8", "C", 12, 0, "@!", ;
        nil, ;
        Space( 12 ), nil, ;
        'Наименование файла шаблона индивидуальной карты (по <F8>)' } )
      AAdd( mm_tmp, { "pl_reg", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_danet, A__MENUVERT ) }, ;
        0, {| x| inieditspr( A__MENUVERT, mm_danet, x ) }, ;
        'Вводим квитанционную книжку:' } )
      AAdd( mm_tmp, { "a_close", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_close, A__MENUVERT ) }, ;
        0, {| x| inieditspr( A__MENUVERT, mm_close, x ) }, ;
        'Закрытие листа учета:' } )
      AAdd( mm_tmp, { "a_dms", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_dms, A__MENUVERT ) }, ;
        0, {| x| inieditspr( A__MENUVERT, mm_dms, x ) }, ;
        'В счет-фактуре ДМС использовать шифры услуг:' } )
      AAdd( mm_tmp, { "kassa", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_kassa, A__MENUVERT ) }, ;
        0, {| x| inieditspr( A__MENUVERT, mm_kassa, x ) }, ;
        'Работа через кассовый аппарат:' } )
      init_base( cur_dir() + "tmp",, mm_tmp, 0 )
      Use ( cur_dir() + "tmp" ) new
      Append Blank
      tmp->anonim    := mem_anonim
      tmp->a_edit_s  := mem_edit_s
      tmp->a_naprvr  := mem_naprvr
      tmp->a_plsoput := mem_plsoput
      tmp->a_dogovor := mem_dogovor
      tmp->a_proc_ms := mem_pl_ms
      tmp->a_proc_sn := mem_pl_sn
      tmp->a_mfile8  := mem_ort_f8
      tmp->a_close   := glob_close
      tmp->pl_reg    := glob_pl_reg
      tmp->a_dms     := mem_dms
      tmp->kassa     := glob_kassa
      Close databases
    Case nTask == X_ORTO .and. tools_ini_orto( 1, 0, 0, .t. ) //  Ортопедические услуги в стоматологии
      ctitle := "настройке ортопедии"
      AAdd( mm_tmp, { "ort_f39", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_ort_f39, A__MENUVERT ) }, ;
        0, {| x| inieditspr( A__MENUVERT, mm_ort_f39, x ) }, ;
        'Кол-во заполняемых полей' } )
      AAdd( mm_tmp, { "a_orto_na", "C", 10, 0, NIL, ;
        nil, ;
        Space( 10 ), nil, ;
        'Шаблон для услуг "НАПЫЛЕНИЕ"' } )
      AAdd( mm_tmp, { "a_orto_sl", "C", 10, 0, NIL, ;
        nil, ;
        Space( 10 ), nil, ;
        'Шаблон для услуг "СЛЕПКИ"' } )
      AAdd( mm_tmp, { "a_orto_ysl", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_da_net, x ) }, ;
        'Разрешается добавлять услуги в режиме "Открытие наряда"?' } )
      AAdd( mm_tmp, { "a_ortootd", "N", 3, 0, NIL, ;
        {| x| menu_reader( x, { dir_server() + "mo_otd",, }, A__POPUPEDIT ) }, ;
        0, {| x| inieditspr( A__POPUPEDIT, dir_server() + "mo_otd", x ) }, ;
        'Отделение по умолчанию при вводе услуг' } )
      AAdd( mm_tmp, { "e_12", "C", 1, 0, NIL, ;
        nil, ;
        " ", nil, ;
        'Каким образом вводится поле "ОТДЕЛЕНИЕ, ГДЕ ОКАЗАНА УСЛУГА"',, {|| .f. } } )
      AAdd( mm_tmp, { "a_ort1otd", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_otdort, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_otdort, x ) }, ;
        ' при вводе услуг' } )
      AAdd( mm_tmp, { "a_edit_s", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_da_net, x ) }, ;
        'Редактировать поле "Стоимость услуги"?' } )
      AAdd( mm_tmp, { "a_orto_ms", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_da_net, x ) }, ;
        'Необходим ввод медсестры в ортопедических услугах?' } )
      AAdd( mm_tmp, { "a_orto_pl", "C", 12, 0, "@!", ;
        nil, ;
        Space( 12 ), nil, ;
        'Наименование файла шаблона для платного наряда-заказа' } )
      AAdd( mm_tmp, { "a_orto_bp", "C", 12, 0, "@!", ;
        nil, ;
        Space( 12 ), nil, ;
        'Наименование файла шаблона для бесплатного наряда-заказа' } )
      AAdd( mm_tmp, { "a_orto_dog", "C", 3, 0, "@!", ; // 16.04.08
      nil, ;
        Space( 12 ), nil, ;
        'Расширение файлов-шаблонов для печати договоров' } )
      AAdd( mm_tmp, { "a_orto_dat", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_da_net, x ) }, ;
        'Дата открытия наряда равна дате начала лечения ?' } )
      AAdd( mm_tmp, { "a_mfile8", "C", 12, 0, "@!", ;
        nil, ;
        Space( 12 ), nil, ;
        'Наименование файла шаблона индивидуальной карты (по <F8>)' } )
      AAdd( mm_tmp, { "kassa", "N", 1, 0, NIL, ;
        {| x| menu_reader( x, mm_kassa, A__MENUVERT ) }, ;
        0, {| x| inieditspr( A__MENUVERT, mm_kassa, x ) }, ;
        'Работа через кассовый аппарат:' } )
      init_base( cur_dir() + "tmp",, mm_tmp, 0 )
      Use ( cur_dir() + "tmp" ) new
      Append Blank
      tmp->ort_f39    := mem_ort_f39
      tmp->a_edit_s   := mem_edit_s
      tmp->a_orto_na  := mem_ort_na
      tmp->a_orto_sl  := mem_ort_sl
      tmp->a_orto_ysl := mem_ort_ysl
      tmp->a_ortootd  := mem_ortotd
      tmp->a_ort1otd  := mem_ortot1
      tmp->a_orto_ms  := mem_ort_ms
      tmp->a_orto_bp  := mem_ort_bp
      tmp->a_orto_pl  := mem_ort_pl
      tmp->a_orto_dat := mem_ort_dat
      tmp->a_orto_dog := mem_ort_dog // 16.04.08
      tmp->a_mfile8   := mem_ort_f8
      tmp->kassa      := glob_kassa
      Close databases
    Endcase
    If f_edit_spr( A__EDIT, mm_tmp, ctitle, "g_use(cur_dir()+'tmp',,,.t.,.t.)", 0, 1 ) > 0
      Use ( cur_dir() + "tmp" ) new
      Do Case
      Case nTask == 0
        mem_smp_input := tmp->a_smp_inp
        mem_smp_tel  := tmp->a_smp_tel
        mem_dom_aktiv := tmp->a_dom_akt
        okato_umolch := tmp->_okato
        is_0_schet   := tmp->schet_nul
        is_uchastok  := tmp->uchastok
        mem_kart_error := tmp->kart_error
        mem_edit_ist := tmp->a_edit_ist
        mem_e_istbol := tmp->a_e_istbol
        yes_d_plus   := tmp->bukva
        is_oplata    := tmp->oplata
        yes_h_otd    := tmp->h_otd
        yes_vypisan  := iif( tmp->standart == 1, B_STANDART, B_END )
        yes_many_uch := ( tmp->many_uch == 2 )
        yes_num_lu   := tmp->num_lu
        is_zf_stomat := tmp->is_zf
        mem_sound    := tmp->a_sound
        mem_pol      := tmp->a_pol
        mem_diagno   := tmp->a_diagno
        mem_diag4    := tmp->a_diag4
        mem_pom_va   := tmp->a_pom_va
        mem_coplec   := tmp->a_coplec
        If yes_parol
          mem_op_out := tmp->a_op_out
        Endif
        mem_ordusl  := tmp->a_ordusl
        mem_ordu_1  := tmp->a_ordu_1
        mem_kodkrt  := tmp->a_kodkrt
        mem_trudoem := tmp->a_trudoem
        mem_tr_plan := tmp->a_tr_plan
        mem_kodotd  := tmp->a_kodotd
        mem_otdusl  := tmp->a_otdusl
        mem_kat_va  := tmp->a_kat_va
        mem_por_vr  := tmp->a_por_vr
        mem_por_ass := tmp->a_por_ass
        mem_por_kol := tmp->a_por_kol
        mem_vv_v_a  := tmp->a_vv_v_a
        mem_date_1  := tmp->a_date_1
        mem_date_2  := tmp->a_date_2
        mem_st_kat  := tmp->st_kat
        mem_st_pov  := tmp->st_pov
        mem_st_trav := tmp->st_trav
        mem_zav_l   := tmp->v_zav_l
        mem_ls_parakl := tmp->ls_parakl
        mem_beg_rees := tmp->beg_rees
        mem_end_rees := tmp->end_rees
        mem_bnn13rees := tmp->bnn_rees
        mem_enn13rees := tmp->enn_rees
        public_date := tmp->date_edit
        mem_n_V034  := tmp->ls_v034
        mem_methodinj := tmp->ls_method
        mem_ver_TNM := tmp->ver_tnm
        tools_ini_oms( 2, 0, 0 )
      Case nTask == X_FNS //  Обмен с ФНС
        g_use( dir_server() + 'reg_fns_nastr', , 'NASTR_FNS' )
        g_rlock( forever )
        nastr_fns->N_SPR_FNS := tmp->N_SPR_FNS
        nastr_fns->N_FILE_UP := tmp->N_FILE_UP
        nastr_fns->PODPIS    := tmp->PODPIS
        if tmp->PODPIS == 0
          nastr_fns->PREDST    := tmp->PREDST
          nastr_fns->PRED_DOC  := tmp->PRED_DOC
        else
          nastr_fns->PREDST    := ''  //tmp->PREDST
          nastr_fns->PRED_DOC  := ''  //tmp->PRED_DOC
        endif
        nastr_fns->ID_POL    := tmp->ID_POL
        nastr_fns->ID_END    := tmp->ID_END
        nastr_fns->EDIT_SUM  := tmp->EDIT_SUM
      Case nTask == X_PPOKOJ //  Приёмный покой
        g_use( dir_server() + "pp_nastr",, "MV" )
        g_rlock( forever )
        mv->IST_BOL   := tmp->IST_BOL
        mv->N_IST_BOL := tmp->N_IST_BOL
        mv->FILE_6    := tmp->FILE_6
        mv->FILE_7    := tmp->FILE_7
        mv->FILE_8    := tmp->FILE_8
        mv->FILE_9    := tmp->FILE_9
        mv->FILE_12   := tmp->FILE_12
        mv->FILE_XX   := tmp->FILE_XX
      Case nTask == X_PLATN
        mem_anonim  := tmp->anonim
        mem_edit_s  := tmp->a_edit_s
        mem_naprvr  := tmp->a_naprvr
        mem_plsoput := tmp->a_plsoput
        mem_dogovor := tmp->a_dogovor
        mem_pl_ms   := tmp->a_proc_ms
        mem_pl_sn   := tmp->a_proc_sn
        mem_ort_f8  := tmp->a_mfile8
        glob_close  := tmp->a_close
        glob_pl_reg := tmp->pl_reg
        mem_dms     := tmp->a_dms
        glob_kassa  := tmp->kassa
        tools_ini_platn( 2, 0, 0 )
      Case nTask == X_ORTO
        mem_edit_s  := tmp->a_edit_s
        mem_ort_na  := tmp->a_orto_na
        mem_ort_sl  := tmp->a_orto_sl
        mem_ort_ysl := tmp->a_orto_ysl
        mem_ortotd  := tmp->a_ortootd
        mem_ortot1  := tmp->a_ort1otd
        mem_ort_ms  := tmp->a_orto_ms
        mem_ort_bp  := tmp->a_orto_bp
        mem_ort_pl  := tmp->a_orto_pl
        mem_ort_dat := tmp->a_orto_dat
        mem_ort_dog := tmp->a_orto_dog
        mem_ort_f8  := tmp->a_mfile8
        mem_ort_f39 := tmp->ort_f39
        glob_kassa  := tmp->kassa
        tools_ini_orto( 2, 0, 0 )
      Endcase
    Endif
    Close databases
    g_sunlock( str_sem )
  Else
    func_error( 4, err_slock() )
  Endif

  Return Nil

// сделать копию tools.ini с сервера в локальный каталог с именем loctools.ini
Function copy_tools_ini()

  Local i := 0, fl := .f., bSaveHandler

  If !hb_FileExists( tools_ini() ) // если ни разу не заходили в режим настроек
    Return .t.
  Endif
  If ( fl := semaphor_tools_ini( 1 ) )
    Do While++i < 20
      //
      bSaveHandler := ErrorBlock( {| x| Break( x ) } )
      //
      Begin Sequence
        // if files_time(tools_ini(),local_tools_ini())
        Delete File ( local_tools_ini() )
        Copy File ( tools_ini() ) to ( local_tools_ini() )
        // endif
        If hb_FileExists( local_tools_ini() )
          fl := .t.
        Endif
      RECOVER USING error
        fl := .f.
      End
      //
      ErrorBlock( bSaveHandler )
      If fl
        Exit
      Endif
      Millisec( 20 )
    Enddo
    semaphor_tools_ini( 2 )
  Endif

  Return fl

//
Function semaphor_tools_ini( k )

  Static sem_tools := "Semaphor_Tools"
  Local i := 0, buf, fl := .t.

  If k == 1
    buf := save_maxrow()
    waitstatus( "Чтение/запись программных настроек" )
    Do While .t.
      updatestatus()
      If++i > 100
        fl := func_error( 'Не удалось заблокировать семафор "' + sem_tools + '"! Попытайтесь снова.' )
        Exit
      Endif
      If g_slock( sem_tools )
        Exit
      Endif
      Millisec( 10 )
    Enddo
    rest_box( buf )
  Else
    g_sunlock( sem_tools )
  Endif

  Return fl

// 17.07.25
Function tools_ini_oms( reg, k1, k2, fll )

  Static arr := { { "okato_umolch",  "C" }, ;
    { "mem_smp_input", "N" }, ;
    { "mem_smp_tel",   "N" }, ;
    { "mem_dom_aktiv", "N" }, ;
    { "mem_kart_error", "N" }, ;
    { "is_0_schet",    "N" }, ;
    { "is_uchastok",   "N" }, ;
    { "mem_edit_ist",  "N" }, ;
    { "mem_e_istbol",  "N" }, ;
    { "yes_d_plus",    "C" }, ;
    { "is_oplata",     "N" }, ;
    { "yes_h_otd",     "N" }, ;
    { "yes_vypisan",   "N" }, ;
    { "yes_many_uch",  "L" }, ;
    { "yes_num_lu",    "N" }, ;
    { "is_zf_stomat",  "N" }, ;
    { "mem_sound",     "N" }, ;
    { "mem_pol",       "N" }, ;
    { "mem_diagno",    "N" }, ;
    { "mem_diag4",     "N" }, ;
    { "mem_pom_va",    "N" }, ;
    { "mem_coplec",    "N" }, ;
    { "mem_op_out",    "N" }, ;
    { "mem_ordusl",    "N" }, ;
    { "mem_ordu_1",    "N" }, ;
    { "mem_kodkrt",    "N" }, ;
    { "mem_trudoem",   "N" }, ;
    { "mem_tr_plan",   "N" }, ;
    { "mem_kodotd",    "N" }, ;
    { "mem_otdusl",    "N" }, ;
    { "mem_kat_va",    "N" }, ;
    { "mem_por_vr",    "N" }, ;
    { "mem_por_ass",   "N" }, ;
    { "mem_por_kol",   "N" }, ;
    { "mem_vv_v_a",    "N" }, ;
    { "mem_date_1",    "D" }, ;
    { "mem_date_2",    "D" }, ;
    { "mem_st_kat",    "N" }, ;
    { "mem_st_pov",    "N" }, ;
    { "mem_st_trav",   "N" }, ;
    { "mem_zav_l",     "N" }, ;
    { "mem_ls_parakl", "N" }, ;
    { "mem_beg_rees",  "N" }, ;
    { "mem_end_rees",  "N" }, ;
    { "mem_bnn_rees",  "N" }, ;
    { "mem_enn_rees",  "N" }, ;
    { "mem_bnn13rees", "N" }, ;
    { "mem_enn13rees", "N" }, ;
    { "public_date",   "D" }, ;
    { "mem_n_V034",    "N" }, ;
    { "mem_methodinj", "N" }, ;
    { "mem_ver_TNM",   "N" } }
  Local name_section := "OMS"
  Local i, j, ta := {}, v, fl

  Default fll To .f.
  If ( fl := iif( fll, semaphor_tools_ini( 1 ), .t. ) )
    name_section += "-" + lstr( k1 ) + "-" + lstr( k2 )
    If reg == 1 // чтение
      ta := getinisect( iif( fll, tools_ini(), local_tools_ini() ), name_section ) // вернуть двумерный массив содержимого секции {{"наим.","знач."},...}
      For j := 1 To Len( ta )
        If ( i := AScan( arr, {| x| Upper( x[ 1 ] ) == ta[ j, 1 ] } ) ) > 0
          If arr[ i, 2 ] == "C"
            &( arr[ i, 1 ] ) := ta[ j, 2 ]
          Elseif arr[ i, 2 ] == "N"
            &( arr[ i, 1 ] ) := Int( Val( ta[ j, 2 ] ) )
          Elseif arr[ i, 2 ] == "L"
            &( arr[ i, 1 ] ) := ( ta[ j, 2 ] == '1' )
          Elseif arr[ i, 2 ] == "D"
            &( arr[ i, 1 ] ) := SToD( ta[ j, 2 ] )
          Endif
        Endif
      Next
      MUSIC_ON_OFF := ( mem_sound == 2 )
      mem_ff_lu := iif( _upr_yes_ff(), 1, 2 )
      yes_bukva := .f.
      For i := 1 To Len( yes_d_plus )
        If Asc( SubStr( yes_d_plus, i, 1 ) ) > 64
          yes_bukva := .t. ; Exit
        Endif
      Next
      If !yes_bukva
        yes_d_plus := "+-"  // вернуть значение по умолчанию
      Endif
      i := getinivar( tmp_ini(), { { "RAB_MESTO", "okato_umolch", "" } } )
      If i[ 1 ] != Nil .and. !Empty( i[ 1 ] )
        okato_umolch := i[ 1 ]
      Endif
    Else // запись
      For i := 1 To Len( arr )
        v := &( arr[ i, 1 ] )
        If arr[ i, 2 ] == "C"
          AAdd( ta, { arr[ i, 1 ], v } )
        Elseif arr[ i, 2 ] == "N"
          AAdd( ta, { arr[ i, 1 ], lstr( v ) } )
        Elseif arr[ i, 2 ] == "L"
          AAdd( ta, { arr[ i, 1 ], iif( v, '1', '0' ) } )
        Elseif arr[ i, 2 ] == "D"
          AAdd( ta, { arr[ i, 1 ], DToS( v ) } )
        Endif
      Next
      setinisect( tools_ini(), name_section, ta ) // запись секции в ini.файл
    Endif
    If fll
      semaphor_tools_ini( 2 )
    Endif
  Endif

  Return fl

//
Function tools_ini_pp( reg, k1, k2, fll )

  Static arr := { { "pp_NOVOR",    "N" }, ;
    { "pp_KEM_NAPR", "C" }, ;
    { "pp_POB_D_LEK", "N" }, ;
    { "pp_KOD_VR",   "N" }, ;
    { "pp_TRAVMA",   "N" }, ;
    { "pp_NE_ZAK",   "N" } }
  Local name_section := "PPOKOJ"
  Local i, j, ta := {}, v, fl

  Default k1 To 0, k2 To 0, fll To .f.
  If ( fl := iif( fll, semaphor_tools_ini( 1 ), .t. ) )
    name_section += "-" + lstr( k1 ) + "-" + lstr( k2 )
    If reg == 1 // чтение
      ta := getinisect( iif( fll, tools_ini(), local_tools_ini() ), name_section ) // вернуть двумерный массив содержимого секции {{"наим.","знач."},...}
      For j := 1 To Len( ta )
        If ( i := AScan( arr, {| x| Upper( x[ 1 ] ) == ta[ j, 1 ] } ) ) > 0
          &( arr[ i, 1 ] ) := iif( arr[ i, 2 ] == "C", ta[ j, 2 ], Int( Val( ta[ j, 2 ] ) ) )
        Endif
      Next
      mem_ortfflu := iif( _upr_yes_ff(), 1, 2 )
    Else // запись
      For i := 1 To Len( arr )
        v := &( arr[ i, 1 ] )
        AAdd( ta, { arr[ i, 1 ], iif( arr[ i, 2 ] == "C", v, lstr( v ) ) } )
      Next
      setinisect( tools_ini(), name_section, ta ) // запись секции в ini.файл
    Endif
    If fll
      semaphor_tools_ini( 2 )
    Endif
  Endif

  Return fl

//
Function tools_ini_platn( reg, k1, k2, fll )

  Static arr := { { "mem_anonim", "N" }, ;
    { "mem_naprvr", "N" }, ;
    { "mem_edit_s", "N" }, ;
    { "mem_plsoput", "N" }, ;
    { "mem_dogovor", "C" }, ;
    { "mem_pl_ms",  "N", .t. }, ;
    { "mem_pl_sn",  "N", .t. }, ;
    { "mem_ort_f8", "C" }, ;
    { "glob_close", "N" }, ;
    { "glob_pl_reg", "N" }, ;
    { "glob_kassa", "N" } }
  Local name_section := "PLATN"
  Local i, j, ta := {}, v, fl

  Default fll To .f.
  If ( fl := iif( fll, semaphor_tools_ini( 1 ), .t. ) )
    name_section += "-" + lstr( k1 ) + "-" + lstr( k2 )
    If reg == 1 // чтение
      ta := getinisect( iif( fll, tools_ini(), local_tools_ini() ), name_section ) // вернуть двумерный массив содержимого секции {{"наим.","знач."},...}
      For j := 1 To Len( ta )
        If ( i := AScan( arr, {| x| Upper( x[ 1 ] ) == ta[ j, 1 ] } ) ) > 0
          &( arr[ i, 1 ] ) := iif( arr[ i, 2 ] == "C", ta[ j, 2 ], Val( ta[ j, 2 ] ) )
          If arr[ i, 2 ] == "N" .and. Len( arr[ i ] ) == 2
            &( arr[ i, 1 ] ) := Int( Val( ta[ j, 2 ] ) )
          Endif
        Endif
      Next
      mem_ortfflu := iif( _upr_yes_ff(), 1, 2 )
    Else // запись
      For i := 1 To Len( arr )
        v := &( arr[ i, 1 ] )
        AAdd( ta, { arr[ i, 1 ], iif( arr[ i, 2 ] == "C", v, lstr( v ) ) } )
      Next
      setinisect( tools_ini(), name_section, ta ) // запись секции в ini.файл
    Endif
    If fll
      semaphor_tools_ini( 2 )
    Endif
  Endif

  Return fl

//
Function tools_ini_orto( reg, k1, k2, fll )

  Static arr := { { "mem_ort_na", "C" }, ;
    { "mem_edit_s", "N" }, ;
    { "mem_ort_sl", "C" }, ;
    { "mem_ort_ysl", "N" }, ;
    { "mem_ortotd", "N" }, ;
    { "mem_ortot1", "N" }, ;
    { "mem_ort_ms", "N" }, ;
    { "mem_ort_pl", "C" }, ;
    { "mem_ort_bp", "C" }, ;
    { "mem_ort_dog", "C" }, ;
    { "mem_ort_dat", "N" }, ;
    { "mem_ort_f39", "N" }, ;
    { "mem_ort_f8", "C" }, ;
    { "glob_kassa", "N" } }
  Local name_section := "ORTO"
  Local i, j, ta := {}, v, fl

  Default fll To .f.
  If ( fl := iif( fll, semaphor_tools_ini( 1 ), .t. ) )
    name_section += "-" + lstr( k1 ) + "-" + lstr( k2 )
    If reg == 1 // чтение
      ta := getinisect( iif( fll, tools_ini(), local_tools_ini() ), name_section ) // вернуть двумерный массив содержимого секции {{"наим.","знач."},...}
      For j := 1 To Len( ta )
        If ( i := AScan( arr, {| x| Upper( x[ 1 ] ) == ta[ j, 1 ] } ) ) > 0
          &( arr[ i, 1 ] ) := iif( arr[ i, 2 ] == "C", ta[ j, 2 ], Int( Val( ta[ j, 2 ] ) ) )
        Endif
      Next
      mem_ortfflu := iif( _upr_yes_ff(), 1, 2 )
    Else // запись
      For i := 1 To Len( arr )
        v := &( arr[ i, 1 ] )
        AAdd( ta, { arr[ i, 1 ], iif( arr[ i, 2 ] == "C", v, lstr( v ) ) } )
      Next
      setinisect( tools_ini(), name_section, ta ) // запись секции в ini.файл
    Endif
    If fll
      semaphor_tools_ini( 2 )
    Endif
  Endif

  Return fl

// настройки по вводу данных в каждой задаче
Function nastr_input( k, nTask )
  Return Nil

// 29.01.26
function mm_oms_pole()

  return { ;
    'сроки лечения', ;    // 1
    'леч.врач', ;         // 2
    'осн.диагноз', ;      // 3
    'профиль', ;          // 4
    'результат', ;        // 5
    'исход', ;            // 6
    'место обращения', ;  // 7
    'способ оплаты',  ;   // 8
    'профиль МЗ РФ' ;     // 9
  }

// 29.01.26 настройка рабочего места
Function nastr_rab_mesto()

  Static group_ini := "RAB_MESTO"
  Static mm_wdir := { { 'в папку рабочего каталога "OwnChipArchiv"', 0 }, ;
    { "в другое место", 1 } }
  Static mm_wokato := { { 'использовать значение из "Общих настроек"', 0 }, ;
    { "своя настройка на данном рабочем месте", 1 } }
  Local ar, sr, mm_tmp := {}

  Delete file tmp.dbf
  //
  Private mm_reader := { ;
    { 'нет', Space( 50 ) }, ;
    { 'подключить', '1' } ;
  }
/*
  Private mm_oms_pole := { ;
    'сроки лечения', ;    // 1
    'леч.врач', ;         // 2
    'осн.диагноз', ;      // 3
    'профиль', ;          // 4
    'результат', ;        // 5
    'исход', ;            // 6
    'место обращения', ;   // 7
    'способ оплаты' ;    // 8
  }
//    'повод обращения', ;  // 7
*/
  ar := getinisect( tmp_ini(), group_ini )
  sr := a2default( ar, 'sc_reader' )
  If !Empty( sr )
    mm_reader[ 2, 1 ] := sr
    mm_reader[ 2, 2 ] := PadR( sr, 50 )
  Endif
  AAdd( mm_tmp, { "sc_reader", "C", 50, 0, NIL, ;
    {| x| menu_reader( x, mm_reader, A__MENUVERT ) }, ;
    "", {| x| inieditspr( A__MENUVERT, mm_reader, x ) }, ;
    'Устройство чтения смарт-карт (для эл.полиса)', ;
    {|| iif( Empty( m1sc_reader ), .t., f_read_sc_reader() ) }, ;
    {|| hb_user_curUser:isadmin() } } )

  AAdd( mm_tmp, { "open_Excel", "N", 1, 0, NIL, ;
    {| x| menu_reader( x, arr_NO_YES(), A__MENUVERT ) }, ;
    1, {| x| inieditspr( A__MENUVERT, arr_NO_YES(), x ) }, ;
    'При установленном Excel, открывать автоматически' } )

  AAdd( mm_tmp, { "base_copy", "N", 1, 0, NIL, ;
    {| x| menu_reader( x, mm_danet, A__MENUVERT ) }, ;
    1, {| x| inieditspr( A__MENUVERT, mm_danet, x ) }, ;
    'Выполнять автоматическое резервное копирование при выходе из программы',, ;
    {|| hb_user_curUser:isadmin() } } )
  AAdd( mm_tmp, { "wdir", "N", 1, 0, NIL, ;
    {| x| menu_reader( x, mm_wdir, A__MENUVERT ) }, ;
    0, {| x| inieditspr( A__MENUVERT, mm_wdir, x ) }, ;
    '└> куда выполняется копирование', ;
    {|| iif( Empty( m1wdir ), ( mpath_copy := m1path_copy := Space( 100 ), update_get( "mpath_copy" ) ), .t. ) }, ;
    {|| hb_user_curUser:isadmin() .and. m1base_copy == 1 } } )
  AAdd( mm_tmp, { "path_copy", "C", 100, 0, NIL, ;
    {| x| menu_reader( x, { {| k, r, c| mng_dir( k, r, c, "path_copy" ) } }, A__FUNCTION ) }, ;
    " ", {| x| x }, ;
    ' └> каталог для копирования',, ;
    {|| hb_user_curUser:isadmin() .and. m1base_copy == 1 .and. m1wdir == 1 } } )
  AAdd( mm_tmp, { "kart_polis", "N", 1, 0, NIL, ;
    {| x| menu_reader( x, mm_danet, A__MENUVERT ) }, ;
    1, {| x| inieditspr( A__MENUVERT, mm_danet, x ) }, ;
    'В режиме добавления в картотеку производить поиск пациента по полису' } )
  AAdd( mm_tmp, { 'e_1', 'C', 1, 0, NIL,, '',, ;
    'Какие поля запоминать и переносить в следующий добавляемый случай при вводе',, ;
    {|| .f. } } )
  AAdd( mm_tmp, { 'oms_pole', 'N', 15, 0, NIL, ;
    {| x| menu_reader( x, mm_oms_pole(), A__MENUBIT ) }, ;
    0, {| x| inieditspr( A__MENUBIT, mm_oms_pole(), x ) }, ;
    'л/у ОМС:' } )
  AAdd( mm_tmp, { 'wokato', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_wokato, A__MENUVERT ) }, ;
    0, {| x| inieditspr( A__MENUVERT, mm_wokato, x ) }, ;
    'Какое ОКАТО по умолчанию использовать', ;
    {|| iif( Empty( m1wokato ), ( m_okato := Space( 70 ), m1_okato := Space( 11 ), update_get( "m_okato" ) ), .t. ) } } )
  AAdd( mm_tmp, { "_okato", "C", 11, 0, NIL, ;
    {| x| menu_reader( x, { {|k, r, c| get_okato_ulica( k, r, c, { k, m_okato, } ) } }, A__FUNCTION ) }, ;
    Space( 11 ), {| x| ret_okato_ulica( '', x ) }, ;
    '└> ОКАТО по умолчанию',, ;
    {|| m1wokato == 1 } } )
  If is_obmen_sds()
    AAdd( mm_tmp, { "e_2", "C", 1, 0, NIL,, "",, ;
      'Каталоги для обмена информацией с программой Smart Delta Systems:',, ;
      {|| .f. } } )
    AAdd( mm_tmp, { "path1_sds", "C", 100, 0, NIL, ;
      {| x| menu_reader( x, { {| k, r, c| mng_dir( k, r, c, "path1_sds" ) } }, A__FUNCTION ) }, ;
      " ", {| x| x }, ;
      '==> для импорта картотеки',, ;
      {|| hb_user_curUser:isadmin() } } )
    AAdd( mm_tmp, { "path2_sds", "C", 100, 0, NIL, ;
      {| x| menu_reader( x, { {| k, r, c| mng_dir( k, r, c, "path2_sds" ) } }, A__FUNCTION ) }, ;
      " ", {| x| x }, ;
      '==> для обработанных файлов',, ;
      {|| hb_user_curUser:isadmin() } } )
  Endif
  init_base( cur_dir() + "tmp",, mm_tmp, 0 )
  Use ( cur_dir() + "tmp" ) new
  Append Blank
  tmp->sc_reader := sr
  tmp->open_Excel := Int( Val( a2default( ar, 'open_Excel', '0' ) ) )
  tmp->base_copy := Int( Val( a2default( ar, "base_copy", "1" ) ) )
  tmp->path_copy := a2default( ar, "path_copy", "" )
  tmp->wdir := iif( Empty( tmp->path_copy ), 0, 1 )
  tmp->kart_polis := Int( Val( a2default( ar, "kart_polis", "1" ) ) )
  tmp->oms_pole := Int( Val( a2default( ar, "oms_pole", "0" ) ) )
  tmp->_okato := a2default( ar, "okato_umolch", "" )
  tmp->wokato := iif( Empty( tmp->_okato ), 0, 1 )
  If is_obmen_sds()
    tmp->path1_sds := a2default( ar, "path1_sds", "" )
    tmp->path2_sds := a2default( ar, "path2_sds", "" )
  Endif
  Close databases
  If f_edit_spr( A__EDIT, mm_tmp, "настройке рабочего места", "g_use(cur_dir()+'tmp',,,.t.,.t.)", 0, 1 ) > 0
    Use ( cur_dir() + "tmp" ) new
    mm_tmp := { ;
      { group_ini, "sc_reader",   tmp->sc_reader }, ;
      { group_ini, "base_copy",   tmp->base_copy }, ;
      { group_ini, "path_copy",   tmp->path_copy }, ;
      { group_ini, "kart_polis",  tmp->kart_polis }, ;
      { group_ini, "oms_pole",    tmp->oms_pole }, ;
      { group_ini, "okato_umolch", tmp->_okato }, ;
      { group_ini, "open_Excel", tmp->open_Excel } ;
    }
    If is_obmen_sds()
      AAdd( mm_tmp, { group_ini, "path1_sds", AllTrim( tmp->path1_sds ) } )
      AAdd( mm_tmp, { group_ini, "path2_sds", AllTrim( tmp->path2_sds ) } )
    Endif
    setinivar( tmp_ini(), mm_tmp )
  Endif
  Close databases

  Return Nil

#define SW_HIDE 0
#define SW_SHOWNORMAL 1

//
Function f_read_sc_reader()

  Static max_seconds := 20
  Static name_ini := "SCreader.ini", group_ini := "SCreader"
  Static task_polis := "ReadEPolis.exe"
  Static smsg := "Неудачная попытка в определении списка ридеров"
  Local fl := .f., t1 := Seconds(), ar, sr, se, buf := save_maxrow()

  mywait( "Определение списка ридеров" )
  If hb_FileExists( dir_exe() + task_polis )
    Do While Seconds() - t1 < max_seconds
      If hb_FileExists( name_ini )
        Delete File ( name_ini )
      Else
        Exit
      Endif
    Enddo
    shellexecute( getdesktopwindow(), ;
      'open', ;
      dir_exe() + task_polis, ;
      '-rdl', ;
      , ;
      SW_HIDE )
    t1 := Seconds()
    Do While Seconds() - t1 < max_seconds
      If hb_FileExists( name_ini )
        If !Empty( ar := getinisect( name_ini, group_ini ) )
          sr := a2default( ar, "reader" )
          se := hb_ANSIToOEM( a2default( ar, "error" ) )
          If !Empty( sr )
            fl := .t.
            msc_reader := m1sc_reader := sr
            mm_reader[ 2, 1 ] := mm_reader[ 2, 2 ] := sr
          Else
            fl := func_error( 4, iif( Empty( se ), smsg + ".", se ) )
          Endif
          Exit
        Endif
      Endif
      Millisec( 10 )
    Enddo
    If !hb_FileExists( name_ini )
      fl := func_error( 4, smsg + "!" )
    Endif
  Else
    fl := func_error( 4, "Не обнаружен файл: " + dir_exe() + task_polis )
  Endif
  If !fl
    msc_reader := "нет"
    m1sc_reader := Space( 50 )
  Endif
  rest_box( buf )

  Return .t.

//
Function f_read_sc_polis()

  Static max_seconds := 20
  Static name_ini := "SCreader.ini", group_ini := "SCreader"
  Static task_polis := "ReadEPolis.exe"
  Static smsg := "Неудачная попытка чтения электронного полиса"
  Local fl := .t., t1 := Seconds(), ar, se, buf := save_maxrow()

  mywait( "Чтение электронного полиса" )
  If hb_FileExists( dir_exe() + task_polis )
    Do While Seconds() - t1 < max_seconds
      If hb_FileExists( name_ini )
        Delete File ( name_ini )
      Else
        Exit
      Endif
    Enddo
    shellexecute( getdesktopwindow(), ;
      'open', ;
      dir_exe() + task_polis, ;
      '-roi="' + name_reader + '"', ;
      , ;
      SW_HIDE )
    t1 := Seconds()
    Do While Seconds() - t1 < max_seconds
      If hb_FileExists( name_ini )
        If !Empty( ar := getinisect( name_ini, group_ini ) )
          arr_epolis[ _EP_OGRN   ] :=              a2default( ar, "OGRN" )
          arr_epolis[ _EP_OKATO  ] :=              a2default( ar, "OKATO" )
          arr_epolis[ _EP_FAM    ] := hb_ANSIToOEM( a2default( ar, "FAM" ) )
          arr_epolis[ _EP_IM     ] := hb_ANSIToOEM( a2default( ar, "IM" ) )
          arr_epolis[ _EP_OT     ] := hb_ANSIToOEM( a2default( ar, "OT" ) )
          arr_epolis[ _EP_W      ] :=              a2default( ar, "W" )
          arr_epolis[ _EP_DR     ] :=              a2default( ar, "DR" )
          arr_epolis[ _EP_MR     ] := hb_ANSIToOEM( a2default( ar, "MR" ) )
          arr_epolis[ _EP_NPOLIS ] :=              a2default( ar, "NPOLIS" )
          arr_epolis[ _EP_D_BEGIN ] :=              a2default( ar, "D_BEGIN" )
          arr_epolis[ _EP_D_END  ] :=              a2default( ar, "D_END" )
          arr_epolis[ _EP_SNILS  ] :=              a2default( ar, "SNILS" )
          se := hb_ANSIToOEM( a2default( ar, "error" ) )
          Exit
        Endif
      Endif
      Millisec( 10 )
    Enddo
    If !hb_FileExists( name_ini )
      fl := func_error( 4, smsg + "!" )
    Endif
  Else
    fl := func_error( 4, "Не обнаружен файл: " + dir_exe() + task_polis )
  Endif
  If fl
    If emptyall( arr_epolis[ _EP_OGRN ], arr_epolis[ _EP_OKATO ], arr_epolis[ _EP_FAM ], ;
        arr_epolis[ _EP_IM ], arr_epolis[ _EP_NPOLIS ] )
      fl := func_error( 4, iif( Empty( se ), smsg + ".", se ) )
    Else
      r_use( dir_exe() + "_mo_smo", cur_dir() + "_mo_smo3", "_SMO" )
      find ( arr_epolis[ _EP_OKATO ] + PadR( arr_epolis[ _EP_OGRN ], 13 ) )
      If Found()
        arr_epolis[ _EP_SMO ] := _smo->smo
        arr_epolis[ _EP_NAMESMO ] := AllTrim( _smo->name )
      Else
        func_error( 4, "Не найдена СМО (ОКАТО=" + arr_epolis[ _EP_OKATO ] + ", ОГРН=" + RTrim( arr_epolis[ _EP_OGRN ] ) + ")" )
      Endif
      _smo->( dbCloseArea() )
      arr_epolis[ _EP_W      ] := iif( arr_epolis[ _EP_W ] == "1", "М", "Ж" )
      arr_epolis[ _EP_DR     ] := xml2date( arr_epolis[ _EP_DR ] )
      arr_epolis[ _EP_D_BEGIN ] := xml2date( arr_epolis[ _EP_D_BEGIN ] )
      arr_epolis[ _EP_D_END  ] := xml2date( arr_epolis[ _EP_D_END ] )
      arr_epolis[ _EP_SNILS  ] := CharRem( " -", arr_epolis[ _EP_SNILS ] )
    Endif
  Endif
  rest_box( buf )

  Return fl

// 12.09.25
Function mo_read_el_polis( /*@*/k)

  Local fl := .f., rec := 0, mfio, mdate_r, arr, buf := SaveScreen()
  Private arr_epolis[ _EP_LEN ]

  AFill( arr_epolis, "" )
  If f_read_sc_polis()
    mfio := AllTrim( arr_epolis[ _EP_FAM ] ) + " " + ;
      AllTrim( arr_epolis[ _EP_IM ] ) + " " + ;
      AllTrim( arr_epolis[ _EP_OT ] )
    mdate_r := arr_epolis[ _EP_DR ]
    r_use( dir_server() + "kartotek", dir_server() + "kartotep", "KART" )
    find ( "1" + PadR( arr_epolis[ _EP_NPOLIS ], 17 ) )
    If Found()
      rec := RecNo()
    Else
      mfio := PadR( Upper( mfio ), 50 )
      Set Index to ( dir_server() + "kartoten" )
      find ( "1" + mfio + DToS( mdate_r ) )
      If Found()
        rec := RecNo()
      Endif
    Endif
    If rec > 0
      r_use( dir_server() + "kartote2",, "KART2" )
      Goto ( rec )
      r_use( dir_server() + "kartote_",, "KART_" )
      Goto ( rec )
      kartotek_to_screen( 1, 8 )
      @ 0, 0 To 9, 79 Color "G+/B"
      str_center( 0, " В картотеке найден пациент ", "G+/RB" )
    Endif
    clrlines( 10, 19, color1 )
    @ 11, 2 Say "Ф.И.О.: " + PadR( mfio, 50 ) + Space( 7 ) + iif( arr_epolis[ _EP_W ] == "М", "мужчина", "женщина" ) Color color8
    @ 12, 2 Say "Дата рождения: " + full_date( arr_epolis[ _EP_DR ] ) Color color8
    @ 13, 2 Say "СНИЛС: " + Transform( arr_epolis[ _EP_SNILS ], picture_pf() ) Color color8
    @ 14, 2 Say "Место рождения: " + AllTrim( arr_epolis[ _EP_MR ] ) Color color8
    @ 15, 2 Say "Полис ОМС: " + AllTrim( arr_epolis[ _EP_NPOLIS ] ) Color color8
    @ 16, 2 Say "           действителен с " + full_date( arr_epolis[ _EP_D_BEGIN ] ) + " по " + full_date( arr_epolis[ _EP_D_END ] ) Color color8
    @ 17, 2 Say "СМО: " + iif( Empty( arr_epolis[ _EP_NAMESMO ] ), "не найдена, ОГРН: " + arr_epolis[ _EP_OGRN ], AllTrim( arr_epolis[ _EP_NAMESMO ] ) ) Color color8
    @ 18, 2 Say "Субъект РФ территории страхования: " + inieditspr( A__MENUVERT, glob_array_srf(), arr_epolis[ _EP_OKATO ] ) Color color8
    @ 10, 0 To 19, 79 double Color color8
    str_center( 10, " Информация с электронного полиса ", "GR+/R" )
    fillscrarea( 20, 0, 24, 79, "░", color1 )
    Close databases
    k := 2 ; arr := { " Отказ от записи ", " Добавить в картотеку " }
    If rec > 0
      k := 3 ; AAdd( arr, " Перезаписать " )
    Endif
    k := f_alert( { PadC( "Выберите действие", 60, "." ) }, arr, ;
      k, "W+/N", "N+/N", 20,, "W+/N,N/BG" )
    If k > 1
      If k == 2 // при добавлении
        rec := 0 // обнуляем значение номера записи
      Endif
      use_base( "kartotek" )
      If rec == 0  // добавление в картотеку
        add1rec( 7 )
        kart->kod := RecNo()
        kart->PC3 := '000'
      Else
        Goto ( rec )
        g_rlock( forever )
      Endif
      glob_kartotek := kart->kod
      glob_k_fio    := AllTrim( mfio )
      kart->FIO     := mfio
      kart->pol     := arr_epolis[ _EP_W ]
      kart->DATE_R  := arr_epolis[ _EP_DR ]
      kart->POLIS   := arr_epolis[ _EP_NPOLIS ]
      kart->srok_polis := dtoc4( arr_epolis[ _EP_D_END ] )
      If !Empty( arr_epolis[ _EP_SNILS ] )
        kart->snils := arr_epolis[ _EP_SNILS ]
      Endif
      newMEST_INOG := 0
      If twowordfamimot( arr_epolis[ _EP_FAM ] ) ;
          .or. twowordfamimot( arr_epolis[ _EP_IM ] ) ;
          .or. twowordfamimot( arr_epolis[ _EP_OT ] )
        newMEST_INOG := 9
      Endif
      kart->MEST_INOG := newMEST_INOG
      Select KART_
      Do While kart_->( LastRec() ) < glob_kartotek
        Append Blank
      Enddo
      Goto ( glob_kartotek )
      g_rlock( forever )
      kart_->VPOLIS := 3
      kart_->SPOLIS := ""
      kart_->NPOLIS := arr_epolis[ _EP_NPOLIS ]
      kart_->SMO    := arr_epolis[ _EP_SMO ]
      kart_->beg_polis := dtoc4( arr_epolis[ _EP_D_BEGIN ] )
      kart_->mesto_r  := arr_epolis[ _EP_MR ]
      kart_->KVARTAL_D := arr_epolis[ _EP_OKATO ]
      If newMEST_INOG == 9
        g_use( dir_server() + "mo_kfio",, "KFIO" )
        Index On Str( kod, 7 ) to ( cur_dir() + "tmp_kfio" )
        find ( Str( glob_kartotek, 7 ) )
        If Found()
          g_rlock( forever )
        Else
          addrec( 7 )
          kfio->kod := glob_kartotek
        Endif
        kfio->FAM := arr_epolis[ _EP_FAM ]
        kfio->IM  := arr_epolis[ _EP_IM ]
        kfio->OT  := arr_epolis[ _EP_OT ]
      Endif
      Close databases
      setinisect( tmp_ini(), "polikl1", { { "s_regim", "1" }, { "s_shablon", "" }, { "s_polis", "" }, { "s_snils", "" } } )
      fl := .t.
    Endif
  Endif
  RestScreen( buf )

  Return fl

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
            elseif human->POL == "Ж" .and. ascan(arr2g_vozrast_DVN,mdvozrast) > 0
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
      elseif human->POL == "Ж" .and. ascan(arr2g_vozrast_DVN,mdvozrast) > 0
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

// 10.04.19 поискать отделение по типу л/у (и м.б.по профилю) (и м.б. по врачу)
Static Function ret_otd_with_lu_prof( lpodr, lump, llu, lprof, lvrach )

  // lpodr  - код подразделения
  // lump   - условия оказания мед.помощи
  // llu    - тип листа учёта
  // lprof  - профиль
  // lvrach - врач
  Static such_otd := { 1, 2 } // для Калачевской ЦРБ
  Local uch_otd := { 0, 0 }
  Select OTD
  If llu > 0
    Set Order To 1
    find ( Str( llu, 2 ) )
    If Found()
      uch_otd := { otd->kod_lpu, otd->kod }
    Endif
  Elseif lpodr > 0
    Set Order To 3
    find ( Str( lpodr, 3 ) + Str( lump, 2 ) )
    If Found()
      uch_otd := { otd->kod_lpu, otd->kod }
    Else
      find ( Str( lpodr, 3 ) )
      If Found()
        uch_otd := { otd->kod_lpu, otd->kod }
      Endif
    Endif
  Elseif lvrach > 0 // в справочнике персонала стоит учреждение + отделение
    perso->( dbGoto( lvrach ) )
    If emptyany( perso->uch, perso->otd )
      If lprof > 0
        Select OTD
        Set Order To 2
        find ( Str( lprof, 3 ) + Str( lump, 2 ) )
        If Found()
          uch_otd := { otd->kod_lpu, otd->kod }
        Else
          find ( Str( lprof, 3 ) )
          If Found()
            uch_otd := { otd->kod_lpu, otd->kod }
          Endif
        Endif
      Endif
    Else
      uch_otd := { perso->uch, perso->otd }
    Endif
  Elseif lprof > 0
    Set Order To 2
    find ( Str( lprof, 3 ) + Str( lump, 2 ) )
    If Found()
      uch_otd := { otd->kod_lpu, otd->kod }
    Else
      find ( Str( lprof, 3 ) )
      If Found()
        uch_otd := { otd->kod_lpu, otd->kod }
      Endif
    Endif
  Endif
  If emptyany( uch_otd[ 1 ], uch_otd[ 2 ] )
    uch_otd := AClone( such_otd )
  Endif

  Return uch_otd

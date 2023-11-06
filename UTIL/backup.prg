#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

#define COMPRESSION 3
#define YEAR_COMPRESSION 2

// 05.05.21 запуск режима резервного копирования из меню
Function m_copy_db( par )
  // par - 1 - резервная копия на диск
  // 2 - резервная копия на FTP-сервер
  // 3 - авторезервирование
  Local s, zip_file

  If ( zip_file := create_zip( par, '' ) ) == nil
    Return Nil
  Endif
  // дальнейшая работа с архивом
  If par == 1
    saveto( cur_dir + zip_file )
  Elseif par == 2
    mywait( 'Отправка "' + zip_file + '" на FTP-сервер службы поддержки' )
    If filetoftp( zip_file )
      stat_msg( 'Файл ' + zip_file + ' успешно отправлен на сервер!' )
    Else
      stat_msg( 'Ошибка отпрвки файла ' + zip_file + ' на сервер!' )
    Endif
    hb_vfErase( zip_file )
  Endif
  mybell( 2, OK )

  Return Nil

// 05.05.21 запуск режима резервного копирования из f_end()
Function m_copy_db_from_end( del_last, spath )
  Local hCurrent, hFile, nSize, fl := .t., ta, zip_file, ;
    i, k, arr_f, dir_archiv := cur_dir + 'OwnChipArchiv'

  Default del_last To .f., spath To ''

  If !Empty( spath )
    dir_archiv := AllTrim( spath )
    If Right( dir_archiv, 1 ) == cslash
      dir_archiv := Left( dir_archiv, Len( dir_archiv ) -1 )
    Endif
  Endif
  If !hb_DirExists( dir_archiv )
    If hb_DirCreate( dir_archiv ) != 0
      Return func_error( 4, 'Невозможно создать подкаталог для архивирования!' )
    Endif
  Endif
  dir_archiv += cslash
  // все уже сохранённые архивы - в массив
  arr_f := Directory( dir_archiv + 'mo*' + szip )
  ta := Directory( dir_archiv + 'mo*' + schip )
  For i := 1 To Len( ta )
    AAdd( arr_f, AClone( ta[ i ] ) )
  Next
  If ( k := Len( arr_f ) ) > 0
    // сортируем файлы
    ASort( arr_f, , , {| x, y | iif( x[ 3 ] == y[ 3 ], x[ 4 ] < y[ 4 ], x[ 3 ] < y[ 3 ] ) } )
    // запомним размер последнего архива
    nSize := arr_f[ k, 2 ] * 1.5 // для надёжности резервируем больше в 1.5 раза
    // проверяем дату и время последнего файла
    If arr_f[ k, 3 ] == sys_date // если сегодня уже сохраняли
      hCurrent := Int( Val( SecToTime( Seconds() ) ) )
      hFile := Int( Val( arr_f[ k, 4 ] ) )
      fl := ( del_last .or. ( hCurrent - hFile ) > 1 ) // прошло заведомо более 1 часа
      If fl
        hb_vfErase( dir_archiv + arr_f[ k, 1 ] ) // удалим сегодняшний архив
        --k
      Endif
    Endif
  Endif
  If fl .and. k > 4 // оставляем только 4 последних архива
    For i := 1 To k -4
      hb_vfErase( dir_archiv + arr_f[ i, 1 ] ) // удалим лишний архив
    Next
  Endif
  If fl .and. k > 0 .and. DiskSpace() < nSize // недостаточно места для архивирования
    For i := 1 To k
      If hb_vfExists( dir_archiv + arr_f[ i, 1 ] )
        hb_vfErase( dir_archiv + arr_f[ i, 1 ] ) // удалим лишний архив
        If DiskSpace() > nSize // уже достаточно места?
          Exit  // выход из цикла
        Endif
      Endif
    Next
  Endif
  If fl
    zip_file := create_zip( 3, dir_archiv )
  Endif

  Return fl

// 20.11.21
Function fillzip( arr_f, sFileName )
  Local hZip, aGauge, cFile
  Local lCompress, nLen

  If Empty( arr_f )
    sFileName := ''
  Else
    hb_vfErase( sFileName )

    nLen := Len( arr_f )
    aGauge := gaugenew( , , { 'R/BG*', 'R/BG*', 'R/BG*' }, 'Создание архива ' + hb_FNameNameExt( sFileName ), .t. )

    // lCompress := hb_ZipFile( sFileName, arr_f, COMPRESSION, ;
    // , ;
    // .t., , .f., ,  )
    lCompress := hb_ZipFile( sFileName, arr_f, COMPRESSION, ;
      {| cFile, nPos | gaugedisplay( aGauge ), stat_msg( 'Добавление в архив файла ' + hb_FNameNameExt( cFile ) + ' ( ' + AllTrim( lstr( nPos ) ) + ' из ' + AllTrim( lstr( nLen ) ) + ' )' ) }, ;
      .t., , .f., , {| nPos, nLen | gaugeupdate( aGauge, nPos / nLen ) } )
    If ! lCompress
      sFileName := ''
    Endif
    closegauge( aGauge ) // Закроем окно отображения бегунка
  Endif

  Return sFileName

// 06.11.23
Function create_zip( par, dir_archiv )
  Static sast := '*', sfile_begin := '_begin.txt', sfile_end := '_end.txt'
  Local arr_f, ar
  Local blk := {| x | f_aadd_copy_db( arr_f, x ) }
  Local hZip, i, cPassword, fl := .t., aGauge, s, y
  Local cFile, nLen
  Local zip_file
  Local buf := SaveScreen()
  Local zip_xml_mo, zip_xml_tf, zip_napr_mo, zip_napr_tf

  // Local time_zip := 0, t1

  // t1 := seconds()

  zip_xml_mo := zip_xml_tf := zip_napr_mo := zip_napr_tf := ''
  If par == 1
    If ! g_slock1task( sem_task, sem_vagno )  // запрет доступа всем
      func_error( 4, 'В данный момент работают другие задачи. Копирование запрещено!' )
      Return Nil
    Endif
  Endif
  If par == 3 .or. f_esc_enter( 'резервного копирования' )

    f_message( { 'Внимание! Создаётся архив базы данных.', ;
      '', ;
      'Во избежание разрушения данных', ;
      'не прерывайте процесс!' }, , 'GR+/R', 'W+/R', 13 )

    // формируем имена архивов
    zip_file := 'mo' + AllTrim( glob_mo[ _MO_KOD_TFOMS ] ) + '_' + DToS( sys_date ) + ;
      Lower( iif( par != 3, szip, schip ) )

    zip_xml_mo := dir_XML_MO + szip
    zip_xml_tf := dir_XML_TF + szip
    zip_napr_mo := dir_NAPR_MO + szip
    zip_napr_tf := dir_NAPR_TF + szip

    hb_vfErase( sfile_begin )
    hb_MemoWrit( sfile_begin, full_date( sys_date ) + ' ' + Time() + ' ' + hb_OEMToANSI( fio_polzovat ) )

    //
    arr_f := {}
    scandirfiles_for_backup( dir_server + dir_XML_MO + cslash, sast + szip, blk, AddMonth(date(), -(12 * YEAR_COMPRESSION)) )
    scandirfiles_for_backup( dir_server + dir_XML_MO + cslash, sast + scsv, blk, AddMonth(date(), -(12 * YEAR_COMPRESSION)) )

    zip_xml_mo := fillzip( arr_f, zip_xml_mo )

    //
    arr_f := {}
    scandirfiles_for_backup( dir_server + dir_XML_TF + cslash, sast + szip, blk, AddMonth(date(), -(12 * YEAR_COMPRESSION)) )
    scandirfiles_for_backup( dir_server + dir_XML_TF + cslash, sast + scsv, blk, AddMonth(date(), -(12 * YEAR_COMPRESSION)) )
    scandirfiles_for_backup( dir_server + dir_XML_TF + cslash, sast + stxt, blk, AddMonth(date(), -(12 * YEAR_COMPRESSION)) )

    zip_xml_tf := fillzip( arr_f, zip_xml_tf )

    //
    arr_f := {}
    scandirfiles_for_backup( dir_server + dir_NAPR_MO + cslash, sast + szip, blk, AddMonth(date(), -(12 * YEAR_COMPRESSION)) )
    scandirfiles_for_backup( dir_server + dir_NAPR_MO + cslash, sast + stxt, blk, AddMonth(date(), -(12 * YEAR_COMPRESSION)) )

    zip_napr_mo := fillzip( arr_f, zip_napr_mo )

    //
    arr_f := {}
    scandirfiles_for_backup( dir_server + dir_NAPR_TF + cslash, sast + szip, blk, AddMonth(date(), -(12 * YEAR_COMPRESSION)) )
    scandirfiles_for_backup( dir_server + dir_NAPR_TF + cslash, sast + stxt, blk, AddMonth(date(), -(12 * YEAR_COMPRESSION)) )

    zip_napr_tf := fillzip( arr_f, zip_napr_tf )

    hb_vfErase( dir_archiv + zip_file )

    // сначала прочие файлы
    ar := { sfile_begin, ;
      tools_ini, ;
      f_stat_lpu, ;
      dir_server + 'f39_nast' + sini, ;
      dir_server + 'usl1year' + smem, ;
      dir_server + 'error' + stxt }
    If ! Empty( zip_xml_mo )
      AAdd( ar, cur_dir + zip_xml_mo )
    Endif
    If ! Empty( zip_xml_tf )
      AAdd( ar, cur_dir + zip_xml_tf )
    Endif
    If ! Empty( zip_napr_mo )
      AAdd( ar, cur_dir + zip_napr_mo )
    Endif
    If ! Empty( zip_napr_tf )
      AAdd( ar, cur_dir + zip_napr_tf )
    Endif

    For i := 1 To Len( array_files_DB )
      cFile := Upper( array_files_DB[ i ] ) + sdbf
      If hb_vfExists( dir_server + cFile )
        AAdd( ar, dir_server + cFile )
      Endif
    Next

    // а теперь файлы WQ...
    arr_f := {}
    y := Year( sys_date )
    // только текущий год
    scandirfiles_for_backup( dir_server, 'mo_wq' + SubStr( Str( y, 4 ), 3 ) + '*' + sdbf, {| x | AAdd( arr_f, x ) }, AddMonth(date(), -(12 * YEAR_COMPRESSION)) )
    For i := 1 To Len( arr_f )
      AAdd( ar, arr_f[ i ] )
    Next

    nLen := Len( ar )
    aGauge := gaugenew( , , { 'R/BG*', 'R/BG*', 'R/BG*' }, 'Создание архива ' + zip_file, .t. )

    // lCompress := hb_ZipFile( dir_archiv + zip_file, ar, COMPRESSION, ;
    // , ;
    // .t., , .f., , )
    lCompress := hb_ZipFile( dir_archiv + zip_file, ar, COMPRESSION, ;
      {| cFile, nPos | gaugedisplay( aGauge ), stat_msg( 'Добавление в архив файла ' + hb_FNameNameExt( cFile ) + ' ( ' + AllTrim( lstr( nPos ) ) + ' из ' + AllTrim( lstr( nLen ) ) + ' )' ) }, ;
      .t., , .f., , {| nPos, nLen | gaugeupdate( aGauge, nPos / nLen ) } )
    closegauge( aGauge ) // Закроем окно отображения бегунка

    If ! lCompress
      fl := func_error( 4, 'Возникла ошибка при архивировании базы данных.' )
    Endif

    // time_zip := seconds() - t1

    // if fl .and. time_zip > 0
    // n_message({'', 'Время создания резервной копии - ' + sectotime(time_zip)}, , ;
    // color1, cDataCSay, , , color8)
    // endif

    hb_vfErase( sfile_end )
    hb_MemoWrit( sfile_end, full_date( sys_date ) + ' ' + Time() + ' ' + hb_OEMToANSI( fio_polzovat ) )

    RestScreen( buf )
  Endif

  // удаляем ненужные архивы
  If ! Empty( zip_xml_mo )
    hb_vfErase( zip_xml_mo )
  Endif
  If ! Empty( zip_xml_tf )
    hb_vfErase( zip_xml_tf )
  Endif
  If !Empty( zip_napr_mo )
    hb_vfErase( zip_napr_mo )
  Endif
  If !Empty( zip_napr_tf )
    hb_vfErase( zip_napr_tf )
  Endif

  // разрешение доступа всем
  If par == 1
    g_sunlock( sem_vagno )
  Endif
  Keyboard ''
  If ! fl
    Return Nil
  Endif

  Return zip_file

// 04.05.21
Function f_aadd_copy_db( arr_f, x )

  Local fl := .t., s, y

  x := Upper( x )
  If eq_any( Right( x, 4 ), szip, stxt )
    s := strippath( x )
    // реестры, ФЛК и счета
    If eq_any( Left( s, 3 ), 'FRM', 'HRM' ) .or. eq_any( Left( s, 4 ), 'PFRM', 'PHRM' ) ;
        .or. eq_any( Left( s, 2 ), 'I0', 'FM', 'HM', 'AT', 'AS', 'DT', 'DS' )
      y := Int( Val( Left( AfterAtNum( '_', s ), 2 ) ) )
      fl := ( y > 19 )  // с 2020 года
    Elseif eq_any( Left( s, 3 ), 'FRT', 'HRT' )
      y := Int( Val( SubStr( s, 14, 2 ) ) )
      fl := ( y > 19 )  // с 2020 года
    Endif
  Endif
  If fl
    AAdd( arr_f, x )
  Endif

  Return Nil

// 06.11.23 то же, что и ScanFiles, но по одной директории cPath
FUNCTION scandirfiles_for_backup(cPath, cFilespec, blk, afterDate)
  LOCAL cFile

  DEFAULT cPath TO '', cFilespec TO '*.*'
  default afterDate to AddMonth(date(), -12)  //один год
  cFile := FILESEEK(cPath + cFileSpec , 32)
  DO WHILE !EMPTY(cFile)
    if FileDate() >= afterDate
      eval(blk, cPath + cFile)         // вызов блока кода для каждого файла
    endif
    cFile := FILESEEK()              // следующий файл
  ENDDO
  RETURN NIL                         // возвращаемое значение неважно
  
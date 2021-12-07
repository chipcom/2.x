#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

#define COMPRESSION 3

***** 05.05.21 запуск режима резервного копирования из меню
Function m_copy_DB(par)
  // par - 1 - резервная копия на диск
  //       2 - резервная копия на FTP-сервер
  //       3 - авторезервирование
  local s, zip_file

  if ( zip_file := create_ZIP( par, '' ) ) == nil
    return nil
  endif
  // дальнейшая работа с архивом
  if par == 1
    SaveTo(cur_dir + zip_file)
  elseif par == 2
    mywait( 'Отправка "' + zip_file + '" на FTP-сервер службы поддержки' )
    if fileToFTP( zip_file )
      stat_msg( 'Файл ' + zip_file + ' успешно отправлен на сервер!' )
    else
      stat_msg( 'Ошибка отпрвки файла ' + zip_file + ' на сервер!' )
    endif
    HB_VFERASE( zip_file )
  endif
  mybell( 2, OK )

  return NIL

***** 05.05.21 запуск режима резервного копирования из f_end()
function m_copy_DB_from_end( del_last, spath )
  local hCurrent, hFile, nSize, fl := .t., ta, zip_file, ;
        i, k, arr_f, dir_archiv := cur_dir + 'OwnChipArchiv'

  DEFAULT del_last TO .f., spath TO ''

  if !empty( spath )
    dir_archiv := alltrim( spath )
    if right( dir_archiv, 1 ) == cslash
      dir_archiv := left( dir_archiv, len( dir_archiv ) - 1 )
    endif
  endif
  if !hb_DirExists( dir_archiv )
    if hb_DirCreate( dir_archiv ) != 0
      return func_error( 4, 'Невозможно создать подкаталог для архивирования!' )
    endif
  endif
  dir_archiv += cslash
  // все уже сохранённые архивы - в массив
  arr_f := directory( dir_archiv + 'mo*' + szip )
  ta := directory( dir_archiv + 'mo*' + schip )
  for i := 1 to len( ta )
    aadd( arr_f, aclone( ta[ i ] ) )
  next
  if (k := len( arr_f )) > 0
    // сортируем файлы
    asort( arr_f, , , { | x, y | iif( x[ 3 ] == y[ 3 ], x[ 4 ] < y[ 4 ], x[ 3 ] < y[ 3 ] ) } )
    // запомним размер последнего архива
    nSize := arr_f[ k, 2 ] * 1.5 // для надёжности резервируем больше в 1.5 раза
    // проверяем дату и время последнего файла
    if arr_f[ k, 3 ] == sys_date // если сегодня уже сохраняли
      hCurrent := int( val( sectotime( seconds() ) ) )
      hFile := int( val( arr_f[ k, 4 ] ) )
      fl := ( del_last .or. ( hCurrent - hFile ) > 1 ) // прошло заведомо более 1 часа
      if fl
        hb_vfErase( dir_archiv + arr_f[ k, 1 ] ) // удалим сегодняшний архив
        --k
      endif
    endif
  endif
  if fl .and. k > 4 // оставляем только 4 последних архива
    for i := 1 to k - 4
      hb_vfErase( dir_archiv + arr_f[ i, 1 ] ) // удалим лишний архив
    next
  endif
  if fl .and. k > 0 .and. diskspace() < nSize // недостаточно места для архивирования
    for i := 1 to k
      if hb_vfExists( dir_archiv + arr_f[ i, 1 ] )
        hb_vfErase( dir_archiv + arr_f[ i, 1 ] ) // удалим лишний архив
        if diskspace() > nSize // уже достаточно места?
          exit  // выход из цикла
        endif
      endif
    next
  endif
  if fl
    zip_file := create_ZIP( 3, dir_archiv )
  endif
  return fl

***** 20.11.21
function fillZIP( arr_f, sFileName )
  local hZip, aGauge, cFile
  local lCompress, nLen

  if empty( arr_f )
    sFileName := ''
  else
    hb_vfErase( sFileName )

    nLen := len(arr_f)
    aGauge := GaugeNew( , , { 'R/BG*', 'R/BG*', 'R/BG*' }, 'Создание архива ' + hb_FNameNameExt( sFileName ), .t. )

    // lCompress := hb_ZipFile( sFileName, arr_f, COMPRESSION, ;
    //     , ;
    //     .t., , .f., ,  )
    lCompress := hb_ZipFile( sFileName, arr_f, COMPRESSION, ;
        {| cFile, nPos | GaugeDisplay( aGauge ), stat_msg( 'Добавление в архив файла ' + hb_FNameNameExt( cFile ) + ' ( ' + alltrim(lstr(nPos)) + ' из ' + alltrim(lstr(nLen)) + ' )' ) }, ;
        .t., , .f., , { | nPos, nLen | GaugeUpdate( aGauge, nPos / nLen ) } )
    if ! lCompress
      sFileName := ''
    endif
    CloseGauge( aGauge ) // Закроем окно отображения бегунка
  endif

  return sFileName

****** 20.11.21
function create_ZIP( par, dir_archiv )
  static sast := '*', sfile_begin := '_begin.txt', sfile_end := '_end.txt'
  local arr_f, ar
  local blk := { | x | f_aadd_copy_DB( arr_f, x ) }
  local hZip, i, cPassword, fl := .t., aGauge, s, y
  local cFile, nLen
  local zip_file
  local buf := savescreen()
  local zip_xml_mo, zip_xml_tf, zip_napr_mo, zip_napr_tf
  // Local time_zip := 0, t1

  // t1 := seconds()

  zip_xml_mo := zip_xml_tf := zip_napr_mo:= zip_napr_tf := ''
  if par == 1
    if ! G_SLock1Task( sem_task, sem_vagno )  // запрет доступа всем
      func_error( 4, 'В данный момент работают другие задачи. Копирование запрещено!' )
      return nil
    endif
  endif
  if par == 3 .or. f_Esc_Enter( 'резервного копирования' )

      f_message( { 'Внимание! Создаётся архив базы данных.', ;
             '', ;
             'Во избежание разрушения данных', ;
             'не прерывайте процесс!' }, , 'GR+/R', 'W+/R', 13 )

    // формируем имена архивов
    zip_file := 'mo' + alltrim( glob_mo[ _MO_KOD_TFOMS ] ) + '_' + dtos( sys_date ) + ;
      lower( iif( par != 3, szip, schip ) )

    zip_xml_mo := dir_XML_MO + szip
    zip_xml_tf := dir_XML_TF + szip
    zip_napr_mo := dir_NAPR_MO + szip
    zip_napr_tf := dir_NAPR_TF + szip

    hb_vfErase( sfile_begin )
    hb_memowrit( sfile_begin, full_date( sys_date ) + ' ' + time() + ' ' + hb_OemToAnsi(fio_polzovat) )

    //
    arr_f := {}
    scandirfiles( dir_server + dir_XML_MO + cslash, sast + szip, blk )
    scandirfiles(dir_server + dir_XML_MO + cslash, sast + scsv, blk )

    zip_xml_mo := fillZIP( arr_f, zip_xml_mo )

    //
    arr_f := {}
    scandirfiles( dir_server + dir_XML_TF + cslash, sast + szip, blk )
    scandirfiles( dir_server + dir_XML_TF + cslash, sast + scsv, blk )
    scandirfiles( dir_server + dir_XML_TF + cslash, sast + stxt, blk )

    zip_xml_tf := fillZIP( arr_f, zip_xml_tf )

    //
    arr_f := {}
    scandirfiles( dir_server + dir_NAPR_MO + cslash, sast + szip, blk )
    scandirfiles( dir_server + dir_NAPR_MO + cslash, sast + stxt, blk )

    zip_napr_mo := fillZIP( arr_f, zip_napr_mo )

    //
    arr_f := {}
    scandirfiles( dir_server + dir_NAPR_TF + cslash, sast + szip, blk )
    scandirfiles( dir_server + dir_NAPR_TF + cslash, sast + stxt, blk )

    zip_napr_tf := fillZIP( arr_f, zip_napr_tf )

    hb_vfErase( dir_archiv + zip_file )

    // сначала прочие файлы
    ar := { sfile_begin, ;
          tools_ini, ;
          f_stat_lpu, ;
          dir_server + 'f39_nast' + sini, ;
          dir_server + 'usl1year' + smem, ;
          dir_server + 'error' + stxt }
    if ! empty( zip_xml_mo )
      aadd( ar, cur_dir + zip_xml_mo )
    endif
    if ! empty( zip_xml_tf )
      aadd( ar, cur_dir + zip_xml_tf )
    endif
    if ! empty( zip_napr_mo )
      aadd( ar, cur_dir + zip_napr_mo )
    endif
    if ! empty( zip_napr_tf )
      aadd( ar, cur_dir + zip_napr_tf )
    endif

    for i := 1 To Len( array_files_DB )
      cFile := upper( array_files_DB[ i ] ) + sdbf
      if hb_vfExists( dir_server + cFile )
        aadd( ar, dir_server + cFile )
      endif
    next

    // а теперь файлы WQ...
    arr_f := {}
    y := year( sys_date )
    // только текущий год
    scandirfiles( dir_server, 'mo_wq' + substr( str( y, 4 ), 3 ) + '*' + sdbf, { | x | aadd( arr_f, x ) } )
    for i := 1 To Len( arr_f )
      aadd( ar, arr_f[ i ] )
    next

    nLen := len(ar)
    aGauge := GaugeNew( , , { 'R/BG*', 'R/BG*', 'R/BG*' }, 'Создание архива ' + zip_file, .t. )
  
    // lCompress := hb_ZipFile( dir_archiv + zip_file, ar, COMPRESSION, ;
    //     , ;
    //     .t., , .f., , )
    lCompress := hb_ZipFile( dir_archiv + zip_file, ar, COMPRESSION, ;
        {| cFile, nPos | GaugeDisplay( aGauge ), stat_msg( 'Добавление в архив файла ' + hb_FNameNameExt( cFile ) + ' ( ' + alltrim(lstr(nPos)) + ' из ' + alltrim(lstr(nLen)) + ' )' ) }, ;
        .t., , .f., , { | nPos, nLen | GaugeUpdate( aGauge, nPos / nLen ) } )
    CloseGauge( aGauge ) // Закроем окно отображения бегунка
  
    if ! lCompress
      fl := func_error( 4, 'Возникла ошибка при архивировании базы данных.' )
    endif

    // time_zip := seconds() - t1

    // if fl .and. time_zip > 0
    //   n_message({'', 'Время создания резервной копии - ' + sectotime(time_zip)}, , ;
    //           color1, cDataCSay, , , color8)
    // endif
  
    hb_vfErase( sfile_end )
    hb_memowrit( sfile_end, full_date( sys_date ) + ' ' + time() + ' ' + hb_OemToAnsi(fio_polzovat))

    restscreen( buf )
  endif

  // удаляем ненужные архивы
  if ! empty( zip_xml_mo )
    hb_vfErase( zip_xml_mo )
  endif
  if ! empty( zip_xml_tf )
    hb_vfErase( zip_xml_tf )
  endif
  if !empty( zip_napr_mo )
    hb_vfErase( zip_napr_mo )
  endif
  if !empty( zip_napr_tf )
    hb_vfErase( zip_napr_tf )
  endif

  // разрешение доступа всем
  if par == 1
    G_SUnLock(sem_vagno)
  endif
  keyboard ''
  if ! fl
    return nil
  endif
  return zip_file

***** 04.05.21
Function f_aadd_copy_DB( arr_f, x )
  Local fl := .t., s, y

  x := upper( x )
  if eq_any( right( x, 4 ), szip, stxt )
    s := StripPath( x )
    // реестры, ФЛК и счета
    if eq_any( left( s, 3 ), 'FRM', 'HRM' ) .or. eq_any( left( s, 4 ), 'PFRM', 'PHRM') ;
                                     .or. eq_any( left( s, 2 ), 'I0', 'FM', 'HM', 'AT', 'AS', 'DT', 'DS' )
      y := int( val( left( afteratnum( '_', s ), 2 ) ) )
      fl := ( y > 19 )  // с 2020 года
    elseif eq_any( left( s, 3 ), 'FRT', 'HRT' )
      y := int( val( substr( s, 14, 2 ) ) )
      fl := ( y > 19 )  // с 2020 года
    endif
  endif
  if fl
    aadd( arr_f, x )
  endif
  return nil
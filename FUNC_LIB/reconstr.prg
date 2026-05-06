#include 'set.ch'
#include 'function.ch'

// 12.10.17 создает или перестраивает файл БД
Function reconstruct( file_base, ;  // имя файла базы данных
  struct_dbf, ; // двумерный массив с эталонной структурой БД
  func_index, ; // наименование ф-ии, в которой создаются индексные файлы для данной БД
  lstring, ;    // строка текста с пояснением содержимого БД
  fl_NET )      // флаг, указывающий, где создается БД, - на сервере или нет

  // Static sdbf := '.dbf'
  Static err_2_task := 'Вероятность повторного запуска задачи!'
  Local vrec
  Local adbf, fl := .f., lOldDeleted, lrec, is_time, buf := save_maxrow()

  Default func_index To '', lstring To '', fl_NET To .f.
  file_base := Lower( file_base )
  If !( Right( file_base, 4 ) == sdbf() )
    file_base += sdbf()
  Endif
  If !hb_FileExists( file_base )
    If !Empty( lstring )
      stat_msg( 'Ждите! Создается база данных по ' + lstring )
    Endif
    dbCreate( file_base, struct_dbf )
    fl := .t.
  Elseif control_base( 2 )
    If !g_use( file_base,,, .t., !fl_NET )
      err_msg( err_2_task )
    Endif
    adbf := dbStruct()
    lrec := LastRec()
    is_time := ( lrec > 1000 )
    Use
    If !compare_arrays( adbf, struct_dbf )
      If !Empty( lstring )
        stat_msg( 'Ждите! Перестраивается база данных по ' + lstring )
      Endif
      dbCreate( 'tmp', struct_dbf )
      If !g_use( 'tmp',,, .t., .t. )
        err_msg( err_2_task )
      Endif
      vrec := ( RecSize() * lrec + Header() + 1 ) * 1.3
      If DiskSpace() < vrec
        func_error( 'На диске не хватает ' + lstr( vrec - DiskSpace(), 15, 0 ) + ;
          ' байт для перестроения базы данных' )
        f_end()
      Endif
      dbCloseAll()
      //
      If is_time
        ShowTime( MaxRow(), 72, .f., 'G+/R' )
      Endif
      lOldDeleted := Set( _SET_DELETED, .f. )
      Use tmp New
      Append from ( file_base ) codepage 'RU866'
      dbCloseAll()
      //
      create_copy_reconsrtuct_file( file_base )
      //
      Do While FErase( file_base ) != 0
      Enddo
      If fl_NET
        Copy file tmp.dbf to ( file_base )
        Delete file tmp.dbf
      Else
        Rename tmp.dbf to ( file_base )
      Endif
      Set( _SET_DELETED, lOldDeleted )
      If is_time
        ShowTime()
      Endif
      fl := .t.
    Endif
  Endif
  rest_box( buf )
  If fl .and. !Empty( func_index )
    If !( '(' $ func_index )
      func_index += '()'
    Endif
    If fl_NET
      g_use( file_base,,, .t., .t. )
    Else
      Use ( file_base )
    Endif
    fl := &( func_index )
  Endif
  dbCloseAll()

  Return Nil

// 05.05.26 создание копии файла до реконструкции в подкаталоге RECONSTRUCTION
Static Function create_copy_reconsrtuct_file( file_base )

//  Static cslash := '\'
  Local name_file := '_' + DToS( Date() ) + CharRem( ':', hour_min( Seconds() ) ) + '_' + strippath( file_base )
  Local name_dir := keeppath( file_base ) + hb_ps() + 'RECONSTRUCTION'

  If !hb_DirExists( name_dir )
    If hb_DirCreate( name_dir ) != 0
      Return Nil // Невозможно создать подкаталог для копии
    Endif
  Endif
  name_dir += hb_ps()
  Copy File ( file_base ) to ( name_dir + name_file )

  Return Nil
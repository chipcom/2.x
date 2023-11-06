#include 'function.ch'
#include 'chip_mo.ch'

// 02.07.14 создать ZIP-архив из массива XML-файлов
Function chip_create_zipxml( zip_file, arr_f, is_delete_files, type_dir )
  // zip_file - имя архива с расширением
  // arr_f - массив файлов
  // is_delete_files - удалять ли файлы после создания архива (по-умолчанию - нет)
  Local hZip, i, cPassword, fl := .t., hGauge, s

  Default is_delete_files To .f., type_dir To 1
  Delete File ( zip_file )
  If !Empty( hZip := hb_zipOpen( zip_file ) )
    For i := 1 To Len( arr_f )
      hb_zipStoreFile( hZip, arr_f[ i ], arr_f[ i ] )
    Next
    hb_zipClose( hZip )
  Else
    fl := func_error( 4, "Возникла ошибка при создании " + zip_file )
  Endif
  If fl .and. is_delete_files
    For i := 1 To Len( arr_f )
      Delete File ( arr_f[ i ] )
    Next
  Endif
  If fl
    fl := chip_copy_zipxml( zip_file, dir_server + iif( type_dir == 1, dir_XML_MO, dir_NAPR_MO ), .t. )
  Endif

  Return fl

// переписать ZIP-архив (с XML-файлами) в целевой каталог
Function chip_copy_zipxml( zip_file, goal_dir, is_delete_files )
  // zip_file - имя архива с расширением (и м.б. с путём)
  // goal_dir - имя каталога, куда надо переписать архив
  // is_delete_files - удалять ли архив после переписывания (по-умолчанию - нет)
  Local fl := .f., zip_file2

  Default is_delete_files To .f.
  If !Empty( goal_dir )
    DirMake( goal_dir )
    goal_dir += cslash
    zip_file2 := strippath( zip_file ) // если в имени присутствует путь - убрать
    Delete File ( goal_dir + zip_file2 )
    Copy File ( zip_file ) to ( goal_dir + zip_file2 )
    If hb_FileExists( goal_dir + zip_file2 )
      fl := .t.
    Else
      func_error( 4, "Ошибка записи файла " + goal_dir + zip_file2 )
    Endif
  Endif
  If fl .and. is_delete_files
    Delete File ( zip_file )
  Endif

  Return fl

// 03.03.13 переписать архив во временный каталог и распаковать
Function extract_zip_xml( goal_dir, name_zip, regim, new_name )
  Local arr_f := {}, fl := .f., n, hUnzip, nErr, cFile, cName, _dir, _dir1

  Default regim To 1, new_name To name_zip
  _dir  := iif( regim == 1, _tmp_dir,  _tmp2dir )
  _dir1 := iif( regim == 1, _tmp_dir1, _tmp2dir1 )
  If Right( goal_dir, 1 ) != cslash
    goal_dir += cslash
  Endif
  // if !hb_FileExists(hb_OemToAnsi(goal_dir)+name_zip)
  If !hb_FileExists( goal_dir + name_zip )
    func_error( 4, "Не найден архив " + goal_dir + name_zip )
    Return Nil
  Endif
  DirMake( _dir )
  FileDelete( _dir1 + "*.*" )
  // copy file (hb_OemToAnsi(goal_dir)+name_zip) to (_dir1+new_name)
  Copy File ( goal_dir + name_zip ) to ( _dir1 + new_name )
  If !hb_FileExists( _dir1 + new_name )
    func_error( 4, "Ошибка при копировании архива " + name_zip + " во временный каталог" )
  Else
    n := 0
    If !Empty( hUnzip := hb_unzipOpen( _dir1 + new_name ) )
      fl := .t.
      hb_unzipGlobalInfo( hUnzip, @n, NIL )
      If n > 0
        nErr := hb_unzipFileFirst( hUnzip )
        Do While nErr == 0
          hb_unzipFileInfo( hUnzip, @cFile )// , @dDate, @cTime,,,, @nSize, @nCompSize, @lCrypted, @cComment )
          hb_unzipExtractCurrentFile( hUnzip, _dir1 + cFile )// , cPassword)
          AAdd( arr_f, cFile )
          nErr := hb_unzipFileNext( hUnzip )
        Enddo
      Endif
      hb_unzipClose( hUnzip )
    Else
      func_error( 4, "Возникла ошибка при разархивировании " + _dir1 + name_zip )
    Endif
  Endif

  Return iif( fl, arr_f, nil )

// 21.06.15 переписать архив во временный каталог и распаковать
Function extract_rar( goal_dir, name_zip, regim, new_name )
  Local fl := .f., buf, _dir, _dir1

  Default regim To 1, new_name To name_zip
  _dir  := iif( regim == 1, _tmp_dir,  _tmp2dir )
  _dir1 := iif( regim == 1, _tmp_dir1, _tmp2dir1 )
  If Right( goal_dir, 1 ) != cslash
    goal_dir += cslash
  Endif
  // if !hb_FileExists(hb_OemToAnsi(goal_dir)+name_zip)
  If !hb_FileExists( goal_dir + name_zip )
    func_error( 4, "Не найден архив " + goal_dir + name_zip )
    Return Nil
  Endif
  DirMake( _dir )
  FileDelete( _dir1 + "*.*" )
  // copy file (hb_OemToAnsi(goal_dir)+name_zip) to (_dir1+new_name)
  Copy File ( goal_dir + name_zip ) to ( _dir1 + new_name )
  If !hb_FileExists( _dir1 + new_name )
    func_error( 4, "Ошибка при копировании архива " + name_zip + " во временный каталог" )
  Else
    buf := SaveScreen()
    Run ( dir_exe + "unrar.exe e " + _dir1 + new_name + " " + _dir1 )
    RestScreen( buf )
    fl := .t.
  Endif

  Return fl

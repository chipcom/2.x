#include 'function.ch'
#include 'chip_mo.ch'

***** 02.07.14 создать ZIP-архив из массива XML-файлов
Function chip_create_zipXML(zip_file,arr_f,is_delete_files,type_dir)
  // zip_file - имя архива с расширением
  // arr_f - массив файлов
  // is_delete_files - удалять ли файлы после создания архива (по-умолчанию - нет)
  Local hZip, i, cPassword, fl := .t., hGauge, s
  DEFAULT is_delete_files TO .f., type_dir TO 1
  delete file (zip_file)
  if !empty(hZip := HB_ZIPOPEN(zip_file))
    for i := 1 To Len(arr_f)
      HB_ZipStoreFile( hZip, arr_f[i], arr_f[i])
    next
    HB_ZIPCLOSE( hZip )
  else
    fl := func_error(4,"Возникла ошибка при создании "+zip_file)
  endif
  if fl .and. is_delete_files
    for i := 1 To Len(arr_f)
      delete file (arr_f[i])
    next
  endif
  if fl
    fl := chip_copy_zipXML(zip_file,dir_server+iif(type_dir==1,dir_XML_MO,dir_NAPR_MO),.t.)
  endif
  return fl

***** переписать ZIP-архив (с XML-файлами) в целевой каталог
Function chip_copy_zipXML(zip_file,goal_dir,is_delete_files)
  // zip_file - имя архива с расширением (и м.б. с путём)
  // goal_dir - имя каталога, куда надо переписать архив
  // is_delete_files - удалять ли архив после переписывания (по-умолчанию - нет)
  Local fl := .f., zip_file2
  DEFAULT is_delete_files TO .f.
  if !empty(goal_dir)
    dirmake(goal_dir)
    goal_dir += cslash
    zip_file2 := StripPath(zip_file) // если в имени присутствует путь - убрать
    delete file (goal_dir+zip_file2)
    copy file (zip_file) to (goal_dir+zip_file2)
    if hb_FileExists(goal_dir+zip_file2)
      fl := .t.
    else
      func_error(4,"Ошибка записи файла "+goal_dir+zip_file2)
    endif
  endif
  if fl .and. is_delete_files
    delete file (zip_file)
  endif
  return fl
  
***** 03.03.13 переписать архив во временный каталог и распаковать
Function Extract_Zip_XML(goal_dir,name_zip,regim,new_name)
  Local arr_f := {}, fl := .f., n, hUnzip, nErr, cFile, cName, _dir, _dir1
  
  DEFAULT regim TO 1, new_name TO name_zip
  _dir  := iif(regim==1, _tmp_dir,  _tmp2dir)
  _dir1 := iif(regim==1, _tmp_dir1, _tmp2dir1)
  if right(goal_dir,1) != cslash
    goal_dir += cslash
  endif
  //if !hb_FileExists(hb_OemToAnsi(goal_dir)+name_zip)
  if !hb_FileExists(goal_dir+name_zip)
    func_error(4,"Не найден архив "+goal_dir+name_zip)
    return NIL
  endif
  dirmake(_dir)
  filedelete(_dir1+"*.*")
  //copy file (hb_OemToAnsi(goal_dir)+name_zip) to (_dir1+new_name)
  copy file (goal_dir+name_zip) to (_dir1+new_name)
  if !hb_FileExists(_dir1+new_name)
    func_error(4,"Ошибка при копировании архива "+name_zip+" во временный каталог")
  else
    n := 0
    if !empty(hUnzip := HB_UNZIPOPEN(_dir1+new_name))
      fl := .t.
      hb_UnzipGlobalInfo( hUnzip, @n, NIL )
      if n > 0
        nErr := HB_UNZIPFILEFIRST(hUnzip)
        DO WHILE nErr == 0
          HB_UnzipFileInfo( hUnzip, @cFile)//, @dDate, @cTime,,,, @nSize, @nCompSize, @lCrypted, @cComment )
          HB_UnzipExtractCurrentFile(hUnzip,_dir1+cFile)//, cPassword)
          aadd(arr_f,cFile)
          nErr := HB_UNZIPFILENEXT(hUnzip)
        ENDDO
      endif
      HB_UNZIPCLOSE(hUnzip)
    else
      func_error(4,"Возникла ошибка при разархивировании "+_dir1+name_zip)
    endif
  endif
  return iif(fl, arr_f, nil)
  
***** 21.06.15 переписать архив во временный каталог и распаковать
Function Extract_RAR(goal_dir,name_zip,regim,new_name)
  Local fl := .f., buf, _dir, _dir1

  DEFAULT regim TO 1, new_name TO name_zip
  _dir  := iif(regim==1, _tmp_dir,  _tmp2dir)
  _dir1 := iif(regim==1, _tmp_dir1, _tmp2dir1)
  if right(goal_dir,1) != cslash
    goal_dir += cslash
  endif
  //if !hb_FileExists(hb_OemToAnsi(goal_dir)+name_zip)
  if !hb_FileExists(goal_dir+name_zip)
    func_error(4,"Не найден архив "+goal_dir+name_zip)
    return NIL
  endif
  dirmake(_dir)
  filedelete(_dir1+"*.*")
  //copy file (hb_OemToAnsi(goal_dir)+name_zip) to (_dir1+new_name)
  copy file (goal_dir+name_zip) to (_dir1+new_name)
  if !hb_FileExists(_dir1+new_name)
    func_error(4,"Ошибка при копировании архива "+name_zip+" во временный каталог")
  else
    buf := savescreen()
    RUN (dir_exe+"unrar.exe e "+_dir1+new_name+" "+_dir1)
    restscreen(buf)
    fl := .t.
  endif
  return fl
  
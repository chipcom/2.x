#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** запуск режима резервного копирования из меню
Function m_copy_DB()
  if G_SLock1Task(sem_task,sem_vagno)  // запрет доступа всем
    if f_Esc_Enter("резервного копирования")
      fm_copy_DB("")
    endif
    // разрешение доступа всем
    G_SUnLock(sem_vagno)
    keyboard ""
  else
    func_error(4,"В данный момент работают другие задачи. Копирование запрещено!")
  endif
  return NIL
  
***** 11.03.15 запуск режима резервного копирования из f_end()
Function m_copy_DB_from_end(del_last,spath)
  Local hCurrent, hFile, nSize, fl := .t., ta,;
        i, k, arr_f, dir_archiv := cur_dir+"OwnChipArchiv"
  DEFAULT del_last TO .f., spath TO ""
  if !empty(spath)
    dir_archiv := alltrim(spath)
    if right(dir_archiv,1) == cslash
      dir_archiv := left(dir_archiv,len(dir_archiv)-1)
    endif
  endif
  if !hb_DirExists(dir_archiv)
    if hb_DirCreate(dir_archiv) != 0
      return func_error(4,"Невозможно создать подкаталог для архивирования!")
    endif
  endif
  dir_archiv += cslash
  // все уже сохранённые архивы - в массив
  arr_f := directory(dir_archiv+"mo*"+szip)
  ta := directory(dir_archiv+"mo*"+schip)
  for i := 1 to len(ta)
    aadd(arr_f,aclone(ta[i]))
  next
  if (k := len(arr_f)) > 0
    // сортируем файлы
    asort(arr_f,,,{|x,y| iif(x[3]==y[3], x[4] < y[4], x[3] < y[3]) })
    // запомним размер последнего архива
    nSize := arr_f[k,2] * 1.5 // для надёжности резервируем больше в 1.5 раза
    // проверяем дату и время последнего файла
    if arr_f[k,3] == sys_date // если сегодня уже сохраняли
      hCurrent := int(val(sectotime(seconds())))
      hFile := int(val(arr_f[k,4]))
      fl := (del_last .or. (hCurrent - hFile) > 1) // прошло заведомо более 1 часа
      if fl
        delete file (dir_archiv+arr_f[k,1]) // удалим сегодняшний архив
        --k
      endif
    endif
  endif
  if fl .and. k > 4 // оставляем только 4 последних архива
    for i := 1 to k-4
      delete file (dir_archiv+arr_f[i,1]) // удалим лишний архив
    next
  endif
  if fl .and. k > 0 .and. diskspace() < nSize // недостаточно места для архивирования
    for i := 1 to k
      if hb_fileExists(dir_archiv+arr_f[i,1])
        delete file (dir_archiv+arr_f[i,1]) // удалим лишний архив
        if diskspace() > nSize // уже достаточно места?
          exit  // выход из цикла
        endif
      endif
    next
  endif
  if fl
    fl := fm_copy_DB(dir_archiv)
  endif
  return fl
  
  ***** 26.05.20
  Function f_aadd_copy_DB(arr_f,x)
  Local fl := .t., s, y
  x := upper(x)
  if eq_any(right(x,4),szip,stxt)
    s := StripPath(x)
    // реестры, ФЛК и счета
    if eq_any(left(s,3),"FRM","HRM") .or. eq_any(left(s,4),"PFRM","PHRM") ;
                                     .or. eq_any(left(s,2),"I0","FM","HM","AT","AS","DT","DS")
      y := int(val(left(afteratnum("_",s),2)))
      fl := (y > 19)  // с 2020 года
    elseif eq_any(left(s,3),"FRT","HRT")
      y := int(val(substr(s,14,2)))
      fl := (y > 19)  // с 2020 года
    endif
  endif
  if fl
    aadd(arr_f,x)
  endif
  return NIL
  
  ***** 06.03.17 внутренняя функция резервного копирования
  Function fm_copy_DB(dir_archiv)
  Static sast := "*", sfile_begin := "_begin.txt", sfile_end := "_end.txt"
  Local arr_f, blk := {| x | f_aadd_copy_DB(arr_f,x) }
  Local ar, hZip, i, cPassword, fl := .t., hGauge, s, y, cFile, buf := savescreen()
  f_message({"Ждите! Создаётся архив базы данных.",;
             "",;
             "Ни в коем случае не прерывайте процесс",;
             "во избежание нежелательных последствий!"},,"GR+/R","W+/R",13)
  zip_file := "mo"+alltrim(glob_mo[_MO_KOD_TFOMS])+"_"+dtos(sys_date)+;
              lower(iif(empty(dir_archiv),szip,schip))
  zip_xml_mo := dir_XML_MO+szip
  zip_xml_tf := dir_XML_TF+szip
  zip_napr_mo := dir_NAPR_MO+szip
  zip_napr_tf := dir_NAPR_TF+szip
  delete file (sfile_begin)
  hb_memowrit(sfile_begin,full_date(sys_date)+" "+hour_min(seconds())+" "+hb_OemToAnsi(fio_polzovat))
  //
  arr_f := {}
  scandirfiles(dir_server+dir_XML_MO+cslash, sast+szip, blk )
  scandirfiles(dir_server+dir_XML_MO+cslash, sast+scsv, blk )
  if empty(arr_f)
    zip_xml_mo := ""
  else
    delete file (zip_xml_mo)
    if !empty(hZip := HB_ZIPOPEN(zip_xml_mo))
      hGauge := GaugeNew(,,{"B/BG*","B/BG*","B/BG*"},"Создание архива "+zip_xml_mo,.t.)
      GaugeDisplay( hGauge )
      for i := 1 To Len(arr_f)
        cFile := StripPath(arr_f[i])  // имя файла без пути
        GaugeUpdate( hGauge, i/Len(arr_f) )
        stat_msg("Добавление в архив файла "+cFile)
        HB_ZipStoreFile( hZip, arr_f[i], cFile)//, cPassword )
      next
      CloseGauge(hGauge) // Закроем окно отображения
      HB_ZIPCLOSE( hZip )
    else
      zip_xml_mo := ""
    endif
  endif
  //
  arr_f := {}
  scandirfiles(dir_server+dir_XML_TF+cslash, sast+szip, blk )
  scandirfiles(dir_server+dir_XML_TF+cslash, sast+scsv, blk )
  scandirfiles(dir_server+dir_XML_TF+cslash, sast+stxt, blk )
  if empty(arr_f)
    zip_xml_tf := ""
  else
    delete file (zip_xml_tf)
    if !empty(hZip := HB_ZIPOPEN(zip_xml_tf))
      hGauge := GaugeNew(,,{"R/BG*","R/BG*","R/BG*"},"Создание архива "+zip_xml_tf,.t.)
      GaugeDisplay( hGauge )
      for i := 1 To Len(arr_f)
        cFile := StripPath(arr_f[i])  // имя файла без пути
        GaugeUpdate( hGauge, i/Len(arr_f) )
        stat_msg("Добавление в архив файла "+cFile)
        HB_ZipStoreFile( hZip, arr_f[i], cFile)//, cPassword )
      next
      CloseGauge(hGauge) // Закроем окно отображения
      HB_ZIPCLOSE( hZip )
    else
      zip_xml_tf := ""
    endif
  endif
  //
  arr_f := {}
  scandirfiles(dir_server+dir_NAPR_MO+cslash, sast+szip, blk )
  scandirfiles(dir_server+dir_NAPR_MO+cslash, sast+stxt, blk )
  if empty(arr_f)
    zip_napr_mo := ""
  else
    delete file (zip_napr_mo)
    if !empty(hZip := HB_ZIPOPEN(zip_napr_mo))
      hGauge := GaugeNew(,,{"RB/BG*","RB/BG*","RB/BG*"},"Создание архива "+zip_napr_mo,.t.)
      GaugeDisplay( hGauge )
      for i := 1 To Len(arr_f)
        cFile := StripPath(arr_f[i])  // имя файла без пути
        GaugeUpdate( hGauge, i/Len(arr_f) )
        stat_msg("Добавление в архив файла "+cFile)
        HB_ZipStoreFile( hZip, arr_f[i], cFile)//, cPassword )
      next
      CloseGauge(hGauge) // Закроем окно отображения
      HB_ZIPCLOSE( hZip )
    else
      zip_napr_mo := ""
    endif
  endif
  //
  arr_f := {}
  scandirfiles(dir_server+dir_NAPR_TF+cslash, sast+szip, blk )
  scandirfiles(dir_server+dir_NAPR_TF+cslash, sast+stxt, blk )
  if empty(arr_f)
    zip_napr_tf := ""
  else
    delete file (zip_napr_tf)
    if !empty(hZip := HB_ZIPOPEN(zip_napr_tf))
      hGauge := GaugeNew(,,{"GR/BG*","GR/BG*","GR/BG*"},"Создание архива "+zip_napr_tf,.t.)
      GaugeDisplay( hGauge )
      for i := 1 To Len(arr_f)
        cFile := StripPath(arr_f[i])  // имя файла без пути
        GaugeUpdate( hGauge, i/Len(arr_f) )
        stat_msg("Добавление в архив файла "+cFile)
        HB_ZipStoreFile( hZip, arr_f[i], cFile)//, cPassword )
      next
      CloseGauge(hGauge) // Закроем окно отображения
      HB_ZIPCLOSE( hZip )
    else
      zip_napr_tf := ""
    endif
  endif
  //
  delete file (dir_archiv+zip_file)
  if !empty(hZip := HB_ZIPOPEN(dir_archiv+zip_file))
    // сначала прочие файлы
    ar := {sfile_begin,;
           tools_ini,;
           f_stat_lpu,;
           dir_server+"f39_nast"+sini,;
           dir_server+"usl1year"+smem,;
           dir_server+"error"+stxt}
    if !empty(zip_xml_mo)
      aadd(ar,cur_dir+zip_xml_mo)
    endif
    if !empty(zip_xml_tf)
      aadd(ar,cur_dir+zip_xml_tf)
    endif
    if !empty(zip_napr_mo)
      aadd(ar,cur_dir+zip_napr_mo)
    endif
    if !empty(zip_napr_tf)
      aadd(ar,cur_dir+zip_napr_tf)
    endif
    for i := 1 To Len(ar)
      if hb_fileExists(ar[i])
        stat_msg("Добавление в архив файла "+ar[i])
        HB_ZipStoreFile( hZip, ar[i], StripPath(ar[i]))//, cPassword )
      endif
    next
    hGauge := GaugeNew(,,{"N/BG*","N/BG*","N/BG*"},"Создание архива "+zip_file,.t.)
    GaugeDisplay( hGauge )
    // а теперь база данных
    for i := 1 To Len(array_files_DB)
      cFile := upper(array_files_DB[i])+sdbf
      GaugeUpdate( hGauge, i/Len(array_files_DB) )
      if hb_fileExists(dir_server+cFile)
        stat_msg("Добавление в архив файла "+cFile)
        HB_ZipStoreFile( hZip, dir_server+cFile, cFile)//, cPassword )
      endif
    next
    delete file (sfile_end)
    hb_memowrit(sfile_end,full_date(sys_date)+" "+hour_min(seconds())+" "+hb_OemToAnsi(fio_polzovat))
    if hb_fileExists(sfile_end)
      HB_ZipStoreFile( hZip, sfile_end, sfile_end)//, cPassword )
    endif
    // а теперь файлы WQ...
    arr_f := {}
    y := year(sys_date)
    // только текущий год
    scandirfiles(dir_server, "mo_wq"+substr(str(y,4),3)+"*"+sdbf, {|x|aadd(arr_f,x)})
    for i := 1 To Len(arr_f)
      cFile := StripPath(arr_f[i])  // имя файла без пути
      HB_ZipStoreFile( hZip, arr_f[i], cFile)//, cPassword )
    next
    CloseGauge(hGauge) // Закроем окно отображения
    HB_ZIPCLOSE( hZip )
  else
    fl := func_error(4,"Возникла ошибка при архивировании базы данных.")
  endif
  restscreen(buf)
  if fl .and. empty(dir_archiv)
    Private p_var_manager := "m_copy_DB"
    s := manager(T_ROW,T_COL+5,maxrow()-2,,.f.,2) // "norton" для выбора каталога
    if !empty(s)
      mywait('Копирование "'+zip_file+'" в каталог "'+s+'"')
      //delete file (hb_OemToAnsi(s)+zip_file)
      delete file (s+zip_file)
      //copy file (zip_file) to (hb_OemToAnsi(s)+zip_file)
      copy file (zip_file) to (s+zip_file)
      //if hb_fileExists(hb_OemToAnsi(s)+zip_file)
      if hb_fileExists(s+zip_file)
        stat_msg("Файл "+s+zip_file+" успешно записан!")
      else
        stat_msg("Ошибка записи файла "+s+zip_file+"!")
      endif
      mybell(2,OK)
    endif
  endif
  if !empty(zip_xml_mo)
    delete file (zip_xml_mo)
  endif
  if !empty(zip_xml_tf)
    delete file (zip_xml_tf)
  endif
  if !empty(zip_napr_mo)
    delete file (zip_napr_mo)
  endif
  if !empty(zip_napr_tf)
    delete file (zip_napr_tf)
  endif
  if empty(dir_archiv)
    delete file (zip_file)
  endif
  restscreen(buf)
  return fl
  
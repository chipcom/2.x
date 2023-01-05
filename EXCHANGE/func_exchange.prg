** различные функции для обмена файлами со внешними системами - func_exchange.prg
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
 
** 17.12.19 проверить, нам ли предназначен данный XML-файл
Function Is_Our_XML(cName, ret_arr)
  Local c, arr_err := {}, i, s, nSMO, nTypeFile, cFrom, cTo, _nYear, _nMonth, nNN, nReestr := 0

  s := cName
  if eq_any(left(s, 3), 'VHR', 'VFR', 'PHR', 'PFR') // файл протокола ФЛК
    nTypeFile := _XML_FILE_FLK
    R_Use(dir_server + 'mo_rees', , 'REES')
    R_Use(dir_server + 'mo_xml', , 'MO_XML')
    index on upper(fname) to (cur_dir + 'tmpmoxml')
    find (padr(substr(s, 2), 26)) // имя то же самое, начиная со второго знака
    if found() .and. (nReestr := mo_xml->REESTR) > 0
      select REES
      goto (nReestr)
      cFrom   := glob_MO[_MO_KOD_TFOMS]
      cTo     := '34'
      _nYear  := rees->NYEAR
      _nMonth := rees->NMONTH
      nNN     := rees->NN
    else
      aadd(arr_err, 'Это файл ФЛК, но мы не отправляли соответствующий реестр случаев в ТФОМС!')
    endif
    rees->(dbCloseArea())
    mo_xml->(dbCloseArea())
  elseif eq_any(left(s, 3), 'D02', 'R02', 'R12', 'R06') // ответный файл на отосланный файл D01 R01 (R05)
    s := substr(s, 4)
    if left(s, 1) == 'M'
      s := substr(s, 2)
    else
      aadd(arr_err, 'Неверная буква в обозначении получателя: ' + s)
    endif
    if len(arr_err) == 0
      cTo := left(s, 6)
      if !(cTo == glob_MO[_MO_KOD_TFOMS])
        aadd(arr_err, 'Ваш код МО ' + glob_MO[_MO_KOD_TFOMS] + ' не соответствует коду получателя: ' + cTo)
        if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cTo})) > 0
          aadd(arr_err, 'Это файл для: ' + glob_arr_mo[i, _MO_SHORT_NAME])
        endif
      endif
      s := substr(s, 7)
      if left(s, 3) == 'T34'
        s := afteratnum('_', s)
      else
        aadd(arr_err, 'Неверный отправитель: ' + s)
      endif
    endif
    if len(arr_err) == 0
      if left(cName, 3) == 'D02'
        nTypeFile := _XML_FILE_D02
        R_Use(dir_server + 'mo_d01', , 'REES')
        R_Use(dir_server + 'mo_xml', , 'MO_XML')
        index on upper(fname) to (cur_dir + 'tmpmoxml')
        find (padr('D01T34M' + glob_MO[_MO_KOD_TFOMS] + '_' + s, 26)) // сконструировали имя файла D01
        if found() .and. (nReestr := mo_xml->REESTR) > 0
          select REES
          goto (nReestr)
          cFrom   := '34'
          cTo     := glob_MO[_MO_KOD_TFOMS]
          _nYear  := rees->NYEAR
          _nMonth := rees->MM
          nNN     := rees->NN
        else
          aadd(arr_err, 'Это файл ответа на D01, но мы не отправляли соответствующий пакет в ТФОМС!')
        endif
        rees->(dbCloseArea())
        mo_xml->(dbCloseArea())
      elseif left(cName, 3) == 'R02'
        nTypeFile := _XML_FILE_R02
        R_Use(dir_server + 'mo_dr01', , 'REES')
        R_Use(dir_server + 'MO_XML', , 'MO_XML')
        index on upper(fname) to (cur_dir + 'tmpmoxml')
        find (padr('R01T34M' + glob_MO[_MO_KOD_TFOMS] + '_' + s, 26)) // сконструировали имя файла R01
        if found() .and. (nReestr := mo_xml->REESTR) > 0
          select REES
          goto (nReestr)
          cFrom   := '34'
          cTo     := glob_MO[_MO_KOD_TFOMS]
          _nYear  := rees->NYEAR
          _nMonth := rees->NQUARTER
          nNN     := rees->NN
        else
          aadd(arr_err, 'Это файл ответа на R01, но мы не отправляли соответствующий пакет в ТФОМС!')
        endif
        rees->(dbCloseArea())
        mo_xml->(dbCloseArea())
      elseif left(cName,3) == 'R12'
        nTypeFile := _XML_FILE_R12
        R_Use(dir_server + 'mo_dr01', , 'REES')
        R_Use(dir_server + 'MO_XML', , 'MO_XML')
        index on upper(fname) to (cur_dir + 'tmpmoxml')
        find (padr('R11T34M' + glob_MO[_MO_KOD_TFOMS] + '_' + s, 26)) // сконструировали имя файла R11
        if found() .and. (nReestr := mo_xml->REESTR) > 0
          select REES
          goto (nReestr)
          cFrom   := '34'
          cTo     := glob_MO[_MO_KOD_TFOMS]
          _nYear  := rees->NYEAR
          _nMonth := rees->NQUARTER
          nNN     := rees->NN
        else
          aadd(arr_err, 'Это файл ответа на R11, но мы не отправляли соответствующий пакет в ТФОМС!')
        endif
        rees->(dbCloseArea())
        mo_xml->(dbCloseArea())
      else // "R06"
        nTypeFile := _XML_FILE_R06
        R_Use(dir_server + 'mo_dr05', , 'REES')
        R_Use(dir_server + 'MO_XML', , 'MO_XML')
        index on upper(fname) to (cur_dir + 'tmpmoxml')
        find (padr('R05T34M' + glob_MO[_MO_KOD_TFOMS] + '_' + s, 26)) // сконструировали имя файла R05
        if found() .and. (nReestr := mo_xml->REESTR) > 0
          select REES
          goto (nReestr)
          cFrom   := '34'
          cTo     := glob_MO[_MO_KOD_TFOMS]
          _nYear  := rees->NYEAR
          _nMonth := 0
          nNN     := rees->NN
        else
          aadd(arr_err, 'Это файл ответа на R05, но мы не отправляли соответствующий пакет в ТФОМС!')
        endif
        rees->(dbCloseArea())
        mo_xml->(dbCloseArea())
      endif
    endif
  elseif eq_any(left(s, 4), 'PR01', 'PR11', 'PR05') // ответный файл на отосланный файл R01 (R11) (R05)
    s := substr(s, 8)
    if left(s, 1) == 'M'
      s := substr(s, 2)
    else
      aadd(arr_err, 'Неверная буква в обозначении получателя: ' + s)
    endif
    if len(arr_err) == 0
      cTo := left(s, 6)
      if !(cTo == glob_MO[_MO_KOD_TFOMS])
        aadd(arr_err, 'Ваш код МО ' + glob_MO[_MO_KOD_TFOMS] + ' не соответствует коду получателя: ' + cTo)
        if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cTo})) > 0
          aadd(arr_err, 'Это файл для: ' + glob_arr_mo[i, _MO_SHORT_NAME])
        endif
      endif
      s := substr(cName, 5, 3)
      if !(left(s, 3) == 'T34')
        aadd(arr_err, 'Неверный отправитель: ' + s)
      endif
    endif
    if len(arr_err) == 0
      if left(cName, 4) == 'PR01'
        nTypeFile := _XML_FILE_R02
        R_Use(dir_server + 'mo_dr01', , 'REES')
        R_Use(dir_server + 'MO_XML', , 'MO_XML')
        index on upper(fname) to (cur_dir + 'tmpmoxml')
        find (padr(substr(cName, 2), 26)) // сконструировали имя файла R01
        if found() .and. (nReestr := mo_xml->REESTR) > 0
          select REES
          goto (nReestr)
          cFrom   := '34'
          cTo     := glob_MO[_MO_KOD_TFOMS]
          _nYear  := rees->NYEAR
          _nMonth := rees->NMONTH
          nNN     := rees->NN
        else
          aadd(arr_err, 'Это файл ответа на R01, но мы не отправляли соответствующий пакет в ТФОМС!')
        endif
        rees->(dbCloseArea())
        mo_xml->(dbCloseArea())
      elseif left(cName,4) == 'PR11'
        nTypeFile := _XML_FILE_R12
        R_Use(dir_server + 'mo_dr01', , 'REES')
        R_Use(dir_server + 'MO_XML', , 'MO_XML')
        index on upper(fname) to (cur_dir + 'tmpmoxml')
        find (padr(substr(cName, 2), 26)) // сконструировали имя файла R01
        if found() .and. (nReestr := mo_xml->REESTR) > 0
          select REES
          goto (nReestr)
          cFrom   := '34'
          cTo     := glob_MO[_MO_KOD_TFOMS]
          _nYear  := rees->NYEAR
          _nMonth := rees->NMONTH
          nNN     := rees->NN
        else
          aadd(arr_err, 'Это файл ответа на R11, но мы не отправляли соответствующий пакет в ТФОМС!')
        endif
        rees->(dbCloseArea())
        mo_xml->(dbCloseArea())
      else // "R06"
        nTypeFile := _XML_FILE_R06
        R_Use(dir_server + 'mo_dr05', , 'REES')
        R_Use(dir_server + 'MO_XML', , 'MO_XML')
        index on upper(fname) to (cur_dir + 'tmpmoxml')
        find (padr(substr(cName, 2), 26)) // сконструировали имя файла R05
        if found() .and. (nReestr := mo_xml->REESTR) > 0
          select REES
          goto (nReestr)
          cFrom   := '34'
          cTo     := glob_MO[_MO_KOD_TFOMS]
          _nYear  := rees->NYEAR
          _nMonth := 0
          nNN     := rees->NN
        else
          aadd(arr_err, 'Это файл ответа на R05, но мы не отправляли соответствующий пакет в ТФОМС!')
        endif
        rees->(dbCloseArea())
        mo_xml->(dbCloseArea())
      endif
    endif
  elseif eq_any(left(s, 4), 'PR01', 'PR11', 'PR05') // ответный файл на отосланный файл R01 (R11) (R05)
    s := substr(s, 8)
    if left(s, 1) == 'M'
      s := substr(s, 2)
    else
      aadd(arr_err, 'Неверная буква в обозначении получателя: ' + s)
    endif
    if len(arr_err) == 0
      cTo := left(s, 6)
      if !(cTo == glob_MO[_MO_KOD_TFOMS])
        aadd(arr_err, 'Ваш код МО ' + glob_MO[_MO_KOD_TFOMS] + ' не соответствует коду получателя: ' + cTo)
        if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cTo})) > 0
          aadd(arr_err, 'Это файл для: ' + glob_arr_mo[i, _MO_SHORT_NAME])
        endif
      endif
      s := substr(cName, 5, 3)
      if !(left(s, 3) == 'T34')
        aadd(arr_err, 'Неверный отправитель: ' + s)
      endif
    endif
    if len(arr_err) == 0
      if eq_any(left(cName, 4), 'PR01', 'PR11')
        nTypeFile := _XML_FILE_R02
        R_Use(dir_server + 'mo_dr01', , 'REES')
        R_Use(dir_server + 'MO_XML', , 'MO_XML')
        index on upper(fname) to (cur_dir + 'tmpmoxml')
        find (padr(substr(cName, 2), 26)) // сконструировали имя файла R01
        if found() .and. (nReestr := mo_xml->REESTR) > 0
          select REES
          goto (nReestr)
          cFrom   := '34'
          cTo     := glob_MO[_MO_KOD_TFOMS]
          _nYear  := rees->NYEAR
          _nMonth := rees->NMONTH
          nNN     := rees->NN
        else
          aadd(arr_err, 'Это файл ответа на R01(R11), но мы не отправляли такой пакет в ТФОМС!')
        endif
        rees->(dbCloseArea())
        mo_xml->(dbCloseArea())
      else // "R06"
        nTypeFile := _XML_FILE_R06
        R_Use(dir_server + 'mo_dr05', , 'REES')
        R_Use(dir_server + 'MO_XML', , 'MO_XML')
        index on upper(fname) to (cur_dir + 'tmpmoxml')
        find (padr(substr(cName, 2), 26)) // сконструировали имя файла R05
        if found() .and. (nReestr := mo_xml->REESTR) > 0
          select REES
          goto (nReestr)
          cFrom   := '34'
          cTo     := glob_MO[_MO_KOD_TFOMS]
          _nYear  := rees->NYEAR
          _nMonth := 0
          nNN     := rees->NN
        else
          aadd(arr_err, 'Это файл ответа на R05, но мы не отправляли соответствующий пакет в ТФОМС!')
        endif
        rees->(dbCloseArea())
        mo_xml->(dbCloseArea())
      endif
    endif
  else
    if eq_any(left(s, 2), 'HR', 'FR') // файл реестра СП
      s := substr(s, 3)
      nTypeFile := _XML_FILE_SP
    elseif left(s, 1) == 'A' // файл РАК
      s := substr(s, 2)
      nTypeFile := _XML_FILE_RAK
    elseif left(s, 1) == 'D' // файл РПД
      s := substr(s, 2)
      nTypeFile := _XML_FILE_RPD
    else
      aadd(arr_err, 'Попытка прочитать незнакомый файл')
    endif
    if left(s, 1) == 'T'
      // из ТФОМС
    elseif left(s, 1) == 'S'
      // от СМО
    else
      aadd(arr_err, 'Неверная буква в обозначении отправителя: ' + s)
    endif
    if len(arr_err) == 0
      if nTypeFile == _XML_FILE_SP
        s := substr(s, 2)
        cFrom := beforatnum('_', s)
        nSMO := int(val(cFrom))
        if ascan(glob_arr_smo, {|x| x[2] == nSMO}) == 0
          aadd(arr_err, 'Неверный код отправителя: ' + cFrom)
        endif
        if len(arr_err) == 0
          s := afteratnum('_', s)
          if left(s, 1) == 'M'
            s := substr(s, 2)
          else
            aadd(arr_err, 'Неверная буква в обозначении получателя: ' + s)
          endif
          if len(arr_err) == 0
            cTo := left(s, 6)
            if !(cTo == glob_MO[_MO_KOD_TFOMS])
              aadd(arr_err, 'Ваш код МО ' + glob_MO[_MO_KOD_TFOMS] + ' не соответствует коду получателя: ' + cTo)
              if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cTo})) > 0
                aadd(arr_err, 'Это файл для: ' + glob_arr_mo[i, _MO_SHORT_NAME])
              endif
            endif
          endif
          if len(arr_err) == 0
            s := substr(s, 7)
            _nYear := int(val('20' + left(s, 2)))
            _nMonth := int(val(substr(s, 3, 2)))
            nNN := int(val(substr(s, 5))) // берём строку до конца
          endif
        endif
      elseif eq_any(nTypeFile, _XML_FILE_RAK, _XML_FILE_RPD)
        s := substr(s, 2)
        cFrom := beforatnum('M', s)
        nSMO := int(val(cFrom))
        if ascan(glob_arr_smo, {|x| x[2] == nSMO }) == 0
          aadd(arr_err, 'Неверный код отправителя: ' + cFrom)
        endif
        if len(arr_err) == 0
          s := afteratnum('M', s)
          cTo := beforatnum('_', s)
          if !(cTo == glob_MO[_MO_KOD_TFOMS])
            aadd(arr_err, 'Ваш код МО ' + glob_MO[_MO_KOD_TFOMS] + ' не соответствует коду получателя: ' + cTo)
            if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cTo})) > 0
              aadd(arr_err, 'Это файл для: ' + glob_arr_mo[i, _MO_SHORT_NAME])
            endif
          endif
          if len(arr_err) == 0
            s := afteratnum('_', s)
            _nYear := int(val('20' + left(s, 2)))
            _nMonth := int(val(substr(s, 3, 2)))
            nNN := int(val(substr(s, 5))) // берём строку до конца
          endif
        endif
      endif
    endif
  endif
  if len(arr_err) == 0
    ret_arr[1] := nTypeFile
    ret_arr[2] := cFrom
    ret_arr[3] := cTo
    ret_arr[4] := _nYear
    ret_arr[5] := _nMonth
    ret_arr[6] := nNN
    ret_arr[7] := nReestr
  else
    Ins_Array(arr_err, 1, '')
    Ins_Array(arr_err, 1, 'Принимаемый файл: ' + cName)
    n_message(arr_err, , 'GR+/R', 'W+/R', , , 'G+/R')
  endif
  return (len(arr_err) == 0)

** 17.06.15 если это файл с расширениием CSV - прочитать
Function Is_Our_CSV(cName, /*@*/tip_csv_file, /*@*/kod_csv_reestr)
  Local fl := .f., i, s := cName, s1

  if eq_any(left(s, 3), 'EO2', 'LO2') // файлы протокола прикрепления и открепления
    fl := .t.
    tip_csv_file := iif(left(s, 1) == 'E', _CSV_FILE_PRIKANS, _CSV_FILE_PRIKFLK)
    kod_csv_reestr := 0
    if (s1 := substr(s, 4, 6)) == glob_MO[_MO_KOD_TFOMS]
      R_Use(dir_server + 'mo_krtf', , 'KRTF')
      index on upper(fname) to (cur_dir + 'tmp_krtf')
      find (padr(s, 26)) // не принимали ли уже данный файл
      if found()
        fl := func_error(4, 'Этот файл уже был прочитан в ' + krtf->TFILE + ' ' + date_8(krtf->DFILE) + 'г.')
        viewtext(Devide_Into_Pages(dir_server + dir_XML_TF + cslash + cName + stxt, 60, 80), , , , .t., , , 2)
      else
        find (padr('M' + substr(s, 2), 26)) // имя то же самое, начиная со второго знака
        if found()
          kod_csv_reestr := krtf->REESTR
          R_Use(dir_server + 'mo_krtr', , 'KRTR')
          goto (kod_csv_reestr)
          if krtr->ANSWER == 0 .and. tip_csv_file == _CSV_FILE_PRIKANS
            fl := func_error(4, 'Сначала необходимо прочитать файл L' + substr(s, 2) + scsv)
          endif
          krtr->(dbCloseArea())
        else
          fl := func_error(4, 'Файл прикрепления для данного протокола обработки мы не отправляли в ТФОМС!')
        endif
      endif
      krtf->(dbCloseArea())
    else
      fl := func_error(4, 'Ваш код МО ' + glob_MO[_MO_KOD_TFOMS] + ' не соответствует коду получателя: ' + s1)
      if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == s1})) > 0
        func_error(4, 'Это файл для: ' + glob_arr_mo[i, _MO_SHORT_NAME])
      endif
    endif
  else
    fl := func_error(4, 'Неизвестный файл')
  endif
  return fl

** 09.03.22 если это укрупнённый архив, распаковать и прочитать
Function Is_Our_ZIP(cName, /*@*/tip_csv_file, /*@*/kod_csv_reestr)
  Static cStFile, si
  Local fl := .f., arr := {}, arr_f, i, s := cName, s1, name_ext, _date, _time, c

  DEFAULT cStFile TO cName
  if left(s, 3) == 'RI0' .or. left(s,2) == 'I0'
    fl := func_error(4, 'Данный файл необходимо читать в подзадаче "Учёт направлений на госпитализацию"')
  elseif eq_any(left(s, 8), 'RHRT34_M', 'RFRT34_M') .and. substr(s, 9, 6) == glob_MO[_MO_KOD_TFOMS]
    c := substr(s, 2, 1)
    if (arr_f := Extract_Zip_XML(KeepPath(full_zip), StripPath(full_zip), 2)) != NIL
      for i := 1 to len(arr_f)
        s := upper(arr_f[i])
        name_ext := Name_Extention(s)
        do case
          case left(s, 8) == 'P' + c + 'RT34_M' .and. name_ext == spdf
            aadd(arr, {1, 'протокол обработки поступивших сведений ' + s, s, name_ext})
          case eq_any(left(s, 4), 'V' + c + 'RM', 'P' + c + 'RM') .and. name_ext == szip
            s1 := 'протокол ФЛК ' + s
            // проверим, читали ли уже данный файл
            if Verify_Is_Already_XML(Name_Without_Ext(s), @_date, @_time)
              s1 += ' [прочитан в ' + _time + ' ' + date_8(_date) + 'г.]'
            endif
            aadd(arr, {2, s1, s, name_ext})
          case left(s, 8) == 'M' + c + 'RT34_M' .and. name_ext == spdf
            aadd(arr, {3, 'сведения о выполнении плана-задания ' + s, s, name_ext})
          case left(s, 8) == 'F' + c + 'RT34_M' .and. name_ext == spdf
            aadd(arr, {4, 'сведения о выполнении обьемов ФО ' + s, s, name_ext})
          case left(s, 7) == c + 'RT34_M' .and. name_ext == szip
            s1 := 'реестр СП и ТК ' + s
            // проверим, читали ли уже данный файл
            if Verify_Is_Already_XML(Name_Without_Ext(s), @_date, @_time)
              s1 += ' [прочитан в ' + _time + ' ' + date_8(_date) + 'г.]'
            endif
            aadd(arr, {5, s1, s, name_ext})
        endcase
      next
      asort(arr, , , {|x, y| x[1] < y[1]})
      arr_f := {}
      aeval(arr, {|x| aadd(arr_f, x[2])})
      i := iif(cStFile == cName, si, 1)
      if (i := popup_prompt(T_ROW, T_COL - 5, i, arr_f)) > 0
        cStFile := cName
        si := i
        if arr[i, 4] == spdf
          // file_AdobeReader(_tmp2dir1+arr[i,3])
          view_file_in_Viewer(_tmp2dir1 + arr[i, 3])
        elseif arr[i, 4] == szip
          fl := .t.
          full_zip := _tmp2dir1 + arr[i, 3] // переопределяем Private-переменную
        endif
      endif
    endif
  elseif left(s, 6) == glob_MO[_MO_KOD_TFOMS]
    if (arr_f := Extract_Zip_XML(KeepPath(full_zip), StripPath(full_zip), 2)) != NIL
      for i := 1 to len(arr_f)
        s := upper(arr_f[i])
        name_ext := Name_Extention(s)
        do case
          case left(s,1) == 'R' .and. name_ext == spdf
            aadd(arr, {1, 'протокол приёма поступивших счетов ОМС ' + s, s, name_ext})
          case left(s, 2) == 'NR' .and. name_ext == spdf
            aadd(arr, {2, 'протокол отклонения поступивших счетов ОМС ' + s, s, name_ext})
        endcase
      next
      asort(arr, , , {|x, y| x[1] < y[1] })
      arr_f := {}
      aeval(arr, {|x| aadd(arr_f, x[2])})
      if (i := popup_prompt(T_ROW, T_COL - 5, 1, arr_f)) > 0
        if arr[i, 4] == spdf
          // file_AdobeReader(_tmp2dir1+arr[i,3])
          view_file_in_Viewer(_tmp2dir1 + arr[i, 3])
        endif
      endif
    endif
  elseif eq_any(left(s, 1), 'A', 'D') // файлы РАК и РПД
    fl := .t.
    s := substr(s, 2)
    if eq_any(left(s, 1), 'T', 'S')
      s := substr(s, 2)
      cFrom := beforatnum('M', s)
      nSMO := int(val(cFrom))
      if ascan(glob_arr_smo, {|x| x[2] == nSMO }) > 0
        s := afteratnum('M', s)
        if beforatnum('_', s) == glob_MO[_MO_KOD_TFOMS] .and. ;
          (arr_f := Extract_Zip_XML(KeepPath(full_zip), StripPath(full_zip), 2, 'tmp' + szip)) != NIL
          for i := 1 to len(arr_f)
            if upper(cName + szip) == upper(arr_f[i])
              full_zip := _tmp2dir1 + arr_f[i] // переопределяем Private-переменную
              exit
            endif
          next
        endif
      endif
    endif
  elseif eq_any(left(s, 2), 'E2', 'O2') // файлы протокола прикрепления и открепления
    fl := .t.
    tip_csv_file := iif(left(s, 1) == 'E', _CSV_FILE_ANSWER, _CSV_FILE_OTKREP)
    kod_csv_reestr := 0
    if (s1 := substr(s, 3, 6)) == glob_MO[_MO_KOD_TFOMS]
      R_Use(dir_server + 'mo_krtf', , 'KRTF')
      index on upper(fname) to (cur_dir + 'tmp_krtf')
      find (padr(s, 26)) // не принимали ли уже данный файл
      if found()
        fl := func_error(4, 'Этот файл уже был прочитан в ' + krtf->TFILE + ' ' + date_8(krtf->DFILE) + 'г.')
        viewtext(Devide_Into_Pages(dir_server + dir_XML_TF + cslash + cName + stxt, 60, 80), , , , .t., , , 2)
      elseif tip_csv_file == _CSV_FILE_ANSWER
        find (padr('MO' + substr(s, 2), 26)) // имя то же самое, начиная с третьего знака
        if found()
          kod_csv_reestr := krtf->REESTR
        else
          fl := func_error(4, 'Файл прикрепления для данного протокола обработки мы не отправляли в ТФОМС!')
        endif
      endif
      krtf->(dbCloseArea())
    else
      fl := func_error(4, 'Ваш код МО ' + glob_MO[_MO_KOD_TFOMS] + ' не соответствует коду получателя: ' + s1)
      if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == s1})) > 0
        func_error(4, 'Это файл для: ' + glob_arr_mo[i, _MO_SHORT_NAME])
      endif
    endif
  elseif left(s, 3) == 'SO2' // ответ на запрос сверки
    fl := .t.
    tip_csv_file := _CSV_FILE_SVERKAO
    kod_csv_reestr := 0
    if (s1 := substr(s, 4, 6)) == glob_MO[_MO_KOD_TFOMS]
      R_Use(dir_server + 'mo_krtf', , 'KRTF')
      index on upper(fname) to (cur_dir + 'tmp_krtf')
      find (padr(s, 26)) // не принимали ли уже данный файл
      if found()
        fl := func_error(4, 'Этот файл уже был прочитан в ' + krtf->TFILE + ' ' + date_8(krtf->DFILE) + 'г.')
        viewtext(Devide_Into_Pages(dir_server + dir_XML_TF + cslash + cName + stxt, 60, 80), , , , .t., , , 2)
      else
        find (padr('SZ' + substr(s, 3), 26)) // имя то же самое, начиная с третьего знака
        if found()
          kod_csv_reestr := krtf->REESTR
        else
          fl := func_error(4, 'Файл запроса по сверке для данного протокола обработки мы не отправляли в ТФОМС')
        endif
      endif
      krtf->(dbCloseArea())
    else
      fl := func_error(4, 'Ваш код МО ' + glob_MO[_MO_KOD_TFOMS] + ;
                        ' не соответствует коду получателя: ' + s1)
      if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == s1})) > 0
        func_error(4, 'Это файл для: ' + glob_arr_mo[i, _MO_SHORT_NAME])
      endif
    endif
  else
    fl := .t.
  endif
  return fl

** проверить, занесен ли данный файл в 'MO_XML'
Function Verify_Is_Already_XML(cName, /*@*/_date, /*@*/_time)
  Local l, fl, tmp_select := select()

  R_Use(dir_server + 'MO_XML', , 'MX')
  index on upper(FNAME) to (cur_dir + 'tmp_mxml')
  l := fieldlen(fieldnum('FNAME'))
  find (padr(cName, l))
  if (fl := found())
    if mx->tip_in > 0  // если принимаемый файл
      _date := mx->DREAD  // то вернём дату последнего чтения (обработки)
      _time := mx->TREAD
    else               // если отсылаемый файл
      _date := mx->DFILE  // то вернём дату создания файла
      _time := mx->TFILE
    endif
  endif
  mx->(dbCloseArea())
  select (tmp_select)
  return fl

** 20.10.14 зачитать CSV-файл в двумерный массив
Function read_CSV_to_array(cFile_csv)
  Local arr := {}, _ar, i, s, s1, lfp

  lfp := fopen(cFile_csv)
  do while !feof(lfp)
    if !empty(s := fReadLn(lfp))
      _ar := {}
      for i := 1 to numtoken(s, ';', 1)
        s1 := alltrim(charrem('"', token(s, ';', i, 1)))
        aadd(_ar, hb_AnsiToOem(s1))
      next
      for i := 1 to 25
        aadd(_ar, ' ') // добавим 25 полей (вдруг что-то не так со строкой)
      next
      aadd(arr, aclone(_ar))
    endif
  enddo
  fclose(lfp)
  return arr
  
** строка даты для XML-файла
Function date2xml(mdate)
  return strzero(year(mdate), 4) + '-' + ;
       strzero(month(mdate), 2) + '-' + ;
       strzero(day(mdate), 2)

** пребразовать дату из "2002-02-01" в тип "DATE"
Function xml2date(s)
  return stod(charrem('-',s))

** 30.01.14 проверить наличие тэга(ов) и вернуть его(их) значение(я) в массиве
Function mo_read_xml_array(_node, _title)
  Local j1, oNode2, arr := {}

  for j1 := 1 to len(_node:aitems)
    oNode2 := _node:aItems[j1]
    if upper(_title) == upper(oNode2:title) .and. !empty(oNode2:aItems) ;
                                          .and. valtype(oNode2:aItems[1]) == 'C'
      aadd(arr, oNode2:aItems[1])
    endif
  next
  return arr

** проверить наличие в узле _node XML-файла тэга _title и вернуть его значение
Function mo_read_xml_stroke(_node, _title, _aerr, _binding)
  // _node - указатель на узел
  // _title - наименование тэга
  // _aerr - массив сообщений об ошибках
  // _binding - обязателен ли атрибут (по-умолчанию .T.)
  Local ret := '', oNode, yes_err := (valtype(_aerr) == 'A'), ;
      s_msg := 'Отсутствует значение обязательного тэга "' + _title + '"'

  DEFAULT _binding TO .t.
  // ищем необходимый "_title" тэг в узле "_node"
  oNode := _node:Find(_title)
  if oNode == NIL .and. _binding .and. yes_err
    aadd(_aerr, s_msg)
  endif
  if oNode != NIL
    ret := mo_read_xml_tag(oNode, _aerr, _binding)
  endif
  return ret

** 11.12.17 вернуть значение тэга
Function mo_read_xml_tag(oNode, _aerr, _binding)
  // oNode - указатель на узел
  // _aerr - массив сообщений об ошибках
  // _binding - обязателен ли атрибут (по-умолчанию .T.)
  Local ret := '', c, yes_err := (valtype(_aerr) == 'A'), ;
      s_msg := 'Отсутствует значение обязательного тэга "' + oNode:title + '"'

  DEFAULT _binding TO .t.
  if empty(oNode:aItems)
    if _binding .and. yes_err
      aadd(_aerr, s_msg)
    endif
  elseif (c := valtype(oNode:aItems[1])) == 'C'
    if type('p_xml_code_page') == 'C' .and. upper(p_xml_code_page) == 'UTF-8'
      ret := hb_Utf8ToStr(alltrim(oNode:aItems[1]), 'RU866')
    else
      ret := hb_AnsiToOem(alltrim(oNode:aItems[1]))
    endif
  elseif yes_err
    aadd(_aerr, 'Неверный тип данных у тэга "' + oNode:title + '": "' + c + '"')
  endif
  return ret

** 22.11.13 записать в XML-файл строку (открыть тэг, записать значение, закрыть тэг)
Function mo_add_xml_stroke(oNode, sTag, sValue)
  Local oXmlNode := oNode:Add( HXMLNode():New(sTag))

  sValue := alltrim(sValue)
  if type('p_xml_code_page') == 'C' .and. upper(p_xml_code_page) == 'UTF-8'
    sValue := hb_StrToUtf8(sValue, 'RU866')
  else
    sValue := hb_OemToAnsi(sValue)
  endif
  oXmlNode:Add(sValue)
  return NIL

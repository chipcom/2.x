#include 'set.ch'
#include 'getexit.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'wapi.ch'

#define SW_SHOWNORMAL 1

// 07.03.22
// function openExcel(cFile)
//   local error

//   // error := WAPI_ShellExecute(GetDeskTopWindow(), 'open', 'Excel.exe', cFile, , 1)
//   error := WAPI_ShellExecute(GetDeskTopWindow(), 'open', cFile, , , SW_SHOWNORMAL)
//   // if error <= 32
//   //   error := WAPI_ShellExecute(GetDeskTopWindow(), 'open', 'scalc.exe', cFile, , 1)
//   // endif
//   // if error <= 32
//   //   func_error(4, 'Эе возможен запуск Excel или LibreOffice Calc!')
//   // endif
//   if error <= 32
//     Err_WAPI_ShellExecute(error, cFile)
//   endif
//   return nil

// 14.10.24
Function f_help()
  Local spar := ''
  local error
  local cFile := dir_exe() + 'CHIP_MO.CHM'

#ifdef __PLATFORM__UNIX
  alertx('Помощь не доступна!')
#else
  if chm_help_code >= 0
    spar := '-mapid ' + lstr(chm_help_code) + ' '
  endif
  error := ShellExecute(GetDeskTopWindow(), 'open', 'hh.exe', spar + cFile, , SW_SHOWNORMAL)
  if error <= 32
    Err_WAPI_ShellExecute(error, cFile)
  endif
#endif
  return NIL
  
// 14.10.24
Function view_file_in_Viewer(cFile)
  local error

#ifdef __PLATFORM__UNIX
#else
  error := WAPI_ShellExecute(GetDeskTopWindow(), 'open', cFile, , , SW_SHOWNORMAL)
  if error <= 32
    Err_WAPI_ShellExecute(error, cFile)
  endif
#endif

  return NIL
  
// 14.10.24
function Err_WAPI_ShellExecute(nCode, cFile)

  do case
    case nCode == SE_ERR_FNF
      alertx('Файл ' + cFile + ' не найден.')
    case nCode == SE_ERR_PNF
      alertx('Путь ' + hb_FNameDir(cFile ) + ' отсутствует.')
    case nCode == SE_ERR_SHARE
      alertx('Произошла ошибка совместного доступа.')
    case nCode == SE_ERR_ASSOCINCOMPLETE
      alertx('Ассоциация имени файла с расширением ' + hb_FNameExt( cFile ) + ' является или неполной или недействительной.')
    case nCode == SE_ERR_NOASSOC
      alertx('Отсутствует программа, связанная с типом файла: ' + hb_FNameExt( cFile ))
    otherwise
  endcase
  return nil

** 10.11.13 запуск Excel'а
Function Start_Excel(/*@*/oExcel, /*@*/is_open_or_create)
  Static sExcel := 'Excel.Application'
  Local ret := .f., bSaveHandler := ERRORBLOCK( {|x| BREAK(x)})

  is_open_or_create := 0
  BEGIN SEQUENCE
    oExcel := GetActiveObject(sExcel) // проверим, не открыт ли уже Excel
    oExcel:DisplayAlerts:=.f.
    is_open_or_create := 1
    ret := .t.
  RECOVER USING error
    ret := .f.
    BEGIN SEQUENCE
      oExcel := CreateObject(sExcel)  // иначе открываем сами
      is_open_or_create := 2
      ret := .t.
    RECOVER USING error
      ret := .f.
    END
  END
  ERRORBLOCK(bSaveHandler)
  Return ret

** 16.07.17 заполнить таблицу Excel'а
Function fill_in_Excel_Book(inFile, outFile, fillArray, smsg)
  Local buf := save_maxrow(), bSaveHandler, msgArray := {}
  local oSheet, oBook, oExcel, is_open_or_create, iS, jC, a, v, s
  
  keyboard ''
  if !hb_FileExists(inFile)
    return func_error(4, 'Не обнаружен файл шаблона ' + inFile)
  elseif valtype(smsg) == 'C'
    aadd(msgArray, 'Имеется возможность выгрузить информацию в файл/шаблон Excel,')
    aadd(msgArray, smsg + '.')
    aadd(msgArray, 'Файл ' + upper(outFile) + ' не должет быть открыт')
    aadd(msgArray, '(и, вообще, лучше закрыть программу Excel, если она открыта).')
    aadd(msgArray, '')
    aadd(msgArray, 'Выберите действие:')
    if f_alert(msgArray, {' Отказ ', ' Выгрузка в файл Excel '}, 1, 'GR+/R', 'W+/R', , ,'GR+/R,N/BG') != 2
      return NIL
    endif
  endif
  stat_msg('Ждите! Производится запуск Excel')
  if Start_Excel(@oExcel, @is_open_or_create)
    oExcel:Visible := .f.
    oExcel:DisplayAlerts:=.f.
    oBook := oExcel:WorkBooks:Open(inFile)
    FOR EACH oSheet IN oBook:WorkSheets
      stat_msg('Обрабатывается лист "' + oSheet:Name + '"')
      if (iS := ascan(fillArray, {|x| x[1] == oSheet:Name})) > 0
        a := fillArray[iS, 2]
        for jC := 1 to len(a) // цикл по ячейкам конкретного листа
          s := ''
          if (v := valtype(a[jC, 3])) == 'N'
            s := lstr(a[jC, 3])
          elseif v == 'C'
            s := a[jC, 3]
          elseif v == 'D'
            s := full_date(a[jC, 3])
          endif
          oSheet:Cells(a[jC, 1],a[jC, 2]):Value := s
        next
      endif
    next
    bSaveHandler := ERRORBLOCK({|x| BREAK(x)})
    BEGIN SEQUENCE
      if int(val(oExcel:get('Version'))) < 12
        oBook:SaveAs(outFile, 43)  // xlExcel9795
      else
        oBook:SaveAs(outFile, 56)  // xlExcel8
      endif
      if is_open_or_create == 2 // если Excel не был открыт, а мы его открыли
        oBook:close(.f., , .f.)   // закрыть книгу
        oExcel:Quit()           // закрываем Excel
        oBook  := nil
        oSheet := nil
        oExcel := nil
        millisec(1000)  // pause
        WAPI_SHELLEXECUTE(0, 'OPEN', outFile) // снова запускаем Excel
      else
        oBook:Activate()        // сделать книгу активной
        oExcel:Visible := .t.   // сделать Excel видимым
      endif
    RECOVER USING error
      oBook:close(.f., , .f.)   // закрыть книгу
      oExcel:Quit()           // закрываем Excel
      oBook  := nil
      oSheet := nil
      oExcel := nil
      func_error(4, 'Ошибка сохранения файла ' + upper(outFile))
    END
    ERRORBLOCK(bSaveHandler)
  else
    func_error(4, 'Неудачная попытка запуска Excel')
  endif
  rest_box(buf)
  return NIL
  
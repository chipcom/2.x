#include 'function.ch'

#define SW_SHOWNORMAL 1

// 09.04.2021
function openExcel(nameFile)
  local error

  error := ShellExecute(GetDeskTopWindow(),'open','Excel.exe',nameFile,,1)
  if error <= 32
    error := ShellExecute(GetDeskTopWindow(),'open','scalc.exe',nameFile,,1)
  endif
  if error <= 32
    func_error(4, 'Не возможен запуск Excel или LibreOffice Calc!')
  endif

  return nil

  *****
  Function f_help()
  Local spar := ''
  if chm_help_code >= 0
    spar := '-mapid '+lstr(chm_help_code)+' '
  endif
  ShellExecute(GetDeskTopWindow(),;
               'open',;
               'hh.exe',;
               spar+exe_dir+cslash+'CHIP_MO.CHM',;
               ,;
               SW_SHOWNORMAL)
  return NIL
  
  *****
  Function file_AdobeReader(cFile)
  ShellExecute(GetDeskTopWindow(),;
               'open',;
               'AcroRd32.exe',;
               cFile,;
               ,;
               SW_SHOWNORMAL)
  return NIL

***** 31.05.21
Function file_Wordpad(rtf_file)

  if hb_FileExists( rtf_file )
    ShellExecute(GetDeskTopWindow(),;
               'open',;
               'wordpad.exe',;
               rtf_file,;
               ,;
               SW_SHOWNORMAL)
  endif
  return NIL
  
  
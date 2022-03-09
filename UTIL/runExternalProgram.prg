#include 'function.ch'
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
//   //   func_error(4, '�� �������� ����� Excel ��� LibreOffice Calc!')
//   // endif
//   if error <= 32
//     Err_WAPI_ShellExecute(error, cFile)
//   endif
//   return nil

***** 07.03.22
Function f_help()
  Local spar := ''
  local error
  local cFile := exe_dir + cslash + 'CHIP_MO.CHM'
  
  if chm_help_code >= 0
    spar := '-mapid ' + lstr(chm_help_code) + ' '
  endif
  error := ShellExecute(GetDeskTopWindow(), 'open', 'hh.exe', spar + cFile, , SW_SHOWNORMAL)
  if error <= 32
    Err_WAPI_ShellExecute(error, cFile)
  endif
  return NIL
  
***** 07.03.22
// Function file_AdobeReader(cFile)
//   local error

//   // error := WAPI_ShellExecute(GetDeskTopWindow(), 'open', 'AcroRd32.exe', cFile, , SW_SHOWNORMAL)
//   error := WAPI_ShellExecute(GetDeskTopWindow(), 'open', cFile, , , SW_SHOWNORMAL)
//   if error <= 32
//     Err_WAPI_ShellExecute(error, cFile)
//   endif
//   return NIL

***** 07.03.22
// Function file_Wordpad(cFile)
//   local error

//   error := WAPI_ShellExecute(GetDeskTopWindow(), 'open', cFile, , , SW_SHOWNORMAL)
//   if error <= 32
//     Err_WAPI_ShellExecute(error, cFile)
//   endif
//   return NIL
  
***** 09.03.22
Function view_file_in_Viewer(cFile)
  local error

  error := WAPI_ShellExecute(GetDeskTopWindow(), 'open', cFile, , , SW_SHOWNORMAL)
  if error <= 32
    Err_WAPI_ShellExecute(error, cFile)
  endif
  return NIL
  
***** 07.03.22
function Err_WAPI_ShellExecute(nCode, cFile)

  do case
    case nCode == SE_ERR_FNF
      alertx('���� ' + cFile + ' �� ������.')
    case nCode == SE_ERR_PNF
      alertx('���� ' + hb_FNameDir(cFile ) + ' ���������.')
    case nCode == SE_ERR_SHARE
      alertx('�ந��諠 �訡�� ᮢ���⭮�� ����㯠.')
    case nCode == SE_ERR_ASSOCINCOMPLETE
      alertx('���樠�� ����� 䠩�� � ���७��� ' + hb_FNameExt( cFile ) + ' ���� ��� �������� ��� ������⢨⥫쭮�.')
    case nCode == SE_ERR_NOASSOC
      alertx('��������� �ணࠬ��, �易���� � ⨯�� 䠩��: ' + hb_FNameExt( cFile ))
    otherwise
  endcase
  return nil
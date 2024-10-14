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
//   //   func_error(4, '�� �������� ����� Excel ��� LibreOffice Calc!')
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
  alertx('������ �� ����㯭�!')
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

** 10.11.13 ����� Excel'�
Function Start_Excel(/*@*/oExcel, /*@*/is_open_or_create)
  Static sExcel := 'Excel.Application'
  Local ret := .f., bSaveHandler := ERRORBLOCK( {|x| BREAK(x)})

  is_open_or_create := 0
  BEGIN SEQUENCE
    oExcel := GetActiveObject(sExcel) // �஢�ਬ, �� ����� �� 㦥 Excel
    oExcel:DisplayAlerts:=.f.
    is_open_or_create := 1
    ret := .t.
  RECOVER USING error
    ret := .f.
    BEGIN SEQUENCE
      oExcel := CreateObject(sExcel)  // ���� ���뢠�� ᠬ�
      is_open_or_create := 2
      ret := .t.
    RECOVER USING error
      ret := .f.
    END
  END
  ERRORBLOCK(bSaveHandler)
  Return ret

** 16.07.17 ��������� ⠡���� Excel'�
Function fill_in_Excel_Book(inFile, outFile, fillArray, smsg)
  Local buf := save_maxrow(), bSaveHandler, msgArray := {}
  local oSheet, oBook, oExcel, is_open_or_create, iS, jC, a, v, s
  
  keyboard ''
  if !hb_FileExists(inFile)
    return func_error(4, '�� �����㦥� 䠩� 蠡���� ' + inFile)
  elseif valtype(smsg) == 'C'
    aadd(msgArray, '������� ����������� ���㧨�� ���ଠ�� � 䠩�/蠡��� Excel,')
    aadd(msgArray, smsg + '.')
    aadd(msgArray, '���� ' + upper(outFile) + ' �� ������ ���� �����')
    aadd(msgArray, '(�, �����, ���� ������� �ணࠬ�� Excel, �᫨ ��� �����).')
    aadd(msgArray, '')
    aadd(msgArray, '�롥�� ����⢨�:')
    if f_alert(msgArray, {' �⪠� ', ' ���㧪� � 䠩� Excel '}, 1, 'GR+/R', 'W+/R', , ,'GR+/R,N/BG') != 2
      return NIL
    endif
  endif
  stat_msg('����! �ந�������� ����� Excel')
  if Start_Excel(@oExcel, @is_open_or_create)
    oExcel:Visible := .f.
    oExcel:DisplayAlerts:=.f.
    oBook := oExcel:WorkBooks:Open(inFile)
    FOR EACH oSheet IN oBook:WorkSheets
      stat_msg('��ࠡ��뢠���� ���� "' + oSheet:Name + '"')
      if (iS := ascan(fillArray, {|x| x[1] == oSheet:Name})) > 0
        a := fillArray[iS, 2]
        for jC := 1 to len(a) // 横� �� �祩��� �����⭮�� ����
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
      if is_open_or_create == 2 // �᫨ Excel �� �� �����, � �� ��� ���뫨
        oBook:close(.f., , .f.)   // ������� �����
        oExcel:Quit()           // ����뢠�� Excel
        oBook  := nil
        oSheet := nil
        oExcel := nil
        millisec(1000)  // pause
        WAPI_SHELLEXECUTE(0, 'OPEN', outFile) // ᭮�� ����᪠�� Excel
      else
        oBook:Activate()        // ᤥ���� ����� ��⨢���
        oExcel:Visible := .t.   // ᤥ���� Excel ������
      endif
    RECOVER USING error
      oBook:close(.f., , .f.)   // ������� �����
      oExcel:Quit()           // ����뢠�� Excel
      oBook  := nil
      oSheet := nil
      oExcel := nil
      func_error(4, '�訡�� ��࠭���� 䠩�� ' + upper(outFile))
    END
    ERRORBLOCK(bSaveHandler)
  else
    func_error(4, '��㤠筠� ����⪠ ����᪠ Excel')
  endif
  rest_box(buf)
  return NIL
  
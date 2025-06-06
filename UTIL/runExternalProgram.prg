#include 'set.ch'
#include 'getexit.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'wapi.ch'

#define SW_SHOWNORMAL 1

// 14.10.24
Function f_help()

  Local spar := ''
  Local error
  Local cFile := dir_exe() + 'chip_mo.chm'

#ifdef __PLATFORM__UNIX
  alertx( '������ �� ����㯭�!' )
#else
  If chm_help_code >= 0
    spar := '-mapid ' + lstr( chm_help_code ) + ' '
  Endif
  error := shellexecute( getdesktopwindow(), 'open', 'hh.exe', spar + cFile, , SW_SHOWNORMAL )
  If error <= 32
    err_wapi_shellexecute( error, cFile )
  Endif
#endif
  Return Nil

// 14.10.24
Function view_file_in_viewer( cFile )

  Local error

#ifdef __PLATFORM__UNIX
#else

  error := wapi_ShellExecute( getdesktopwindow(), 'open', cFile, , , SW_SHOWNORMAL )
  If error <= 32
    err_wapi_shellexecute( error, cFile )
  Endif
#endif
  Return Nil

// 14.10.24
Function err_wapi_shellexecute( nCode, cFile )

  Do Case
  Case nCode == SE_ERR_FNF
    alertx( '���� ' + cFile + ' �� ������.' )
  Case nCode == SE_ERR_PNF
    alertx( '���� ' + hb_FNameDir( cFile ) + ' ���������.' )
  Case nCode == SE_ERR_SHARE
    alertx( '�ந��諠 �訡�� ᮢ���⭮�� ����㯠.' )
  Case nCode == SE_ERR_ASSOCINCOMPLETE
    alertx( '���樠�� ����� 䠩�� � ���७��� ' + hb_FNameExt( cFile ) + ' ���� ��� �������� ��� ������⢨⥫쭮�.' )
  Case nCode == SE_ERR_NOASSOC
    alertx( '��������� �ணࠬ��, �易���� � ⨯�� 䠩��: ' + hb_FNameExt( cFile ) )
  Otherwise
  Endcase
  Return Nil

// * 10.11.13 ����� Excel'�
Function start_excel( /*@*/oExcel, /*@*/is_open_or_create)

  Static sExcel := 'Excel.Application'
  Local ret := .f., bSaveHandler := ErrorBlock( {| x| Break( x ) } )

  is_open_or_create := 0
  Begin Sequence
    oExcel := GetActiveObject( sExcel ) // �஢�ਬ, �� ����� �� 㦥 Excel
    oExcel:DisplayAlerts := .f.
    is_open_or_create := 1
    ret := .t.
  RECOVER USING error
    ret := .f.
    Begin Sequence
      oExcel := CreateObject( sExcel )  // ���� ���뢠�� ᠬ�
      is_open_or_create := 2
      ret := .t.
    RECOVER USING error
      ret := .f.
    End
  End
  ErrorBlock( bSaveHandler )
  Return ret

// 16.07.17 ��������� ⠡���� Excel'�
Function fill_in_excel_book( inFile, outFile, fillArray, smsg )

  Local buf := save_maxrow(), bSaveHandler, msgArray := {}
  Local oSheet, oBook, oExcel, is_open_or_create, iS, jC, a, v, s

  Keyboard ''
  If !hb_FileExists( inFile )
    Return func_error( 4, '�� �����㦥� 䠩� 蠡���� ' + inFile )
  Elseif ValType( smsg ) == 'C'
    AAdd( msgArray, '������� ����������� ���㧨�� ���ଠ�� � 䠩�/蠡��� Excel,' )
    AAdd( msgArray, smsg + '.' )
    AAdd( msgArray, '���� ' + Upper( outFile ) + ' �� ������ ���� �����' )
    AAdd( msgArray, '(�, �����, ���� ������� �ணࠬ�� Excel, �᫨ ��� �����).' )
    AAdd( msgArray, '' )
    AAdd( msgArray, '�롥�� ����⢨�:' )
    If f_alert( msgArray, { ' �⪠� ', ' ���㧪� � 䠩� Excel ' }, 1, 'GR+/R', 'W+/R', , , 'GR+/R,N/BG' ) != 2
      Return Nil
    Endif
  Endif
  stat_msg( '����! �ந�������� ����� Excel' )
  If start_excel( @oExcel, @is_open_or_create )
    oExcel:Visible := .f.
    oExcel:DisplayAlerts := .f.
    oBook := oExcel:WorkBooks:open( inFile )
    For Each oSheet IN oBook:WorkSheets
      stat_msg( '��ࠡ��뢠���� ���� "' + oSheet:Name + '"' )
      If ( iS := AScan( fillArray, {| x| x[ 1 ] == oSheet:Name } ) ) > 0
        a := fillArray[ iS, 2 ]
        For jC := 1 To Len( a ) // 横� �� �祩��� �����⭮�� ����
          s := ''
          If ( v := ValType( a[ jC, 3 ] ) ) == 'N'
            s := lstr( a[ jC, 3 ] )
          Elseif v == 'C'
            s := a[ jC, 3 ]
          Elseif v == 'D'
            s := full_date( a[ jC, 3 ] )
          Endif
          oSheet:cells( a[ jC, 1 ], a[ jC, 2 ] ):Value := s
        Next
      Endif
    Next
    bSaveHandler := ErrorBlock( {| x| Break( x ) } )
    Begin Sequence
      If Int( Val( oExcel:Get( 'Version' ) ) ) < 12
        oBook:saveas( outFile, 43 )  // xlExcel9795
      Else
        oBook:saveas( outFile, 56 )  // xlExcel8
      Endif
      If is_open_or_create == 2 // �᫨ Excel �� �� �����, � �� ��� ���뫨
        oBook:close( .f., , .f. )   // ������� �����
        oExcel:quit()           // ����뢠�� Excel
        oBook  := nil
        oSheet := nil
        oExcel := nil
        Millisec( 1000 )  // pause
        wapi_ShellExecute( 0, 'OPEN', outFile ) // ᭮�� ����᪠�� Excel
      Else
        oBook:activate()        // ᤥ���� ����� ��⨢���
        oExcel:Visible := .t.   // ᤥ���� Excel ������
      Endif
    RECOVER USING error
      oBook:close( .f., , .f. )   // ������� �����
      oExcel:quit()           // ����뢠�� Excel
      oBook  := nil
      oSheet := nil
      oExcel := nil
      func_error( 4, '�訡�� ��࠭���� 䠩�� ' + Upper( outFile ) )
    End
    ErrorBlock( bSaveHandler )
  Else
    func_error( 4, '��㤠筠� ����⪠ ����᪠ Excel' )
  Endif
  rest_box( buf )
  Return Nil

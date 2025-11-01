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
  alertx( 'Помощь не доступна!' )
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
    alertx( 'Файл ' + cFile + ' не найден.' )
  Case nCode == SE_ERR_PNF
    alertx( 'Путь ' + hb_FNameDir( cFile ) + ' отсутствует.' )
  Case nCode == SE_ERR_SHARE
    alertx( 'Произошла ошибка совместного доступа.' )
  Case nCode == SE_ERR_ASSOCINCOMPLETE
    alertx( 'Ассоциация имени файла с расширением ' + hb_FNameExt( cFile ) + ' является или неполной или недействительной.' )
  Case nCode == SE_ERR_NOASSOC
    alertx( 'Отсутствует программа, связанная с типом файла: ' + hb_FNameExt( cFile ) )
  Otherwise
  Endcase
  Return Nil

// * 10.11.13 запуск Excel'а
Function start_excel( /*@*/oExcel, /*@*/is_open_or_create)

  Static sExcel := 'Excel.Application'
  Local ret := .f., bSaveHandler := ErrorBlock( {| x| Break( x ) } )

  is_open_or_create := 0
  Begin Sequence
    oExcel := GetActiveObject( sExcel ) // проверим, не открыт ли уже Excel
    oExcel:DisplayAlerts := .f.
    is_open_or_create := 1
    ret := .t.
  RECOVER USING error
    ret := .f.
    Begin Sequence
      oExcel := CreateObject( sExcel )  // иначе открываем сами
      is_open_or_create := 2
      ret := .t.
    RECOVER USING error
      ret := .f.
    End
  End
  ErrorBlock( bSaveHandler )
  Return ret

// 16.07.17 заполнить таблицу Excel'а
Function fill_in_excel_book( inFile, outFile, fillArray, smsg )

  Local buf := save_maxrow(), bSaveHandler, msgArray := {}
  Local oSheet, oBook, oExcel, is_open_or_create, iS, jC, a, v, s

  Keyboard ''
  If !hb_FileExists( inFile )
    Return func_error( 4, 'Не обнаружен файл шаблона ' + inFile )
  Elseif ValType( smsg ) == 'C'
    AAdd( msgArray, 'Имеется возможность выгрузить информацию в файл/шаблон Excel,' )
    AAdd( msgArray, smsg + '.' )
    AAdd( msgArray, 'Файл ' + Upper( outFile ) + ' не должет быть открыт' )
    AAdd( msgArray, '(и, вообще, лучше закрыть программу Excel, если она открыта).' )
    AAdd( msgArray, '' )
    AAdd( msgArray, 'Выберите действие:' )
    If f_alert( msgArray, { ' Отказ ', ' Выгрузка в файл Excel ' }, 1, 'GR+/R', 'W+/R', , , 'GR+/R,N/BG' ) != 2
      Return Nil
    Endif
  Endif
  stat_msg( 'Ждите! Производится запуск Excel' )
  If start_excel( @oExcel, @is_open_or_create )
    oExcel:Visible := .f.
    oExcel:DisplayAlerts := .f.
    oBook := oExcel:WorkBooks:open( inFile )
    For Each oSheet IN oBook:WorkSheets
      stat_msg( 'Обрабатывается лист "' + oSheet:Name + '"' )
      If ( iS := AScan( fillArray, {| x| x[ 1 ] == oSheet:Name } ) ) > 0
        a := fillArray[ iS, 2 ]
        For jC := 1 To Len( a ) // цикл по ячейкам конкретного листа
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
      If is_open_or_create == 2 // если Excel не был открыт, а мы его открыли
        oBook:close( .f., , .f. )   // закрыть книгу
        oExcel:quit()           // закрываем Excel
        oBook  := nil
        oSheet := nil
        oExcel := nil
        Millisec( 1000 )  // pause
        wapi_ShellExecute( 0, 'OPEN', outFile ) // снова запускаем Excel
      Else
        oBook:activate()        // сделать книгу активной
        oExcel:Visible := .t.   // сделать Excel видимым
      Endif
    RECOVER USING error
      oBook:close( .f., , .f. )   // закрыть книгу
      oExcel:quit()           // закрываем Excel
      oBook  := nil
      oSheet := nil
      oExcel := nil
      func_error( 4, 'Ошибка сохранения файла ' + Upper( outFile ) )
    End
    ErrorBlock( bSaveHandler )
  Else
    func_error( 4, 'Неудачная попытка запуска Excel' )
  Endif
  rest_box( buf )
  Return Nil

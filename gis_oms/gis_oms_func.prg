// различные функции справочников ГИС ОМС - gis_oms.prg
#include 'set.ch'
#include 'getexit.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'tfile.ch'
#include 'tbox.ch'

#require 'rddsql'
#require 'sddsqlt3'

#include 'simpleio.ch'
#include 'dbinfo.ch'

REQUEST SDDSQLITE3, SQLMIX

// 12.08.26 {_MO_KOD_TFOMS,_MO_SHORT_NAME}
Function viewf032() 

  Local nTop, nLeft, nBottom, nRight
  Local tmp_select := Select()
  Local l := 0, fl
  Local ar
  Local color_say := 'N/W', color_get := 'W/N*'
  Local oBox, oBoxRegion
  Local strRegion := 'Выбор региона'
  Local lFileCreated := .f.
  Local retMCOD := { '', Space( 10 ) }
  Local ar_f010 := getf010()
  Local selectedRegion := '34'
  Local sbase := 'mo_add'
  Local prev_codem := 0, cur_codem := 0
  Local i, ifi
  local nRegion := 34
  local funcColumn, funcView
  local tmpAlias := 'tF032'
  local pDb, f032_mcod, f032_namemok, f032_namemop, f032_address

  Private oBoxCompany

  ar := {}
  For i := 1 To Len( ar_f010 )
    if between_date( ar_f010[ i, 5 ], ar_f010[ i, 6 ], Date() )
      AAdd( ar, ar_f010[ i, 1 ] )
      l := Max( l, Len( ar[ Len( ar ) ] ) )
    endif
  Next

  nTop := 4
  nLeft := 3
  nBottom := 23
  nRight := 77

  // окно выбора региона
  oBoxRegion := tbox():new( nTop, nLeft, nBottom, nRight )
  oBoxRegion:Caption := 'Выберите регион'
  oBoxRegion:Frame := BORDER_SINGLE

  // окно полного наименования организации
  oBoxCompany := tbox():new( 19, 11, 21, 68 )
  oBoxCompany:Frame := BORDER_NONE
  oBoxCompany:Color := color5

  // главное окно
  oBox := Nil // уничтожим окно
  oBox := tbox():new( 2, 10, 22, 70 )
  oBox:Color := color_say + ',' + color_get
  oBox:Frame := BORDER_DOUBLE
  oBox:MessageLine := '^^ или нач.буква - просмотр;  ^<Esc>^ - выход;  ^<Enter>^ - выбор'
  oBox:Save := .t.

  oBoxRegion:MessageLine := '^^ или нач.буква - просмотр;  ^<Esc>^ - выход;  ^<Enter>^ - выбор'
  oBoxRegion:Save := .t.
  oBoxRegion:view()
  nRegion := AChoice( oBoxRegion:Top + 1, oBoxRegion:Left + 1, oBoxRegion:Bottom -1, oBoxRegion:Right - 1, ar, , , 34 )
  If nRegion == 0
    Select ( tmp_select )
    Return retMCOD
  Else
    selectedRegion  := StrZero( nRegion, 2 )
  Endif

#if defined( __HBSCRIPT__HBSHELL )
    rddRegister( 'SQLBASE' )
    rddRegister( 'SQLMIX' )
    hb_SDDSQLITE3_Register()
#endif

  rddSetDefault( 'SQLMIX' )
  pDb := rddInfo( RDDI_CONNECT, { 'SQLITE3', dir_exe() + FILE_NAME_SQL } )

  dbUseArea( .T., , 'select mcod, namemok, namemop, address, region from f032 where region==' + selectedRegion, 'f032' )
  f032->( dbGoTop() )

  oBox:Caption := 'Выбор направившей организации'
  oBox:view()

  funcColumn := 'columnF032' + '(' + 'oBrowse, "' + 'f032' + '")'
  funcView := 'ViewRecordF032' + '("' + 'f032' + '")'

  If fl := alpha_browse( oBox:Top + 1, oBox:Left + 1, oBox:Bottom -5, oBox:Right - 1, funcColumn, color0, , , , , , funcView, 'controlF032', , { '═', '░', '═', 'N/BG, W+/N, B/BG, BG+/B' } )
    // проверяем выбор
    If ( ifi := hb_AScan( glob_arr_mo(), {| x| x[ _MO_KOD_FFOMS ] == f032->MCOD }, , , .t. ) ) > 0
      // нашли в файле
      Alert( 'Медицинское учреждение уже добавлено в справочник!' )
      f032->( dbCloseArea() )
      rddSetDefault( 'DBFNTX' )
    Else
      f032_mcod := f032->mcod
      f032_namemok := f032->namemok
      f032_namemop := f032->namemop
      f032_address := f032->address
      f032->( dbCloseArea() )
      rddSetDefault( 'DBFNTX' )
      If g_use( dir_server() + sbase, dir_server() + sbase, sbase, , .t., )
        ( sbase )->( dbGoTop() )
        Do While ! ( sbase )->( Eof() )
          prev_codem := ( sbase )->CODEM
          ( sbase )->( dbSkip() )
          cur_codem := ( sbase )->CODEM
          If ( Val( cur_codem ) - Val( prev_codem ) ) != 1
            ( sbase )->( dbAppend() )
            ( sbase )->MCOD := f032_mcod
            ( sbase )->CODEM := Str( Val( prev_codem ) + 1, 6 )
            ( sbase )->NAMEF := f032_namemop
            ( sbase )->NAMES := f032_namemok
            ( sbase )->ADRES := f032_address
            ( sbase )->DEND := hb_SToD( '20261231' )
            Exit
          Endif
        Enddo
        ( sbase )->( dbCloseArea() )
        retMCOD := { Str( Val( prev_codem ) + 1, 6 ), AllTrim( f032_namemok ) }
      Endif
    Endif
  else
    f032->( dbCloseArea() )
    rddSetDefault( 'DBFNTX' )
  Endif
  selectedRegion := ''

  oBoxRegion := NIL
  oBoxCompany := nil
  oBox := nil
  Select ( tmp_select )

  Return retMCOD

// 06.06.26
Function controlf032( nkey, oBrow )

  Local ret := -1

  Return ret

// 12.08.26
Function columnf032( oBrow, al )

  Local oColumn

  oColumn := TBColumnNew( Center( 'Наименование', 50 ), {|| Padr( ( al )->NAMEMOK, 50 ) } )
  oBrow:addcolumn( oColumn )
  status_key( '^<Esc>^ - выход; ^<Enter>^ - выбор' )

  Return Nil

// 21.01.21
Function viewrecordf032( al )

  Local i, arr := {}, count

  If ! oBoxCompany:Visible
    oBoxCompany:view()
  Else
    oBoxCompany:clear()
  Endif
  // разобьем полное наменование на подстроки
  perenos( arr, ( al )->NAMEMOP, oBoxCompany:Width )
  count := iif( Len( arr ) > oBoxCompany:Height, oBoxCompany:Height, Len( arr ) )

  For i := 1 To count
    @ oBoxCompany:Top + i - 1, oBoxCompany:Left + 1 Say arr[ i ]
  Next

  Return Nil


// 30.03.26
function get_f032() 

  static arr
  Local tmp_select := Select(), pDb

  if HB_ISNIL( arr )
    arr := {}
#if defined( __HBSCRIPT__HBSHELL )
    rddRegister( 'SQLBASE' )
    rddRegister( 'SQLMIX' )
    hb_SDDSQLITE3_Register()
#endif

    rddSetDefault( 'SQLMIX' )
    pDb := rddInfo( RDDI_CONNECT, { 'SQLITE3', dir_exe() + FILE_NAME_SQL } )

    dbUseArea( .T., , 'select namemok, mcod from f032', 'f032' )
    f032->( dbGoTop() )
    do while ! f032->( Eof() )
      AAdd( arr, { AllTrim( f032->NAMEMOK ), f032->MCOD } )
      f032->( dbSkip() )
    enddo
    f032->( dbCloseArea() )
    rddSetDefault( 'DBFNTX' )
    Select ( tmp_select )
  endif
  
  return arr

// 24.01.26
function get_f032_prik()

  static arr

  local i, j, loc_m
  local arr_glob := glob_arr_mo()
  local arr_f032 := get_f032()

  if HB_ISNIL( arr )
    arr := {}
    for i := 1 to len( arr_f032 )
      loc_m := arr_f032[ i, 2 ]
      if ( j := ascan( arr_glob, { | x | ( x[ _MO_KOD_FFOMS ] == loc_m ) .and. x[ _MO_IS_UCH ] } ) ) > 0
        AAdd( arr, { arr_f032[ i, 1 ], arr_f032[ i, 2 ] } )
      endif
    next
  endif
  return arr

// 10.08.26 вернуть UIDMO из справочника F032
Function ret_uidmo_f032( mcod )

  Local tmp_select := Select()
  Local pDb, cUIDMO := ''

#if defined( __HBSCRIPT__HBSHELL )
   rddRegister( 'SQLBASE' )
   rddRegister( 'SQLMIX' )
   hb_SDDSQLITE3_Register()
#endif

  rddSetDefault( 'SQLMIX' )
  pDb := rddInfo( RDDI_CONNECT, { 'SQLITE3', dir_exe() + FILE_NAME_SQL } )

  dbUseArea( .T., , 'select uidmo, mcod from f032 where mcod==' + mcod, 'f032' )

  f032->( dbGoTop() )
  if ! f032->( Eof() ) .and. ! f032->( Bof() )  //   f032->( Found() )
    cUIDMO := f032->UIDMO
  Endif

  f032->( dbCloseArea() )
  rddSetDefault( 'DBFNTX' )
  Select ( tmp_select )

  return cUIDMO

// 10.08.26 вернуть массив из справочника F033
Function get_f033( mcod )

  Local tmp_select := Select()
  Local cUIDMO, pDb
  Local arr := {}

  cUIDMO := AllTrim( ret_uidmo_f032( mcod ) )

  if ! Empty( cUIDMO )

#if defined( __HBSCRIPT__HBSHELL )
   rddRegister( 'SQLBASE' )
   rddRegister( 'SQLMIX' )
   hb_SDDSQLITE3_Register()
#endif

    rddSetDefault( 'SQLMIX' )
    pDb := rddInfo( RDDI_CONNECT, { 'SQLITE3', dir_exe() + FILE_NAME_SQL } )
    dbUseArea( .T., , 'select nam_sk, uidspmo from f033', 'f033' )
    f033->( dbGoTop() )

    Do While ! f033->( Eof() )
      if SubStr( f033->uidspmo, 1, 11 ) == cUIDMO
        AAdd( arr, { AllTrim( f033->NAM_SK ), f033->UIDSPMO } )
      endif
      f033->( dbSkip() )
    Enddo
    f033->( dbCloseArea() )
    rddSetDefault( 'DBFNTX' )
  endif
  Select ( tmp_select )

  return arr

// 10.08.26 вернуть массив из справочника F033
Function get_f033_with_address( mcod )

  Local tmp_select := Select()
  local pDb
  Local i
  local mStr, pos
  Local arr := get_f033( mcod )

#if defined( __HBSCRIPT__HBSHELL )
   rddRegister( 'SQLBASE' )
   rddRegister( 'SQLMIX' )
   hb_SDDSQLITE3_Register()
#endif

  rddSetDefault( 'SQLMIX' )
  pDb := rddInfo( RDDI_CONNECT, { 'SQLITE3', dir_exe() + FILE_NAME_SQL } )
  for i := 1 to Len( arr )
// TODO: оптимизировать алгоритм запроса
    dbUseArea( .T., , 'select addr, uidspmo from f038 where uidspmo==' + arr[ i, 2 ], 'f038' )
    f038->( dbGoTop() )
    if ! f038->( Eof() ) .and. ! f038->( Bof() )
      mStr := StrTran( AllTrim( SubStr( f038->ADDR, 8 ) ), 'Волгоградская область, ', '' )
      pos := hb_At( 'район,', mstr )
      if pos != 0
        mStr := SubStr( mstr, pos + 7 )
      endif
      arr[ i, 1 ] += ' - ' + mStr
    endif
  f038->( dbCloseArea() )
  next
  rddSetDefault( 'DBFNTX' )
  Select ( tmp_select )
  
  return arr

// 11.08.26 вернуть массив из справочника F034
Function get_f034( mUIDSPMO )

  Static sUIDSPMO
  Static arr
  Local tmp_select := Select()
  local db, aTable
//  local nI

//  MPVID	Char	4	О	Код вида МП, оказываемой МО по указанному условию оказания и профилю МП. 
//  Заполняется в соответствии с Лицензией на осуществление МД, с использованием Классификатора видов МП (атрибут IDVMP справочника V008)
//	MPUSL	Char	2	О	Код условий оказания МП, оказываемой МО по указан?ному виду и профилю МП.
//  Заполняется в соответствии с Лицензией на осуществле?ние МД, с использованием Классификатора условий ока?зания МП (атрибут IDUMP справочника V006)
//  MPROF	Char	3	О	Код профиля МП, оказываемой МО по указанному виду и условию оказания МП.
//  Заполняется в соответствии с Ли-цензией на осуществление МД, с использованием Класси-фикатора профилей МП (атрибут IDPR справочника V002)

  if HB_ISNIL( arr ) .or. HB_ISNIL( sUIDSPMO ) .or. ( sUIDSPMO != mUIDSPMO )
    sUIDSPMO := mUIDSPMO
    arr := {}

    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT mpvid, mpusl, mprof, uidspmo FROM f034' )
    If Len( aTable ) > 1
      AEval( aTable, { | elem | iif( elem[ 4 ] == mUIDSPMO, AAdd( arr, { Val( elem[ 1 ] ), Val( elem[ 2 ] ), Val( elem[ 3 ] ) } ), ) } )
    Endif
    db := nil
/*
    r_use( dir_exe() + '_mo_f034', cur_dir() + '_mo_f034', 'F034' )
    f034->( dbSeek( mUIDSPMO ) )
    Do While f034->uidspmo == mUIDSPMO .and. ! f034->( Eof() )
      AAdd( arr, { f034->MPVID, f034->MPUSL, f034->MPROF } )
      f034->( dbSkip() )
    Enddo
    dbCloseArea()
    Select ( tmp_select )
*/
  endif

  return arr

// 14.04.26 вернуть массив из справочника F034
Function get_f034_usl_ok( mUIDSPMO, usl_ok )

  Local aF034
  Local arr

//  MPVID	Char	4	О	Код вида МП, оказываемой МО по указанному условию оказания и профилю МП. 
//  Заполняется в соответствии с Лицензией на осуществление МД, с использованием Классификатора видов МП (атрибут IDVMP справочника V008)
//	MPUSL	Char	2	О	Код условий оказания МП, оказываемой МО по указан?ному виду и профилю МП.
//  Заполняется в соответствии с Лицензией на осуществле?ние МД, с использованием Классификатора условий ока?зания МП (атрибут IDUMP справочника V006)
//  MPROF	Char	3	О	Код профиля МП, оказываемой МО по указанному виду и условию оказания МП.
//  Заполняется в соответствии с Ли-цензией на осуществление МД, с использованием Класси-фикатора профилей МП (атрибут IDPR справочника V002)

  arr := {}
  aF034 := get_f034( mUIDSPMO )
  AEval( aF034, { | elem | iif( elem[ 2 ] == usl_ok, AAdd( arr, elem ), ) } )

  return arr

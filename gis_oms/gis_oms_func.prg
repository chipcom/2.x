// различные функции справочников ГИС ОМС - gis_oms.prg
#include 'set.ch'
#include 'getexit.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'tfile.ch'

#require 'rddsql'
#require 'sddsqlt3'

#include 'simpleio.ch'
#include 'dbinfo.ch'

REQUEST SDDSQLITE3, SQLMIX

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

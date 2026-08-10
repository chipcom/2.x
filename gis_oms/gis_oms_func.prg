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
  pDb := rddInfo( RDDI_CONNECT, { 'SQLITE3', dir_exe() + 'gis_mo.db' } )

  dbUseArea( .T., , 'select uidmo, mcod from f032 where mcod==' + mcod, 'f032' )

//  r_use( dir_exe() + '_mo_f032', cur_dir() + '_mo_f032', 'f032' )
//  f032->( dbSeek( mcod ) )
  f032->( dbGoTop() )
  if ! f032->( Eof() ) .and. ! f032->( Bof() )  //   f032->( Found() )
    cUIDMO := f032->UIDMO
  Endif

  f032->( dbCloseArea() )
  rddSetDefault( 'DBFNTX' )
  Select ( tmp_select )

  return cUIDMO

/*

// 06.02.26 вернуть массив из справочника F033
Function get_f033( mcod )

  Local tmp_select, pDb
  Local cUIDMO
  Local arr := {}

#if defined( __HBSCRIPT__HBSHELL )
   rddRegister( 'SQLBASE' )
   rddRegister( 'SQLMIX' )
   hb_SDDSQLITE3_Register()
#endif

  tmp_select := Select()

  cUIDMO := AllTrim( ret_uidmo_f032( mcod ) )

  rddSetDefault( 'SQLMIX' )
  pDb := rddInfo( RDDI_CONNECT, { 'SQLITE3', dir_exe() + 'gis_mo.db' } )

  if ! Empty( cUIDMO )

//    dbUseArea( .T., , 'select nam_sk, uidspmo from f033 where substr(uidspmo,1,11)==' + cUIDMO, 'f033' )
    dbUseArea( .T., , 'select nam_sk, uidspmo from f033', 'f033' )

    f033->( dbGoTop() )

//    r_use( dir_exe() + '_mo_f033', cur_dir() + '_mo_f033', 'F033' )
//    f033->( dbSeek( cUIDMO ) )
    Do While SubStr( f033->uidspmo, 1, 11 ) == cUIDMO .and. ! f033->( Eof() )
      AAdd( arr, { AllTrim( f033->NAM_SK ), f033->UIDSPMO } )
      f033->( dbSkip() )
altd()
    Enddo
    f033->( dbCloseArea() )
  endif

  rddSetDefault( 'DBFNTX' )
  Select ( tmp_select )

  return arr
*/
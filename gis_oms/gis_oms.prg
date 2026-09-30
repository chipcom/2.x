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

// 10.09.26
function gis_oms() 

  local buf
  local tmp_select := Select()
  LOCAL pDb

#if defined( __HBSCRIPT__HBSHELL )
   rddRegister( 'SQLBASE' )
   rddRegister( 'SQLMIX' )
   hb_SDDSQLITE3_Register()
#endif

  buf := save_maxrow()

  rddSetDefault( 'SQLMIX' )
  pDb := rddInfo( RDDI_CONNECT, { 'SQLITE3', dir_exe() + FILE_NAME_SQL } )

  if glob_mo()[ _MO_KOD_FFOMS ] == '340342' // для РУСАЛа
    dbUseArea( .T., , 'select * from f037 where mcod==340177', 'f037' )
  else
    dbUseArea( .T., , 'select * from f037 where mcod==' + glob_mo()[ _MO_KOD_FFOMS ], 'f037' )
  endif

  If f037->( LastRec() ) == 0
    func_error( 4, 'Пустой справочник лицензий' )
  Else
    alpha_browse( 2, 1, 7, 40, 'f1edit_licenses_f037', color0, , , , , , , 'f2edit_licenses_f037', , ;
      { '═', '░', '═', 'N/BG,W+/N,B/BG,BG+/B,N+/BG,W/N', .t. } )
  Endif
  f037->( dbCloseArea() )

  rddSetDefault( 'DBFNTX' )
  Select ( tmp_select )
  rest_box( buf )

  return nil

// 04.08.26
Function f1edit_licenses_f037( oBrow )

  Local oColumn

  oColumn := TBColumnNew( 'Номер лицензии', {|| f037->N_DOC } )
  oBrow:addcolumn( oColumn )
  status_key( '^<Esc>^ выход ^<Enter>^ просмотр' )
  Return Nil

// 10.09.26
Function f2edit_licenses_f037( nKey, oBrow )

  Local oBr, ret := -1

  local aLic := {}
  local aAddr := {}
  local tmpSelect := Select()

  oBr := oBrow
  Do Case
  Case nKey == K_ENTER

    if glob_mo()[ _MO_KOD_FFOMS ] == '340342' // для РУСАЛа
      dbUseArea( .T., , 'select * from f038 where uidmo==34202616601 group by idaddress', 'f038' )
//      dbUseArea( .T., , 'select * from f038 where uidmo==34202616601', 'f038' )
    else
      dbUseArea( .T., , 'select * from f038 where uidmo==' + f037->UIDMO + ' group by idaddress', 'f038' )
    endif

    f038->( dbGoTop() )
    If f038->( LastRec() ) == 0
      func_error( 4, 'Пустой справочник адресов' )
    Else
      alpha_browse( 4, 2, MaxRow() - 1, 78, 'f1edit_lic_addr_f038', color0, , , , , , , 'f2edit_lic_addr_f038', , ;
        { '═', '░', '═', 'N/BG,W+/N,B/BG,BG+/B,N+/BG,W/N', .t. } )
    Endif

    f038->( dbCloseArea() )
    Select ( tmpSelect )

  Case nKey == K_F9

  Endcase
  Return ret

// 04.08.26
Function f1edit_lic_addr_f038( oBrow )

  Local oColumn

  oColumn := TBColumnNew( 'Адрес расположения', {|| Padr( StrTran( f038->ADDR, 'Волгоградская область, ', '' ), 75 ) } )
  oBrow:addcolumn( oColumn )

  status_key( '^<Esc>^ выход ^<Enter>^ просмотр отделений' )
  Return Nil

// 07.08.26
Function f2edit_lic_addr_f038( nKey, oBrow )

  Local ret := -1

  local tmp_select := Select()

  Do Case
  CASE nKey == K_LEFT
    oBrow:left()
  CASE nKey == K_RIGHT
    oBrow:right()
  Case nKey == K_ENTER

    dbUseArea( .T., , 'select * from f033', 'f033' )
    dbUseArea( .T., , 'select f033.nam_sk, f038.uidspmo, f038.idaddress from f038, f033 where f038.uidspmo = f033.uidspmo and f038.idaddress==' + str( f038->IDADDRESS, 19 ), 'otd' )

    otd->( dbGoTop() )
    If otd->( LastRec() ) == 0
      func_error( 4, 'Пустой справочник отделений' )
    Else
      alpha_browse( 4, 2, MaxRow() - 1, 78, 'f1edit_addr_otd', color0, , , , , , , 'f2edit_addr_otd', , ;
        { '═', '░', '═', 'N/BG,W+/N,B/BG,BG+/B,N+/BG,W/N', .t. } )
    Endif

    otd->( dbCloseArea() )
    f033->( dbCloseArea() )

    Select ( tmp_select )
  Endcase

  Return ret

// 07.08.26
Function f1edit_addr_otd( oBrow )

  Local oColumn

  oColumn := TBColumnNew( 'Отделение "ГИС ОМС"', {|| Padr( otd->NAM_SK, 75 ) } )
  oBrow:addcolumn( oColumn )

  status_key( '^<Esc>^ выход ^<Enter>^ просмотр профилей' )
  Return Nil

// 08.08.26
Function f2edit_addr_otd( nKey, oBrow )

  Local oBr, ret := -1
  local tmp_select := Select()

  oBr := oBrow
  Do Case
  Case nKey == K_ENTER
    dbUseArea( .T., , 'select mpvid, mpusl, mprof from f034 where uidspmo==' + otd->uidspmo + ' and idaddress==' + str( otd->IDADDRESS, 19 ), 'f034' )

    f034->( dbGoTop() )
    If f034->( LastRec() ) == 0
      func_error( 4, 'Пустой справочник видов, условий и профилей медицинской помощи' )
    Else
      alpha_browse( 9, 2, 20, 78, 'f1edit_otd_f034', color0, , , , , , , 'f2edit_otd_f034', , ;
        { '═', '░', '═', 'N/BG,W+/N,B/BG,BG+/B,N+/BG,W/N', .t. } )
    Endif
    f034->( dbCloseArea() )
    Select ( tmp_select )
  Endcase

  Return ret

// 08.08.26
Function f1edit_otd_f034( oBrow )

  Local oColumn

  oColumn := TBColumnNew( 'Вид, условия и профиль медицинской помощи в "ГИС ОМС"', ;
    { || padr( AllTrim( inieditspr( A__MENUVERT, getv008(), f034->MPVID ) ) ;
      + ', ' + AllTrim( inieditspr( A__MENUVERT, getv006(), f034->MPUSL ) ) ;
      + ', ' + AllTrim( inieditspr( A__MENUVERT, getv002(), f034->MPROF ) ), 75 ) } )
  oBrow:addcolumn( oColumn )

  status_key( '^<Esc>^ выход' )
  Return Nil

// 08.08.26
Function f2edit_otd_f034( nKey, oBrow )

  Local oBr, ret := -1
  local tmp_select := Select()

  oBr := oBrow
  Do Case
  Case nKey == K_ENTER
  Endcase

  Return ret
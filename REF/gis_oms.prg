// различные функции справочников ГИС ОМС - gis_oms.prg
#include 'set.ch'
#include 'getexit.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'tfile.ch'

// 29.03.26
function gis_oms() 

  local buf
  local sbase, org_mcod, tmp_select := Select()
  local aDbf, k

  aDbf := { ;
    { 'N_DOC', 'C', 32, 0 }, ;
    { 'IDMO',  'C', 17, 0 }, ;
    { 'UIDMO', 'C', 17, 0 }, ;
    { 'MCOD',  'C',  6, 0 } ;
  }
  dbCreate( cur_dir() + 'tmp_f037', aDbf )
  Use ( cur_dir() + 'tmp_f037' ) new

  sbase := '_mo_f037'
  org_mcod := glob_mo()[ _MO_KOD_FFOMS ]
  r_use( dir_exe() + sbase, cur_dir() + sbase, 'F037' )
  f037->( dbGoTop() )
  do while f037->MCOD == org_mcod .and. ! f037->( Eof() )
    tmp_f037->( dbAppend() )
    tmp_f037->N_DOC := AllTrim( f037->N_DOC )
    tmp_f037->IDMO := f037->IDMO
    tmp_f037->UIDMO := f037->UIDMO
    tmp_f037->MCOD := f037->MCOD
    f037->( dbSkip() )
  enddo
  f037->( dbCloseArea() )
  Select tmp_f037
  k := tmp_f037->( LastRec() )

  buf := save_maxrow()

  If k == 0
    func_error( 4, 'Пустой справочник лицензий' )
  Else
    alpha_browse( 2, 1, 7, 40, 'f1edit_licenses', color0, , , , , , , 'f2edit_licenses', , ;
      { '═', '░', '═', 'N/BG,W+/N,B/BG,BG+/B,N+/BG,W/N', .t. } )
  Endif
  tmp_f037->( dbCloseArea() )
  Select ( tmp_select )

  rest_box( buf )

  return nil

// 30.03.26
Function f1edit_licenses( oBrow )

  Local oColumn

  oColumn := TBColumnNew( 'Номер лицензии', {|| tmp_f037->N_DOC } )
  oBrow:addcolumn( oColumn )
  status_key( '^<Esc>^ выход ^<Enter>^ просмотр' )
  Return Nil

// 30.03.26
Function f2edit_licenses( nKey, oBrow )

  Local fl := .f., ret := -1

  local sbase, tmp_select := Select()
  local aDbf, k

  Do Case
  Case nKey == K_ENTER

    aDbf := { ;
      { 'ADDR',     'C', 250, 0 }, ;
      { 'IDADDRESS','N',  19, 0 }, ;
      { 'N_DOC',    'C',  32, 0 }, ;
      { 'UIDMO',    'C',  17, 0 }, ;
      { 'UIDSPMO',  'C',  17, 0 } ;
    }
    dbCreate( cur_dir() + 'tmp_f038', aDbf, , .t., 'tmp_f038' )
    Index ON str( FIELD->IDADDRESS, 19 ) to ( cur_dir() + 'tmp_f038' )

    sbase := '_mo_f038'
    r_use( dir_exe() + sbase, cur_dir() + sbase, 'F038' )
    f038->( dbSeek( tmp_f037->UIDMO ) )
    do while f038->UIDMO == tmp_f037->UIDMO .and. ! f038->( Eof() )
      tmp_f038->( dbSeek( str( f038->IDADDRESS, 19 ) ) )
      if ! tmp_f038->( Found() )
        tmp_f038->( dbAppend() )
        tmp_f038->ADDR := AllTrim( SubStr( f038->ADDR, 9 ) )
        tmp_f038->N_DOC := AllTrim( f038->N_DOC )
        tmp_f038->IDADDRESS := f038->IDADDRESS
        tmp_f038->UIDMO := f038->UIDMO
        tmp_f038->UIDSPMO := f038->UIDSPMO
      endif
      f038->( dbSkip() )
    enddo
    Select tmp_f038
    k := tmp_f038->( LastRec() )
    tmp_f038->( dbGoTop() )

    If k == 0
      func_error( 4, 'Пустой справочник адресов' )
    Else
      alpha_browse( 4, 2, MaxRow() - 1, 78, 'f1edit_lic_addr', color0, , , , , , , 'f2edit_lic_addr', , ;
        { '═', '░', '═', 'N/BG,W+/N,B/BG,BG+/B,N+/BG,W/N', .t. } )
    Endif

    f038->( dbCloseArea() )

    tmp_f038->( dbCloseArea() )
    Select ( tmp_select )

  Endcase
  Return ret

// 30.03.26
Function f1edit_lic_addr( oBrow )

  Local oColumn

  oColumn := TBColumnNew( 'Адрес расположения', {|| StrTran( tmp_f038->ADDR, 'Волгоградская область, ', '' ) } )
  oBrow:addcolumn( oColumn )

  status_key( '^<Esc>^ выход ^<Enter>^ просмотр отделений' )
  Return Nil

// 30.03.26
Function f2edit_lic_addr( nKey, oBrow )

  Local fl := .f., ret := -1

  local sbase, tmp_select := Select()
  local aDbf, k

  Do Case
  CASE nKey == K_LEFT
    oBrow:left()
  CASE nKey == K_RIGHT
    oBrow:right()
  Case nKey == K_ENTER
    sbase := '_mo_f033'
    r_use( dir_exe() + sbase, cur_dir() + sbase, 'F033' )

    select f038
    Set Index To
    Index ON str( FIELD->IDADDRESS, 19 ) to ( cur_dir() + 'tmp_f038_addr' )
    aDbf := { ;
      { 'IDADDRESS','N',  19, 0 }, ;
      { 'UIDMO',    'C',  17, 0 }, ;
      { 'UIDSPMO',  'C',  17, 0 }, ;
      { 'NAME',     'C',  80, 0 } ;
    }
    dbCreate( cur_dir() + 'tmp_otd', aDbf, , .t., 'tmp_otd' )
    select f038
    f038->( dbSeek( str( tmp_f038->IDADDRESS, 19 ) ) )
    do while f038->IDADDRESS == tmp_f038->IDADDRESS .and. ! f038->( Eof() )
      tmp_otd->( dbAppend() )
      tmp_otd->UIDSPMO := f038->UIDSPMO
      tmp_otd->UIDMO := f038->UIDMO
      tmp_otd->IDADDRESS := f038->IDADDRESS
      f033->( dbSeek( f038->UIDSPMO ))
      if f033->( Found() )
        tmp_otd->NAME := f033->NAM_SK
      endif
      f038->( dbSkip() )
    enddo
    f033->( dbCloseArea() )

    Select tmp_otd
    k := tmp_otd->( LastRec() )
    tmp_otd->( dbGoTop() )

    If k == 0
      func_error( 4, 'Пустой справочник отделений' )
    Else
      alpha_browse( 6, 5, 20, 75, 'f1edit_addr_otd', color0, , , , , , , 'f2edit_addr_otd', , ;
        { '═', '░', '═', 'N/BG,W+/N,B/BG,BG+/B,N+/BG,W/N', .t. } )
    Endif

    tmp_otd->( dbCloseArea() )
    Select ( tmp_select )
  Endcase

  Return ret

// 30.03.26
Function f1edit_addr_otd( oBrow )

  Local oColumn

  oColumn := TBColumnNew( 'Отделение "ГИС ОМС"', {|| tmp_otd->NAME } )
  oBrow:addcolumn( oColumn )

  status_key( '^<Esc>^ выход ^<Enter>^ просмотр профилей' )
  Return Nil

// 30.03.26
Function f2edit_addr_otd( nKey, oBrow )

  Local fl := .f., ret := -1

  local sbase, tmp_select := Select()
  local aDbf, k

  Do Case
  Case nKey == K_ENTER
    aDbf := { ;
      { 'OPIS',     'C',  80, 0 }, ;
      { 'IDADDRESS','N',  19, 0 }, ;
      { 'UIDSPMO',  'C',  17, 0 }, ;
      { 'MPVID',    'N',   4, 0 }, ;
      { 'MPUSL',    'N',   2, 0 }, ;
      { 'MPROF',    'N',   3, 0 } ;
    }
    dbCreate( cur_dir() + 'tmp_f034', aDbf, , .t., 'tmp_f034' )

    sbase := '_mo_f034'
    r_use( dir_exe() + sbase, cur_dir() + sbase, 'F034' )
    f034->( dbSeek( tmp_otd->UIDSPMO + str( tmp_otd->IDADDRESS, 19 ) ) )
    do while f034->IDADDRESS == tmp_otd->IDADDRESS .and. f034->UIDSPMO == tmp_otd->UIDSPMO .and. ! f034->( Eof() )
      tmp_f034->( dbAppend() )
      tmp_f034->UIDSPMO   := f034->UIDSPMO
      tmp_f034->IDADDRESS := f034->IDADDRESS
      tmp_f034->MPVID     := f034->MPVID
      tmp_f034->MPUSL     := f034->MPUSL
      tmp_f034->MPROF     := f034->MPROF
      tmp_f034->OPIS      := AllTrim( inieditspr( A__MENUVERT, getv008(), f034->MPVID ) ) ;
        + ', ' + AllTrim( inieditspr( A__MENUVERT, getv006(), f034->MPUSL ) ) ;
        + ', ' + AllTrim( inieditspr( A__MENUVERT, getv002(), f034->MPROF ) )
      f034->( dbSkip() )
    enddo
    f034->( dbCloseArea() )
    Select tmp_f034
    k := tmp_f034->( LastRec() )
    tmp_f034->( dbGoTop() )

    If k == 0
      func_error( 4, 'Пустой справочник видов, условий и профилей медицинской помощи' )
    Else
      //ret := fget_tmp_f034( r, c, , 'Выбор профиля' )
      alpha_browse( 9, 2, 20, 78, 'f1edit_otd_mp', color0, , , , , , , 'f2edit_otd_mp', , ;
        { '═', '░', '═', 'N/BG,W+/N,B/BG,BG+/B,N+/BG,W/N', .t. } )
    Endif
    tmp_f034->( dbCloseArea() )
    Select ( tmp_select )
  Endcase

  Return ret

// 30.03.26
Function f1edit_otd_mp( oBrow )

  Local oColumn

  oColumn := TBColumnNew( 'Вид, условия и профиль медицинской помощи в "ГИС ОМС"', {|| tmp_f034->OPIS } )
  oBrow:addcolumn( oColumn )

  status_key( '^<Esc>^ выход' )
  Return Nil

// 30.03.26
Function f2edit_otd_mp( nKey, oBrow )

  Local fl := .f., ret := -1

  local tmp_select := Select()

  Do Case
  Case nKey == K_ENTER
  Endcase

  Return ret

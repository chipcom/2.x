// различные функции справочников ГИС ОМС - gis_oms.prg
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 29.03.26
function gis_oms()

  local ret

  If ( ret := input_lic( T_ROW -1, T_COL + 5 ) ) == NIL
    Return Nil
  else
    if ( ret := input_lic_addr( T_ROW -1, T_COL + 5, ret[ 2 ] ) ) == NIL
      Return Nil
    else
      input_lic_addr_prof( T_ROW -1, T_COL + 5, ret[ 1 ], ret[ 2 ] )
    endif
  Endif

  return nil

// 29.03.26
function input_lic_addr_prof( r, c, mIDADDRESS, mUIDSPMO )

  local ret, sbase, tmp_select := Select()
  local aDbf, k

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
  f034->( dbSeek( mUIDSPMO + str( mIDADDRESS, 19 ) ) )
  do while f034->IDADDRESS == mIDADDRESS .and. f034->UIDSPMO == mUIDSPMO .and. ! f034->( Eof() )
    tmp_f034->( dbAppend() )
    tmp_f034->UIDSPMO := f034->UIDSPMO
    tmp_f034->IDADDRESS := f034->IDADDRESS
    tmp_f034->MPVID := f034->MPVID
    tmp_f034->MPUSL := f034->MPUSL
    tmp_f034->MPROF := f034->MPROF
    tmp_f034->OPIS := AllTrim( inieditspr( A__MENUVERT, getv008(), f034->MPVID ) ) ;
      + ', ' + AllTrim( inieditspr( A__MENUVERT, getv006(), f034->MPUSL ) ) ;
      + ', ' + AllTrim( inieditspr( A__MENUVERT, getv002(), f034->MPROF ) )
    f034->( dbSkip() )
  enddo
  f034->( dbCloseArea() )
  Select tmp_f034
  k := tmp_f034->( LastRec() )

  If k == 0
    func_error( 4, 'Пустой справочник профилей' )
  Else
    ret := fget_tmp_f034( r, c, , 'Выбор профиля' )
  Endif

  tmp_f034->( dbCloseArea() )
  Select ( tmp_select )

  return ret

// 29.03.26 в GET'е выбрать значение из TMP_F038.DBF
Function fget_tmp_f034( r, c, name_base, browTitle )

  Local ret, cRec, kolRec, nRec, len1, len2, t_arr[ BR_LEN ]

  Default name_base To 'tmp_f034', browTitle To 'Наименование'
  kolRec := LastRec()
  len1 := FieldLen( 1 )
  len2 := FieldLen( 2 )
  If r <= MaxRow() / 2
    t_arr[ BR_TOP ] := r + 1
    If ( t_arr[ BR_BOTTOM ] := t_arr[ BR_TOP ] + kolRec + 3 ) > MaxRow() -2
      t_arr[ BR_BOTTOM ] := MaxRow() - 2
    Endif
  Else
    t_arr[ BR_BOTTOM ] := r -1
    If ( t_arr[ BR_TOP ] := t_arr[ BR_BOTTOM ] - kolRec -3 ) < 1
      t_arr[ BR_TOP ] := 1
    Endif
  Endif
  t_arr[ BR_LEFT ] := c
  If ( t_arr[ BR_RIGHT ] := c + len1 + 3 ) > 77
    t_arr[ BR_RIGHT ] := 77
    t_arr[ BR_LEFT ] := t_arr[ BR_RIGHT ] - len1 -3
    If t_arr[ BR_LEFT ] < 2
      t_arr[ BR_LEFT ] := 2
    Endif
  Endif
  len1 := t_arr[ BR_RIGHT ] - t_arr[ BR_LEFT ] - 3
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_ARR_BROWSE ] := {, , , 'N/BG,W+/N,B/BG,W+/B', .f. }
  t_arr[ BR_COLUMN ] := { { Center( browTitle, len1 ), {|| Left( tmp_f034->OPIS, len1 ) } } }
  t_arr[ BR_ENTER ] := {|| ret := tmp_f034->MPROF }
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход;  ^<Enter>^ - выбор' ) }
  nRec := 0
  tmp_f034->( dbGoTop() )   //  Go Top
  If nRec > 0
    If kolRec - nRec < t_arr[ BR_BOTTOM ] - t_arr[ BR_TOP ] -3 // последняя страница?
      Keyboard Chr( K_END ) + Replicate( Chr( K_UP ), kolRec - nRec - 1 )
    Else
      tmp_f034->( dbGoto( cRec ) )    //  Goto ( cRec )
    Endif
  Endif
  edit_browse( t_arr )

  Return ret

// 29.03.26
function input_lic_addr( r, c, mUIDMO )

  local ret, sbase, tmp_select := Select()
  local aDbf, k

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
  f038->( dbSeek( mUIDMO ) )
  do while f038->UIDMO == mUIDMO .and. ! f038->( Eof() )
//    tmp_f038->( dbSeek( str( f038->IDADDRESS, 19 ) ) )
//    if ! tmp_f038->( Found() )
      tmp_f038->( dbAppend() )
      tmp_f038->ADDR := AllTrim( SubStr( f038->ADDR, 9 ) )
      tmp_f038->N_DOC := AllTrim( f038->N_DOC )
      tmp_f038->IDADDRESS := f038->IDADDRESS
      tmp_f038->UIDMO := f038->UIDMO
      tmp_f038->UIDSPMO := f038->UIDSPMO
//    endif
    f038->( dbSkip() )
  enddo
  f038->( dbCloseArea() )
  Select tmp_f038
  k := tmp_f038->( LastRec() )

  If k == 0
    func_error( 4, 'Пустой справочник адресов' )
  Else
    ret := fget_tmp_f038( r, c, , 'Выбор адреса' )
  Endif

  tmp_f038->( dbCloseArea() )
  Select ( tmp_select )

  return ret

// 29.03.26 в GET'е выбрать значение из TMP_F038.DBF
Function fget_tmp_f038( r, c, name_base, browTitle )

  Local ret, cRec, kolRec, nRec, len1, len2, t_arr[ BR_LEN ]

  Default name_base To 'tmp_f038', browTitle To 'Наименование'
  kolRec := LastRec()
  len1 := FieldLen( 1 )
  len2 := FieldLen( 2 )
  If r <= MaxRow() / 2
    t_arr[ BR_TOP ] := r + 1
    If ( t_arr[ BR_BOTTOM ] := t_arr[ BR_TOP ] + kolRec + 3 ) > MaxRow() -2
      t_arr[ BR_BOTTOM ] := MaxRow() - 2
    Endif
  Else
    t_arr[ BR_BOTTOM ] := r -1
    If ( t_arr[ BR_TOP ] := t_arr[ BR_BOTTOM ] - kolRec -3 ) < 1
      t_arr[ BR_TOP ] := 1
    Endif
  Endif
  t_arr[ BR_LEFT ] := c
  If ( t_arr[ BR_RIGHT ] := c + len1 + 3 ) > 77
    t_arr[ BR_RIGHT ] := 77
    t_arr[ BR_LEFT ] := t_arr[ BR_RIGHT ] - len1 -3
    If t_arr[ BR_LEFT ] < 2
      t_arr[ BR_LEFT ] := 2
    Endif
  Endif
  len1 := t_arr[ BR_RIGHT ] - t_arr[ BR_LEFT ] - 3
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_ARR_BROWSE ] := {, , , 'N/BG,W+/N,B/BG,W+/B', .f. }
  t_arr[ BR_COLUMN ] := { { Center( browTitle, len1 ), {|| Left( tmp_f038->ADDR, len1 ) } } }
  t_arr[ BR_ENTER ] := {|| ret := { tmp_f038->IDADDRESS, tmp_f038->UIDSPMO } }
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход;  ^<Enter>^ - выбор' ) }
  nRec := 0
  tmp_f038->( dbGoTop() )   //  Go Top
  If nRec > 0
    If kolRec - nRec < t_arr[ BR_BOTTOM ] - t_arr[ BR_TOP ] -3 // последняя страница?
      Keyboard Chr( K_END ) + Replicate( Chr( K_UP ), kolRec - nRec - 1 )
    Else
      tmp_f038->( dbGoto( cRec ) )    //  Goto ( cRec )
    Endif
  Endif
  edit_browse( t_arr )

  Return ret

// 29.03.26
function input_lic( r, c )

  local ret, sbase, org_mcod, tmp_select := Select()
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

  If k == 0
    func_error( 4, 'Пустой справочник лицензий' )
  Else
    ret := fget_tmp_f037( r, c, , 'Выбор лицензии' )
  Endif
  tmp_f037->( dbCloseArea() )
  Select ( tmp_select )

  return ret

// 29.03.26 в GET'е выбрать значение из TMP_F037.DBF
Function fget_tmp_f037( r, c, name_base, browTitle )

  Local ret, cRec, kolRec, nRec, len1, len2, t_arr[ BR_LEN ]

  Default name_base To 'tmp_f037', browTitle To 'Наименование'
  kolRec := LastRec()
  len1 := FieldLen( 1 )
  len2 := FieldLen( 2 )
  If r <= MaxRow() / 2
    t_arr[ BR_TOP ] := r + 1
    If ( t_arr[ BR_BOTTOM ] := t_arr[ BR_TOP ] + kolRec + 3 ) > MaxRow() -2
      t_arr[ BR_BOTTOM ] := MaxRow() - 2
    Endif
  Else
    t_arr[ BR_BOTTOM ] := r -1
    If ( t_arr[ BR_TOP ] := t_arr[ BR_BOTTOM ] - kolRec -3 ) < 1
      t_arr[ BR_TOP ] := 1
    Endif
  Endif
  t_arr[ BR_LEFT ] := c
  If ( t_arr[ BR_RIGHT ] := c + len1 + 3 ) > 77
    t_arr[ BR_RIGHT ] := 77
    t_arr[ BR_LEFT ] := t_arr[ BR_RIGHT ] - len1 -3
    If t_arr[ BR_LEFT ] < 2
      t_arr[ BR_LEFT ] := 2
    Endif
  Endif
  len1 := t_arr[ BR_RIGHT ] - t_arr[ BR_LEFT ] - 3
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_ARR_BROWSE ] := {, , , 'N/BG,W+/N,B/BG,W+/B', .f. }
  t_arr[ BR_COLUMN ] := { { Center( browTitle, len1 ), {|| Left( tmp_f037->N_DOC, len1 ) } } }
  t_arr[ BR_ENTER ] := {|| ret := { tmp_f037->IDMO, tmp_f037->UIDMO } }
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход;  ^<Enter>^ - выбор' ) }
  nRec := 0
  tmp_f037->( dbGoTop() )   //  Go Top
  If nRec > 0
    If kolRec - nRec < t_arr[ BR_BOTTOM ] - t_arr[ BR_TOP ] -3 // последняя страница?
      Keyboard Chr( K_END ) + Replicate( Chr( K_UP ), kolRec - nRec - 1 )
    Else
      tmp_f037->( dbGoto( cRec ) )    //  Goto ( cRec )
    Endif
  Endif
  edit_browse( t_arr )

  Return ret

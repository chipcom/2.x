// setupFFOMSref.prg - настройка используемых справочников ФФОМС
#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 18.01.26 Настройка справочников ФФОМС
Function nastr_sprav_ffoms( k )

  Static arr_spr, arr_spr_name, sk := 1
  Static arr_ref, arr_name
  Local str_sem, mas_pmt := {}, mas_msg := {}, mas_fun := {}, j

  Default k To 0
  Do Case
  Case k == 0
    If ! currentuser():isadmin()
      Return func_error( 4, err_admin() )
    Endif
    arr_ref := { ;
      'V002', ;
      'M003', ;
      'V020', ;
      'V006', ;
      'V034', ;
      'MethodINJ', ;
      'Implantant' ;
      }
    arr_name := { ;
      'ПРОФИЛЕЙ оказанной медицинской помощи', ;
      'ПРОФИЛЕЙ медицинской помощи МЗ РФ', ;
      'ПРОФИЛЕЙ КОЙКИ', ;
      'УСЛОВИЙ оказания медицинской помощи', ;
      'ЕДИНИЦ ИЗМЕРЕНИЯ', ;
      'ПУТЕЙ ВВЕДЕНИЯ', ;
      'ИМПЛАНТАНТОВ' ;
      }
    arr_spr_name := { ;
      'Классификатор ПРОФИЛЕЙ оказанной медицинской помощи', ;
      'Классификатор ПРОФИЛЕЙ медицинской помощи Минздрава РФ', ;
      'Классификатор ПРОФИЛЕЙ КОЙКИ', ;
      'Классификатор УСЛОВИЙ оказания медицинской помощи', ;
      'Классификатор ЕДИНИЦ ИЗМЕРЕНИЯ', ;
      'Классификатор ПУТЕЙ ВВЕДЕНИЯ лекарственных препаратов', ;
      'Классификатор ИМПЛАНТАНТОВ для использования' ;
      }

    arr_spr := arr_name   // подставим имена пунктов меню
    For j := 1 To Len( arr_spr )
      AAdd( mas_pmt, 'Настройка ' + arr_spr[ j ] )
      AAdd( mas_msg, arr_spr_name[ j ] )
      AAdd( mas_fun, 'nastr_sprav_FFOMS(' + lstr( j ) + ')' )
    Next
    popup_prompt( T_ROW, T_COL + 5, sk, mas_pmt, mas_msg, mas_fun )
  Case k > 0
    str_sem := 'Настройка ' + arr_spr[ k ]
    arr_spr := arr_ref  // подставим имена справочников
    If g_slock( str_sem )
      fnastr_sprav_ffoms( 0, arr_spr[ k ], arr_spr_name[ k ] )
      g_sunlock( str_sem )
    Else
      func_error( 4, err_slock() )
    Endif
    arr_spr := arr_name   // подставим имена пунктов меню
  Endcase
  If k > 0
    sk := k
  Endif

  Return Nil

//
Function fnastr_sprav_ffoms( k, _n, _m )

  Static sk := 1, _name, _msg
  Local mas_pmt, mas_msg, mas_fun

  Default k To 0
  Do Case
  Case k == 0
    _name := _n ; _msg := _m
    mas_pmt := { ;
      '~По организации', ;
      'По ~учреждению', ;
      'По ~отделению' ;
    }
    mas_msg := { ;
      'Настройка содержания классификатора ' + _name + ' в целом по организации', ;
      'Уточнение настройки классификатора ' + _name + ' по учреждению', ;
      'Уточнение настройки классификатора ' + _name + ' по отделению' ;
    }
    mas_fun := { ;
      'fnastr_sprav_FFOMS(1)', ;
      'fnastr_sprav_FFOMS(2)', ;
      'fnastr_sprav_FFOMS(3)' ;
    }
    popup_prompt( T_ROW, T_COL + 5, sk, mas_pmt, mas_msg, mas_fun )
  Case k == 1
    f1nastr_sprav_ffoms( 0, _name, _msg )
  Case k == 2
    If input_uch( T_ROW -1, T_COL + 5, sys_date ) != nil
      f1nastr_sprav_ffoms( 1, _name, _msg )
    Endif
  Case k == 3
    If input_uch( T_ROW -1, T_COL + 5, sys_date ) != Nil .and. ;
        input_otd( T_ROW -1, T_COL + 5, sys_date ) != NIL
      f1nastr_sprav_ffoms( 2, _name, _msg )
    Endif
  Endcase
  If k > 0
    sk := k
  Endif

  Return Nil

// 21.04.23
Function f1nastr_sprav_ffoms( reg, _name, _msg )

  Local buf, t_arr[ BR_LEN ], blk, len1, sKey, s, arr, arr1, arr2, fl := .t.

  Private name_arr := 'get' + _name + '()', ob_kol, p_blk

  If Upper( _name ) == 'V034'
    name_arr := 'get_ed_izm()'
  Elseif Upper( _name ) == 'IMPLANTANT'
    name_arr := 'get_implantant()'
  Endif

  If !init_tmp_glob_array(, &name_arr, sys_date, .f. )
    Return Nil
  Endif
  Use ( cur_dir() + 'tmp_ga' ) new
  ob_kol := LastRec()
  sKey := lstr( reg )
  s := 'Настройка по '
  Do Case
  Case reg == 0
    s += 'организации'
  Case reg == 1
    sKey += '-' + lstr( glob_uch[ 1 ] )
    s += 'учреждению "' + glob_uch[ 2 ] + '"'
  Case reg == 2
    sKey += "-" + lstr( glob_otd[ 1 ] )
    s += 'отделению "' + glob_otd[ 2 ] + '"'
  Endcase
  //
  If ( fl := semaphor_tools_ini( 1 ) )
    arr := getinivar( tools_ini(), { { _name, '0', '' } } )
    arr := list2arr( arr[ 1 ] )
    If Len( arr ) > 0
      ob_kol := Len( arr )
      tmp_ga->( dbEval( {|| tmp_ga->is := ( AScan( arr, kod ) > 0 ) } ) )
    Endif
    If reg > 0
      If Empty( arr )
        fl := func_error( 4, 'Сначала необходимо сохранить настройку классификатора по ОРГАНИЗАЦИИ' )
      Else
        Delete For !tmp_ga->is
        Pack
        //
        arr1 := getinivar( tools_ini(), { { _name, '1-' + lstr( glob_uch[ 1 ] ), '' } } )
        arr1 := list2arr( arr1[ 1 ] )
        If Len( arr1 ) > 0
          ob_kol := Len( arr1 )
          tmp_ga->( dbEval( {|| tmp_ga->is := ( AScan( arr1, kod ) > 0 ) } ) )
        Endif
      Endif
      If fl .and. reg == 2
        If Empty( arr1 )
          fl := func_error( 4, 'Сначала необходимо сохранить настройку классификатора по УЧРЕЖДЕНИЮ' )
        Else
          Delete For !tmp_ga->is
          Pack
          //
          arr2 := getinivar( tools_ini(), { { _name, sKey, '' } } )
          arr2 := list2arr( arr2[ 1 ] )
          If Len( arr2 ) > 0
            ob_kol := Len( arr2 )
            tmp_ga->( dbEval( {|| tmp_ga->is := ( AScan( arr2, kod ) > 0 ) } ) )
          Endif
        Endif
      Endif
    Endif
    semaphor_tools_ini( 2 )
  Endif
  If !fl
    Close databases
    Return Nil
  Endif
  Index On Upper( name ) to ( cur_dir() + 'tmp_ga' )
  buf := SaveScreen()
  box_shadow( 0, 50, 2, 77, color1 )
  p_blk := {|| SetPos( 1, 51 ), DispOut( PadC( 'Выбрано строк: ' + lstr( ob_kol ), 26 ), color8 ) }
  blk := {|| iif( tmp_ga->is, { 1, 2 }, { 3, 4 } ) }
  Eval( p_blk )
  //
  t_arr[ BR_TOP ] := 4
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := 2
  t_arr[ BR_RIGHT ] := 77
  len1 := t_arr[ BR_RIGHT ] - t_arr[ BR_LEFT ] -3 -4
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := _name + ' ' + _msg
  t_arr[ BR_TITUL_COLOR ] := 'B/BG'
  t_arr[ BR_FL_NOCLEAR ] := .t.
  t_arr[ BR_ARR_BROWSE ] := {, , , 'N/BG,W+/N,B/BG,W+/B', .t. }
  t_arr[ BR_COLUMN ] := { { ' ', {|| iif( tmp_ga->is, '', ' ' ) }, blk }, ;
    { Center( s, len1 ), {|| PadR( tmp_ga->name, len1 ) }, blk } }
  t_arr[ BR_EDIT ] := {| nk, ob| f2nastr_sprav_ffoms( nk, ob, 'edit' ) }
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход;  ^<+,-,Ins>^ - отметить;  ^<F2>^ - поиск по подстроке' ) }
  Go Top
  edit_browse( t_arr )
  Eval( p_blk )
  If f_esc_enter( 'записи настройки' )
    arr := {}
    tmp_ga->( dbEval( {|| iif( tmp_ga->is, AAdd( arr, tmp_ga->kod ), nil ) } ) )
    If semaphor_tools_ini( 1 )
      setinivar( tools_ini(), { { _name, sKey, arr2list( arr ) } } )
      semaphor_tools_ini( 2 )
    Endif
  Endif
  Close databases
  RestScreen( buf )

  Return Nil

//
Function f2nastr_sprav_ffoms( nKey, oBrow, regim )

  Local k := -1, rec, fl

  If regim == 'edit'
    Do Case
    Case nKey == K_F2
      k := f1get_tmp_ga( nKey, oBrow, regim )
    Case nkey == K_INS
      Replace tmp_ga->is With !tmp_ga->is
      If tmp_ga->is
        ob_kol++
      Else
        ob_kol--
      Endif
      Eval( p_blk )
      k := 0
      Keyboard Chr( K_TAB )
    Case nkey == 43 .or. nkey == 45  // + или -
      fl := ( nkey == 43 )
      rec := RecNo()
      tmp_ga->( dbEval( {|| tmp_ga->is := fl } ) )
      Goto ( rec )
      If fl
        ob_kol := tmp_ga->( LastRec() )
      Else
        ob_kol := 0
      Endif
      Eval( p_blk )
      k := 0
    Endcase
  Endif

  Return k

// 18.10.22 сформировать справочник по настройке организации/учреждения/отделения
Function create_classif_ffoms( reg, _name )

  // reg - возврат кслассификатора для 0-организации/1-учреждения/2-отделения
  Local i, k, arr, arr1, arr2, fl := .t., ret := {}, ret1

  Private name_arr := 'get' + _name + '()'
  //
  If Upper( _name ) == 'V034'
    name_arr := 'get_ed_izm()'
  Elseif Upper( _name ) == 'IMPLANTANT'
    name_arr := 'get_implantant()'
  Endif

  arr := getinivar( local_tools_ini(), { { _name, '0', '' } } )
  arr := list2arr( arr[ 1 ] )
  If Len( arr ) > 0
    ret := AClone( arr )
    If reg > 0
      arr1 := getinivar( local_tools_ini(), { { _name, '1-' + lstr( glob_uch[ 1 ] ), '' } } )
      arr1 := list2arr( arr1[ 1 ] )
      If ( k := Len( arr1 ) ) > 0
        For i := k To 1 Step -1
          If AScan( ret, arr1[ i ] ) == 0
            del_array( arr1, i )
          Endif
        Next
        ret := AClone( arr1 )
      Endif
      If reg == 2
        arr2 := getinivar( local_tools_ini(), { { _name, '2-' + lstr( glob_otd[ 1 ] ), '' } } )
        arr2 := list2arr( arr2[ 1 ] )
        If ( k := Len( arr2 ) ) > 0
          For i := k To 1 Step -1
            If AScan( ret, arr2[ i ] ) == 0
              del_array( arr2, i )
            Endif
          Next
          ret := AClone( arr2 )
        Endif
      Endif
    Endif
  Endif
  If Len( ret ) > 0
    ret1 := {}
    For i := 1 To Len( ret )
      If ( k := AScan( &name_arr, {| x| x[ 2 ] == ret[ i ] } ) ) > 0
        AAdd( ret1, &name_arr.[ k ] )
      Endif
    Next
  Elseif Upper( _name ) == 'V002'
    ret1 := AClone( getv002() )
  Else
    ret1 := cut_glob_array( &name_arr, sys_date )
  Endif
  ASort( ret1, , , {| x, y| Upper( x[ 1 ] ) < Upper( y[ 1 ] ) } )

  Return ret1

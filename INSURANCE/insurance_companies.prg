// insurance_companies.prg - функции работы со страховыми компаниями
#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'
#include 'edit_spr.ch'

// 02.06.25 справочник страховых компаний в Волгоградской области
function smo_volgograd()

  static arr_smo

  if HB_ISNIL( arr_smo )
    arr_smo := { ;
      { 'АСП ООО "Капитал МС"-филиал в Волгоградской области',    34007, 1 }, ;
      { 'ОАО "СОГАЗ-Мед"',        34002, 1 }, ;
      { 'АО ВТБ Мед.страхование', 34003, 0 }, ;  // не работает
      { 'ООО "ВСК-Милосердие"',   34004, 0 }, ;  // не работает
      { 'КапиталЪ Медстрах',      34001, 0 }, ;
      { 'ООО "МСК-Максимус"',     34006, 0 }, ;
      { 'ТФОМС (иногородние)',   34, 1 } ;
    }
  Endif
  return arr_smo

// 15.09.25 справочник страховых компаний РФ
function glob_array_srf( dir_spavoch, working_dir )

  // dir_spavoch - каталог расположения справочников системы
  // working_dir - рабочий каталог в котором хранятся рабочие файлы пользователя

  static arr_srf
  local sbase, i

  if HB_ISNIL( arr_srf )
    sbase := '_mo_smo'
    arr_srf := {}
    r_use( dir_spavoch + sbase )
    Index On FIELD->okato to ( working_dir + sbase ) UNIQUE
    dbEval( {|| AAdd( arr_srf, { '', FIELD->okato } ) } )
    Index On FIELD->okato + FIELD->smo to ( working_dir + sbase )
    Index On FIELD->smo to ( working_dir + sbase + '2' )
    Index On FIELD->okato + FIELD->ogrn to ( working_dir + sbase + '3' )
    Use

    dbCreate( working_dir + 'tmp_srf', { { 'okato', 'C', 5, 0 }, { 'name', 'C', 80, 0 } } )
    Use ( working_dir + 'tmp_srf' ) New Alias TMP
    r_use( dir_spavoch + '_okator', working_dir + '_okatr', 'RE' )
    r_use( dir_spavoch + '_okatoo', working_dir + '_okato', 'OB' )
    For i := 1 To Len( arr_srf )
      ob->( dbSeek( arr_srf[ i, 2 ] ) )
      If ob->( Found() )
        arr_srf[ i, 1 ] := RTrim( ob->name )
      Else
        re->( dbSeek( Left( arr_srf[ i, 2 ], 2 ) ) )
        If re->( Found() )
          arr_srf[ i, 1 ] := RTrim( re->name )
        Elseif Left( arr_srf[ i, 2 ], 2 ) == '55'
          arr_srf[ i, 1 ] := 'г.Байконур'
        Endif
      Endif
      tmp->( dbAppend() )
      tmp->okato := arr_srf[ i, 2 ]
      tmp->name  := iif( SubStr( arr_srf[ i, 2 ], 3, 1 ) == '0', '', '  ' ) + arr_srf[ i, 1 ]
    Next
    OB->( dbCloseArea() )
    RE->( dbCloseArea() )
    TMP->( dbCloseArea() )
  endif
  return arr_srf

// 18.11.25 вернуть иногороднюю СМО
Function ret_inogsmo_name( ltip, /*@*/rec, fl_close)

  Local s := Space( 100 ), fl := .f., tmp_select := Select()

  Default fl_close To .f.
  If Select( 'SN' ) == 0
    r_use( dir_server() + iif( ltip == 1, 'mo_kismo', 'mo_hismo' ), , 'SN' )
    Index On Str( FIELD->kod, 7 ) to ( cur_dir() + 'tmp_ismo' )
    fl := .t.
  Endif
//  Select SN
  sn->( dbSeek( Str( iif( ltip == 1, kart->kod, human->kod ), 7 ) ) ) // find ( Str( iif( ltip == 1, kart->kod, human->kod ), 7 ) )
  If sn->( Found() )
    s := sn->SMO_NAME
    rec := sn->( RecNo() )
  Endif
  If fl .and. fl_close
    sn->( dbCloseArea() )
  Endif
  Select ( tmp_select )

  Return s

// 17.11.25 СМО на экран (печать)
Function smo_to_screen( ltip )

  Local s := '', s1 := '', lsmo, nsmo, lokato

  lsmo := iif( ltip == 1, kart_->smo, human_->smo )
  nsmo := Int( Val( lsmo ) )
  s := inieditspr( A__MENUVERT, smo_volgograd(), nsmo )
  If Empty( s ) .or. nsmo == 34
    If nsmo == 34
      s1 := ret_inogsmo_name( ltip, , .t. )
    Else
      s1 := init_ismo( lsmo )
    Endif
    If !Empty( s1 )
      s := AllTrim( s1 )
    Endif
    lokato := iif( ltip == 1, kart_->KVARTAL_D, human_->okato )
    If !Empty( lokato )
      s += '/' + inieditspr( A__MENUVERT, glob_array_srf(), lokato )
    Endif
  Endif

  Return s

// вернуть наименование иногородней СМО
Function init_ismo( lsmo )

  Local s := Space( 10 ), tmp_select

  If !Empty( lsmo )
    tmp_select := Select()
    r_use( dir_exe() + '_mo_smo', cur_dir() + '_mo_smo2', 'SMO' )
    smo->( dbSeek( PadR( lsmo, 5 ) ) )
    If smo->( Found() )
      s := RTrim( smo->name )
    Endif
    smo->( dbCloseArea() )
    Select ( tmp_select )
  Endif
  Return s

// вместо иногородней СМО подставить код ТФОМС
Function cut_code_smo( _smo )

  Local s := Space( 5 )

  If !Empty( _smo )
    If Left( _smo, 3 ) == '340'
      s := _smo
    Else
      s := '34   '
    Endif
  Endif
  Return s

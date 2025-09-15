#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

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